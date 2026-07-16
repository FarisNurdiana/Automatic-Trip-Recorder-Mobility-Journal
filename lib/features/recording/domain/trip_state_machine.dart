import '../../../core/activity/activity_models.dart';
import '../../../core/config/trip_detection_config.dart';
import '../../../core/constants/enums.dart';
import '../../../core/location/location_models.dart';
import '../../../core/utils/geo_utils.dart';

/// A single state change with its cause, for logging and side effects.
class TripStateTransition {
  const TripStateTransition({
    required this.from,
    required this.to,
    required this.at,
    required this.reason,
  });

  final TripRecordingState from;
  final TripRecordingState to;
  final DateTime at;
  final String reason;

  @override
  String toString() => '${from.name} -> ${to.name} ($reason)';
}

/// Abstract contract so orchestration code can be tested against fakes.
abstract interface class TripStateMachine {
  TripRecordingState get state;

  List<TripStateTransition> onActivity(DetectedActivity activity);
  List<TripStateTransition> onLocation(RecordedLocation location);

  /// Periodic evaluation of time-based rules (timeouts, stop windows).
  List<TripStateTransition> onTick(DateTime now);

  List<TripStateTransition> manualStart(DateTime now);
  List<TripStateTransition> manualPause(DateTime now);
  List<TripStateTransition> manualResume(DateTime now);
  List<TripStateTransition> manualFinish(DateTime now);
  List<TripStateTransition> manualCancel(DateTime now);

  /// Marks the finishing work as done (summary calculated & stored).
  List<TripStateTransition> completeFinish(DateTime now);

  /// Returns to [TripRecordingState.idle] after finished/cancelled.
  void reset();

  /// Restores an active state after the app was killed mid-trip.
  void restore(TripRecordingState state, DateTime now);
}

/// Rule-based implementation driven entirely by injected events and
/// timestamps — no timers, no platform calls — so every transition path is
/// unit-testable. Thresholds come from [TripDetectionConfig].
class DefaultTripStateMachine implements TripStateMachine {
  DefaultTripStateMachine({TripDetectionConfig? config})
    : config = config ?? defaultTripDetectionConfig;

  final TripDetectionConfig config;

  TripRecordingState _state = TripRecordingState.idle;

  @override
  TripRecordingState get state => _state;

  // --- aggregates ---
  DetectedActivity? _lastActivity;
  RecordedLocation? _lastValidLocation;

  DateTime? _possibleTripSince;
  RecordedLocation? _possibleTripAnchor;
  DateTime? _sustainedSpeedSince;
  int _consistentMovingPoints = 0;

  RecordedLocation? _stopAnchor;
  DateTime? _stopCandidateSince;
  DateTime? _nonVehicleSince;
  bool _manuallyPaused = false;

  DetectedActivity? get lastActivity => _lastActivity;
  RecordedLocation? get lastValidLocation => _lastValidLocation;

  bool _isValid(RecordedLocation l) {
    final acc = l.horizontalAccuracy;
    return acc == null || acc <= config.maxHorizontalAccuracyMeters;
  }

  List<TripStateTransition> _go(
    TripRecordingState to,
    DateTime at,
    String reason,
  ) {
    final t = TripStateTransition(from: _state, to: to, at: at, reason: reason);
    _state = to;
    return [t];
  }

  // -------------------------------------------------------------------------
  // Activity events
  // -------------------------------------------------------------------------

  @override
  List<TripStateTransition> onActivity(DetectedActivity activity) {
    _lastActivity = activity;
    final now = activity.recordedAt;

    switch (_state) {
      case TripRecordingState.idle:
        final confident =
            activity.confidence == null ||
            activity.confidence! >= config.minActivityConfidence;
        final isVehicleEnter =
            activity.type == DetectedActivityType.vehicle &&
            activity.transition != ActivityTransition.exit;
        if (isVehicleEnter && confident) {
          _enterPossibleTrip(now);
          return _go(
            TripRecordingState.possibleTrip,
            now,
            'activity:vehicle conf=${activity.confidence}',
          );
        }
      case TripRecordingState.possibleTrip:
        // A confident non-vehicle transition cancels the candidate.
        if (activity.type != DetectedActivityType.vehicle &&
            activity.type != DetectedActivityType.unknown &&
            activity.transition == ActivityTransition.enter) {
          _resetPossible();
          return _go(
            TripRecordingState.idle,
            now,
            'activity:${activity.type.name} cancels candidate',
          );
        }
      case TripRecordingState.temporarilyStopped:
        // Track how long the user has been out of a vehicle.
        if (activity.type == DetectedActivityType.vehicle) {
          _nonVehicleSince = null;
        } else if (activity.type != DetectedActivityType.unknown) {
          _nonVehicleSince ??= now;
        }
      case TripRecordingState.recording:
      case TripRecordingState.finishing:
      case TripRecordingState.finished:
      case TripRecordingState.cancelled:
        break;
    }
    return const [];
  }

