//
//  AudioCapturePlugin.swift
//  Runner
//
//  Created by Collin Yang on 2025-10-04.
//

import Foundation
import AVFoundation
import Flutter

public class IosAudioCapturePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {

    // MARK: - Channels

    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = IosAudioCapturePlugin()

        let method = FlutterMethodChannel(name: "recording_method_channel", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: method)

        let event = FlutterEventChannel(name: "recording_event_channel", binaryMessenger: registrar.messenger())
        event.setStreamHandler(instance)
    }

    // MARK: - State
    private let session = AVAudioSession.sharedInstance()
    private let engine  = AVAudioEngine()
    private var eventSink: FlutterEventSink?

    private var desiredSR: Double = 44100
    private var desiredFrames: Int = 2048

    private var converter: AVAudioConverter?
    private var targetFormat: AVAudioFormat?
    private var ring = [Float]()               // accumulate until we have desiredFrames
    private let q = DispatchQueue(label: "IosAudioCapture.Capture", qos: .userInitiated)

    private var isRunning = false
    private var tapInstalled = false

    // MARK: - FlutterPlugin
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {

        case "startRecording":
            guard let args = call.arguments as? [String: Any] else { result(FlutterError(code:"args", message:"missing args", details:nil)); return }
            if let sr = args["sampleRate"] as? NSNumber { desiredSR = sr.doubleValue }
            if let bs = args["bufferSize"] as? NSNumber { desiredFrames = bs.intValue }

            startCapture()
            result(nil)

        case "stopRecording":
            stopCapture()
            result(nil)

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - StreamHandler
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }

    // MARK: - Audio setup
    private func configureSession() {
        do {
            // mic + speaker; avoid voiceChat/videoChat modes (they force earpiece & processing)
            if (session.category != .playAndRecord) {
                try session.setCategory(.playAndRecord,
                                        mode: .measurement,
                                        options: [.defaultToSpeaker, .allowBluetooth, .allowBluetoothA2DP])
            }
            // Try to match requested IO timing
            if (session.preferredSampleRate != desiredSR) {
                try session.setPreferredSampleRate(desiredSR)
            }
            
            let dur = Double(desiredFrames) / desiredSR
            if (session.preferredIOBufferDuration != dur){
                try session.setPreferredIOBufferDuration(dur)
            }
       
   
            try session.setActive(true)

            // Double-ensure speaker if route came up as receiver
            if session.currentRoute.outputs.first?.portType == .builtInReceiver {
                try? session.overrideOutputAudioPort(.speaker)
            }
        } catch {
            print("[IosAudioCapture] Session error: \(error)")
        }
    }

    private func startCapture() {
        print("got here at least\n")
        if isRunning { return }
        configureSession()

        // Build converter target: Float32 mono @ desiredSR
        targetFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32,
                                     sampleRate: desiredSR,
                                     channels: 1,
                                     interleaved: false)

        let input = engine.inputNode
        let srcFormat = input.inputFormat(forBus: 0) // HW format (likely 48k, mono)
        converter = AVAudioConverter(from: srcFormat, to: targetFormat!)

        // Install tap in HW format; we’ll convert in the callback
        if tapInstalled { input.removeTap(onBus: 0) }
        input.installTap(onBus: 0, bufferSize: 1024, format: srcFormat) { [weak self] buf, _ in
            self?.q.async {
                self?.process(buffer: buf, srcFormat: srcFormat)
            }
        }
        tapInstalled = true

        do {
            if !engine.isRunning {
                try engine.start()
            }
            isRunning = true
        } catch {
            print("[IosAudioCapture] Engine start error: \(error)")
        }
    }

    private func stopCapture() {
        guard isRunning else { return }
        engine.inputNode.removeTap(onBus: 0)
        tapInstalled = false
        engine.stop()
        isRunning = false
        ring.removeAll(keepingCapacity: false)

        // If you want to hand session back to playback-only, uncomment:
        // try? session.setCategory(.playback, mode: .default, options: [])
        // try? session.setActive(true)
    }

    // MARK: - Convert, chunk, emit
    private func process(buffer src: AVAudioPCMBuffer, srcFormat: AVAudioFormat) {
        guard let converter = converter, let target = targetFormat else { return }

        // Prepare output buffer (size big enough for one callback; converter will set frameLength)
        let capacity = AVAudioFrameCount(Double(src.frameLength) * desiredSR / srcFormat.sampleRate + 1024)
        guard let out = AVAudioPCMBuffer(pcmFormat: target, frameCapacity: capacity) else { return }

        var err: NSError?
        let inputBlock: AVAudioConverterInputBlock = { _, outStatus in
            outStatus.pointee = .haveData
            return src
        }
        converter.convert(to: out, error: &err, withInputFrom: inputBlock)
        if let err { print("[IosAudioCapture] Convert error: \(err)"); return }
        let n = Int(out.frameLength)
        guard n > 0, let ch0 = out.floatChannelData?[0] else { return }

        // Accumulate to fixed-size frames
        ring.reserveCapacity(ring.count + n)
        ring.append(contentsOf: UnsafeBufferPointer(start: ch0, count: n))

        while ring.count >= desiredFrames {
            // Take exactly desiredFrames samples
            let chunk = ring.prefix(desiredFrames)
            // Send as bytes; Dart converts to Float32List
            let data = chunk.withUnsafeBufferPointer { Data(buffer: $0) }
            if let sink = eventSink {
                DispatchQueue.main.async { sink(FlutterStandardTypedData(bytes: data)) }
            }
            ring.removeFirst(desiredFrames)
        }
    }
}
