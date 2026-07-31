import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

/// Loud over-speed warning: alarm sound (alarm volume stream) + vibration
/// for a bounded duration, implemented natively on Android.
abstract interface class SpeedAlarm {
  /// Starts the alarm; it stops itself after [duration].
  Future<void> start({Duration duration});

  /// Stops the alarm early (e.g. the trip ended).
  Future<void> stop();
}

/// Android implementation over the `triplog/alarm` method channel.
class MethodChannelSpeedAlarm implements SpeedAlarm {
  MethodChannelSpeedAlarm({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel('triplog/alarm');

  final MethodChannel _channel;
  final _log = Logger('MethodChannelSpeedAlarm');

  @override
  Future<void> start({Duration duration = const Duration(seconds: 10)}) async {
    try {
      await _channel.invokeMethod('start', {
        'durationMs': duration.inMilliseconds,
      });
    } on PlatformException catch (e) {
      _log.warning('speed alarm start failed', e);
    } on MissingPluginException {
      // Not available on this platform (iOS/tests) — best effort only.
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod('stop');
    } on PlatformException catch (e) {
      _log.warning('speed alarm stop failed', e);
    } on MissingPluginException {
      // Best effort.
    }
  }
}

/// Test/simulator implementation that only records calls.
class RecordingSpeedAlarm implements SpeedAlarm {
  int startCount = 0;
  int stopCount = 0;
  Duration? lastDuration;

  @override
  Future<void> start({Duration duration = const Duration(seconds: 10)}) async {
    startCount++;
    lastDuration = duration;
  }

  @override
  Future<void> stop() async {
    stopCount++;
  }
}
