import 'dart:io';

import 'package:drift/drift.dart';
import 'package:logging/logging.dart';

import 'app_database.dart';

/// Result of a backup import: how many trips are new.
class BackupImportResult {
  const BackupImportResult({required this.tripsImported});

  final int tripsImported;
}

/// Local backup & restore of the trip history as a single SQLite file the
/// user keeps wherever they want (Drive, email, file manager).
///
/// Export uses `VACUUM INTO`, which produces a consistent snapshot of the
/// live database without closing it. Import ATTACHes the backup file and
/// merges row-by-id (`INSERT OR IGNORE`), so restoring never duplicates or
/// overwrites existing trips — it only fills in what is missing.
class DatabaseBackupService {
  DatabaseBackupService(this._db);

  final AppDatabase _db;
  final _log = Logger('DatabaseBackupService');

  /// Tables that make up the user's history, in FK-safe insert order.
  static const _tables = [
    'trips',
    'trip_points',
    'trip_stops',
    'activity_events',
    'sensor_samples',
  ];

  static String _quotePath(String path) => path.replaceAll("'", "''");

  /// Writes a consistent snapshot of the database to [targetPath]
  /// (overwriting any existing file) and returns it.
  Future<File> exportTo(String targetPath) async {
    final target = File(targetPath);
    if (await target.exists()) await target.delete();
    await _db.customStatement("VACUUM INTO '${_quotePath(targetPath)}'");
    return target;
  }

  /// Merges a backup file into the live database. [assignToUserId] rewrites
  /// the imported trips' owner so a backup restored on a fresh
  /// install/account actually shows up in the history.
  Future<BackupImportResult> importFrom(
    String backupPath, {
    required String assignToUserId,
  }) async {
    if (!await _isSqliteFile(backupPath)) {
      throw const FormatException('not a Motivox backup file');
    }
    await _db.customStatement(
      "ATTACH DATABASE '${_quotePath(backupPath)}' AS backup",
    );
    try {
      var tripsImported = 0;
      for (final table in _tables) {
        final exists = await _db
            .customSelect(
              "SELECT name FROM backup.sqlite_master "
              "WHERE type='table' AND name = ?",
              variables: [Variable.withString(table)],
            )
            .get();
        if (exists.isEmpty) continue;
        final liveCols = await _columnNames('PRAGMA table_info("$table")');
        final backupCols = await _columnNames(
          'PRAGMA backup.table_info("$table")',
        );
        final cols = liveCols.where(backupCols.contains).toList();
        if (cols.isEmpty) continue;
        final colList = cols.map((c) => '"$c"').join(', ');
        await _db.customStatement(
          'INSERT OR IGNORE INTO "$table" ($colList) '
          'SELECT $colList FROM backup."$table"',
        );
        if (table == 'trips') {
          final changes = await _db
              .customSelect('SELECT changes() AS n')
              .getSingle();
          tripsImported = changes.read<int>('n');
        }
      }
      if (assignToUserId.isNotEmpty) {
        await _db.customStatement(
          'UPDATE trips SET user_id = ? '
          'WHERE id IN (SELECT id FROM backup.trips)',
          [assignToUserId],
        );
      }
      _log.info('backup import done: $tripsImported new trips');
      return BackupImportResult(tripsImported: tripsImported);
    } finally {
      await _db.customStatement('DETACH DATABASE backup');
      // Raw SQL bypasses drift's change tracking — poke the streams so the
      // history list refreshes immediately.
      _db.markTablesUpdated([
        _db.trips,
        _db.tripPoints,
        _db.tripStops,
        _db.activityEvents,
        _db.sensorSamples,
      ]);
    }
  }

  Future<List<String>> _columnNames(String pragma) async {
    final rows = await _db.customSelect(pragma).get();
    return [for (final row in rows) row.read<String>('name')];
  }

  static Future<bool> _isSqliteFile(String path) async {
    try {
      final raf = await File(path).open();
      final header = await raf.read(16);
      await raf.close();
      return String.fromCharCodes(header).startsWith('SQLite format 3');
    } catch (_) {
      return false;
    }
  }
}
