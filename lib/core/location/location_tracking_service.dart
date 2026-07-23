import 'location_models.dart';

/// Background-capable GPS recording. Implementations:
///  * [MethodChannelLocationTrackingService] — native Android foreground
///    service (fused provider) / iOS Core Location background updates.
///  * [SimulatedLocationTrackingService] — replays a JSON route for tests
///    and development without driving.
abstract interface class LocationTrackingService {
  /// Stream of location fixes while tracking is active.
  Stream<RecordedLocation> get locationStream;

  /// Notification action taps (pause/resume/stop) on Android; empty on iOS.
  Stream<TrackingNotificationAction> get notificationActions;

  /// Whether location services (GPS) are enabled on the device.
  Future<bool> isLocationServiceEnabled();

  /// Starts tracking with the given sampling profile. On Android this starts
  /// a foreground service with a persistent notification.
  Future<void> start({required LocationSamplingProfile profile});

  /// Adjusts adaptive sampling without restarting the tracker.
  Future<void> setProfile(LocationSamplingProfile profile);

  /// Updates the persistent notification content (Android only, no-op on
  /// other platforms). [paused] switches the action button set;
  /// [question] switches the actions to the arrived/resting/continue answers.
  Future<void> updateNotification({
    required String title,
    required String body,
    bool paused = false,
    bool question = false,
  });

  /// Stops tracking and removes the foreground service/notification.
  Future<void> stop();
}
