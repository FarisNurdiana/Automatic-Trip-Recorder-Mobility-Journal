package com.triplog.triplog

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.google.android.gms.location.ActivityRecognitionResult
import com.google.android.gms.location.ActivityTransition
import com.google.android.gms.location.ActivityTransitionResult
import com.google.android.gms.location.DetectedActivity

/**
 * Receives both Activity Recognition Transition API results (enter/exit) and
 * periodic sampled ActivityRecognitionResult updates, then forwards them to
 * Flutter as normalized events.
 */
class ActivityTransitionReceiver : BroadcastReceiver() {

    companion object {
        fun mapActivityType(type: Int): String = when (type) {
            DetectedActivity.IN_VEHICLE -> "vehicle"
            DetectedActivity.ON_BICYCLE -> "cycling"
            DetectedActivity.WALKING, DetectedActivity.ON_FOOT -> "walking"
            DetectedActivity.RUNNING -> "running"
            DetectedActivity.STILL -> "still"
            else -> "unknown"
        }
    }

    /**
     * Starts the tracking service directly from the receiver so recording
     * begins even when the app process is dead. Guarded by the user's
     * auto-detection setting (read from Flutter's SharedPreferences) and
     * allowed from the background because the app holds
     * ACCESS_BACKGROUND_LOCATION. GPS points are buffered by the service
     * bridge and adopted by Dart the next time the app runs.
     */
    private fun autoStartTracking(context: Context) {
        if (TripTrackingService.isRunning) return
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences",
            Context.MODE_PRIVATE,
        )
        if (!prefs.getBoolean("flutter.autoDetection", true)) return
        try {
            context.startForegroundService(
                Intent(context, TripTrackingService::class.java)
                    .setAction(TripTrackingService.ACTION_START)
                    .putExtra(TripTrackingService.EXTRA_PROFILE, "moving")
                    .putExtra(TripTrackingService.EXTRA_AUTO_STARTED, true),
            )
        } catch (_: Exception) {
            // Some OEMs still block background FGS starts; the in-app
            // detection path keeps working regardless.
        }
    }

    /**
     * Auto-stop plumbing for auto-started background recordings: leaving
     * the vehicle (still/walking) arms a delayed stop in the service;
     * getting back in a vehicle cancels it. No-op while the app is alive —
     * the Dart state machine owns stops then (checked inside the service).
     */
    private fun sendAutoStopSignal(context: Context, action: String) {
        if (!TripTrackingService.isRunning || !TripTrackingService.autoStarted) {
            return
        }
        try {
            context.startService(
                Intent(context, TripTrackingService::class.java).setAction(action),
            )
        } catch (_: Exception) {
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (ActivityTransitionResult.hasResult(intent)) {
            val result = ActivityTransitionResult.extractResult(intent) ?: return
            for (event in result.transitionEvents) {
                val transition = when (event.transitionType) {
                    ActivityTransition.ACTIVITY_TRANSITION_ENTER -> "enter"
                    ActivityTransition.ACTIVITY_TRANSITION_EXIT -> "exit"
                    else -> "sample"
                }
                if (event.activityType == DetectedActivity.IN_VEHICLE &&
                    event.transitionType ==
                        ActivityTransition.ACTIVITY_TRANSITION_ENTER
                ) {
                    autoStartTracking(context)
                    sendAutoStopSignal(
                        context,
                        TripTrackingService.ACTION_CANCEL_AUTO_STOP,
                    )
                }
                if ((
                        event.activityType == DetectedActivity.STILL ||
                            event.activityType == DetectedActivity.WALKING ||
                            event.activityType == DetectedActivity.ON_FOOT
                        ) &&
                    event.transitionType ==
                        ActivityTransition.ACTIVITY_TRANSITION_ENTER
                ) {
                    sendAutoStopSignal(
                        context,
                        TripTrackingService.ACTION_SCHEDULE_AUTO_STOP,
                    )
                }
                // elapsedRealTimeNanos is relative to boot; convert to wall time.
                val eventUptimeMs = event.elapsedRealTimeNanos / 1_000_000
                val bootTimeMs =
                    System.currentTimeMillis() - android.os.SystemClock.elapsedRealtime()
                EventStreams.emitActivity(
                    mapOf(
                        "timestampMs" to (bootTimeMs + eventUptimeMs),
                        "activityType" to mapActivityType(event.activityType),
                        "transition" to transition,
                        "confidence" to null,
                        "platformSource" to "android",
                        "rawValue" to event.toString(),
                    )
                )
            }
        } else if (ActivityRecognitionResult.hasResult(intent)) {
            val result = ActivityRecognitionResult.extractResult(intent) ?: return
            val most = result.mostProbableActivity
            EventStreams.emitActivity(
                mapOf(
                    "timestampMs" to result.time,
                    "activityType" to mapActivityType(most.type),
                    "transition" to "sample",
                    "confidence" to most.confidence / 100.0,
                    "platformSource" to "android",
                    "rawValue" to result.probableActivities.joinToString {
                        "${mapActivityType(it.type)}:${it.confidence}"
                    },
                )
            )
        }
    }
}
