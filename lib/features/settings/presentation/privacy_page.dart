import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../l10n/gen/app_localizations.dart';

/// Privacy controls: disable detection/sensors, delete local data, delete
/// cloud data, sign out.
class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String message,
  ) async {
    final l10n = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    return result == true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);
    final settingsController = ref.read(settingsControllerProvider.notifier);
    final auth = ref.watch(authControllerProvider);

    void toast(String message) => ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text(l10n.settingsAutoDetection),
            value: settings.autoDetectionEnabled,
            onChanged: settingsController.setAutoDetection,
          ),
          SwitchListTile(
            title: Text(l10n.settingsSensorLogging),
            value: settings.sensorConfig.enabled,
            onChanged: settingsController.setSensorLogging,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l10n.privacyDeleteAllLocal),
            onTap: () async {
              if (await _confirm(
                context,
                l10n.privacyDeleteAllLocal,
                l10n.privacyDeleteAllLocalConfirm,
              )) {
                await ref.read(tripRepositoryProvider).deleteAllLocalData();
                toast(l10n.privacyDataDeleted);
              }
            },
          ),
          if (auth.isSignedIn && !auth.isLocalMode)
            ListTile(
              leading: const Icon(Icons.cloud_off_outlined),
              title: Text(l10n.privacyDeleteAllCloud),
              onTap: () async {
                if (await _confirm(
                  context,
                  l10n.privacyDeleteAllCloud,
                  l10n.privacyDeleteAllCloudConfirm,
                )) {
                  final remote = ref.read(remoteTripDataSourceProvider);
                  final userId = auth.user?.id;
                  if (remote != null && userId != null) {
                    try {
                      await remote.deleteAllUserData(userId);
                      toast(l10n.privacyDataDeleted);
                    } catch (e) {
                      toast(l10n.errorSupabaseUnavailable);
                    }
                  }
                }
              },
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.authLogout),
            onTap: () async {
              final userId = auth.user?.id;
              var warning = '';
              if (userId != null && !auth.isLocalMode) {
                final hasUnsynced = await ref
                    .read(localTripDataSourceProvider)
                    .hasUnsyncedData(userId);
                if (hasUnsynced) warning = l10n.authLogoutUnsyncedWarning;
              }
              if (!context.mounted) return;
              final message = warning.isEmpty ? l10n.authLogout : warning;
              if (await _confirm(context, l10n.authLogout, message)) {
                await ref.read(authControllerProvider.notifier).signOut();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}
