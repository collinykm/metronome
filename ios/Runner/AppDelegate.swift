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
        [silentClick, normalClick, accent2Click, accent3Click]

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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.startScheduling()
        }
        
        /*
        let nodeTime = metronomePlayer.lastRenderTime!
        let playerTime = metronomePlayer.playerTime(forNodeTime: nodeTime)!
        scheduledSampleTime = playerTime.sampleTime // small lead-in

        scheduleBeats()
        */
        
        /*
        Task{
            while (isMetronomePlaying) {
                let beatIntervalSec = 60.0 / Double(tempo * subdivision[0])
                let beatIntervalSamples = Int(beatIntervalSec * sampleRate)
                let silenceSamples = beatIntervalSamples - clickSamples
                let silence = generateClick(sampleCount: silenceSamples, sampleRate: sampleRate, frequency: 440.0, volume: 0.0)
                
                let currentBeat = (currentPulse / subdivision[0]) % meter[0] + 1
                let pulseInBeat = currentPulse % subdivision[0] + 1
                
                var click: AVAudioPCMBuffer
                
                if (currentPulse % subdivision[0] == 0){
                    click = clicksList[accentsList[currentBeat - 1] * subdivision[pulseInBeat]]
                } else {
                    click = clicksList[subdivision[pulseInBeat]]
                }
                print("processed samples: \(processedSamples), currentBeat: \(currentBeat)")
                let now = Date().timeIntervalSince1970
                print("Tick at: \(now)")
                
                
                let startBeatTime = AVAudioTime(sampleTime: processedSamples, atRate: 44100.0)
                let startSilentTime = AVAudioTime(sampleTime: processedSamples + AVAudioFramePosition(self.clickSamples), atRate: 44100.0)
                metronomePlayer.scheduleBuffer(click, at: startBeatTime, completionHandler: nil)
                metronomePlayer.scheduleBuffer(silence, at: startSilentTime, completionHandler: nil)
                
                try await Task.sleep(for: .seconds(beatIntervalSec-0.001), tolerance: .nanoseconds(1))
                processedSamples += AVAudioFramePosition(beatIntervalSamples)

                currentPulse = (currentPulse + 1) % (meter[0] * subdivision[0])
            }
                     
        }
         */
        
    }
    
    func startScheduling() {
        let nodeTime = self.metronomePlayer.lastRenderTime!
        let playerTime = self.metronomePlayer.playerTime(forNodeTime: nodeTime)!
        self.scheduledSampleTime = playerTime.sampleTime + AVAudioFramePosition(0.1 * self.sampleRate) // small lead-in


        self.scheduleBeats()
    }
    
    var scheduledSampleTime: AVAudioFramePosition = 0
    var currentPulse = 0
    
    func scheduleBeats() {
        
        guard isMetronomePlaying else { return }

        let beatIntervalSec = 60.0 / Double(tempo * subdivision[0])
        let beatIntervalSamples = AVAudioFramePosition(beatIntervalSec * sampleRate)
        
        print("Yeah got here; scheduleSampleTime: \(scheduledSampleTime), currentTimeInSamples: \(currentTimeInSamples())")
       
        var index = 1
        while scheduledSampleTime < currentTimeInSamples() + AVAudioFramePosition(1 * beatIntervalSamples) {
        
            let currentBeat = (currentPulse / subdivision[0]) % meter[0] + 1
            let pulseInBeat = currentPulse % subdivision[0] + 1
            print("currentPulse: \(currentPulse), currentBeat: \(currentBeat)")
            
            
            var click: AVAudioPCMBuffer
            if (currentPulse % subdivision[0] == 0){
                click = clicksList[accentsList[currentBeat - 1] * subdivision[pulseInBeat]]
            } else {
                click = clicksList[subdivision[pulseInBeat]]
            }
            
            let beatTime = AVAudioTime(sampleTime: scheduledSampleTime, atRate: sampleRate)

            metronomePlayer.scheduleBuffer(click, at: beatTime, options: [])

            scheduledSampleTime += beatIntervalSamples
            index += 1
            currentPulse = (currentPulse + 1) % (self.meter[0] * self.subdivision[0])
            
        }
        

        DispatchQueue.global().asyncAfter(deadline: .now() + beatIntervalSec) {
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

        let fadeOut: (Int) -> Float = { i in
            return 1.0 - Float(i) / Float(sampleCount)
        }

        let theta = 2.0 * Double.pi * frequency / sampleRate
        for i in 0..<sampleCount {
            let amp = Float(Int16.max) * Float(volume) * fadeOut(i)
            buffer.floatChannelData!.pointee[i] = amp * sin(Float(theta * Double(i)))
        }

        return buffer
    }
    
    
    

    
    

    
    
    
}