  void _enterPossibleTrip(DateTime now) {
    _possibleTripSince = now;
    _possibleTripAnchor = _lastValidLocation;
    _sustainedSpeedSince = null;
    _consistentMovingPoints = 0;
  }

  void _resetPossible() {
    _possibleTripSince = null;
    _possibleTripAnchor = null;
    _sustainedSpeedSince = null;
    _consistentMovingPoints = 0;
  }

  // -------------------------------------------------------------------------
  // Location events
  // -------------------------------------------------------------------------

  @override
  List<TripStateTransition> onLocation(RecordedLocation location) {
    if (!_isValid(location)) return const [];
    final previous = _lastValidLocation;
    _lastValidLocation = location;
    final now = location.recordedAt;

    switch (_state) {
      case TripRecordingState.possibleTrip:
        return _evaluatePossibleTrip(location, previous, now);
      case TripRecordingState.recording:
        return _evaluateRecording(location, now);
      case TripRecordingState.temporarilyStopped:
        return _evaluateTemporarilyStopped(location, now);
      case TripRecordingState.idle:
      case TripRecordingState.finishing:
      case TripRecordingState.finished:
      case TripRecordingState.cancelled:
        return const [];
    }
  }

  List<TripStateTransition> _evaluatePossibleTrip(
    RecordedLocation location,
    RecordedLocation? previous,
    DateTime now,
  ) {
    _possibleTripAnchor ??= location;
    final speedKmh = location.speedKmh;

    // Condition 1: displacement from the anchor.
    final anchor = _possibleTripAnchor!;
    final displacement = GeoUtils.haversineMeters(
      anchor.latitude,
      anchor.longitude,
      location.latitude,
      location.longitude,
    );
    if (displacement >= config.possibleTripMinDisplacementMeters) {
      return _startRecording(now, 'displacement ${displacement.round()}m');
    }

    // Condition 2: sustained valid speed.
    if (speedKmh != null && speedKmh >= config.possibleTripMinSpeedKmh) {
      _sustainedSpeedSince ??= now;
      if (now.difference(_sustainedSpeedSince!) >=
          config.possibleTripMinSpeedDuration) {
        return _startRecording(
          now,
          'speed>=${config.possibleTripMinSpeedKmh}km/h sustained',
        );
      }
    } else if (speedKmh != null) {
      _sustainedSpeedSince = null;
    }

    // Condition 3: several consecutive points moving consistently.
    if (previous != null) {
      final stepMeters = GeoUtils.haversineMeters(
        previous.latitude,
        previous.longitude,
        location.latitude,
        location.longitude,
      );
      final dt = now.difference(previous.recordedAt).inMilliseconds / 1000.0;
      final impliedKmh = dt > 0 ? GeoUtils.msToKmh(stepMeters / dt) : 0.0;
      if (impliedKmh >= config.possibleTripMinSpeedKmh &&
          impliedKmh <= config.maxRealisticSpeedKmh) {
        _consistentMovingPoints++;
        if (_consistentMovingPoints >= config.possibleTripMinConsistentPoints) {
          return _startRecording(
            now,
            '$_consistentMovingPoints consistent moving points',
          );
        }
      } else {
        _consistentMovingPoints = 0;
      }
    }
    return const [];
  }

  List<TripStateTransition> _startRecording(DateTime now, String reason) {
    _resetPossible();
    _stopAnchor = null;
    _stopCandidateSince = null;
    _nonVehicleSince = null;
    _manuallyPaused = false;
    return _go(TripRecordingState.recording, now, reason);
  }

  List<TripStateTransition> _evaluateRecording(
    RecordedLocation location,
    DateTime now,
  ) {
    final speedKmh = location.speedKmh ?? 0;
    if (speedKmh <= config.stopSpeedThresholdKmh) {
      _stopAnchor ??= location;
      final jitter = GeoUtils.haversineMeters(
        _stopAnchor!.latitude,
        _stopAnchor!.longitude,
        location.latitude,
        location.longitude,
      );
      if (jitter <= config.stopLocationJitterMeters) {
        _stopCandidateSince ??= now;
        if (now.difference(_stopCandidateSince!) >= config.stopMinDuration) {
          _nonVehicleSince = null;
          return _go(
            TripRecordingState.temporarilyStopped,
            now,
            'low speed & stable for >=${config.stopMinDuration.inSeconds}s',
          );
        }
      } else {
        // Drifted out of the stable radius: restart the stop window.
        _stopAnchor = location;
        _stopCandidateSince = now;
      }
    } else {
      _stopAnchor = null;
      _stopCandidateSince = null;
    }
    return const [];
  }

