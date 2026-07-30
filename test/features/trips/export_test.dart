import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/features/trips/domain/geojson_exporter.dart';
import 'package:triplog/features/trips/domain/share_privacy.dart';

import '../../helpers.dart';

void main() {
  group('GeoJsonExporter', () {
    final track = straightTrack(
      movingSeconds: 120,
      stoppedSeconds: 0,
      intervalSeconds: 10,
    );
    final geojson = const GeoJsonExporter().build(
      name: 'Motivox test',
      points: track,
      properties: {'distance_meters': 1234.5},
    );
    final doc = json.decode(geojson) as Map<String, dynamic>;

    test('is a valid FeatureCollection with route + start + end', () {
      expect(doc['type'], 'FeatureCollection');
      final features = doc['features'] as List;
      expect(features, hasLength(3));
      final line = features.first as Map<String, dynamic>;
      expect((line['geometry'] as Map)['type'], 'LineString');
      expect(
        ((line['geometry'] as Map)['coordinates'] as List).length,
        track.length,
      );
      expect((line['properties'] as Map)['distance_meters'], 1234.5);
    });

    test('coordinates are [lon, lat] order per the GeoJSON spec', () {
      final line = (doc['features'] as List).first as Map<String, dynamic>;
      final first = ((line['geometry'] as Map)['coordinates'] as List).first;
      expect(first[0], track.first.longitude);
      expect(first[1], track.first.latitude);
    });
  });

  group('SharePrivacyOptions', () {
    // 36 km/h, points every 10 s => 100 m per point.
    final track = straightTrack(
      movingSeconds: 600,
      stoppedSeconds: 0,
      intervalSeconds: 10,
    );

    test('privacy mode trims ~300 m from both route ends', () {
      const options = SharePrivacyOptions(privacyMode: true);
      final trimmed = options.applyTo(track);
      expect(trimmed.length, lessThan(track.length));
      expect(
        trimmed.first.latitude,
        isNot(track.first.latitude),
        reason: 'the start must be hidden',
      );
      expect(
        trimmed.last.latitude,
        isNot(track.last.latitude),
        reason: 'the end must be hidden',
      );
      // Roughly 3 points (~300 m) removed at each end.
      expect(track.length - trimmed.length, inInclusiveRange(4, 10));
    });

    test('without privacy mode the route is untouched', () {
      const options = SharePrivacyOptions();
      expect(options.applyTo(track), same(track));
    });

    test('short routes are never trimmed into nothing', () {
      const options = SharePrivacyOptions(privacyMode: true);
      final short = track.take(4).toList();
      final trimmed = options.applyTo(short);
      expect(trimmed.length, greaterThanOrEqualTo(2));
    });
  });
}
