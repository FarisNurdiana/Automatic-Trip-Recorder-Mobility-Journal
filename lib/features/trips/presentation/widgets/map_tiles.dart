import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Basemap tiles with a clean, Google-Maps-like appearance.
///
/// Light mode uses CARTO "Voyager" (soft pastel roads/water like Google
/// Maps); dark mode uses CARTO "Dark Matter" — a real dark basemap instead
/// of the old color-inverted OSM tiles. Attribution for both: OpenStreetMap
/// contributors + CARTO (free tier, attribution required).
TileLayer appTileLayer(BuildContext context, {bool forceLight = false}) {
  final isDark = !forceLight && Theme.of(context).brightness == Brightness.dark;
  return TileLayer(
    urlTemplate: isDark
        ? 'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
    userAgentPackageName: 'com.triplog.triplog',
    retinaMode: RetinaMode.isHighDensity(context),
  );
}

/// Attribution matching [appTileLayer]'s providers.
const mapAttribution = RichAttributionWidget(
  attributions: [
    TextSourceAttribution('OpenStreetMap contributors'),
    TextSourceAttribution('CARTO'),
  ],
);
