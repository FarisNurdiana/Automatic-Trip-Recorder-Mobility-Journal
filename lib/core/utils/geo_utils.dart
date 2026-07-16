import 'dart:math' as math;

/// Geographic helpers used by trip summary and the state machine.
class GeoUtils {
  GeoUtils._();

  static const double earthRadiusMeters = 6371008.8;

  /// Great-circle distance between two coordinates in meters (Haversine).
  static double haversineMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final phi1 = _rad(lat1);
    final phi2 = _rad(lat2);
    final dPhi = _rad(lat2 - lat1);
    final dLambda = _rad(lon2 - lon1);

    final a = math.pow(math.sin(dPhi / 2), 2) +
        math.cos(phi1) * math.cos(phi2) * math.pow(math.sin(dLambda / 2), 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _rad(double deg) => deg * math.pi / 180.0;

  /// m/s -> km/h
  static double msToKmh(double ms) => ms * 3.6;

  /// km/h -> m/s
  static double kmhToMs(double kmh) => kmh / 3.6;
}
