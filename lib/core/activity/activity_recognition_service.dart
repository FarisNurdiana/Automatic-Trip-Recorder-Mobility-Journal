import 'activity_models.dart';

/// Native activity recognition. Android uses the Activity Recognition
/// Transition API; iOS uses CMMotionActivityManager. Events are triggers
/// only — the trip state machine decides whether a trip actually starts.
abstract interface class ActivityRecognitionService {
  /// Normalized activity events from the platform.
  Stream<DetectedActivity> get activityStream;

  /// Whether the device/platform supports activity recognition.
  Future<bool> isAvailable();

  /// Begins delivering events. Requires the activity-recognition (Android) /
  /// motion & fitness (iOS) permission.
  Future<void> start();

  Future<void> stop();
}
