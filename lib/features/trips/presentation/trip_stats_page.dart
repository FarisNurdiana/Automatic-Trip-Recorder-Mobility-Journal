import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/fuel_estimator.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../domain/trip_csv_exporter.dart';

/// Monthly recap of all finished trips: distance, count, time on the road,
/// and estimated fuel cost — plus a CSV export for claims/bookkeeping.
class TripStatsPage extends ConsumerWidget {
  const TripStatsPage({super.key});

  Future<void> _exportCsv(
    BuildContext context,
    WidgetRef ref,
    List<Trip> trips,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final profile = ref.read(settingsControllerProvider).fuelProfile;
      final csv = const TripCsvExporter().build(trips, profile: profile);
      final dir = await getTemporaryDirectory();
      final stamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      final file = File(p.join(dir.path, 'ruteku_rekap_$stamp.csv'));
      await file.writeAsString('﻿$csv');
      await Share.shareXFiles([XFile(file.path, mimeType: 'text/csv')]);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final trips = ref.watch(tripsStreamProvider);
    final profile = ref.watch(settingsControllerProvider).fuelProfile;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statsTitle)),
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
              icon: Icons.insert_chart_outlined,
            );
          }
          final months = _groupByMonth(finished, profile);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FilledButton.icon(
                onPressed: () => _exportCsv(context, ref, finished),
                icon: const Icon(Icons.table_view_outlined),
                label: Text(l10n.statsExportCsv),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.statsExportCsvDesc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              for (final month in months) ...[
                _MonthCard(month: month, locale: locale),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }

  List<_MonthStats> _groupByMonth(List<Trip> trips, FuelProfile profile) {
    final map = <String, _MonthStats>{};
    for (final trip in trips) {
      final local = trip.startedAt.toLocal();
      final key = '${local.year}-${local.month}';
      final stats = map.putIfAbsent(
        key,
        () => _MonthStats(DateTime(local.year, local.month)),
      );
      stats.trips += 1;
      stats.meters += trip.distanceMeters;
      stats.seconds += trip.elapsedDurationSeconds;
      final fuel = estimateFuel(
        distanceMeters: trip.distanceMeters,
        vehicleType: VehicleType.fromName(
          trip.confirmedVehicleType ?? trip.detectedVehicleType,
        ),
        profile: profile,
      );
      if (fuel != null) {
        stats.fuelLiters += fuel.liters;
        if (fuel.cost != null) stats.fuelCost += fuel.cost!;
      }
    }
    final months = map.values.toList()
      ..sort((a, b) => b.month.compareTo(a.month));
    return months;
  }
}

class _MonthStats {
  _MonthStats(this.month);

  final DateTime month;
  int trips = 0;
  double meters = 0;
  int seconds = 0;
  double fuelLiters = 0;
  double fuelCost = 0;
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({required this.month, required this.locale});

  final _MonthStats month;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final title = DateFormat('MMMM y', locale).format(month.month);

    Widget cell(String label, String value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                cell(l10n.homeTripCount, '${month.trips}'),
                cell(
                  l10n.tripDistance,
                  Formatters.distanceKm(month.meters, locale: locale),
                ),
                cell(
                  l10n.tripDuration,
                  Formatters.duration(
                    Duration(seconds: month.seconds),
                    locale: locale,
                  ),
                ),
              ],
            ),
            if (month.fuelLiters > 0) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  cell(
                    l10n.fuelEstimateLabel,
                    '≈ ${month.fuelLiters.toStringAsFixed(1).replaceAll('.', ',')} L',
                  ),
                  cell(
                    l10n.fuelCostLabel,
                    month.fuelCost > 0
                        ? '≈ Rp ${_rupiah(month.fuelCost)}'
                        : '—',
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _rupiah(double amount) {
    final digits = amount.round().toString();
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
      out.write(digits[i]);
    }
    return out.toString();
  }
}
