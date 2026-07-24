import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import 'widgets/vehicle_ui.dart';

class TripHistoryPage extends ConsumerWidget {
  const TripHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final trips = ref.watch(tripsStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.historyTitle)),
      body: trips.when(
        loading: () => LoadingView(message: l10n.commonLoading),
        error: (e, _) => ErrorView(message: l10n.commonError),
        data: (list) {
          final finished = list
              .where((t) => t.status == TripRecordingState.finished.name)
              .toList();
          if (finished.isEmpty) {
            return EmptyStateView(
              message: l10n.historyEmpty,
              icon: Icons.route_outlined,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: finished.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _TripCard(trip: finished[index], locale: locale),
          );
        },
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.locale});

  final Trip trip;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final vehicle = VehicleType.fromName(
      trip.confirmedVehicleType ?? trip.detectedVehicleType,
    );
    final syncStatus = SyncStatus.fromName(trip.syncStatus);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/trips/${trip.id}'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 21,
                    backgroundColor: scheme.secondaryContainer,
                    child: Icon(
                      vehicleIcon(vehicle),
                      size: 22,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.dateTime(trip.startedAt, locale: locale),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          vehicleLabel(l10n, vehicle),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    switch (syncStatus) {
                      SyncStatus.synced => Icons.cloud_done_outlined,
                      SyncStatus.syncing => Icons.cloud_sync_outlined,
                      SyncStatus.failed => Icons.cloud_off_outlined,
                      SyncStatus.pending => Icons.cloud_upload_outlined,
                    },
                    size: 18,
                    color: syncStatus == SyncStatus.failed
                        ? scheme.error
                        : scheme.outline,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MetricChip(
                    icon: Icons.straighten,
                    value: Formatters.distanceKm(
                      trip.distanceMeters,
                      locale: locale,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MetricChip(
                    icon: Icons.schedule,
                    value: Formatters.duration(
                      Duration(seconds: trip.elapsedDurationSeconds),
                      locale: locale,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MetricChip(
                    icon: Icons.speed,
                    value: Formatters.speedKmh(
                      trip.averageSpeedKmh,
                      locale: locale,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 5),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
