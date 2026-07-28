import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

import 'geo_utils.dart';

/// Position along a route during playback.
class PlaybackFrame {
  const PlaybackFrame({
    required this.position,
    required this.bearingRadians,
    required this.traveled,
  });

  final LatLng position;

  /// Heading of travel at [position], radians clockwise from north.
  final double bearingRadians;

  /// Route points already passed, ending exactly at [position].
  final List<LatLng> traveled;
}

/// Precomputes cumulative distances over a route so a trip animation can be
/// sampled by fraction (0 = start, 1 = end) at frame rate without re-running
/// Haversine over the whole track every frame.
class RoutePlayback {
  RoutePlayback(this.points)
    : _cumulative = List<double>.filled(points.length, 0) {
    for (var i = 1; i < points.length; i++) {
      _cumulative[i] =
          _cumulative[i - 1] +
          GeoUtils.haversineMeters(
            points[i - 1].latitude,
            points[i - 1].longitude,
            points[i].latitude,
            points[i].longitude,
          );
    }
  }

  final List<LatLng> points;
  final List<double> _cumulative;

  double get totalMeters => points.isEmpty ? 0 : _cumulative.last;

  bool get canPlay => points.length >= 2 && totalMeters > 0;

  /// Frame at [fraction] of the total route distance, clamped to [0, 1].
  PlaybackFrame at(double fraction) {
    assert(canPlay, 'call canPlay before sampling');
    final target = totalMeters * fraction.clamp(0.0, 1.0);

    // Binary search for the first cumulative distance >= target.
    var lo = 0, hi = _cumulative.length - 1;
    while (lo < hi) {
      final mid = (lo + hi) ~/ 2;
      if (_cumulative[mid] < target) {
        lo = mid + 1;
      } else {
        hi = mid;
      }
    }
    final index = math.max(lo, 1);

    final segStart = points[index - 1];
    final segEnd = points[index];
    final segMeters = _cumulative[index] - _cumulative[index - 1];
    final t = segMeters <= 0
        ? 1.0
        : ((target - _cumulative[index - 1]) / segMeters).clamp(0.0, 1.0);
    final position = LatLng(
      segStart.latitude + (segEnd.latitude - segStart.latitude) * t,
      segStart.longitude + (segEnd.longitude - segStart.longitude) * t,
    );

    return PlaybackFrame(
      position: position,
      bearingRadians: bearingRadians(segStart, segEnd),
      traveled: [...points.take(index), position],
    );
  }

  /// Initial bearing from [from] to [to], radians clockwise from north.
  static double bearingRadians(LatLng from, LatLng to) {
    final dLon = (to.longitude - from.longitude) * math.pi / 180;
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return math.atan2(y, x);
  }
}
