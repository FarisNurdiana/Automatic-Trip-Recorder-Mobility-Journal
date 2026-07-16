import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/constants/enums.dart';
import 'package:triplog/core/location/location_models.dart';
import 'package:triplog/core/simulation/trip_simulator.dart';
import 'package:triplog/features/trips/domain/gps_point_filter.dart';
import 'package:triplog/features/trips/domain/trip_summary_calculator.dart';

void main() {
  late TripSimulator simulator;

  setUpAll(() {
    final jsonString = File(
      'assets/simulator/jakarta_commute.json',
    ).readAsStringSync();
    simulator = TripSimulator.fromJson(jsonString);
  });

  group('TripSimulator', () {
    test('parses the bundled script', () {
      expect(simulator.name, 'jakarta-sudirman-commute');
      expect(
        simulator.steps.whereType<SimulatedPointStep>().length,
        greaterThan(200),
      );
      expect(
        simulator.steps.whereType<SimulatedActivityStep>().length,
        greaterThanOrEqualTo(3),
      );
      expect(simulator.steps.whereType<SimulatedSignalLossStep>().length, 1);
    });

    test(
      'instant playback emits gradual points with advancing timestamps',
      () async {
        final events = await simulator.play(instant: true).toList();
        final locations = events
            .whereType<SimulationLocationEvent>()
            .map((e) => e.location)
            .toList();
        expect(locations.length, greaterThan(200));
        for (var i = 1; i < locations.length; i++) {
          expect(
            locations[i].recordedAt.isAfter(locations[i - 1].recordedAt),
            isTrue,
          );
        }
      },
    );

    test('emits enter and exit vehicle events', () async {
      final events = await simulator.play(instant: true).toList();
      final activities = events
          .whereType<SimulationActivityEvent>()
          .map((e) => e.activity)
          .toList();
      expect(
        activities.any(
          (a) =>
              a.type == DetectedActivityType.vehicle &&
              a.transition == ActivityTransition.enter,
        ),
        isTrue,
      );
      expect(
        activities.any(
          (a) =>
              a.type == DetectedActivityType.vehicle &&
              a.transition == ActivityTransition.exit,
        ),
        isTrue,
      );
    });

    test('signal loss creates a >40 s gap between fixes', () async {
      final events = await simulator.play(instant: true).toList();
      final locations = events
          .whereType<SimulationLocationEvent>()
          .map((e) => e.location)
          .toList();
      var maxGap = Duration.zero;
      for (var i = 1; i < locations.length; i++) {
        final gap = locations[i].recordedAt.difference(
          locations[i - 1].recordedAt,
        );
        if (gap > maxGap) maxGap = gap;
      }
      expect(maxGap.inSeconds, greaterThanOrEqualTo(40));
    });

    test('full pipeline: filter drops the GPS jump, summary is sane', () async {
      final events = await simulator.play(instant: true).toList();
      final raw = events
          .whereType<SimulationLocationEvent>()
          .map((e) => e.location)
          .toList();

      final filtered = GpsPointFilter().filter(raw);
      expect(
        filtered.rejectedCount,
        greaterThanOrEqualTo(1),
        reason: 'the scripted GPS jump must be filtered out',
      );

      final summary = DefaultTripSummaryCalculator().calculate(raw);
      expect(summary, isNotNull);
      expect(summary!.distanceMeters, inInclusiveRange(4000, 9000));
      expect(
        summary.stops.length,
        greaterThanOrEqualTo(2),
        reason: 'two scripted red lights',
      );
      expect(
        summary.maximumSpeedKmh,
        lessThan(80),
        reason: 'the 300 km/h outlier must not leak into max speed',
      );
      expect(
        summary.movingAverageSpeedKmh,
        greaterThan(summary.averageSpeedKmh),
      );
    });
  });

  group('scripted edge cases', () {
    test('rejects unknown step types', () {
      expect(
        () => TripSimulator.fromJson(
          '{"name":"x","steps":[{"type":"teleport"}]}',
        ),
        throwsFormatException,
      );
    });

    test('supports mocked points', () async {
      final sim = TripSimulator.fromJson('''
        {"name":"mock","steps":[
          {"type":"point","lat":-6.2,"lon":106.8,"speedKmh":30,
           "isMocked":true,"afterSeconds":0}
        ]}
      ''');
      final events = await sim.play(instant: true).toList();
      final location = (events.single as SimulationLocationEvent).location;
      expect(location.isMocked, isTrue);
    });
  });

  group('speed simulation', () {
    test('scripted speeds survive the RecordedLocation mapping', () async {
      final sim = TripSimulator.fromJson('''
        {"name":"speed","steps":[
          {"type":"point","lat":-6.2,"lon":106.8,"speedKmh":45,"afterSeconds":0}
        ]}
      ''');
      final events = await sim.play(instant: true).toList();
      final RecordedLocation location =
          (events.single as SimulationLocationEvent).location;
      expect(location.speedKmh, closeTo(45, 0.01));
    });
  });
}
