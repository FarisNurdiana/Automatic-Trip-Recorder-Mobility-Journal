import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/route_playback.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import 'trip_detail_page.dart';
import 'widgets/trip_map.dart';

/// "Peta perjalanan" — near-full-screen map with the complete route, all
/// markers, tappable stops (bottom sheet with details + labeling), fit/zoom/
/// recenter controls and share access. Statistics stay off this page so the
/// map keeps the whole screen.
class TripMapPage extends ConsumerStatefulWidget {
  const TripMapPage({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<TripMapPage> createState() => _TripMapPageState();
}

class _TripMapPageState extends ConsumerState<TripMapPage>
    with SingleTickerProviderStateMixin {
  final _mapController = MapController();

  /// Non-null while the A→B trip animation is running.
  RoutePlayback? _playback;
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _anim,
    curve: Curves.easeInOutSine,
  );

  @override
  void initState() {
    super.initState();
    _anim.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        // Hold the finished frame briefly, then return to the normal view.
        Future<void>.delayed(const Duration(milliseconds: 900)).then((_) {
          if (mounted) {
            setState(() => _playback = null);
            _anim.reset();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _curved.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _togglePlayback(List<LatLng> points) {
    if (_playback != null) {
      _anim.stop();
      _anim.reset();
      setState(() => _playback = null);
      return;
    }
    final playback = RoutePlayback(points);
    if (!playback.canPlay) return;
    // Longer routes get a bit more time on screen (8–18 s).
    final seconds = (8 + playback.totalMeters / 1000).clamp(8, 18).round();
    _anim.duration = Duration(seconds: seconds);
    // Show the whole route while the marker travels it.
    _mapController.fitCamera(
      CameraFit.coordinates(
        coordinates: points,
        padding: const EdgeInsets.all(48),
      ),
    );
    setState(() => _playback = playback);
    _anim.forward(from: 0);
  }

  String stopTypeLabel(AppLocalizations l10n, StopType type) => switch (type) {
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

  Future<void> _showStopSheet(TripStop stop, int index) async {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        var currentType = StopType.fromName(stop.stopType);
        return StatefulBuilder(
          builder: (ctx, setSheetState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stopSheetTitle(index + 1),
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _row(
                    ctx,
                    l10n.stopArrivalTime,
                    Formatters.time(stop.arrivalTime, locale: locale),
                  ),
                  if (stop.departureTime != null)
                    _row(
                      ctx,
                      l10n.stopDepartureTime,
                      Formatters.time(stop.departureTime!, locale: locale),
                    ),
                  _row(
                    ctx,
                    l10n.stopDurationLabel,
                    Formatters.duration(
                      Duration(seconds: stop.durationSeconds),
                      locale: locale,
                    ),
                  ),
                  _row(
                    ctx,
                    l10n.stopLocationLabel,
                    stop.address ??
                        '${stop.latitude.toStringAsFixed(5)}, '
                            '${stop.longitude.toStringAsFixed(5)}',
                  ),
                  _row(
                    ctx,
                    l10n.stopTypeLabel,
                    stop.confirmedByUser
                        ? stopTypeLabel(l10n, currentType)
                        : l10n.stopUnconfirmed,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in [
                        StopType.rest,
                        StopType.parking,
                        StopType.fuel,
                        StopType.food,
                        StopType.destination,
                        StopType.other,
                      ])
                        ChoiceChip(
                          label: Text(stopTypeLabel(l10n, type)),
                          selected: stop.confirmedByUser && currentType == type,
                          onSelected: (_) async {
                            await ref
                                .read(tripRepositoryProvider)
                                .labelStop(
                                  stopId: stop.id,
                                  type: type,
                                  isDestination: type == StopType.destination
                                      ? true
                                      : null,
                                );
                            setSheetState(() => currentType = type);
                            ref.invalidate(tripDetailProvider(widget.tripId));
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.stopLabelSaved)),
                              );
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _roundButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
    bool filled = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final button = Material(
      color: filled ? scheme.primary : scheme.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 22,
            color: filled ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }

  Widget _row(BuildContext context, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(tripDetailProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.mapPageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.shareTripTitle,
            onPressed: () => Navigator.of(context).pop('share'),
          ),
        ],
      ),
      body: detail.when(
        loading: () => LoadingView(message: l10n.commonLoading),
        error: (e, _) => ErrorView(message: l10n.commonError),
        data: (data) {
          if (data == null || data.displayPoints.isEmpty) {
            return EmptyStateView(message: l10n.tripNoPoints, icon: Icons.map);
          }
          final playing = _playback != null;
          return AnimatedBuilder(
            animation: _curved,
            builder: (context, _) => TripMap(
              controller: _mapController,
              points: data.displayPoints,
              stops: data.stopRows,
              onStopTap: _showStopSheet,
              playbackFrame: playing ? _playback!.at(_curved.value) : null,
              extraControls: [
                // Play / stop the A→B trip animation.
                _roundButton(
                  icon: playing ? Icons.stop : Icons.play_arrow,
                  tooltip: l10n.mapPlayAnimation,
                  filled: true,
                  onTap: () => _togglePlayback(data.displayPoints),
                ),
                // Recenter: jump back to the route start.
                _roundButton(
                  icon: Icons.my_location,
                  onTap: () =>
                      _mapController.move(data.displayPoints.first, 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
