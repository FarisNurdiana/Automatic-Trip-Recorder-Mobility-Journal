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

  /// Contiguous crawling stretches of the trip, each with its own duration
  /// and the points it covers — so the UI can say *where* the jam was and
  /// paint it on the map. Gaps up to [mergeGap] between crawling samples
  /// are bridged (a few seconds of stop-and-go is still the same jam);
  /// stretches shorter than [minDuration] are noise and dropped.
  List<CongestionSegment> segments(
    List<RecordedLocation> points, {
    Duration mergeGap = const Duration(seconds: 45),
    Duration minDuration = const Duration(minutes: 2),
  }) {
    if (points.length < 3) return const [];
    final segments = <CongestionSegment>[];
    int? runStart;
    var runEnd = 0;
    DateTime? lastCrawlAt;

    void flush() {
      if (runStart == null) return;
      final duration = points[runEnd].recordedAt.difference(
        points[runStart!].recordedAt,
      );
      if (duration >= minDuration) {
        segments.add(
          CongestionSegment(
            points: points.sublist(runStart!, runEnd + 1),
            duration: duration,
          ),
        );
      }
      runStart = null;
    }

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
      final crawling = speedKmh > crawlFloorKmh && speedKmh <= crawlCeilingKmh;
      if (crawling) {
        final lastCrawl = lastCrawlAt;
        if (runStart != null &&
            lastCrawl != null &&
            current.recordedAt.difference(lastCrawl) > mergeGap) {
          flush();
        }
        runStart ??= i - 1;
        runEnd = i;
        lastCrawlAt = current.recordedAt;
      }
    }
    flush();
    return segments;
  }
}

/// One stretch of crawling traffic within a trip.
class CongestionSegment {
  const CongestionSegment({required this.points, required this.duration});

  final List<RecordedLocation> points;
  final Duration duration;

  /// Representative position of the jam (its middle point).
  RecordedLocation get midpoint => points[points.length ~/ 2];
}
