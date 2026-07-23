import 'dart:math' as math;

/// A minimal 2D point for simplification, independent of any map library.
class SimplePoint {
  const SimplePoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;
}

/// Ramer–Douglas–Peucker route simplification for map display. Raw points
/// remain stored locally; only the rendered polyline is simplified so the UI
/// never freezes on trips with thousands of points.
class PolylineSimplifier {
  PolylineSimplifier._();

  /// Simple moving-average smoothing for DISPLAY only (window must be odd).
  /// Endpoints are preserved so the route still starts/ends exactly where
  /// the raw data does.
  static List<SimplePoint> smooth(List<SimplePoint> points, {int window = 3}) {
    if (points.length < window || window < 3) return List.of(points);
    final half = window ~/ 2;
    final out = <SimplePoint>[points.first];
    for (var i = 1; i < points.length - 1; i++) {
      final from = (i - half).clamp(0, points.length - 1);
      final to = (i + half).clamp(0, points.length - 1);
      var lat = 0.0, lon = 0.0;
      for (var j = from; j <= to; j++) {
        lat += points[j].latitude;
        lon += points[j].longitude;
      }
      final n = to - from + 1;
      out.add(SimplePoint(lat / n, lon / n));
    }
    out.add(points.last);
    return out;
  }

  /// [toleranceDegrees] ~0.0001 is roughly 11 m at the equator.
  static List<SimplePoint> simplify(
    List<SimplePoint> points, {
    double toleranceDegrees = 0.0001,
  }) {
    if (points.length <= 2) return List.of(points);
    final keep = List<bool>.filled(points.length, false);
    keep[0] = true;
    keep[points.length - 1] = true;
    _simplifySection(points, 0, points.length - 1, toleranceDegrees, keep);
    return [
      for (var i = 0; i < points.length; i++)
        if (keep[i]) points[i],
    ];
  }

  static void _simplifySection(
    List<SimplePoint> points,
    int first,
    int last,
    double tolerance,
    List<bool> keep,
  ) {
    if (last <= first + 1) return;
    var maxDistance = 0.0;
    var index = first;
    for (var i = first + 1; i < last; i++) {
      final d = _perpendicularDistance(points[i], points[first], points[last]);
      if (d > maxDistance) {
        maxDistance = d;
        index = i;
      }
    }
    if (maxDistance > tolerance) {
      keep[index] = true;
      _simplifySection(points, first, index, tolerance, keep);
      _simplifySection(points, index, last, tolerance, keep);
    }
  }

  static double _perpendicularDistance(
    SimplePoint point,
    SimplePoint lineStart,
    SimplePoint lineEnd,
  ) {
    final x = point.longitude;
    final y = point.latitude;
    final x1 = lineStart.longitude;
    final y1 = lineStart.latitude;
    final x2 = lineEnd.longitude;
    final y2 = lineEnd.latitude;

    final dx = x2 - x1;
    final dy = y2 - y1;
    if (dx == 0 && dy == 0) {
      return math.sqrt(math.pow(x - x1, 2) + math.pow(y - y1, 2)).toDouble();
    }
    final t = (((x - x1) * dx + (y - y1) * dy) / (dx * dx + dy * dy)).clamp(
      0.0,
      1.0,
    );
    final px = x1 + t * dx;
    final py = y1 + t * dy;
    return math.sqrt(math.pow(x - px, 2) + math.pow(y - py, 2)).toDouble();
  }
}
