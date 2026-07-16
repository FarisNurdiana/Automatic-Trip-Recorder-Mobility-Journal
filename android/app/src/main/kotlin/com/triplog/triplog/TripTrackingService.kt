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
        const val ACTION_NOTIF_PAUSE = "com.triplog.NOTIF_PAUSE"
        const val ACTION_NOTIF_RESUME = "com.triplog.NOTIF_RESUME"
        const val ACTION_NOTIF_STOP = "com.triplog.NOTIF_STOP"

        const val EXTRA_PROFILE = "profile"
        const val EXTRA_TITLE = "title"
        const val EXTRA_BODY = "body"
        const val EXTRA_PAUSED = "paused"

        private const val CHANNEL_ID = "triplog_tracking"
        private const val NOTIFICATION_ID = 100

        @Volatile
        var isRunning = false
            private set
    }

    private lateinit var fusedClient: FusedLocationProviderClient
    private var currentProfile = "moving"
    private var lastTitle = "Perjalanan sedang direkam"
    private var lastBody = ""
    private var lastPaused = false

    private val locationCallback = object : LocationCallback() {
        override fun onLocationResult(result: LocationResult) {
            val battery = batteryLevel()
            for (location in result.locations) {
                EventStreams.emitLocation(
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
                )
            }
        }
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
        when (intent?.action) {
            ACTION_START -> {
                currentProfile = intent.getStringExtra(EXTRA_PROFILE) ?: "moving"
                startForegroundWithNotification()
                requestUpdates()
                isRunning = true
            }
            ACTION_SET_PROFILE -> {
                currentProfile = intent.getStringExtra(EXTRA_PROFILE) ?: currentProfile
                if (isRunning) requestUpdates()
            }
            ACTION_UPDATE_NOTIFICATION -> {
                lastTitle = intent.getStringExtra(EXTRA_TITLE) ?: lastTitle
                lastBody = intent.getStringExtra(EXTRA_BODY) ?: lastBody
                lastPaused = intent.getBooleanExtra(EXTRA_PAUSED, lastPaused)
                if (isRunning) {
                    val manager = getSystemService(NotificationManager::class.java)
                    manager.notify(NOTIFICATION_ID, buildNotification())
                }
            }
            ACTION_NOTIF_PAUSE -> EventStreams.emitAction("pause")
            ACTION_NOTIF_RESUME -> EventStreams.emitAction("resume")
            ACTION_NOTIF_STOP -> EventStreams.emitAction("stop")
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
        if (lastPaused) {
            builder.addAction(0, "Lanjutkan", servicePendingIntent(ACTION_NOTIF_RESUME, 1))
        } else {
            builder.addAction(0, "Pause", servicePendingIntent(ACTION_NOTIF_PAUSE, 2))
        }
        builder.addAction(0, "Stop", servicePendingIntent(ACTION_NOTIF_STOP, 3))
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
        fusedClient.removeLocationUpdates(locationCallback)
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