  List<TripStateTransition> _evaluateTemporarilyStopped(
    RecordedLocation location,
    DateTime now,
  ) {
    if (_manuallyPaused) return const [];
    final speedKmh = location.speedKmh ?? 0;
    final movedFromStop = _stopAnchor == null
        ? false
        : GeoUtils.haversineMeters(
                _stopAnchor!.latitude,
                _stopAnchor!.longitude,
                location.latitude,
                location.longitude,
              ) >
              config.stopLocationJitterMeters * 2;
    if (speedKmh > config.possibleTripMinSpeedKmh || movedFromStop) {
      _stopAnchor = null;
      _stopCandidateSince = null;
      _nonVehicleSince = null;
      return _go(TripRecordingState.recording, now, 'movement resumed');
    }
    return const [];
  }

  // -------------------------------------------------------------------------
  // Time-based rules
  // -------------------------------------------------------------------------

  @override
  List<TripStateTransition> onTick(DateTime now) {
    switch (_state) {
      case TripRecordingState.possibleTrip:
        if (_possibleTripSince != null &&
            now.difference(_possibleTripSince!) >= config.possibleTripTimeout) {
          _resetPossible();
          return _go(TripRecordingState.idle, now, 'possibleTrip timeout');
        }
      case TripRecordingState.temporarilyStopped:
        if (_manuallyPaused) return const [];
        final activityNotVehicle =
            _lastActivity != null &&
            _lastActivity!.type != DetectedActivityType.vehicle &&
            _lastActivity!.type != DetectedActivityType.unknown;
        if (activityNotVehicle && _nonVehicleSince == null) {
          _nonVehicleSince = _lastActivity!.recordedAt;
        }
        if (_nonVehicleSince != null &&
            now.difference(_nonVehicleSince!) >= config.finishAfterStopped) {
          return _go(
            TripRecordingState.finishing,
            now,
            'non-vehicle & stable for >=${config.finishAfterStopped.inMinutes}min',
          );
        }
      case TripRecordingState.idle:
      case TripRecordingState.recording:
      case TripRecordingState.finishing:
      case TripRecordingState.finished:
      case TripRecordingState.cancelled:
        break;
    }
    return const [];
  }

  // -------------------------------------------------------------------------
  // Manual controls
  // -------------------------------------------------------------------------

  @override
  List<TripStateTransition> manualStart(DateTime now) {
    if (_state == TripRecordingState.idle ||
        _state == TripRecordingState.possibleTrip) {
      return _startRecording(now, 'manual start');
    }
    return const [];
  }

  @override
  List<TripStateTransition> manualPause(DateTime now) {
    if (_state == TripRecordingState.recording) {
      _manuallyPaused = true;
      _stopAnchor = _lastValidLocation;
      return _go(TripRecordingState.temporarilyStopped, now, 'manual pause');
    }
    return const [];
  }

  @override
  List<TripStateTransition> manualResume(DateTime now) {
    if (_state == TripRecordingState.temporarilyStopped) {
      _manuallyPaused = false;
      _stopAnchor = null;
      _stopCandidateSince = null;
      _nonVehicleSince = null;
      return _go(TripRecordingState.recording, now, 'manual resume');
    }
    return const [];
  }

  @override
  List<TripStateTransition> manualFinish(DateTime now) {
    if (_state == TripRecordingState.recording ||
        _state == TripRecordingState.temporarilyStopped) {
      return _go(TripRecordingState.finishing, now, 'manual finish');
    }
    return const [];
  }

  @override
  List<TripStateTransition> manualCancel(DateTime now) {
    if (_state.isActiveTrip || _state == TripRecordingState.possibleTrip) {
      _resetPossible();
      return _go(TripRecordingState.cancelled, now, 'manual cancel');
    }
    return const [];
  }

  @override
  List<TripStateTransition> completeFinish(DateTime now) {
    if (_state == TripRecordingState.finishing) {
      return _go(TripRecordingState.finished, now, 'summary stored');
    }
    return const [];
  }

  @override
  void reset() {
    _state = TripRecordingState.idle;
    _resetPossible();
    _stopAnchor = null;
    _stopCandidateSince = null;
    _nonVehicleSince = null;
    _manuallyPaused = false;
  }

  @override
  void restore(TripRecordingState state, DateTime now) {
    _state = state;
    if (state == TripRecordingState.temporarilyStopped) {
      _stopCandidateSince = now;
    }
  }
}
