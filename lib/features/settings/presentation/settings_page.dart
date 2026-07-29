import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../l10n/gen/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  /// "12.0" -> "12", "11.5" -> "11,5"-style short number for subtitles.
  static String _trimNumber(double value) {
    final text = value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1);
    return text.replaceAll('.', ',');
  }

  /// Numeric input dialog for a settings value. Empty input clears it.
  static Future<void> _editNumber(
    BuildContext context, {
    required String title,
    required String suffix,
    required double? current,
    required Future<void> Function(double?) onSave,
  }) async {
    final l10n = AppLocalizations.of(context);
    final input = TextEditingController(
      text: current == null ? '' : _trimNumber(current),
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: input,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            suffixText: suffix,
            hintText: l10n.fuelInputHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, input.text),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (result == null) return;
    await onSave(double.tryParse(result.trim().replaceAll(',', '.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);

    String mountLabel(PhoneMountPosition p) => switch (p) {
      PhoneMountPosition.dashboardHolder => l10n.mountDashboard,
      PhoneMountPosition.handlebarHolder => l10n.mountHandlebar,
      PhoneMountPosition.pocket => l10n.mountPocket,
      PhoneMountPosition.bag => l10n.mountBag,
      PhoneMountPosition.cupHolder => l10n.mountCupHolder,
      PhoneMountPosition.unknown => l10n.mountUnknown,
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.settingsAutoDetection),
            subtitle: Text(l10n.settingsAutoDetectionDesc),
            value: settings.autoDetectionEnabled,
            onChanged: controller.setAutoDetection,
          ),
          SwitchListTile(
            title: Text(l10n.settingsKeepScreenOn),
            subtitle: Text(l10n.settingsKeepScreenOnDesc),
            value: settings.keepScreenOn,
            onChanged: controller.setKeepScreenOn,
          ),
          SwitchListTile(
            title: Text(l10n.settingsSensorLogging),
            subtitle: Text(
              '${l10n.settingsSensorLoggingDesc}\n⚠ ${l10n.settingsSensorLoggingWarning}',
            ),
            value: settings.sensorConfig.enabled,
            onChanged: controller.setSensorLogging,
          ),
          ListTile(
            title: Text(l10n.settingsMountPosition),
            subtitle: Text(l10n.settingsMountPositionDesc),
            trailing: DropdownButton<PhoneMountPosition>(
              value: settings.mountPosition,
              onChanged: (v) {
                if (v != null) controller.setMountPosition(v);
              },
              items: [
                for (final p in PhoneMountPosition.values)
                  DropdownMenuItem(value: p, child: Text(mountLabel(p))),
              ],
            ),
          ),
          const Divider(),
          // --- fuel profile (per-trip fuel estimates) ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.fuelSectionTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 4),
            child: Text(
              l10n.fuelSectionDesc,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.two_wheeler),
            title: Text(l10n.fuelMotorcycleKmPerLiter),
            subtitle: Text(
              settings.fuelProfile.motorcycleKmPerLiter == null
                  ? l10n.fuelNotSet
                  : '${_trimNumber(settings.fuelProfile.motorcycleKmPerLiter!)} km/L',
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _editNumber(
              context,
              title: l10n.fuelMotorcycleKmPerLiter,
              suffix: 'km/L',
              current: settings.fuelProfile.motorcycleKmPerLiter,
              onSave: (v) =>
                  controller.setFuelProfileValue('fuelKmPerLiterMotorcycle', v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.directions_car),
            title: Text(l10n.fuelCarKmPerLiter),
            subtitle: Text(
              settings.fuelProfile.carKmPerLiter == null
                  ? l10n.fuelNotSet
                  : '${_trimNumber(settings.fuelProfile.carKmPerLiter!)} km/L',
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _editNumber(
              context,
              title: l10n.fuelCarKmPerLiter,
              suffix: 'km/L',
              current: settings.fuelProfile.carKmPerLiter,
              onSave: (v) =>
                  controller.setFuelProfileValue('fuelKmPerLiterCar', v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.payments_outlined),
            title: Text(l10n.fuelPricePerLiter),
            subtitle: Text(
              settings.fuelProfile.fuelPricePerLiter == null
                  ? l10n.fuelNotSet
                  : 'Rp ${_trimNumber(settings.fuelProfile.fuelPricePerLiter!)} / L',
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _editNumber(
              context,
              title: l10n.fuelPricePerLiter,
              suffix: 'Rp/L',
              current: settings.fuelProfile.fuelPricePerLiter,
              onSave: (v) =>
                  controller.setFuelProfileValue('fuelPricePerLiter', v),
            ),
          ),
          const Divider(),
          // --- driving: speed warning + service reminders ---
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              l10n.drivingSectionTitle,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.speed),
            title: Text(l10n.settingsSpeedLimit),
            subtitle: Text(
              settings.speedLimitKmh == null
                  ? l10n.settingsSpeedLimitOff
                  : '${_trimNumber(settings.speedLimitKmh!)} km/j',
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _editNumber(
              context,
              title: l10n.settingsSpeedLimit,
              suffix: 'km/j',
              current: settings.speedLimitKmh,
              onSave: controller.setSpeedLimit,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.build_outlined),
            title: Text(l10n.serviceIntervalMotorcycle),
            subtitle: Text(
              settings.serviceProfile.intervalKmMotorcycle == null
                  ? l10n.serviceIntervalOff
                  : l10n.serviceIntervalEvery(
                      _trimNumber(
                        settings.serviceProfile.intervalKmMotorcycle!,
                      ),
                    ),
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _editNumber(
              context,
              title: l10n.serviceIntervalMotorcycle,
              suffix: 'km',
              current: settings.serviceProfile.intervalKmMotorcycle,
              onSave: (v) =>
                  controller.setServiceInterval(VehicleType.motorcycle, v),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.car_repair_outlined),
            title: Text(l10n.serviceIntervalCar),
            subtitle: Text(
              settings.serviceProfile.intervalKmCar == null
                  ? l10n.serviceIntervalOff
                  : l10n.serviceIntervalEvery(
                      _trimNumber(settings.serviceProfile.intervalKmCar!),
                    ),
            ),
            trailing: const Icon(Icons.edit_outlined, size: 20),
            onTap: () => _editNumber(
              context,
              title: l10n.serviceIntervalCar,
              suffix: 'km',
              current: settings.serviceProfile.intervalKmCar,
              onSave: (v) => controller.setServiceInterval(VehicleType.car, v),
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(l10n.settingsTheme),
            trailing: DropdownButton<ThemeMode>(
              value: settings.themeMode,
              onChanged: (v) {
                if (v != null) controller.setThemeMode(v);
              },
              items: [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text(l10n.themeSystem),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text(l10n.themeLight),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text(l10n.themeDark),
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(l10n.settingsLanguage),
            trailing: DropdownButton<String>(
              value: settings.locale?.languageCode ?? 'id',
              onChanged: (v) {
                if (v != null) controller.setLocale(Locale(v));
              },
              items: const [
                DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.verified_user_outlined),
            title: Text(l10n.settingsPermissions),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/permissions'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.settingsPrivacy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/privacy'),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: Text(l10n.detectionLogTitle),
            subtitle: Text(l10n.detectionLogDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/detection-log'),
          ),
        ],
      ),
    );
  }
}
