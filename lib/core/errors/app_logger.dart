import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Application-wide logging. Console in debug builds plus a rotating local
/// file so field issues can be diagnosed. Auth tokens and other secrets must
/// never be passed to the logger.
class AppLogger {
  AppLogger._();

  static final AppLogger instance = AppLogger._();

  static const int _maxLogBytes = 512 * 1024;

  IOSink? _sink;
  File? _file;
  StreamSubscription<LogRecord>? _subscription;

  Future<void> init() async {
    Logger.root.level = kDebugMode ? Level.ALL : Level.INFO;
    try {
      final dir = await getApplicationSupportDirectory();
      _file = File(p.join(dir.path, 'triplog.log'));
      if (await _file!.exists() && await _file!.length() > _maxLogBytes) {
        final rotated = File('${_file!.path}.1');
        if (await rotated.exists()) await rotated.delete();
        await _file!.rename(rotated.path);
        _file = File(p.join(dir.path, 'triplog.log'));
      }
      _sink = _file!.openWrite(mode: FileMode.append);
    } catch (e) {
      debugPrint('AppLogger: file logging unavailable: $e');
    }
    _subscription ??= Logger.root.onRecord.listen(_onRecord);
  }

  void _onRecord(LogRecord record) {
    final line =
        '${record.time.toIso8601String()} ${record.level.name} '
        '[${record.loggerName}] ${record.message}'
        '${record.error == null ? '' : ' error=${record.error}'}';
    if (kDebugMode) debugPrint(line);
    _sink?.writeln(line);
    if (record.stackTrace != null && record.level >= Level.SEVERE) {
      _sink?.writeln(record.stackTrace);
    }
  }

  /// Registers global Flutter error handlers.
  void installGlobalHandlers() {
    final log = Logger('global');
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      log.severe(
        'FlutterError: ${details.exceptionAsString()}',
        details.exception,
        details.stack,
      );
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      log.severe('Uncaught: $error', error, stack);
      return true;
    };
  }

  Future<String?> readLogContents() async {
    try {
      await _sink?.flush();
      return await _file?.readAsString();
    } catch (_) {
      return null;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _sink?.flush();
    await _sink?.close();
    _sink = null;
  }
}
