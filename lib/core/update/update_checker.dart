import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Outcome of an update check against the rolling GitHub release.
class UpdateCheckResult {
  const UpdateCheckResult({
    required this.currentVersionCode,
    required this.latestVersionCode,
    required this.releaseUrl,
  });

  final int currentVersionCode;
  final int latestVersionCode;
  final String releaseUrl;

  bool get hasUpdate => latestVersionCode > currentVersionCode;
}

/// Checks the rolling `debug-latest` GitHub release for a newer build. CI
/// publishes a small `version.json` next to the APK carrying the build's
/// versionCode (the Actions run number), which is compared against this
/// install's own versionCode.
class UpdateChecker {
  UpdateChecker({
    this.repoSlug = 'FarisNurdiana/Automatic-Trip-Recorder-Mobility-Journal',
  });

  final String repoSlug;
  final _log = Logger('UpdateChecker');

  String get releaseUrl =>
      'https://github.com/$repoSlug/releases/tag/debug-latest';

  String get _versionJsonUrl =>
      'https://github.com/$repoSlug/releases/download/debug-latest/version.json';

  /// Null when the check could not be performed (offline, release missing).
  Future<UpdateCheckResult?> check() async {
    final current = int.tryParse(
      (await PackageInfo.fromPlatform()).buildNumber,
    );
    if (current == null) return null;
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(Uri.parse(_versionJsonUrl));
      request.followRedirects = true;
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      if (response.statusCode != 200) return null;
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 15));
      final latest = parseLatestVersionCode(body);
      if (latest == null) return null;
      return UpdateCheckResult(
        currentVersionCode: current,
        latestVersionCode: latest,
        releaseUrl: releaseUrl,
      );
    } catch (e) {
      _log.warning('update check failed', e);
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Pure parsing of version.json, separated for unit testing.
  static int? parseLatestVersionCode(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final code = (json['versionCode'] as num?)?.toInt();
      return (code != null && code > 0) ? code : null;
    } catch (_) {
      return null;
    }
  }
}
