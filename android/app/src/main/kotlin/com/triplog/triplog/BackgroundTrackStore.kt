package com.triplog.triplog

import android.content.Context
import java.io.File
import org.json.JSONObject

/**
 * Persists GPS points recorded while the Flutter side is not listening
 * (trip auto-started with the app closed). Unlike the in-memory event
 * buffer, this survives the process being killed, so a whole background
 * trip can still be imported the next time the user opens the app.
 *
 * Format: JSON lines. A line with {"type":"start", ...} begins a new
 * segment (one segment per auto-started recording); every other line is a
 * location map with the same keys the live event stream uses.
 */
object BackgroundTrackStore {

    private const val FILE_NAME = "background_track.jsonl"

    /**
     * Set once Dart has consumed the file (it is alive and receives points
     * via the event stream from then on) or when Dart itself started the
     * tracker. Reset by [begin] when a new auto-start happens.
     */
    @Volatile
    var suspended = false

    private fun file(context: Context) = File(context.filesDir, FILE_NAME)

    /** Starts a new persisted segment for an auto-started recording. */
    @Synchronized
    fun begin(context: Context, startedAtMillis: Long) {
        suspended = false
        try {
            file(context).appendText(
                JSONObject(
                    mapOf("type" to "start", "startedAtMillis" to startedAtMillis),
                ).toString() + "\n",
            )
        } catch (_: Exception) {
        }
    }

    @Synchronized
    fun append(context: Context, event: Map<String, Any?>) {
        if (suspended) return
        try {
            val json = JSONObject()
            for ((key, value) in event) {
                json.put(key, value ?: JSONObject.NULL)
            }
            file(context).appendText(json.toString() + "\n")
        } catch (_: Exception) {
        }
    }

    /**
     * Returns all persisted lines and deletes the file. Further appends are
     * suspended: from this moment Dart is alive and the event stream (with
     * its in-memory buffer) is the delivery path.
     */
    @Synchronized
    fun consume(context: Context): List<String> {
        suspended = true
        return try {
            val f = file(context)
            if (!f.exists()) return emptyList()
            val lines = f.readLines().filter { it.isNotBlank() }
            f.delete()
            lines
        } catch (_: Exception) {
            emptyList()
        }
    }
}
