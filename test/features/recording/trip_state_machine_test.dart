import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/constants/enums.dart';
import 'package:triplog/features/recording/domain/trip_state_machine.dart';

import '../../helpers.dart';

void main() {
  late DefaultTripStateMachine machine;

  setUp(() => machine = DefaultTripStateMachine());

  group('idle -> possibleTrip (activity trigger)', () {
    test('vehicle enter with high confidence triggers possibleTrip', () {
      final transitions = machine.onActivity(activity(secondsFromStart: 0));
      expect(transitions, hasLength(1));
      expect(transitions.single.to, TripRecordingState.possibleTrip);
    });

    test('low confidence vehicle event is ignored and logged', () {
      final transitions = machine.onActivity(
        activity(secondsFromStart: 0, confidence: 0.3),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.idle);
      expect(
        machine.diagnostics.any((d) => d.contains('deferred')),
        isTrue,
        reason: 'diagnostic must explain why the trip was deferred',
      );
    });

    test('walking event does not start a candidate', () {
      final transitions = machine.onActivity(
        activity(secondsFromStart: 0, type: DetectedActivityType.walking),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.idle);
    });
  });

  group('idle -> possibleTrip (speed trigger, no activity event)', () {
    test('0 to 20 km/h on a single point does NOT start anything', () {
      final transitions = machine.onLocation(
        loc(secondsFromStart: 0, speedKmh: 20),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.idle);
    });

    test('consistent 0 -> 20 km/h with displacement creates a candidate', () {
      // Warm-up + sustained speed >=10 km/h for >=10 s + displacement >=50 m.
      machine.onLocation(loc(secondsFromStart: 0, lat: -6.2000, speedKmh: 0));
      machine.onLocation(loc(secondsFromStart: 3, lat: -6.2000, speedKmh: 0));
      machine.onLocation(loc(secondsFromStart: 6, lat: -6.2000, speedKmh: 20));
      machine.onLocation(loc(secondsFromStart: 9, lat: -6.1995, speedKmh: 21));
      machine.onLocation(loc(secondsFromStart: 12, lat: -6.1990, speedKmh: 22));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 17, lat: -6.1984, speedKmh: 22),
      );
      expect(transitions, hasLength(1));
      expect(transitions.single.to, TripRecordingState.possibleTrip);
      expect(transitions.single.reason, contains('sustained'));
    });

    test('a GPS jump does not create a candidate', () {
      machine.onLocation(loc(secondsFromStart: 0, lat: -6.2000, speedKmh: 0));
      machine.onLocation(loc(secondsFromStart: 3, lat: -6.2000, speedKmh: 0));
      machine.onLocation(loc(secondsFromStart: 6, lat: -6.2000, speedKmh: 0));
      // Teleport ~2.2 km in 3 s (impossible) with a high reported speed.
      final transitions = machine.onLocation(
        loc(secondsFromStart: 9, lat: -6.2200, speedKmh: 25),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.idle);
      expect(
        machine.diagnostics.any((d) => d.contains('GPS jump')),
        isTrue,
        reason: 'the jump must be diagnosed',
      );
    });

    test('poor GPS accuracy defers the decision', () {
      for (var t = 0; t <= 20; t += 3) {
        machine.onLocation(
          loc(
            secondsFromStart: t,
            lat: -6.2000 + t * 0.0002,
            speedKmh: 25,
            accuracy: 90, // worse than maximumAcceptedAccuracyMeters
          ),
        );
      }
      expect(machine.state, TripRecordingState.idle);
    });

    test('fresh GPS (warm-up) does not trigger from the first fixes', () {
      final transitions = machine.onLocation(
        loc(secondsFromStart: 0, speedKmh: 30),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.idle);
    });
  });

  group('possibleTrip -> recording', () {
    setUp(() => machine.onActivity(activity(secondsFromStart: 0)));

    test('validates via displacement from the anchor', () {
      machine.onLocation(loc(secondsFromStart: 5, lat: -6.2000, speedKmh: 5));
      // ~220 m north of the anchor (>= 80 m threshold).
      final transitions = machine.onLocation(
        loc(secondsFromStart: 30, lat: -6.1980, speedKmh: 5),
      );
      expect(transitions.single.to, TripRecordingState.recording);
    });

    test('validates via sustained speed (activity strengthens speed)', () {
      machine.onLocation(loc(secondsFromStart: 0, speedKmh: 20));
      machine.onLocation(loc(secondsFromStart: 10, speedKmh: 22));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 16, speedKmh: 21),
      );
      expect(transitions.single.to, TripRecordingState.recording);
      expect(transitions.single.reason, contains('sustained'));
    });

    test('validates via consistent moving points', () {
      // ~20 m steps every 3 s (~24 km/h implied) with strong reported speed:
      // total displacement stays below the 80 m shortcut so the
      // consistency rule is the one that fires.
      machine.onLocation(loc(secondsFromStart: 0, lat: -6.20000, speedKmh: 25));
      machine.onLocation(loc(secondsFromStart: 3, lat: -6.19982, speedKmh: 25));
      machine.onLocation(loc(secondsFromStart: 6, lat: -6.19964, speedKmh: 26));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 9, lat: -6.19946, speedKmh: 26),
      );
      expect(transitions.single.to, TripRecordingState.recording);
      expect(transitions.single.reason, contains('consistent'));
    });

    test('single fast point is NOT enough', () {
      final transitions = machine.onLocation(
        loc(secondsFromStart: 0, speedKmh: 40),
      );
      expect(transitions, isEmpty);
      expect(machine.state, TripRecordingState.possibleTrip);
    });

    test('candidate expires when nothing validates', () {
      final transitions = machine.onTick(t0.add(const Duration(minutes: 6)));
      expect(transitions.single.to, TripRecordingState.idle);
      expect(transitions.single.reason, contains('expired'));
    });

    test('confident walking transition cancels the candidate', () {
      final transitions = machine.onActivity(
        activity(secondsFromStart: 60, type: DetectedActivityType.walking),
      );
      expect(transitions.single.to, TripRecordingState.idle);
    });
  });

  group('stop lifecycle', () {
    setUp(() {
      machine.manualStart(t0);
    });

    void stopAt(int fromSeconds, int toSeconds) {
      for (var t = fromSeconds; t <= toSeconds; t += 30) {
        machine.onLocation(loc(secondsFromStart: t, speedKmh: 0));
        machine.onTick(t0.add(Duration(seconds: t)));
      }
    }

    test('recording -> shortStop after ~1 minute stationary', () {
      machine.onLocation(loc(secondsFromStart: 0, speedKmh: 0));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 65, speedKmh: 0),
      );
      expect(transitions.single.to, TripRecordingState.shortStop);
    });

    test('a 2-minute stop stays shortStop — no question asked', () {
      stopAt(0, 120);
      expect(machine.state, TripRecordingState.shortStop);
    });

    test('a 10-minute stop escalates to temporarilyStopped', () {
      stopAt(0, 600);
      expect(machine.state, TripRecordingState.temporarilyStopped);
    });

    test('a 30-minute stop raises the rest/arrived question', () {
      stopAt(0, 1830);
      expect(machine.state, TripRecordingState.restStopCandidate);
    });

    test('movement again cancels the destination candidate', () {
      stopAt(0, 1830);
      expect(machine.state, TripRecordingState.restStopCandidate);
      final transitions = machine.onLocation(
        loc(secondsFromStart: 1860, speedKmh: 25),
      );
      expect(transitions.single.to, TripRecordingState.recording);
    });

    test('answer "resting" keeps the trip active and does not re-ask', () {
      stopAt(0, 1830);
      final transitions = machine.answerStopQuestion(
        StopQuestionAnswer.resting,
        t0.add(const Duration(minutes: 31)),
      );
      expect(transitions.single.to, TripRecordingState.temporarilyStopped);
      // Another 30 minutes at the same spot: question must NOT reappear.
      stopAt(1860, 3700);
      expect(
        machine.state,
        isNot(TripRecordingState.restStopCandidate),
        reason: 'the same location must not be asked twice',
      );
    });

    test('answer "arrived" finishes the trip', () {
      stopAt(0, 1830);
      final transitions = machine.answerStopQuestion(
        StopQuestionAnswer.arrived,
        t0.add(const Duration(minutes: 31)),
      );
      expect(transitions.single.to, TripRecordingState.finishing);
    });

    test('the stop start time is exposed as the arrival candidate', () {
      stopAt(0, 1830);
      expect(machine.currentStopStartedAt, isNotNull);
      expect(
        machine.currentStopStartedAt!.difference(t0).inSeconds,
        lessThan(120),
        reason: 'arrival candidate is when the vehicle stopped, not later',
      );
    });

    test('5 hours stationary becomes destinationCandidate', () {
      stopAt(0, 5 * 3600 + 120);
      expect(machine.state, TripRecordingState.destinationCandidate);
    });

    test('destinationCandidate auto-finishes after the grace period', () {
      stopAt(0, 5 * 3600 + 120);
      final transitions = machine.onTick(
        t0.add(const Duration(hours: 5, minutes: 40)),
      );
      expect(transitions.single.to, TripRecordingState.finishing);
      expect(transitions.single.reason, contains('auto-finish'));
    });

    test('non-vehicle activity plus stability finishes early', () {
      stopAt(0, 600);
      expect(machine.state, TripRecordingState.temporarilyStopped);
      machine.onActivity(
        activity(
          secondsFromStart: 660,
          type: DetectedActivityType.walking,
          transition: ActivityTransition.enter,
        ),
      );
      final transitions = machine.onTick(t0.add(const Duration(minutes: 18)));
      expect(transitions.single.to, TripRecordingState.finishing);
    });

    test('stays stopped while activity still says vehicle', () {
      stopAt(0, 600);
      machine.onActivity(
        activity(
          secondsFromStart: 660,
          type: DetectedActivityType.vehicle,
          transition: ActivityTransition.sample,
        ),
      );
      final transitions = machine.onTick(t0.add(const Duration(minutes: 12)));
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
    test('restores an active state and keeps operating', () {
      machine.restore(TripRecordingState.recording, t0);
      expect(machine.state, TripRecordingState.recording);
      machine.onLocation(loc(secondsFromStart: 0, speedKmh: 0));
      final transitions = machine.onLocation(
        loc(secondsFromStart: 65, speedKmh: 0),
      );
      expect(transitions.single.to, TripRecordingState.shortStop);
    });
  });
}
