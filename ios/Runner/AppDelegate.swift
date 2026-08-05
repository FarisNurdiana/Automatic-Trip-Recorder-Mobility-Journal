import AudioToolbox
import CoreLocation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private let locationTracker = LocationTracker()
  private let motionTracker = MotionActivityTracker()
  private let oneShotLocator = OneShotLocator()

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
      case "currentPosition":
        // One-shot fix for the nearby fuel/workshop lookup.
        self.oneShotLocator.request { location in
          guard let location else {
            result(nil)
            return
          }
          result([
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "timestamp": Int(location.timestamp.timeIntervalSince1970 * 1000),
          ])
        }
      case "trackingStatus":
        // iOS has no independent native service to adopt: tracking lives
        // and dies with the app process.
        result(["isTracking": self.locationTracker.isTracking, "startedAtMillis": 0])
      case "consumeBackgroundTrack":
        result([String]())
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // ---- speed-limit alarm (sound + vibration) ----
    let alarmChannel = FlutterMethodChannel(
      name: "triplog/alarm", binaryMessenger: messenger)
    alarmChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "start":
        let args = call.arguments as? [String: Any]
        SpeedAlarmPlayer.shared.start(durationMs: args?["durationMs"] as? Int ?? 10000)
        result(nil)
      case "stop":
        SpeedAlarmPlayer.shared.stop()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // ---- quick actions (no Quick Settings tile on iOS) ----
    let shortcutsChannel = FlutterMethodChannel(
      name: "triplog/shortcuts", binaryMessenger: messenger)
    shortcutsChannel.setMethodCallHandler { call, result in
      switch call.method {
      case "consumePendingAction":
        result(nil)
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

/// One-shot "where am I now" using its own CLLocationManager so it never
/// interferes with the continuous tracking manager. Serves a recent cached
/// fix instantly when available.
final class OneShotLocator: NSObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  private var completion: ((CLLocation?) -> Void)?

  override init() {
    super.init()
    manager.delegate = self
    manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
  }

  func request(_ completion: @escaping (CLLocation?) -> Void) {
    if let cached = manager.location,
      cached.timestamp > Date(timeIntervalSinceNow: -30) {
      completion(cached)
      return
    }
    // A newer request supersedes any pending one.
    self.completion?(nil)
    self.completion = completion
    manager.requestLocation()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    completion?(locations.last)
    completion = nil
  }

  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    completion?(nil)
    completion = nil
  }
}

/// Over-speed warning: repeating system alert sound + vibration for a
/// bounded duration. AudioToolbox needs no audio-session setup and keeps
/// working when the phone is in a pocket.
final class SpeedAlarmPlayer {
  static let shared = SpeedAlarmPlayer()

  private var timer: Timer?
  private var stopAt: Date?

  func start(durationMs: Int) {
    stop()
    stopAt = Date().addingTimeInterval(Double(durationMs) / 1000.0)
    let timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] t in
      guard let self else {
        t.invalidate()
        return
      }
      if let stopAt = self.stopAt, Date() >= stopAt {
        self.stop()
        return
      }
      AudioServicesPlaySystemSound(1005)
      AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    self.timer = timer
    timer.fire()
  }

  func stop() {
    timer?.invalidate()
    timer = nil
    stopAt = nil
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
