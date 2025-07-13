package com.example.metronome_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine



import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import kotlin.math.PI
import kotlin.math.sin

class MainActivity: FlutterActivity() {
    private val METHODCHANNEL = "metronome_method_channel"
    private val EVENTCHANNEL = "metronome_event_channel"
    private var eventSink: EventChannel.EventSink? = null

    private val metronomeScope = CoroutineScope(Dispatchers.Default + SupervisorJob())


    private var tempo = 120
    private var accentsList = mutableListOf(1, 1, 1, 1)
    private var meter = mutableListOf(4, 1)
    private var subdivision = mutableListOf(1, 1)
    private var isMetronomePlaying = false
    private var isSongPlaying = false



    val sampleRate = 44100
    val clickDurationMs = 30
    val clickSamples = (clickDurationMs * sampleRate / 1000)

    val accent3Click = generateClick(clickSamples, sampleRate, frequency = 2000.0, volume = 1.0)
    val accent2Click = generateClick(clickSamples, sampleRate, frequency = 1600.0, volume = 0.8)
    val normalClick = generateClick(clickSamples, sampleRate, frequency = 1000.0, volume = 0.6)
    val silentClick = generateClick(clickSamples, sampleRate, frequency = 1000.0, volume = 0.0)

    val clicksList = arrayOf(silentClick, normalClick, accent2Click, accent3Click)
    //sets up some audio stuff


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHODCHANNEL).setMethodCallHandler {
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
                    isMetronomePlaying = false
                }

                "playSong" -> {
                    metronomeScope.launch {
                        var song = call.arguments as Map<String, Any>
                        println("the song that was passed in :$song")
                        playSong(song)
                        result.success(null)
                    }
                }
                "pauseSong" ->  {
                    isSongPlaying = false
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
                else -> {
                    result.notImplemented()
                }

            }

        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTCHANNEL).setStreamHandler(
            object: EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    this@MainActivity.eventSink = events

                }

                override fun onCancel(arguments: Any?) {
                    this@MainActivity.eventSink = null
                }
            }
        )
    }


    override fun onDestroy() {
        super.onDestroy()
        metronomeScope.cancel() // prevent leaks
    }


    private fun playMetronome() {
        println("i got called here")
        if (isMetronomePlaying) {
            return
        }
        isMetronomePlaying = true

        val metronomeTrack = AudioTrack(
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
        metronomeTrack.play()
        CoroutineScope(Dispatchers.Default).launch {
            println("maybe here")
            try {
                var currentPulse = 0
                while (isMetronomePlaying) {
                    val beatIntervalSec = 60f / ( tempo * subdivision[0])
                    val beatIntervalSamples = (beatIntervalSec * sampleRate).toInt()
                    val silenceSamples = beatIntervalSamples - clickSamples
                    val silence = ShortArray(silenceSamples) { 0 }

                    val currentBeat = (currentPulse / subdivision[0]) % meter[0] + 1
                    val pulseInBeat = currentPulse % subdivision[0] + 1
                    lateinit var click: ShortArray

                    if (currentPulse % subdivision[0] == 0) {

                        click = clicksList[accentsList[currentBeat - 1] * subdivision[pulseInBeat]]
                    } else {
                        click = clicksList[subdivision[pulseInBeat]]
                    }

                    withContext(Dispatchers.Main) {
                        eventSink?.success(currentBeat);
                    }
                    println("has to be here")

                    metronomeTrack.write(click, 0, click.size)
                    metronomeTrack.write(silence, 0, silence.size)
                    currentPulse = (currentPulse + 1) % (meter[0] * subdivision[0])

                }
            } finally {
                metronomeTrack.stop()
                metronomeTrack.release()
            }
        }


    }

/*

song = {
    "songId": songId,
    "songName": songName,
    "sectionsList": [
        {
          "sectionName": sectionName,
          "bars": bars,
          "tempo": tempo,
          "accentsList": accentsList,
          "meter": meter,
          "subdivision": subdivision
        }
    ]

}

 */

    private fun playSong(song: Map<String, Any>) {
        if (isSongPlaying) {
            return
        }
        isSongPlaying = true
        val sectionsList = song["sectionsList"] as List<Map<String, Any>>


        val songTrack = AudioTrack(
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
        songTrack.play()
        try {

            for (section in sectionsList) {
                val sectionTempo = section["tempo"] as Int
                val sectionBars = section["bars"] as Int
                val sectionAccentsList = section["accentsList"] as List<Int>
                val sectionMeter = section["meter"] as List<Int>
                val sectionSubdivision = section["subdivision"] as List<Int>

                val beatIntervalSec = 60f / ( sectionTempo * sectionSubdivision[0])
                val beatIntervalSamples = (beatIntervalSec * sampleRate).toInt()
                val silenceSamples = beatIntervalSamples - clickSamples
                val silence = ShortArray(silenceSamples) { 0 }
                val totalPulses = sectionBars * sectionMeter[0] * sectionSubdivision[0]



                var currentPulse = 0
                for (i in 0 until totalPulses) {
                    if (isSongPlaying == false) {return}
                    println("is song playing: $isSongPlaying")
                    val currentBeat = (currentPulse / sectionSubdivision[0]) % sectionMeter[0] + 1
                    val pulseInBeat = currentPulse % sectionSubdivision[0] + 1

                    lateinit var click: ShortArray

                    if (currentPulse % sectionSubdivision[0] == 0) {

                        click = clicksList[sectionAccentsList[currentBeat - 1] * sectionSubdivision[pulseInBeat]]
                    } else {
                        click = clicksList[sectionSubdivision[pulseInBeat]]
                    }

                    songTrack.write(click, 0, click.size)
                    songTrack.write(silence, 0, silence.size)
                    currentPulse = (currentPulse + 1) % (sectionMeter[0] * sectionSubdivision[0])
                }
            }

        } finally {
            songTrack.stop()
            songTrack.release()
            isSongPlaying = false
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




}

