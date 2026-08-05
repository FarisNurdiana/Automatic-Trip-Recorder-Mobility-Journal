import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/constants/enums.dart';
import '../../l10n/gen/app_localizations.dart';

/// Round "layers" button (Google-Maps style) that opens the basemap picker:
/// Motivox (clean), OpenStreetMap (full place detail) or Satellite. The
/// choice persists in settings, so every map in the app follows it.
class MapStyleButton extends ConsumerWidget {
  const MapStyleButton({super.key});

  static Future<void> showPicker(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final current = ref.read(settingsControllerProvider).mapStyle;
    final chosen = await showModalBottomSheet<MapStyle>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                l10n.mapStyleTitle,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            for (final (value, icon, title, subtitle) in [
              (
                MapStyle.osm,
                Icons.storefront_outlined,
                l10n.mapStyleOsm,
                l10n.mapStyleOsmDesc,
              ),
              (
                MapStyle.motivox,
                Icons.map_outlined,
                l10n.mapStyleMotivox,
                l10n.mapStyleMotivoxDesc,
              ),
              (
                MapStyle.satellite,
                Icons.satellite_alt_outlined,
                l10n.mapStyleSatellite,
                l10n.mapStyleSatelliteDesc,
              ),
            ])
              ListTile(
                leading: Icon(icon),
                title: Text(title),
                subtitle: Text(subtitle),
                trailing: value == current
                    ? Icon(
                        Icons.check_circle,
                        color: Theme.of(ctx).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.pop(ctx, value),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (chosen != null) {
      await ref.read(settingsControllerProvider.notifier).setMapStyle(chosen);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: AppLocalizations.of(context).mapStyleTitle,
      child: Material(
        color: scheme.surface.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => showPicker(context, ref),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(
              Icons.layers_outlined,
              size: 22,
              color: scheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
