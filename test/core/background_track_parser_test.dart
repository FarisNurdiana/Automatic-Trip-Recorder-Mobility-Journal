import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/location/background_track.dart';

void main() {
  String start(int millis) => '{"type":"start","startedAtMillis":$millis}';
  String point(int millis, double lat) =>
      '{"timestampMs":$millis,"latitude":$lat,"longitude":106.8,'
      '"horizontalAccuracy":8.0,"speed":10.0,"source":"fused"}';

  group('BackgroundTrackParser', () {
    test('parses a single segment with its points', () {
      final segments = BackgroundTrackParser.parse([
        start(1000),
        point(2000, -6.20),
        point(5000, -6.21),
      ]);
      expect(segments, hasLength(1));
      expect(segments.single.startedAt.millisecondsSinceEpoch, 1000);
      expect(segments.single.points, hasLength(2));
      expect(segments.single.points.last.latitude, -6.21);
    });

    test('splits multiple start lines into separate segments', () {
      final segments = BackgroundTrackParser.parse([
        start(1000),
        point(2000, -6.20),
        start(90000),
        point(91000, -6.30),
        point(92000, -6.31),
      ]);
      expect(segments, hasLength(2));
      expect(segments[0].points, hasLength(1));
      expect(segments[1].points, hasLength(2));
      expect(segments[1].startedAt.millisecondsSinceEpoch, 90000);
    });

    test('skips malformed lines and points before any start', () {
      final segments = BackgroundTrackParser.parse([
        point(500, -6.19), // no segment yet
        start(1000),
        '{"broken json', // partially written (process killed mid-write)
        '',
        point(2000, -6.20),
        '{"latitude":"not-a-number","longitude":106.8}',
      ]);
      expect(segments, hasLength(1));
      expect(segments.single.points, hasLength(1));
    });

    test('empty input yields no segments', () {
      expect(BackgroundTrackParser.parse(const []), isEmpty);
    });
  });
}
