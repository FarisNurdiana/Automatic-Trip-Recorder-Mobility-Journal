import 'dart:async';
import 'dart:convert';

import '../activity/activity_models.dart';
import '../constants/enums.dart';
import '../location/location_models.dart';

/// One playable event from a simulation script.
sealed class SimulationStep {
  const SimulationStep(this.afterSeconds);

  /// Delay relative to the previous step (virtual seconds).
  final double afterSeconds;
}

class SimulatedPointStep extends SimulationStep {
  const SimulatedPointStep({
    required double afterSeconds,
    required this.latitude,
    required this.longitude,
    this.speedKmh,
    this.accuracy = 8,
    this.heading,
    this.altitude,
    this.isMocked = false,
  }) : super(afterSeconds);

  final double latitude;
  final double longitude;
  final double? speedKmh;
  final double accuracy;
  final double? heading;
  final double? altitude;
  final bool isMocked;
}

class SimulatedActivityStep extends SimulationStep {
  const SimulatedActivityStep({
    required double afterSeconds,
    required this.activity,
    required this.transition,
    this.confidence = 0.9,
  }) : super(afterSeconds);

  final DetectedActivityType activity;
  final ActivityTransition transition;
  final double confidence;
}

/// A pure wait — models temporary GPS signal loss.
class SimulatedSignalLossStep extends SimulationStep {
  const SimulatedSignalLossStep({required double afterSeconds})
      : super(afterSeconds);
}

/// Playback event delivered to listeners with its virtual timestamp.
sealed class SimulationEvent {
  const SimulationEvent();
}

class SimulationLocationEvent extends SimulationEvent {
  const SimulationLocationEvent(this.location);

  final RecordedLocation location;
}

class SimulationActivityEvent extends SimulationEvent {
  const SimulationActivityEvent(this.activity);

  final DetectedActivity activity;
}

/// Replays a scripted trip (JSON) so trip recording can be exercised without
/// actually driving: gradual route points, speeds, stops, GPS jumps, signal
/// loss, and enter/exit vehicle events.
class TripSimulator {
  TripSimulator(this.steps, {this.name = 'simulation'});

  final String name;
  final List<SimulationStep> steps;

  /// Parses the JSON script format documented in `assets/simulator/`.
  factory TripSimulator.fromJson(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    final steps = <SimulationStep>[];
    for (final raw in (map['steps'] as List)) {
      final step = raw as Map<String, dynamic>;
      final after = ((step['afterSeconds'] ?? 0) as num).toDouble();
      switch (step['type'] as String) {
        case 'point':
          steps.add(SimulatedPointStep(
            afterSeconds: after,
            latitude: (step['lat'] as num).toDouble(),
            longitude: (step['lon'] as num).toDouble(),
            speedKmh: (step['speedKmh'] as num?)?.toDouble(),
            accuracy: ((step['accuracy'] ?? 8) as num).toDouble(),
            heading: (step['heading'] as num?)?.toDouble(),
            altitude: (step['altitude'] as num?)?.toDouble(),
            isMocked: (step['isMocked'] as bool?) ?? false,
          ));
        case 'activity':
          steps.add(SimulatedActivityStep(
            afterSeconds: after,
            activity:
                DetectedActivityType.fromName(step['activity'] as String?),
            transition:
                ActivityTransition.fromName(step['transition'] as String?),
            confidence: ((step['confidence'] ?? 0.9) as num).toDouble(),
          ));
        case 'signalLoss':
          steps.add(SimulatedSignalLossStep(afterSeconds: after));
        default:
          throw FormatException('Unknown simulator step: ${step['type']}');
      }
    }
    return TripSimulator(steps, name: (map['name'] as String?) ?? 'simulation');
  }

  /// Plays the script. Virtual time starts at [startTime] (defaults to now);
  /// [timeFactor] > 1 plays faster than real time. With
  /// [instant] = true no real waiting happens at all (for unit tests) while
  /// virtual timestamps still advance per script.
  Stream<SimulationEvent> play({
    DateTime? startTime,
    double timeFactor = 1.0,
    bool instant = false,
  }) async* {
    var virtualTime = (startTime ?? DateTime.now().toUtc());
    for (final step in steps) {
      virtualTime = virtualTime.add(
        Duration(milliseconds: (step.afterSeconds * 1000).round()),
      );
      if (!instant && step.afterSeconds > 0) {
        await Future<void>.delayed(Duration(
          milliseconds: (step.afterSeconds * 1000 / timeFactor).round(),
        ));
      }
      switch (step) {
        case SimulatedPointStep p:
          yield SimulationLocationEvent(RecordedLocation(
            recordedAt: virtualTime,
            latitude: p.latitude,
            longitude: p.longitude,
            altitude: p.altitude,
            horizontalAccuracy: p.accuracy,
            speed: p.speedKmh == null ? null : p.speedKmh! / 3.6,
            heading: p.heading,
            source: 'simulator',
            isMocked: p.isMocked,
          ));
        case SimulatedActivityStep a:
          yield SimulationActivityEvent(DetectedActivity(
            recordedAt: virtualTime,
            type: a.activity,
            transition: a.transition,
            confidence: a.confidence,
            platformSource: 'simulator',
            rawValue: 'simulated',
          ));
        case SimulatedSignalLossStep _:
          // Nothing emitted: the gap itself is the simulation.
          break;
      }
    }
  }
}
