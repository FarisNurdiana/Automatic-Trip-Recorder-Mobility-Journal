import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../../recording/presentation/state_labels.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  String _stateLabel(AppLocalizations l10n, TripRecordingState state) =>
      tripStateLabel(l10n, state);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final recording = ref.watch(tripRecordingControllerProvider);
    final trips = ref.watch(tripsStreamProvider);
    final totals = ref.watch(tripTotalsProvider);
    final permissions = ref.watch(permissionsSnapshotProvider);
    final syncState = ref.watch(syncStateProvider);
    final auth = ref.watch(authControllerProvider);

    final isActive = recording.machineState.isActiveTrip;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(permissionsSnapshotProvider);
          ref.invalidate(tripTotalsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- detection status ---
            Card(
              color: isActive
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeDetectionStatus,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          isActive ? Icons.radio_button_checked : Icons.radar,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _stateLabel(l10n, recording.machineState),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (isActive)
                      FilledButton.icon(
                        onPressed: () => context.push('/current-trip'),
                        icon: const Icon(Icons.navigation),
                        label: Text(l10n.tripCurrentTitle),
                      )
                    else
                      FilledButton.icon(
                        onPressed: () async {
                          await ref
                              .read(tripRecordingControllerProvider.notifier)
                              .startManual();
                          if (context.mounted) context.push('/current-trip');
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: Text(l10n.homeStartTrip),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // --- totals ---
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: l10n.homeTotalDistance,
                    icon: Icons.straighten,
                    value: totals.maybeWhen(
                      data: (t) => Formatters.distanceKm(t.$2, locale: locale),
                      orElse: () => '—',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: l10n.homeTripCount,
                    icon: Icons.map_outlined,
                    value: totals.maybeWhen(
                      data: (t) => '${t.$1}',
                      orElse: () => '—',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- last trip ---
            Text(
              l10n.homeLastTrip,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            trips.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(message: l10n.commonError),
              data: (list) {
                final finished = list
                    .where((t) => t.status == TripRecordingState.finished.name)
                    .toList();
                if (finished.isEmpty) {
                  return EmptyStateView(
                    message: l10n.homeNoTrips,
                    icon: Icons.route_outlined,
                  );
                }
                final t = finished.first;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.directions_car_outlined),
                    title: Text(
                      Formatters.dateTime(t.startedAt, locale: locale),
                    ),
                    subtitle: Text(
                      '${Formatters.distanceKm(t.distanceMeters, locale: locale)} • '
                      '${Formatters.duration(Duration(seconds: t.elapsedDurationSeconds), locale: locale)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/trips/${t.id}'),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // --- permission status ---
            Card(
              child: ListTile(
                leading: permissions.maybeWhen(
                  data: (p) => Icon(
                    p.allCoreGranted
                        ? Icons.verified_user
                        : Icons.gpp_maybe_outlined,
                    color: p.allCoreGranted
                        ? Colors.green
                        : Theme.of(context).colorScheme.error,
                  ),
                  orElse: () => const Icon(Icons.verified_user_outlined),
                ),
                title: Text(l10n.homePermissions),
                subtitle: permissions.maybeWhen(
                  data: (p) => Text(
                    p.allCoreGranted
                        ? l10n.homePermissionsComplete
                        : l10n.homePermissionsIncomplete,
                  ),
                  orElse: () => Text(l10n.commonLoading),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/permissions'),
              ),
            ),
            const SizedBox(height: 12),

            // --- sync status ---
            Card(
              child: ListTile(
                leading: const Icon(Icons.sync),
                title: Text(l10n.homeSyncStatus),
                subtitle: Text(
                  auth.isLocalMode
                      ? l10n.syncLocalOnly
                      : syncState.maybeWhen(
                          data: (s) => switch (s.status) {
                            SyncStatus.pending => l10n.syncPending,
                            SyncStatus.syncing =>
                              '${l10n.syncSyncing} (${s.pendingTrips})',
                            SyncStatus.synced => l10n.syncSynced,
                            SyncStatus.failed => l10n.syncFailed,
                          },
                          orElse: () => l10n.syncSynced,
                        ),
                ),
                trailing: auth.isLocalMode
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: l10n.syncNow,
                        onPressed: () {
                          final userId = auth.user?.id;
                          final sync = ref.read(syncServiceProvider);
                          if (userId != null && sync != null) {
                            sync.syncNow(userId);
                          }
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () => context.push('/trips'),
              icon: const Icon(Icons.history),
              label: Text(l10n.historyTitle),
            ),
          ],
        ),
      ),
    );
  }
}
