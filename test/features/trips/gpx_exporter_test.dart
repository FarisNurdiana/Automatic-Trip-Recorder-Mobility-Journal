import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/features/trips/domain/gpx_exporter.dart';

import '../../helpers.dart';

void main() {
  const exporter = GpxExporter();

  group('GpxExporter', () {
    final track = straightTrack(
      movingSeconds: 60,
      stoppedSeconds: 0,
      intervalSeconds: 10,
    );
    final gpx = exporter.build(
      name: 'TripLog test <trip> & "quotes"',
      description: '6 km • 12 menit',
      points: track,
    );

    test('produces a GPX 1.1 document with the standard namespace', () {
      expect(gpx, startsWith('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(gpx, contains('<gpx version="1.1"'));
      expect(gpx, contains('xmlns="http://www.topografix.com/GPX/1/1"'));
      expect(gpx, contains('creator="Motivox"'));
    });

    test('contains one trkpt per point with lat/lon/time', () {
      expect('<trkpt'.allMatches(gpx).length, track.length);
      expect('</trkpt>'.allMatches(gpx).length, track.length);
      expect(gpx, contains('lat="${track.first.latitude.toStringAsFixed(7)}"'));
      // Every point carries a timestamp so importers reconstruct duration.
      expect('<time>'.allMatches(gpx).length, track.length + 1); // +metadata
    });

    test('timestamps are UTC ISO-8601 with Z suffix', () {
      final match = RegExp('<time>([^<]+)</time>').firstMatch(gpx)!;
      final value = match.group(1)!;
      expect(value, matches(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$'));
      expect(DateTime.parse(value).toUtc(), track.first.recordedAt.toUtc());
    });

    test('escapes XML special characters in name and description', () {
      expect(
        gpx,
        contains('TripLog test &lt;trip&gt; &amp; &quot;quotes&quot;'),
      );
      expect(gpx, isNot(contains('<trip>')));
    });

    test('track duration is reconstructable from first and last point', () {
      final times = RegExp(
        '<time>([^<]+)</time>',
      ).allMatches(gpx).map((m) => DateTime.parse(m.group(1)!)).toList();
      final duration = times.last.difference(times[1]); // [0] is metadata
      final expected = track.last.recordedAt.difference(track.first.recordedAt);
      expect(duration, expected);
    });

    test('includes elevation only when available', () {
      expect(gpx, isNot(contains('<ele>')));
      final withAltitude = exporter.build(
        name: 'alt',
        points: [
          for (final p in track.take(3))
            loc(
              secondsFromStart: p.recordedAt.difference(t0).inSeconds,
              lat: p.latitude,
              lon: p.longitude,
              speedKmh: 30,
            ),
        ],
      );
      expect(withAltitude, isNot(contains('<ele>')));
    });
  });
}
