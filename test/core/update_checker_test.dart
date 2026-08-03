import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/update/update_checker.dart';

void main() {
  group('UpdateChecker.parseLatestVersionCode', () {
    test('reads versionCode from CI version.json', () {
      expect(
        UpdateChecker.parseLatestVersionCode(
          '{"versionCode": 87, "apkUrl": "https://example.com/app.apk"}',
        ),
        87,
      );
    });

    test('rejects malformed or missing values', () {
      expect(UpdateChecker.parseLatestVersionCode('not json'), isNull);
      expect(UpdateChecker.parseLatestVersionCode('{}'), isNull);
      expect(
        UpdateChecker.parseLatestVersionCode('{"versionCode": 0}'),
        isNull,
      );
      expect(
        UpdateChecker.parseLatestVersionCode('{"versionCode": "abc"}'),
        isNull,
      );
    });
  });

  test('UpdateCheckResult.hasUpdate compares version codes', () {
    const newer = UpdateCheckResult(
      currentVersionCode: 80,
      latestVersionCode: 87,
      releaseUrl: 'https://example.com',
    );
    const same = UpdateCheckResult(
      currentVersionCode: 87,
      latestVersionCode: 87,
      releaseUrl: 'https://example.com',
    );
    expect(newer.hasUpdate, isTrue);
    expect(same.hasUpdate, isFalse);
  });
}
