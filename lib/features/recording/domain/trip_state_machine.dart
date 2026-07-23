import 'package:logging/logging.dart';

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

/// User answers to the "arrived or resting?" question.
enum StopQuestionAnswer { arrived, resting, continueTrip }

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

  /// User answered the rest/arrived question.
  List<TripStateTransition> answerStopQuestion(
    StopQuestionAnswer answer,
    DateTime now,
  );

  /// Marks the finishing work as done (summary calculated & stored).
  List<TripStateTransition> completeFinish(DateTime now);

  /// Returns to [TripRecordingState.idle] after finished/cancelled.
  void reset();

  /// Restores an active state after the app was killed mid-trip.
  void restore(TripRecordingState state, DateTime now);

  /// When the current stop started (null while moving). Used as the arrival
  /// candidate when a stop turns out to be the destination.
  DateTime? get currentStopStartedAt;

  /// Recent human-readable detection decisions (why a trip started, was
  /// deferred, cancelled, or a fix was treated as a GPS jump).
  List<String> get diagnostics;
}

/// Rule-based implementation driven entirely by injected events and
/// timestamps — no timers, no platform calls — so every transition path is
/// unit-testable. Thresholds come from [TripDetectionConfig].
///
/// Never trusts a single GPS fix or a single sensor event: every transition
/// requires either a confident activity event, sustained evidence, or both.
class DefaultTripStateMachine implements TripStateMachine {
  DefaultTripStateMachine({TripDetectionConfig? config})
    : config = config ?? defaultTripDetectionConfig;

  final TripDetectionConfig config;
  final _log = Logger('TripDetection');

  TripRecordingState _state = TripRecordingState.idle;

  @override
  TripRecordingState get state => _state;

  // --- aggregates ---
  DetectedActivity? _lastActivity;

  /// Last activity event seen (diagnostics/tests).
  DetectedActivity? get lastActivity => _lastActivity;
  RecordedLocation? _lastValidLocation;
  int _validPointStreak = 0;

  // possibleTrip bookkeeping
  DateTime? _possibleTripSince;
  RecordedLocation? _possibleTripAnchor;
  DateTime? _sustainedSpeedSince;
  int _consistentMovingPoints = 0;

  // idle speed-trigger bookkeeping
  DateTime? _idleCandidateSpeedSince;
  RecordedLocation? _idleCandidateAnchor;

  // stop bookkeeping
  RecordedLocation? _stopAnchor;
  DateTime? _stopCandidateSince;
  DateTime? _stopStartedAt;
  DateTime? _nonVehicleSince;
  DateTime? _destinationCandidateSince;
  bool _manuallyPaused = false;
  bool _restAnswerReceived = false;

  final List<String> _diagnostics = [];

  @override
  DateTime? get currentStopStartedAt => _stopStartedAt;

  @override
  List<String> get diagnostics => List.unmodifiable(_diagnostics);

  void _diagnose(String message) {
    _log.fine(message);
    _diagnostics.add(message);
    if (_diagnostics.length > 100) _diagnostics.removeAt(0);
  }

  // -------------------------------------------------------------------------
  // Point acceptance (GPS jump / accuracy / warm-up guards)
  // -------------------------------------------------------------------------

  bool _acceptForDetection(RecordedLocation l) {
    final acc = l.horizontalAccuracy;
    if (acc != null && acc > config.maximumAcceptedAccuracyMeters) {
      _validPointStreak = 0;
      _diagnose('fix ignored: accuracy ${acc.round()}m too poor');
      return false;
    }
    final prev = _lastValidLocation;
    if (prev != null) {
      if (!l.recordedAt.isAfter(prev.recordedAt)) {
        _diagnose('fix ignored: timestamp not increasing');
        return false;
      }
      final meters = GeoUtils.haversineMeters(
        prev.latitude,
        prev.longitude,
        l.latitude,
        l.longitude,
      );
      final dt = l.recordedAt.difference(prev.recordedAt).inMilliseconds / 1000;
      final impliedKmh = dt > 0
          ? GeoUtils.msToKmh(meters / dt)
          : double.infinity;
      if (impliedKmh > config.maxRealisticSpeedKmh) {
        _diagnose(
          'fix rejected as GPS jump: implied ${impliedKmh.round()} km/h',
        );
        _validPointStreak = 0;
        return false;
      }
    }
    _validPointStreak++;
    // Fresh GPS is unstable: skip the first fixes after a cold start.
    if (_validPointStreak <= config.gpsWarmupPoints && prev == null) {
      _diagnose('fix accepted but in GPS warm-up window');
    }
    return true;
  }

