import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:logging/logging.dart';

/// Fetches the legal speed limit (OSM `maxspeed`) of the road closest to a
/// position, via the public Overpass API.
///
/// Privacy: positions are sent to the Overpass server ONLY while a trip is
/// being recorded and the user has the map-based speed limit setting on.
class RoadSpeedLimitService {
  RoadSpeedLimitService({List<String>? endpoints})
    : endpoints =
          endpoints ??
          const [
            'https://overpass-api.de/api/interpreter',
            'https://overpass.kumi.systems/api/interpreter',
            'https://overpass.private.coffee/api/interpreter',
          ];

  final List<String> endpoints;
  final _log = Logger('RoadSpeedLimitService');

  static const _userAgent = 'Motivox/1.0 (mobility journal app)';

  /// Roads farther than this from the fix are ignored — a parallel street's
  /// limit must not be applied.
  static const maxWayDistanceMeters = 40.0;

  /// Null when no tagged road is nearby or the lookup failed.
  Future<double?> fetchLimitKmh(double latitude, double longitude) async {
    final query =
        '[out:json][timeout:10];'
        'way(around:60,$latitude,$longitude)["highway"]["maxspeed"];'
        'out geom 10;';
    for (final endpoint in endpoints) {
      try {
        final json = await _fetch(endpoint, query);
        return parse(json, latitude, longitude);
      } catch (e) {
        _log.fine('road limit lookup via $endpoint failed', e);
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _fetch(String endpoint, String query) async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.postUrl(Uri.parse(endpoint));
      final body = utf8.encode('data=${Uri.encodeQueryComponent(query)}');
      request.headers.set(HttpHeaders.userAgentHeader, _userAgent);
      request.headers.contentType = ContentType(
        'application',
        'x-www-form-urlencoded',
        charset: 'utf-8',
      );
      request.contentLength = body.length;
      request.add(body);
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      if (response.statusCode != 200) {
        throw HttpException('overpass status ${response.statusCode}');
      }
      final text = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 12));
      return jsonDecode(text) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }

  /// Picks the way whose geometry passes closest to the position (within
  /// [maxWayDistanceMeters]) and returns its parsed maxspeed. Pure, for
  /// unit testing.
  static double? parse(
    Map<String, dynamic> json,
    double latitude,
    double longitude,
  ) {
    final elements = json['elements'] as List<dynamic>? ?? const [];
    double? bestLimit;
    var bestDistance = maxWayDistanceMeters;
    for (final raw in elements) {
      final element = raw as Map<String, dynamic>;
      if (element['type'] != 'way') continue;
      final tags = element['tags'] as Map<String, dynamic>? ?? const {};
      final limit = parseMaxspeed(tags['maxspeed'] as String?);
      if (limit == null) continue;
      final geometry = element['geometry'] as List<dynamic>? ?? const [];
      final distance = _distanceToWayMeters(geometry, latitude, longitude);
      if (distance != null && distance <= bestDistance) {
        bestDistance = distance;
        bestLimit = limit;
      }
    }
    return bestLimit;
  }

  /// "50" / "50 km/h" -> 50; "30 mph" -> 48.3; "walk"/"none" -> null.
  static double? parseMaxspeed(String? raw) {
    if (raw == null) return null;
    final value = raw.trim().toLowerCase();
    final match = RegExp(r'^(\d+(?:\.\d+)?)').firstMatch(value);
    if (match == null) return null;
    var kmh = double.parse(match.group(1)!);
    if (value.contains('mph')) kmh *= 1.609344;
    return (kmh > 0 && kmh < 200) ? kmh : null;
  }

