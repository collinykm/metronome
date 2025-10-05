//
//  MetronomeEngine.swift
//  Runner
//
//  Created by Collin Yang on 2025-10-04.
//


import Foundation
import AVFoundation
import MediaPlayer
import UIKit

final class MetronomeEngine {
    static let shared = MetronomeEngine()

    // MARK: - Public state mirrors Android getters
    private(set) var isMetronomePlaying = false
    private(set) var isSongPlaying = false
    private(set) var isRefNotePlaying = false

    // MARK: - Config/state matching Android variables
    private var tempo: Int = 120
    private var accentsList: [Int] = [1, 1, 1, 1]      // 0..3 (0 = silent)
    private var meter: [Int] = [4, 1]                  // [beatsPerBar, beatUnit]
    private var subdivision: [Int] = [1, 1]            // [N, sub1 .. subN] where subs are 0 or 1

    // MARK: - Audio
    private let engine = AVAudioEngine()
    private let playerNode = AVAudioPlayerNode()
    private var sourceNode: AVAudioSourceNode? // for reference tone

    private var sampleRate: Double = 44100
    private let clickDurationMs: Int = 30
    private var clickFrames: AVAudioFrameCount = 0

    // Pre-generated clicks (Float32)
    private var accent3Click: [Float] = []
    private var accent2Click: [Float] = []
    private var normalClick: [Float] = []
    private var silentClick: [Float] = []
    private var clicksList: [[Float]] { [silentClick, normalClick, accent2Click, accent3Click] }

    // Threading
    private let audioQueue = DispatchQueue(label: "MetronomeAudioQueue")

    // Event callback back to Flutter
    var emitEvent: (([String: Any]) -> Void)?

    // Reference tone
    private var refFreq: Double = 440.0
    private var currentFreq: AtomicDouble = .init(0)

    private init() {
        setupAudioGraph()
    }

    // MARK: - Setup
    private func setupAudioGraph() {
        let outputFormat = engine.outputNode.outputFormat(forBus: 0)
        sampleRate = outputFormat.sampleRate
        clickFrames = AVAudioFrameCount(Double(clickDurationMs) * sampleRate / 1000.0)

        engine.attach(playerNode)
        engine.connect(playerNode, to: engine.mainMixerNode, format: AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1))

