import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/utils/geo_utils.dart';

void main() {
  group('GeoUtils.haversineMeters', () {
    test('zero distance for identical points', () {
      expect(GeoUtils.haversineMeters(-6.2, 106.8, -6.2, 106.8), 0);
    });

    test('1 degree of latitude is ~111.2 km', () {
      final d = GeoUtils.haversineMeters(0, 0, 1, 0);
      expect(d, closeTo(111195, 200));
    });

    test('known city pair: Monas to Kota Tua Jakarta (~4.7 km)', () {
      // Monas: -6.1754, 106.8272 — Kota Tua: -6.1352, 106.8133
      final d = GeoUtils.haversineMeters(-6.1754, 106.8272, -6.1352, 106.8133);
      expect(d, closeTo(4700, 300));
    });

    test('is symmetric', () {
      final a = GeoUtils.haversineMeters(-6.2, 106.8, -6.3, 106.9);
      final b = GeoUtils.haversineMeters(-6.3, 106.9, -6.2, 106.8);
      expect(a, closeTo(b, 0.0001));
    });

    test('handles the antimeridian', () {
      final d = GeoUtils.haversineMeters(0, 179.9995, 0, -179.9995);
      expect(d, closeTo(111.2, 5));
    });
  });

  group('speed conversions', () {
    test('m/s to km/h', () {
      expect(GeoUtils.msToKmh(10), closeTo(36, 0.0001));
    });

    test('km/h to m/s', () {
      expect(GeoUtils.kmhToMs(36), closeTo(10, 0.0001));
    });
  });
}
