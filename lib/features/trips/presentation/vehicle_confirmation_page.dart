import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import 'trip_detail_page.dart';
import 'widgets/vehicle_ui.dart';

/// Post-trip vehicle confirmation with a natural, confidence-tiered flow:
///  * confidence >= 70% — direct yes/no question about the prediction;
///  * 40–69%           — "kemungkinan" phrasing with confirm/change;
///  * < 40%            — neutral question, no steering toward one vehicle.
///
/// The user's answer is stored separately from the detection and treated as
/// the ground-truth label for the future classification dataset.
class VehicleConfirmationPage extends ConsumerStatefulWidget {
  const VehicleConfirmationPage({super.key, required this.tripId});

  final String tripId;

  @override
  ConsumerState<VehicleConfirmationPage> createState() =>
      _VehicleConfirmationPageState();
}

class _VehicleConfirmationPageState
    extends ConsumerState<VehicleConfirmationPage> {
  bool _showAllChoices = false;

  static const _choices = [
    VehicleType.motorcycle,
    VehicleType.car,
    VehicleType.bus,
    VehicleType.truck,
    VehicleType.train,
    VehicleType.bicycle,
    VehicleType.other,
  ];

  Future<void> _confirm(VehicleType type) async {
    await ref
        .read(tripRepositoryProvider)
        .confirmVehicle(
          tripId: widget.tripId,
          confirmed: type,
          confirmedAt: DateTime.now().toUtc(),
        );
    ref.invalidate(tripDetailProvider(widget.tripId));
    if (mounted) context.go('/trips/${widget.tripId}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(tripDetailProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vehicleConfirmTitle)),
      body: detail.when(
        loading: () => LoadingView(message: l10n.commonLoading),
        error: (e, _) => ErrorView(message: l10n.commonError),
        data: (data) {
          if (data == null) return EmptyStateView(message: l10n.commonEmpty);
          final trip = data.trip;
          final detected = VehicleType.fromName(trip.detectedVehicleType);
          final confidence = trip.vehicleConfidence ?? 0;
          final hasPrediction =
              detected != VehicleType.unknown && confidence > 0;

          final Widget content;
          if (_showAllChoices || !hasPrediction || confidence < 0.40) {
            content = _neutralChoices(l10n);
          } else if (confidence >= 0.70) {
            content = _directQuestion(l10n, detected, confidence);
          } else {
            content = _probableQuestion(l10n, detected, confidence);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  hasPrediction ? vehicleIcon(detected) : Icons.commute,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                content,
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go('/trips/${widget.tripId}'),
                  child: Text(l10n.commonSkip),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Confidence >= 70%: ask directly.
  Widget _directQuestion(
    AppLocalizations l10n,
    VehicleType detected,
    double confidence,
  ) {
    final name = vehicleLabel(l10n, detected).toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.vehicleQuestionHigh(name),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.vehiclePredictionInfo,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          l10n.vehicleConfidenceLabel((confidence * 100).toStringAsFixed(0)),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          icon: Icon(vehicleIcon(detected)),
          onPressed: () => _confirm(detected),
          label: Text(l10n.vehicleYes(vehicleLabel(l10n, detected))),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => setState(() => _showAllChoices = true),
          child: Text(l10n.vehicleNo),
        ),
      ],
    );
  }

  /// Confidence 40–69%: "kemungkinan" phrasing.
  Widget _probableQuestion(
    AppLocalizations l10n,
    VehicleType detected,
    double confidence,
  ) {
    final name = vehicleLabel(l10n, detected).toLowerCase();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.vehicleQuestionMedium(name),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.vehicleQuestionMediumAsk,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        Text(
          l10n.vehicleConfidenceLabel((confidence * 100).toStringAsFixed(0)),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          icon: Icon(vehicleIcon(detected)),
          onPressed: () => _confirm(detected),
          label: Text(l10n.vehicleCorrect),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => setState(() => _showAllChoices = true),
          child: Text(l10n.vehicleChange),
        ),
      ],
    );
  }

  /// Confidence < 40% (or user asked to change): neutral choices, no
  /// steering.
  Widget _neutralChoices(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.vehicleQuestionLow,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),
        for (final type in _choices) ...[
          OutlinedButton.icon(
            icon: Icon(vehicleIcon(type)),
            style: OutlinedButton.styleFrom(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            onPressed: () => _confirm(type),
            label: Text(vehicleLabel(l10n, type)),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
