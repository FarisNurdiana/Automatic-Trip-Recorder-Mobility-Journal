import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';

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
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final t = finished[index];
              final vehicle = VehicleType.fromName(
                  t.confirmedVehicleType ?? t.detectedVehicleType);
              final syncStatus = SyncStatus.fromName(t.syncStatus);
              return Card(
                child: ListTile(
                  leading: Icon(switch (vehicle) {
                    VehicleType.car => Icons.directions_car,
                    VehicleType.motorcycle => Icons.two_wheeler,
                    VehicleType.bus => Icons.directions_bus,
                    VehicleType.truck => Icons.local_shipping,
                    VehicleType.train => Icons.train,
                    _ => Icons.route,
                  }),
                  title:
                      Text(Formatters.dateTime(t.startedAt, locale: locale)),
                  subtitle: Text(
                    '${Formatters.distanceKm(t.distanceMeters, locale: locale)} • '
                    '${Formatters.duration(Duration(seconds: t.elapsedDurationSeconds), locale: locale)} • '
                    '${Formatters.speedKmh(t.averageSpeedKmh, locale: locale)}',
                  ),
                  trailing: Icon(
                    switch (syncStatus) {
                      SyncStatus.synced => Icons.cloud_done_outlined,
                      SyncStatus.syncing => Icons.cloud_sync_outlined,
                      SyncStatus.failed => Icons.cloud_off_outlined,
                      SyncStatus.pending => Icons.cloud_upload_outlined,
                    },
                    size: 20,
                    color: syncStatus == SyncStatus.failed
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.outline,
                  ),
                  onTap: () => context.push('/trips/${t.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
