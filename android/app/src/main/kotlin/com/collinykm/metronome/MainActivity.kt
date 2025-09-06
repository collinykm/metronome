// MainActivity.kt
package com.collinykm.metronome

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import androidx.annotation.NonNull
import java.io.Serializable

class MainActivity: FlutterActivity() {
    private val METHODCHANNEL = "metronome_method_channel"
    private val EVENTCHANNEL = "metronome_event_channel"

    private var metronomeService: MetronomeService? = null
    private var bound = false
    private var eventSink: EventChannel.EventSink? = null

    private val connection = object : ServiceConnection {
        override fun onServiceConnected(className: ComponentName, service: IBinder) {
            val binder = service as MetronomeService.MetronomeBinder
            metronomeService = binder.getService()
            bound = true
            // Connect the event sink to the service
            metronomeService?.eventSink = eventSink
        }

        override fun onServiceDisconnected(arg0: ComponentName) {
            bound = false
            metronomeService = null
        }
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Bind to service immediately
        val intent = Intent(this, MetronomeService::class.java)
        bindService(intent, connection, Context.BIND_AUTO_CREATE)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHODCHANNEL).setMethodCallHandler { call, result ->
            when(call.method) {
                "playMetronome" -> {
                    startMetronomeService()
                    result.success(null)
                }
                "pauseMetronome" -> {
                    metronomeService?.pauseMetronome()
                    result.success(null)
                }
                "playSong" -> {
                    val song = call.arguments as Map<String, Any>
                    startSongService(song)
                    result.success(null)
                }
                "pauseSong" -> {
                    metronomeService?.pauseSong()
                    result.success(null)
                }
                "updateTempo" -> {
                    val newTempo = call.arguments as Int
                    metronomeService?.updateTempo(newTempo)
                    result.success(null)
                }
                "updateAccent" -> {
                    val newAccents = call.arguments as MutableList<Int>
                    metronomeService?.updateAccent(newAccents)
                    result.success(null)
                }
                "updateMeter" -> {
                    val newMeter = call.arguments as MutableList<Int>
                    metronomeService?.updateMeter(newMeter)
                    result.success(null)
                }
                "updateSubdivision" -> {
                    val newSubdivision = call.arguments as MutableList<Int>
                    metronomeService?.updateSubdivision(newSubdivision)
                    result.success(null)
                }
                "playRefNote" -> {
                    print("message received")
                    startRefNoteService()
                    result.success(null)
                }
                "updateRefNote" -> {
                    val newFreq = call.arguments as Double
                    metronomeService?.updateRefNote(newFreq)
                    result.success(null)
                }
                "pauseRefNote" -> {
                    metronomeService?.pauseRefNote()
                    result.success(null)
                }
                // Add getters for state
                "isMetronomePlaying" -> {
                    val isPlaying = metronomeService?.isMetronomePlaying() ?: false
                    result.success(isPlaying)
                }
                "isSongPlaying" -> {
                    val isPlaying = metronomeService?.isSongPlaying() ?: false
                    result.success(isPlaying)
                }
                "isRefNotePlaying" -> {
                    val isPlaying = metronomeService?.isRefNotePlaying() ?: false
                    result.success(isPlaying)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENTCHANNEL).setStreamHandler(
            object: EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    // If service is already bound, connect the event sink
                    metronomeService?.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                    metronomeService?.eventSink = null
                }
            }
        )
    }

    private fun startMetronomeService() {
        val intent = Intent(this, MetronomeService::class.java).apply {
            action = MetronomeService.ACTION_START_METRONOME
        }
        startForegroundService(intent)

        // Bind to service if not already bound
        if (!bound) {
            bindService(intent, connection, Context.BIND_AUTO_CREATE)
        }
    }

    private fun startSongService(song: Map<String, Any>) {
        val intent = Intent(this, MetronomeService::class.java).apply {
            action = MetronomeService.ACTION_START_SONG
            putExtra("song", HashMap(song) as Serializable)
        }
        startForegroundService(intent)

        // Bind to service if not already bound
        if (!bound) {
            bindService(intent, connection, Context.BIND_AUTO_CREATE)
        }
    }

    private fun startRefNoteService() {
        val intent = Intent(this, MetronomeService::class.java).apply {
            action = MetronomeService.ACTION_START_REF_NOTE
        }
        startForegroundService(intent)

        // Bind to service if not already bound
        if (!bound) {
            bindService(intent, connection, Context.BIND_AUTO_CREATE)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        if (bound) {
            unbindService(connection)
            bound = false
        }
    }
}