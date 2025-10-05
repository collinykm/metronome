//
//  MetronomePlugin.swift
//  Runner
//
//  Created by Collin Yang on 2025-10-04.
//

import Foundation
import Flutter

final class MetronomePlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
    private let METHODCHANNEL = "metronome_method_channel"
    private let EVENTCHANNEL  = "metronome_event_channel"

    private var eventSink: FlutterEventSink?

    static func register(with registrar: FlutterPluginRegistrar) {
        let instance = MetronomePlugin()

        let methodChannel = FlutterMethodChannel(name: instance.METHODCHANNEL, binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: methodChannel)

        let eventChannel = FlutterEventChannel(name: instance.EVENTCHANNEL, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(instance)

        // hookup engine events
        MetronomeEngine.shared.emitEvent = { payload in
            instance.eventSink?(payload)
        }
    }

    // MARK: - FlutterPlugin
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let engine = MetronomeEngine.shared
        switch call.method {
        case "playMetronome": engine.playMetronome(); result(nil)
        case "pauseMetronome": engine.pauseMetronome(); result(nil)
        case "playSong":
            if let song = call.arguments as? [String: Any] { engine.playSong(song) }
            result(nil)
        case "pauseSong": engine.pauseSong(); result(nil)
        case "updateTempo": if let v = call.arguments as? Int { engine.updateTempo(v) }; result(nil)
        case "updateAccent": if let v = call.arguments as? [Int] { engine.updateAccent(v) }; result(nil)
        case "updateMeter": if let v = call.arguments as? [Int] { engine.updateMeter(v) }; result(nil)
        case "updateSubdivision": if let v = call.arguments as? [Int] { engine.updateSubdivision(v) }; result(nil)
        case "playRefNote": engine.playRefNote(); result(nil)
        case "updateRefNote": if let v = call.arguments as? Double { engine.updateRefNote(v) }; result(nil)
        case "pauseRefNote": engine.pauseRefNote(); result(nil)
        default: result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - FlutterStreamHandler
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
