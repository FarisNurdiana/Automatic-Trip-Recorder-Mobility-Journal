import 'dart:async';

import 'activity_models.dart';
import 'activity_recognition_service.dart';

/// In-memory [ActivityRecognitionService] for tests and the simulator.
class SimulatedActivityRecognitionService
    implements ActivityRecognitionService {
  final _controller = StreamController<DetectedActivity>.broadcast();
  bool started = false;

  void emit(DetectedActivity activity) {
    if (started) _controller.add(activity);
  }

  @override
  Stream<DetectedActivity> get activityStream => _controller.stream;

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<void> start() async {
    started = true;
  }

  @override
  Future<void> stop() async {
    started = false;
  }

  void dispose() => _controller.close();
}
