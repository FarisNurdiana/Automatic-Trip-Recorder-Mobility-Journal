import 'dart:convert';

import '../../../core/location/location_models.dart';

/// Builds a GeoJSON FeatureCollection for a trip: a LineString for the route
/// plus Point features for start/end. Widely supported by GIS tools,
/// Mapbox/MapLibre, QGIS, and geojson.io.
class GeoJsonExporter {
  const GeoJsonExporter();

  String build({
    required String name,
    required List<RecordedLocation> points,
    Map<String, Object?> properties = const {},
  }) {
    final coordinates = [
      for (final p in points) [p.longitude, p.latitude],
    ];
    final doc = {
      'type': 'FeatureCollection',
      'features': [
        {
          'type': 'Feature',
          'properties': {'name': name, ...properties},
          'geometry': {'type': 'LineString', 'coordinates': coordinates},
        },
        if (points.isNotEmpty)
          {
            'type': 'Feature',
            'properties': {'name': 'start'},
            'geometry': {
              'type': 'Point',
              'coordinates': [points.first.longitude, points.first.latitude],
            },
          },
        if (points.length > 1)
          {
            'type': 'Feature',
            'properties': {'name': 'end'},
            'geometry': {
              'type': 'Point',
              'coordinates': [points.last.longitude, points.last.latitude],
            },
          },
      ],
    };
    return const JsonEncoder.withIndent(' ').convert(doc);
  }
}
