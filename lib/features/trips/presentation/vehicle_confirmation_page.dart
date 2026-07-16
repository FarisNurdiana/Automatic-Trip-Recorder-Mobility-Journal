import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import 'trip_detail_page.dart';

/// Post-trip vehicle confirmation. The user's answer is stored separately
/// from the detection and treated as the ground-truth label for the future
/// car/motorcycle classification dataset.
class VehicleConfirmationPage extends ConsumerWidget {
  const VehicleConfirmationPage({super.key, required this.tripId});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final detail = ref.watch(tripDetailProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.vehicleConfirmTitle)),
      body: detail.when(
        loading: () => LoadingView(message: l10n.commonLoading),
        error: (e, _) => ErrorView(message: l10n.commonError),
        data: (data) {
          if (data == null) return EmptyStateView(message: l10n.commonEmpty);
          final trip = data.trip;
          final detected = VehicleType.fromName(trip.detectedVehicleType);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.directions_car_filled_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.vehicleConfirmMessage,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (detected != VehicleType.unknown) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Text(l10n.vehiclePrediction(_label(l10n, detected))),
                          if (trip.vehicleConfidence != null)
                            Text(
                              l10n.vehicleConfidence(
                                (trip.vehicleConfidence! * 100).toStringAsFixed(
                                  0,
                                ),
                              ),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  l10n.vehicleConfirmQuestion,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final type in [
                      VehicleType.motorcycle,
                      VehicleType.car,
                      VehicleType.bus,
                      VehicleType.truck,
                      VehicleType.train,
                      VehicleType.other,
                    ])
                      _VehicleChoice(
                        label: _label(l10n, type),
                        icon: _icon(type),
                        selected: trip.confirmedVehicleType == type.name,
                        onTap: () async {
                          await ref
                              .read(tripRepositoryProvider)
                              .confirmVehicle(
                                tripId: tripId,
                                confirmed: type,
                                confirmedAt: DateTime.now().toUtc(),
                              );
                          ref.invalidate(tripDetailProvider(tripId));
                          if (context.mounted) {
                            context.go('/trips/$tripId');
                          }
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => context.go('/trips/$tripId'),
                  child: Text(l10n.commonSkip),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _label(AppLocalizations l10n, VehicleType type) => switch (type) {
    VehicleType.car => l10n.vehicleCar,
    VehicleType.motorcycle => l10n.vehicleMotorcycle,
    VehicleType.bus => l10n.vehicleBus,
    VehicleType.truck => l10n.vehicleTruck,
    VehicleType.train => l10n.vehicleTrain,
    VehicleType.other => l10n.vehicleOther,
    VehicleType.unknown => l10n.vehicleUnknown,
  };

  IconData _icon(VehicleType type) => switch (type) {
    VehicleType.car => Icons.directions_car,
    VehicleType.motorcycle => Icons.two_wheeler,
    VehicleType.bus => Icons.directions_bus,
    VehicleType.truck => Icons.local_shipping,
    VehicleType.train => Icons.train,
    _ => Icons.more_horiz,
  };
}

class _VehicleChoice extends StatelessWidget {
  const _VehicleChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}
