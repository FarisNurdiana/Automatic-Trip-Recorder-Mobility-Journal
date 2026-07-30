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
}
