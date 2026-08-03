import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/geo/road_speed_limit.dart';

void main() {
  group('RoadSpeedLimitService.parseMaxspeed', () {
    test('parses common OSM values', () {
      expect(RoadSpeedLimitService.parseMaxspeed('50'), 50);
      expect(RoadSpeedLimitService.parseMaxspeed('50 km/h'), 50);
      expect(
        RoadSpeedLimitService.parseMaxspeed('30 mph'),
        closeTo(48.28, 0.01),
      );
      expect(RoadSpeedLimitService.parseMaxspeed('walk'), isNull);
      expect(RoadSpeedLimitService.parseMaxspeed('none'), isNull);
      expect(RoadSpeedLimitService.parseMaxspeed(null), isNull);
    });
  });

  group('RoadSpeedLimitService.parse', () {
    Map<String, dynamic> way(String maxspeed, double latOffset) => {
      'type': 'way',
      'tags': {'highway': 'residential', 'maxspeed': maxspeed},
      'geometry': [
        {'lat': -6.2000 + latOffset, 'lon': 106.7990},
        {'lat': -6.2000 + latOffset, 'lon': 106.8010},
      ],
    };

    test('picks the way closest to the position', () {
      final json = {
        'elements': [
          way('80', 0.0020), // ~222 m away — too far
          way('40', 0.0001), // ~11 m away — this road
        ],
      };
      expect(RoadSpeedLimitService.parse(json, -6.2000, 106.8000), 40);
    });

    test('ignores ways beyond the distance ceiling', () {
      final json = {
        'elements': [way('80', 0.0020)],
      };
      expect(RoadSpeedLimitService.parse(json, -6.2000, 106.8000), isNull);
    });

    test('empty response yields null', () {
      expect(RoadSpeedLimitService.parse({'elements': []}, 0, 0), isNull);
    });
  });

  group('RoadSpeedLimitResolver', () {
    test('kicks one fetch, then serves the cached limit', () async {
      var fetches = 0;
      final resolver = RoadSpeedLimitResolver(
        fetcher: (lat, lon) async {
          fetches++;
          return 40;
        },
      );
      // First call: nothing cached yet, refresh kicked in the background.
      expect(resolver.limitFor(-6.2, 106.8), isNull);
      await Future<void>.delayed(Duration.zero);
      // Cached now; nearby calls reuse it without refetching.
      expect(resolver.limitFor(-6.2001, 106.8001), 40);
      expect(resolver.limitFor(-6.2001, 106.8001), 40);
      expect(fetches, 1);
    });

    test('disabled toggle returns null and never fetches', () async {
      var fetches = 0;
      final resolver = RoadSpeedLimitResolver(
        fetcher: (lat, lon) async {
          fetches++;
          return 40;
        },
        enabled: () => false,
      );
      expect(resolver.limitFor(-6.2, 106.8), isNull);
      await Future<void>.delayed(Duration.zero);
      expect(fetches, 0);
    });

    test('far movement invalidates the cached value', () async {
      final resolver = RoadSpeedLimitResolver(fetcher: (lat, lon) async => 40);
      resolver.limitFor(-6.2, 106.8);
      await Future<void>.delayed(Duration.zero);
      expect(resolver.limitFor(-6.2, 106.8), 40);
      // ~1.1 km away: cache no longer applies (refetch is throttled).
      expect(resolver.limitFor(-6.21, 106.8), isNull);
    });
  });
}
