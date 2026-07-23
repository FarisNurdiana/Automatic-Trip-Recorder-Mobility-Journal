import 'dart:async';

import 'location_models.dart';
import 'location_tracking_service.dart';

/// In-memory [LocationTrackingService] fed by a [TripSimulator] or directly
/// from tests. No platform dependencies.
class SimulatedLocationTrackingService implements LocationTrackingService {
  final _locations = StreamController<RecordedLocation>.broadcast();
  final _actions = StreamController<TrackingNotificationAction>.broadcast();

  bool started = false;
  LocationSamplingProfile? profile;
  String? lastNotificationTitle;
  String? lastNotificationBody;
  bool lastNotificationQuestion = false;

  /// Push a fix into the stream (used by simulator playback and tests).
  void emit(RecordedLocation location) {
    if (started) _locations.add(location);
  }

  /// Simulate the user tapping a notification action.
  void emitAction(TrackingNotificationAction action) => _actions.add(action);

  @override
  Stream<RecordedLocation> get locationStream => _locations.stream;

  @override
  Stream<TrackingNotificationAction> get notificationActions => _actions.stream;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<void> start({required LocationSamplingProfile profile}) async {
    started = true;
    this.profile = profile;
  }

  @override
  Future<void> setProfile(LocationSamplingProfile profile) async {
    this.profile = profile;
  }

  @override
  Future<void> updateNotification({
    required String title,
    required String body,
    bool paused = false,
    bool question = false,
  }) async {
    lastNotificationQuestion = question;
    lastNotificationTitle = title;
    lastNotificationBody = body;
  }

  @override
  Future<void> stop() async {
    started = false;
  }

  void dispose() {
    _locations.close();
    _actions.close();
  }
}
