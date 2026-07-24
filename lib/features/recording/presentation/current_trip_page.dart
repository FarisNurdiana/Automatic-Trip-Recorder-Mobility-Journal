import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../application/trip_recording_controller.dart';
import '../domain/trip_state_machine.dart';
import 'state_labels.dart';

/// Live view of the ongoing trip: big speed readout, live stats and manual
/// controls (pause / resume / finish / cancel).
class CurrentTripPage extends ConsumerWidget {
  const CurrentTripPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final state = ref.watch(tripRecordingControllerProvider);
    final controller = ref.read(tripRecordingControllerProvider.notifier);

    final statusLabel = tripStateLabel(l10n, state.machineState);
    final isRecording =
        state.machineState == TripRecordingState.recording ||
        state.machineState == TripRecordingState.shortStop;
    final isPaused =
        state.machineState.isStoppedLike &&
        state.machineState != TripRecordingState.shortStop;
    final hasActive = state.machineState.isActiveTrip;

    final speed = state.currentSpeedKmh;

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
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 12),

              // --- big speed readout ---
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        speed == null ? '—' : speed.toStringAsFixed(0),
                        style: theme.textTheme.displayLarge?.copyWith(
                          fontSize: 88,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                          color: hasActive
                              ? scheme.primary
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        'km/j',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
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
              const SizedBox(height: 16),

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
