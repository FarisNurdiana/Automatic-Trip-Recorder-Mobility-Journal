import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/activity/activity_models.dart';
import '../../../core/constants/enums.dart';
import '../../../core/location/location_models.dart';
import '../../../core/sensors/sensor_models.dart';
import '../../../core/storage/app_database.dart';
import '../domain/trip_summary_calculator.dart';
import 'local_trip_data_source.dart';

/// Device/app metadata stamped onto every trip for the sensor dataset.
class TripDeviceMetadata {
  const TripDeviceMetadata({
    this.deviceModel,
    this.operatingSystem,
    this.operatingSystemVersion,
    this.appVersion,
    this.sensorSamplingConfiguration,
  });

  final String? deviceModel;
  final String? operatingSystem;
  final String? operatingSystemVersion;
  final String? appVersion;
  final String? sensorSamplingConfiguration;
}

/// High-level trip persistence API. UI and controllers never touch the
/// database directly — everything goes through this repository.
abstract interface class TripRepository {
  Future<Trip> createTrip({
    required String userId,
    required DateTime startedAt,
    VehicleType detectedVehicleType = VehicleType.unknown,
    double? vehicleConfidence,
    TripDeviceMetadata? metadata,
    PhoneMountPosition mountPosition = PhoneMountPosition.unknown,
  });

  Future<void> appendPoint(String tripId, RecordedLocation location);
  Future<void> setTripStatus(String tripId, TripRecordingState state);

  /// Computes and stores the summary. Returns null (and cancels the trip)
  /// when the trip is invalid — too few points, too short, etc.
  ///
  /// [finishReason] records why the trip ended (manual, arrivedAnswer,
  /// autoStationary, ...). [finishedAutomatically] marks auto-finish so the
  /// user can correct it later. [arrivalOverride] replaces the last-point
  /// arrival time (e.g. the moment the vehicle first stopped).
  Future<TripSummaryResult?> finishTrip(
    String tripId,
    DateTime endedAt, {
    String? finishReason,
    bool finishedAutomatically = false,
    DateTime? arrivalOverride,
  });

  Future<void> cancelAndDeleteTrip(String tripId);

  // --- stops ---
  Future<List<TripStop>> stopsForTrip(String tripId);

  /// User labels a stop (rest/parking/fuel/...). Ground truth, optional.
  Future<void> labelStop({
    required String stopId,
    required StopType type,
    String? note,
    bool? isDestination,
  });

  /// Marks the notification-question timestamp for a stop.
  Future<void> markStopNotified(String stopId, DateTime at);

  /// User corrects the arrival time after an automatic finish.
  Future<void> correctArrivalTime(String tripId, DateTime arrival);

  Future<void> confirmVehicle({
    required String tripId,
    required VehicleType confirmed,
    required DateTime confirmedAt,
  });

  Future<Trip?> getTrip(String id);
  Stream<List<Trip>> watchTrips(String userId);
  Future<List<RecordedLocation>> pointsForTrip(String tripId);
  Future<void> deleteTrip(String id);
  Future<void> deleteAllLocalData();
  Future<(int, double)> totalsForUser(String userId);

  /// Trip that was active when the app was killed, if any (recovery).
  Future<Trip?> findRecoverableTrip();

  Future<void> recordActivityEvent(DetectedActivity activity, {String? tripId});
  Future<void> addSensorSamples(
    String tripId,
    List<CollectedSensorSample> samples,
  );
}

