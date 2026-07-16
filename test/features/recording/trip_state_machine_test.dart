import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/constants/enums.dart';
import 'package:triplog/features/recording/domain/trip_state_machine.dart';

import '../../helpers.dart';

void main() {
  late DefaultTripStateMachine machine;

  setUp(() => machine = DefaultTripStateMachine());

  group('idle -> possibleTrip', () {
    test('vehicle enter with high confidence triggers possibleTrip', () {
      final transitions = machine.onActivity(activity(secondsFromStart: 0));
      expect(transitions, hasLength(1));
      expect(transitions.single.to, TripRecordingState.possibleTrip);
      expect(machine.state, TripRecordingState.possibleTrip);
    });

    test('low confidence vehicle event is ignored', () {
      final transitions = machine.onActivity(
        activity(secondsFromStart: 0, confidence: 0.3),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.idle);
    });

    test('walking event does not start a candidate', () {
      final transitions = machine.onActivity(
        activity(secondsFromStart: 0, type: DetectedActivityType.walking),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.idle);
    });

    test('null confidence counts as confident (Transition API)', () {
      final transitions = machine.onActivity(
        activity(secondsFromStart: 0, confidence: null),
      );
      expect(transitions.single.to, TripRecordingState.possibleTrip);
    });
  });

  group('possibleTrip -> recording', () {
    setUp(() => machine.onActivity(activity(secondsFromStart: 0)));

    test('validates via displacement from the anchor', () {
      machine.onLocation(loc(secondsFromStart: 5, lat: -6.2000, speedKmh: 5));
      // ~220 m north of the anchor.
      final transitions = machine.onLocation(
        loc(secondsFromStart: 30, lat: -6.1980, speedKmh: 5),
      );
      expect(transitions.single.to, TripRecordingState.recording);
    });

    test('validates via sustained speed', () {
      machine.onLocation(loc(secondsFromStart: 0, speedKmh: 20));
      machine.onLocation(loc(secondsFromStart: 10, speedKmh: 22));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 25, speedKmh: 21),
      );
      expect(transitions.single.to, TripRecordingState.recording);
      expect(transitions.single.reason, contains('sustained'));
    });

    test('single fast point is NOT enough', () {
      final transitions = machine.onLocation(
        loc(secondsFromStart: 0, speedKmh: 40),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.possibleTrip);
    });

    test('speed dropping below threshold resets the sustained window', () {
      machine.onLocation(loc(secondsFromStart: 0, speedKmh: 20));
      machine.onLocation(loc(secondsFromStart: 10, speedKmh: 2)); // reset
      machine.onLocation(loc(secondsFromStart: 15, speedKmh: 20));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 25, speedKmh: 20),
      );
      // Only 10 s of sustained speed since the reset: not validated yet.
      expect(transitions, isEmpty);
    });
  });

  group('possibleTrip -> idle', () {
    setUp(() => machine.onActivity(activity(secondsFromStart: 0)));

    test('times out when nothing validates', () {
      final transitions = machine.onTick(t0.add(const Duration(minutes: 6)));
      expect(transitions.single.to, TripRecordingState.idle);
    });

    test('confident walking transition cancels the candidate', () {
      final transitions = machine.onActivity(
        activity(secondsFromStart: 60, type: DetectedActivityType.walking),
      );
      expect(transitions.single.to, TripRecordingState.idle);
    });
  });

  group('recording -> temporarilyStopped', () {
    setUp(() {
      machine.manualStart(t0);
    });

    test('low speed at a stable location beyond the window pauses', () {
      machine.onLocation(loc(secondsFromStart: 0, speedKmh: 0));
      machine.onLocation(loc(secondsFromStart: 60, speedKmh: 1));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 95, speedKmh: 0),
      );
      expect(transitions.single.to, TripRecordingState.temporarilyStopped);
    });

    test('brief stop below the window keeps recording', () {
      machine.onLocation(loc(secondsFromStart: 0, speedKmh: 0));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 30, speedKmh: 0),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.recording);
    });
  });

  group('temporarilyStopped', () {
    setUp(() {
      machine.manualStart(t0);
      machine.onLocation(loc(secondsFromStart: 0, speedKmh: 0));
      machine.onLocation(loc(secondsFromStart: 95, speedKmh: 0));
      expect(machine.state, TripRecordingState.temporarilyStopped);
    });

    test('-> recording when movement resumes', () {
      final transitions = machine.onLocation(
        loc(secondsFromStart: 150, speedKmh: 25),
      );
      expect(transitions.single.to, TripRecordingState.recording);
    });

    test('-> finishing after long non-vehicle stability', () {
      machine.onActivity(
        activity(
          secondsFromStart: 120,
          type: DetectedActivityType.walking,
          transition: ActivityTransition.enter,
        ),
      );
      final transitions = machine.onTick(t0.add(const Duration(minutes: 10)));
      expect(transitions.single.to, TripRecordingState.finishing);
    });

    test('stays stopped while activity still says vehicle', () {
      machine.onActivity(
        activity(
          secondsFromStart: 120,
          type: DetectedActivityType.vehicle,
          transition: ActivityTransition.sample,
        ),
      );
      final transitions = machine.onTick(t0.add(const Duration(minutes: 10)));
      expect(transitions, isEmpty);
    });
  });

  group('finishing -> finished', () {
    test('completeFinish moves to finished', () {
      machine.manualStart(t0);
      machine.manualFinish(t0.add(const Duration(minutes: 5)));
      expect(machine.state, TripRecordingState.finishing);
      final transitions = machine.completeFinish(
        t0.add(const Duration(minutes: 5)),
      );
      expect(transitions.single.to, TripRecordingState.finished);
    });
  });

  group('manual controls', () {
    test('manual start from idle begins recording', () {
      final transitions = machine.manualStart(t0);
      expect(transitions.single.from, TripRecordingState.idle);
      expect(transitions.single.to, TripRecordingState.recording);
    });

    test('manual pause and resume', () {
      machine.manualStart(t0);
      expect(
        machine.manualPause(t0).single.to,
        TripRecordingState.temporarilyStopped,
      );
      expect(machine.manualResume(t0).single.to, TripRecordingState.recording);
    });

    test('manual pause blocks automatic resume', () {
      machine.manualStart(t0);
      machine.manualPause(t0);
      final transitions = machine.onLocation(
        loc(secondsFromStart: 10, speedKmh: 40),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.temporarilyStopped);
    });

    test('recording -> cancelled via manual cancel', () {
      machine.manualStart(t0);
      final transitions = machine.manualCancel(t0);
      expect(transitions.single.to, TripRecordingState.cancelled);
    });

    test('manual finish from temporarilyStopped', () {
      machine.manualStart(t0);
      machine.manualPause(t0);
      expect(machine.manualFinish(t0).single.to, TripRecordingState.finishing);
    });

    test('reset returns to idle', () {
      machine.manualStart(t0);
      machine.manualCancel(t0);
      machine.reset();
      expect(machine.state, TripRecordingState.idle);
    });
  });

  group('restore (crash recovery)', () {
    test('restores an active state', () {
      machine.restore(TripRecordingState.recording, t0);
      expect(machine.state, TripRecordingState.recording);
      // The machine keeps operating normally after restore.
      machine.onLocation(loc(secondsFromStart: 0, speedKmh: 0));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 95, speedKmh: 0),
      );
      expect(transitions.single.to, TripRecordingState.temporarilyStopped);
    });
  });
}
