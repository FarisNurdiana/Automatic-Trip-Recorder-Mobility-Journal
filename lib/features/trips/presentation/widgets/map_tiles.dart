import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../core/constants/enums.dart';
import 'cached_tile_provider.dart';

/// Basemap tile layers for the selected [MapStyle].
///
///  * [MapStyle.motivox] — CARTO Voyager (light) / Dark Matter (dark): the
///    clean brand look;
///  * [MapStyle.osm] — standard OpenStreetMap: the richest place detail
///    (street names, warung, kios, banks, mosques — the Google-Maps-like
///    level of labeling);
///  * [MapStyle.satellite] — Esri World Imagery with a CARTO labels-only
///    overlay, like Google Maps' satellite-with-labels mode.
///
/// All layers share the disk cache so previously viewed areas keep working
/// offline.
List<Widget> appTileLayers(
  BuildContext context, {
  MapStyle style = MapStyle.motivox,
  bool forceLight = false,
}) {
  final isDark = !forceLight && Theme.of(context).brightness == Brightness.dark;
  final provider = DiskCachingTileProvider(userAgent: 'com.triplog.triplog');

  TileLayer layer(String url, {bool retina = false}) => TileLayer(
    urlTemplate: url,
    userAgentPackageName: 'com.triplog.triplog',
    retinaMode: retina && RetinaMode.isHighDensity(context),
    tileProvider: provider,
  );

  return switch (style) {
    MapStyle.motivox => [
      layer(
        isDark
            ? 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
            : 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
        retina: true,
      ),
    ],
    MapStyle.osm => [layer('https://tile.openstreetmap.org/{z}/{x}/{y}.png')],
    MapStyle.satellite => [
      layer(
        'https://server.arcgisonline.com/ArcGIS/rest/services/'
        'World_Imagery/MapServer/tile/{z}/{y}/{x}',
      ),
      // White street/place names read well over imagery.
      layer(
        'https://basemaps.cartocdn.com/dark_only_labels/{z}/{x}/{y}{r}.png',
        retina: true,
      ),
    ],
  };
}

/// Attribution covering every provider [appTileLayers] can use.
Widget mapAttributionFor(MapStyle style) => RichAttributionWidget(
  attributions: [
    const TextSourceAttribution('OpenStreetMap contributors'),
    if (style != MapStyle.osm) const TextSourceAttribution('CARTO'),
    if (style == MapStyle.satellite)
      const TextSourceAttribution('Esri, Maxar, Earthstar Geographics'),
  ],
);
