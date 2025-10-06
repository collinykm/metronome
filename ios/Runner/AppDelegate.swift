import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        // Register our custom plugin
        MetronomePlugin.register(with: self.registrar(forPlugin: "MetronomePlugin")!)
      
        IosAudioCapturePlugin.register(with: self.registrar(forPlugin: "IosAudioCapturePlugin")!)
        MetronomeEngine.shared.initAudio()


        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
