import 'package:drift/drift.dart';

import '../../../core/constants/enums.dart';
import '../../../core/storage/app_database.dart';

/// Contract for local persistence so the repository can be tested against an
/// in-memory database.
abstract interface class LocalTripDataSource {
  Future<void> upsertTrip(TripsCompanion trip);
  Future<Trip?> getTrip(String id);
  Stream<List<Trip>> watchTripsForUser(String userId);
  Future<List<Trip>> tripsForUser(String userId);
  Future<List<Trip>> activeTrips();
  Future<void> deleteTrip(String id);
  Future<void> deleteAllData();

  Future<void> insertPoints(List<TripPointsCompanion> points);
  Future<List<TripPoint>> pointsForTrip(String tripId);
  Future<int> pointCountForTrip(String tripId);

  Future<void> insertActivityEvent(ActivityEventsCompanion event);
  Future<void> insertSensorSamples(List<SensorSamplesCompanion> samples);
  Future<List<SensorSample>> sensorSamplesForTrip(String tripId);
  Future<List<ActivityEvent>> activityEventsForTrip(String tripId);

  Future<List<Trip>> tripsWithSyncStatus(
    String userId,
    List<SyncStatus> statuses,
  );
  Future<void> setTripSyncStatus(String tripId, SyncStatus status);
  Future<void> setPointsSyncStatus(String tripId, SyncStatus status);
  Future<void> setSensorSamplesSyncStatus(String tripId, SyncStatus status);
  Future<void> setActivityEventsSyncStatus(List<String> ids, SyncStatus status);
  Future<bool> hasUnsyncedData(String userId);

  Future<void> upsertUser(UsersCompanion user);

  /// Aggregate totals for the dashboard: (tripCount, totalDistanceMeters).
  Future<(int, double)> totalsForUser(String userId);
}

/// Drift-backed implementation.
class DriftTripDataSource implements LocalTripDataSource {
  DriftTripDataSource(this.db);

  final AppDatabase db;

  static const _finishedStatus = 'finished';

  @override
  Future<void> upsertTrip(TripsCompanion trip) =>
      db.into(db.trips).insertOnConflictUpdate(trip);

  @override
  Future<Trip?> getTrip(String id) =>
      (db.select(db.trips)..where((t) => t.id.equals(id))).getSingleOrNull();

  @override
  Stream<List<Trip>> watchTripsForUser(String userId) =>
      (db.select(db.trips)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .watch();

  @override
  Future<List<Trip>> tripsForUser(String userId) =>
      (db.select(db.trips)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .get();

  @override
  Future<List<Trip>> activeTrips() => db.activeTrips();

  @override
  Future<void> deleteTrip(String id) async {
    await db.transaction(() async {
      await (db.delete(db.tripPoints)..where((p) => p.tripId.equals(id))).go();
      await (db.delete(
        db.sensorSamples,
      )..where((s) => s.tripId.equals(id))).go();
      await (db.delete(
        db.activityEvents,
      )..where((e) => e.tripId.equals(id))).go();
      await (db.delete(db.trips)..where((t) => t.id.equals(id))).go();
    });
  }

  @override
  Future<void> deleteAllData() async {
    await db.transaction(() async {
      await db.delete(db.tripPoints).go();
      await db.delete(db.sensorSamples).go();
      await db.delete(db.activityEvents).go();
      await db.delete(db.trips).go();
    });
  }

  @override
  Future<void> insertPoints(List<TripPointsCompanion> points) =>
      db.batch((b) => b.insertAllOnConflictUpdate(db.tripPoints, points));

  @override
  Future<List<TripPoint>> pointsForTrip(String tripId) =>
      (db.select(db.tripPoints)
            ..where((p) => p.tripId.equals(tripId))
            ..orderBy([(p) => OrderingTerm.asc(p.sequenceNumber)]))
          .get();

  @override
  Future<int> pointCountForTrip(String tripId) async {
    final count = db.tripPoints.id.count();
    final query = db.selectOnly(db.tripPoints)
      ..addColumns([count])
      ..where(db.tripPoints.tripId.equals(tripId));
    final row = await query.getSingle();
    return row.read(count) ?? 0;
  }

  @override
  Future<void> insertActivityEvent(ActivityEventsCompanion event) =>
      db.into(db.activityEvents).insertOnConflictUpdate(event);

  @override
  Future<void> insertSensorSamples(List<SensorSamplesCompanion> samples) =>
      db.batch((b) => b.insertAllOnConflictUpdate(db.sensorSamples, samples));

  @override
  Future<List<SensorSample>> sensorSamplesForTrip(String tripId) =>
      (db.select(db.sensorSamples)
            ..where((s) => s.tripId.equals(tripId))
            ..orderBy([(s) => OrderingTerm.asc(s.recordedAt)]))
          .get();

  @override
  Future<List<ActivityEvent>> activityEventsForTrip(String tripId) =>
      (db.select(db.activityEvents)
            ..where((e) => e.tripId.equals(tripId))
            ..orderBy([(e) => OrderingTerm.asc(e.recordedAt)]))
          .get();

  @override
  Future<List<Trip>> tripsWithSyncStatus(
    String userId,
    List<SyncStatus> statuses,
  ) =>
      (db.select(db.trips)..where(
            (t) =>
                t.userId.equals(userId) &
                t.syncStatus.isIn(statuses.map((s) => s.name).toList()) &
                t.status.equals(_finishedStatus),
          ))
          .get();

  @override
  Future<void> setTripSyncStatus(String tripId, SyncStatus status) =>
      (db.update(db.trips)..where((t) => t.id.equals(tripId))).write(
        TripsCompanion(syncStatus: Value(status.name)),
      );

  @override
  Future<void> setPointsSyncStatus(String tripId, SyncStatus status) =>
      (db.update(db.tripPoints)..where((p) => p.tripId.equals(tripId))).write(
        TripPointsCompanion(syncStatus: Value(status.name)),
      );

  @override
  Future<void> setSensorSamplesSyncStatus(String tripId, SyncStatus status) =>
      (db.update(db.sensorSamples)..where((s) => s.tripId.equals(tripId)))
          .write(SensorSamplesCompanion(syncStatus: Value(status.name)));

  @override
  Future<void> setActivityEventsSyncStatus(
    List<String> ids,
    SyncStatus status,
  ) => (db.update(db.activityEvents)..where((e) => e.id.isIn(ids))).write(
    ActivityEventsCompanion(syncStatus: Value(status.name)),
  );

  @override
  Future<bool> hasUnsyncedData(String userId) async {
    final pending = await tripsWithSyncStatus(userId, [
      SyncStatus.pending,
      SyncStatus.failed,
      SyncStatus.syncing,
    ]);
    return pending.isNotEmpty;
  }

  @override
  Future<void> upsertUser(UsersCompanion user) =>
      db.into(db.users).insertOnConflictUpdate(user);

  @override
  Future<(int, double)> totalsForUser(String userId) async {
    final count = db.trips.id.count();
    final distance = db.trips.distanceMeters.sum();
    final query = db.selectOnly(db.trips)
      ..addColumns([count, distance])
      ..where(
        db.trips.userId.equals(userId) &
            db.trips.status.equals(_finishedStatus),
      );
    final row = await query.getSingle();
    return (row.read(count) ?? 0, row.read(distance) ?? 0.0);
  }
}
