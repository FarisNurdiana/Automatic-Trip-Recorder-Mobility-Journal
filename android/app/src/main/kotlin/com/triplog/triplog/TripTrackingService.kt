package com.triplog.triplog

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.os.BatteryManager
import android.os.Build
import android.os.IBinder
import android.os.Looper
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.FusedLocationProviderClient
import com.google.android.gms.location.LocationCallback
import com.google.android.gms.location.LocationRequest
import com.google.android.gms.location.LocationResult
import com.google.android.gms.location.LocationServices
import com.google.android.gms.location.Priority

/**
 * Foreground service recording GPS fixes with the Fused Location Provider
 * while a trip is active. Shows a persistent notification with live stats and
 * Pause/Resume/Stop actions. Sampling interval follows the adaptive profile
 * requested from Dart (moving / slow / stopped).
 */
class TripTrackingService : Service() {

    companion object {
        const val ACTION_START = "com.triplog.START_TRACKING"
        const val ACTION_STOP = "com.triplog.STOP_TRACKING"
        const val ACTION_SET_PROFILE = "com.triplog.SET_PROFILE"
        const val ACTION_UPDATE_NOTIFICATION = "com.triplog.UPDATE_NOTIFICATION"
        const val ACTION_SCHEDULE_AUTO_STOP = "com.triplog.SCHEDULE_AUTO_STOP"
        const val ACTION_CANCEL_AUTO_STOP = "com.triplog.CANCEL_AUTO_STOP"
        const val ACTION_NOTIF_PAUSE = "com.triplog.NOTIF_PAUSE"
        const val ACTION_NOTIF_RESUME = "com.triplog.NOTIF_RESUME"
        const val ACTION_NOTIF_STOP = "com.triplog.NOTIF_STOP"
        const val ACTION_NOTIF_ARRIVED = "com.triplog.NOTIF_ARRIVED"
        const val ACTION_NOTIF_RESTING = "com.triplog.NOTIF_RESTING"
        const val ACTION_NOTIF_CONTINUE = "com.triplog.NOTIF_CONTINUE"

        const val EXTRA_PROFILE = "profile"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_PAUSED = "paused"
        const val EXTRA_QUESTION = "question"
        const val EXTRA_AUTO_STARTED = "autoStarted"

        private const val CHANNEL_ID = "triplog_tracking"
        private const val NOTIFICATION_ID = 100

        /**
         * How long after the driver stops being "in vehicle" an auto-started
         * background recording keeps running before shutting itself down.
         * Only applies while the Flutter side is dead — once the app is
         * opened, the Dart state machine owns the stop logic.
         */
        private const val AUTO_STOP_DELAY_MS = 8 * 60 * 1000L

        private const val ALARM_COOLDOWN_MS = 30_000L
        private const val ALARM_DURATION_MS = 10_000L

        @Volatile
        var isRunning = false

        /** True when activity recognition (not Dart) started this recording. */
        @Volatile
        var autoStarted = false

        /** Wall-clock time tracking started; 0 when not tracking. */
        var startedAtMillis: Long = 0
            private set
    }

