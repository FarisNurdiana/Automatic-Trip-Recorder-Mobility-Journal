import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';

/// Live overview of every permission the app needs, with request shortcuts.
class PermissionDiagnosticsPage extends ConsumerWidget {
  const PermissionDiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final snapshot = ref.watch(permissionsSnapshotProvider);
    final service = ref.read(permissionsServiceProvider);

    Future<void> refresh() async => ref.invalidate(permissionsSnapshotProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsPermissions)),
      body: snapshot.when(
        loading: () => LoadingView(message: l10n.commonLoading),
        error: (e, _) => ErrorView(message: l10n.commonError, onRetry: refresh),
        data: (p) => RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Why all of this matters: without "allow all the time" and
              // the exemptions below, background auto-start silently fails.
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.tips_and_updates_outlined,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.permGuideIntro,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _PermissionRow(
                title: l10n.permLocation,
                description: l10n.permLocationDesc,
                granted: p.location,
                grantedLabel: l10n.permGranted,
                deniedLabel: l10n.permDenied,
                requestLabel: l10n.permRequest,
                onRequest: () async {
                  await service.requestLocation();
                  await refresh();
                },
              ),
              _PermissionRow(
                title: l10n.permBackgroundLocation,
                description: l10n.permBackgroundLocationDesc,
                granted: p.backgroundLocation,
                grantedLabel: l10n.permGranted,
                deniedLabel: l10n.permDenied,
                requestLabel: l10n.permRequest,
                onRequest: () async {
                  await service.requestBackgroundLocation();
                  await refresh();
                },
              ),
              _PermissionRow(
                title: l10n.permActivityRecognition,
                description: l10n.permActivityRecognitionDesc,
                granted: p.activityRecognition,
                grantedLabel: l10n.permGranted,
                deniedLabel: l10n.permDenied,
                requestLabel: l10n.permRequest,
                onRequest: () async {
                  await service.requestActivityRecognition();
                  await refresh();
                },
              ),
              _PermissionRow(
                title: l10n.permMotionFitness,
                description: l10n.permMotionFitnessDesc,
                granted: p.motionFitness,
                grantedLabel: l10n.permGranted,
                deniedLabel: l10n.permDenied,
                requestLabel: l10n.permRequest,
                onRequest: () async {
                  await service.requestMotionFitness();
                  await refresh();
                },
              ),
              _PermissionRow(
                title: l10n.permNotifications,
                description: l10n.permNotificationsDesc,
                granted: p.notifications,
                grantedLabel: l10n.permGranted,
                deniedLabel: l10n.permDenied,
                requestLabel: l10n.permRequest,
                onRequest: () async {
                  await service.requestNotifications();
                  await refresh();
                },
              ),
              _PermissionRow(
                title: l10n.permBatteryOptimization,
                description: l10n.permBatteryOptimizationDesc,
                granted: p.batteryOptimizationExempt,
                grantedLabel: l10n.permActive,
                deniedLabel: l10n.permInactive,
                requestLabel: l10n.permRequest,
                onRequest: () async {
                  await service.requestBatteryOptimizationExemption();
                  await refresh();
                },
              ),
              if (!kIsWeb && Platform.isAndroid) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.rocket_launch_outlined),
                    title: Text(
                      l10n.permAutostartTitle(
                        ref
                                .watch(deviceMetadataProvider)
                                .deviceModel
                                ?.split(' ')
                                .first ??
                            'Android',
                      ),
                    ),
                    subtitle: Text(l10n.permAutostartDesc),
                    isThreeLine: true,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: service.openSettings,
                icon: const Icon(Icons.settings),
                label: Text(l10n.permOpenSettings),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.title,
    required this.description,
    required this.granted,
    required this.grantedLabel,
    required this.deniedLabel,
    required this.requestLabel,
    required this.onRequest,
  });

  final String title;
  final String description;
  final bool granted;
  final String grantedLabel;
  final String deniedLabel;
  final String requestLabel;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Icon(
          granted ? Icons.check_circle : Icons.cancel_outlined,
          color: granted ? Colors.green : scheme.error,
        ),
        title: Text(title),
        subtitle: Text('$description\n${granted ? grantedLabel : deniedLabel}'),
        isThreeLine: true,
        trailing: granted
            ? null
            : TextButton(onPressed: onRequest, child: Text(requestLabel)),
      ),
    );
  }
}
