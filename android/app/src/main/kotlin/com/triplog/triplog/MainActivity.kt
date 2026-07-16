package com.triplog.triplog

import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.location.LocationManager
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.location.ActivityRecognition
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionRequest
import com.google.android.gms.location.DetectedActivity
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var transitionPendingIntent: PendingIntent? = null
    private var samplingPendingIntent: PendingIntent? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val messenger = flutterEngine.dartExecutor.binaryMessenger

        // ---- location tracking ----
        MethodChannel(messenger, "triplog/location").setMethodCallHandler { call, result ->
            when (call.method) {
                "startTracking" -> {
                    val profile = call.argument<String>("profile") ?: "moving"
                    val intent = Intent(this, TripTrackingService::class.java)
                        .setAction(TripTrackingService.ACTION_START)
                        .putExtra(TripTrackingService.EXTRA_PROFILE, profile)
                    startForegroundService(intent)
                    result.success(null)
                }
                "setProfile" -> {
                    val intent = Intent(this, TripTrackingService::class.java)
                        .setAction(TripTrackingService.ACTION_SET_PROFILE)
                        .putExtra(
                            TripTrackingService.EXTRA_PROFILE,
                            call.argument<String>("profile") ?: "moving",
                        )
                    startService(intent)
                    result.success(null)
                }
                "updateNotification" -> {
                    if (TripTrackingService.isRunning) {
                        val intent = Intent(this, TripTrackingService::class.java)
                            .setAction(TripTrackingService.ACTION_UPDATE_NOTIFICATION)
                            .putExtra(TripTrackingService.EXTRA_TITLE, call.argument<String>("title"))
                            .putExtra(TripTrackingService.EXTRA_BODY, call.argument<String>("body"))
                            .putExtra(TripTrackingService.EXTRA_PAUSED, call.argument<Boolean>("paused") ?: false)
                        startService(intent)
                    }
                    result.success(null)
                }
                "stopTracking" -> {
                    val intent = Intent(this, TripTrackingService::class.java)
                        .setAction(TripTrackingService.ACTION_STOP)
                    startService(intent)
                    result.success(null)
                }
                "isLocationServiceEnabled" -> {
                    val lm = getSystemService(Context.LOCATION_SERVICE) as LocationManager
                    result.success(
                        lm.isProviderEnabled(LocationManager.GPS_PROVIDER) ||
                            lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
                    )
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, "triplog/location_stream").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    EventStreams.locationSink = events
                }

                override fun onCancel(arguments: Any?) {
                    EventStreams.locationSink = null
                }
            },
        )

        EventChannel(messenger, "triplog/notification_actions").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    EventStreams.actionSink = events
                }

                override fun onCancel(arguments: Any?) {
                    EventStreams.actionSink = null
                }
            },
        )

        // ---- activity recognition ----
        MethodChannel(messenger, "triplog/activity").setMethodCallHandler { call, result ->
            when (call.method) {
                "isAvailable" -> {
                    val available = GoogleApiAvailability.getInstance()
                        .isGooglePlayServicesAvailable(this) == ConnectionResult.SUCCESS
                    result.success(available)
                }
                "start" -> startActivityRecognition(result)
                "stop" -> stopActivityRecognition(result)
                else -> result.notImplemented()
            }
        }

        EventChannel(messenger, "triplog/activity_stream").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    EventStreams.activitySink = events
                }

                override fun onCancel(arguments: Any?) {
                    EventStreams.activitySink = null
                }
            },
        )
    }

    private fun receiverPendingIntent(requestCode: Int): PendingIntent =
        PendingIntent.getBroadcast(
            this,
            requestCode,
            Intent(this, ActivityTransitionReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_MUTABLE,
        )

    private fun startActivityRecognition(result: MethodChannel.Result) {
        try {
            val client = ActivityRecognition.getClient(this)

            // Transition API: enter/exit for the activities the state machine
            // cares about.
            val transitions = mutableListOf<ActivityTransition>()
            for (type in listOf(
                DetectedActivity.IN_VEHICLE,
                DetectedActivity.WALKING,
                DetectedActivity.STILL,
                DetectedActivity.ON_BICYCLE,
                DetectedActivity.RUNNING,
            )) {
                for (transition in listOf(
                    ActivityTransition.ACTIVITY_TRANSITION_ENTER,
                    ActivityTransition.ACTIVITY_TRANSITION_EXIT,
                )) {
                    transitions.add(
                        ActivityTransition.Builder()
                            .setActivityType(type)
                            .setActivityTransition(transition)
                            .build(),
                    )
                }
            }
            transitionPendingIntent = receiverPendingIntent(10)
            samplingPendingIntent = receiverPendingIntent(11)
            client.requestActivityTransitionUpdates(
                ActivityTransitionRequest(transitions),
                transitionPendingIntent!!,
            )
            // Periodic sampled updates carry a confidence value the
            // transition API does not provide.
            client.requestActivityUpdates(20_000L, samplingPendingIntent!!)
            result.success(null)
        } catch (e: SecurityException) {
            result.error("PERMISSION_DENIED", e.message, null)
        } catch (e: Exception) {
            result.error("UNAVAILABLE", e.message, null)
        }
    }

    private fun stopActivityRecognition(result: MethodChannel.Result) {
        try {
            val client = ActivityRecognition.getClient(this)
            transitionPendingIntent?.let { client.removeActivityTransitionUpdates(it) }
            samplingPendingIntent?.let { client.removeActivityUpdates(it) }
            result.success(null)
        } catch (e: Exception) {
            result.error("UNAVAILABLE", e.message, null)
        }
    }
}
