import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/enums.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Tables
// ---------------------------------------------------------------------------

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text()();
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();

  /// Persisted [TripRecordingState] name. Active states allow crash recovery.
  TextColumn get status => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get startLatitude => real().nullable()();
  RealColumn get startLongitude => real().nullable()();
  RealColumn get endLatitude => real().nullable()();
  RealColumn get endLongitude => real().nullable()();
  TextColumn get startAddress => text().nullable()();
  TextColumn get endAddress => text().nullable()();
  RealColumn get distanceMeters => real().withDefault(const Constant(0))();
  IntColumn get elapsedDurationSeconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get movingDurationSeconds =>
      integer().withDefault(const Constant(0))();
  IntColumn get stoppedDurationSeconds =>
      integer().withDefault(const Constant(0))();
  RealColumn get averageSpeedKmh => real().withDefault(const Constant(0))();
  RealColumn get movingAverageSpeedKmh =>
      real().withDefault(const Constant(0))();
  RealColumn get maximumSpeedKmh => real().withDefault(const Constant(0))();
  TextColumn get detectedVehicleType =>
      text().withDefault(const Constant('unknown'))();
  TextColumn get confirmedVehicleType => text().nullable()();
  RealColumn get vehicleConfidence => real().nullable()();
  DateTimeColumn get vehicleConfirmedAt => dateTime().nullable()();
  BoolColumn get vehiclePredictionChanged => boolean().nullable()();
  IntColumn get stopCount => integer().withDefault(const Constant(0))();
  IntColumn get summaryAlgorithmVersion =>
      integer().withDefault(const Constant(0))();
  TextColumn get deviceModel => text().nullable()();
  TextColumn get operatingSystem => text().nullable()();
  TextColumn get operatingSystemVersion => text().nullable()();
  TextColumn get appVersion => text().nullable()();
  TextColumn get phoneMountPosition => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class TripPoints extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  RealColumn get horizontalAccuracy => real().nullable()();
  RealColumn get verticalAccuracy => real().nullable()();

  /// Speed in m/s as reported by the platform.
  RealColumn get speed => real().nullable()();
  RealColumn get speedAccuracy => real().nullable()();
  RealColumn get heading => real().nullable()();
  RealColumn get headingAccuracy => real().nullable()();
  IntColumn get sequenceNumber => integer()();
  TextColumn get source => text().nullable()();
  BoolColumn get isMocked => boolean().nullable()();
  RealColumn get batteryLevel => real().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class ActivityEvents extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().nullable()();
  DateTimeColumn get recordedAt => dateTime()();
  TextColumn get activityType => text()();
  TextColumn get transitionType => text().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get platformSource => text()();
  TextColumn get rawPayload => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

class SensorSamples extends Table {
  TextColumn get id => text()();
  TextColumn get tripId => text().references(Trips, #id)();
  DateTimeColumn get recordedAt => dateTime()();
  RealColumn get accelerometerX => real().nullable()();
  RealColumn get accelerometerY => real().nullable()();
  RealColumn get accelerometerZ => real().nullable()();
  RealColumn get gyroscopeX => real().nullable()();
  RealColumn get gyroscopeY => real().nullable()();
  RealColumn get gyroscopeZ => real().nullable()();
  RealColumn get magnetometerX => real().nullable()();
  RealColumn get magnetometerY => real().nullable()();
  RealColumn get magnetometerZ => real().nullable()();
  TextColumn get deviceOrientation => text().nullable()();
  RealColumn get samplingRate => real().nullable()();
  RealColumn get speed => real().nullable()();
  TextColumn get activityState => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [Users, Trips, TripPoints, ActivityEvents, SensorSamples],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  AppDatabase.open() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
        },
        onUpgrade: (m, from, to) async {
          // Versioned, additive migrations. Example for a future version 2:
          // if (from < 2) {
          //   await m.addColumn(trips, trips.someNewColumn);
          // }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_trip_points_trip '
      'ON trip_points (trip_id, sequence_number)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_trips_user_started '
      'ON trips (user_id, started_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_sensor_samples_trip '
      'ON sensor_samples (trip_id, recorded_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_activity_events_time '
      'ON activity_events (recorded_at DESC)',
    );
  }

  /// Trips in an active state — used for crash recovery on app start.
  Future<List<Trip>> activeTrips() {
    final active = [
      TripRecordingState.recording.name,
      TripRecordingState.temporarilyStopped.name,
      TripRecordingState.finishing.name,
    ];
    return (select(trips)..where((t) => t.status.isIn(active))).get();
  }

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final dir = await getApplicationDocumentsDirectory();
      final file = File(p.join(dir.path, 'triplog.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
