import 'dart:async';

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
      appBar: AppBar(
        title: Text(l10n.historyTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.insert_chart_outlined),
            tooltip: l10n.statsTitle,
            onPressed: () => context.push('/stats'),
          ),
        ],
      ),
      body: trips.when(
        loading: () => LoadingView(message: l10n.commonLoading),
        error: (e, _) => ErrorView(message: l10n.commonError),
        data: (list) {
          final finished = list
              .where((t) => t.status == TripRecordingState.finished.name)
              .toList();
          // Backfill missing place labels for the most recent trips (best
          // effort, serialized, deduped inside the resolver).
          final resolver = ref.read(tripAddressResolverProvider);
          for (final t
              in finished
                  .where((t) => t.startAddress == null || t.endAddress == null)
                  .take(5)) {
            unawaited(resolver.ensure(t));
          }
          if (finished.isEmpty) {
            return EmptyStateView(
              message: l10n.historyEmpty,
              icon: Icons.route_outlined,
            );
          }
          final now = DateTime.now();
          final thisMonth = finished
              .where(
                (t) =>
                    t.startedAt.toLocal().year == now.year &&
                    t.startedAt.toLocal().month == now.month,
              )
              .toList();
          final monthMeters = thisMonth.fold<double>(
            0,
            (sum, t) => sum + t.distanceMeters,
          );
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: finished.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _MonthSummaryCard(
                  distanceLabel: Formatters.distanceKm(
                    monthMeters,
                    locale: locale,
                  ),
                  tripsLabel: l10n.historyTripsCount(thisMonth.length),
                );
              }
              return _TripCard(trip: finished[index - 1], locale: locale);
            },
          );
        },
      ),
    );
  }
}

/// Gradient banner summarizing the current month.
class _MonthSummaryCard extends StatelessWidget {
  const _MonthSummaryCard({
    required this.distanceLabel,
    required this.tripsLabel,
  });

  final String distanceLabel;
  final String tripsLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.55)!,
          ],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_month, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.historyThisMonth,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$distanceLabel • $tripsLabel',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  const _TripCard({required this.trip, required this.locale});

  final Trip trip;
  final String locale;

  /// "Jl. A, Gedebage" + "Jl. B, Cimahi" -> "Jl. A → Jl. B"; null while
  /// either address is still unknown.
  String? _routeLabel(Trip t) {
    final start = t.startAddress?.split(',').first.trim();
    final end = t.endAddress?.split(',').first.trim();
    if (start == null || start.isEmpty || end == null || end.isEmpty) {
      return null;
    }
    return '$start → $end';
  }

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
                          _routeLabel(trip) ??
                              Formatters.dateTime(
                                trip.startedAt,
                                locale: locale,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _routeLabel(trip) == null
                              ? vehicleLabel(l10n, vehicle)
                              : '${Formatters.dateTime(trip.startedAt, locale: locale)} • '
                                    '${vehicleLabel(l10n, vehicle)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
