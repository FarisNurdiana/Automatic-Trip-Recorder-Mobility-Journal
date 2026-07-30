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
  OverpassPoiService({List<String>? endpoints})
    : endpoints =
          endpoints ??
          const [
            'https://overpass-api.de/api/interpreter',
            'https://overpass.kumi.systems/api/interpreter',
            'https://overpass.private.coffee/api/interpreter',
          ];

  /// Public Overpass instances, tried in order — a single instance being
  /// down or rate-limited must not kill the feature.
  final List<String> endpoints;

  static const _userAgent = 'Motivox/1.0 (mobility journal app)';

  Future<List<NearbyPoi>> findNearby(
    double latitude,
    double longitude, {
    int radiusMeters = 5000,
    int limit = 40,
  }) async {
    final query =
        '[out:json][timeout:25];'
        '(node["amenity"="fuel"](around:$radiusMeters,$latitude,$longitude);'
        'node["shop"~"car_repair|motorcycle_repair"]'
        '(around:$radiusMeters,$latitude,$longitude););'
        'out center 80;';

    Object? lastError;
    for (final endpoint in endpoints) {
      // Some networks/proxies mishandle chunked POSTs; try a plain POST with
      // an explicit Content-Length first, then a GET on the same instance.
      for (final useGet in [false, true]) {
        try {
          final json = await _fetch(endpoint, query, useGet: useGet);
          return parse(json, latitude, longitude, limit: limit);
        } catch (e) {
          lastError = e;
        }
      }
    }
    throw Exception('all overpass endpoints failed: $lastError');
  }

  Future<Map<String, dynamic>> _fetch(
    String endpoint,
    String query, {
    required bool useGet,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 12);
    try {
      final HttpClientRequest request;
      if (useGet) {
        final uri = Uri.parse(
          '$endpoint?data=${Uri.encodeQueryComponent(query)}',
        );
        request = await client.getUrl(uri);
        request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      } else {
        request = await client.postUrl(Uri.parse(endpoint));
        final body = utf8.encode('data=${Uri.encodeQueryComponent(query)}');
        request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
        request.headers.contentType = ContentType(
          'application',
          'x-www-form-urlencoded',
          charset: 'utf-8',
        );
        request.contentLength = body.length;
        request.add(body);
      }
      final response = await request.close().timeout(
        const Duration(seconds: 30),
      );
      if (response.statusCode != 200) {
        throw HttpException('overpass status ${response.statusCode}');
      }
      final body = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 30));
      return jsonDecode(body) as Map<String, dynamic>;
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
