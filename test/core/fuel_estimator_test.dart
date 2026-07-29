import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/constants/enums.dart';
import 'package:triplog/core/utils/fuel_estimator.dart';

void main() {
  group('estimateFuel', () {
    const profile = FuelProfile(
      motorcycleKmPerLiter: 40,
      carKmPerLiter: 12,
      fuelPricePerLiter: 10000,
    );

    test('computes liters = km / (km per liter)', () {
      final est = estimateFuel(
        distanceMeters: 20000,
        vehicleType: VehicleType.motorcycle,
        profile: profile,
      );
      expect(est, isNotNull);
      expect(est!.liters, closeTo(0.5, 1e-9));
      expect(est.cost, closeTo(5000, 1e-6));
    });

    test('uses the car figure for car trips', () {
      final est = estimateFuel(
        distanceMeters: 12000,
        vehicleType: VehicleType.car,
        profile: profile,
      );
      expect(est!.liters, closeTo(1.0, 1e-9));
    });

    test('no estimate for vehicle types without a configured figure', () {
      for (final type in [
        VehicleType.bus,
        VehicleType.truck,
        VehicleType.train,
        VehicleType.bicycle,
        VehicleType.unknown,
      ]) {
        expect(
          estimateFuel(
            distanceMeters: 5000,
            vehicleType: type,
            profile: profile,
          ),
          isNull,
          reason: 'never guess consumption for $type',
        );
      }
    });

    test('no estimate when the profile is empty or invalid', () {
      expect(
        estimateFuel(
          distanceMeters: 5000,
          vehicleType: VehicleType.motorcycle,
          profile: const FuelProfile(),
        ),
        isNull,
      );
      expect(
        estimateFuel(
          distanceMeters: 5000,
          vehicleType: VehicleType.motorcycle,
          profile: const FuelProfile(motorcycleKmPerLiter: 0),
        ),
        isNull,
      );
    });

    test('cost is omitted when no fuel price is set', () {
      final est = estimateFuel(
        distanceMeters: 40000,
        vehicleType: VehicleType.motorcycle,
        profile: const FuelProfile(motorcycleKmPerLiter: 40),
      );
      expect(est!.liters, closeTo(1.0, 1e-9));
      expect(est.cost, isNull);
    });

    test('zero-distance trips produce no estimate', () {
      expect(
        estimateFuel(
          distanceMeters: 0,
          vehicleType: VehicleType.motorcycle,
          profile: profile,
        ),
        isNull,
      );
    });
  });
}
