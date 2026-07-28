import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:triplog/core/utils/route_playback.dart';

void main() {
  group('RoutePlayback', () {
    // Straight line heading east along the equator, 3 evenly spaced points.
    final east = [
      const LatLng(0, 0),
      const LatLng(0, 0.001),
      const LatLng(0, 0.002),
    ];

    test('canPlay requires two points and a non-zero distance', () {
      expect(RoutePlayback(const []).canPlay, isFalse);
      expect(RoutePlayback([const LatLng(0, 0)]).canPlay, isFalse);
      expect(
        RoutePlayback([const LatLng(0, 0), const LatLng(0, 0)]).canPlay,
        isFalse,
        reason: 'identical points give a zero-length route',
      );
      expect(RoutePlayback(east).canPlay, isTrue);
    });

    test('fraction 0 starts at A and fraction 1 ends at B', () {
      final playback = RoutePlayback(east);
      expect(playback.at(0).position, east.first);
      final end = playback.at(1).position;
      expect(end.latitude, closeTo(east.last.latitude, 1e-9));
      expect(end.longitude, closeTo(east.last.longitude, 1e-9));
    });

    test('fraction 0.5 sits halfway along the route', () {
      final frame = RoutePlayback(east).at(0.5);
      expect(frame.position.longitude, closeTo(0.001, 1e-6));
      expect(frame.position.latitude, closeTo(0, 1e-9));
    });

    test('traveled path grows with the fraction and ends at the marker', () {
      final playback = RoutePlayback(east);
      final quarter = playback.at(0.25);
      final threeQuarters = playback.at(0.75);
      expect(quarter.traveled.length, lessThan(threeQuarters.traveled.length));
      expect(threeQuarters.traveled.last, threeQuarters.position);
    });

    test('bearing points east on an eastward segment', () {
      final frame = RoutePlayback(east).at(0.25);
      expect(frame.bearingRadians, closeTo(math.pi / 2, 0.01));
    });

    test('out-of-range fractions are clamped', () {
      final playback = RoutePlayback(east);
      expect(playback.at(-1).position, east.first);
      final end = playback.at(2).position;
      expect(end.longitude, closeTo(east.last.longitude, 1e-9));
    });

    test('total distance matches ~111 m per 0.001° at the equator', () {
      expect(RoutePlayback(east).totalMeters, closeTo(222.4, 2));
    });
  });
}
