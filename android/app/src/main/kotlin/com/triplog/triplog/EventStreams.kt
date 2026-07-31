package com.triplog.triplog

import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel

/**
 * Bridges native callbacks (service, broadcast receivers) to Flutter
 * EventChannels. Events arriving while Dart is not listening are buffered so
 * nothing is lost during engine startup.
 */
object EventStreams {
    private val mainHandler = Handler(Looper.getMainLooper())

    private const val MAX_BUFFER = 500

    /**
     * Location events buffer far more than the rest: when a trip is
     * auto-started by activity recognition while the app is closed, every
     * GPS point recorded until the user next opens the app lives here.
     * ~4000 points at a 3 s interval covers over 3 hours of driving.
     */
    private const val MAX_LOCATION_BUFFER = 4000

    var locationSink: EventChannel.EventSink? = null
        set(value) {
            field = value
            if (value != null) drain(locationBuffer, value)
        }
    private val locationBuffer = ArrayDeque<Map<String, Any?>>()

    var actionSink: EventChannel.EventSink? = null
        set(value) {
            field = value
            if (value != null) drainStrings(actionBuffer, value)
        }
    private val actionBuffer = ArrayDeque<String>()

    var activitySink: EventChannel.EventSink? = null
        set(value) {
            field = value
            if (value != null) drain(activityBuffer, value)
        }
    private val activityBuffer = ArrayDeque<Map<String, Any?>>()

    fun emitLocation(event: Map<String, Any?>) = mainHandler.post {
        locationSink?.success(event)
            ?: buffer(locationBuffer, event, MAX_LOCATION_BUFFER)
    }

    fun emitAction(action: String) = mainHandler.post {
        actionSink?.success(action) ?: run {
            if (actionBuffer.size < MAX_BUFFER) actionBuffer.addLast(action)
        }
    }

    fun emitActivity(event: Map<String, Any?>) = mainHandler.post {
        activitySink?.success(event) ?: buffer(activityBuffer, event)
    }

    private fun buffer(
        queue: ArrayDeque<Map<String, Any?>>,
        event: Map<String, Any?>,
        max: Int = MAX_BUFFER,
    ) {
        if (queue.size >= max) queue.removeFirst()
        queue.addLast(event)
    }

    private fun drain(queue: ArrayDeque<Map<String, Any?>>, sink: EventChannel.EventSink) {
        while (queue.isNotEmpty()) sink.success(queue.removeFirst())
    }

    private fun drainStrings(queue: ArrayDeque<String>, sink: EventChannel.EventSink) {
        while (queue.isNotEmpty()) sink.success(queue.removeFirst())
    }
}
