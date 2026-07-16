import '../../../core/config/trip_detection_config.dart';
import '../../../core/location/location_models.dart';
import '../../../core/utils/geo_utils.dart';
import 'gps_point_filter.dart';

/// A detected stop within a trip.
class TripStop {
  const TripStop({
    required this.latitude,
    required this.longitude,
    required this.startedAt,
    required this.endedAt,
  });

  final double latitude;
  final double longitude;
  final DateTime startedAt;
  final DateTime endedAt;

  Duration get duration => endedAt.difference(startedAt);
}

/// Computed trip summary. Speeds in km/h, distance in meters.
class TripSummaryResult {
  const TripSummaryResult({
    required this.departureTime,
    required this.arrivalTime,
    required this.elapsed,
    required this.moving,
    required this.stopped,
    required this.distanceMeters,
    required this.averageSpeedKmh,
    required this.movingAverageSpeedKmh,
    required this.maximumSpeedKmh,
    required this.stops,
    required this.startLatitude,
    required this.startLongitude,
    required this.endLatitude,
    required this.endLongitude,
    required this.validPointCount,
    required this.rejectedPointCount,
    required this.containsMockedPoints,
    required this.algorithmVersion,
  });

  final DateTime departureTime;
  final DateTime arrivalTime;
  final Duration elapsed;
  final Duration moving;
  final Duration stopped;
  final double distanceMeters;
  final double averageSpeedKmh;
  final double movingAverageSpeedKmh;
  final double maximumSpeedKmh;
  final List<TripStop> stops;
  final double startLatitude;
  final double startLongitude;
  final double endLatitude;
  final double endLongitude;
  final int validPointCount;
  final int rejectedPointCount;
  final bool containsMockedPoints;
  final int algorithmVersion;
}

/// Contract for summary computation so alternative algorithms can be swapped
/// in and mocked out in tests.
abstract interface class TripSummaryCalculator {
  /// Returns null when the trip has too few valid points, is too short in
  /// distance, or too short in duration (per config).
  TripSummaryResult? calculate(List<RecordedLocation> rawPoints);
}

/// Version-tagged rule-based implementation.
///
/// overall average speed = total distance / elapsed time
/// moving average speed  = total distance / moving time
class DefaultTripSummaryCalculator implements TripSummaryCalculator {
  DefaultTripSummaryCalculator({
    TripDetectionConfig? config,
    GpsPointFilter? filter,
  }) : config = config ?? defaultTripDetectionConfig,
       filter = filter ?? GpsPointFilter(config: config);

  final TripDetectionConfig config;
  final GpsPointFilter filter;

  @override
  TripSummaryResult? calculate(List<RecordedLocation> rawPoints) {
    final filtered = filter.filter(rawPoints);
    final points = filtered.accepted;
    if (points.length < config.minTripPoints) return null;

    final departure = points.first.recordedAt;
    final arrival = points.last.recordedAt;
    final elapsed = arrival.difference(departure);
    if (elapsed < config.minTripDuration) return null;

    // Distance over validated points.
    var distance = 0.0;
    for (var i = 1; i < points.length; i++) {
      distance += GeoUtils.haversineMeters(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
    }
    if (distance < config.minTripDistanceMeters) return null;

    // Per-point speeds: reported when available, implied otherwise, then
    // median-smoothed so single glitches do not distort moving time/max.
    final speeds = _speedSeriesKmh(points);
    final smoothed = _medianSmooth(speeds, config.speedSmoothingWindow);

    var movingMs = 0;
    var maxSpeed = 0.0;
    for (var i = 1; i < points.length; i++) {
      final dtMs = points[i].recordedAt
          .difference(points[i - 1].recordedAt)
          .inMilliseconds;
      if (smoothed[i] > config.stopSpeedThresholdKmh) movingMs += dtMs;
      if (smoothed[i] > maxSpeed) maxSpeed = smoothed[i];
    }
    final moving = Duration(milliseconds: movingMs);
    final stopped = elapsed - moving;

    final elapsedHours = elapsed.inMilliseconds / 3600000.0;
    final movingHours = moving.inMilliseconds / 3600000.0;
    final distanceKm = distance / 1000.0;
    final avgSpeed = elapsedHours > 0 ? distanceKm / elapsedHours : 0.0;
    final movingAvg = movingHours > 0 ? distanceKm / movingHours : 0.0;

    return TripSummaryResult(
      departureTime: departure,
      arrivalTime: arrival,
      elapsed: elapsed,
      moving: moving,
      stopped: stopped.isNegative ? Duration.zero : stopped,
      distanceMeters: distance,
      averageSpeedKmh: avgSpeed,
      movingAverageSpeedKmh: movingAvg,
      maximumSpeedKmh: maxSpeed,
      stops: _detectStops(points, smoothed),
      startLatitude: points.first.latitude,
      startLongitude: points.first.longitude,
      endLatitude: points.last.latitude,
      endLongitude: points.last.longitude,
      validPointCount: points.length,
      rejectedPointCount: filtered.rejectedCount,
      containsMockedPoints: filtered.containsMockedPoints,
      algorithmVersion: tripSummaryAlgorithmVersion,
    );
  }

  List<double> _speedSeriesKmh(List<RecordedLocation> points) {
    final speeds = List<double>.filled(points.length, 0);
    for (var i = 0; i < points.length; i++) {
      final reported = points[i].speedKmh;
      if (reported != null && reported >= 0) {
        speeds[i] = reported;
      } else if (i > 0) {
        final meters = GeoUtils.haversineMeters(
          points[i - 1].latitude,
          points[i - 1].longitude,
          points[i].latitude,
          points[i].longitude,
        );
        final dt =
            points[i].recordedAt
                .difference(points[i - 1].recordedAt)
                .inMilliseconds /
            1000.0;
        speeds[i] = dt > 0 ? GeoUtils.msToKmh(meters / dt) : 0;
      }
    }
    return speeds;
  }

  /// Simple, testable median smoothing — explicitly rule-based, not ML.
  List<double> _medianSmooth(List<double> values, int window) {
    if (window <= 1 || values.length < window) return values;
    final half = window ~/ 2;
    final out = List<double>.from(values);
    for (var i = half; i < values.length - half; i++) {
      final slice = values.sublist(i - half, i + half + 1)..sort();
      out[i] = slice[half];
    }
    return out;
  }

  List<TripStop> _detectStops(
    List<RecordedLocation> points,
    List<double> smoothedSpeeds,
  ) {
    final stops = <TripStop>[];
    int? clusterStart;
    for (var i = 0; i < points.length; i++) {
      final isStopped = smoothedSpeeds[i] <= config.stopSpeedThresholdKmh;
      if (isStopped) {
        clusterStart ??= i;
      }
      final closesCluster =
          (!isStopped || i == points.length - 1) && clusterStart != null;
      if (closesCluster) {
        final endIndex = isStopped ? i : i - 1;
        final start = points[clusterStart];
        final end = points[endIndex];
        if (end.recordedAt.difference(start.recordedAt) >=
            config.minStopDurationForSummary) {
          var lat = 0.0, lon = 0.0;
          final n = endIndex - clusterStart + 1;
          for (var j = clusterStart; j <= endIndex; j++) {
            lat += points[j].latitude;
            lon += points[j].longitude;
          }
          stops.add(
            TripStop(
              latitude: lat / n,
              longitude: lon / n,
              startedAt: start.recordedAt,
              endedAt: end.recordedAt,
            ),
          );
        }
        clusterStart = null;
      }
    }
    return stops;
  }
}
