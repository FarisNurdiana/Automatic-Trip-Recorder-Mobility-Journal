import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../../core/activity/activity_models.dart';
import '../../../core/activity/activity_recognition_service.dart';
import '../../../core/config/sensor_config.dart';
import '../../../core/config/trip_detection_config.dart';
import '../../../core/constants/enums.dart';
import '../../../core/location/location_models.dart';
import '../../../core/location/location_tracking_service.dart';
import '../../../core/sensors/sensor_collection_service.dart';
import '../../../core/sensors/sensor_models.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/geo_utils.dart';
import '../../trips/data/trip_repository.dart';
import '../domain/trip_state_machine.dart';

/// Immutable UI state for the recording feature.
class RecordingUiState {
  const RecordingUiState({
    this.machineState = TripRecordingState.idle,
    this.activeTrip,
    this.liveDistanceMeters = 0,
    this.liveElapsed = Duration.zero,
    this.currentSpeedKmh,
    this.lastActivity,
    this.finishedTripId,
    this.recoveredTrip = false,
    this.errorKey,
  });

  final TripRecordingState machineState;
  final Trip? activeTrip;
  final double liveDistanceMeters;
  final Duration liveElapsed;
  final double? currentSpeedKmh;
  final DetectedActivity? lastActivity;

  /// Set right after a trip finishes, so the UI can navigate to the vehicle
  /// confirmation page. Cleared with [TripRecordingController.consumeFinishedTrip].
  final String? finishedTripId;

  /// True when an interrupted trip was recovered on startup.
  final bool recoveredTrip;

  /// Machine-readable error identifier mapped to a localized message in UI.
  final String? errorKey;

  RecordingUiState copyWith({
    TripRecordingState? machineState,
    Trip? activeTrip,
    bool clearActiveTrip = false,
    double? liveDistanceMeters,
    Duration? liveElapsed,
    double? currentSpeedKmh,
    DetectedActivity? lastActivity,
    String? finishedTripId,
    bool clearFinishedTrip = false,
    bool? recoveredTrip,
    String? errorKey,
    bool clearError = false,
  }) {
    return RecordingUiState(
      machineState: machineState ?? this.machineState,
      activeTrip: clearActiveTrip ? null : (activeTrip ?? this.activeTrip),
      liveDistanceMeters: liveDistanceMeters ?? this.liveDistanceMeters,
      liveElapsed: liveElapsed ?? this.liveElapsed,
      currentSpeedKmh: currentSpeedKmh ?? this.currentSpeedKmh,
      lastActivity: lastActivity ?? this.lastActivity,
      finishedTripId: clearFinishedTrip
          ? null
          : (finishedTripId ?? this.finishedTripId),
      recoveredTrip: recoveredTrip ?? this.recoveredTrip,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
    );
  }
}

/// Orchestrates the whole recording pipeline:
/// activity events + GPS fixes -> [TripStateMachine] -> repository writes,
/// adaptive sampling, notification updates and sensor collection.
class TripRecordingController extends StateNotifier<RecordingUiState> {
  TripRecordingController({
    required this.stateMachine,
    required this.locationService,
    required this.activityService,
    required this.sensorService,
    required this.repository,
    required this.userIdProvider,
    this.config = defaultTripDetectionConfig,
    this.metadataProvider,
    this.mountPositionProvider,
    this.autoDetectionEnabledProvider,
    this.sensorConfigProvider,
    DateTime Function()? clock,
    this.tickInterval = const Duration(seconds: 5),
  }) : _clock = clock ?? (() => DateTime.now().toUtc()),
       super(const RecordingUiState());

  final TripStateMachine stateMachine;
  final LocationTrackingService locationService;
  final ActivityRecognitionService activityService;
  final SensorCollectionService sensorService;
  final TripRepository repository;

  /// Returns the current user id ('' when signed out).
  final String Function() userIdProvider;
  final TripDetectionConfig config;
  final TripDeviceMetadata Function()? metadataProvider;
  final PhoneMountPosition Function()? mountPositionProvider;
  final bool Function()? autoDetectionEnabledProvider;
  final SensorSamplingConfig Function()? sensorConfigProvider;

  final DateTime Function() _clock;
  final Duration tickInterval;
  final _log = Logger('TripRecordingController');

  StreamSubscription<DetectedActivity>? _activitySub;
  StreamSubscription<RecordedLocation>? _locationSub;
  StreamSubscription<TrackingNotificationAction>? _actionSub;
  StreamSubscription? _sensorSub;
  Timer? _ticker;

