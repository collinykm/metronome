// MetronomeService.kt
package com.collinykm.metronome

import android.app.*
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.os.Binder
import android.os.Build
import android.os.IBinder
import android.os.PowerManager
import androidx.core.app.NotificationCompat
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import kotlin.math.PI
import kotlin.math.sin

class MetronomeService : Service() {
    companion object {
        const val CHANNEL_ID = "MetronomeServiceChannel"
        const val NOTIFICATION_ID = 1
        const val ACTION_START_METRONOME = "START_METRONOME"
        const val ACTION_STOP_METRONOME = "STOP_METRONOME"
        const val ACTION_START_SONG = "START_SONG"
        const val ACTION_STOP_SONG = "STOP_SONG"
        const val ACTION_START_REF_NOTE = "START_REF_NOTE"
        const val ACTION_STOP_REF_NOTE = "STOP_REF_NOTE"
    }

    private val binder = MetronomeBinder()
    private var wakeLock: PowerManager.WakeLock? = null

    // Event sink for communication back to Flutter
    var eventSink: EventChannel.EventSink? = null

    // Audio configuration - same as your original
    val sampleRate = 44100
    val clickDurationMs = 30
    val clickSamples = (clickDurationMs * sampleRate / 1000)

    // Pre-generated clicks - same as your original
    val accent3Click = generateClick(clickSamples, sampleRate, frequency = 2000.0, volume = 1.0)
    val accent2Click = generateClick(clickSamples, sampleRate, frequency = 1600.0, volume = 0.8)
    val normalClick = generateClick(clickSamples, sampleRate, frequency = 1000.0, volume = 0.6)
    val silentClick = generateClick(clickSamples, sampleRate, frequency = 1000.0, volume = 0.0)
    val clicksList = arrayOf(silentClick, normalClick, accent2Click, accent3Click)

    // Metronome state - same as your original
    private var tempo = 120
    private var accentsList = mutableListOf(1, 1, 1, 1)
    private var meter = mutableListOf(4, 1)
    private var subdivision = mutableListOf(1, 1)
    private var isMetronomePlaying = false
    private var metronomeAudioJob: Job? = null

    // Song state - same as your original
    private var isSongPlaying = false
    private var songJob: Job? = null

    // Reference note state - same as your original
    private var isRefNotePlaying = false
    private var refFreq = 440.0
    private var audioJob: Job? = null
    private var refNoteTrack: AudioTrack? = null
    @Volatile private var currentFreq = 0.0
    @Volatile private var shouldStop = false

    // Service scopes
    private val serviceScope = CoroutineScope(Dispatchers.Default + SupervisorJob())