  /// Minimum distance from the position to any segment of the way's
  /// geometry, using a local equirectangular approximation (fine at
  /// street scale). Null when the way has no geometry.
  static double? _distanceToWayMeters(
    List<dynamic> geometry,
    double latitude,
    double longitude,
  ) {
    const metersPerLatDegree = 111320.0;
    final metersPerLonDegree =
        metersPerLatDegree * math.cos(latitude * math.pi / 180);
    (double, double)? project(dynamic node) {
      final map = node as Map<String, dynamic>;
      final lat = (map['lat'] as num?)?.toDouble();
      final lon = (map['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) return null;
      return (
        (lat - latitude) * metersPerLatDegree,
        (lon - longitude) * metersPerLonDegree,
      );
    }

    double? best;
    (double, double)? previous;
    for (final node in geometry) {
      final point = project(node);
      if (point == null) continue;
      double distance;
      if (previous == null) {
        distance = math.sqrt(point.$1 * point.$1 + point.$2 * point.$2);
      } else {
        distance = _pointToSegment(previous, point);
      }
      if (best == null || distance < best) best = distance;
      previous = point;
    }
    return best;
  }

  /// Distance from origin (0,0) to the segment a-b in meters.
  static double _pointToSegment((double, double) a, (double, double) b) {
    final abx = b.$1 - a.$1;
    final aby = b.$2 - a.$2;
    final lengthSquared = abx * abx + aby * aby;
    double t = 0;
    if (lengthSquared > 0) {
      t = ((-a.$1 * abx) + (-a.$2 * aby)) / lengthSquared;
      t = t.clamp(0.0, 1.0);
    }
    final cx = a.$1 + t * abx;
    final cy = a.$2 + t * aby;
    return math.sqrt(cx * cx + cy * cy);
  }
}

/// Non-blocking cache in front of [RoadSpeedLimitService] for use from the
/// recording hot path: `limitFor` always returns immediately (the cached
/// limit or null) and kicks an async refresh when the cache is stale.
class RoadSpeedLimitResolver {
  RoadSpeedLimitResolver({
    required this._fetcher,
    bool Function()? enabled,
    DateTime Function()? clock,
  }) : _enabled = enabled ?? (() => true),
       _clock = clock ?? DateTime.now;

  final Future<double?> Function(double latitude, double longitude) _fetcher;
  final bool Function() _enabled;
  final DateTime Function() _clock;
  final _log = Logger('RoadSpeedLimitResolver');

  static const _refreshDistanceMeters = 300.0;
  static const _minFetchGap = Duration(seconds: 45);
  static const _cacheValidity = Duration(minutes: 10);

  double? _cachedLimit;
  DateTime? _fetchedAt;
  double? _fetchLat;
  double? _fetchLon;
  DateTime? _lastAttemptAt;
  bool _fetching = false;

  /// Cached road limit for this position, or null when unknown. Never
  /// blocks; refreshes in the background.
  double? limitFor(double latitude, double longitude) {
    if (!_enabled()) return null;
    final now = _clock();
    final moved = _fetchLat == null
        ? double.infinity
        : _approxMeters(latitude, longitude, _fetchLat!, _fetchLon!);
    final stale =
        _fetchedAt == null ||
        now.difference(_fetchedAt!) > _cacheValidity ||
        moved > _refreshDistanceMeters;
    final attemptAllowed =
        _lastAttemptAt == null ||
        now.difference(_lastAttemptAt!) >= _minFetchGap;
    if (stale && !_fetching && attemptAllowed) {
      _lastAttemptAt = now;
      _fetching = true;
      unawaited(_refresh(latitude, longitude));
    }
    final usable =
        _fetchedAt != null &&
        now.difference(_fetchedAt!) <= _cacheValidity &&
        moved <= 2 * _refreshDistanceMeters;
    return usable ? _cachedLimit : null;
  }

  Future<void> _refresh(double latitude, double longitude) async {
    try {
      final limit = await _fetcher(latitude, longitude);
      _cachedLimit = limit;
      _fetchedAt = _clock();
      _fetchLat = latitude;
      _fetchLon = longitude;
    } catch (e) {
      _log.fine('road limit refresh failed', e);
    } finally {
      _fetching = false;
    }
  }

  static double _approxMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const metersPerLatDegree = 111320.0;
    final dx = (lat1 - lat2) * metersPerLatDegree;
    final dy =
        (lon1 - lon2) * metersPerLatDegree * math.cos(lat1 * math.pi / 180);
    return math.sqrt(dx * dx + dy * dy);
  }
}
