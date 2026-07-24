import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/config/trip_detection_config.dart';
import 'package:triplog/features/trips/domain/trip_summary_calculator.dart';

import '../../helpers.dart';

void main() {
  final calculator = DefaultTripSummaryCalculator();

  group('DefaultTripSummaryCalculator', () {
    // 300 s moving at 36 km/h (=3000 m), 120 s stopped, 300 s moving (=3000 m).
    final track = straightTrack(
      movingSeconds: 300,
      stoppedSeconds: 120,
      speedKmh: 36,
      intervalSeconds: 10,
    );
    final summary = calculator.calculate(track)!;

    test('departure and arrival times', () {
      expect(summary.departureTime, track.first.recordedAt);
      expect(summary.arrivalTime, track.last.recordedAt);
    });

    test('elapsed = moving + stopped', () {
      expect(summary.elapsed, summary.moving + summary.stopped);
      expect(summary.elapsed.inSeconds, 710); // 72 ticks * 10s - 10s
    });

    test('total distance ~6 km', () {
      expect(summary.distanceMeters, closeTo(6000, 150));
    });

    test('moving time excludes the stop', () {
      expect(summary.moving.inSeconds, closeTo(590, 40));
      expect(summary.stopped.inSeconds, closeTo(120, 40));
    });

    test('overall average speed = distance / elapsed', () {
      final expected =
          (summary.distanceMeters / 1000) / (summary.elapsed.inSeconds / 3600);
      expect(summary.averageSpeedKmh, closeTo(expected, 0.01));
    });

    test('moving average speed = distance / moving time', () {
      final expected =
          (summary.distanceMeters / 1000) / (summary.moving.inSeconds / 3600);
      expect(summary.movingAverageSpeedKmh, closeTo(expected, 0.01));
      expect(
        summary.movingAverageSpeedKmh,
        greaterThan(summary.averageSpeedKmh),
      );
    });

    test('maximum speed is the cruising speed', () {
      expect(summary.maximumSpeedKmh, closeTo(36, 2));
    });

    test('detects the single stop with its duration', () {
      expect(summary.stops.length, 1);
      expect(summary.stops.single.duration.inSeconds, closeTo(110, 30));
    });

    test('start and end coordinates come from the track', () {
      expect(summary.startLatitude, track.first.latitude);
      expect(summary.endLatitude, track.last.latitude);
    });

    test('carries the algorithm version', () {
      expect(summary.algorithmVersion, tripSummaryAlgorithmVersion);
    });

    test('returns null for too few points', () {
      expect(calculator.calculate(track.take(5).toList()), isNull);
    });

    test('returns null for too short distance', () {
      final short = [
        for (var i = 0; i < 20; i++)
          loc(secondsFromStart: i * 10, lat: -6.2 + i * 0.000001, speedKmh: 1),
      ];
      expect(calculator.calculate(short), isNull);
    });

    test('returns null for too short duration', () {
      final quick = [
        for (var i = 0; i < 15; i++)
          loc(secondsFromStart: i * 2, lat: -6.2 + i * 0.0005, speedKmh: 60),
      ];
      expect(calculator.calculate(quick), isNull);
    });

    group('lenient mode (explicit user finish)', () {
      test('keeps a trip below the minimum distance', () {
        final short = [
          for (var i = 0; i < 20; i++)
            loc(
              secondsFromStart: i * 10,
              lat: -6.2 + i * 0.000001,
              speedKmh: 1,
            ),
        ];
        final summary = calculator.calculate(short, lenient: true);
        expect(summary, isNotNull);
        expect(summary!.distanceMeters, lessThan(300));
      });

      test('keeps a trip below the minimum duration and point count', () {
        final quick = [
          loc(secondsFromStart: 0, lat: -6.2, speedKmh: 30),
          loc(secondsFromStart: 5, lat: -6.2004, speedKmh: 30),
          loc(secondsFromStart: 10, lat: -6.2008, speedKmh: 30),
        ];
        expect(calculator.calculate(quick), isNull);
        expect(calculator.calculate(quick, lenient: true), isNotNull);
      });

      test('still returns null with fewer than two points', () {
        expect(
          calculator.calculate([loc(secondsFromStart: 0)], lenient: true),
          isNull,
        );
        expect(calculator.calculate(const [], lenient: true), isNull);
      });
    });
  });
}
