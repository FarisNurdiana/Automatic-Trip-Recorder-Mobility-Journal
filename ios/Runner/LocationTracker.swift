import CoreLocation
import Flutter
import UIKit

/// Core Location tracker with background updates for trip recording.
/// Sampling adapts to the profile requested from Dart:
///  * moving  — best accuracy, ~5 m distance filter
///  * slow    — best accuracy, ~15 m distance filter
///  * stopped — reduced accuracy, ~30 m distance filter
final class LocationTracker: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private var emit: (([String: Any?]) -> Void)?
    private(set) var isTracking = false

    override init() {
        super.init()
        manager.delegate = self
        manager.pausesLocationUpdatesAutomatically = false
        manager.activityType = .automotiveNavigation
    }

    func setEmitter(_ emitter: @escaping ([String: Any?]) -> Void) {
        emit = emitter
    }

    func isLocationServiceEnabled() -> Bool {
        if #available(iOS 14.0, *) {
            return manager.authorizationStatus != .denied
                && manager.authorizationStatus != .restricted
        }
        return CLLocationManager.locationServicesEnabled()
    }

    func start(profile: String) {
        applyProfile(profile)
        // Background updates require the "location" UIBackgroundMode and the
        // Always (or provisional while-in-use) authorization.
        manager.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            manager.showsBackgroundLocationIndicator = true
        }
        manager.startUpdatingLocation()
        isTracking = true
    }

    func setProfile(_ profile: String) {
        applyProfile(profile)
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.allowsBackgroundLocationUpdates = false
        isTracking = false
    }

    private func applyProfile(_ profile: String) {
        switch profile {
        case "moving":
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = 5
        case "slow":
            manager.desiredAccuracy = kCLLocationAccuracyBest
            manager.distanceFilter = 15
        default: // stopped
            manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            manager.distanceFilter = 30
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let emit = emit else { return }
        let battery = batteryLevel()
        for location in locations {
            var isMocked: Bool? = nil
            if #available(iOS 15.0, *) {
                isMocked = location.sourceInformation?.isSimulatedBySoftware
            }
            var headingAccuracy: Double? = nil
            if #available(iOS 13.4, *) {
                headingAccuracy = location.courseAccuracy >= 0 ? location.courseAccuracy : nil
            }
            emit([
                "timestampMs": Int(location.timestamp.timeIntervalSince1970 * 1000),
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
                "altitude": location.altitude,
                "horizontalAccuracy": location.horizontalAccuracy >= 0 ? location.horizontalAccuracy : nil,
                "verticalAccuracy": location.verticalAccuracy >= 0 ? location.verticalAccuracy : nil,
                "speed": location.speed >= 0 ? location.speed : nil,
                "speedAccuracy": location.speedAccuracy >= 0 ? location.speedAccuracy : nil,
                "heading": location.course >= 0 ? location.course : nil,
                "headingAccuracy": headingAccuracy,
                "source": "core_location",
                "isMocked": isMocked,
                "batteryLevel": battery,
            ])
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Transient failures (e.g. kCLErrorLocationUnknown) are expected;
        // recording continues with the next fix.
    }

    private func batteryLevel() -> Double? {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        return level >= 0 ? Double(level) : nil
    }
}
