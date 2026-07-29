import 'dart:convert';
import 'dart:io';

import '../utils/geo_utils.dart';

/// Kind of point of interest the driving assistant surfaces.
enum PoiType { fuel, workshop }

/// A nearby fuel station or repair shop from OpenStreetMap.
class NearbyPoi {
  const NearbyPoi({
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });

  final String name;
  final PoiType type;
  final double latitude;
  final double longitude;
  final double distanceMeters;
}

/// Looks up nearby fuel stations (amenity=fuel) and vehicle repair shops
/// (shop=car_repair / motorcycle_repair) via the public Overpass API.
///
/// Privacy: the device's coordinates are sent to the Overpass server ONLY
/// when the user explicitly taps the lookup button — never automatically.
/// The public instance is rate-limited, so lookups are on-demand and small.
class OverpassPoiService {
  OverpassPoiService({
    this.endpoint = 'https://overpass-api.de/api/interpreter',
  });

  final String endpoint;

  Future<List<NearbyPoi>> findNearby(
    double latitude,
    double longitude, {
    int radiusMeters = 3000,
    int limit = 25,
  }) async {
    final query =
        '[out:json][timeout:10];'
        '(node["amenity"="fuel"](around:$radiusMeters,$latitude,$longitude);'
        'node["shop"~"car_repair|motorcycle_repair"]'
        '(around:$radiusMeters,$latitude,$longitude););'
        'out center 60;';

    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.postUrl(Uri.parse(endpoint));
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.write('data=${Uri.encodeQueryComponent(query)}');
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      if (response.statusCode != 200) {
        throw HttpException('overpass status ${response.statusCode}');
      }
      final body = await response.transform(utf8.decoder).join();
      final json = jsonDecode(body) as Map<String, dynamic>;
      return parse(json, latitude, longitude, limit: limit);
    } finally {
      client.close(force: true);
    }
  }

  /// Pure parsing of an Overpass response, separated for unit testing.
  static List<NearbyPoi> parse(
    Map<String, dynamic> json,
    double latitude,
    double longitude, {
    int limit = 25,
  }) {
    final elements = (json['elements'] as List<dynamic>? ?? const []);
    final pois = <NearbyPoi>[];
    for (final raw in elements) {
      final element = raw as Map<String, dynamic>;
      final lat = (element['lat'] as num?)?.toDouble();
      final lon = (element['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;
      final tags =
          (element['tags'] as Map<String, dynamic>?) ??
          const <String, dynamic>{};
      final PoiType type;
      if (tags['amenity'] == 'fuel') {
        type = PoiType.fuel;
      } else if (tags['shop'] == 'car_repair' ||
          tags['shop'] == 'motorcycle_repair') {
        type = PoiType.workshop;
      } else {
        continue;
      }
      final name = (tags['name'] as String?)?.trim();
      final brand = (tags['brand'] as String?)?.trim();
      pois.add(
        NearbyPoi(
          name: (name != null && name.isNotEmpty)
              ? name
              : (brand != null && brand.isNotEmpty)
              ? brand
              : (type == PoiType.fuel ? 'SPBU' : 'Bengkel'),
          type: type,
          latitude: lat,
          longitude: lon,
          distanceMeters: GeoUtils.haversineMeters(
            latitude,
            longitude,
            lat,
            lon,
          ),
        ),
      );
    }
    pois.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));
    return pois.take(limit).toList();
  }
}