class DefaultTripRepository implements TripRepository {
  DefaultTripRepository({
    required this.local,
    required this.summaryCalculator,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final LocalTripDataSource local;
  final TripSummaryCalculator summaryCalculator;
  final Uuid _uuid;

  /// Per-trip sequence counters for point ordering.
  final Map<String, int> _sequenceCounters = {};

  @override
  Future<Trip> createTrip({
    required String userId,
    required DateTime startedAt,
    VehicleType detectedVehicleType = VehicleType.unknown,
    double? vehicleConfidence,
    TripDeviceMetadata? metadata,
    PhoneMountPosition mountPosition = PhoneMountPosition.unknown,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now().toUtc();
    final companion = TripsCompanion.insert(
      id: id,
      userId: userId,
      status: TripRecordingState.recording.name,
      startedAt: startedAt,
      detectedVehicleType: Value(detectedVehicleType.name),
      vehicleConfidence: Value(vehicleConfidence),
      deviceModel: Value(metadata?.deviceModel),
      operatingSystem: Value(metadata?.operatingSystem),
      operatingSystemVersion: Value(metadata?.operatingSystemVersion),
      appVersion: Value(metadata?.appVersion),
      phoneMountPosition: Value(mountPosition.name),
      syncStatus: const Value('pending'),
      createdAt: now,
      updatedAt: now,
    );
    await local.upsertTrip(companion);
    _sequenceCounters[id] = 0;
    return (await local.getTrip(id))!;
  }

  @override
  Future<void> appendPoint(String tripId, RecordedLocation location) async {
    final seq =
        _sequenceCounters[tripId] ?? await local.pointCountForTrip(tripId);
    _sequenceCounters[tripId] = seq + 1;
    await local.insertPoints([
      TripPointsCompanion.insert(
        id: _uuid.v4(),
        tripId: tripId,
        recordedAt: location.recordedAt,
        latitude: location.latitude,
        longitude: location.longitude,
        altitude: Value(location.altitude),
        horizontalAccuracy: Value(location.horizontalAccuracy),
        verticalAccuracy: Value(location.verticalAccuracy),
        speed: Value(location.speed),
        speedAccuracy: Value(location.speedAccuracy),
        heading: Value(location.heading),
        headingAccuracy: Value(location.headingAccuracy),
        sequenceNumber: seq,
        source: Value(location.source),
        isMocked: Value(location.isMocked),
        batteryLevel: Value(location.batteryLevel),
      ),
    ]);
  }

  @override
  Future<void> setTripStatus(String tripId, TripRecordingState state) async {
    final trip = await local.getTrip(tripId);
    if (trip == null) return;
    await local.upsertTrip(
      trip
          .toCompanion(false)
          .copyWith(
            status: Value(state.name),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
    );
  }

  @override
  Future<TripSummaryResult?> finishTrip(
    String tripId,
    DateTime endedAt, {
    String? finishReason,
    bool finishedAutomatically = false,
    DateTime? arrivalOverride,
  }) async {
    final trip = await local.getTrip(tripId);
    if (trip == null) return null;
    final points = await pointsForTrip(tripId);
    final summary = summaryCalculator.calculate(points);
    if (summary == null) {
      await setTripStatus(tripId, TripRecordingState.cancelled);
      return null;
    }
    await local.upsertTrip(
      trip
          .toCompanion(false)
          .copyWith(
            status: Value(TripRecordingState.finished.name),
            endedAt: Value(arrivalOverride ?? endedAt),
            startLatitude: Value(summary.startLatitude),
            startLongitude: Value(summary.startLongitude),
            endLatitude: Value(summary.endLatitude),
            endLongitude: Value(summary.endLongitude),
            distanceMeters: Value(summary.distanceMeters),
            elapsedDurationSeconds: Value(summary.elapsed.inSeconds),
            movingDurationSeconds: Value(summary.moving.inSeconds),
            stoppedDurationSeconds: Value(summary.stopped.inSeconds),
            averageSpeedKmh: Value(summary.averageSpeedKmh),
            movingAverageSpeedKmh: Value(summary.movingAverageSpeedKmh),
            maximumSpeedKmh: Value(summary.maximumSpeedKmh),
            stopCount: Value(summary.stops.length),
            summaryAlgorithmVersion: Value(summary.algorithmVersion),
            finishedAutomatically: Value(finishedAutomatically),
            finishReason: Value(finishReason),
            syncStatus: const Value('pending'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
    );

    // Persist detected stops so the user can label them later. The last stop
    // that touches the trip end is flagged as the destination candidate.
    final now = DateTime.now().toUtc();
    for (var i = 0; i < summary.stops.length; i++) {
      final stop = summary.stops[i];
      await local.upsertStop(
        TripStopsCompanion.insert(
          id: _uuid.v4(),
          tripId: tripId,
          arrivalTime: stop.startedAt,
          departureTime: Value(stop.endedAt),
          durationSeconds: Value(stop.duration.inSeconds),
          latitude: stop.latitude,
          longitude: stop.longitude,
          isDestination: Value(i == summary.stops.length - 1),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
    _sequenceCounters.remove(tripId);
    return summary;
  }

  @override
  Future<List<TripStop>> stopsForTrip(String tripId) =>
      local.stopsForTrip(tripId);

  @override
  Future<void> labelStop({
    required String stopId,
    required StopType type,
    String? note,
    bool? isDestination,
  }) async {
    final stop = await local.getStop(stopId);
    if (stop == null) return;
    await local.upsertStop(
      stop
          .toCompanion(false)
          .copyWith(
            stopType: Value(type.name),
            stopNote: Value(note ?? stop.stopNote),
            isDestination: isDestination == null
                ? const Value.absent()
                : Value(isDestination),
            confirmedByUser: const Value(true),
            syncStatus: const Value('pending'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
    );
  }

  @override
  Future<void> markStopNotified(String stopId, DateTime at) async {
    final stop = await local.getStop(stopId);
    if (stop == null) return;
    await local.upsertStop(
      stop
          .toCompanion(false)
          .copyWith(
            notificationSentAt: Value(at),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
    );
  }

  @override
  Future<void> correctArrivalTime(String tripId, DateTime arrival) async {
    final trip = await local.getTrip(tripId);
    if (trip == null) return;
    final elapsed = arrival.difference(trip.startedAt).inSeconds;
    await local.upsertTrip(
      trip
          .toCompanion(false)
          .copyWith(
            endedAt: Value(arrival),
            elapsedDurationSeconds: elapsed > 0
                ? Value(elapsed)
                : const Value.absent(),
            arrivalCorrectedByUser: const Value(true),
            syncStatus: const Value('pending'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
    );
  }

  @override
  Future<void> cancelAndDeleteTrip(String tripId) async {
    _sequenceCounters.remove(tripId);
    await local.deleteTrip(tripId);
  }

  @override
  Future<void> confirmVehicle({
    required String tripId,
    required VehicleType confirmed,
    required DateTime confirmedAt,
  }) async {
    final trip = await local.getTrip(tripId);
    if (trip == null) return;
    final changed = trip.detectedVehicleType != confirmed.name;
    await local.upsertTrip(
      trip
          .toCompanion(false)
          .copyWith(
            confirmedVehicleType: Value(confirmed.name),
            vehicleConfirmedAt: Value(confirmedAt),
            vehiclePredictionChanged: Value(changed),
            // Confirmation must reach the cloud even if the trip already synced.
            syncStatus: const Value('pending'),
            updatedAt: Value(DateTime.now().toUtc()),
          ),
    );
  }

  @override
  Future<Trip?> getTrip(String id) => local.getTrip(id);

  @override
  Stream<List<Trip>> watchTrips(String userId) =>
      local.watchTripsForUser(userId);

  @override
  Future<List<RecordedLocation>> pointsForTrip(String tripId) async {
    final rows = await local.pointsForTrip(tripId);
    return [
      for (final p in rows)
        RecordedLocation(
          recordedAt: p.recordedAt,
          latitude: p.latitude,
          longitude: p.longitude,
          altitude: p.altitude,
          horizontalAccuracy: p.horizontalAccuracy,
          verticalAccuracy: p.verticalAccuracy,
          speed: p.speed,
          speedAccuracy: p.speedAccuracy,
          heading: p.heading,
          headingAccuracy: p.headingAccuracy,
          source: p.source,
          isMocked: p.isMocked,
          batteryLevel: p.batteryLevel,
        ),
    ];
  }

  @override
  Future<void> deleteTrip(String id) => local.deleteTrip(id);

  @override
  Future<void> deleteAllLocalData() => local.deleteAllData();

  @override
  Future<(int, double)> totalsForUser(String userId) =>
      local.totalsForUser(userId);

  @override
  Future<Trip?> findRecoverableTrip() async {
    final active = await local.activeTrips();
    if (active.isEmpty) return null;
    active.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return active.first;
  }

  @override
  Future<void> recordActivityEvent(
    DetectedActivity activity, {
    String? tripId,
  }) => local.insertActivityEvent(
    ActivityEventsCompanion.insert(
      id: _uuid.v4(),
      tripId: Value(tripId),
      recordedAt: activity.recordedAt,
      activityType: activity.type.name,
      transitionType: Value(activity.transition.name),
      confidence: Value(activity.confidence),
      platformSource: activity.platformSource,
      rawPayload: Value(activity.rawValue),
    ),
  );

  @override
  Future<void> addSensorSamples(
    String tripId,
    List<CollectedSensorSample> samples,
  ) => local.insertSensorSamples([
    for (final s in samples)
      SensorSamplesCompanion.insert(
        id: _uuid.v4(),
        tripId: tripId,
        recordedAt: s.recordedAt,
        accelerometerX: Value(s.accelerometerX),
        accelerometerY: Value(s.accelerometerY),
        accelerometerZ: Value(s.accelerometerZ),
        gyroscopeX: Value(s.gyroscopeX),
        gyroscopeY: Value(s.gyroscopeY),
        gyroscopeZ: Value(s.gyroscopeZ),
        magnetometerX: Value(s.magnetometerX),
        magnetometerY: Value(s.magnetometerY),
        magnetometerZ: Value(s.magnetometerZ),
        deviceOrientation: Value(s.deviceOrientation),
        samplingRate: Value(s.samplingRateHz),
        speed: Value(s.speed),
        activityState: Value(s.activityState),
      ),
  ]);
}
