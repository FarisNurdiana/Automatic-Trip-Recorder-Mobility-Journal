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

    override fun onReceive(context: Context, intent: Intent) {
        if (ActivityTransitionResult.hasResult(intent)) {
            val result = ActivityTransitionResult.extractResult(intent) ?: return
            for (event in result.transitionEvents) {
                val transition = when (event.transitionType) {
                    ActivityTransition.ACTIVITY_TRANSITION_ENTER -> "enter"
                    ActivityTransition.ACTIVITY_TRANSITION_EXIT -> "exit"
                    else -> "sample"
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
