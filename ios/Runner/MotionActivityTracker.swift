import CoreMotion
import Foundation

/// CMMotionActivityManager wrapper mapping iOS motion states onto the same
/// internal activity types used on Android (still/walking/running/cycling/
/// vehicle/unknown). iOS delivers continuous samples, not transitions; the
/// Dart state machine treats them accordingly.
final class MotionActivityTracker {
    private let manager = CMMotionActivityManager()
    private var emit: (([String: Any?]) -> Void)?
    private(set) var isRunning = false

    func setEmitter(_ emitter: @escaping ([String: Any?]) -> Void) {
        emit = emitter
    }

    static func isAvailable() -> Bool {
        CMMotionActivityManager.isActivityAvailable()
    }

    func start() {
        guard CMMotionActivityManager.isActivityAvailable(), !isRunning else { return }
        isRunning = true
        manager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let self, let activity, let emit = self.emit else { return }
            emit([
                "timestampMs": Int(activity.startDate.timeIntervalSince1970 * 1000),
                "activityType": Self.mapType(activity),
                "transition": "sample",
                "confidence": Self.mapConfidence(activity.confidence),
                "platformSource": "ios",
                "rawValue": Self.rawDescription(activity),
            ])
        }
    }

    func stop() {
        manager.stopActivityUpdates()
        isRunning = false
    }

    private static func mapType(_ activity: CMMotionActivity) -> String {
        if activity.automotive { return "vehicle" }
        if activity.cycling { return "cycling" }
        if activity.running { return "running" }
        if activity.walking { return "walking" }
        if activity.stationary { return "still" }
        return "unknown"
    }

    private static func mapConfidence(_ confidence: CMMotionActivityConfidence) -> Double {
        switch confidence {
        case .high: return 0.9
        case .medium: return 0.6
        default: return 0.3
        }
    }

    private static func rawDescription(_ a: CMMotionActivity) -> String {
        "stationary=\(a.stationary) walking=\(a.walking) running=\(a.running) "
            + "automotive=\(a.automotive) cycling=\(a.cycling) unknown=\(a.unknown) "
            + "confidence=\(a.confidence.rawValue)"
    }
}
