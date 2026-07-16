import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let locationTracker = LocationTracker()
  private let motionTracker = MotionActivityTracker()

  private var locationSink: FlutterEventSink?
  private var activitySink: FlutterEventSink?
  private var actionSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    guard let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "TripLogNative") else {
      return
    }
    let messenger = registrar.messenger()

    locationTracker.setEmitter { [weak self] event in
      self?.locationSink?(event)
    }
    motionTracker.setEmitter { [weak self] event in
      self?.activitySink?(event)
    }

    // ---- location tracking ----
    let locationChannel = FlutterMethodChannel(
      name: "triplog/location", binaryMessenger: messenger)
    locationChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      switch call.method {
      case "startTracking":
        let args = call.arguments as? [String: Any]
        self.locationTracker.start(profile: args?["profile"] as? String ?? "moving")
        result(nil)
      case "setProfile":
        let args = call.arguments as? [String: Any]
        self.locationTracker.setProfile(args?["profile"] as? String ?? "moving")
        result(nil)
      case "updateNotification":
        // iOS has no persistent notification; the system shows its own
        // background-location indicator.
        result(nil)
      case "stopTracking":
        self.locationTracker.stop()
        result(nil)
      case "isLocationServiceEnabled":
        result(self.locationTracker.isLocationServiceEnabled())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    FlutterEventChannel(name: "triplog/location_stream", binaryMessenger: messenger)
      .setStreamHandler(SinkHandler { [weak self] sink in self?.locationSink = sink })

    FlutterEventChannel(name: "triplog/notification_actions", binaryMessenger: messenger)
      .setStreamHandler(SinkHandler { [weak self] sink in self?.actionSink = sink })

    // ---- activity recognition (Core Motion) ----
    let activityChannel = FlutterMethodChannel(
      name: "triplog/activity", binaryMessenger: messenger)
    activityChannel.setMethodCallHandler { [weak self] call, result in
      guard let self else { return }
      switch call.method {
      case "isAvailable":
        result(MotionActivityTracker.isAvailable())
      case "start":
        self.motionTracker.start()
        result(nil)
      case "stop":
        self.motionTracker.stop()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    FlutterEventChannel(name: "triplog/activity_stream", binaryMessenger: messenger)
      .setStreamHandler(SinkHandler { [weak self] sink in self?.activitySink = sink })
  }
}

/// Minimal FlutterStreamHandler storing the sink through a closure.
final class SinkHandler: NSObject, FlutterStreamHandler {
  private let assign: (FlutterEventSink?) -> Void

  init(_ assign: @escaping (FlutterEventSink?) -> Void) {
    self.assign = assign
  }

  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    assign(events)
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    assign(nil)
    return nil
  }
}
