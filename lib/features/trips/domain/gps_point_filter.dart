import '../../../core/config/trip_detection_config.dart';
import '../../../core/location/location_models.dart';
import '../../../core/utils/geo_utils.dart';

/// Result of validating a raw point sequence.
class GpsFilterResult {
  const GpsFilterResult({
    required this.accepted,
    required this.rejectedCount,
    required this.containsMockedPoints,
  });

  final List<RecordedLocation> accepted;
  final int rejectedCount;

  /// True when any point was flagged as a mock location by the platform.
  final bool containsMockedPoints;
}

/// Rule-based GPS validation (deliberately not machine learning):
///  * drops points with horizontal accuracy worse than the configured limit;
///  * drops points whose timestamps are not strictly increasing;
///  * drops impossible jumps (implied speed above the realistic maximum);
///  * drops extreme reported-speed spikes inconsistent with neighbors;
///  * flags mock locations when the platform reports them.
class GpsPointFilter {
  GpsPointFilter({TripDetectionConfig? config})
    : config = config ?? defaultTripDetectionConfig;

  final TripDetectionConfig config;

  GpsFilterResult filter(List<RecordedLocation> points) {
    final accepted = <RecordedLocation>[];
    var rejected = 0;
    var mocked = false;

    for (final point in points) {
      if (point.isMocked == true) mocked = true;

      // Accuracy gate.
      final acc = point.horizontalAccuracy;
      if (acc != null && acc > config.maxHorizontalAccuracyMeters) {
        rejected++;
        continue;
      }

      // Invalid/non-monotonic timestamps.
      final prev = accepted.isEmpty ? null : accepted.last;
      if (point.recordedAt.millisecondsSinceEpoch <= 0 ||
          (prev != null && !point.recordedAt.isAfter(prev.recordedAt))) {
        rejected++;
        continue;
      }

      // Impossible displacement relative to the previous accepted point.
      if (prev != null) {
        final meters = GeoUtils.haversineMeters(
          prev.latitude,
          prev.longitude,
          point.latitude,
          point.longitude,
        );
        final dt =
            point.recordedAt.difference(prev.recordedAt).inMilliseconds /
            1000.0;
        final impliedKmh = dt > 0
            ? GeoUtils.msToKmh(meters / dt)
            : double.infinity;
        if (impliedKmh > config.maxRealisticSpeedKmh) {
          rejected++;
          continue;
        }
      }

      // Reported speed sanity.
      final speedKmh = point.speedKmh;
      if (speedKmh != null && speedKmh > config.maxRealisticSpeedKmh) {
        rejected++;
        continue;
      }

      accepted.add(point);
    }

    // Second pass: remove isolated reported-speed spikes inconsistent with
    // their neighbors (median of the surrounding window).
    final result = <RecordedLocation>[];
    for (var i = 0; i < accepted.length; i++) {
      final speedKmh = accepted[i].speedKmh;
      if (speedKmh != null && i > 0 && i < accepted.length - 1) {
        final neighbors = <double>[
          accepted[i - 1].speedKmh ?? 0,
          accepted[i + 1].speedKmh ?? 0,
        ]..sort();
        final medianNeighbor = (neighbors[0] + neighbors[1]) / 2;
        if (medianNeighbor > 0 &&
            speedKmh > medianNeighbor * config.maxSpeedSpikeFactor &&
            speedKmh > config.possibleTripMinSpeedKmh * 4) {
          rejected++;
          continue;
        }
      }
      result.add(accepted[i]);
    }

    return GpsFilterResult(
      accepted: result,
      rejectedCount: rejected,
      containsMockedPoints: mocked,
    );
  }
}
