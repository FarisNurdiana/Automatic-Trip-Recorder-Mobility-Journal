import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/geo/reverse_geocoder.dart';

void main() {
  group('NominatimReverseGeocoder.parse', () {
    test('prefers "road, locality"', () {
      final label = NominatimReverseGeocoder.parse({
        'address': {
          'road': 'Jalan Soekarno-Hatta',
          'suburb': 'Gedebage',
          'city': 'Bandung',
        },
      });
      expect(label, 'Jalan Soekarno-Hatta, Gedebage');
    });

    test('falls back to locality when the road is missing', () {
      final label = NominatimReverseGeocoder.parse({
        'address': {'village': 'Sukawening', 'county': 'Garut'},
      });
      expect(label, 'Sukawening');
    });

    test('falls back to display_name prefix without an address block', () {
      final label = NominatimReverseGeocoder.parse({
        'display_name': 'Jalan Perintis, Sukawening, Garut, Jawa Barat',
      });
      expect(label, 'Jalan Perintis, Sukawening');
    });

    test('returns null for an empty response', () {
      expect(NominatimReverseGeocoder.parse({}), isNull);
    });
  });
}
