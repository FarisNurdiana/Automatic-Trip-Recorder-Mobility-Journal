import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../storage/backup_service.dart';
import '../update/update_checker.dart';

/// Silent startup housekeeping so the user does not have to remember it:
///  * weekly automatic backup into the app's documents folder (latest 3
///    kept), a restore point even if the user never opens Settings;
///  * daily update check against the rolling GitHub release — the result
///    feeds the "new version" banner on the home tab.
class AppMaintenanceService {
  AppMaintenanceService({
    required this._prefs,
    required this._backup,
    required this._updateChecker,
    required this._backupDirProvider,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final SharedPreferences _prefs;
  final DatabaseBackupService _backup;
  final UpdateChecker _updateChecker;
  final Future<Directory> Function() _backupDirProvider;
  final DateTime Function() _clock;
  final _log = Logger('AppMaintenanceService');

  static const backupInterval = Duration(days: 7);
  static const updateCheckInterval = Duration(hours: 20);
  static const keptBackups = 3;

  static const _lastBackupKey = 'lastAutoBackupAtMs';
  static const _lastUpdateCheckKey = 'lastUpdateCheckAtMs';
  static const _dismissedBuildKey = 'dismissedUpdateBuild';

  /// True when [last] (epoch ms, 0 = never) is at least [interval] ago.
  static bool isDue(int last, DateTime now, Duration interval) =>
      last <= 0 ||
      now.difference(DateTime.fromMillisecondsSinceEpoch(last)) >= interval;

  /// Runs the due tasks. Returns an update the user has not dismissed yet,
  /// or null. Never throws — housekeeping must not break startup.
  Future<UpdateCheckResult?> runStartupTasks() async {
    await _autoBackupIfDue();
    return _checkUpdateIfDue();
  }

  /// Hides the banner for this build until an even newer one appears.
  Future<void> dismissUpdate(int buildNumber) =>
      _prefs.setInt(_dismissedBuildKey, buildNumber);

  Future<void> _autoBackupIfDue() async {
    final now = _clock();
    if (!isDue(_prefs.getInt(_lastBackupKey) ?? 0, now, backupInterval)) {
      return;
    }
    try {
      final dir = await _backupDirProvider();
      if (!await dir.exists()) await dir.create(recursive: true);
      final stamp =
          '${now.year}'
          '${now.month.toString().padLeft(2, '0')}'
          '${now.day.toString().padLeft(2, '0')}';
      await _backup.exportTo(p.join(dir.path, 'motivox_auto_$stamp.db'));
      await _pruneOldBackups(dir);
      await _prefs.setInt(_lastBackupKey, now.millisecondsSinceEpoch);
      _log.info('auto backup written to ${dir.path}');
    } catch (e) {
      _log.warning('auto backup failed', e);
    }
  }

  Future<void> _pruneOldBackups(Directory dir) async {
    final backups =
        (await dir.list().toList())
            .whereType<File>()
            .where((f) => p.basename(f.path).startsWith('motivox_auto_'))
            .toList()
          ..sort((a, b) => b.path.compareTo(a.path)); // stamp desc
    for (final old in backups.skip(keptBackups)) {
      try {
        await old.delete();
      } catch (_) {}
    }
  }

  Future<UpdateCheckResult?> _checkUpdateIfDue() async {
    final now = _clock();
    if (!isDue(
      _prefs.getInt(_lastUpdateCheckKey) ?? 0,
      now,
      updateCheckInterval,
    )) {
      return null;
    }
    try {
      final result = await _updateChecker.check();
      if (result != null) {
        // Only a completed check counts against the throttle, so a launch
        // without network retries next time.
        await _prefs.setInt(_lastUpdateCheckKey, now.millisecondsSinceEpoch);
      }
      if (result == null || !result.hasUpdate) return null;
      final dismissed = _prefs.getInt(_dismissedBuildKey) ?? 0;
      return result.latestVersionCode > dismissed ? result : null;
    } catch (e) {
      _log.warning('update check failed', e);
      return null;
    }
  }
}
