import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/activity/simulated_activity_service.dart';
import 'package:triplog/core/config/sensor_config.dart';
import 'package:triplog/core/constants/enums.dart';
import 'package:triplog/core/location/location_models.dart';
import 'package:triplog/core/location/simulated_location_service.dart';
import 'package:triplog/core/platform/speed_alarm.dart';
import 'package:triplog/core/sensors/sensor_collection_service.dart';
import 'package:triplog/core/sensors/sensor_models.dart';
import 'package:triplog/core/storage/app_database.dart';
import 'package:triplog/features/recording/application/trip_recording_controller.dart';
import 'package:triplog/features/recording/domain/trip_state_machine.dart';
import 'package:triplog/features/trips/data/local_trip_data_source.dart';
import 'package:triplog/features/trips/data/trip_repository.dart';
import 'package:triplog/features/trips/domain/trip_summary_calculator.dart';

import '../../helpers.dart';

/// No-op sensor service for controller tests.
class FakeSensorService implements SensorCollectionService {
  bool started = false;

  @override
  Stream<CollectedSensorSample> get sampleStream => const Stream.empty();

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> start(SensorSamplingConfig config) async => started = true;

  @override
  Future<void> stop() async => started = false;

  @override
  void updateActivityState(String? activityState) {}

  @override
  void updateSpeed(double? speedMs) {}
}

