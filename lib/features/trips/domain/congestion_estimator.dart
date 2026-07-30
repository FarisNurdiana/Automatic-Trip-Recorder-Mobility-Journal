import '../../../core/location/location_models.dart';
import '../../../core/utils/geo_utils.dart';

/// Rule-based congestion estimate: total time the vehicle spent *crawling* —
/// moving, but slower than typical riding speed — which on a road usually
/// means a traffic jam.
///
/// Explicitly an estimate from the speed pattern; the app has no access to
/// real traffic data. Crawling = smoothed speed in (3, 15] km/h.
class CongestionEstimator {
  const CongestionEstimator({
    this.crawlFloorKmh = 3,
    this.crawlCeilingKmh = 15,
  });

  final double crawlFloorKmh;
  final double crawlCeilingKmh;

  Duration estimate(List<RecordedLocation> points) {
    if (points.length < 3) return Duration.zero;
    var crawlingMs = 0;
    for (var i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      final dtMs = current.recordedAt
          .difference(previous.recordedAt)
          .inMilliseconds;
      if (dtMs <= 0) continue;
      final speedKmh =
          current.speedKmh ??
          GeoUtils.msToKmh(
            GeoUtils.haversineMeters(
                  previous.latitude,
                  previous.longitude,
                  current.latitude,
                  current.longitude,
                ) /
                (dtMs / 1000),
          );
      if (speedKmh > crawlFloorKmh && speedKmh <= crawlCeilingKmh) {
        crawlingMs += dtMs;
      }
    }
    return Duration(milliseconds: crawlingMs);
  }
}
