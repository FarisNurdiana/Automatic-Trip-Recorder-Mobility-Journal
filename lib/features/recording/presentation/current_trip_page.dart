import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/poi/nearby_poi_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/trip_recording_controller.dart';
import '../domain/trip_state_machine.dart';
import 'state_labels.dart';
import 'widgets/live_trip_map.dart';

/// Route recorded so far for the active trip, refreshed every few seconds
/// so the live map draws the polyline without hammering the database.
final _activeTripPointsProvider = StreamProvider.autoDispose<List<LatLng>>((
  ref,
) async* {
  final tripId = ref.watch(
    tripRecordingControllerProvider.select((s) => s.activeTrip?.id),
  );
  if (tripId == null) {
    yield const [];
    return;
  }
  final repo = ref.watch(tripRepositoryProvider);
  while (true) {
    final points = await repo.pointsForTrip(tripId);
    yield [for (final p in points) LatLng(p.latitude, p.longitude)];
    await Future<void>.delayed(const Duration(seconds: 4));
  }
});

/// Driving-assistant view of the ongoing trip: realtime map with the live
/// position and route, speed overlay, nearby fuel/workshop lookup, live
/// stats and manual controls (pause / resume / finish / cancel).
class CurrentTripPage extends ConsumerStatefulWidget {
  const CurrentTripPage({super.key});

  @override
  ConsumerState<CurrentTripPage> createState() => _CurrentTripPageState();
}

class _CurrentTripPageState extends ConsumerState<CurrentTripPage> {
  final _mapController = MapController();
  var _follow = true;
  var _loadingPois = false;
  List<NearbyPoi> _pois = const [];

  /// Rolling speed samples of the last ~2.5 minutes for the live
  /// congestion hint.
  final _speedSamples = <(DateTime, double)>[];

  /// Sustained crawling (2–15 km/h for ≥2 minutes with some distance
  /// covered) reads as a traffic jam. Rule-based hint, not traffic data.
  bool _likelyCongested(double liveDistanceMeters) {
    final now = DateTime.now();
    _speedSamples.removeWhere(
      (s) => now.difference(s.$1) > const Duration(seconds: 150),
    );
    final window = _speedSamples
        .where((s) => now.difference(s.$1) <= const Duration(seconds: 120))
        .toList();
    if (window.length < 10 || liveDistanceMeters < 200) return false;
    final speeds = window.map((s) => s.$2).toList();
    final avg = speeds.reduce((a, b) => a + b) / speeds.length;
    final max = speeds.reduce((a, b) => a > b ? a : b);
    return avg >= 2 && avg <= 12 && max <= 15;
  }

