import 'package:logging/logging.dart';

import '../../../core/geo/reverse_geocoder.dart';
import '../../../core/storage/app_database.dart';
import '../data/trip_repository.dart';

/// Fills in the start/end address labels of a finished trip using reverse
/// geocoding. Fire-and-forget: failures (offline, rate limit) are logged and
/// ignored, and a later call retries only the fields that are still empty.
class TripAddressResolver {
  TripAddressResolver({required this.repository, required this.geocoder});

  final TripRepository repository;
  final ReverseGeocoder geocoder;
  final _log = Logger('TripAddressResolver');

  /// Trips currently being resolved, so UI-triggered backfills don't stack
  /// duplicate requests for the same trip.
  final _inFlight = <String>{};

  /// Serializes lookups with a pause between trips — Nominatim's usage
  /// policy asks for at most ~1 request per second.
  Future<void> _queue = Future.value();

  Future<void> ensure(Trip trip) async {
    if (trip.status != 'finished') return;
    final needStart = trip.startAddress == null && trip.startLatitude != null;
    final needEnd = trip.endAddress == null && trip.endLatitude != null;
    if (!needStart && !needEnd) return;
    if (!_inFlight.add(trip.id)) return;
    final run = _queue.then((_) => _resolve(trip, needStart, needEnd));
    _queue = run.then(
      (_) => Future<void>.delayed(const Duration(milliseconds: 1200)),
    );
    return run;
  }

  Future<void> _resolve(Trip trip, bool needStart, bool needEnd) async {
    try {
      final start = needStart
          ? await geocoder.shortLabel(trip.startLatitude!, trip.startLongitude!)
          : null;
      final end = needEnd
          ? await geocoder.shortLabel(trip.endLatitude!, trip.endLongitude!)
          : null;
      if (start != null || end != null) {
        await repository.setTripAddresses(
          trip.id,
          startAddress: start,
          endAddress: end,
        );
      }
    } catch (e) {
      _log.fine('address resolve failed for ${trip.id}', e);
    } finally {
      _inFlight.remove(trip.id);
    }
  }
}
