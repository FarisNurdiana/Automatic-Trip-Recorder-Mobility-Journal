import 'dart:async';

import 'package:logging/logging.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../config/sensor_config.dart';
import 'sensor_collection_service.dart';
import 'sensor_models.dart';

/// [SensorCollectionService] backed by the `sensors_plus` platform streams.
///
/// Raw events are buffered per axis and averaged into fixed windows of
/// `1 / storedSamplingHz` seconds, so the database only sees the downsampled
/// rate regardless of how fast the hardware delivers events.
class SensorsPlusCollectionService implements SensorCollectionService {
  SensorsPlusCollectionService();

  final _log = Logger('SensorsPlusCollectionService');
  final _samples = StreamController<CollectedSensorSample>.broadcast();

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  Timer? _windowTimer;

  final _accelBuffer = <List<double>>[];
  final _gyroBuffer = <List<double>>[];
  final _magBuffer = <List<double>>[];

  double? _lastSpeed;
  String? _activityState;
  SensorSamplingConfig? _config;

  @override
  Stream<CollectedSensorSample> get sampleStream => _samples.stream;

  @override
  Future<bool> isAvailable() async {
    // sensors_plus has no capability probe; treat the platforms it supports
    // as available and surface per-stream errors at start().
    return true;
  }

  @override
  Future<void> start(SensorSamplingConfig config) async {
    await stop();
    _config = config;
    final interval =
        Duration(microseconds: (1000000 / config.rawSamplingHz).round());

    _accelSub = accelerometerEventStream(samplingPeriod: interval).listen(
      (e) => _accelBuffer.add([e.x, e.y, e.z]),
      onError: (Object e) => _log.warning('accelerometer unavailable', e),
    );
    _gyroSub = gyroscopeEventStream(samplingPeriod: interval).listen(
      (e) => _gyroBuffer.add([e.x, e.y, e.z]),
      onError: (Object e) => _log.warning('gyroscope unavailable', e),
    );
    _magSub = magnetometerEventStream(samplingPeriod: interval).listen(
      (e) => _magBuffer.add([e.x, e.y, e.z]),
      onError: (Object e) => _log.warning('magnetometer unavailable', e),
    );

    final window =
        Duration(milliseconds: (1000 / config.storedSamplingHz).round());
    _windowTimer = Timer.periodic(window, (_) => _flushWindow());
  }

  void _flushWindow() {
    final accel = _average(_accelBuffer);
    final gyro = _average(_gyroBuffer);
    final mag = _average(_magBuffer);
    _accelBuffer.clear();
    _gyroBuffer.clear();
    _magBuffer.clear();
    if (accel == null && gyro == null && mag == null) return;

    _samples.add(CollectedSensorSample(
      recordedAt: DateTime.now().toUtc(),
      accelerometerX: accel?[0],
      accelerometerY: accel?[1],
      accelerometerZ: accel?[2],
      gyroscopeX: gyro?[0],
      gyroscopeY: gyro?[1],
      gyroscopeZ: gyro?[2],
      magnetometerX: mag?[0],
      magnetometerY: mag?[1],
      magnetometerZ: mag?[2],
      samplingRateHz: _config?.storedSamplingHz.toDouble(),
      speed: _lastSpeed,
      activityState: _activityState,
    ));
  }

  static List<double>? _average(List<List<double>> buffer) {
    if (buffer.isEmpty) return null;
    var x = 0.0, y = 0.0, z = 0.0;
    for (final v in buffer) {
      x += v[0];
      y += v[1];
      z += v[2];
    }
    final n = buffer.length;
    return [x / n, y / n, z / n];
  }

  @override
  void updateSpeed(double? speedMs) => _lastSpeed = speedMs;

  @override
  void updateActivityState(String? activityState) =>
      _activityState = activityState;

  @override
  Future<void> stop() async {
    await _accelSub?.cancel();
    await _gyroSub?.cancel();
    await _magSub?.cancel();
    _accelSub = null;
    _gyroSub = null;
    _magSub = null;
    _windowTimer?.cancel();
    _windowTimer = null;
    _accelBuffer.clear();
    _gyroBuffer.clear();
    _magBuffer.clear();
  }
}
