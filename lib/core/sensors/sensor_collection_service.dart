import '../config/sensor_config.dart';
import 'sensor_models.dart';

/// Collects motion sensor data during an active trip for the future
/// car/motorcycle classification dataset.
///
/// Pipeline: sensor stream -> temporary buffer -> downsampling/aggregation
/// -> local database -> batch synchronization.
abstract interface class SensorCollectionService {
  /// Downsampled samples at the configured storage rate.
  Stream<CollectedSensorSample> get sampleStream;

  Future<bool> isAvailable();

  /// Starts raw collection at `config.rawSamplingHz`, emitting aggregated
  /// samples at `config.storedSamplingHz`.
  Future<void> start(SensorSamplingConfig config);

  Future<void> stop();

  /// Context setters so each stored sample carries the nearest known speed
  /// and activity state.
  void updateSpeed(double? speedMs);
  void updateActivityState(String? activityState);
}
