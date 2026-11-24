import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Display während des Spiels anlassen (US-803) — gleicher Kanal wie
    // MainActivity unter Android (US-702)
    FlutterMethodChannel(
      name: "de.beobachter/screen",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
      .setMethodCallHandler { call, result in
        switch call.method {
        case "setKeepScreenOn":
          UIApplication.shared.isIdleTimerDisabled = (call.arguments as? Bool) == true
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
  }
}