    inner class MetronomeBinder : Binder() {
        fun getService(): MetronomeService = this@MetronomeService
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        acquireWakeLock()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_METRONOME -> {
                startForeground(NOTIFICATION_ID, createNotification("Metronome", "BPM: $tempo"))
                playMetronome()
            }
            ACTION_STOP_METRONOME -> {
                pauseMetronome()
            }
            ACTION_START_SONG -> {
                val song = intent.getSerializableExtra("song") as? HashMap<String, Any>
                song?.let {
                    startForeground(NOTIFICATION_ID, createNotification("Song", "Playing song"))
                    playSong(it)
                }
            }
            ACTION_STOP_SONG -> {
                pauseSong()
            }
            ACTION_START_REF_NOTE -> {
                startForeground(NOTIFICATION_ID, createNotification("Reference Note", "${refFreq}Hz"))
                playRefNote()
            }
            ACTION_STOP_REF_NOTE -> {
                pauseRefNote()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder = binder

    private fun createNotificationChannel() {
        val channel = NotificationChannel(
            CHANNEL_ID,
            "Metronome Service",
            NotificationManager.IMPORTANCE_LOW
        ).apply {
            description = "Keeps metronome playing in background"
            setSound(null, null)
        }

        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.createNotificationChannel(channel)
    }

    private fun acquireWakeLock() {
        val powerManager = getSystemService(Context.POWER_SERVICE) as PowerManager
        wakeLock = powerManager.newWakeLock(
            PowerManager.PARTIAL_WAKE_LOCK,
            "MetronomeApp::MetronomeWakeLock"
        ).apply {
            acquire(10*60*1000L /*10 minutes*/)
        }
    }

    private fun createNotification(title: String, content: String): Notification {
        val stopIntent = Intent(this, MetronomeService::class.java).apply {
            action = ACTION_STOP_METRONOME
        }
        val stopPendingIntent = PendingIntent.getService(
            this, 0, stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle(title)
            .setContentText(content)
            .setSmallIcon(android.R.drawable.ic_media_play)
            .setOngoing(true)
            .addAction(
                android.R.drawable.ic_media_pause,
                "Stop",
                stopPendingIntent
            )
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .build()
    }

    // METRONOME FUNCTIONS - Your exact logic preserved
    fun playMetronome() {
        if (isMetronomePlaying) {
            return
        }
        println("\n$accentsList")
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
        metronomeAudioJob = serviceScope.launch {
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

                    // Send event back to Flutter
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

    fun pauseMetronome() {
        isMetronomePlaying = false
        metronomeAudioJob?.cancel()
        metronomeAudioJob = null
    }

    // SONG FUNCTIONS - Your exact logic preserved
    fun playSong(song: Map<String, Any>) {
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
        songJob = serviceScope.launch {
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

    fun pauseSong() {
        isSongPlaying = false
        songJob?.cancel()
        songJob = null
    }

    // REFERENCE NOTE FUNCTIONS - Your exact logic preserved
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
        audioJob = serviceScope.launch {
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

    fun pauseRefNote() {
        shouldStop = true
        isRefNotePlaying = false
        audioJob?.cancel()
        audioJob = null
    }

    // UPDATE FUNCTIONS - Your exact logic preserved
    fun updateTempo(newTempo: Int) {
        tempo = newTempo
        if (isMetronomePlaying) {
            // Update notification
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.notify(NOTIFICATION_ID, createNotification("Metronome", "BPM: $tempo"))
        }
    }

    fun updateAccent(newAccents: MutableList<Int>) {
        accentsList = newAccents
        println("updated")
    }

    fun updateMeter(newMeter: MutableList<Int>) {
        meter = newMeter
    }

    fun updateSubdivision(newSubdivision: MutableList<Int>) {
        subdivision = newSubdivision
    }

    fun updateRefNote(newFreq: Double) {
        refFreq = newFreq
        currentFreq = newFreq
        println("\n\n currentFreq has been set to $currentFreq")
        if (isRefNotePlaying) {
            // Update notification
            val notificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.notify(NOTIFICATION_ID, createNotification("Reference Note", "${refFreq}Hz"))
        }
    }

    // UTILITY FUNCTIONS - Your exact logic preserved
    fun generateClick(length: Int, sampleRate: Int, frequency: Double, volume: Double): ShortArray {
        val buffer = ShortArray(length)
        for (i in 0 until length) {
            val fadeOut = 1.0 - i.toDouble() / length
            val amp = Short.MAX_VALUE * volume * fadeOut
            buffer[i] = (amp * sin(2 * PI * frequency * i / sampleRate)).toInt().toShort()
        }
        return buffer
    }

    // GETTERS
    fun isMetronomePlaying(): Boolean = isMetronomePlaying
    fun isSongPlaying(): Boolean = isSongPlaying
    fun isRefNotePlaying(): Boolean = isRefNotePlaying

    override fun onDestroy() {
        super.onDestroy()
        pauseMetronome()
        pauseSong()
        pauseRefNote()
        serviceScope.cancel()
        wakeLock?.let {
            if (it.isHeld) {
                it.release()
            }
        }
    }
}