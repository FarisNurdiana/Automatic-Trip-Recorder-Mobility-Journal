import '../../../core/constants/enums.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/utils/fuel_estimator.dart';

/// Builds a spreadsheet-friendly CSV of finished trips (for expense claims,
/// bookkeeping, or further analysis). Values follow the data as stored;
/// fuel columns are estimates from the user's km/L profile and stay empty
/// when no figure is configured for the trip's vehicle type.
class TripCsvExporter {
  const TripCsvExporter();

  static const header = [
    'tanggal_mulai',
    'tanggal_selesai',
    'alamat_awal',
    'alamat_tujuan',
    'jarak_km',
    'durasi_menit',
    'waktu_bergerak_menit',
    'kecepatan_rata_kmh',
    'kecepatan_maks_kmh',
    'kendaraan',
    'perkiraan_bbm_liter',
    'perkiraan_biaya',
  ];

  String build(List<Trip> trips, {FuelProfile profile = const FuelProfile()}) {
    final rows = <List<String>>[header];
    for (final trip in trips) {
      final vehicle = VehicleType.fromName(
        trip.confirmedVehicleType ?? trip.detectedVehicleType,
      );
      final fuel = estimateFuel(
        distanceMeters: trip.distanceMeters,
        vehicleType: vehicle,
        profile: profile,
      );
      rows.add([
        trip.startedAt.toLocal().toIso8601String(),
        trip.endedAt?.toLocal().toIso8601String() ?? '',
        trip.startAddress ?? '',
        trip.endAddress ?? '',
        (trip.distanceMeters / 1000).toStringAsFixed(2),
        (trip.elapsedDurationSeconds / 60).toStringAsFixed(1),
        (trip.movingDurationSeconds / 60).toStringAsFixed(1),
        trip.averageSpeedKmh.toStringAsFixed(1),
        trip.maximumSpeedKmh.toStringAsFixed(1),
        vehicle.name,
        fuel == null ? '' : fuel.liters.toStringAsFixed(2),
        fuel?.cost == null ? '' : fuel!.cost!.toStringAsFixed(0),
      ]);
    }
    return rows.map((r) => r.map(_escape).join(',')).join('\r\n');
  }

  /// RFC 4180 escaping: quote when the value contains comma/quote/newline.
  static String _escape(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
