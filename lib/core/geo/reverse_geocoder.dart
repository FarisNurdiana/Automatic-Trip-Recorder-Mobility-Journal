import 'dart:convert';
import 'dart:io';

/// Turns coordinates into a short human place label ("Jl. Soekarno-Hatta,
/// Gedebage") using OSM Nominatim. Used to label trip start/end points so
/// history reads as places instead of raw dates.
///
/// Usage policy: requests are on-demand (max two per finished trip), carry a
/// proper User-Agent, and failures are silently ignored — addresses are a
/// nicety, never a requirement. Offline trips simply keep coordinates.
abstract interface class ReverseGeocoder {
  Future<String?> shortLabel(double latitude, double longitude);
}

class NominatimReverseGeocoder implements ReverseGeocoder {
  NominatimReverseGeocoder({
    this.endpoint = 'https://nominatim.openstreetmap.org/reverse',
  });

  final String endpoint;

  @override
  Future<String?> shortLabel(double latitude, double longitude) async {
    final uri = Uri.parse(endpoint).replace(
      queryParameters: {
        'format': 'jsonv2',
        'lat': '$latitude',
        'lon': '$longitude',
        'zoom': '16',
        'accept-language': 'id',
      },
    );
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 8);
    try {
      final request = await client.getUrl(uri);
      request.headers.set(
        HttpHeaders.userAgentHeader,
        'Ruteku/1.0 (mobility journal; contact via app repository)',
      );
      final response = await request.close().timeout(
        const Duration(seconds: 12),
      );
      if (response.statusCode != 200) return null;
      final body = await response.transform(utf8.decoder).join();
      return parse(jsonDecode(body) as Map<String, dynamic>);
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  /// Pure label composition from a Nominatim response (testable).
  ///
  /// Prefers "road, locality" and falls back through coarser fields so it
  /// always returns something readable when an address block exists.
  static String? parse(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    if (address == null) {
      final display = (json['display_name'] as String?)?.trim();
      if (display == null || display.isEmpty) return null;
      final parts = display.split(',');
      return parts.take(2).join(',').trim();
    }
    String? pick(List<String> keys) {
      for (final key in keys) {
        final value = (address[key] as String?)?.trim();
        if (value != null && value.isNotEmpty) return value;
      }
      return null;
    }

    final road = pick(['road', 'pedestrian', 'residential', 'neighbourhood']);
    final locality = pick([
      'village',
      'suburb',
      'town',
      'city_district',
      'city',
      'county',
    ]);
    if (road != null && locality != null && road != locality) {
      return '$road, $locality';
    }
    return road ?? locality;
  }
}
