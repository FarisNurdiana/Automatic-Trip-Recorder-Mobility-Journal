import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/constants/enums.dart';
import 'package:triplog/core/storage/app_database.dart';
import 'package:triplog/features/trips/data/local_trip_data_source.dart';
import 'package:triplog/features/trips/data/trip_repository.dart';
import 'package:triplog/features/trips/domain/trip_summary_calculator.dart';

import '../../helpers.dart';

void main() {
  late AppDatabase db;
  late DefaultTripRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DefaultTripRepository(
      local: DriftTripDataSource(db),
      summaryCalculator: DefaultTripSummaryCalculator(),
    );
  });

  tearDown(() => db.close());

  Future<Trip> startTrip() => repo.createTrip(userId: 'user-1', startedAt: t0);

  group('trip lifecycle', () {
    test('createTrip stores a recording trip with pending sync', () async {
      final trip = await startTrip();
      expect(trip.status, TripRecordingState.recording.name);
      expect(trip.syncStatus, 'pending');
      expect(trip.userId, 'user-1');
    });

    test('appendPoint keeps sequence order', () async {
      final trip = await startTrip();
      for (final p in straightTrack()) {
        await repo.appendPoint(trip.id, p);
      }
      final points = await repo.pointsForTrip(trip.id);
      expect(points.length, straightTrack().length);
      for (var i = 1; i < points.length; i++) {
        expect(points[i].recordedAt.isAfter(points[i - 1].recordedAt), isTrue);
      }
    });

    test('finishTrip computes and stores the summary', () async {
      final trip = await startTrip();
      for (final p in straightTrack()) {
        await repo.appendPoint(trip.id, p);
      }
      final summary = await repo.finishTrip(
        trip.id,
        t0.add(const Duration(minutes: 12)),
      );
      expect(summary, isNotNull);
      final stored = (await repo.getTrip(trip.id))!;
      expect(stored.status, TripRecordingState.finished.name);
      expect(stored.distanceMeters, closeTo(6000, 200));
      expect(stored.movingDurationSeconds, greaterThan(0));
      expect(stored.stoppedDurationSeconds, greaterThan(0));
      expect(stored.averageSpeedKmh, greaterThan(0));
      expect(stored.summaryAlgorithmVersion, greaterThan(0));
      expect(stored.stopCount, 1);
    });

    test('finishTrip cancels an invalid (too short) trip', () async {
      final trip = await startTrip();
      await repo.appendPoint(trip.id, loc(secondsFromStart: 0, speedKmh: 10));
      final summary = await repo.finishTrip(
        trip.id,
        t0.add(const Duration(seconds: 30)),
      );
      expect(summary, isNull);
      final stored = (await repo.getTrip(trip.id))!;
      expect(stored.status, TripRecordingState.cancelled.name);
    });

    test('cancelAndDeleteTrip removes the trip and its points', () async {
      final trip = await startTrip();
      await repo.appendPoint(trip.id, loc(secondsFromStart: 0));
      await repo.cancelAndDeleteTrip(trip.id);
      expect(await repo.getTrip(trip.id), isNull);
      expect(await repo.pointsForTrip(trip.id), isEmpty);
    });
  });

  group('vehicle confirmation (ground-truth label)', () {
    test('stores confirmed type, timestamp, and changed flag', () async {
      final trip = await startTrip();
      final confirmedAt = t0.add(const Duration(hours: 1));
      await repo.confirmVehicle(
        tripId: trip.id,
        confirmed: VehicleType.motorcycle,
        confirmedAt: confirmedAt,
      );
      final stored = (await repo.getTrip(trip.id))!;
      expect(stored.confirmedVehicleType, 'motorcycle');
      expect(
        stored.detectedVehicleType,
        'unknown',
        reason: 'detection must be preserved separately',
      );
      // Drift returns DateTimes without the UTC flag; compare the instant.
      expect(stored.vehicleConfirmedAt!.toUtc(), confirmedAt);
      expect(stored.vehiclePredictionChanged, isTrue);
      expect(
        stored.syncStatus,
        'pending',
        reason: 'confirmation must be re-synced',
      );
    });

    test('confirming the same type as detected marks unchanged', () async {
      final trip = await startTrip();
      await repo.confirmVehicle(
        tripId: trip.id,
        confirmed: VehicleType.unknown,
        confirmedAt: t0,
      );
      final stored = (await repo.getTrip(trip.id))!;
      expect(stored.vehiclePredictionChanged, isFalse);
    });
  });

  group('trip recovery after restart', () {
    test('findRecoverableTrip returns the active trip', () async {
      final trip = await startTrip();
      // Simulate app restart: a brand-new repository over the same database.
      final repo2 = DefaultTripRepository(
        local: DriftTripDataSource(db),
        summaryCalculator: DefaultTripSummaryCalculator(),
      );
      final recovered = await repo2.findRecoverableTrip();
      expect(recovered, isNotNull);
      expect(recovered!.id, trip.id);
      expect(recovered.status, TripRecordingState.recording.name);
    });

    test('appendPoint continues the sequence after recovery', () async {
      final trip = await startTrip();
      await repo.appendPoint(trip.id, loc(secondsFromStart: 0));
      await repo.appendPoint(trip.id, loc(secondsFromStart: 5));

      final repo2 = DefaultTripRepository(
        local: DriftTripDataSource(db),
        summaryCalculator: DefaultTripSummaryCalculator(),
      );
      await repo2.appendPoint(trip.id, loc(secondsFromStart: 10));
      final rows = await DriftTripDataSource(db).pointsForTrip(trip.id);
      expect(rows.map((r) => r.sequenceNumber), [0, 1, 2]);
    });

    test('no recoverable trip when everything is finished', () async {
      final trip = await startTrip();
      for (final p in straightTrack()) {
        await repo.appendPoint(trip.id, p);
      }
      await repo.finishTrip(trip.id, t0.add(const Duration(minutes: 12)));
      expect(await repo.findRecoverableTrip(), isNull);
    });
  });

  group('privacy', () {
    test('deleteAllLocalData wipes everything', () async {
      final trip = await startTrip();
      await repo.appendPoint(trip.id, loc(secondsFromStart: 0));
      await repo.deleteAllLocalData();
      expect(await repo.getTrip(trip.id), isNull);
      final totals = await repo.totalsForUser('user-1');
      expect(totals.$1, 0);
    });
  });
}