void main() {
  late AppDatabase db;
  late DefaultTripRepository repo;
  late SimulatedLocationTrackingService location;
  late SimulatedActivityRecognitionService activityService;
  late TripRecordingController controller;
  late RecordingSpeedAlarm alarm;
  double? speedLimit;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DefaultTripRepository(
      local: DriftTripDataSource(db),
      summaryCalculator: DefaultTripSummaryCalculator(),
    );
    location = SimulatedLocationTrackingService();
    activityService = SimulatedActivityRecognitionService();
    alarm = RecordingSpeedAlarm();
    speedLimit = null;
    controller = TripRecordingController(
      stateMachine: DefaultTripStateMachine(),
      locationService: location,
      activityService: activityService,
      sensorService: FakeSensorService(),
      repository: repo,
      userIdProvider: () => 'user-1',
      speedLimitKmhProvider: () => speedLimit,
      speedAlarm: alarm,
      tickInterval: const Duration(hours: 1), // ticks driven manually in tests
    );
  });

  tearDown(() async {
    controller.dispose();
    location.dispose();
    activityService.dispose();
    await db.close();
  });

  Future<void> pump() => pumpEventQueue(times: 40);

  group('manual recording flow', () {
    test('startManual creates a trip and starts tracking', () async {
      await controller.init();
      await controller.startManual();
      await pump();
      expect(controller.state.machineState, TripRecordingState.recording);
      expect(controller.state.activeTrip, isNotNull);
      expect(location.started, isTrue);
    });

    test('points from the tracker are persisted with live stats', () async {
      await controller.init();
      await controller.startManual();
      await pump();
      final track = straightTrack(
        movingSeconds: 120,
        stoppedSeconds: 0,
        intervalSeconds: 10,
      ).take(12).toList();
      for (final p in track) {
        location.emit(p);
      }
      await pump();
      final points = await repo.pointsForTrip(controller.state.activeTrip!.id);
      expect(points.length, 12);
      expect(controller.state.liveDistanceMeters, greaterThan(1000));
    });

    test('finish computes the summary and exposes finishedTripId', () async {
      await controller.init();
      await controller.startManual();
      await pump();
      for (final p in straightTrack()) {
        location.emit(p);
      }
      await pump();
      final tripId = controller.state.activeTrip!.id;
      await controller.finish();
      await pump();
      expect(controller.state.machineState, TripRecordingState.idle);
      expect(controller.state.finishedTripId, tripId);
      final trip = (await repo.getTrip(tripId))!;
      expect(trip.status, TripRecordingState.finished.name);
      expect(location.started, isFalse, reason: 'GPS must stop after finish');
    });

    test('manual finish without usable GPS surfaces tripNoGps error', () async {
      await controller.init();
      await controller.startManual();
      await pump();
      location.emit(loc(secondsFromStart: 0, speedKmh: 10));
      await pump();
      await controller.finish();
      await pump();
      expect(controller.state.finishedTripId, isNull);
      expect(controller.state.errorKey, 'tripNoGps');
    });

    test('manual finish keeps a short trip (lenient rules)', () async {
      await controller.init();
      await controller.startManual();
      await pump();
      // Two nearby fixes only — far below the strict 300 m / 60 s minimums.
      location.emit(loc(secondsFromStart: 0, speedKmh: 5));
      location.emit(loc(secondsFromStart: 8, lat: -6.20005, speedKmh: 5));
      await pump();
      final tripId = controller.state.activeTrip!.id;
      await controller.finish();
      await pump();
      expect(controller.state.errorKey, isNull);
      expect(controller.state.finishedTripId, tripId);
      final trip = (await repo.getTrip(tripId))!;
      expect(trip.status, TripRecordingState.finished.name);
    });

    test('cancel deletes the trip completely', () async {
      await controller.init();
      await controller.startManual();
      await pump();
      final tripId = controller.state.activeTrip!.id;
      await controller.cancel();
      await pump();
      expect(controller.state.machineState, TripRecordingState.idle);
      expect(await repo.getTrip(tripId), isNull);
      expect(location.started, isFalse);
    });

    test('notification pause/stop actions drive the machine', () async {
      await controller.init();
      await controller.startManual();
      await pump();
      location.emitAction(TrackingNotificationAction.pause);
      await pump();
      expect(
        controller.state.machineState,
        TripRecordingState.temporarilyStopped,
      );
      location.emitAction(TrackingNotificationAction.resume);
      await pump();
      expect(controller.state.machineState, TripRecordingState.recording);
    });
  });

  group('automatic detection', () {
    test('vehicle activity leads to possibleTrip then recording', () async {
      await controller.init();
      activityService.emit(activity(secondsFromStart: 0));
      await pump();
      expect(controller.state.machineState, TripRecordingState.possibleTrip);
      expect(
        location.started,
        isTrue,
        reason: 'GPS validation starts during possibleTrip',
      );

      // Sustained movement validates the candidate.
      location.emit(loc(secondsFromStart: 10, speedKmh: 25));
      location.emit(loc(secondsFromStart: 20, speedKmh: 26));
      location.emit(loc(secondsFromStart: 40, speedKmh: 27));
      await pump();
      expect(controller.state.machineState, TripRecordingState.recording);
      expect(controller.state.activeTrip, isNotNull);
    });

    test('activity events are stored for the dataset', () async {
      await controller.init();
      activityService.emit(activity(secondsFromStart: 0));
      await pump();
      final events = await DriftTripDataSource(
        db,
      ).activityEventsForTrip('none');
      // Stored with tripId null (no trip yet) — verify via raw query instead.
      expect(events, isEmpty);
      final all = await db.select(db.activityEvents).get();
      expect(all.length, 1);
      expect(all.single.activityType, 'vehicle');
    });
  });

  group('speed-limit alarm', () {
    test('fires once above the limit, with a cooldown', () async {
      speedLimit = 80;
      await controller.init();
      await controller.startManual();
      await pump();
      location.emit(loc(secondsFromStart: 0, speedKmh: 70));
      await pump();
      expect(alarm.startCount, 0, reason: 'below the limit');
      location.emit(loc(secondsFromStart: 10, lat: -6.201, speedKmh: 95));
      await pump();
      expect(alarm.startCount, 1);
      expect(alarm.lastDuration, const Duration(seconds: 10));
      // Still speeding moments later: cooldown suppresses a re-trigger.
      location.emit(loc(secondsFromStart: 20, lat: -6.202, speedKmh: 96));
      await pump();
      expect(alarm.startCount, 1);
    });

    test('uses implied speed when the fix reports no speed', () async {
      speedLimit = 60;
      await controller.init();
      await controller.startManual();
      await pump();
      // ~111 m in 4 s => ~100 km/h implied, but no reported speed at all
      // (typical of cellular fixes).
      location.emit(loc(secondsFromStart: 0, lat: -6.2000));
      location.emit(loc(secondsFromStart: 4, lat: -6.2010));
      await pump();
      expect(alarm.startCount, 1);
    });

    test('never fires without an active trip or configured limit', () async {
      await controller.init();
      await controller.startManual();
      await pump();
      // No limit configured.
      location.emit(loc(secondsFromStart: 0, speedKmh: 120));
      await pump();
      expect(alarm.startCount, 0);
      await controller.cancel();
      await pump();
      // Limit set but no active trip.
      speedLimit = 80;
      location.emit(loc(secondsFromStart: 10, speedKmh: 120));
      await pump();
      expect(alarm.startCount, 0);
    });
  });

  group('background auto-start adoption', () {
    test('init adopts a native background recording as a trip', () async {
      location.backgroundStartedAt = t0;
      await controller.init();
      await pump();
      expect(controller.state.machineState, TripRecordingState.recording);
      expect(controller.state.activeTrip, isNotNull);
      // Drift round-trips DateTimes without the isUtc flag; compare epoch.
      expect(
        controller.state.activeTrip!.startedAt.millisecondsSinceEpoch,
        t0.millisecondsSinceEpoch,
      );
      expect(controller.state.recoveredTrip, isTrue);
      expect(location.started, isTrue);
    });

    test('init imports persisted points into the adopted live trip', () async {
      location.backgroundStartedAt = t0;
      location.backgroundTrackLines = [
        '{"type":"start","startedAtMillis":${t0.millisecondsSinceEpoch}}',
        for (var i = 0; i < 6; i++)
          '{"timestampMs":${t0.add(Duration(seconds: 10 * i)).millisecondsSinceEpoch},'
              '"latitude":${-6.2 + 0.001 * i},"longitude":106.8,'
              '"horizontalAccuracy":8.0,"speed":11.0,"source":"fused"}',
      ];
      await controller.init();
      await pump();
      expect(controller.state.machineState, TripRecordingState.recording);
      final points = await repo.pointsForTrip(controller.state.activeTrip!.id);
      expect(points, hasLength(6));
      expect(controller.state.liveDistanceMeters, greaterThan(400));
    });

    test(
      'init turns completed background segments into finished trips',
      () async {
        // Service no longer running: the whole file is history.
        location.backgroundStartedAt = null;
        location.backgroundTrackLines = [
          '{"type":"start","startedAtMillis":${t0.millisecondsSinceEpoch}}',
          for (var i = 0; i < 12; i++)
            '{"timestampMs":${t0.add(Duration(seconds: 10 * i)).millisecondsSinceEpoch},'
                '"latitude":${-6.2 + 0.001 * i},"longitude":106.8,'
                '"horizontalAccuracy":8.0,"speed":11.0,"source":"fused"}',
        ];
        await controller.init();
        await pump();
        expect(controller.state.machineState, TripRecordingState.idle);
        expect(controller.state.activeTrip, isNull);
        final trips = await repo.watchTrips('user-1').first;
        expect(trips, hasLength(1));
        expect(trips.single.status, TripRecordingState.finished.name);
        expect(
          trips.single.startedAt.millisecondsSinceEpoch,
          t0.millisecondsSinceEpoch,
        );
      },
    );

    test('init without background tracking stays idle', () async {
      await controller.init();
      await pump();
      expect(controller.state.machineState, TripRecordingState.idle);
      expect(controller.state.activeTrip, isNull);
    });

    test('signed-out adoption stops the orphan service instead', () async {
      final other = TripRecordingController(
        stateMachine: DefaultTripStateMachine(),
        locationService: location,
        activityService: activityService,
        sensorService: FakeSensorService(),
        repository: repo,
        userIdProvider: () => '',
        tickInterval: const Duration(hours: 1),
      );
      location.backgroundStartedAt = t0;
      location.started = true;
      await other.init();
      await pump();
      expect(other.state.activeTrip, isNull);
      expect(location.started, isFalse);
      other.dispose();
    });
  });

  group('trip recovery after app restart', () {
    test('init restores an interrupted trip and resumes tracking', () async {
      final trip = await repo.createTrip(userId: 'user-1', startedAt: t0);
      for (final p in straightTrack(
        movingSeconds: 60,
        stoppedSeconds: 0,
        intervalSeconds: 10,
      )) {
        await repo.appendPoint(trip.id, p);
      }

      await controller.init();
      await pump();
      expect(controller.state.recoveredTrip, isTrue);
      expect(controller.state.activeTrip?.id, trip.id);
      expect(controller.state.machineState, TripRecordingState.recording);
      expect(controller.state.liveDistanceMeters, greaterThan(0));
      expect(location.started, isTrue);
    });
  });
}