  RecordedLocation? _lastStoredPoint;
  LocationSamplingProfile? _currentProfile;
  final _pendingSensorSamples = <CollectedSensorSample>[];

  bool get _autoDetectionEnabled =>
      autoDetectionEnabledProvider?.call() ?? true;

  /// Call once after construction: recovers interrupted trips and starts
  /// listening to activity recognition.
  Future<void> init() async {
    await _recoverIfNeeded();
    _actionSub = locationService.notificationActions.listen(_onAction);
    if (_autoDetectionEnabled && await activityService.isAvailable()) {
      try {
        await activityService.start();
        _activitySub = activityService.activityStream.listen(_onActivity);
      } catch (e) {
        _log.warning('activity recognition unavailable', e);
        state = state.copyWith(errorKey: 'activityUnavailable');
      }
    }
    _ticker = Timer.periodic(tickInterval, (_) => _onTick());
  }

  Future<void> _recoverIfNeeded() async {
    final trip = await repository.findRecoverableTrip();
    if (trip == null) return;
    final recoveredState = TripRecordingState.fromName(trip.status);
    _log.info('recovering trip ${trip.id} in state ${trip.status}');
    stateMachine.restore(recoveredState, _clock());
    state = state.copyWith(
      machineState: recoveredState,
      activeTrip: trip,
      recoveredTrip: true,
    );
    final points = await repository.pointsForTrip(trip.id);
    if (points.isNotEmpty) {
      _lastStoredPoint = points.last;
      var distance = 0.0;
      for (var i = 1; i < points.length; i++) {
        distance += GeoUtils.haversineMeters(
          points[i - 1].latitude,
          points[i - 1].longitude,
          points[i].latitude,
          points[i].longitude,
        );
      }
      state = state.copyWith(
        liveDistanceMeters: distance,
        liveElapsed: _clock().difference(trip.startedAt),
      );
    }
    await _startTracking(LocationSamplingProfile.moving);
    await _startSensorsIfEnabled(trip.id);
  }

  // ---------------------------------------------------------------------
  // Event plumbing
  // ---------------------------------------------------------------------

  Future<void> _onActivity(DetectedActivity activity) async {
    state = state.copyWith(lastActivity: activity);
    sensorService.updateActivityState(activity.type.name);
    try {
      await repository.recordActivityEvent(
        activity,
        tripId: state.activeTrip?.id,
      );
    } catch (e) {
      _log.warning('failed to store activity event', e);
    }
    if (!_autoDetectionEnabled) return;
    await _applyTransitions(stateMachine.onActivity(activity));
  }

  Future<void> _onLocation(RecordedLocation location) async {
    state = state.copyWith(currentSpeedKmh: location.speedKmh);
    sensorService.updateSpeed(location.speed);

    final transitions = stateMachine.onLocation(location);

    // Persist points while a trip is active.
    final trip = state.activeTrip;
    if (trip != null &&
        (state.machineState == TripRecordingState.recording ||
            state.machineState == TripRecordingState.temporarilyStopped)) {
      final accuracyOk =
          location.horizontalAccuracy == null ||
          location.horizontalAccuracy! <= config.maxHorizontalAccuracyMeters;
      if (accuracyOk) {
        try {
          await repository.appendPoint(trip.id, location);
        } catch (e) {
          _log.severe('failed to store point', e);
          state = state.copyWith(errorKey: 'database');
        }
        if (_lastStoredPoint != null) {
          final segment = GeoUtils.haversineMeters(
            _lastStoredPoint!.latitude,
            _lastStoredPoint!.longitude,
            location.latitude,
            location.longitude,
          );
          // Ignore GPS jitter segments implying unrealistic speed.
          final dt =
              location.recordedAt
                  .difference(_lastStoredPoint!.recordedAt)
                  .inMilliseconds /
              1000.0;
          final impliedKmh = dt > 0
              ? GeoUtils.msToKmh(segment / dt)
              : double.infinity;
          if (impliedKmh <= config.maxRealisticSpeedKmh) {
            state = state.copyWith(
              liveDistanceMeters: state.liveDistanceMeters + segment,
            );
          }
        }
        _lastStoredPoint = location;
      }
      await _adaptSamplingProfile(location);
      await _refreshNotification();
    }

    await _applyTransitions(transitions);
  }

  Future<void> _onTick() async {
    final now = _clock();
    if (state.activeTrip != null) {
      state = state.copyWith(
        liveElapsed: now.difference(state.activeTrip!.startedAt),
      );
    }
    await _applyTransitions(stateMachine.onTick(now));
  }

