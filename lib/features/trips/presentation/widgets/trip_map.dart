import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/storage/app_database.dart';
import '../../../../core/utils/route_playback.dart';
import '../../../../shared/widgets/rider_avatar.dart';
import 'map_tiles.dart';

/// Shared trip map used by the detail page and the full-screen map page.
///
/// Renders the simplified display polyline (raw points stay untouched in the
/// database), start (green) / end (red) / stop (amber) markers, direction
/// arrows along the route, zoom controls, fit-route, and a dark-mode tile
/// treatment. OSM attribution is always visible per the tile license.
class TripMap extends StatelessWidget {
  const TripMap({
    super.key,
    required this.controller,
    required this.points,
    required this.stops,
    this.onStopTap,
    this.interactive = true,
    this.showControls = true,
    this.extraControls = const [],
    this.lightTiles = false,
    this.playbackFrame,
    this.riderStyle = RiderStyle.normal,
    this.congestedSegments = const [],
  });

  final MapController controller;

  /// Simplified display points (already smoothed/simplified).
  final List<LatLng> points;
  final List<TripStop> stops;
  final void Function(TripStop stop, int index)? onStopTap;
  final bool interactive;
  final bool showControls;

  /// Extra buttons stacked under the built-in controls.
  final List<Widget> extraControls;

  /// Always use the light basemap regardless of theme (e.g. share exports).
  final bool lightTiles;

  /// When set, the map renders trip playback: the route so far in full
  /// color, the rest dimmed, and a moving vehicle marker at the frame's
  /// position. Direction arrows are hidden while playing.
  final PlaybackFrame? playbackFrame;

  /// Chibi rider character shown as the playback marker.
  final RiderStyle riderStyle;

  /// Stretches of the route that were congested (crawling traffic), drawn
  /// in warning orange over the route line.
  final List<List<LatLng>> congestedSegments;

  void fitRoute() {
    if (points.length < 2) return;
    controller.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.all(48),
      ),
    );
  }

  /// Direction arrow markers every ~1/8 of the route.
  List<Marker> _directionMarkers(ColorScheme scheme) {
    if (points.length < 8) return const [];
    final markers = <Marker>[];
    final step = math.max(points.length ~/ 8, 2);
    for (var i = step; i < points.length - step ~/ 2; i += step) {
      final from = points[i - 1];
      final to = points[i];
      final bearing = _bearingRadians(from, to);
      markers.add(
        Marker(
          point: to,
          width: 22,
          height: 22,
          child: Transform.rotate(
            angle: bearing,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: scheme.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: const Icon(
                Icons.navigation,
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }
    return markers;
  }

  static double _bearingRadians(LatLng from, LatLng to) {
    final dLon = (to.longitude - from.longitude) * math.pi / 180;
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final y = math.sin(dLon) * math.cos(lat2);
    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return math.atan2(y, x);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark =
        !lightTiles && Theme.of(context).brightness == Brightness.dark;
    final playing = playbackFrame != null;

    return Stack(
      children: [
        FlutterMap(
          mapController: controller,
          options: MapOptions(
            initialCameraFit: points.length >= 2
                ? CameraFit.coordinates(
                    coordinates: points,
                    padding: const EdgeInsets.all(48),
                  )
                : null,
            initialCenter: points.isNotEmpty
                ? points.first
                : const LatLng(0, 0),
            initialZoom: 14,
            interactionOptions: InteractionOptions(
              flags: interactive ? InteractiveFlag.all : InteractiveFlag.none,
            ),
          ),
          children: [
            appTileLayer(context, forceLight: lightTiles),
            PolylineLayer(
              polylines: [
                // Casing below the route line keeps it visible on any tile.
                Polyline(
                  points: points,
                  strokeWidth: 9,
                  color: isDark ? Colors.black87 : Colors.white,
                ),
                Polyline(
                  points: points,
                  strokeWidth: 5.5,
                  color: playing
                      ? scheme.primary.withValues(alpha: 0.25)
                      : scheme.primary,
                ),
                // The already-traveled part of the route during playback.
                if (playing && playbackFrame!.traveled.length >= 2)
                  Polyline(
                    points: playbackFrame!.traveled,
                    strokeWidth: 5.5,
                    color: scheme.primary,
                  ),
                // Congested stretches on top, in warning orange.
                if (!playing)
                  for (final segment in congestedSegments)
                    if (segment.length >= 2)
                      Polyline(
                        points: segment,
                        strokeWidth: 5.5,
                        color: Colors.deepOrange.shade600,
                      ),
              ],
            ),
            if (!playing) MarkerLayer(markers: _directionMarkers(scheme)),
            MarkerLayer(
              markers: [
                // Stop markers (amber), tappable when onStopTap is given.
                for (var i = 0; i < stops.length; i++)
                  Marker(
                    point: LatLng(stops[i].latitude, stops[i].longitude),
                    width: 34,
                    height: 34,
                    child: GestureDetector(
                      onTap: onStopTap == null
                          ? null
                          : () => onStopTap!(stops[i], i),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(color: Colors.black38, blurRadius: 4),
                          ],
                        ),
                        child: const Icon(
                          Icons.local_parking,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (points.isNotEmpty)
                  Marker(
                    point: points.first,
                    width: 30,
                    height: 30,
                    child: _dotMarker(Colors.green.shade600, Icons.play_arrow),
                  ),
                if (points.length > 1)
                  Marker(
                    point: points.last,
                    width: 30,
                    height: 30,
                    child: _dotMarker(Colors.red.shade600, Icons.flag),
                  ),
                // Chibi rider marker during playback.
                if (playing)
                  Marker(
                    point: playbackFrame!.position,
                    width: 68,
                    height: 68,
                    child: RiderAvatar(
                      style: riderStyle,
                      size: 66,
                      bearingRadians: playbackFrame!.bearingRadians,
                    ),
                  ),
              ],
            ),
            mapAttribution,
          ],
        ),
        if (showControls)
          Positioned(
            right: 12,
            bottom: 28,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapButton(
                  icon: Icons.add,
                  onTap: () => controller.move(
                    controller.camera.center,
                    controller.camera.zoom + 1,
                  ),
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove,
                  onTap: () => controller.move(
                    controller.camera.center,
                    controller.camera.zoom - 1,
                  ),
                ),
                const SizedBox(height: 8),
                _MapButton(icon: Icons.fit_screen, onTap: fitRoute),
                for (final control in extraControls) ...[
                  const SizedBox(height: 8),
                  control,
                ],
              ],
            ),
          ),
      ],
    );
  }

  static Widget _dotMarker(Color color, IconData icon) => DecoratedBox(
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2),
      boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 4)],
    ),
    child: Icon(icon, size: 16, color: Colors.white),
  );
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 22, color: scheme.onSurface),
        ),
      ),
    );
  }
}
