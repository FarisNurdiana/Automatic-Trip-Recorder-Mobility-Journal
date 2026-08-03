import 'dart:async';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'location_models.dart';
import 'location_tracking_service.dart';

/// Bridges to the native trackers:
///  * Android — `TripTrackingService` foreground service using the platform
///    fused location provider, with a persistent notification.
///  * iOS — `LocationTracker` using Core Location with
///    `allowsBackgroundLocationUpdates`.
class MethodChannelLocationTrackingService implements LocationTrackingService {
  MethodChannelLocationTrackingService({
    MethodChannel? channel,
    EventChannel? locationEvents,
    EventChannel? actionEvents,
  }) : _channel = channel ?? const MethodChannel('triplog/location'),
       _locationEvents =
           locationEvents ?? const EventChannel('triplog/location_stream'),
       _actionEvents =
           actionEvents ?? const EventChannel('triplog/notification_actions');

  final MethodChannel _channel;
  final EventChannel _locationEvents;
  final EventChannel _actionEvents;
  final _log = Logger('MethodChannelLocationTrackingService');

  Stream<RecordedLocation>? _locations;
  Stream<TrackingNotificationAction>? _actions;

  @override
  Stream<RecordedLocation> get locationStream => _locations ??= _locationEvents
      .receiveBroadcastStream()
      .map((event) => RecordedLocation.fromMap(event as Map))
      .handleError((Object e) {
        _log.warning('location stream error', e);
        throw e;
      })
      .asBroadcastStream();

  @override
  Stream<TrackingNotificationAction> get notificationActions =>
      _actions ??= _actionEvents
          .receiveBroadcastStream()
          .map(
            (event) => switch (event as String) {
              'pause' => TrackingNotificationAction.pause,
              'resume' => TrackingNotificationAction.resume,
              'arrived' => TrackingNotificationAction.arrived,
              'resting' => TrackingNotificationAction.resting,
              'continue' => TrackingNotificationAction.continueTrip,
              _ => TrackingNotificationAction.stop,
            },
          )
          .asBroadcastStream();

  @override
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('isLocationServiceEnabled') ??
          false;
    } on PlatformException catch (e) {
      _log.warning('isLocationServiceEnabled failed', e);
      return false;
    }
  }

  @override
  Future<void> start({required LocationSamplingProfile profile}) async {
    await _channel.invokeMethod('startTracking', {'profile': profile.name});
  }

  @override
  Future<void> setProfile(LocationSamplingProfile profile) async {
    await _channel.invokeMethod('setProfile', {'profile': profile.name});
  }

  @override
  Future<void> updateNotification({
    required String title,
    required String body,
    bool paused = false,
    bool question = false,
  }) async {
    try {
      await _channel.invokeMethod('updateNotification', {
        'title': title,
        'body': body,
        'paused': paused,
        'question': question,
      });
    } on PlatformException {
      // Notification updates are best-effort (no-op on iOS).
    }
  }

  @override
  Future<void> stop() async {
    await _channel.invokeMethod('stopTracking');
  }

  @override
  Future<RecordedLocation?> currentPosition() async {
    try {
      final map = await _channel.invokeMethod<Map<Object?, Object?>>(
        'currentPosition',
      );
      if (map == null) return null;
      return RecordedLocation(
        recordedAt: DateTime.fromMillisecondsSinceEpoch(
          (map['timestamp'] as num?)?.toInt() ??
              DateTime.now().millisecondsSinceEpoch,
          isUtc: true,
        ),
        latitude: (map['latitude']! as num).toDouble(),
        longitude: (map['longitude']! as num).toDouble(),
        horizontalAccuracy: (map['accuracy'] as num?)?.toDouble(),
        source: 'oneShot',
      );
    } on PlatformException catch (e) {
      _log.warning('currentPosition failed', e);
      return null;
    }
  }

  @override
  Future<DateTime?> backgroundTrackingStartedAt() async {
    try {
      final map = await _channel.invokeMethod<Map<Object?, Object?>>(
        'trackingStatus',
      );
      if (map == null || map['isTracking'] != true) return null;
      final startedAt = (map['startedAtMillis'] as num?)?.toInt() ?? 0;
      if (startedAt <= 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(startedAt, isUtc: true);
    } on PlatformException catch (e) {
      _log.warning('trackingStatus failed', e);
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<List<String>> consumeBackgroundTrackLines() async {
    try {
      final lines = await _channel.invokeMethod<List<Object?>>(
        'consumeBackgroundTrack',
      );
      return lines?.whereType<String>().toList() ?? const [];
    } on PlatformException catch (e) {
      _log.warning('consumeBackgroundTrack failed', e);
      return const [];
    } on MissingPluginException {
      return const [];
    }
  }
}