  Future<void> _onAction(TrackingNotificationAction action) async {
    switch (action) {
      case TrackingNotificationAction.pause:
        await pause();
      case TrackingNotificationAction.resume:
        await resume();
      case TrackingNotificationAction.stop:
        await finish();
    }
  }

  // ---------------------------------------------------------------------
  // Manual controls
  // ---------------------------------------------------------------------

  Future<void> startManual() async =>
      _applyTransitions(stateMachine.manualStart(_clock()));

  Future<void> pause() async =>
      _applyTransitions(stateMachine.manualPause(_clock()));

  Future<void> resume() async =>
      _applyTransitions(stateMachine.manualResume(_clock()));

  Future<void> finish() async =>
      _applyTransitions(stateMachine.manualFinish(_clock()));

  Future<void> cancel() async =>
      _applyTransitions(stateMachine.manualCancel(_clock()));

  /// UI acknowledges the finished-trip navigation event.
  void consumeFinishedTrip() =>
      state = state.copyWith(clearFinishedTrip: true, recoveredTrip: false);

  void clearError() => state = state.copyWith(clearError: true);

  // ---------------------------------------------------------------------
  // Transition side effects
  // ---------------------------------------------------------------------

  Future<void> _applyTransitions(List<TripStateTransition> transitions) async {
    for (final t in transitions) {
      _log.info('transition: $t');
      state = state.copyWith(machineState: t.to);
      switch (t.to) {
        case TripRecordingState.possibleTrip:
          await _startTracking(LocationSamplingProfile.moving);
        case TripRecordingState.idle:
          if (state.activeTrip == null) await _stopTracking();
        case TripRecordingState.recording:
          if (state.activeTrip == null) {
            await _createTrip(t.at);
          } else {
            await repository.setTripStatus(
              state.activeTrip!.id,
              TripRecordingState.recording,
            );
          }
          await _startTracking(LocationSamplingProfile.moving);
          await _refreshNotification();
        case TripRecordingState.temporarilyStopped:
          if (state.activeTrip != null) {
            await repository.setTripStatus(
              state.activeTrip!.id,
              TripRecordingState.temporarilyStopped,
            );
          }
          await _setProfile(LocationSamplingProfile.stopped);
          await _refreshNotification();
        case TripRecordingState.finishing:
          await _finishTrip(t.at);
        case TripRecordingState.cancelled:
          await _cancelTrip();
        case TripRecordingState.finished:
          break;
      }
    }
  }

  Future<void> _createTrip(DateTime at) async {
    final userId = userIdProvider();
    if (userId.isEmpty) {
      state = state.copyWith(errorKey: 'notSignedIn');
      stateMachine.reset();
      state = state.copyWith(machineState: TripRecordingState.idle);
      return;
    }
    final lastActivity = state.lastActivity;
    final trip = await repository.createTrip(
      userId: userId,
      startedAt: at,
      detectedVehicleType: lastActivity?.type == DetectedActivityType.vehicle
          ? VehicleType.unknown
          : VehicleType.unknown,
      vehicleConfidence: lastActivity?.confidence,
      metadata: metadataProvider?.call(),
      mountPosition:
          mountPositionProvider?.call() ?? PhoneMountPosition.unknown,
    );
    _lastStoredPoint = null;
    state = state.copyWith(
      activeTrip: trip,
      liveDistanceMeters: 0,
      liveElapsed: Duration.zero,
    );
    await _startSensorsIfEnabled(trip.id);
  }

  Future<void> _finishTrip(DateTime at) async {
    final trip = state.activeTrip;
    if (trip == null) {
      stateMachine.reset();
      state = state.copyWith(machineState: TripRecordingState.idle);
      return;
    }
    await repository.setTripStatus(trip.id, TripRecordingState.finishing);
    await _stopSensors(trip.id);
    TripSummarySafeResult summaryResult;
    try {
      final summary = await repository.finishTrip(trip.id, at);
      summaryResult = TripSummarySafeResult(summary != null);
    } catch (e) {
      _log.severe('finishTrip failed', e);
      summaryResult = TripSummarySafeResult(false);
    }
    await _stopTracking();
    await _applyTransitions(stateMachine.completeFinish(_clock()));
    stateMachine.reset();
    state = state.copyWith(
      machineState: TripRecordingState.idle,
      clearActiveTrip: true,
      finishedTripId: summaryResult.valid ? trip.id : null,
      errorKey: summaryResult.valid ? null : 'tripTooShort',
      liveDistanceMeters: 0,
      liveElapsed: Duration.zero,
    );
    _lastStoredPoint = null;
  }

