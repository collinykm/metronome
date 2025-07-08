package com.example.metronome_app

import android.os.Bundle
import android.os.Handler
import android.os.HandlerThread
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.media.AudioAttributes
import android.media.SoundPool
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine



import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import androidx.activity.ComponentActivity
import kotlinx.coroutines.*
import kotlin.math.PI
import kotlin.math.sin

class MainActivity: FlutterActivity() {
    private val CHANNEL = "metronome_channel"

    private val metronomeScope = CoroutineScope(Dispatchers.Default + SupervisorJob())


    private var tempo = 120
    private var accentsList = mutableListOf(1, 1, 1, 1)
    private var meter = mutableListOf(4, 1)
    private var subdivision = mutableListOf(1, 1)
    private var isPlaying = false

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // This method is invoked on the main thread.
                call, result ->
            when(call.method) {
                "playMetronome" -> {
                    metronomeScope.launch {
                        playMetronome()
                        result.success(null)
                    }
                }
                "pauseMetronome" -> {
                    isPlaying = false
                }
                "updateTempo" -> {
                    val newTempo = call.arguments as Int
                    println("here's the new tempo: $newTempo")
                    tempo = newTempo
                    result.success(null)
                }
                "updateAccent" -> {
                    val newAccents = call.arguments as MutableList<Int>
                    println("here's the new accents: $newAccents")
                    accentsList = newAccents
                    result.success(null)
                }
                "updateMeter" -> {
                    val newMeter = call.arguments as MutableList<Int>
                    println("here's the new meter: $newMeter")
                    meter = newMeter
                    result.success(null)
                }
                "updateSubdivision" -> {
                    val newSubdivision = call.arguments as MutableList<Int>
                    println("here's the new subdivision: $newSubdivision")
                    subdivision = newSubdivision
                    result.success(null)
                }
                else -> result.notImplemented()

            }

        }
    }


    override fun onDestroy() {
        super.onDestroy()
        metronomeScope.cancel() // prevent leaks
    }


    private fun playMetronome() {
        if (isPlaying) {
            return
        }
        isPlaying = true

        val sampleRate = 44100
        val clickDurationMs = 30
        val clickSamples = (clickDurationMs * sampleRate / 1000)


        val accent3Click = generateClick(clickSamples, sampleRate, frequency = 2000.0, volume = 1.0)
        val accent2Click = generateClick(clickSamples, sampleRate, frequency = 1600.0, volume = 0.8)
        val normalClick = generateClick(clickSamples, sampleRate, frequency = 1000.0, volume = 0.6)
        val silentClick = generateClick(clickSamples, sampleRate, frequency = 1000.0, volume = 0.0)

        val clicksList = arrayOf(silentClick, normalClick, accent2Click, accent3Click)

        val track = AudioTrack(
            AudioManager.STREAM_MUSIC,
            sampleRate,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            AudioTrack.getMinBufferSize(
                sampleRate,
                AudioFormat.CHANNEL_OUT_MONO,
                AudioFormat.ENCODING_PCM_16BIT
            ),
            AudioTrack.MODE_STREAM
        )

        track.play()


        try {
            var currentPulse = 0
            while (isPlaying) {
                val beatIntervalSec = 60f / ( tempo * subdivision[0])
                val beatIntervalSamples = (beatIntervalSec * sampleRate).toInt()
                val silenceSamples = beatIntervalSamples - clickSamples
                val silence = ShortArray(silenceSamples) { 0 }

                var currentBeat = (currentPulse / subdivision[0]) % meter[0] + 1
                var pulseInBeat = currentPulse % subdivision[0] + 1
                lateinit var click: ShortArray

                if (currentPulse % subdivision[0] == 0) {

                    println("in the if statement here: ")
                    println("accents list: $accentsList")
                    println("subdivision list: $subdivision")
                    println("currentBeat: $currentBeat")
                    println("pulseInBeat: $pulseInBeat")
                    println("_______________________\n")




                    click = clicksList[accentsList[currentBeat - 1] * subdivision[pulseInBeat]]
                } else {
                    click = clicksList[subdivision[pulseInBeat]]
                }



                track.write(click, 0, click.size)
                track.write(silence, 0, silence.size)
                currentPulse = (currentPulse + 1) % (meter[0] * subdivision[0]);

            }
        } finally {
            track.stop()
            track.release()
        }


    }

    fun generateClick(length: Int, sampleRate: Int, frequency: Double, volume: Double): ShortArray {
        val buffer = ShortArray(length)
        for (i in 0 until length) {
            val fadeOut = 1.0 - i.toDouble() / length
            val amp = Short.MAX_VALUE * volume * fadeOut
            buffer[i] = (amp * sin(2 * PI * frequency * i / sampleRate)).toInt().toShort()
        }
        return buffer
    }

    private fun pauseMetronome() {

    }


}