  List<TripStateTransition> _go(
    TripRecordingState to,
    DateTime at,
    String reason,
  ) {
    final t = TripStateTransition(from: _state, to: to, at: at, reason: reason);
    _state = to;
    _diagnose(t.toString());
    return [t];
  }

  // -------------------------------------------------------------------------
  // Activity events
  // -------------------------------------------------------------------------

  @override
  List<TripStateTransition> onActivity(DetectedActivity activity) {
    _lastActivity = activity;
    final now = activity.recordedAt;

    final confident =
        activity.confidence == null ||
        activity.confidence! >= config.minActivityConfidence;
    final isVehicleEnter =
        activity.type == DetectedActivityType.vehicle &&
        activity.transition != ActivityTransition.exit;
    final isOnFoot =
        activity.type == DetectedActivityType.walking ||
        activity.type == DetectedActivityType.running;

    switch (_state) {
      case TripRecordingState.idle:
        if (isVehicleEnter && confident) {
          _enterPossibleTrip(now);
          return _go(
            TripRecordingState.possibleTrip,
            now,
            'activity:vehicle conf=${activity.confidence}',
          );
        }
        if (isVehicleEnter && !confident) {
          _diagnose(
            'trip deferred: vehicle activity below confidence '
            '(${activity.confidence})',
          );
        }
      case TripRecordingState.possibleTrip:
        // A confident on-foot/still transition cancels the candidate:
        // walking or running must never be treated as a vehicle.
        if ((isOnFoot || activity.type == DetectedActivityType.still) &&
            activity.transition == ActivityTransition.enter &&
            confident) {
          _resetPossible();
          return _go(
            TripRecordingState.idle,
            now,
            'candidate cancelled by activity:${activity.type.name}',
          );
        }
      case TripRecordingState.shortStop:
      case TripRecordingState.temporarilyStopped:
      case TripRecordingState.restStopCandidate:
      case TripRecordingState.destinationCandidate:
        // Track how long the user has been out of the vehicle.
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
    _idleCandidateSpeedSince = null;
    _idleCandidateAnchor = null;
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
    if (!_acceptForDetection(location)) return const [];
    final previous = _lastValidLocation;
    _lastValidLocation = location;
    final now = location.recordedAt;

    switch (_state) {
      case TripRecordingState.idle:
        return _evaluateIdle(location, now);
      case TripRecordingState.possibleTrip:
        return _evaluatePossibleTrip(location, previous, now);
      case TripRecordingState.recording:
        return _evaluateRecording(location, now);
      case TripRecordingState.shortStop:
      case TripRecordingState.temporarilyStopped:
      case TripRecordingState.restStopCandidate:
      case TripRecordingState.destinationCandidate:
        return _evaluateStopped(location, now);
      case TripRecordingState.finishing:
      case TripRecordingState.finished:
      case TripRecordingState.cancelled:
        return const [];
    }
  }

  /// Speed-based candidate trigger: 0 -> >candidate km/h sustained with real
  /// displacement enters possibleTrip even without an activity event.
  List<TripStateTransition> _evaluateIdle(
    RecordedLocation location,
    DateTime now,
  ) {
    final speedKmh = location.speedKmh;
    if (speedKmh == null) return const [];
    if (_validPointStreak <= config.gpsWarmupPoints) {
      // GPS just woke up — do not trust the first fixes.
      return const [];
    }
    if (speedKmh >= config.candidateVehicleSpeedKmh) {
      _idleCandidateSpeedSince ??= now;
      _idleCandidateAnchor ??= location;
      final sustained = now.difference(_idleCandidateSpeedSince!);
      final displacement = GeoUtils.haversineMeters(
        _idleCandidateAnchor!.latitude,
        _idleCandidateAnchor!.longitude,
        location.latitude,
        location.longitude,
      );
      if (sustained >= config.candidateEntrySpeedDuration &&
          displacement >= config.candidateEntryDisplacementMeters) {
        _enterPossibleTrip(now);
        return _go(
          TripRecordingState.possibleTrip,
          now,
          'speed ${speedKmh.round()} km/h sustained ${sustained.inSeconds}s, '
          'displacement ${displacement.round()}m',
        );
      }
    } else {
      if (_idleCandidateSpeedSince != null) {
        _diagnose('idle speed-candidate reset: speed dropped');
      }
      _idleCandidateSpeedSince = null;
      _idleCandidateAnchor = null;
    }
    return const [];
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
    if (displacement >= config.minimumDisplacementMeters) {
      return _startRecording(now, 'displacement ${displacement.round()}m');
    }

    // Condition 2: sustained candidate speed.
    if (speedKmh != null && speedKmh >= config.candidateVehicleSpeedKmh) {
      _sustainedSpeedSince ??= now;
      if (now.difference(_sustainedSpeedSince!) >=
          config.minimumMovementDuration) {
        return _startRecording(
          now,
          'speed>=${config.candidateVehicleSpeedKmh} km/h sustained',
        );
      }
    } else if (speedKmh != null) {
      _sustainedSpeedSince = null;
    }

    // Condition 3: several consecutive strong/consistent moving points.
    if (previous != null) {
      final stepMeters = GeoUtils.haversineMeters(
        previous.latitude,
        previous.longitude,
        location.latitude,
        location.longitude,
      );
      final dt = now.difference(previous.recordedAt).inMilliseconds / 1000.0;
      final impliedKmh = dt > 0 ? GeoUtils.msToKmh(stepMeters / dt) : 0.0;
      final reportedOk =
          speedKmh != null && speedKmh >= config.strongVehicleSpeedKmh;
      final impliedOk = impliedKmh >= config.candidateVehicleSpeedKmh;
      if ((reportedOk || impliedOk) &&
          impliedKmh <= config.maxRealisticSpeedKmh) {
        _consistentMovingPoints++;
        if (_consistentMovingPoints >= config.minimumConsistentPoints) {
          return _startRecording(
            now,
            '$_consistentMovingPoints consistent moving points '
            '(~${impliedKmh.round()} km/h)',
          );
        }
      } else {
        if (_consistentMovingPoints > 0) {
          _diagnose('consistency streak reset at $_consistentMovingPoints');
        }
        _consistentMovingPoints = 0;
      }
    }
    return const [];
  }

  List<TripStateTransition> _startRecording(DateTime now, String reason) {
    _resetPossible();
    _clearStopState();
    _manuallyPaused = false;
    return _go(TripRecordingState.recording, now, reason);
  }

  void _clearStopState() {
    _stopAnchor = null;
    _stopCandidateSince = null;
    _stopStartedAt = null;
    _nonVehicleSince = null;
    _destinationCandidateSince = null;
    _restAnswerReceived = false;
  }

  List<TripStateTransition> _evaluateRecording(
    RecordedLocation location,
    DateTime now,
  ) {
    final speedKmh = location.speedKmh ?? 0;
    if (speedKmh <= config.stopSpeedThresholdKmh) {
      _stopAnchor ??= location;
      final radius = config.stopRadiusFor(location.horizontalAccuracy);
      final jitter = GeoUtils.haversineMeters(
        _stopAnchor!.latitude,
        _stopAnchor!.longitude,
        location.latitude,
        location.longitude,
      );
      if (jitter <= radius) {
        _stopCandidateSince ??= now;
        if (now.difference(_stopCandidateSince!) >= config.shortStopAfter) {
          _stopStartedAt = _stopCandidateSince;
          _nonVehicleSince = null;
          return _go(
            TripRecordingState.shortStop,
            now,
            'low speed & stable >=${config.shortStopAfter.inSeconds}s',
          );
        }
      } else {
        _stopAnchor = location;
        _stopCandidateSince = now;
      }
    } else {
      _stopAnchor = null;
      _stopCandidateSince = null;
    }
    return const [];
  }

  /// Shared logic for all stopped-flavored states: resume on movement,
  /// escalate by duration on tick.
  List<TripStateTransition> _evaluateStopped(
    RecordedLocation location,
    DateTime now,
  ) {
    if (_manuallyPaused) return const [];
    final speedKmh = location.speedKmh ?? 0;
    final radius = config.stopRadiusFor(location.horizontalAccuracy);
    final movedFromStop = _stopAnchor == null
        ? false
        : GeoUtils.haversineMeters(
                _stopAnchor!.latitude,
                _stopAnchor!.longitude,
                location.latitude,
                location.longitude,
              ) >
              radius * 2;
    if (speedKmh > config.candidateVehicleSpeedKmh || movedFromStop) {
      _clearStopState();
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
          return _go(
            TripRecordingState.idle,
            now,
            'candidate expired: nothing validated within '
            '${config.possibleTripTimeout.inMinutes} min',
          );
        }

      case TripRecordingState.shortStop:
        final stopFor = _stopDuration(now);
        if (stopFor != null && stopFor >= config.mediumStopAfter) {
          return _go(
            TripRecordingState.temporarilyStopped,
            now,
            'stationary >=${config.mediumStopAfter.inMinutes} min',
          );
        }

      case TripRecordingState.temporarilyStopped:
        if (_manuallyPaused) return const [];
        final stopFor = _stopDuration(now);
        // Old fast path: activity clearly says the user left the vehicle.
        if (_nonVehicleSince != null &&
            now.difference(_nonVehicleSince!) >= config.finishAfterStopped) {
          return _go(
            TripRecordingState.finishing,
            now,
            'non-vehicle activity & stable '
            '>=${config.finishAfterStopped.inMinutes} min',
          );
        }
        if (!_restAnswerReceived &&
            stopFor != null &&
            stopFor >= config.restStopQuestionAfter) {
          return _go(
            TripRecordingState.restStopCandidate,
            now,
            'stationary >=${config.restStopQuestionAfter.inMinutes} min: '
            'ask arrived/resting',
          );
        }

      case TripRecordingState.restStopCandidate:
        final stopFor = _stopDuration(now);
        if (stopFor != null && stopFor >= config.destinationCandidateAfter) {
          _destinationCandidateSince = now;
          return _go(
            TripRecordingState.destinationCandidate,
            now,
            'stationary >=${config.destinationCandidateAfter.inHours}h: '
            'trip likely finished',
          );
        }

      case TripRecordingState.destinationCandidate:
        if (_destinationCandidateSince != null &&
            now.difference(_destinationCandidateSince!) >=
                config.autoFinishGrace) {
          return _go(
            TripRecordingState.finishing,
            now,
            'auto-finish: no answer within '
            '${config.autoFinishGrace.inMinutes} min of destination candidate',
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

  Duration? _stopDuration(DateTime now) =>
      _stopStartedAt == null ? null : now.difference(_stopStartedAt!);

  // -------------------------------------------------------------------------
  // Question answers
  // -------------------------------------------------------------------------

  @override
  List<TripStateTransition> answerStopQuestion(
    StopQuestionAnswer answer,
    DateTime now,
  ) {
    if (_state != TripRecordingState.restStopCandidate &&
        _state != TripRecordingState.destinationCandidate) {
      return const [];
    }
    switch (answer) {
      case StopQuestionAnswer.arrived:
        return _go(TripRecordingState.finishing, now, 'user answered arrived');
      case StopQuestionAnswer.resting:
        _restAnswerReceived = true;
        return _go(
          TripRecordingState.temporarilyStopped,
          now,
          'user answered resting: keep trip active, do not re-ask here',
        );
      case StopQuestionAnswer.continueTrip:
        _restAnswerReceived = true;
        return _go(
          TripRecordingState.temporarilyStopped,
          now,
          'user answered continue: waiting for movement',
        );
    }
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
    if (_state == TripRecordingState.recording ||
        _state == TripRecordingState.shortStop) {
      _manuallyPaused = true;
      _stopAnchor = _lastValidLocation;
      _stopStartedAt ??= now;
      return _go(TripRecordingState.temporarilyStopped, now, 'manual pause');
    }
    return const [];
  }

  @override
  List<TripStateTransition> manualResume(DateTime now) {
    if (_state.isStoppedLike) {
      _manuallyPaused = false;
      _clearStopState();
      return _go(TripRecordingState.recording, now, 'manual resume');
    }
    return const [];
  }

  @override
  List<TripStateTransition> manualFinish(DateTime now) {
    if (_state == TripRecordingState.recording || _state.isStoppedLike) {
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
    _clearStopState();
    _manuallyPaused = false;
    _validPointStreak = 0;
    _idleCandidateSpeedSince = null;
    _idleCandidateAnchor = null;
  }

  @override
  void restore(TripRecordingState state, DateTime now) {
    _state = state;
    if (state.isStoppedLike) {
      _stopCandidateSince = now;
      _stopStartedAt = now;
    }
  }
}
