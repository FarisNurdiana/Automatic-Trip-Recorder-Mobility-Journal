import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/location/location_models.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/fuel_estimator.dart';
import '../../../core/utils/polyline_simplifier.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../domain/congestion_estimator.dart';
import '../domain/gps_point_filter.dart';
import 'share/trip_share_sheet.dart';
import 'widgets/trip_map.dart';
import 'widgets/vehicle_ui.dart';

/// Everything the detail page needs, loaded once.
class TripDetailData {
  const TripDetailData({
    required this.trip,
    required this.rawPoints,
    required this.displayPoints,
    required this.stopRows,
  });

  final Trip trip;
  final List<RecordedLocation> rawPoints;

  /// Smoothed + simplified for rendering — raw points stay in the database.
  final List<LatLng> displayPoints;

  /// Persisted stops (labelable by the user).
  final List<TripStop> stopRows;
}

final tripDetailProvider = FutureProvider.family<TripDetailData?, String>((
  ref,
  tripId,
) async {
  final repo = ref.watch(tripRepositoryProvider);
  final trip = await repo.getTrip(tripId);
  if (trip == null) return null;
  if (trip.startAddress == null || trip.endAddress == null) {
    // Backfill place labels in the background; visible on the next open.
    unawaited(ref.read(tripAddressResolverProvider).ensure(trip));
  }
  final raw = await repo.pointsForTrip(tripId);
  final filtered = GpsPointFilter().filter(raw);
  final display = PolylineSimplifier.simplify(
    PolylineSimplifier.smooth([
      for (final p in filtered.accepted) SimplePoint(p.latitude, p.longitude),
    ]),
  );
  final stops = await repo.stopsForTrip(tripId);
  return TripDetailData(
    trip: trip,
    rawPoints: filtered.accepted,
    displayPoints: [for (final p in display) LatLng(p.latitude, p.longitude)],
    stopRows: stops,
  );
});

