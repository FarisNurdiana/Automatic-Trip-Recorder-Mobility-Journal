import 'package:flutter_test/flutter_test.dart';
import 'package:triplog/core/storage/app_database.dart';
import 'package:triplog/core/utils/fuel_estimator.dart';
import 'package:triplog/features/trips/domain/trip_csv_exporter.dart';

import '../../helpers.dart';

Trip _trip({
  String? startAddress,
  double distanceMeters = 12000,
  String vehicle = 'motorcycle',
}) => Trip(
  id: 't1',
  userId: 'u1',
  status: 'finished',
  startedAt: t0,
  endedAt: t0.add(const Duration(minutes: 30)),
  startAddress: startAddress,
  distanceMeters: distanceMeters,
  elapsedDurationSeconds: 1800,
  movingDurationSeconds: 1500,
  stoppedDurationSeconds: 300,
  averageSpeedKmh: 24,
  movingAverageSpeedKmh: 28.8,
  maximumSpeedKmh: 60,
  detectedVehicleType: vehicle,
  stopCount: 0,
  summaryAlgorithmVersion: 2,
  finishedAutomatically: false,
  arrivalCorrectedByUser: false,
  syncStatus: 'pending',
  createdAt: t0,
  updatedAt: t0,
);

void main() {
  const exporter = TripCsvExporter();

  test('produces a header plus one row per trip', () {
    final csv = exporter.build([_trip(), _trip()]);
    final lines = csv.split('\r\n');
    expect(lines, hasLength(3));
    expect(lines.first.split(','), TripCsvExporter.header);
  });

  test('escapes commas and quotes per RFC 4180', () {
    final csv = exporter.build([_trip(startAddress: 'Jl. "Merdeka", Bandung')]);
    expect(csv, contains('"Jl. ""Merdeka"", Bandung"'));
  });

  test('fills fuel columns from the profile, empty otherwise', () {
    const profile = FuelProfile(
      motorcycleKmPerLiter: 40,
      fuelPricePerLiter: 10000,
    );
    final withFuel = exporter
        .build([_trip()], profile: profile)
        .split('\r\n')[1];
    expect(withFuel, contains('0.30'));
    expect(withFuel, contains('3000'));

    final noFuel = exporter.build([_trip(vehicle: 'bus')], profile: profile);
    final cells = noFuel.split('\r\n')[1].split(',');
    expect(cells[cells.length - 1], isEmpty);
    expect(cells[cells.length - 2], isEmpty);
  });

  test('distance is exported in kilometers with two decimals', () {
    final row = exporter.build([_trip(distanceMeters: 2345)]).split('\r\n')[1];
    expect(row, contains('2.35'));
  });
}