    private lateinit var fusedClient: FusedLocationProviderClient
    private var currentProfile = "moving"
    private var lastTitle = "Perjalanan sedang direkam"
    private var lastBody = ""
    private var lastPaused = false
    private var lastQuestion = false
    private var lastAlarmAtMillis = 0L
    private val autoStopHandler = android.os.Handler(Looper.getMainLooper())
    private val autoStopRunnable = Runnable {
        if (isRunning && autoStarted && EventStreams.locationSink == null) {
            stopTracking()
        }
    }

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            val battery = batteryLevel()
            for (location in result.locations) {
                val event =
                    mapOf(
                        "timestampMs" to location.time,
                        "latitude" to location.latitude,
                        "longitude" to location.longitude,
                        "altitude" to if (location.hasAltitude()) location.altitude else null,
                        "horizontalAccuracy" to if (location.hasAccuracy()) location.accuracy.toDouble() else null,
                        "verticalAccuracy" to if (Build.VERSION.SDK_INT >= 26 && location.hasVerticalAccuracy()) location.verticalAccuracyMeters.toDouble() else null,
                        "speed" to if (location.hasSpeed()) location.speed.toDouble() else null,
                        "speedAccuracy" to if (Build.VERSION.SDK_INT >= 26 && location.hasSpeedAccuracy()) location.speedAccuracyMetersPerSecond.toDouble() else null,
                        "heading" to if (location.hasBearing()) location.bearing.toDouble() else null,
                        "headingAccuracy" to if (Build.VERSION.SDK_INT >= 26 && location.hasBearingAccuracy()) location.bearingAccuracyDegrees.toDouble() else null,
                        "source" to "fused",
                        "isMocked" to isMocked(location),
                        "batteryLevel" to battery,
                    )
                if (EventStreams.locationSink == null) {
                    // App closed: persist to disk (survives process death)
                    // and run the over-speed alarm natively, since the Dart
                    // side that normally does both is not alive.
                    BackgroundTrackStore.append(this@TripTrackingService, event)
                    maybeFireBackgroundSpeedAlarm(location)
                }
                EventStreams.emitLocation(event)
            }
        }
    }

    /**
     * Over-speed warning for background-recorded trips. Mirrors the Dart
     * implementation: reads the user's speed-limit setting, fires the loud
     * alarm for 10 s, then stays quiet for a 30 s cooldown.
     */
    private fun maybeFireBackgroundSpeedAlarm(location: android.location.Location) {
        if (!location.hasSpeed()) return
        val limitKmh = readSpeedLimitKmh() ?: return
        val speedKmh = location.speed * 3.6
        if (speedKmh <= limitKmh) return
        val now = System.currentTimeMillis()
        if (now - lastAlarmAtMillis < ALARM_COOLDOWN_MS) return
        lastAlarmAtMillis = now
        SpeedAlarmPlayer.start(this, ALARM_DURATION_MS)
    }

    /**
     * Reads flutter.speedLimitKmh from the shared_preferences plugin store.
     * The Android plugin encodes doubles as a Base64-prefixed string
     * ("This is the prefix for Double."), so every plausible representation
     * is handled. Null when the warning is disabled.
     */
    private fun readSpeedLimitKmh(): Double? {
        val raw = getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
            .all["flutter.speedLimitKmh"] ?: return null
        val value = when (raw) {
            is Double -> raw
            is Float -> raw.toDouble()
            is Long -> Double.fromBits(raw)
            is String -> raw
                .removePrefix("VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu")
                .toDoubleOrNull()
            else -> null
        } ?: return null
        return if (value > 0 && value < 1000) value else null
    }

    private fun isMocked(location: android.location.Location): Boolean =
        if (Build.VERSION.SDK_INT >= 31) location.isMock else @Suppress("DEPRECATION") location.isFromMockProvider

    private fun batteryLevel(): Double? {
        val bm = getSystemService(Context.BATTERY_SERVICE) as? BatteryManager ?: return null
        val level = bm.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        return if (level in 0..100) level / 100.0 else null
    }

    override fun onCreate() {
        super.onCreate()
        fusedClient = LocationServices.getFusedLocationProviderClient(this)
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null) {
            // START_STICKY restart after a process kill: without an intent
            // there is nothing to resume — the persisted background track
            // (if any) will be imported when the app next opens.
            stopSelf()
            return START_NOT_STICKY
        }
        when (intent.action) {
            ACTION_START -> {
                currentProfile = intent.getStringExtra(EXTRA_PROFILE) ?: "moving"
                startForegroundWithNotification()
                requestUpdates()
                autoStopHandler.removeCallbacks(autoStopRunnable)
                if (!isRunning) {
                    startedAtMillis = System.currentTimeMillis()
                    autoStarted = intent.getBooleanExtra(EXTRA_AUTO_STARTED, false)
                    if (autoStarted) {
                        BackgroundTrackStore.begin(this, startedAtMillis)
                    } else {
                        // Dart started this itself: it is alive and persists
                        // points to its own database.
                        BackgroundTrackStore.suspended = true
                    }
                }
                isRunning = true
            }
            ACTION_SCHEDULE_AUTO_STOP -> {
                if (isRunning && autoStarted && EventStreams.locationSink == null) {
                    autoStopHandler.removeCallbacks(autoStopRunnable)
                    autoStopHandler.postDelayed(autoStopRunnable, AUTO_STOP_DELAY_MS)
                }
            }
            ACTION_CANCEL_AUTO_STOP -> {
                autoStopHandler.removeCallbacks(autoStopRunnable)
            }
            ACTION_SET_PROFILE -> {
                currentProfile = intent.getStringExtra(EXTRA_PROFILE) ?: currentProfile
                if (isRunning) requestUpdates()
            }
            ACTION_UPDATE_NOTIFICATION -> {
                lastTitle = intent.getStringExtra(EXTRA_TITLE) ?: lastTitle
                lastBody = intent.getStringExtra(EXTRA_BODY) ?: lastBody
                lastPaused = intent.getBooleanExtra(EXTRA_PAUSED, lastPaused)
                lastQuestion = intent.getBooleanExtra(EXTRA_QUESTION, false)
                if (isRunning) {
                    val manager = getSystemService(NotificationManager::class.java)
                    manager.notify(NOTIFICATION_ID, buildNotification())
                }
            }
            ACTION_NOTIF_PAUSE -> EventStreams.emitAction("pause")
            ACTION_NOTIF_RESUME -> EventStreams.emitAction("resume")
            ACTION_NOTIF_STOP -> EventStreams.emitAction("stop")
            ACTION_NOTIF_ARRIVED -> EventStreams.emitAction("arrived")
            ACTION_NOTIF_RESTING -> EventStreams.emitAction("resting")
            ACTION_NOTIF_CONTINUE -> EventStreams.emitAction("continue")
            ACTION_STOP -> {
                stopTracking()
                return START_NOT_STICKY
            }
        }
        return START_STICKY
    }

    private fun intervalForProfile(): Long = when (currentProfile) {
        "moving" -> 3_000L
        "slow" -> 7_000L
        else -> 20_000L
    }

    private fun requestUpdates() {
        if (ActivityCompat.checkSelfPermission(this, android.Manifest.permission.ACCESS_FINE_LOCATION)
            != PackageManager.PERMISSION_GRANTED
        ) {
            stopTracking()
            return
        }
        fusedClient.removeLocationUpdates(locationCallback)
        val request = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, intervalForProfile())
            .setMinUpdateIntervalMillis(intervalForProfile() / 2)
            .setWaitForAccurateLocation(false)
            .build()
        fusedClient.requestLocationUpdates(request, locationCallback, Looper.getMainLooper())
    }

    private fun stopTracking() {
        isRunning = false
        autoStarted = false
        startedAtMillis = 0
        autoStopHandler.removeCallbacks(autoStopRunnable)
        fusedClient.removeLocationUpdates(locationCallback)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Perekaman perjalanan",
            NotificationManager.IMPORTANCE_LOW,
        ).apply {
            description = "Menunjukkan bahwa perjalanan sedang direkam"
            setShowBadge(false)
        }
        getSystemService(NotificationManager::class.java).createNotificationChannel(channel)
    }

    private fun servicePendingIntent(action: String, requestCode: Int): PendingIntent =
        PendingIntent.getService(
            this,
            requestCode,
            Intent(this, TripTrackingService::class.java).setAction(action),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )

    private fun buildNotification(): Notification {
        val contentIntent = packageManager.getLaunchIntentForPackage(packageName)?.let {
            PendingIntent.getActivity(
                this, 0, it,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }
        val builder = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(lastTitle)
            .setContentText(lastBody)
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentIntent)
            .setCategory(NotificationCompat.CATEGORY_NAVIGATION)
        if (lastQuestion) {
            // Stationary-stop question: answer directly from the notification.
            builder.addAction(0, "Sudah sampai", servicePendingIntent(ACTION_NOTIF_ARRIVED, 4))
            builder.addAction(0, "Istirahat", servicePendingIntent(ACTION_NOTIF_RESTING, 5))
            builder.addAction(0, "Lanjutkan", servicePendingIntent(ACTION_NOTIF_CONTINUE, 6))
        } else {
            if (lastPaused) {
                builder.addAction(0, "Lanjutkan", servicePendingIntent(ACTION_NOTIF_RESUME, 1))
            } else {
                builder.addAction(0, "Pause", servicePendingIntent(ACTION_NOTIF_PAUSE, 2))
            }
            builder.addAction(0, "Stop", servicePendingIntent(ACTION_NOTIF_STOP, 3))
        }
        return builder.build()
    }

    private fun startForegroundWithNotification() {
        val notification = buildNotification()
        if (Build.VERSION.SDK_INT >= 29) {
            startForeground(
                NOTIFICATION_ID,
                notification,
                ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION,
            )
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
    }

    override fun onDestroy() {
        isRunning = false
        autoStarted = false
        startedAtMillis = 0
        autoStopHandler.removeCallbacks(autoStopRunnable)
        fusedClient.removeLocationUpdates(locationCallback)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
