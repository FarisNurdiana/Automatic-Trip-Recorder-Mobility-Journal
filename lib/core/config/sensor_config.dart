/// Configuration for on-trip sensor sampling (accelerometer/gyroscope/
/// magnetometer). Raw streams are buffered at a higher rate and downsampled
/// before hitting the local database.
class SensorSamplingConfig {
  const SensorSamplingConfig({
    this.enabled = false,
    this.rawSamplingHz = 20,
    this.storedSamplingHz = 5,
    this.flushBatchSize = 50,
  });

  /// Master switch — user-controlled from Settings. Off by default because
  /// sensor logging increases battery usage.
  final bool enabled;

  /// Rate requested from the platform sensor streams.
  final int rawSamplingHz;

  /// Rate written to the local database after downsampling (aggregation by
  /// averaging each window).
  final int storedSamplingHz;

  /// Buffered samples are flushed to the database in batches of this size.
  final int flushBatchSize;

  SensorSamplingConfig copyWith({
    bool? enabled,
    int? rawSamplingHz,
    int? storedSamplingHz,
    int? flushBatchSize,
  }) {
    return SensorSamplingConfig(
      enabled: enabled ?? this.enabled,
      rawSamplingHz: rawSamplingHz ?? this.rawSamplingHz,
      storedSamplingHz: storedSamplingHz ?? this.storedSamplingHz,
      flushBatchSize: flushBatchSize ?? this.flushBatchSize,
    );
  }

  String get description =>
      'raw=${rawSamplingHz}Hz stored=${storedSamplingHz}Hz batch=$flushBatchSize';
}
