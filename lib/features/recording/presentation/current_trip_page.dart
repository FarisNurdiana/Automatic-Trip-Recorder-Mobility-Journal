import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../application/trip_recording_controller.dart';
import '../domain/trip_state_machine.dart';
import 'state_labels.dart';

/// Live view of the ongoing trip with manual controls
/// (pause / resume / finish / cancel).
class CurrentTripPage extends ConsumerWidget {
  const CurrentTripPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final state = ref.watch(tripRecordingControllerProvider);
    final controller = ref.read(tripRecordingControllerProvider.notifier);

    final statusLabel = tripStateLabel(l10n, state.machineState);

    final isRecording =
        state.machineState == TripRecordingState.recording ||
        state.machineState == TripRecordingState.shortStop;
    final isPaused = state.machineState.isStoppedLike &&
        state.machineState != TripRecordingState.shortStop;
    final hasActive = state.machineState.isActiveTrip;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tripCurrentTitle)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: hasActive
                  ? Theme.of(context).colorScheme.primaryContainer
                  : null,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      isPaused ? Icons.pause_circle : Icons.navigation,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusLabel,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (state.recoveredTrip) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.recoveredTripMessage,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: l10n.tripDistance,
                    icon: Icons.straighten,
                    value: Formatters.distanceKm(
                      state.liveDistanceMeters,
                      locale: locale,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: l10n.tripDuration,
                    icon: Icons.schedule,
                    value: Formatters.duration(
                      state.liveElapsed,
                      locale: locale,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: l10n.tripSpeed,
                    icon: Icons.speed,
                    value: state.currentSpeedKmh == null
                        ? '—'
                        : Formatters.speedKmh(
                            state.currentSpeedKmh!,
                            locale: locale,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: l10n.gpsQuality,
                    icon: Icons.gps_fixed,
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
            const Spacer(),
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
              const SizedBox(height: 8),
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
    );
  }

  String _gpsQualityLabel(AppLocalizations l10n, double? accuracy) {
    if (accuracy == null) return '—';
    if (accuracy <= 15) return '${l10n.gpsGood} (±${accuracy.round()} m)';
    if (accuracy <= 40) return '${l10n.gpsFair} (±${accuracy.round()} m)';
    return '${l10n.gpsPoor} (±${accuracy.round()} m)';
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
