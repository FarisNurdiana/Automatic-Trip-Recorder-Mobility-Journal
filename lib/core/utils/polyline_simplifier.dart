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
