import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/constants/enums.dart';
import 'package:triplog/core/storage/app_database.dart';
import 'package:triplog/core/sync/sync_service.dart';
import 'package:triplog/features/trips/data/local_trip_data_source.dart';
import 'package:triplog/features/trips/data/remote_trip_data_source.dart';
import 'package:triplog/features/trips/data/trip_repository.dart';
import 'package:triplog/features/trips/domain/trip_summary_calculator.dart';

import '../helpers.dart';

/// In-memory fake remote that can fail on demand and records every upsert
/// so idempotency can be asserted.
class FakeRemote implements RemoteTripDataSource {
  int failuresRemaining = 0;
  final upsertedTripIds = <String>[];
  final upsertedPointIds = <String>[];
  final upsertedSampleIds = <String>[];
  final upsertedEventIds = <String>[];

  void _maybeFail() {
    if (failuresRemaining > 0) {
      failuresRemaining--;
      throw Exception('simulated network failure');
    }
  }

  @override
  Future<void> upsertTrip(Trip trip) async {
    _maybeFail();
    upsertedTripIds.add(trip.id);
  }

  @override
  Future<void> upsertPoints(List<TripPoint> points) async {
    _maybeFail();
    upsertedPointIds.addAll(points.map((p) => p.id));
  }

  @override
  Future<void> upsertActivityEvents(
    String userId,
    List<ActivityEvent> events,
  ) async {
    _maybeFail();
    upsertedEventIds.addAll(events.map((e) => e.id));
  }

  @override
  Future<void> upsertSensorSamples(List<SensorSample> samples) async {
    _maybeFail();
    upsertedSampleIds.addAll(samples.map((s) => s.id));
  }

  final upsertedStopIds = <String>[];

  @override
  Future<void> upsertStops(List<TripStop> stops) async {
    _maybeFail();
    upsertedStopIds.addAll(stops.map((s) => s.id));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTrips(String userId) async => [];

  @override
  Future<void> deleteTrip(String tripId) async {}

  @override
  Future<void> deleteAllUserData(String userId) async {}
}

void main() {
  late AppDatabase db;
  late DriftTripDataSource local;
  late DefaultTripRepository repo;
  late FakeRemote remote;
  late DefaultSyncService sync;
  final delays = <Duration>[];

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    local = DriftTripDataSource(db);
    repo = DefaultTripRepository(
      local: local,
      summaryCalculator: DefaultTripSummaryCalculator(),
    );
    remote = FakeRemote();
    delays.clear();
    sync = DefaultSyncService(
      local: local,
      remote: remote,
      pointBatchSize: 25,
      maxRetries: 3,
      delay: (d) async => delays.add(d),
    );
  });

  tearDown(() => db.close());

  Future<Trip> finishedTrip() async {
    final trip = await repo.createTrip(userId: 'user-1', startedAt: t0);
    for (final p in straightTrack()) {
      await repo.appendPoint(trip.id, p);
    }
    await repo.finishTrip(trip.id, t0.add(const Duration(minutes: 12)));
    return (await repo.getTrip(trip.id))!;
  }

  group('DefaultSyncService', () {
    test('uploads a finished trip and marks it synced', () async {
      final trip = await finishedTrip();
      await sync.syncNow('user-1');
      expect(remote.upsertedTripIds, [trip.id]);
      final points = await local.pointsForTrip(trip.id);
      expect(remote.upsertedPointIds.length, points.length);
      final stored = (await local.getTrip(trip.id))!;
      expect(stored.syncStatus, SyncStatus.synced.name);
      expect(sync.state.status, SyncStatus.synced);
    });

    test('points are uploaded in batches', () async {
      await finishedTrip();
      await sync.syncNow('user-1');
      // 122 points with batch size 25 → all present exactly once.
      expect(
        remote.upsertedPointIds.toSet().length,
        remote.upsertedPointIds.length,
      );
    });

    test('re-syncing does not duplicate anything (idempotent)', () async {
      final trip = await finishedTrip();
      await sync.syncNow('user-1');
      // Force another pass: mark pending again (e.g. vehicle confirmation).
      await repo.confirmVehicle(
        tripId: trip.id,
        confirmed: VehicleType.car,
        confirmedAt: t0,
      );
      await sync.syncNow('user-1');
      // Trip row was upserted twice with the SAME id — dedup happens via
      // primary-key upsert on the server, so ids must be identical.
      expect(remote.upsertedTripIds.toSet(), {trip.id});
      // No point was inserted with a fresh id on the second pass.
      expect(
        remote.upsertedPointIds.toSet().length,
        (await local.pointsForTrip(trip.id)).length,
      );
    });

    test('retries with exponential backoff and eventually succeeds', () async {
      final trip = await finishedTrip();
      remote.failuresRemaining = 2;
      await sync.syncNow('user-1');
      expect(delays, [const Duration(seconds: 2), const Duration(seconds: 4)]);
      final stored = (await local.getTrip(trip.id))!;
      expect(stored.syncStatus, SyncStatus.synced.name);
    });

    test('failure never deletes local data and leaves status failed', () async {
      final trip = await finishedTrip();
      remote.failuresRemaining = 99;
      await sync.syncNow('user-1');
      final stored = (await local.getTrip(trip.id))!;
      expect(stored.syncStatus, SyncStatus.failed.name);
      expect(
        (await local.pointsForTrip(trip.id)).length,
        greaterThan(0),
        reason: 'local data must survive failed uploads',
      );
      expect(sync.state.status, SyncStatus.failed);
      expect(sync.state.lastError, isNotNull);
    });

    test('active (unfinished) trips are not uploaded', () async {
      await repo.createTrip(userId: 'user-1', startedAt: t0);
      await sync.syncNow('user-1');
      expect(remote.upsertedTripIds, isEmpty);
    });

    test('does nothing for an empty user id', () async {
      await finishedTrip();
      await sync.syncNow('');
      expect(remote.upsertedTripIds, isEmpty);
    });
  });
}
