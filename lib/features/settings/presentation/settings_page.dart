import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../l10n/gen/app_localizations.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

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
        ],
      ),
    );
  }
}
