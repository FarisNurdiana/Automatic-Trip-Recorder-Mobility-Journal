/// One downsampled/aggregated sensor sample ready for local storage.
class CollectedSensorSample {
  const CollectedSensorSample({
    required this.recordedAt,
    this.accelerometerX,
    this.accelerometerY,
    this.accelerometerZ,
    this.gyroscopeX,
    this.gyroscopeY,
    this.gyroscopeZ,
    this.magnetometerX,
    this.magnetometerY,
    this.magnetometerZ,
    this.deviceOrientation,
    this.samplingRateHz,
    this.speed,
    this.activityState,
  });

  final DateTime recordedAt;
  final double? accelerometerX;
  final double? accelerometerY;
  final double? accelerometerZ;
  final double? gyroscopeX;
  final double? gyroscopeY;
  final double? gyroscopeZ;
  final double? magnetometerX;
  final double? magnetometerY;
  final double? magnetometerZ;
  final String? deviceOrientation;
  final double? samplingRateHz;

  /// m/s from the nearest location fix, when known.
  final double? speed;

  /// Current activity recognition state name, when known.
  final String? activityState;
}
