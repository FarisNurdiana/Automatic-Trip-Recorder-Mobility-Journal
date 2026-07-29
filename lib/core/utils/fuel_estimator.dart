import '../constants/enums.dart';

/// User-entered fuel profile: typical consumption per vehicle type
/// (km per liter, the way it is usually quoted in Indonesia) and an
/// optional fuel price per liter for cost estimates.
class FuelProfile {
  const FuelProfile({
    this.motorcycleKmPerLiter,
    this.carKmPerLiter,
    this.fuelPricePerLiter,
  });

  final double? motorcycleKmPerLiter;
  final double? carKmPerLiter;
  final double? fuelPricePerLiter;

  /// km/L that applies to [type]; null when the user has not set one for
  /// that vehicle type (no estimate is shown then — never guessed).
  double? kmPerLiterFor(VehicleType type) => switch (type) {
    VehicleType.motorcycle => motorcycleKmPerLiter,
    VehicleType.car => carKmPerLiter,
    _ => null,
  };
}

/// Estimated fuel use for one trip. Explicitly an *estimate* derived from
/// the user's own km/L figure — the app cannot measure real consumption
/// (that would need engine/OBD data, not phone sensors).
class FuelEstimate {
  const FuelEstimate({required this.liters, this.cost});

  final double liters;

  /// Estimated cost in the user's currency; null when no price is set.
  final double? cost;
}

/// Computes the estimate, or null when the profile has no km/L for the
/// vehicle type, the figure is invalid, or the trip has no distance.
FuelEstimate? estimateFuel({
  required double distanceMeters,
  required VehicleType vehicleType,
  required FuelProfile profile,
}) {
  final kmPerLiter = profile.kmPerLiterFor(vehicleType);
  if (kmPerLiter == null || kmPerLiter <= 0 || distanceMeters <= 0) {
    return null;
  }
  final liters = (distanceMeters / 1000) / kmPerLiter;
  final price = profile.fuelPricePerLiter;
  return FuelEstimate(
    liters: liters,
    cost: (price != null && price > 0) ? liters * price : null,
  );
}
