import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../app/providers.dart';
import '../../../core/geo/reverse_geocoder.dart';
import '../../../core/poi/nearby_poi_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../../recording/presentation/widgets/live_trip_map.dart';

/// "SPBU & bengkel terdekat" reachable from the home tab: takes one GPS fix
/// (no tracking service), queries Overpass, and shows a map + sorted list.
class NearbyPage extends ConsumerStatefulWidget {
  const NearbyPage({super.key});

  @override
  ConsumerState<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends ConsumerState<NearbyPage> {
  final _mapController = MapController();
  LatLng? _position;
  List<NearbyPoi> _pois = const [];
  var _loading = true;
  String? _errorKey; // 'gps' | 'network'

  /// Bumped on every reload so stale address lookups stop themselves.
  var _generation = 0;

  /// Fills missing street lines for the nearest results via Nominatim,
  /// serially (usage policy) and abandoned when the page reloads/closes.
  Future<void> _fillAddresses(int generation) async {
    final geocoder = NominatimReverseGeocoder();
    for (var i = 0; i < _pois.length && i < 8; i++) {
      if (!mounted || generation != _generation) return;
      final poi = _pois[i];
      if (poi.address != null) continue;
      final label = await geocoder.shortLabel(poi.latitude, poi.longitude);
      if (!mounted || generation != _generation) return;
      if (label != null) {
        setState(() {
          _pois = List.of(_pois)..[i] = poi.withAddress(label);
        });
      }
      await Future<void>.delayed(const Duration(milliseconds: 1100));
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorKey = null;
    });
    final fix = await ref
        .read(locationTrackingServiceProvider)
        .currentPosition();
    if (!mounted) return;
    if (fix == null) {
      setState(() {
        _loading = false;
        _errorKey = 'gps';
      });
      return;
    }
    final position = LatLng(fix.latitude, fix.longitude);
    setState(() => _position = position);
    try {
      final pois = await ref
          .read(nearbyPoiServiceProvider)
          .findNearby(fix.latitude, fix.longitude);
      if (!mounted) return;
      setState(() {
        _pois = pois;
        _loading = false;
      });
      unawaited(_fillAddresses(++_generation));
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorKey = 'network';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.poiSheetTitle),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? LoadingView(message: l10n.commonLoading)
          : _errorKey == 'gps'
          ? ErrorView(message: l10n.errorGpsDisabled, onRetry: _load)
          : _errorKey == 'network'
          ? ErrorView(message: l10n.poiError, onRetry: _load)
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: LiveTripMap(
                    controller: _mapController,
                    points: const [],
                    current: _position,
                    pois: _pois,
                    follow: false,
                    onPoiTap: (poi) => _mapController.move(
                      LatLng(poi.latitude, poi.longitude),
                      16.5,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: _pois.isEmpty
                      ? EmptyStateView(
                          message: l10n.poiNone,
                          icon: Icons.local_gas_station_outlined,
                        )
                      : ListView.builder(
                          itemCount: _pois.length,
                          itemBuilder: (context, i) {
                            final poi = _pois[i];
                            final fuel = poi.type == PoiType.fuel;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: fuel
                                    ? Colors.orange.shade700
                                    : Colors.teal.shade600,
                                child: Icon(
                                  fuel ? Icons.local_gas_station : Icons.build,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(poi.name),
                              subtitle: Text(
                                [
                                  if (poi.address != null) poi.address!,
                                  '${fuel ? l10n.poiFuel : l10n.poiWorkshop} • '
                                      '${Formatters.distanceKm(poi.distanceMeters, locale: locale)}',
                                ].join('\n'),
                              ),
                              isThreeLine: poi.address != null,
                              trailing: const Icon(Icons.map_outlined),
                              onTap: () => _mapController.move(
                                LatLng(poi.latitude, poi.longitude),
                                16.5,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
