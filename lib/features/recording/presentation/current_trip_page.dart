import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';

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

    final statusLabel = switch (state.machineState) {
      TripRecordingState.idle => l10n.stateIdle,
      TripRecordingState.possibleTrip => l10n.statePossibleTrip,
      TripRecordingState.recording => l10n.stateRecording,
      TripRecordingState.temporarilyStopped => l10n.stateTemporarilyStopped,
      TripRecordingState.finishing => l10n.stateFinishing,
      TripRecordingState.finished => l10n.stateFinished,
      TripRecordingState.cancelled => l10n.stateCancelled,
    };

    final isRecording = state.machineState == TripRecordingState.recording;
    final isPaused =
        state.machineState == TripRecordingState.temporarilyStopped;
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
            StatTile(
              label: l10n.tripSpeed,
              icon: Icons.speed,
              value: state.currentSpeedKmh == null
                  ? '—'
                  : Formatters.speedKmh(state.currentSpeedKmh!, locale: locale),
            ),
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
}
