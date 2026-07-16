import 'dart:async';

import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import 'activity_models.dart';
import 'activity_recognition_service.dart';

/// Bridges to native activity recognition:
///  * Android — Activity Recognition Transition API (enter/exit vehicle,
///    walking, still) plus periodic sampled updates.
///  * iOS — CMMotionActivityManager mapped onto the same internal types.
class MethodChannelActivityRecognitionService
    implements ActivityRecognitionService {
  MethodChannelActivityRecognitionService({
    MethodChannel? channel,
    EventChannel? events,
  }) : _channel = channel ?? const MethodChannel('triplog/activity'),
       _events = events ?? const EventChannel('triplog/activity_stream');

  final MethodChannel _channel;
  final EventChannel _events;
  final _log = Logger('MethodChannelActivityRecognitionService');

  Stream<DetectedActivity>? _stream;

  @override
  Stream<DetectedActivity> get activityStream => _stream ??= _events
      .receiveBroadcastStream()
      .map((event) => DetectedActivity.fromMap(event as Map))
      .asBroadcastStream();

  @override
  Future<bool> isAvailable() async {
    try {
      return await _channel.invokeMethod<bool>('isAvailable') ?? false;
    } on PlatformException catch (e) {
      _log.warning('isAvailable failed', e);
      return false;
    }
  }

  @override
  Future<void> start() => _channel.invokeMethod('start');

  @override
  Future<void> stop() => _channel.invokeMethod('stop');
}
