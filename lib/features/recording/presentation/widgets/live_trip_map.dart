import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/poi/nearby_poi_service.dart';
import '../../../trips/presentation/widgets/map_tiles.dart';

/// Realtime map for the driving-assistant view: the route recorded so far,
/// a live position dot that the camera can follow, and optional nearby POI
/// markers (fuel stations / repair shops).
class LiveTripMap extends StatefulWidget {
  const LiveTripMap({
    super.key,
    required this.controller,
    required this.points,
    required this.current,
    this.pois = const [],
    this.follow = true,
    this.onPoiTap,
  });

  final MapController controller;
  final List<LatLng> points;
  final LatLng? current;
  final List<NearbyPoi> pois;

  /// When true the camera keeps chasing [current].
  final bool follow;
  final void Function(NearbyPoi poi)? onPoiTap;

  @override
  State<LiveTripMap> createState() => _LiveTripMapState();
}

class _LiveTripMapState extends State<LiveTripMap> {
  @override
  void didUpdateWidget(covariant LiveTripMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final current = widget.current;
    if (widget.follow && current != null && current != oldWidget.current) {
      // Chase the fix but respect the user's chosen zoom (min 14).
      final zoom = widget.controller.camera.zoom;
      widget.controller.move(current, zoom < 14 ? 16 : zoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial =
        widget.current ??
        (widget.points.isNotEmpty ? widget.points.last : const LatLng(0, 0));

    return FlutterMap(
      mapController: widget.controller,
      options: MapOptions(initialCenter: initial, initialZoom: 16),
      children: [
        appTileLayer(context),
        if (widget.points.length >= 2)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.points,
                strokeWidth: 8,
                color: isDark ? Colors.black87 : Colors.white,
              ),
              Polyline(
                points: widget.points,
                strokeWidth: 5,
                color: scheme.primary,
              ),
            ],
          ),
        MarkerLayer(
          markers: [
            for (final poi in widget.pois)
              Marker(
                point: LatLng(poi.latitude, poi.longitude),
                width: 32,
                height: 32,
                child: GestureDetector(
                  onTap: widget.onPoiTap == null
                      ? null
                      : () => widget.onPoiTap!(poi),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: poi.type == PoiType.fuel
                          ? Colors.orange.shade700
                          : Colors.teal.shade600,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 4),
                      ],
                    ),
                    child: Icon(
                      poi.type == PoiType.fuel
                          ? Icons.local_gas_station
                          : Icons.build,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            if (widget.current != null)
              Marker(
                point: widget.current!,
                width: 26,
                height: 26,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.45),
                        blurRadius: 12,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        mapAttribution,
      ],
    );
  }
}
