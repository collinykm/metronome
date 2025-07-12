import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
    
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
        let channel = FlutterMethodChannel(name: "metronome_channel", binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { [weak self] call, result in
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
                    Task {
                        var song = call.arguments as! [String: Any]
                        await self.playSong()
                    }
                    result(nil)
                
                case "pauseSong":
                
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
        
        var currentPulse = 0
        
        
        let nodeTime = metronomePlayer.lastRenderTime!
        let playerTime = metronomePlayer.playerTime(forNodeTime: nodeTime)!
        scheduledSampleTime = playerTime.sampleTime // small lead-in
        
        scheduleBeats()
    }
        
        
    
    var scheduledSampleTime: AVAudioFramePosition = 0
    var currentPulse = 0
    
    func scheduleBeats() {
        guard isMetronomePlaying else { return }

        // Capture current state to ensure consistency during this scheduling pass
        let currentTempo = tempo
        let currentSubdivision = subdivision[0]
        let currentMeter = meter[0]
        let beatIntervalSec = 60.0 / Double(currentTempo * currentSubdivision)
        let beatIntervalSamples = AVAudioFramePosition(beatIntervalSec * sampleRate)
        let now = currentTimeInSamples()
        
        // Skip any beats that should have already played
     
        
        
        // Schedule exactly one beat ahead
        let currentBeat = (currentPulse / currentSubdivision) % currentMeter + 1
        let pulseInBeat = currentPulse % currentSubdivision + 1
        
        var click: AVAudioPCMBuffer
        if (currentPulse % subdivision[0] == 0){
            click = clicksList[accentsList[currentBeat - 1] * subdivision[pulseInBeat]]
        } else {
            click = clicksList[subdivision[pulseInBeat]]
        }
        print("currentPulse: \(currentPulse), currentBeat: \(currentBeat), pulseInBeat: \(pulseInBeat), currentSubdivision: \(currentSubdivision), currentMeter: \(currentMeter)")
        
        let beatTime = AVAudioTime(sampleTime: scheduledSampleTime, atRate: sampleRate)
        metronomePlayer.scheduleBuffer(click, at: beatTime, options: []) { [weak self] in
            // This completion handler runs in the audio render thread
            guard let self = self else { return }
            guard self.isMetronomePlaying else { return }
            self.scheduledSampleTime += beatIntervalSamples
            self.currentPulse = (self.currentPulse + 1) % (currentMeter * currentSubdivision)
            self.scheduleBeats()
        }
    }
    
    func currentTimeInSamples() -> AVAudioFramePosition {
        guard let nodeTime = metronomePlayer.lastRenderTime,
              let playerTime = metronomePlayer.playerTime(forNodeTime: nodeTime) else {
            return 0
        }
        return playerTime.sampleTime
    }
    
    
    
    private func playSong() async {
        
        if isSongPlaying{
            return
        }
                
        isSongPlaying = true
        
    
            
        audioEngine.attach(songPlayer)
        audioEngine.connect(songPlayer, to: audioEngine.mainMixerNode, format: clicksList[0].format)
        try! audioEngine.start()
        songPlayer.play()
    }
    
    
    
    func generateClick(sampleCount: Int, sampleRate: Double, frequency: Double, volume: Double) -> AVAudioPCMBuffer {
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(sampleCount))!
        buffer.frameLength = AVAudioFrameCount(sampleCount)

       

        let theta = 2.0 * Double.pi * frequency / sampleRate
        for i in 0..<sampleCount {
            let fadeOut = 1.0 - Double(i) / Double(sampleCount)
            let amp = volume * fadeOut
            
            buffer.floatChannelData!.pointee[i] = Float(amp * sin(2 * Double.pi * frequency * Double(i) / Double(sampleRate)))
        }

        return buffer
    }

    
    
}
