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
import kotlin.math.abs
import kotlin.math.sin

class MainActivity: FlutterActivity() {
    private val METHODCHANNEL = "metronome_method_channel"
    private val EVENTCHANNEL = "metronome_event_channel"
    private var eventSink: EventChannel.EventSink? = null

    private val metronomeScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    private val songScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
    private val refNoteScope = CoroutineScope(Dispatchers.Default + SupervisorJob())


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


    private var isRefNotePlaying = false
    private var refFreq = 440.0


    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine)  {
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
                    result.success(null)
                }

                "playSong" -> {
                    songScope.launch {
                        var song = call.arguments as Map<String, Any>
                        playSong(song)
                        result.success(null)
                    }
                }
                "pauseSong" ->  {
                    isSongPlaying = false
                    result.success(null)
                }

                "updateTempo" -> {
                    val newTempo = call.arguments as Int
                    tempo = newTempo
                    result.success(null)
                }
                "updateAccent" -> {
                    val newAccents = call.arguments as MutableList<Int>
                    accentsList = newAccents
                    result.success(null)
                }
                "updateMeter" -> {
                    val newMeter = call.arguments as MutableList<Int>
                    meter = newMeter
                    result.success(null)
                }
                "updateSubdivision" -> {
                    val newSubdivision = call.arguments as MutableList<Int>
                    subdivision = newSubdivision
                    result.success(null)
                }
                "playRefNote" -> {
                    print("message received")
                    refNoteScope.launch {
                        playRefNote()
                    }
                }
                "updateRefNote" -> {
                    val newFreq = call.arguments as Double
                    refFreq = newFreq
                    currentFreq = newFreq
                    println("\n\n currentFreq has been set to $currentFreq")

                    result.success(null)
                    
                }
                "pauseRefNote" -> {
                    shouldStop = true
                    isRefNotePlaying = false
                    audioJob?.cancel()
                    audioJob = null
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






    private var audioJob: Job? = null
    private var refNoteTrack: AudioTrack? = null

    // Make these volatile so they can be safely updated from other threads
    @Volatile private var currentFreq = 0.0
    @Volatile private var shouldStop = false

    fun playRefNote() {
        if (isRefNotePlaying) return

        isRefNotePlaying = true
        shouldStop = false
        currentFreq = refFreq

        // Create AudioTrack once
        refNoteTrack = AudioTrack(
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

        refNoteTrack?.play()

        // Single coroutine that runs until stopped
        audioJob = CoroutineScope(Dispatchers.Default).launch {
            try {
                var phase = 0.0
                val bufferSize = sampleRate / 100 // 10ms buffers
                val volume = 0.3f
                println("\n\n playing frequency $currentFreq\n\n")

                while (!shouldStop) {
                    // Calculate phase increment based on current frequency
                    val phaseIncrement = 2.0 * Math.PI * currentFreq / sampleRate

                    val buffer = ShortArray(bufferSize)
                    for (i in buffer.indices) {
                        val sample = (Math.sin(phase) * volume * Short.MAX_VALUE).toInt()
                        buffer[i] = sample.coerceIn(Short.MIN_VALUE.toInt(), Short.MAX_VALUE.toInt()).toShort()
                        phase += phaseIncrement

                        // Keep phase in reasonable range
                        if (phase >= 2.0 * Math.PI) {
                            phase -= 2.0 * Math.PI
                        }
                    }

                    refNoteTrack?.write(buffer, 0, bufferSize)
                }
            } finally {
                refNoteTrack?.stop()
                refNoteTrack?.release()
                refNoteTrack = null
                isRefNotePlaying = false
            }
        }
    }

    private fun playMetronome() {
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
                        eventSink?.success(mapOf("type" to "metronome", "beat" to currentBeat))
                    }

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
        CoroutineScope(Dispatchers.Default).launch {
            try {
                while (isSongPlaying){
                    for (section in sectionsList) {
                        if (!isSongPlaying){break}
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
                            if (!isSongPlaying){break}
                            val currentBeat = (currentPulse / sectionSubdivision[0]) % sectionMeter[0] + 1
                            val pulseInBeat = currentPulse % sectionSubdivision[0] + 1

                            lateinit var click: ShortArray

                            if (currentPulse % sectionSubdivision[0] == 0) {

                                click = clicksList[sectionAccentsList[currentBeat - 1] * sectionSubdivision[pulseInBeat]]
                            } else {
                                click = clicksList[sectionSubdivision[pulseInBeat]]
                            }
                            withContext(Dispatchers.Main) {
                                eventSink?.success(mapOf("type" to "song", "beat" to currentBeat, "section" to section["sectionId"]))
                            }
                            songTrack.write(click, 0, click.size)
                            songTrack.write(silence, 0, silence.size)
                            currentPulse = (currentPulse + 1) % (sectionMeter[0] * sectionSubdivision[0])
                        }

                    }
                    isSongPlaying = false
                    withContext(Dispatchers.Main) {
                        eventSink?.success(mapOf("type" to "alert", "message" to "song ended"))
                    }

                }

            } finally {
                songTrack.stop()
                songTrack.release()
                isSongPlaying = false
            }
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

    fun generateSineWave(length: Int, sampleRate: Int, frequency: Double, volume: Double): ShortArray {
        val buffer = ShortArray(length)
        val amplitude = Short.MAX_VALUE * volume
        for (i in 0 until length) {
            buffer[i] = (amplitude * sin(2 * Math.PI * frequency * i / sampleRate)).toInt().toShort()
        }
        return buffer
    }




}

