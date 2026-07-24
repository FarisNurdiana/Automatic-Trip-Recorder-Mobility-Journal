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

  Future<Trip> finishedTrip() async {
    final trip = await repo.createTrip(userId: 'user-1', startedAt: t0);
    for (final p in straightTrack()) {
      await repo.appendPoint(trip.id, p);
    }
    await repo.finishTrip(trip.id, t0.add(const Duration(minutes: 12)));
    return (await repo.getTrip(trip.id))!;
  }

  group('trip stops persistence', () {
    test('finishTrip stores detected stops with durations', () async {
      final trip = await finishedTrip();
      final stops = await repo.stopsForTrip(trip.id);
      expect(stops, hasLength(1));
      expect(stops.single.durationSeconds, greaterThan(60));
      expect(stops.single.stopType, StopType.unconfirmed.name);
      expect(stops.single.confirmedByUser, isFalse);
      expect(
        stops.single.isDestination,
        isTrue,
        reason: 'the last stop is flagged as the destination candidate',
      );
    });

    test('labelStop stores the user label as ground truth', () async {
      final trip = await finishedTrip();
      final stop = (await repo.stopsForTrip(trip.id)).single;
      await repo.labelStop(stopId: stop.id, type: StopType.fuel, note: 'SPBU');
      final updated = (await repo.stopsForTrip(trip.id)).single;
      expect(updated.stopType, StopType.fuel.name);
      expect(updated.stopNote, 'SPBU');
      expect(updated.confirmedByUser, isTrue);
      expect(updated.syncStatus, 'pending', reason: 'label must be re-synced');
    });

    test('label survives a repository restart (app reopen)', () async {
      final trip = await finishedTrip();
      final stop = (await repo.stopsForTrip(trip.id)).single;
      await repo.labelStop(stopId: stop.id, type: StopType.rest);

      final repo2 = DefaultTripRepository(
        local: DriftTripDataSource(db),
        summaryCalculator: DefaultTripSummaryCalculator(),
      );
      final reloaded = (await repo2.stopsForTrip(trip.id)).single;
      expect(reloaded.stopType, StopType.rest.name);
      expect(reloaded.confirmedByUser, isTrue);
    });

    test('deleteTrip removes its stops', () async {
      final trip = await finishedTrip();
      await repo.deleteTrip(trip.id);
      expect(await repo.stopsForTrip(trip.id), isEmpty);
    });
  });

  group('automatic finish metadata', () {
    test(
      'finishTrip records reason, auto flag, and arrival override',
      () async {
        final trip = await repo.createTrip(userId: 'user-1', startedAt: t0);
        for (final p in straightTrack()) {
          await repo.appendPoint(trip.id, p);
        }
        final stopStart = t0.add(const Duration(minutes: 6));
        await repo.finishTrip(
          trip.id,
          t0.add(const Duration(hours: 6)),
          finishReason: 'auto-finish: stationary 5h',
          finishedAutomatically: true,
          arrivalOverride: stopStart,
        );
        final stored = (await repo.getTrip(trip.id))!;
        expect(stored.finishedAutomatically, isTrue);
        expect(stored.finishReason, contains('auto-finish'));
        expect(
          stored.endedAt!.toUtc(),
          stopStart,
          reason: 'arrival candidate is when the vehicle stopped',
        );
      },
    );

    test(
      'lenient finish keeps a short manual trip instead of cancelling it',
      () async {
        final trip = await repo.createTrip(userId: 'user-1', startedAt: t0);
        // Only a handful of nearly-stationary points — the emulator case
        // that previously vanished without a trace.
        for (var i = 0; i < 4; i++) {
          await repo.appendPoint(
            trip.id,
            loc(secondsFromStart: i * 5, lat: -6.2 + i * 0.000002),
          );
        }
        final strict = await repo.finishTrip(
          trip.id,
          t0.add(const Duration(seconds: 20)),
        );
        expect(strict, isNull, reason: 'strict rules reject it');

        final summary = await repo.finishTrip(
          trip.id,
          t0.add(const Duration(seconds: 20)),
          finishReason: 'manual finish',
          lenient: true,
        );
        expect(summary, isNotNull);
        final stored = (await repo.getTrip(trip.id))!;
        expect(stored.status, 'finished');
        expect(stored.finishReason, 'manual finish');
      },
    );

    test('correctArrivalTime updates arrival and marks correction', () async {
      final trip = await finishedTrip();
      final corrected = t0.add(const Duration(minutes: 9));
      await repo.correctArrivalTime(trip.id, corrected);
      final stored = (await repo.getTrip(trip.id))!;
      expect(stored.endedAt!.toUtc(), corrected);
      expect(stored.arrivalCorrectedByUser, isTrue);
      expect(stored.elapsedDurationSeconds, 9 * 60);
      expect(stored.syncStatus, 'pending');
    });
  });
}
