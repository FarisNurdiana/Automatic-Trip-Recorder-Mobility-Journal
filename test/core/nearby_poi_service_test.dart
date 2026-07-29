import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/poi/nearby_poi_service.dart';

void main() {
  group('OverpassPoiService.parse', () {
    final sample = {
      'elements': [
        {
          'type': 'node',
          'lat': -6.201,
          'lon': 106.801,
          'tags': {'amenity': 'fuel', 'name': 'SPBU Pertamina 34.123'},
        },
        {
          'type': 'node',
          'lat': -6.2005,
          'lon': 106.8005,
          'tags': {'shop': 'motorcycle_repair', 'name': 'Bengkel Jaya'},
        },
        {
          'type': 'node',
          'lat': -6.209,
          'lon': 106.809,
          'tags': {'amenity': 'fuel', 'brand': 'Shell'},
        },
        // Irrelevant tag — must be skipped.
        {
          'type': 'node',
          'lat': -6.2,
          'lon': 106.8,
          'tags': {'amenity': 'cafe', 'name': 'Kopi'},
        },
        // Missing coordinates — must be skipped.
        {
          'type': 'node',
          'tags': {'amenity': 'fuel'},
        },
      ],
    };

    test('keeps only fuel stations and repair shops', () {
      final pois = OverpassPoiService.parse(sample, -6.2, 106.8);
      expect(pois, hasLength(3));
      expect(pois.where((p) => p.type == PoiType.fuel), hasLength(2));
      expect(pois.where((p) => p.type == PoiType.workshop), hasLength(1));
    });

    test('sorts by distance from the given position', () {
      final pois = OverpassPoiService.parse(sample, -6.2, 106.8);
      expect(pois.first.name, 'Bengkel Jaya');
      for (var i = 1; i < pois.length; i++) {
        expect(
          pois[i].distanceMeters,
          greaterThanOrEqualTo(pois[i - 1].distanceMeters),
        );
      }
    });

    test('falls back to brand, then a generic label, when unnamed', () {
      final pois = OverpassPoiService.parse(sample, -6.2, 106.8);
      expect(pois.map((p) => p.name), contains('Shell'));
      final unnamed = OverpassPoiService.parse(
        {
          'elements': [
            {
              'lat': -6.2,
              'lon': 106.8,
              'tags': {'shop': 'car_repair'},
            },
          ],
        },
        -6.2,
        106.8,
      );
      expect(unnamed.single.name, 'Bengkel');
    });

    test('respects the result limit', () {
      final many = {
        'elements': [
          for (var i = 0; i < 40; i++)
            {
              'lat': -6.2 + i * 0.001,
              'lon': 106.8,
              'tags': {'amenity': 'fuel'},
            },
        ],
      };
      expect(
        OverpassPoiService.parse(many, -6.2, 106.8, limit: 10),
        hasLength(10),
      );
    });

    test('empty or malformed responses give an empty list', () {
      expect(OverpassPoiService.parse({}, -6.2, 106.8), isEmpty);
      expect(OverpassPoiService.parse({'elements': []}, -6.2, 106.8), isEmpty);
    });
  });
}
