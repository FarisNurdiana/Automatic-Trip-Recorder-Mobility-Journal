import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/storage/app_database.dart';

/// Contract for the cloud side of sync. All operations are idempotent
/// (UUID-keyed upserts) so retries never duplicate data.
abstract interface class RemoteTripDataSource {
  Future<void> upsertTrip(Trip trip);
  Future<void> upsertPoints(List<TripPoint> points);
  Future<void> upsertActivityEvents(String userId, List<ActivityEvent> events);
  Future<void> upsertSensorSamples(List<SensorSample> samples);
  Future<List<Map<String, dynamic>>> fetchTrips(String userId);
  Future<void> deleteTrip(String tripId);
  Future<void> deleteAllUserData(String userId);
}

/// Supabase implementation. Row Level Security on the server enforces that
/// users only ever touch their own rows.
class SupabaseTripDataSource implements RemoteTripDataSource {
  SupabaseTripDataSource(this.client);

  final SupabaseClient client;

  @override
  Future<void> upsertTrip(Trip trip) async {
    await client.from('trips').upsert({
      'id': trip.id,
      'user_id': trip.userId,
      'status': trip.status,
      'started_at': trip.startedAt.toUtc().toIso8601String(),
      'ended_at': trip.endedAt?.toUtc().toIso8601String(),
      'start_latitude': trip.startLatitude,
      'start_longitude': trip.startLongitude,
      'end_latitude': trip.endLatitude,
      'end_longitude': trip.endLongitude,
      'start_address': trip.startAddress,
      'end_address': trip.endAddress,
      'distance_meters': trip.distanceMeters,
      'elapsed_duration_seconds': trip.elapsedDurationSeconds,
      'moving_duration_seconds': trip.movingDurationSeconds,
      'stopped_duration_seconds': trip.stoppedDurationSeconds,
      'average_speed_kmh': trip.averageSpeedKmh,
      'moving_average_speed_kmh': trip.movingAverageSpeedKmh,
      'maximum_speed_kmh': trip.maximumSpeedKmh,
      'detected_vehicle_type': trip.detectedVehicleType,
      'confirmed_vehicle_type': trip.confirmedVehicleType,
      'vehicle_confidence': trip.vehicleConfidence,
      'vehicle_confirmed_at': trip.vehicleConfirmedAt
          ?.toUtc()
          .toIso8601String(),
      'vehicle_prediction_changed': trip.vehiclePredictionChanged,
      'stop_count': trip.stopCount,
      'summary_algorithm_version': trip.summaryAlgorithmVersion,
      'device_model': trip.deviceModel,
      'operating_system': trip.operatingSystem,
      'operating_system_version': trip.operatingSystemVersion,
      'app_version': trip.appVersion,
      'phone_mount_position': trip.phoneMountPosition,
    });
  }

  @override
  Future<void> upsertPoints(List<TripPoint> points) async {
    if (points.isEmpty) return;
    await client.from('trip_points').upsert([
      for (final p in points)
        {
          'id': p.id,
          'trip_id': p.tripId,
          'recorded_at': p.recordedAt.toUtc().toIso8601String(),
          'latitude': p.latitude,
          'longitude': p.longitude,
          'altitude': p.altitude,
          'horizontal_accuracy': p.horizontalAccuracy,
          'vertical_accuracy': p.verticalAccuracy,
          'speed': p.speed,
          'speed_accuracy': p.speedAccuracy,
          'heading': p.heading,
          'heading_accuracy': p.headingAccuracy,
          'sequence_number': p.sequenceNumber,
          'source': p.source,
          'is_mocked': p.isMocked,
          'battery_level': p.batteryLevel,
        },
    ]);
  }

  @override
  Future<void> upsertActivityEvents(
    String userId,
    List<ActivityEvent> events,
  ) async {
    if (events.isEmpty) return;
    await client.from('activity_events').upsert([
      for (final e in events)
        {
          'id': e.id,
          'user_id': userId,
          'trip_id': e.tripId,
          'recorded_at': e.recordedAt.toUtc().toIso8601String(),
          'activity_type': e.activityType,
          'transition_type': e.transitionType,
          'confidence': e.confidence,
          'platform_source': e.platformSource,
          'raw_payload': e.rawPayload,
        },
    ]);
  }

  @override
  Future<void> upsertSensorSamples(List<SensorSample> samples) async {
    if (samples.isEmpty) return;
    await client.from('sensor_samples').upsert([
      for (final s in samples)
        {
          'id': s.id,
          'trip_id': s.tripId,
          'recorded_at': s.recordedAt.toUtc().toIso8601String(),
          'accelerometer_x': s.accelerometerX,
          'accelerometer_y': s.accelerometerY,
          'accelerometer_z': s.accelerometerZ,
          'gyroscope_x': s.gyroscopeX,
          'gyroscope_y': s.gyroscopeY,
          'gyroscope_z': s.gyroscopeZ,
          'magnetometer_x': s.magnetometerX,
          'magnetometer_y': s.magnetometerY,
          'magnetometer_z': s.magnetometerZ,
          'device_orientation': s.deviceOrientation,
          'sampling_rate_hz': s.samplingRate,
          'speed': s.speed,
          'activity_state': s.activityState,
        },
    ]);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchTrips(String userId) async {
    final rows = await client
        .from('trips')
        .select()
        .eq('user_id', userId)
        .order('started_at', ascending: false);
    return List<Map<String, dynamic>>.from(rows);
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    await client.from('trips').delete().eq('id', tripId);
  }

  @override
  Future<void> deleteAllUserData(String userId) async {
    // trip_points / sensor_samples cascade from trips.
    await client.from('activity_events').delete().eq('user_id', userId);
    await client.from('trips').delete().eq('user_id', userId);
  }
}