class TripDetailPage extends ConsumerStatefulWidget {
  const TripDetailPage({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TripDetailPage> createState() => _TripDetailPageState();
}

class _TripDetailPageState extends ConsumerState<TripDetailPage> {
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final detail = ref.watch(tripDetailProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.shareTripTitle,
            onPressed: detail.valueOrNull == null
                ? null
                : () => showTripShareSheet(
                    context,
                    detail.valueOrNull!,
                    user: ref.read(authControllerProvider).user,
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: detail.when(
        loading: () => LoadingView(message: l10n.commonLoading),
        error: (e, _) => ErrorView(message: l10n.commonError),
        data: (data) {
          if (data == null) {
            return EmptyStateView(message: l10n.commonEmpty);
          }
          return _buildDetail(context, l10n, locale, data);
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.privacyDeleteTrip),
        content: Text(l10n.privacyDeleteTripConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(tripRepositoryProvider).deleteTrip(widget.tripId);
      if (mounted && context.mounted) context.pop();
    }
  }

  Future<void> _openFullscreenMap(TripDetailData data) async {
    final result = await context.push<Object?>('/trips/${widget.tripId}/map');
    if (result == 'share' && mounted) {
      await showTripShareSheet(
        context,
        data,
        user: ref.read(authControllerProvider).user,
      );
    }
  }

  Future<void> _correctArrival(TripDetailData data) async {
    final l10n = AppLocalizations.of(context);
    final trip = data.trip;
    final initial = trip.endedAt ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initial.toLocal(),
      firstDate: trip.startedAt.toLocal().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (pickedDate == null || !mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial.toLocal()),
    );
    if (pickedTime == null || !mounted) return;
    final arrival = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );
    await ref
        .read(tripRepositoryProvider)
        .correctArrivalTime(widget.tripId, arrival.toUtc());
    ref.invalidate(tripDetailProvider(widget.tripId));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.arrivalUpdated)));
    }
  }

  /// "0.126" L -> "0,13"; "1.5" -> "1,50".
  static String _liters(double liters) =>
      liters.toStringAsFixed(2).replaceAll('.', ',');

  /// Rounded rupiah with thousands dots: 15250.4 -> "15.250".
  static String _rupiah(double amount) {
    final digits = amount.round().toString();
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) out.write('.');
      out.write(digits[i]);
    }
    return out.toString();
  }

  Widget _buildDetail(
    BuildContext context,
    AppLocalizations l10n,
    String locale,
    TripDetailData data,
  ) {
    final trip = data.trip;
    final points = data.displayPoints;
    final vehicle = VehicleType.fromName(
      trip.confirmedVehicleType ?? trip.detectedVehicleType,
    );
    // Fuel estimate from the user's own km/L figure (null when not set for
    // this vehicle type — nothing is guessed).
    final fuel = estimateFuel(
      distanceMeters: trip.distanceMeters,
      vehicleType: vehicle,
      profile: ref.watch(settingsControllerProvider).fuelProfile,
    );
    // Crawling time (3–15 km/h): a rule-based congestion indication.
    final congestion = const CongestionEstimator().estimate(data.rawPoints);

    return ListView(
      children: [
        // --- map preview with expand-to-fullscreen ---
        SizedBox(
          height: 300,
          child: points.isEmpty
              ? EmptyStateView(message: l10n.tripNoPoints, icon: Icons.map)
              : Stack(
                  children: [
                    TripMap(
                      controller: _mapController,
                      points: points,
                      stops: data.stopRows,
                    ),
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Material(
                        color: Theme.of(context).colorScheme.primary,
                        shape: const CircleBorder(),
                        elevation: 3,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => _openFullscreenMap(data),
                          child: Tooltip(
                            message: l10n.mapOpenFullscreen,
                            child: SizedBox(
                              width: 44,
                              height: 44,
                              child: Icon(
                                Icons.open_in_full,
                                size: 22,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),

        // --- stats ---
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: l10n.tripDistance,
                      icon: Icons.straighten,
                      value: Formatters.distanceKm(
                        trip.distanceMeters,
                        locale: locale,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: l10n.tripDuration,
                      icon: Icons.schedule,
                      value: Formatters.duration(
                        Duration(seconds: trip.elapsedDurationSeconds),
                        locale: locale,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: l10n.tripMovingTime,
                      icon: Icons.play_arrow,
                      value: Formatters.duration(
                        Duration(seconds: trip.movingDurationSeconds),
                        locale: locale,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: l10n.tripStoppedTime,
                      icon: Icons.pause,
                      value: Formatters.duration(
                        Duration(seconds: trip.stoppedDurationSeconds),
                        locale: locale,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: l10n.tripAvgSpeed,
                      icon: Icons.speed,
                      value: Formatters.speedKmh(
                        trip.averageSpeedKmh,
                        locale: locale,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: l10n.tripMovingAvgSpeed,
                      icon: Icons.shutter_speed,
                      value: Formatters.speedKmh(
                        trip.movingAverageSpeedKmh,
                        locale: locale,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: l10n.tripMaxSpeed,
                      icon: Icons.rocket_launch_outlined,
                      value: Formatters.speedKmh(
                        trip.maximumSpeedKmh,
                        locale: locale,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatTile(
                      label: l10n.tripPoints,
                      icon: Icons.timeline,
                      value: '${data.rawPoints.length}',
                    ),
                  ),
                ],
              ),
              if (fuel != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: l10n.fuelEstimateLabel,
                        icon: Icons.local_gas_station_outlined,
                        value: '≈ ${_liters(fuel.liters)} L',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: fuel.cost == null
                          ? const SizedBox.shrink()
                          : StatTile(
                              label: l10n.fuelCostLabel,
                              icon: Icons.payments_outlined,
                              value: '≈ Rp ${_rupiah(fuel.cost!)}',
                            ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    l10n.fuelEstimateNote,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              if (congestion.inMinutes >= 2) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        label: l10n.congestionLabel,
                        icon: Icons.traffic_outlined,
                        value: Formatters.duration(congestion, locale: locale),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    l10n.congestionNote,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Where the trip went: "area A → area B" once the reverse
              // geocoder has filled the labels.
              if (trip.startAddress != null && trip.endAddress != null) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.place_outlined),
                    title: Text(
                      l10n.tripFromTo(trip.startAddress!, trip.endAddress!),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(
                    '${l10n.tripDeparture}: '
                    '${Formatters.dateTime(trip.startedAt, locale: locale)}',
                  ),
                  subtitle: trip.endedAt == null
                      ? null
                      : Text(
                          '${l10n.tripArrival}: '
                          '${Formatters.dateTime(trip.endedAt!, locale: locale)}'
                          '${trip.finishedAutomatically ? '\n${l10n.finishedAutomaticallyBadge}' : ''}',
                        ),
                  isThreeLine: trip.finishedAutomatically,
                  trailing: trip.finishedAutomatically
                      ? IconButton(
                          icon: const Icon(Icons.edit_calendar_outlined),
                          tooltip: l10n.editArrivalTime,
                          onPressed: () => _correctArrival(data),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: Icon(vehicleIcon(vehicle)),
                  title: Text(vehicleLabel(l10n, vehicle)),
                  subtitle: trip.vehicleConfidence == null
                      ? null
                      : Text(
                          l10n.vehicleConfidenceLabel(
                            (trip.vehicleConfidence! * 100).toStringAsFixed(0),
                          ),
                        ),
                  trailing: TextButton(
                    onPressed: () =>
                        context.push('/trips/${trip.id}/confirm-vehicle'),
                    child: Text(l10n.vehicleConfirmTitle),
                  ),
                ),
              ),

              // --- stops list ---
              if (data.stopRows.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${l10n.tripStops} (${data.stopRows.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                for (final stop in data.stopRows)
                  Card(
                    child: ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.local_parking,
                        color: Colors.orange,
                      ),
                      title: Text(
                        '${Formatters.time(stop.arrivalTime, locale: locale)}'
                        '${stop.departureTime != null ? ' - ${Formatters.time(stop.departureTime!, locale: locale)}' : ''}',
                      ),
                      subtitle: Text(
                        '${Formatters.duration(Duration(seconds: stop.durationSeconds), locale: locale)}'
                        ' • ${_stopTypeLabel(l10n, stop)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openFullscreenMap(data),
                    ),
                  ),
              ],

              // --- speed chart ---
              if (data.rawPoints.length >= 5) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.tripSpeedChart,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 180,
                  child: _SpeedChart(points: data.rawPoints),
                ),
              ],
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  String _stopTypeLabel(AppLocalizations l10n, TripStop stop) {
    if (!stop.confirmedByUser) return l10n.stopUnconfirmed;
    return switch (StopType.fromName(stop.stopType)) {
      StopType.rest => l10n.stopTypeRest,
      StopType.parking => l10n.stopTypeParking,
      StopType.food => l10n.stopTypeFood,
      StopType.fuel => l10n.stopTypeFuel,
      StopType.visit => l10n.stopTypeVisit,
      StopType.traffic => l10n.stopTypeTraffic,
      StopType.destination => l10n.stopTypeDestination,
      StopType.other => l10n.stopTypeOther,
      StopType.unconfirmed => l10n.stopUnconfirmed,
    };
  }
}

class _SpeedChart extends StatelessWidget {
  const _SpeedChart({required this.points});

  final List<RecordedLocation> points;

  @override
  Widget build(BuildContext context) {
    final start = points.first.recordedAt;
    // Downsample for the chart when there are thousands of points.
    final step = (points.length / 300).ceil().clamp(1, 1 << 30);
    final spots = <FlSpot>[
      for (var i = 0; i < points.length; i += step)
        if (points[i].speedKmh != null)
          FlSpot(
            points[i].recordedAt.difference(start).inSeconds / 60.0,
            points[i].speedKmh!,
          ),
    ];
    if (spots.length < 2) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: LineChart(
        LineChartData(
          lineTouchData: const LineTouchData(enabled: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}m',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: false,
              dotData: const FlDotData(show: false),
              color: scheme.primary,
              barWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
