import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/features/trips/domain/congestion_estimator.dart';

import '../../helpers.dart';

void main() {
  const estimator = CongestionEstimator();

  test('cruising at normal speed counts no congestion', () {
    final track = [
      for (var i = 0; i < 20; i++)
        loc(secondsFromStart: i * 5, lat: -6.2 + i * 0.0005, speedKmh: 36),
    ];
    expect(estimator.estimate(track), Duration.zero);
  });

  test('crawling between 3 and 15 km/h counts as congestion', () {
    final track = [
      for (var i = 0; i < 13; i++)
        loc(secondsFromStart: i * 10, lat: -6.2 + i * 0.00002, speedKmh: 8),
    ];
    expect(estimator.estimate(track).inSeconds, 120);
  });

  test('fully stopped time is NOT congestion (it is a stop)', () {
    final track = [
      for (var i = 0; i < 10; i++) loc(secondsFromStart: i * 10, speedKmh: 0),
    ];
    expect(estimator.estimate(track), Duration.zero);
  });

  test('uses implied speed when the fix reports none', () {
    // ~11 m every 10 s ≈ 4 km/h — crawling, but with null reported speed.
    final track = [
      for (var i = 0; i < 7; i++)
        loc(secondsFromStart: i * 10, lat: -6.2 + i * 0.0001),
    ];
    expect(estimator.estimate(track).inSeconds, 60);
  });

  test('too few points give zero', () {
    expect(estimator.estimate([loc(secondsFromStart: 0)]), Duration.zero);
  });

  group('segments', () {
    test('finds separate jam stretches with their locations', () {
      final track = [
        // Fast riding for 2 minutes.
        for (var i = 0; i < 12; i++)
          loc(secondsFromStart: i * 10, lat: -6.2 + i * 0.001, speedKmh: 40),
        // Jam #1: crawling for 3 minutes.
        for (var i = 0; i < 18; i++)
          loc(
            secondsFromStart: 120 + i * 10,
            lat: -6.188 + i * 0.00002,
            speedKmh: 6,
          ),
        // Fast again for 2 minutes (breaks the run).
        for (var i = 0; i < 12; i++)
          loc(
            secondsFromStart: 300 + i * 10,
            lat: -6.18 + i * 0.001,
            speedKmh: 40,
          ),
        // Jam #2: crawling for 4 minutes.
        for (var i = 0; i < 24; i++)
          loc(
            secondsFromStart: 420 + i * 10,
            lat: -6.16 + i * 0.00002,
            speedKmh: 7,
          ),
      ];
      final segments = estimator.segments(track);
      expect(segments, hasLength(2));
      expect(segments[0].duration.inMinutes, greaterThanOrEqualTo(2));
      expect(segments[1].duration, greaterThan(segments[0].duration));
      // Each jam knows roughly where it happened.
      expect(segments[0].midpoint.latitude, closeTo(-6.188, 0.002));
      expect(segments[1].midpoint.latitude, closeTo(-6.16, 0.002));
    });

    test('short crawls below the minimum are dropped', () {
      final track = [
        for (var i = 0; i < 5; i++)
          loc(secondsFromStart: i * 10, lat: -6.2 + i * 0.00002, speedKmh: 6),
      ];
      expect(estimator.segments(track), isEmpty);
    });
  });
}
