import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/constants/enums.dart';
import 'package:triplog/features/settings/application/settings_controller.dart';

void main() {
  group('ServiceProfile', () {
    const profile = ServiceProfile(
      intervalKmMotorcycle: 2000,
      intervalKmCar: 5000,
      baseKmMotorcycle: 1500,
    );

    test('interval and base resolve per vehicle type', () {
      expect(profile.intervalFor(VehicleType.motorcycle), 2000);
      expect(profile.intervalFor(VehicleType.car), 5000);
      expect(profile.baseFor(VehicleType.motorcycle), 1500);
      expect(profile.baseFor(VehicleType.car), 0);
    });

    test('other vehicle types never get a reminder interval', () {
      for (final type in [
        VehicleType.bus,
        VehicleType.truck,
        VehicleType.bicycle,
        VehicleType.unknown,
      ]) {
        expect(profile.intervalFor(type), isNull);
      }
    });

    test('due check: since-service km reaches the interval', () {
      // Mirrors the home-page rule: due when total - base >= interval.
      const totalKm = 3600.0;
      final since = totalKm - profile.baseFor(VehicleType.motorcycle);
      expect(since >= profile.intervalFor(VehicleType.motorcycle)!, isTrue);
      expect(3400 - profile.baseFor(VehicleType.motorcycle) >= 2000, isFalse);
    });
  });
}
