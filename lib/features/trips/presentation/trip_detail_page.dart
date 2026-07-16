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
import '../../../core/utils/polyline_simplifier.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../domain/gps_point_filter.dart';
import '../domain/trip_summary_calculator.dart';

/// Everything the detail page needs, loaded once.
class TripDetailData {
  const TripDetailData({
    required this.trip,
    required this.rawPoints,
    required this.displayPoints,
    required this.stops,
  });

  final Trip trip;
  final List<RecordedLocation> rawPoints;

  /// Simplified for rendering — raw points stay in the database untouched.
  final List<LatLng> displayPoints;
  final List<TripStop> stops;
}

final tripDetailProvider =
    FutureProvider.family<TripDetailData?, String>((ref, tripId) async {
  final repo = ref.watch(tripRepositoryProvider);
  final trip = await repo.getTrip(tripId);
  if (trip == null) return null;
  final raw = await repo.pointsForTrip(tripId);
  final filtered = GpsPointFilter().filter(raw);
  final simplified = PolylineSimplifier.simplify([
    for (final p in filtered.accepted) SimplePoint(p.latitude, p.longitude),
  ]);
  final summary = DefaultTripSummaryCalculator().calculate(raw);
  return TripDetailData(
    trip: trip,
    rawPoints: filtered.accepted,
    displayPoints: [
      for (final p in simplified) LatLng(p.latitude, p.longitude),
    ],
    stops: summary?.stops ?? const [],
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

  void _fitRoute(List<LatLng> points) {
    if (points.length < 2) return;
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.all(40),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final detail = ref.watch(tripDetailProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripCurrentTitle),
        actions: [
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

  Widget _buildDetail(
    BuildContext context,
    AppLocalizations l10n,
    String locale,
    TripDetailData data,
  ) {
    final trip = data.trip;
    final points = data.displayPoints;
    final vehicle =
        VehicleType.fromName(trip.confirmedVehicleType ?? trip.detectedVehicleType);

    return ListView(
      children: [
        // --- map ---
        SizedBox(
          height: 300,
          child: points.isEmpty
              ? EmptyStateView(message: l10n.tripNoPoints, icon: Icons.map)
              : Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCameraFit: points.length >= 2
                            ? CameraFit.coordinates(
                                coordinates: points,
                                padding: const EdgeInsets.all(40),
                              )
                            : null,
                        initialCenter:
                            points.isNotEmpty ? points.first : const LatLng(0, 0),
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.triplog.triplog',
                        ),
                        PolylineLayer(polylines: [
                          Polyline(
                            points: points,
                            strokeWidth: 4,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ]),
                        MarkerLayer(markers: [
                          if (points.isNotEmpty)
                            Marker(
                              point: points.first,
                              child: const Icon(Icons.trip_origin,
                                  color: Colors.green),
                            ),
                          if (points.length > 1)
                            Marker(
                              point: points.last,
                              child:
                                  const Icon(Icons.flag, color: Colors.red),
                            ),
                          for (final stop in data.stops)
                            Marker(
                              point: LatLng(stop.latitude, stop.longitude),
                              child: const Icon(Icons.local_parking,
                                  size: 20, color: Colors.orange),
                            ),
                        ]),
                        RichAttributionWidget(attributions: [
                          TextSourceAttribution('OpenStreetMap contributors'),
                        ]),
                      ],
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FloatingActionButton.small(
                        heroTag: 'fit',
                        tooltip: l10n.tripFitRoute,
                        onPressed: () => _fitRoute(points),
                        child: const Icon(Icons.fit_screen),
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
              Row(children: [
                Expanded(
                  child: StatTile(
                    label: l10n.tripDistance,
                    icon: Icons.straighten,
                    value: Formatters.distanceKm(trip.distanceMeters,
                        locale: locale),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    label: l10n.tripDuration,
                    icon: Icons.schedule,
                    value: Formatters.duration(
                        Duration(seconds: trip.elapsedDurationSeconds),
                        locale: locale),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: StatTile(
                    label: l10n.tripMovingTime,
                    icon: Icons.play_arrow,
                    value: Formatters.duration(
                        Duration(seconds: trip.movingDurationSeconds),
                        locale: locale),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    label: l10n.tripStoppedTime,
                    icon: Icons.pause,
                    value: Formatters.duration(
                        Duration(seconds: trip.stoppedDurationSeconds),
                        locale: locale),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: StatTile(
                    label: l10n.tripAvgSpeed,
                    icon: Icons.speed,
                    value: Formatters.speedKmh(trip.averageSpeedKmh,
                        locale: locale),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: StatTile(
                    label: l10n.tripMovingAvgSpeed,
                    icon: Icons.shutter_speed,
                    value: Formatters.speedKmh(trip.movingAverageSpeedKmh,
                        locale: locale),
                  ),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: StatTile(
                    label: l10n.tripMaxSpeed,
                    icon: Icons.rocket_launch_outlined,
                    value: Formatters.speedKmh(trip.maximumSpeedKmh,
                        locale: locale),
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
              ]),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(
                      '${l10n.tripDeparture}: ${Formatters.dateTime(trip.startedAt, locale: locale)}'),
                  subtitle: trip.endedAt == null
                      ? null
                      : Text(
                          '${l10n.tripArrival}: ${Formatters.dateTime(trip.endedAt!, locale: locale)}'),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_car_outlined),
                  title: Text(_vehicleLabel(l10n, vehicle)),
                  subtitle: trip.vehicleConfidence == null
                      ? null
                      : Text(l10n.vehicleConfidence(
                          (trip.vehicleConfidence! * 100).toStringAsFixed(0))),
                  trailing: TextButton(
                    onPressed: () =>
                        context.push('/trips/${trip.id}/confirm-vehicle'),
                    child: Text(l10n.vehicleConfirmTitle),
                  ),
                ),
              ),

              // --- stops list ---
              if (data.stops.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('${l10n.tripStops} (${data.stops.length})',
                    style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                for (final stop in data.stops)
                  Card(
                    child: ListTile(
                      dense: true,
                      leading: const Icon(Icons.local_parking,
                          color: Colors.orange),
                      title: Text(
                          '${Formatters.time(stop.startedAt, locale: locale)} - ${Formatters.time(stop.endedAt, locale: locale)}'),
                      subtitle: Text(Formatters.duration(stop.duration,
                          locale: locale)),
                    ),
                  ),
              ],

              // --- speed chart ---
              if (data.rawPoints.length >= 5) ...[
                const SizedBox(height: 16),
                Text(l10n.tripSpeedChart,
                    style: Theme.of(context).textTheme.titleSmall),
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

  String _vehicleLabel(AppLocalizations l10n, VehicleType type) =>
      switch (type) {
        VehicleType.car => l10n.vehicleCar,
        VehicleType.motorcycle => l10n.vehicleMotorcycle,
        VehicleType.bus => l10n.vehicleBus,
        VehicleType.truck => l10n.vehicleTruck,
        VehicleType.train => l10n.vehicleTrain,
        VehicleType.other => l10n.vehicleOther,
        VehicleType.unknown => l10n.vehicleUnknown,
      };
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
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text('${v.toInt()}',
                    style: Theme.of(context).textTheme.labelSmall),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                getTitlesWidget: (v, _) => Text('${v.toInt()}m',
                    style: Theme.of(context).textTheme.labelSmall),
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