  Future<void> _cancelTrip() async {
    final trip = state.activeTrip;
    if (trip != null) {
      await _stopSensors(trip.id);
      try {
        await repository.cancelAndDeleteTrip(trip.id);
      } catch (e) {
        _log.warning('cancelAndDeleteTrip failed', e);
      }
    }
    await _stopTracking();
    stateMachine.reset();
    _lastStoredPoint = null;
    state = state.copyWith(
      machineState: TripRecordingState.idle,
      clearActiveTrip: true,
      liveDistanceMeters: 0,
      liveElapsed: Duration.zero,
    );
  }

  // ---------------------------------------------------------------------
  // Tracking helpers
  // ---------------------------------------------------------------------

  Future<void> _startTracking(LocationSamplingProfile profile) async {
    if (_locationSub == null) {
      if (!await locationService.isLocationServiceEnabled()) {
        state = state.copyWith(errorKey: 'gpsDisabled');
      }
      try {
        await locationService.start(profile: profile);
        _currentProfile = profile;
        _locationSub = locationService.locationStream.listen(
          _onLocation,
          onError: (Object e) {
            _log.warning('location stream error', e);
            state = state.copyWith(errorKey: 'gpsDisabled');
          },
        );
      } catch (e) {
        _log.severe('failed to start tracking', e);
        state = state.copyWith(errorKey: 'permissionDenied');
      }
    } else {
      await _setProfile(profile);
    }
  }

  Future<void> _setProfile(LocationSamplingProfile profile) async {
    if (_currentProfile == profile) return;
    _currentProfile = profile;
    try {
      await locationService.setProfile(profile);
    } catch (e) {
      _log.warning('setProfile failed', e);
    }
  }

  Future<void> _adaptSamplingProfile(RecordedLocation location) async {
    final speedKmh = location.speedKmh ?? 0;
    final LocationSamplingProfile profile;
    if (state.machineState == TripRecordingState.temporarilyStopped ||
        speedKmh <= config.stopSpeedThresholdKmh) {
      profile = LocationSamplingProfile.stopped;
    } else if (speedKmh < config.slowSpeedThresholdKmh) {
      profile = LocationSamplingProfile.slow;
    } else {
      profile = LocationSamplingProfile.moving;
    }
    await _setProfile(profile);
  }

  Future<void> _stopTracking() async {
    await _locationSub?.cancel();
    _locationSub = null;
    _currentProfile = null;
    try {
      await locationService.stop();
    } catch (e) {
      _log.warning('stopTracking failed', e);
    }
  }

  Future<void> _refreshNotification() async {
    final paused = state.machineState == TripRecordingState.temporarilyStopped;
    await locationService.updateNotification(
      title: paused ? 'Berhenti sementara' : 'Perjalanan sedang direkam',
      body:
          '${Formatters.distanceKm(state.liveDistanceMeters)} • ${Formatters.duration(state.liveElapsed)}',
      paused: paused,
    );
  }

  Future<void> _startSensorsIfEnabled(String tripId) async {
    final sensorConfig = sensorConfigProvider?.call();
    if (sensorConfig == null || !sensorConfig.enabled) return;
    if (!await sensorService.isAvailable()) {
      state = state.copyWith(errorKey: 'sensorUnavailable');
      return;
    }
    await sensorService.start(sensorConfig);
    _sensorSub = sensorService.sampleStream.listen((sample) {
      _pendingSensorSamples.add(sample);
      if (_pendingSensorSamples.length >= sensorConfig.flushBatchSize) {
        _flushSensorSamples(tripId);
      }
    });
  }

  void _flushSensorSamples(String tripId) {
    if (_pendingSensorSamples.isEmpty) return;
    final batch = List.of(_pendingSensorSamples);
    _pendingSensorSamples.clear();
    unawaited(
      repository
          .addSensorSamples(tripId, batch)
          .catchError((Object e) => _log.warning('sensor flush failed', e)),
    );
  }

  Future<void> _stopSensors(String tripId) async {
    await _sensorSub?.cancel();
    _sensorSub = null;
    await sensorService.stop();
    _flushSensorSamples(tripId);
  }

  @override
  Future<void> dispose() async {
    _ticker?.cancel();
    await _activitySub?.cancel();
    await _locationSub?.cancel();
    await _actionSub?.cancel();
    await _sensorSub?.cancel();
    super.dispose();
  }
}

/// Small wrapper so summary success/failure survives try/catch cleanly.
class TripSummarySafeResult {
  const TripSummarySafeResult(this.valid);

  final bool valid;
}
