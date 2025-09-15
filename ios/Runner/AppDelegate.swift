import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
    private var eventSink: FlutterEventSink?
    private let METHODCHANNEL = "metronome_method_channel"
    private let EVENTCHANNEL = "metronome_event_channel"
    
    var songWork: Task<Void, Never>?
    
    
    private var tempo = 120
    private var accentsList = [1, 1, 1, 1]
    private var meter = [4, 1]
    private var subdivision = [1, 1]
    private var isMetronomePlaying = false
    private var isSongPlaying = false
    private var isRefNotePlaying = false
    private var refFreq = 440.0
    
    
    
    let sampleRate = 44100.0
    let clickDurationMs = 30.0
    var clickSamples: Int {
        return Int(sampleRate * clickDurationMs / 1000.0)
    }
    var accent3Click: AVAudioPCMBuffer { generateClick(sampleCount: clickSamples, sampleRate: sampleRate, frequency: 2000.0, volume: 1.0)
    }
    var accent2Click: AVAudioPCMBuffer { generateClick(sampleCount: clickSamples, sampleRate: sampleRate, frequency: 1600.0, volume: 0.9)
    }
    var normalClick: AVAudioPCMBuffer { generateClick(sampleCount: clickSamples, sampleRate: sampleRate, frequency: 1000.0, volume: 0.8)
    }
    var silentClick: AVAudioPCMBuffer { generateClick(sampleCount: clickSamples, sampleRate: sampleRate, frequency: 1000.0, volume: 0.0)
        
    }
    var clicksList: [AVAudioPCMBuffer] {
        return [silentClick, normalClick, accent2Click, accent3Click]
    }
    
    let audioEngine = AVAudioEngine()
    let metronomePlayer = AVAudioPlayerNode()
    let songPlayer = AVAudioPlayerNode()
    let refNotePlayer = AVAudioPlayerNode()
    let fmt = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 1)!
    let session = AVAudioSession.sharedInstance()
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: METHODCHANNEL, binaryMessenger: controller.binaryMessenger)
        
        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            switch call.method {
            case "initAudio":
                audioEngine.attach(refNotePlayer)
                audioEngine.attach(metronomePlayer)
                audioEngine.attach(songPlayer)
                audioEngine.mainMixerNode.outputVolume = 1.0

                do {
                    try session.setCategory(.playback, mode: .default)
                    try session.setActive(true)

                    audioEngine.connect(refNotePlayer, to: audioEngine.mainMixerNode, format: fmt)
                    audioEngine.connect(metronomePlayer, to: audioEngine.mainMixerNode, format: fmt)
                    audioEngine.connect(songPlayer, to: audioEngine.mainMixerNode, format: fmt)

                    try audioEngine.start()
                    //try session.overrideOutputAudioPort(.speaker)
                    print("Engine running? \(audioEngine.isRunning)")
                    print(session.category, session.mode)

                    print("Audio route: \(session.currentRoute.outputs.map { $0.portName })")
                    print("Audio route: \(session.currentRoute.outputs.map { $0.portName })")
                } catch {
                    print("Audio init failed: \(error)")
                }
                result(nil)
            
            case "playMetronome":
                Task {
                    await self.playMetronome()
                    result(nil)
                }

            case "pauseMetronome":
                isMetronomePlaying = false
                metronomePlayer.stop()
                metronomePlayer.reset()
                currentPulse = 0
                print("\n\n________________")
                result(nil)
                
            case "playSong":
                songWork = Task {
                    let song = call.arguments as! [String: Any]
                    print(song)
                    await self.playSong(song: song)
                }
                result(nil)
                
            case "pauseSong":
                isSongPlaying = false
                songPlayer.stop()
                songPlayer.reset()
                print("shoulda paused it here")
                result(nil)
                
            case "updateTempo":
                let newTempo = call.arguments as! Int
                tempo = newTempo
                result(nil)
                
            case "updateAccent":
                let newAccents = call.arguments as! [Int]
                accentsList = newAccents
                result(nil)
                
            case "updateMeter":
                let newMeter = call.arguments as! [Int]
                meter = newMeter
                result(nil)
                
            case "updateSubdivision":
                let newSubdivision = call.arguments as! [Int]
                subdivision = newSubdivision
                result(nil)
            
            case "playRefNote":
                Task {
                    self.playRefNote()
                }
                result(nil)
                
            case "updateRefNote":
                let newFreq = call.arguments as! Double
                refFreq = newFreq
                print("Received new frequency \(newFreq)")
                if (isRefNotePlaying) {
                    // Just update the increment - no need to stop/start
                    let twoPi = 2.0 * Double.pi
                    let sr: Double = 44100.0  // Use the same sample rate you set in playRefNote
                    currentInc = twoPi * Double(refFreq) / sr
                    print("Updated frequency on the fly")
                }
              
                result(nil)
            
            case "pauseRefNote":
                pauseRefNote()
                refNotePlayer.stop()
                //refNotePlayer.reset()
                result(nil)
                
                
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        let eventChannel = FlutterEventChannel(name: EVENTCHANNEL, binaryMessenger: controller.binaryMessenger)
        
        eventChannel.setStreamHandler(self)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    private var refLoopBuffer: AVAudioPCMBuffer?
    private var currentInc: Double = 0
    private var phase: Double = 0

    func playRefNote() {
        let start = DispatchTime.now()
        guard refFreq > 0 else { return }
        guard !isRefNotePlaying else { return }


        // Tone state
        let twoPi = 2.0 * Double.pi
        currentInc = twoPi * Double(refFreq) / sampleRate
        let framesPerBuf = max(4096, Int(sampleRate * 0.06)) // ~60–90 ms, avoids underflows nicely
        let cap = AVAudioFrameCount(framesPerBuf)
        let amp: Float = 0.9
    
        isRefNotePlaying = true
        
        if session.category != .playAndRecord {
            do {
                try session.setCategory(.playAndRecord,
                                                      mode: .default,
                                                      options: [.defaultToSpeaker, .allowBluetooth])
                try session.setActive(true)
            } catch {
                print("failed to set session category to .playAndRecord: \(error)")
            }
            
        }
  
    
  
        print("ref note player: \(refNotePlayer.isPlaying), audio engine: \(audioEngine.isRunning), source: \(session.currentRoute.outputs.map { $0.portName })")
        
        
        let end = DispatchTime.now()
        let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds
        let timeInterval = Double(nanoTime) / 1_000_000_000
        print("Took \(timeInterval) seconds")
        // Add this debug line to see what's happening
        print("Audio session when trying to play: category=\(session.category), options=\(session.categoryOptions)")

        func scheduleNext() {
            if !isRefNotePlaying {
                DispatchQueue.main.async {
                    self.refNotePlayer.pause()
                    self.refNotePlayer.reset()
                }
                return
            }
            guard let buffer = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: cap) else { return }
            buffer.frameLength = cap
            let n = Int(cap)
            let fcd = buffer.floatChannelData!
            
            for i in 0..<n {
                let s = amp * Float(sin(phase))
                phase += currentInc
                if phase >= twoPi { phase -= twoPi }
                fcd.pointee[i] = s
            }
            refNotePlayer.scheduleBuffer(buffer) {
                scheduleNext()
            }
        }
        scheduleNext()  //this is very important, as scheduling a buffer before starting playback removes the bug of the app freezing after play/pausing for like 10 times
        refNotePlayer.play()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { // 10ms delay
            // Prime a few buffers so it never starves
            for _ in 0..<6 { scheduleNext() }
        }
    }

    // Call this to stop (pop is okay per your note)
    func pauseRefNote() {
        isRefNotePlaying = false
    }





    
    
    
    
    
    
    private func playMetronome() async {
        if isMetronomePlaying{
            return
        }
        isMetronomePlaying = true
        
        if session.category != .playback {
            do {
                try session.setCategory(.playback, mode: .default)
                try session.setActive(true)
            } catch {
                print("Failed to reset to playback: \(error)")
            }
        }
        print("within playMetronome: \(session.category), \(session.mode)")

        metronomePlayer.volume = 3.5
        metronomePlayer.play()
        print("is metronomePlayer playing: \(metronomePlayer.isPlaying), from source: \(session.currentRoute.outputs.map { $0.portName }), volume: \(audioEngine.mainMixerNode.outputVolume)")

        var attempts = 0
        var nodeTime: AVAudioTime?
        while nodeTime == nil && attempts < 50 { // Increased attempts
            nodeTime = metronomePlayer.lastRenderTime
            if nodeTime == nil {
                usleep(1000) // 1ms sleep - more responsive than Task.sleep
                attempts += 1
            }
        }

        let playerTime = metronomePlayer.playerTime(forNodeTime: nodeTime!)
        metronomeScheduledSampleTime = playerTime!.sampleTime
        

        scheduleBeats()
    }
    
    
    
    var metronomeScheduledSampleTime: AVAudioFramePosition = 0
    var currentPulse = 0
    
    func scheduleBeats() {
        guard isMetronomePlaying else { return }
        
        // Capture current state to ensure consistency during this scheduling pass
        let currentTempo = tempo
        let currentSubdivision = subdivision[0]
        let currentMeter = meter[0]
        let beatIntervalSec = 60.0 / Double(currentTempo * currentSubdivision)
        let beatIntervalSamples = AVAudioFramePosition(beatIntervalSec * sampleRate)
        
        
        let currentBeat = (currentPulse / currentSubdivision) % currentMeter + 1
        let pulseInBeat = currentPulse % currentSubdivision + 1
        
        var click: AVAudioPCMBuffer
        if (currentPulse % subdivision[0] == 0){
            click = clicksList[accentsList[currentBeat - 1] * subdivision[pulseInBeat]]
        } else {
            click = clicksList[subdivision[pulseInBeat]]
        }
        
        let beatTime = AVAudioTime(sampleTime: metronomeScheduledSampleTime, atRate: sampleRate)
        
        metronomePlayer.scheduleBuffer(click, at: beatTime, options: []) { [weak self] in
            // This completion handler runs in the audio render thread
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.eventSink?(["type": "metronome", "beat": currentBeat])
            }
            guard self.isMetronomePlaying else { return }
            self.metronomeScheduledSampleTime += beatIntervalSamples
            self.currentPulse = (self.currentPulse + 1) % (currentMeter * currentSubdivision)
            self.scheduleBeats()
        }
    }
    
    
    
    var songScheduledSampleTime: AVAudioFramePosition = 0
    
    private func playSong(song: [String: Any]) async {
        if isSongPlaying{
            return
        }
        isSongPlaying = true
        
        if session.category != .playback {
            do {
                try session.setCategory(.playback, mode: .default)
                try session.setActive(true)
            } catch {
                print("Failed to reset to playback: \(error)")
            }
        }
        songPlayer.volume = 3.5
        songPlayer.play()
        
        var attempts = 0
        var nodeTime: AVAudioTime?
        while nodeTime == nil && attempts < 50 { // Increased attempts
            nodeTime = songPlayer.lastRenderTime
            if nodeTime == nil {
                usleep(1000) // 1ms sleep - more responsive than Task.sleep
                attempts += 1
            }
        }
        
        let playerTime = songPlayer.playerTime(forNodeTime: nodeTime!)
        songScheduledSampleTime = playerTime!.sampleTime // small lead-in
        
        scheduleSongBeats(song: song)
        
        
        
        
    }
    
    var currentSectionIndex = 0
    var numSectionClicksPlayed = 0
    var currentSectionPulse = 0
    private func scheduleSongBeats(song: [String: Any]){
        
        if (currentSectionIndex == (song["sectionsList"] as! [[String: Any]]).count || !isSongPlaying){   //either ran out of sections to play or song ended
    
            currentSectionIndex = 0
            numSectionClicksPlayed = 0
            currentSectionPulse = 0
            isSongPlaying = false
            eventSink?(["type": "alert", "message": "song ended"])
            return
        }
        
        let section = (song["sectionsList"] as! [[String: Any]])[currentSectionIndex]
        let tempo = section["tempo"] as! Int
        let bars = section["bars"] as! Int
        let accentsList = section["accentsList"] as! [Int]
        let meter = section["meter"] as! [Int]
        let subdivision = section["subdivision"] as! [Int]
        let totalPulses = bars * meter[0] * subdivision[0]
        
       
        
        let beatIntervalSec = 60.0 / Double(tempo * subdivision[0])
        
        let beatIntervalSamples = AVAudioFramePosition(beatIntervalSec * sampleRate)
        
        
        let currentBeat = (currentSectionPulse / subdivision[0]) % meter[0] + 1
        let pulseInBeat = currentSectionPulse % subdivision[0] + 1
        
        var click: AVAudioPCMBuffer
        if (currentSectionPulse % subdivision[0] == 0){
            click = clicksList[accentsList[currentBeat - 1] * subdivision[pulseInBeat]]
        } else {
            click = clicksList[subdivision[pulseInBeat]]
        }
        

        
        let beatTime = AVAudioTime(sampleTime: songScheduledSampleTime, atRate: sampleRate)
        
        songPlayer.scheduleBuffer(click, at: beatTime, options: []) { [weak self] in
            guard let self = self else { return }
            eventSink?(["type": "song", "beat": currentBeat, "section": section["sectionId"] ])
            numSectionClicksPlayed += 1
            
            if numSectionClicksPlayed >= totalPulses{  //this is where the section finishes
                
                currentSectionIndex += 1
                numSectionClicksPlayed = 0
                currentSectionPulse = 0
            } else {
                self.currentSectionPulse = (self.currentSectionPulse + 1) % (meter[0] * subdivision[0])
            }
            
            self.songScheduledSampleTime += beatIntervalSamples

            self.scheduleSongBeats(song: song)
        }
        
        
        
    }
    
    
    
    func generateClick(sampleCount: Int, sampleRate: Double, frequency: Double, volume: Double) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(sampleCount))!
        buffer.frameLength = AVAudioFrameCount(sampleCount)

        for i in 0..<sampleCount {
            let fadeOut = 1.0 - Double(i) / Double(sampleCount)
            let amp = volume * fadeOut
            
            buffer.floatChannelData!.pointee[i] = Float(amp * sin(2 * Double.pi * frequency * Double(i) / Double(sampleRate)))
        }

        return buffer
    }

    
    
}


extension AppDelegate: FlutterStreamHandler {
  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }
}
