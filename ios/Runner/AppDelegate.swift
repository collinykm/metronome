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
    
    
    
    let sampleRate = 44100.0
    let clickDurationMs = 30.0
    var clickSamples: Int {
        return Int(sampleRate * clickDurationMs / 1000.0)
    }
    var accent3Click: AVAudioPCMBuffer {
        generateClick(sampleCount: clickSamples, sampleRate: sampleRate, frequency: 2000.0, volume: 1.0)
    }
    var accent2Click: AVAudioPCMBuffer {
        generateClick(sampleCount: clickSamples, sampleRate: sampleRate, frequency: 1600.0, volume: 0.8)
    }
    var normalClick: AVAudioPCMBuffer {
        generateClick(sampleCount: clickSamples, sampleRate: sampleRate, frequency: 1000.0, volume: 0.6)
    }
    var silentClick: AVAudioPCMBuffer {
        generateClick(sampleCount: clickSamples, sampleRate: sampleRate, frequency: 1000.0, volume: 0.0)
        
    }
    var clicksList: [AVAudioPCMBuffer] {
        return [silentClick, normalClick, accent2Click, accent3Click]
        
    }
    
    let audioEngine = AVAudioEngine()
    let metronomePlayer = AVAudioPlayerNode()
    let songPlayer = AVAudioPlayerNode()
    
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        let controller = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: METHODCHANNEL, binaryMessenger: controller.binaryMessenger)
        
        methodChannel.setMethodCallHandler { [weak self] call, result in
            guard let self = self else { return }
            switch call.method {
            case "playMetronome":
                Task {
                    await self.playMetronome()
                }
                
                result(nil)
            case "pauseMetronome":
                isMetronomePlaying = false
                metronomePlayer.reset()
                currentPulse = 0
                print("\n\n________________")
                result(nil)
                
            case "playSong":
                songWork = Task {
                    var song = call.arguments as! [String: Any]
                    print(song)
                    await self.playSong(song: song)
                }
                result(nil)
                
            case "pauseSong":
                isSongPlaying = false
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
                
                
                
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        let eventChannel = FlutterEventChannel(name: EVENTCHANNEL, binaryMessenger: controller.binaryMessenger)
        
        eventChannel.setStreamHandler(self)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    
    
    
    private func playMetronome() async {
        if isMetronomePlaying{
            return
        }
        isMetronomePlaying = true
        
        audioEngine.attach(metronomePlayer)
        audioEngine.connect(metronomePlayer, to: audioEngine.mainMixerNode, format: clicksList[0].format)
        try! audioEngine.start()
        metronomePlayer.play()
        
        
        
        let nodeTime = metronomePlayer.lastRenderTime!
        let playerTime = metronomePlayer.playerTime(forNodeTime: nodeTime)!
        metronomeScheduledSampleTime = playerTime.sampleTime // small lead-in
        
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
            eventSink?(["type": "metronome", "beat": currentBeat])
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
        
        audioEngine.attach(songPlayer)
        audioEngine.connect(songPlayer, to: audioEngine.mainMixerNode, format: clicksList[0].format)
        try! audioEngine.start()
        songPlayer.play()
        
        
        
        let nodeTime = songPlayer.lastRenderTime!
        let playerTime = songPlayer.playerTime(forNodeTime: nodeTime)!
        songScheduledSampleTime = playerTime.sampleTime // small lead-in
        
        scheduleSongBeats(song: song)
        
        
        
        
    }
    
    var currentSectionIndex = 0
    var numSectionClicksPlayed = 0
    var currentSectionPulse = 0
    private func scheduleSongBeats(song: [String: Any]){
        print(isSongPlaying)
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
        print("beatInteralSe: \(beatIntervalSec)")
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
            print("just played a beat, \(currentBeat)")
            guard let self = self else { return }
            eventSink?(["type": "song", "beat": currentBeat, "section": section["sectionId"] ])
            numSectionClicksPlayed += 1
            print("shoulda played a click, numSectionClicksPlayed: \(self.numSectionClicksPlayed), currentSection: \(self.currentSectionIndex), totalPulses: \(totalPulses)")
            if numSectionClicksPlayed >= totalPulses{  //this is where the section finishes
                print("moved on here")
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
