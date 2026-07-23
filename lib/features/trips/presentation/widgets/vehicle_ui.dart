import 'package:flutter/material.dart';

import '../../../../core/constants/enums.dart';
import '../../../../l10n/gen/app_localizations.dart';

/// Single source of truth for vehicle labels and icons so the icon can never
/// disagree with the label (e.g. a car icon next to "Motor").
String vehicleLabel(AppLocalizations l10n, VehicleType type) => switch (type) {
  VehicleType.car => l10n.vehicleCar,
  VehicleType.motorcycle => l10n.vehicleMotorcycle,
  VehicleType.bus => l10n.vehicleBus,
  VehicleType.truck => l10n.vehicleTruck,
  VehicleType.train => l10n.vehicleTrain,
  VehicleType.bicycle => l10n.vehicleBicycle,
  VehicleType.other => l10n.vehicleOther,
  VehicleType.unknown => l10n.vehicleUnknown,
};

IconData vehicleIcon(VehicleType type) => switch (type) {
  VehicleType.car => Icons.directions_car,
  VehicleType.motorcycle => Icons.two_wheeler,
  VehicleType.bus => Icons.directions_bus,
  VehicleType.truck => Icons.local_shipping,
  VehicleType.train => Icons.train,
  VehicleType.bicycle => Icons.pedal_bike,
  VehicleType.other => Icons.commute,
  VehicleType.unknown => Icons.help_outline,
};
