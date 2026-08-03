import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/storage/app_database.dart';
import 'package:triplog/core/storage/backup_service.dart';
import 'package:triplog/features/trips/data/local_trip_data_source.dart';
import 'package:triplog/features/trips/data/trip_repository.dart';
import 'package:triplog/features/trips/domain/trip_summary_calculator.dart';

import '../helpers.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('motivox_backup_test');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<String> createBackupWithOneTrip() async {
    final source = AppDatabase(NativeDatabase.memory());
    final repo = DefaultTripRepository(
      local: DriftTripDataSource(source),
      summaryCalculator: DefaultTripSummaryCalculator(),
    );
    final trip = await repo.createTrip(userId: 'old-user', startedAt: t0);
    for (final p in straightTrack(
      movingSeconds: 120,
      stoppedSeconds: 0,
      intervalSeconds: 10,
    )) {
      await repo.appendPoint(trip.id, p);
    }
    await repo.finishTrip(trip.id, t0.add(const Duration(minutes: 5)));
    final path = '${tempDir.path}/backup.db';
    await DatabaseBackupService(source).exportTo(path);
    await source.close();
    return path;
  }

  test('export produces a valid SQLite snapshot', () async {
    final path = await createBackupWithOneTrip();
    final file = File(path);
    expect(await file.exists(), isTrue);
    final header = (await file.openRead(0, 15).first);
    expect(String.fromCharCodes(header), 'SQLite format 3');
  });

  test('import merges trips and reassigns the owner', () async {
    final path = await createBackupWithOneTrip();

    final target = AppDatabase(NativeDatabase.memory());
    final service = DatabaseBackupService(target);
    final result = await service.importFrom(path, assignToUserId: 'new-user');
    expect(result.tripsImported, 1);

    final repo = DefaultTripRepository(
      local: DriftTripDataSource(target),
      summaryCalculator: DefaultTripSummaryCalculator(),
    );
    final trips = await repo.watchTrips('new-user').first;
    expect(trips, hasLength(1));
    final points = await repo.pointsForTrip(trips.single.id);
    expect(points.length, greaterThan(5));

    // Importing the same backup again must not duplicate anything.
    final again = await service.importFrom(path, assignToUserId: 'new-user');
    expect(again.tripsImported, 0);
    expect(await repo.watchTrips('new-user').first, hasLength(1));

    await target.close();
  });

  test('import rejects a non-SQLite file', () async {
    final bogus = File('${tempDir.path}/bogus.db');
    await bogus.writeAsString('definitely not a database');
    final target = AppDatabase(NativeDatabase.memory());
    expect(
      () => DatabaseBackupService(
        target,
      ).importFrom(bogus.path, assignToUserId: 'u'),
      throwsFormatException,
    );
    await target.close();
  });
}