        regenerateClickSamples()
        configureSession()
        startEngineIfNeeded()
    }

    private func regenerateClickSamples() {
        accent3Click = MetronomeEngine.generateClick(length: Int(clickFrames), sampleRate: sampleRate, frequency: 2000.0, volume: 3.0)
        accent2Click = MetronomeEngine.generateClick(length: Int(clickFrames), sampleRate: sampleRate, frequency: 1600.0, volume: 2.5)
        normalClick  = MetronomeEngine.generateClick(length: Int(clickFrames), sampleRate: sampleRate, frequency: 1000.0, volume: 2)
        silentClick  = Array(repeating: 0.0, count: Int(clickFrames))
    }

    private func configureSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // 1) Force bottom speaker as the default route
            try session.setCategory(
                .playAndRecord,
                mode: .measurement, // or .default — avoid .voiceChat / .videoChat
                options: [.defaultToSpeaker, .allowBluetoothA2DP, .allowAirPlay, .mixWithOthers] // add .mixWithOthers if you want
            )
            try session.setActive(true)

            // 2) If iOS still picked the receiver, override it (valid only for .playAndRecord)
            if session.currentRoute.outputs.first?.portType == .builtInReceiver {
                try session.overrideOutputAudioPort(.speaker)
            }

        } catch {
            print("[AudioSession] \(error)")
        }
    }

    private func startEngineIfNeeded() {
        if engine.isRunning { return }
        do {
            try engine.start()
        } catch {
            print("[Metronome] Engine failed to start: \(error)")
        }
    }

    // MARK: - Public API (invoked by Flutter)
    func playMetronome() {
        guard !isMetronomePlaying else { return }
        UIApplication.shared.isIdleTimerDisabled = true
        isSongPlaying = false
        isMetronomePlaying = true

        startEngineIfNeeded()
        playerNode.stop()
        playerNode.play()

        scheduleMetronomeLoop()
        updateNowPlaying(title: "Metronome", subtitle: "BPM: \(tempo)")
    }

    func pauseMetronome() {
        isMetronomePlaying = false
        playerNode.stop()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func playSong(_ song: [String: Any]) {
        guard !isSongPlaying else { return }
        UIApplication.shared.isIdleTimerDisabled = true
        isMetronomePlaying = false
        isSongPlaying = true

        startEngineIfNeeded()
        playerNode.stop()
        playerNode.play()

        scheduleSongLoop(song)
        updateNowPlaying(title: "Song", subtitle: "Playing song")
    }

    func pauseSong() {
        isSongPlaying = false
        playerNode.stop()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func playRefNote() {
        guard !isRefNotePlaying else { return }
        UIApplication.shared.isIdleTimerDisabled = true
        isRefNotePlaying = true
        currentFreq.value = refFreq

        // Create a source node that generates a sine wave in real-time
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        var phase: Double = 0
        sourceNode = AVAudioSourceNode(format: format) { _, _, frameCount, audioBufferList -> OSStatus in
            let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
            let frames = Int(frameCount)
            let freq = self.currentFreq.value
            let phaseInc = 2.0 * Double.pi * freq / self.sampleRate
            let volume: Float = 0.3

            for buffer in abl {
                let ptr = buffer.mData!.assumingMemoryBound(to: Float.self)
                for i in 0..<frames {
                    ptr[i] = sin(phase).toFloat() * volume
                    phase += phaseInc
                    if phase >= 2.0 * Double.pi { phase -= 2.0 * Double.pi }
                }
            }
            return noErr
        }
        guard let sourceNode else { return }
        engine.attach(sourceNode)
        engine.connect(sourceNode, to: engine.mainMixerNode, format: format)
        startEngineIfNeeded()

        updateNowPlaying(title: "Reference Note", subtitle: "\(Int(refFreq))Hz")
    }

    func pauseRefNote() {
        isRefNotePlaying = false
        if let sourceNode { engine.disconnectNodeInput(sourceNode); engine.detach(sourceNode) }
        sourceNode = nil
        UIApplication.shared.isIdleTimerDisabled = false
    }

    func updateTempo(_ newTempo: Int) {
        tempo = newTempo
        if isMetronomePlaying { updateNowPlaying(title: "Metronome", subtitle: "BPM: \(tempo)") }
    }

    func updateAccent(_ newAccents: [Int]) { accentsList = newAccents }
    func updateMeter(_ newMeter: [Int]) { meter = newMeter }
    func updateSubdivision(_ newSubdivision: [Int]) { subdivision = newSubdivision }

    func updateRefNote(_ newFreq: Double) {
        refFreq = newFreq
        currentFreq.value = newFreq
        if isRefNotePlaying { updateNowPlaying(title: "Reference Note", subtitle: "\(Int(refFreq))Hz") }
    }

    // MARK: - Scheduling (sample-accurate enough for metronome)
    private func scheduleMetronomeLoop() {
        audioQueue.async {
            var currentPulse = 0 // 0..(meter[0]*subdivision[0]-1)
            while self.isMetronomePlaying {
                print("\njust ran another scheduleMetronomeLoop")
                let beatIntervalSec = 60.0 / ( Double(self.tempo) * Double(self.subdivision[safe: 0] ?? 1) )
                let beatIntervalFrames = Int(beatIntervalSec * self.sampleRate)
                let silenceFrames = max(beatIntervalFrames - Int(self.clickFrames), 0)

                let beatsPerBar = self.meter[safe: 0] ?? 4
                let subdivision = max(self.subdivision[safe: 0] ?? 1, 1)

                let currentBeat = (currentPulse / subdivision) % beatsPerBar + 1
                let pulseInBeat = (currentPulse % subdivision) + 1 // 1-indexed like Android

                var click: [Float]
                if (currentPulse % self.subdivision[0] == 0) {
                    click = self.clicksList[self.accentsList[currentBeat - 1] * self.subdivision[pulseInBeat]]
                } else {
                    click = self.clicksList[self.subdivision[pulseInBeat]]
                }

            

                self.scheduleOnePulse(click: click, silenceFrames: silenceFrames, isMetronome: true, config: ["currentBeat": currentBeat])

                currentPulse = (currentPulse + 1) % (beatsPerBar * subdivision)
            }
        }
    }

    private func scheduleSongLoop(_ song: [String: Any]) {
        audioQueue.async {
            while self.isSongPlaying {
                guard let sections = song["sectionsList"] as? [[String: Any]] else { break }
                for section in sections {
                    if !self.isSongPlaying { break }

                    let sectionTempo = section["tempo"] as? Int ?? 120
                    let bars = section["bars"] as? Int ?? 1
                    let sectionAccents = section["accentsList"] as? [Int] ?? [1,1,1,1]
                    let sectionMeter = section["meter"] as? [Int] ?? [4,1]
                    let sectionSubdivision = section["subdivision"] as? [Int] ?? [1,1]

                    let subs = max(sectionSubdivision.first ?? 1, 1)
                    let totalPulses = bars * (sectionMeter.first ?? 4) * subs
                    let beatIntervalSec = 60.0 / ( Double(sectionTempo) * Double(subs) )
                    let beatIntervalFrames = Int(beatIntervalSec * self.sampleRate)
                    let silenceFrames = max(beatIntervalFrames - Int(self.clickFrames), 0)

                    var currentPulse = 0
                    for _ in 0..<totalPulses {
                        if !self.isSongPlaying { break }

                        let currentBeat = (currentPulse / subs) % (sectionMeter.first ?? 4) + 1
                        let pulseInBeat = (currentPulse % subs) + 1

                        let accentLevel = (sectionAccents[safe: currentBeat - 1] ?? 1)
                        let subGate = (sectionSubdivision[safe: pulseInBeat] ?? 1)
                        let clickIndex = min(max(accentLevel * subGate, 0), 3)
                        let click = self.clicksList[clickIndex]
                        print(section)
                        self.scheduleOnePulse(click: click, silenceFrames: silenceFrames, isMetronome: false,
                                              config: ["type": "song", "currentBeat": currentBeat, "sectionId": section["sectionId"]!])
                        

                        currentPulse = (currentPulse + 1) % ((sectionMeter.first ?? 4) * subs)
                    }
                }
                self.isSongPlaying = false
                DispatchQueue.main.async { self.emitEvent?(["type": "alert", "message": "song ended"]) }
            }
        }
    }

    private func scheduleOnePulse(click: [Float], silenceFrames: Int, isMetronome: Bool, config: [ String: Any]) {
        print("just ran a scheduleOnePulse")
        let totalFrames = click.count + silenceFrames
        guard totalFrames > 0 else { return }

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(totalFrames))!
        buffer.frameLength = buffer.frameCapacity
        let ptr = buffer.floatChannelData![0]

        // write click
        click.withUnsafeBufferPointer { src in
            ptr.update(from: src.baseAddress!, count: click.count)
        }
        // write trailing silence
        if silenceFrames > 0 {
            let silenceStart = ptr.advanced(by: click.count)
            silenceStart.update(repeating: 0.0, count: silenceFrames)
        }
        DispatchQueue.main.async {
            if (isMetronome) {
                print("currentBeat: \(config["currentBeat"]!)")
                self.emitEvent?(["type": "metronome", "beat": config["currentBeat"]!])
            } else {
                self.emitEvent?(["type": "song", "beat": config["currentBeat"]!, "section": config["sectionId"]!])
            }
            

        }

        // Schedule without blocking; fire UI callback on main after playback ends
        playerNode.scheduleBuffer(buffer, at: nil, options: [])
        if !playerNode.isPlaying { playerNode.play() }

        // Pace the outer loop without waiting on a lower-QoS signal (no priority inversion)
        let durationSec = Double(totalFrames) / sampleRate
        Thread.sleep(forTimeInterval: durationSec)  // keeps the “one buffer at a time” behavior
    }

    // MARK: - Now Playing (optional, replaces Android foreground notification)
    private func updateNowPlaying(title: String, subtitle: String) {
        let info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyAlbumTitle: subtitle
        ]
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Utils
    static func generateClick(length: Int, sampleRate: Double, frequency: Double, volume: Double) -> [Float] {
        let twoPiOverSR = 2.0 * Double.pi / sampleRate
        return (0..<length).map { i in
            let fadeOut = 1.0 - Double(i)/Double(length)
            let amp = Float(volume * fadeOut)
            return sin(Double(i) * twoPiOverSR * frequency).toFloat() * amp
        }
    }
}

// Simple safe index extension
private extension Array {
    subscript(safe index: Int) -> Element? { indices.contains(index) ? self[index] : nil }
}

// Atomic double for frequency updates from Flutter thread
final class AtomicDouble { private let q = DispatchQueue(label: "AtomicDouble"); private var _value: Double
    init(_ v: Double) { _value = v }
    var value: Double { get { q.sync { _value } } set { q.sync { _value = newValue } } }
}

private extension Double { func toFloat() -> Float { return Float(self) } }

