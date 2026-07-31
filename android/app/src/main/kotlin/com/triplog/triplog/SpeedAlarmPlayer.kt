package com.triplog.triplog

import android.content.Context
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.RingtoneManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

/**
 * Plays the device's alarm sound at alarm volume while vibrating, for a
 * bounded duration — the over-speed warning. USAGE_ALARM makes the sound
 * follow the alarm volume stream, so it stays loud even when media volume
 * is low, which is exactly what a safety warning needs.
 */
object SpeedAlarmPlayer {
    private val mainHandler = Handler(Looper.getMainLooper())
    private var player: MediaPlayer? = null
    private var vibrator: Vibrator? = null
    private val stopRunnable = Runnable { stop() }

    fun start(context: Context, durationMs: Long) {
        stop()
        val appContext = context.applicationContext
        try {
            val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_RINGTONE)
                ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            if (uri != null) {
                player = MediaPlayer().apply {
                    setDataSource(appContext, uri)
                    setAudioAttributes(
                        AudioAttributes.Builder()
                            .setUsage(AudioAttributes.USAGE_ALARM)
                            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                            .build(),
                    )
                    isLooping = true
                    prepare()
                    start()
                }
            }
        } catch (_: Exception) {
            player = null
        }
        try {
            val vib = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                val manager = appContext.getSystemService(Context.VIBRATOR_MANAGER_SERVICE)
                    as VibratorManager
                manager.defaultVibrator
            } else {
                @Suppress("DEPRECATION")
                appContext.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
            }
            vib.vibrate(
                VibrationEffect.createWaveform(
                    longArrayOf(0, 500, 200, 500, 200),
                    0,
                ),
            )
            vibrator = vib
        } catch (_: Exception) {
            vibrator = null
        }
        mainHandler.removeCallbacks(stopRunnable)
        mainHandler.postDelayed(stopRunnable, durationMs)
    }

    fun stop() {
        mainHandler.removeCallbacks(stopRunnable)
        try {
            player?.stop()
            player?.release()
        } catch (_: Exception) {
        }
        player = null
        try {
            vibrator?.cancel()
        } catch (_: Exception) {
        }
        vibrator = null
    }
}
