import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:triplog/core/maintenance/app_maintenance.dart';
import 'package:triplog/core/storage/app_database.dart';
import 'package:triplog/core/storage/backup_service.dart';
import 'package:triplog/core/update/update_checker.dart';

import '../helpers.dart';

void main() {
  late Directory tempDir;
  late AppDatabase db;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('motivox_maint_test');
    db = AppDatabase(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
  });

  tearDown(() async {
    await db.close();
    await tempDir.delete(recursive: true);
  });

  Future<AppMaintenanceService> service(DateTime now) async =>
      AppMaintenanceService(
        prefs: await SharedPreferences.getInstance(),
        backup: DatabaseBackupService(db),
        updateChecker: UpdateChecker(),
        backupDirProvider: () async => tempDir,
        clock: () => now,
      );

  test('isDue respects the interval', () {
    expect(AppMaintenanceService.isDue(0, t0, const Duration(days: 7)), isTrue);
    expect(
      AppMaintenanceService.isDue(
        t0.subtract(const Duration(days: 8)).millisecondsSinceEpoch,
        t0,
        const Duration(days: 7),
      ),
      isTrue,
    );
    expect(
      AppMaintenanceService.isDue(
        t0.subtract(const Duration(days: 2)).millisecondsSinceEpoch,
        t0,
        const Duration(days: 7),
      ),
      isFalse,
    );
  });

  test('weekly auto backup writes a file once, then throttles', () async {
    final first = await service(t0);
    await first.runStartupTasks();
    final files = tempDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.contains('motivox_auto_'))
        .toList();
    expect(files, hasLength(1));

    // Next launch a day later: throttled, no new file.
    final second = await service(t0.add(const Duration(days: 1)));
    await second.runStartupTasks();
    expect(
      tempDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('motivox_auto_'))
          .length,
      1,
    );

    // Eight days later: due again — and old backups beyond 3 are pruned.
    final third = await service(t0.add(const Duration(days: 8)));
    await third.runStartupTasks();
    expect(
      tempDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.contains('motivox_auto_'))
          .length,
      2,
    );
  });
}
