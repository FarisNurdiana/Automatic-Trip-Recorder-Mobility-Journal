import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/features/trips/domain/gps_point_filter.dart';

import '../../helpers.dart';

void main() {
  final filter = GpsPointFilter();

  group('GpsPointFilter', () {
    test('keeps a clean track untouched', () {
      final points = straightTrack();
      final result = filter.filter(points);
      expect(result.accepted.length, points.length);
      expect(result.rejectedCount, 0);
      expect(result.containsMockedPoints, isFalse);
    });

    test('drops points with bad horizontal accuracy', () {
      final points = [
        loc(secondsFromStart: 0, speedKmh: 30),
        loc(secondsFromStart: 10, speedKmh: 30, accuracy: 120),
        loc(secondsFromStart: 20, speedKmh: 30),
      ];
      final result = filter.filter(points);
      expect(result.accepted.length, 2);
      expect(result.rejectedCount, 1);
    });

    test('drops non-monotonic timestamps', () {
      final points = [
        loc(secondsFromStart: 0, speedKmh: 30),
        loc(secondsFromStart: 10, speedKmh: 30),
        loc(secondsFromStart: 5, speedKmh: 30), // goes backwards
        loc(secondsFromStart: 20, speedKmh: 30),
      ];
      final result = filter.filter(points);
      expect(result.accepted.length, 3);
      expect(result.rejectedCount, 1);
    });

    test('drops impossible jumps (implied speed too high)', () {
      final points = [
        loc(secondsFromStart: 0, lat: -6.2000, speedKmh: 30),
        // ~2.2 km in 5 s => ~1600 km/h implied
        loc(secondsFromStart: 5, lat: -6.2200, speedKmh: 30),
        loc(secondsFromStart: 10, lat: -6.2001, speedKmh: 30),
      ];
      final result = filter.filter(points);
      expect(result.rejectedCount, greaterThanOrEqualTo(1));
      expect(
        result.accepted.every((p) => p.latitude > -6.21),
        isTrue,
        reason: 'the jump outlier must be gone',
      );
    });

    test('drops isolated extreme reported-speed spikes', () {
      final points = [
        for (var i = 0; i < 3; i++)
          loc(secondsFromStart: i * 10, lat: -6.2 + i * 0.0009, speedKmh: 32),
        loc(secondsFromStart: 30, lat: -6.2 + 3 * 0.0009, speedKmh: 190),
        for (var i = 4; i < 7; i++)
          loc(secondsFromStart: i * 10, lat: -6.2 + i * 0.0009, speedKmh: 32),
      ];
      final result = filter.filter(points);
      expect(result.accepted.any((p) => (p.speedKmh ?? 0) > 180), isFalse);
      expect(result.rejectedCount, 1);
    });

    test('flags mock locations without dropping the trip', () {
      final points = [
        loc(secondsFromStart: 0, speedKmh: 30),
        loc(secondsFromStart: 10, speedKmh: 30, isMocked: true),
        loc(secondsFromStart: 20, speedKmh: 30),
      ];
      final result = filter.filter(points);
      expect(result.containsMockedPoints, isTrue);
      expect(result.accepted.length, 3);
    });
  });
}