  Future<void> _findPois() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final state = ref.read(tripRecordingControllerProvider);
    final lat = state.currentLatitude;
    final lon = state.currentLongitude;
    if (lat == null || lon == null || _loadingPois) return;
    setState(() => _loadingPois = true);
    try {
      final pois = await ref
          .read(nearbyPoiServiceProvider)
          .findNearby(lat, lon);
      if (!mounted) return;
      setState(() => _pois = pois);
      if (pois.isEmpty) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.poiNone)));
      } else {
        _showPoiSheet(pois);
      }
    } catch (_) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text(l10n.poiError)));
      }
    } finally {
      if (mounted) setState(() => _loadingPois = false);
    }
  }

  void _focusPoi(NearbyPoi poi) {
    setState(() => _follow = false);
    _mapController.move(LatLng(poi.latitude, poi.longitude), 16.5);
  }

  void _showPoiSheet(List<NearbyPoi> pois) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
              child: Text(
                l10n.poiSheetTitle,
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                l10n.poiDisclaimer,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: pois.length,
                itemBuilder: (ctx, i) {
                  final poi = pois[i];
                  final fuel = poi.type == PoiType.fuel;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: fuel
                          ? Colors.orange.shade700
                          : Colors.teal.shade600,
                      child: Icon(
                        fuel ? Icons.local_gas_station : Icons.build,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(poi.name),
                    subtitle: Text(
                      '${fuel ? l10n.poiFuel : l10n.poiWorkshop} • '
                      '${Formatters.distanceKm(poi.distanceMeters, locale: locale)}',
                    ),
                    trailing: const Icon(Icons.map_outlined),
                    onTap: () {
                      Navigator.pop(ctx);
                      _focusPoi(poi);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(tripRecordingControllerProvider);
    final controller = ref.read(tripRecordingControllerProvider.notifier);
    final livePoints =
        ref.watch(_activeTripPointsProvider).valueOrNull ?? const <LatLng>[];

    final statusLabel = tripStateLabel(l10n, state.machineState);
    final isRecording =
        state.machineState == TripRecordingState.recording ||
        state.machineState == TripRecordingState.shortStop;
    final isPaused =
        state.machineState.isStoppedLike &&
        state.machineState != TripRecordingState.shortStop;
    final hasActive = state.machineState.isActiveTrip;

    final current = (state.currentLatitude != null)
        ? LatLng(state.currentLatitude!, state.currentLongitude!)
        : null;
    final speed = state.currentSpeedKmh;

    // Speed-limit warning: red speed chip + one strong vibration when the
    // limit is first exceeded (visual works because the screen stays on).
    final speedLimit = ref.watch(
      settingsControllerProvider.select((s) => s.speedLimitKmh),
    );
    final overLimit = speed != null && speedLimit != null && speed > speedLimit;
    ref.listen(
      tripRecordingControllerProvider.select((s) => s.currentSpeedKmh),
      (previous, next) {
        if (next != null) _speedSamples.add((DateTime.now(), next));
        final limit = ref.read(settingsControllerProvider).speedLimitKmh;
        if (limit == null || next == null) return;
        final wasOver = (previous ?? 0) > limit;
        if (next > limit && !wasOver) {
          HapticFeedback.heavyImpact();
        }
      },
    );
    final congested = hasActive && _likelyCongested(state.liveDistanceMeters);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tripCurrentTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: l10n.detectionLogTitle,
            onPressed: () => context.push('/settings/detection-log'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- status pill ---
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: hasActive
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPaused
                            ? Icons.pause_circle
                            : (hasActive
                                  ? Icons.fiber_manual_record
                                  : Icons.radar),
                        size: 16,
                        color: hasActive && !isPaused
                            ? const Color(0xFFE53935)
                            : scheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        statusLabel,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.recoveredTrip) ...[
                const SizedBox(height: 8),
                Text(
                  l10n.recoveredTripMessage,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (congested) ...[
                const SizedBox(height: 8),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade800,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.traffic,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.congestionLikely,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),

              // --- live map (assistant view) or idle placeholder ---
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: current == null
                      ? _IdlePlaceholder(hasActive: hasActive)
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: LiveTripMap(
                                controller: _mapController,
                                points: livePoints,
                                current: current,
                                pois: _pois,
                                follow: _follow,
                                onPoiTap: (poi) => _showPoiSheet(
                                  _pois.isEmpty ? [poi] : _pois,
                                ),
                              ),
                            ),
                            // Speed overlay.
                            Positioned(
                              left: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: overLimit
                                      ? const Color(0xFFD32F2F)
                                      : scheme.surface.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (overLimit) ...[
                                      const Icon(
                                        Icons.warning_amber_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      speed == null
                                          ? '0'
                                          : speed.toStringAsFixed(0),
                                      style: theme.textTheme.headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: overLimit
                                                ? Colors.white
                                                : scheme.primary,
                                          ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'km/j',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: overLimit
                                                ? Colors.white70
                                                : scheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Map action buttons.
                            Positioned(
                              right: 12,
                              bottom: 12,
                              child: Column(
                                children: [
                                  _MapActionButton(
                                    icon: Icons.local_gas_station,
                                    tooltip: l10n.poiButton,
                                    loading: _loadingPois,
                                    onTap: _findPois,
                                  ),
                                  const SizedBox(height: 8),
                                  _MapActionButton(
                                    icon: _follow
                                        ? Icons.my_location
                                        : Icons.location_searching,
                                    tooltip: l10n.followPosition,
                                    active: _follow,
                                    onTap: () =>
                                        setState(() => _follow = !_follow),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // --- live stats ---
              Row(
                children: [
                  Expanded(
                    child: _LiveStat(
                      icon: Icons.straighten,
                      label: l10n.tripDistance,
                      value: Formatters.distanceKm(
                        state.liveDistanceMeters,
                        locale: locale,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LiveStat(
                      icon: Icons.schedule,
                      label: l10n.tripDuration,
                      value: Formatters.duration(
                        state.liveElapsed,
                        locale: locale,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LiveStat(
                      icon: Icons.gps_fixed,
                      label: l10n.gpsQuality,
                      value: _gpsQualityLabel(
                        l10n,
                        state.currentAccuracyMeters,
                      ),
                    ),
                  ),
                ],
              ),

              if (state.stopQuestion != null) ...[
                const SizedBox(height: 12),
                _StopQuestionCard(
                  kind: state.stopQuestion!,
                  onAnswer: controller.answerStopQuestion,
                ),
              ],
              const SizedBox(height: 14),

              // --- controls ---
              if (!hasActive)
                FilledButton.icon(
                  onPressed: () => controller.startManual(),
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.homeStartTrip),
                )
              else ...[
                Row(
                  children: [
                    Expanded(
                      child: isPaused
                          ? FilledButton.tonalIcon(
                              onPressed: () => controller.resume(),
                              icon: const Icon(Icons.play_arrow),
                              label: Text(l10n.tripResume),
                            )
                          : FilledButton.tonalIcon(
                              onPressed: isRecording
                                  ? () => controller.pause()
                                  : null,
                              icon: const Icon(Icons.pause),
                              label: Text(l10n.tripPause),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => controller.finish(),
                        icon: const Icon(Icons.stop),
                        label: Text(l10n.tripFinish),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.tripCancel),
                        content: Text(l10n.tripCancelConfirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(l10n.commonClose),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(l10n.commonConfirm),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await controller.cancel();
                      if (context.mounted) context.go('/');
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.tripCancel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _gpsQualityLabel(AppLocalizations l10n, double? accuracy) {
    if (accuracy == null) return '—';
    if (accuracy <= 15) return l10n.gpsGood;
    if (accuracy <= 40) return l10n.gpsFair;
    return l10n.gpsPoor;
  }
}

/// Shown before the first GPS fix arrives.
class _IdlePlaceholder extends StatelessWidget {
  const _IdlePlaceholder({required this.hasActive});

  final bool hasActive;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      color: scheme.surfaceContainerLow,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              hasActive ? Icons.gps_not_fixed : Icons.map_outlined,
              size: 56,
              color: scheme.outline,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                hasActive ? l10n.liveMapWaitingFix : l10n.liveMapIdleHint,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.active = false,
    this.loading = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final bool active;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final button = Material(
      color: active ? scheme.primary : scheme.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: loading ? null : onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: loading
              ? const Padding(
                  padding: EdgeInsets.all(11),
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Icon(
                  icon,
                  size: 22,
                  color: active ? scheme.onPrimary : scheme.onSurface,
                ),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

class _LiveStat extends StatelessWidget {
  const _LiveStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? scheme.surfaceContainerLow
            : scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// In-app version of the stationary-stop question (mirrors the notification
/// actions, for when the app is open).
class _StopQuestionCard extends StatelessWidget {
  const _StopQuestionCard({required this.kind, required this.onAnswer});

  final StopQuestionKind kind;
  final Future<void> Function(StopQuestionAnswer) onAnswer;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final destination = kind == StopQuestionKind.destination;
    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              destination ? l10n.stopQuestion5hTitle : l10n.stopQuestion30Title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              destination ? l10n.stopQuestion5hBody : l10n.stopQuestion30Body,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            if (destination) ...[
              FilledButton(
                onPressed: () => onAnswer(StopQuestionAnswer.arrived),
                child: Text(l10n.finishTripAction),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => onAnswer(StopQuestionAnswer.continueTrip),
                child: Text(l10n.keepTripAction),
              ),
            ] else ...[
              FilledButton(
                onPressed: () => onAnswer(StopQuestionAnswer.arrived),
                child: Text(l10n.answerArrived),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => onAnswer(StopQuestionAnswer.resting),
                child: Text(l10n.answerResting),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => onAnswer(StopQuestionAnswer.continueTrip),
                child: Text(l10n.answerContinue),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
