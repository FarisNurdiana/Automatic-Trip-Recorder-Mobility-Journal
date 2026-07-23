// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    email,
    displayName,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime updatedAt;
  const User({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || displayName != null) {
      map['display_name'] = Variable<String>(displayName);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      email: Value(email),
      displayName: displayName == null && nullToAbsent
          ? const Value.absent()
          : Value(displayName),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<String>(json['id']),
      email: serializer.fromJson<String>(json['email']),
      displayName: serializer.fromJson<String?>(json['displayName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'email': serializer.toJson<String>(email),
      'displayName': serializer.toJson<String?>(displayName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  User copyWith({
    String? id,
    String? email,
    Value<String?> displayName = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => User(
    id: id ?? this.id,
    email: email ?? this.email,
    displayName: displayName.present ? displayName.value : this.displayName,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      email: data.email.present ? data.email.value : this.email,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, email, displayName, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.email == this.email &&
          other.displayName == this.displayName &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<String> id;
  final Value<String> email;
  final Value<String?> displayName;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.email = const Value.absent(),
    this.displayName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UsersCompanion.insert({
    required String id,
    required String email,
    this.displayName = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<User> custom({
    Expression<String>? id,
    Expression<String>? email,
    Expression<String>? displayName,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (email != null) 'email': email,
      if (displayName != null) 'display_name': displayName,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UsersCompanion copyWith({
    Value<String>? id,
    Value<String>? email,
    Value<String?>? displayName,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('email: $email, ')
          ..write('displayName: $displayName, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripsTable extends Trips with TableInfo<$TripsTable, Trip> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startLatitudeMeta = const VerificationMeta(
    'startLatitude',
  );
  @override
  late final GeneratedColumn<double> startLatitude = GeneratedColumn<double>(
    'start_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startLongitudeMeta = const VerificationMeta(
    'startLongitude',
  );
  @override
  late final GeneratedColumn<double> startLongitude = GeneratedColumn<double>(
    'start_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endLatitudeMeta = const VerificationMeta(
    'endLatitude',
  );
  @override
  late final GeneratedColumn<double> endLatitude = GeneratedColumn<double>(
    'end_latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endLongitudeMeta = const VerificationMeta(
    'endLongitude',
  );
  @override
  late final GeneratedColumn<double> endLongitude = GeneratedColumn<double>(
    'end_longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startAddressMeta = const VerificationMeta(
    'startAddress',
  );
  @override
  late final GeneratedColumn<String> startAddress = GeneratedColumn<String>(
    'start_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endAddressMeta = const VerificationMeta(
    'endAddress',
  );
  @override
  late final GeneratedColumn<String> endAddress = GeneratedColumn<String>(
    'end_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<double> distanceMeters = GeneratedColumn<double>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elapsedDurationSecondsMeta =
      const VerificationMeta('elapsedDurationSeconds');
  @override
  late final GeneratedColumn<int> elapsedDurationSeconds = GeneratedColumn<int>(
    'elapsed_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movingDurationSecondsMeta =
      const VerificationMeta('movingDurationSeconds');
  @override
  late final GeneratedColumn<int> movingDurationSeconds = GeneratedColumn<int>(
    'moving_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stoppedDurationSecondsMeta =
      const VerificationMeta('stoppedDurationSeconds');
  @override
  late final GeneratedColumn<int> stoppedDurationSeconds = GeneratedColumn<int>(
    'stopped_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _averageSpeedKmhMeta = const VerificationMeta(
    'averageSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> averageSpeedKmh = GeneratedColumn<double>(
    'average_speed_kmh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _movingAverageSpeedKmhMeta =
      const VerificationMeta('movingAverageSpeedKmh');
  @override
  late final GeneratedColumn<double> movingAverageSpeedKmh =
      GeneratedColumn<double>(
        'moving_average_speed_kmh',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _maximumSpeedKmhMeta = const VerificationMeta(
    'maximumSpeedKmh',
  );
  @override
  late final GeneratedColumn<double> maximumSpeedKmh = GeneratedColumn<double>(
    'maximum_speed_kmh',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _detectedVehicleTypeMeta =
      const VerificationMeta('detectedVehicleType');
  @override
  late final GeneratedColumn<String> detectedVehicleType =
      GeneratedColumn<String>(
        'detected_vehicle_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('unknown'),
      );
  static const VerificationMeta _confirmedVehicleTypeMeta =
      const VerificationMeta('confirmedVehicleType');
  @override
  late final GeneratedColumn<String> confirmedVehicleType =
      GeneratedColumn<String>(
        'confirmed_vehicle_type',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vehicleConfidenceMeta = const VerificationMeta(
    'vehicleConfidence',
  );
  @override
  late final GeneratedColumn<double> vehicleConfidence =
      GeneratedColumn<double>(
        'vehicle_confidence',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vehicleConfirmedAtMeta =
      const VerificationMeta('vehicleConfirmedAt');
  @override
  late final GeneratedColumn<DateTime> vehicleConfirmedAt =
      GeneratedColumn<DateTime>(
        'vehicle_confirmed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _vehiclePredictionChangedMeta =
      const VerificationMeta('vehiclePredictionChanged');
  @override
  late final GeneratedColumn<bool> vehiclePredictionChanged =
      GeneratedColumn<bool>(
        'vehicle_prediction_changed',
        aliasedName,
        true,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("vehicle_prediction_changed" IN (0, 1))',
        ),
      );
  static const VerificationMeta _stopCountMeta = const VerificationMeta(
    'stopCount',
  );
  @override
  late final GeneratedColumn<int> stopCount = GeneratedColumn<int>(
    'stop_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _summaryAlgorithmVersionMeta =
      const VerificationMeta('summaryAlgorithmVersion');
  @override
  late final GeneratedColumn<int> summaryAlgorithmVersion =
      GeneratedColumn<int>(
        'summary_algorithm_version',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _finishedAutomaticallyMeta =
      const VerificationMeta('finishedAutomatically');
  @override
  late final GeneratedColumn<bool> finishedAutomatically =
      GeneratedColumn<bool>(
        'finished_automatically',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("finished_automatically" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _finishReasonMeta = const VerificationMeta(
    'finishReason',
  );
  @override
  late final GeneratedColumn<String> finishReason = GeneratedColumn<String>(
    'finish_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arrivalCorrectedByUserMeta =
      const VerificationMeta('arrivalCorrectedByUser');
  @override
  late final GeneratedColumn<bool> arrivalCorrectedByUser =
      GeneratedColumn<bool>(
        'arrival_corrected_by_user',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("arrival_corrected_by_user" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _deviceModelMeta = const VerificationMeta(
    'deviceModel',
  );
  @override
  late final GeneratedColumn<String> deviceModel = GeneratedColumn<String>(
    'device_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operatingSystemMeta = const VerificationMeta(
    'operatingSystem',
  );
  @override
  late final GeneratedColumn<String> operatingSystem = GeneratedColumn<String>(
    'operating_system',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _operatingSystemVersionMeta =
      const VerificationMeta('operatingSystemVersion');
  @override
  late final GeneratedColumn<String> operatingSystemVersion =
      GeneratedColumn<String>(
        'operating_system_version',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMountPositionMeta =
      const VerificationMeta('phoneMountPosition');
  @override
  late final GeneratedColumn<String> phoneMountPosition =
      GeneratedColumn<String>(
        'phone_mount_position',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    status,
    startedAt,
    endedAt,
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
    startAddress,
    endAddress,
    distanceMeters,
    elapsedDurationSeconds,
    movingDurationSeconds,
    stoppedDurationSeconds,
    averageSpeedKmh,
    movingAverageSpeedKmh,
    maximumSpeedKmh,
    detectedVehicleType,
    confirmedVehicleType,
    vehicleConfidence,
    vehicleConfirmedAt,
    vehiclePredictionChanged,
    stopCount,
    summaryAlgorithmVersion,
    finishedAutomatically,
    finishReason,
    arrivalCorrectedByUser,
    deviceModel,
    operatingSystem,
    operatingSystemVersion,
    appVersion,
    phoneMountPosition,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trips';
  @override
  VerificationContext validateIntegrity(
    Insertable<Trip> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('start_latitude')) {
      context.handle(
        _startLatitudeMeta,
        startLatitude.isAcceptableOrUnknown(
          data['start_latitude']!,
          _startLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('start_longitude')) {
      context.handle(
        _startLongitudeMeta,
        startLongitude.isAcceptableOrUnknown(
          data['start_longitude']!,
          _startLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('end_latitude')) {
      context.handle(
        _endLatitudeMeta,
        endLatitude.isAcceptableOrUnknown(
          data['end_latitude']!,
          _endLatitudeMeta,
        ),
      );
    }
    if (data.containsKey('end_longitude')) {
      context.handle(
        _endLongitudeMeta,
        endLongitude.isAcceptableOrUnknown(
          data['end_longitude']!,
          _endLongitudeMeta,
        ),
      );
    }
    if (data.containsKey('start_address')) {
      context.handle(
        _startAddressMeta,
        startAddress.isAcceptableOrUnknown(
          data['start_address']!,
          _startAddressMeta,
        ),
      );
    }
    if (data.containsKey('end_address')) {
      context.handle(
        _endAddressMeta,
        endAddress.isAcceptableOrUnknown(data['end_address']!, _endAddressMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('elapsed_duration_seconds')) {
      context.handle(
        _elapsedDurationSecondsMeta,
        elapsedDurationSeconds.isAcceptableOrUnknown(
          data['elapsed_duration_seconds']!,
          _elapsedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('moving_duration_seconds')) {
      context.handle(
        _movingDurationSecondsMeta,
        movingDurationSeconds.isAcceptableOrUnknown(
          data['moving_duration_seconds']!,
          _movingDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('stopped_duration_seconds')) {
      context.handle(
        _stoppedDurationSecondsMeta,
        stoppedDurationSeconds.isAcceptableOrUnknown(
          data['stopped_duration_seconds']!,
          _stoppedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('average_speed_kmh')) {
      context.handle(
        _averageSpeedKmhMeta,
        averageSpeedKmh.isAcceptableOrUnknown(
          data['average_speed_kmh']!,
          _averageSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('moving_average_speed_kmh')) {
      context.handle(
        _movingAverageSpeedKmhMeta,
        movingAverageSpeedKmh.isAcceptableOrUnknown(
          data['moving_average_speed_kmh']!,
          _movingAverageSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('maximum_speed_kmh')) {
      context.handle(
        _maximumSpeedKmhMeta,
        maximumSpeedKmh.isAcceptableOrUnknown(
          data['maximum_speed_kmh']!,
          _maximumSpeedKmhMeta,
        ),
      );
    }
    if (data.containsKey('detected_vehicle_type')) {
      context.handle(
        _detectedVehicleTypeMeta,
        detectedVehicleType.isAcceptableOrUnknown(
          data['detected_vehicle_type']!,
          _detectedVehicleTypeMeta,
        ),
      );
    }
    if (data.containsKey('confirmed_vehicle_type')) {
      context.handle(
        _confirmedVehicleTypeMeta,
        confirmedVehicleType.isAcceptableOrUnknown(
          data['confirmed_vehicle_type']!,
          _confirmedVehicleTypeMeta,
        ),
      );
    }
    if (data.containsKey('vehicle_confidence')) {
      context.handle(
        _vehicleConfidenceMeta,
        vehicleConfidence.isAcceptableOrUnknown(
          data['vehicle_confidence']!,
          _vehicleConfidenceMeta,
        ),
      );
    }
    if (data.containsKey('vehicle_confirmed_at')) {
      context.handle(
        _vehicleConfirmedAtMeta,
        vehicleConfirmedAt.isAcceptableOrUnknown(
          data['vehicle_confirmed_at']!,
          _vehicleConfirmedAtMeta,
        ),
      );
    }
    if (data.containsKey('vehicle_prediction_changed')) {
      context.handle(
        _vehiclePredictionChangedMeta,
        vehiclePredictionChanged.isAcceptableOrUnknown(
          data['vehicle_prediction_changed']!,
          _vehiclePredictionChangedMeta,
        ),
      );
    }
    if (data.containsKey('stop_count')) {
      context.handle(
        _stopCountMeta,
        stopCount.isAcceptableOrUnknown(data['stop_count']!, _stopCountMeta),
      );
    }
    if (data.containsKey('summary_algorithm_version')) {
      context.handle(
        _summaryAlgorithmVersionMeta,
        summaryAlgorithmVersion.isAcceptableOrUnknown(
          data['summary_algorithm_version']!,
          _summaryAlgorithmVersionMeta,
        ),
      );
    }
    if (data.containsKey('finished_automatically')) {
      context.handle(
        _finishedAutomaticallyMeta,
        finishedAutomatically.isAcceptableOrUnknown(
          data['finished_automatically']!,
          _finishedAutomaticallyMeta,
        ),
      );
    }
    if (data.containsKey('finish_reason')) {
      context.handle(
        _finishReasonMeta,
        finishReason.isAcceptableOrUnknown(
          data['finish_reason']!,
          _finishReasonMeta,
        ),
      );
    }
    if (data.containsKey('arrival_corrected_by_user')) {
      context.handle(
        _arrivalCorrectedByUserMeta,
        arrivalCorrectedByUser.isAcceptableOrUnknown(
          data['arrival_corrected_by_user']!,
          _arrivalCorrectedByUserMeta,
        ),
      );
    }
    if (data.containsKey('device_model')) {
      context.handle(
        _deviceModelMeta,
        deviceModel.isAcceptableOrUnknown(
          data['device_model']!,
          _deviceModelMeta,
        ),
      );
    }
    if (data.containsKey('operating_system')) {
      context.handle(
        _operatingSystemMeta,
        operatingSystem.isAcceptableOrUnknown(
          data['operating_system']!,
          _operatingSystemMeta,
        ),
      );
    }
    if (data.containsKey('operating_system_version')) {
      context.handle(
        _operatingSystemVersionMeta,
        operatingSystemVersion.isAcceptableOrUnknown(
          data['operating_system_version']!,
          _operatingSystemVersionMeta,
        ),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    if (data.containsKey('phone_mount_position')) {
      context.handle(
        _phoneMountPositionMeta,
        phoneMountPosition.isAcceptableOrUnknown(
          data['phone_mount_position']!,
          _phoneMountPositionMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Trip map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Trip(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      startLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_latitude'],
      ),
      startLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}start_longitude'],
      ),
      endLatitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_latitude'],
      ),
      endLongitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}end_longitude'],
      ),
      startAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_address'],
      ),
      endAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_address'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}distance_meters'],
      )!,
      elapsedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}elapsed_duration_seconds'],
      )!,
      movingDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}moving_duration_seconds'],
      )!,
      stoppedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stopped_duration_seconds'],
      )!,
      averageSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_speed_kmh'],
      )!,
      movingAverageSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}moving_average_speed_kmh'],
      )!,
      maximumSpeedKmh: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}maximum_speed_kmh'],
      )!,
      detectedVehicleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}detected_vehicle_type'],
      )!,
      confirmedVehicleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}confirmed_vehicle_type'],
      ),
      vehicleConfidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vehicle_confidence'],
      ),
      vehicleConfirmedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}vehicle_confirmed_at'],
      ),
      vehiclePredictionChanged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}vehicle_prediction_changed'],
      ),
      stopCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stop_count'],
      )!,
      summaryAlgorithmVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}summary_algorithm_version'],
      )!,
      finishedAutomatically: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}finished_automatically'],
      )!,
      finishReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}finish_reason'],
      ),
      arrivalCorrectedByUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}arrival_corrected_by_user'],
      )!,
      deviceModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_model'],
      ),
      operatingSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operating_system'],
      ),
      operatingSystemVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operating_system_version'],
      ),
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      ),
      phoneMountPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone_mount_position'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TripsTable createAlias(String alias) {
    return $TripsTable(attachedDatabase, alias);
  }
}

class Trip extends DataClass implements Insertable<Trip> {
  final String id;
  final String userId;

  /// Persisted [TripRecordingState] name. Active states allow crash recovery.
  final String status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;
  final String? startAddress;
  final String? endAddress;
  final double distanceMeters;
  final int elapsedDurationSeconds;
  final int movingDurationSeconds;
  final int stoppedDurationSeconds;
  final double averageSpeedKmh;
  final double movingAverageSpeedKmh;
  final double maximumSpeedKmh;
  final String detectedVehicleType;
  final String? confirmedVehicleType;
  final double? vehicleConfidence;
  final DateTime? vehicleConfirmedAt;
  final bool? vehiclePredictionChanged;
  final int stopCount;
  final int summaryAlgorithmVersion;

  /// True when the trip was closed by the auto-finish rules (e.g. stationary
  /// for hours) instead of an explicit user/detector finish.
  final bool finishedAutomatically;

  /// Machine-readable reason: manual, autoDetection, arrivedAnswer,
  /// autoStationary5h, ...
  final String? finishReason;

  /// True when the user edited the arrival time after an automatic finish.
  final bool arrivalCorrectedByUser;
  final String? deviceModel;
  final String? operatingSystem;
  final String? operatingSystemVersion;
  final String? appVersion;
  final String? phoneMountPosition;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Trip({
    required this.id,
    required this.userId,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.startAddress,
    this.endAddress,
    required this.distanceMeters,
    required this.elapsedDurationSeconds,
    required this.movingDurationSeconds,
    required this.stoppedDurationSeconds,
    required this.averageSpeedKmh,
    required this.movingAverageSpeedKmh,
    required this.maximumSpeedKmh,
    required this.detectedVehicleType,
    this.confirmedVehicleType,
    this.vehicleConfidence,
    this.vehicleConfirmedAt,
    this.vehiclePredictionChanged,
    required this.stopCount,
    required this.summaryAlgorithmVersion,
    required this.finishedAutomatically,
    this.finishReason,
    required this.arrivalCorrectedByUser,
    this.deviceModel,
    this.operatingSystem,
    this.operatingSystemVersion,
    this.appVersion,
    this.phoneMountPosition,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['status'] = Variable<String>(status);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || startLatitude != null) {
      map['start_latitude'] = Variable<double>(startLatitude);
    }
    if (!nullToAbsent || startLongitude != null) {
      map['start_longitude'] = Variable<double>(startLongitude);
    }
    if (!nullToAbsent || endLatitude != null) {
      map['end_latitude'] = Variable<double>(endLatitude);
    }
    if (!nullToAbsent || endLongitude != null) {
      map['end_longitude'] = Variable<double>(endLongitude);
    }
    if (!nullToAbsent || startAddress != null) {
      map['start_address'] = Variable<String>(startAddress);
    }
    if (!nullToAbsent || endAddress != null) {
      map['end_address'] = Variable<String>(endAddress);
    }
    map['distance_meters'] = Variable<double>(distanceMeters);
    map['elapsed_duration_seconds'] = Variable<int>(elapsedDurationSeconds);
    map['moving_duration_seconds'] = Variable<int>(movingDurationSeconds);
    map['stopped_duration_seconds'] = Variable<int>(stoppedDurationSeconds);
    map['average_speed_kmh'] = Variable<double>(averageSpeedKmh);
    map['moving_average_speed_kmh'] = Variable<double>(movingAverageSpeedKmh);
    map['maximum_speed_kmh'] = Variable<double>(maximumSpeedKmh);
    map['detected_vehicle_type'] = Variable<String>(detectedVehicleType);
    if (!nullToAbsent || confirmedVehicleType != null) {
      map['confirmed_vehicle_type'] = Variable<String>(confirmedVehicleType);
    }
    if (!nullToAbsent || vehicleConfidence != null) {
      map['vehicle_confidence'] = Variable<double>(vehicleConfidence);
    }
    if (!nullToAbsent || vehicleConfirmedAt != null) {
      map['vehicle_confirmed_at'] = Variable<DateTime>(vehicleConfirmedAt);
    }
    if (!nullToAbsent || vehiclePredictionChanged != null) {
      map['vehicle_prediction_changed'] = Variable<bool>(
        vehiclePredictionChanged,
      );
    }
    map['stop_count'] = Variable<int>(stopCount);
    map['summary_algorithm_version'] = Variable<int>(summaryAlgorithmVersion);
    map['finished_automatically'] = Variable<bool>(finishedAutomatically);
    if (!nullToAbsent || finishReason != null) {
      map['finish_reason'] = Variable<String>(finishReason);
    }
    map['arrival_corrected_by_user'] = Variable<bool>(arrivalCorrectedByUser);
    if (!nullToAbsent || deviceModel != null) {
      map['device_model'] = Variable<String>(deviceModel);
    }
    if (!nullToAbsent || operatingSystem != null) {
      map['operating_system'] = Variable<String>(operatingSystem);
    }
    if (!nullToAbsent || operatingSystemVersion != null) {
      map['operating_system_version'] = Variable<String>(
        operatingSystemVersion,
      );
    }
    if (!nullToAbsent || appVersion != null) {
      map['app_version'] = Variable<String>(appVersion);
    }
    if (!nullToAbsent || phoneMountPosition != null) {
      map['phone_mount_position'] = Variable<String>(phoneMountPosition);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TripsCompanion toCompanion(bool nullToAbsent) {
    return TripsCompanion(
      id: Value(id),
      userId: Value(userId),
      status: Value(status),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      startLatitude: startLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(startLatitude),
      startLongitude: startLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(startLongitude),
      endLatitude: endLatitude == null && nullToAbsent
          ? const Value.absent()
          : Value(endLatitude),
      endLongitude: endLongitude == null && nullToAbsent
          ? const Value.absent()
          : Value(endLongitude),
      startAddress: startAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(startAddress),
      endAddress: endAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(endAddress),
      distanceMeters: Value(distanceMeters),
      elapsedDurationSeconds: Value(elapsedDurationSeconds),
      movingDurationSeconds: Value(movingDurationSeconds),
      stoppedDurationSeconds: Value(stoppedDurationSeconds),
      averageSpeedKmh: Value(averageSpeedKmh),
      movingAverageSpeedKmh: Value(movingAverageSpeedKmh),
      maximumSpeedKmh: Value(maximumSpeedKmh),
      detectedVehicleType: Value(detectedVehicleType),
      confirmedVehicleType: confirmedVehicleType == null && nullToAbsent
          ? const Value.absent()
          : Value(confirmedVehicleType),
      vehicleConfidence: vehicleConfidence == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleConfidence),
      vehicleConfirmedAt: vehicleConfirmedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleConfirmedAt),
      vehiclePredictionChanged: vehiclePredictionChanged == null && nullToAbsent
          ? const Value.absent()
          : Value(vehiclePredictionChanged),
      stopCount: Value(stopCount),
      summaryAlgorithmVersion: Value(summaryAlgorithmVersion),
      finishedAutomatically: Value(finishedAutomatically),
      finishReason: finishReason == null && nullToAbsent
          ? const Value.absent()
          : Value(finishReason),
      arrivalCorrectedByUser: Value(arrivalCorrectedByUser),
      deviceModel: deviceModel == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceModel),
      operatingSystem: operatingSystem == null && nullToAbsent
          ? const Value.absent()
          : Value(operatingSystem),
      operatingSystemVersion: operatingSystemVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(operatingSystemVersion),
      appVersion: appVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(appVersion),
      phoneMountPosition: phoneMountPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(phoneMountPosition),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Trip.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Trip(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      status: serializer.fromJson<String>(json['status']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      startLatitude: serializer.fromJson<double?>(json['startLatitude']),
      startLongitude: serializer.fromJson<double?>(json['startLongitude']),
      endLatitude: serializer.fromJson<double?>(json['endLatitude']),
      endLongitude: serializer.fromJson<double?>(json['endLongitude']),
      startAddress: serializer.fromJson<String?>(json['startAddress']),
      endAddress: serializer.fromJson<String?>(json['endAddress']),
      distanceMeters: serializer.fromJson<double>(json['distanceMeters']),
      elapsedDurationSeconds: serializer.fromJson<int>(
        json['elapsedDurationSeconds'],
      ),
      movingDurationSeconds: serializer.fromJson<int>(
        json['movingDurationSeconds'],
      ),
      stoppedDurationSeconds: serializer.fromJson<int>(
        json['stoppedDurationSeconds'],
      ),
      averageSpeedKmh: serializer.fromJson<double>(json['averageSpeedKmh']),
      movingAverageSpeedKmh: serializer.fromJson<double>(
        json['movingAverageSpeedKmh'],
      ),
      maximumSpeedKmh: serializer.fromJson<double>(json['maximumSpeedKmh']),
      detectedVehicleType: serializer.fromJson<String>(
        json['detectedVehicleType'],
      ),
      confirmedVehicleType: serializer.fromJson<String?>(
        json['confirmedVehicleType'],
      ),
      vehicleConfidence: serializer.fromJson<double?>(
        json['vehicleConfidence'],
      ),
      vehicleConfirmedAt: serializer.fromJson<DateTime?>(
        json['vehicleConfirmedAt'],
      ),
      vehiclePredictionChanged: serializer.fromJson<bool?>(
        json['vehiclePredictionChanged'],
      ),
      stopCount: serializer.fromJson<int>(json['stopCount']),
      summaryAlgorithmVersion: serializer.fromJson<int>(
        json['summaryAlgorithmVersion'],
      ),
      finishedAutomatically: serializer.fromJson<bool>(
        json['finishedAutomatically'],
      ),
      finishReason: serializer.fromJson<String?>(json['finishReason']),
      arrivalCorrectedByUser: serializer.fromJson<bool>(
        json['arrivalCorrectedByUser'],
      ),
      deviceModel: serializer.fromJson<String?>(json['deviceModel']),
      operatingSystem: serializer.fromJson<String?>(json['operatingSystem']),
      operatingSystemVersion: serializer.fromJson<String?>(
        json['operatingSystemVersion'],
      ),
      appVersion: serializer.fromJson<String?>(json['appVersion']),
      phoneMountPosition: serializer.fromJson<String?>(
        json['phoneMountPosition'],
      ),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'status': serializer.toJson<String>(status),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'startLatitude': serializer.toJson<double?>(startLatitude),
      'startLongitude': serializer.toJson<double?>(startLongitude),
      'endLatitude': serializer.toJson<double?>(endLatitude),
      'endLongitude': serializer.toJson<double?>(endLongitude),
      'startAddress': serializer.toJson<String?>(startAddress),
      'endAddress': serializer.toJson<String?>(endAddress),
      'distanceMeters': serializer.toJson<double>(distanceMeters),
      'elapsedDurationSeconds': serializer.toJson<int>(elapsedDurationSeconds),
      'movingDurationSeconds': serializer.toJson<int>(movingDurationSeconds),
      'stoppedDurationSeconds': serializer.toJson<int>(stoppedDurationSeconds),
      'averageSpeedKmh': serializer.toJson<double>(averageSpeedKmh),
      'movingAverageSpeedKmh': serializer.toJson<double>(movingAverageSpeedKmh),
      'maximumSpeedKmh': serializer.toJson<double>(maximumSpeedKmh),
      'detectedVehicleType': serializer.toJson<String>(detectedVehicleType),
      'confirmedVehicleType': serializer.toJson<String?>(confirmedVehicleType),
      'vehicleConfidence': serializer.toJson<double?>(vehicleConfidence),
      'vehicleConfirmedAt': serializer.toJson<DateTime?>(vehicleConfirmedAt),
      'vehiclePredictionChanged': serializer.toJson<bool?>(
        vehiclePredictionChanged,
      ),
      'stopCount': serializer.toJson<int>(stopCount),
      'summaryAlgorithmVersion': serializer.toJson<int>(
        summaryAlgorithmVersion,
      ),
      'finishedAutomatically': serializer.toJson<bool>(finishedAutomatically),
      'finishReason': serializer.toJson<String?>(finishReason),
      'arrivalCorrectedByUser': serializer.toJson<bool>(arrivalCorrectedByUser),
      'deviceModel': serializer.toJson<String?>(deviceModel),
      'operatingSystem': serializer.toJson<String?>(operatingSystem),
      'operatingSystemVersion': serializer.toJson<String?>(
        operatingSystemVersion,
      ),
      'appVersion': serializer.toJson<String?>(appVersion),
      'phoneMountPosition': serializer.toJson<String?>(phoneMountPosition),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Trip copyWith({
    String? id,
    String? userId,
    String? status,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<double?> startLatitude = const Value.absent(),
    Value<double?> startLongitude = const Value.absent(),
    Value<double?> endLatitude = const Value.absent(),
    Value<double?> endLongitude = const Value.absent(),
    Value<String?> startAddress = const Value.absent(),
    Value<String?> endAddress = const Value.absent(),
    double? distanceMeters,
    int? elapsedDurationSeconds,
    int? movingDurationSeconds,
    int? stoppedDurationSeconds,
    double? averageSpeedKmh,
    double? movingAverageSpeedKmh,
    double? maximumSpeedKmh,
    String? detectedVehicleType,
    Value<String?> confirmedVehicleType = const Value.absent(),
    Value<double?> vehicleConfidence = const Value.absent(),
    Value<DateTime?> vehicleConfirmedAt = const Value.absent(),
    Value<bool?> vehiclePredictionChanged = const Value.absent(),
    int? stopCount,
    int? summaryAlgorithmVersion,
    bool? finishedAutomatically,
    Value<String?> finishReason = const Value.absent(),
    bool? arrivalCorrectedByUser,
    Value<String?> deviceModel = const Value.absent(),
    Value<String?> operatingSystem = const Value.absent(),
    Value<String?> operatingSystemVersion = const Value.absent(),
    Value<String?> appVersion = const Value.absent(),
    Value<String?> phoneMountPosition = const Value.absent(),
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Trip(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    status: status ?? this.status,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    startLatitude: startLatitude.present
        ? startLatitude.value
        : this.startLatitude,
    startLongitude: startLongitude.present
        ? startLongitude.value
        : this.startLongitude,
    endLatitude: endLatitude.present ? endLatitude.value : this.endLatitude,
    endLongitude: endLongitude.present ? endLongitude.value : this.endLongitude,
    startAddress: startAddress.present ? startAddress.value : this.startAddress,
    endAddress: endAddress.present ? endAddress.value : this.endAddress,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    elapsedDurationSeconds:
        elapsedDurationSeconds ?? this.elapsedDurationSeconds,
    movingDurationSeconds: movingDurationSeconds ?? this.movingDurationSeconds,
    stoppedDurationSeconds:
        stoppedDurationSeconds ?? this.stoppedDurationSeconds,
    averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
    movingAverageSpeedKmh: movingAverageSpeedKmh ?? this.movingAverageSpeedKmh,
    maximumSpeedKmh: maximumSpeedKmh ?? this.maximumSpeedKmh,
    detectedVehicleType: detectedVehicleType ?? this.detectedVehicleType,
    confirmedVehicleType: confirmedVehicleType.present
        ? confirmedVehicleType.value
        : this.confirmedVehicleType,
    vehicleConfidence: vehicleConfidence.present
        ? vehicleConfidence.value
        : this.vehicleConfidence,
    vehicleConfirmedAt: vehicleConfirmedAt.present
        ? vehicleConfirmedAt.value
        : this.vehicleConfirmedAt,
    vehiclePredictionChanged: vehiclePredictionChanged.present
        ? vehiclePredictionChanged.value
        : this.vehiclePredictionChanged,
    stopCount: stopCount ?? this.stopCount,
    summaryAlgorithmVersion:
        summaryAlgorithmVersion ?? this.summaryAlgorithmVersion,
    finishedAutomatically: finishedAutomatically ?? this.finishedAutomatically,
    finishReason: finishReason.present ? finishReason.value : this.finishReason,
    arrivalCorrectedByUser:
        arrivalCorrectedByUser ?? this.arrivalCorrectedByUser,
    deviceModel: deviceModel.present ? deviceModel.value : this.deviceModel,
    operatingSystem: operatingSystem.present
        ? operatingSystem.value
        : this.operatingSystem,
    operatingSystemVersion: operatingSystemVersion.present
        ? operatingSystemVersion.value
        : this.operatingSystemVersion,
    appVersion: appVersion.present ? appVersion.value : this.appVersion,
    phoneMountPosition: phoneMountPosition.present
        ? phoneMountPosition.value
        : this.phoneMountPosition,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Trip copyWithCompanion(TripsCompanion data) {
    return Trip(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      status: data.status.present ? data.status.value : this.status,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      startLatitude: data.startLatitude.present
          ? data.startLatitude.value
          : this.startLatitude,
      startLongitude: data.startLongitude.present
          ? data.startLongitude.value
          : this.startLongitude,
      endLatitude: data.endLatitude.present
          ? data.endLatitude.value
          : this.endLatitude,
      endLongitude: data.endLongitude.present
          ? data.endLongitude.value
          : this.endLongitude,
      startAddress: data.startAddress.present
          ? data.startAddress.value
          : this.startAddress,
      endAddress: data.endAddress.present
          ? data.endAddress.value
          : this.endAddress,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      elapsedDurationSeconds: data.elapsedDurationSeconds.present
          ? data.elapsedDurationSeconds.value
          : this.elapsedDurationSeconds,
      movingDurationSeconds: data.movingDurationSeconds.present
          ? data.movingDurationSeconds.value
          : this.movingDurationSeconds,
      stoppedDurationSeconds: data.stoppedDurationSeconds.present
          ? data.stoppedDurationSeconds.value
          : this.stoppedDurationSeconds,
      averageSpeedKmh: data.averageSpeedKmh.present
          ? data.averageSpeedKmh.value
          : this.averageSpeedKmh,
      movingAverageSpeedKmh: data.movingAverageSpeedKmh.present
          ? data.movingAverageSpeedKmh.value
          : this.movingAverageSpeedKmh,
      maximumSpeedKmh: data.maximumSpeedKmh.present
          ? data.maximumSpeedKmh.value
          : this.maximumSpeedKmh,
      detectedVehicleType: data.detectedVehicleType.present
          ? data.detectedVehicleType.value
          : this.detectedVehicleType,
      confirmedVehicleType: data.confirmedVehicleType.present
          ? data.confirmedVehicleType.value
          : this.confirmedVehicleType,
      vehicleConfidence: data.vehicleConfidence.present
          ? data.vehicleConfidence.value
          : this.vehicleConfidence,
      vehicleConfirmedAt: data.vehicleConfirmedAt.present
          ? data.vehicleConfirmedAt.value
          : this.vehicleConfirmedAt,
      vehiclePredictionChanged: data.vehiclePredictionChanged.present
          ? data.vehiclePredictionChanged.value
          : this.vehiclePredictionChanged,
      stopCount: data.stopCount.present ? data.stopCount.value : this.stopCount,
      summaryAlgorithmVersion: data.summaryAlgorithmVersion.present
          ? data.summaryAlgorithmVersion.value
          : this.summaryAlgorithmVersion,
      finishedAutomatically: data.finishedAutomatically.present
          ? data.finishedAutomatically.value
          : this.finishedAutomatically,
      finishReason: data.finishReason.present
          ? data.finishReason.value
          : this.finishReason,
      arrivalCorrectedByUser: data.arrivalCorrectedByUser.present
          ? data.arrivalCorrectedByUser.value
          : this.arrivalCorrectedByUser,
      deviceModel: data.deviceModel.present
          ? data.deviceModel.value
          : this.deviceModel,
      operatingSystem: data.operatingSystem.present
          ? data.operatingSystem.value
          : this.operatingSystem,
      operatingSystemVersion: data.operatingSystemVersion.present
          ? data.operatingSystemVersion.value
          : this.operatingSystemVersion,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      phoneMountPosition: data.phoneMountPosition.present
          ? data.phoneMountPosition.value
          : this.phoneMountPosition,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Trip(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startLatitude: $startLatitude, ')
          ..write('startLongitude: $startLongitude, ')
          ..write('endLatitude: $endLatitude, ')
          ..write('endLongitude: $endLongitude, ')
          ..write('startAddress: $startAddress, ')
          ..write('endAddress: $endAddress, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elapsedDurationSeconds: $elapsedDurationSeconds, ')
          ..write('movingDurationSeconds: $movingDurationSeconds, ')
          ..write('stoppedDurationSeconds: $stoppedDurationSeconds, ')
          ..write('averageSpeedKmh: $averageSpeedKmh, ')
          ..write('movingAverageSpeedKmh: $movingAverageSpeedKmh, ')
          ..write('maximumSpeedKmh: $maximumSpeedKmh, ')
          ..write('detectedVehicleType: $detectedVehicleType, ')
          ..write('confirmedVehicleType: $confirmedVehicleType, ')
          ..write('vehicleConfidence: $vehicleConfidence, ')
          ..write('vehicleConfirmedAt: $vehicleConfirmedAt, ')
          ..write('vehiclePredictionChanged: $vehiclePredictionChanged, ')
          ..write('stopCount: $stopCount, ')
          ..write('summaryAlgorithmVersion: $summaryAlgorithmVersion, ')
          ..write('finishedAutomatically: $finishedAutomatically, ')
          ..write('finishReason: $finishReason, ')
          ..write('arrivalCorrectedByUser: $arrivalCorrectedByUser, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('operatingSystem: $operatingSystem, ')
          ..write('operatingSystemVersion: $operatingSystemVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('phoneMountPosition: $phoneMountPosition, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    userId,
    status,
    startedAt,
    endedAt,
    startLatitude,
    startLongitude,
    endLatitude,
    endLongitude,
    startAddress,
    endAddress,
    distanceMeters,
    elapsedDurationSeconds,
    movingDurationSeconds,
    stoppedDurationSeconds,
    averageSpeedKmh,
    movingAverageSpeedKmh,
    maximumSpeedKmh,
    detectedVehicleType,
    confirmedVehicleType,
    vehicleConfidence,
    vehicleConfirmedAt,
    vehiclePredictionChanged,
    stopCount,
    summaryAlgorithmVersion,
    finishedAutomatically,
    finishReason,
    arrivalCorrectedByUser,
    deviceModel,
    operatingSystem,
    operatingSystemVersion,
    appVersion,
    phoneMountPosition,
    syncStatus,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Trip &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.status == this.status &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.startLatitude == this.startLatitude &&
          other.startLongitude == this.startLongitude &&
          other.endLatitude == this.endLatitude &&
          other.endLongitude == this.endLongitude &&
          other.startAddress == this.startAddress &&
          other.endAddress == this.endAddress &&
          other.distanceMeters == this.distanceMeters &&
          other.elapsedDurationSeconds == this.elapsedDurationSeconds &&
          other.movingDurationSeconds == this.movingDurationSeconds &&
          other.stoppedDurationSeconds == this.stoppedDurationSeconds &&
          other.averageSpeedKmh == this.averageSpeedKmh &&
          other.movingAverageSpeedKmh == this.movingAverageSpeedKmh &&
          other.maximumSpeedKmh == this.maximumSpeedKmh &&
          other.detectedVehicleType == this.detectedVehicleType &&
          other.confirmedVehicleType == this.confirmedVehicleType &&
          other.vehicleConfidence == this.vehicleConfidence &&
          other.vehicleConfirmedAt == this.vehicleConfirmedAt &&
          other.vehiclePredictionChanged == this.vehiclePredictionChanged &&
          other.stopCount == this.stopCount &&
          other.summaryAlgorithmVersion == this.summaryAlgorithmVersion &&
          other.finishedAutomatically == this.finishedAutomatically &&
          other.finishReason == this.finishReason &&
          other.arrivalCorrectedByUser == this.arrivalCorrectedByUser &&
          other.deviceModel == this.deviceModel &&
          other.operatingSystem == this.operatingSystem &&
          other.operatingSystemVersion == this.operatingSystemVersion &&
          other.appVersion == this.appVersion &&
          other.phoneMountPosition == this.phoneMountPosition &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripsCompanion extends UpdateCompanion<Trip> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> status;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<double?> startLatitude;
  final Value<double?> startLongitude;
  final Value<double?> endLatitude;
  final Value<double?> endLongitude;
  final Value<String?> startAddress;
  final Value<String?> endAddress;
  final Value<double> distanceMeters;
  final Value<int> elapsedDurationSeconds;
  final Value<int> movingDurationSeconds;
  final Value<int> stoppedDurationSeconds;
  final Value<double> averageSpeedKmh;
  final Value<double> movingAverageSpeedKmh;
  final Value<double> maximumSpeedKmh;
  final Value<String> detectedVehicleType;
  final Value<String?> confirmedVehicleType;
  final Value<double?> vehicleConfidence;
  final Value<DateTime?> vehicleConfirmedAt;
  final Value<bool?> vehiclePredictionChanged;
  final Value<int> stopCount;
  final Value<int> summaryAlgorithmVersion;
  final Value<bool> finishedAutomatically;
  final Value<String?> finishReason;
  final Value<bool> arrivalCorrectedByUser;
  final Value<String?> deviceModel;
  final Value<String?> operatingSystem;
  final Value<String?> operatingSystemVersion;
  final Value<String?> appVersion;
  final Value<String?> phoneMountPosition;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TripsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.status = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.startLatitude = const Value.absent(),
    this.startLongitude = const Value.absent(),
    this.endLatitude = const Value.absent(),
    this.endLongitude = const Value.absent(),
    this.startAddress = const Value.absent(),
    this.endAddress = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.elapsedDurationSeconds = const Value.absent(),
    this.movingDurationSeconds = const Value.absent(),
    this.stoppedDurationSeconds = const Value.absent(),
    this.averageSpeedKmh = const Value.absent(),
    this.movingAverageSpeedKmh = const Value.absent(),
    this.maximumSpeedKmh = const Value.absent(),
    this.detectedVehicleType = const Value.absent(),
    this.confirmedVehicleType = const Value.absent(),
    this.vehicleConfidence = const Value.absent(),
    this.vehicleConfirmedAt = const Value.absent(),
    this.vehiclePredictionChanged = const Value.absent(),
    this.stopCount = const Value.absent(),
    this.summaryAlgorithmVersion = const Value.absent(),
    this.finishedAutomatically = const Value.absent(),
    this.finishReason = const Value.absent(),
    this.arrivalCorrectedByUser = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.operatingSystem = const Value.absent(),
    this.operatingSystemVersion = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.phoneMountPosition = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripsCompanion.insert({
    required String id,
    required String userId,
    required String status,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.startLatitude = const Value.absent(),
    this.startLongitude = const Value.absent(),
    this.endLatitude = const Value.absent(),
    this.endLongitude = const Value.absent(),
    this.startAddress = const Value.absent(),
    this.endAddress = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.elapsedDurationSeconds = const Value.absent(),
    this.movingDurationSeconds = const Value.absent(),
    this.stoppedDurationSeconds = const Value.absent(),
    this.averageSpeedKmh = const Value.absent(),
    this.movingAverageSpeedKmh = const Value.absent(),
    this.maximumSpeedKmh = const Value.absent(),
    this.detectedVehicleType = const Value.absent(),
    this.confirmedVehicleType = const Value.absent(),
    this.vehicleConfidence = const Value.absent(),
    this.vehicleConfirmedAt = const Value.absent(),
    this.vehiclePredictionChanged = const Value.absent(),
    this.stopCount = const Value.absent(),
    this.summaryAlgorithmVersion = const Value.absent(),
    this.finishedAutomatically = const Value.absent(),
    this.finishReason = const Value.absent(),
    this.arrivalCorrectedByUser = const Value.absent(),
    this.deviceModel = const Value.absent(),
    this.operatingSystem = const Value.absent(),
    this.operatingSystemVersion = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.phoneMountPosition = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       status = Value(status),
       startedAt = Value(startedAt),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Trip> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? status,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<double>? startLatitude,
    Expression<double>? startLongitude,
    Expression<double>? endLatitude,
    Expression<double>? endLongitude,
    Expression<String>? startAddress,
    Expression<String>? endAddress,
    Expression<double>? distanceMeters,
    Expression<int>? elapsedDurationSeconds,
    Expression<int>? movingDurationSeconds,
    Expression<int>? stoppedDurationSeconds,
    Expression<double>? averageSpeedKmh,
    Expression<double>? movingAverageSpeedKmh,
    Expression<double>? maximumSpeedKmh,
    Expression<String>? detectedVehicleType,
    Expression<String>? confirmedVehicleType,
    Expression<double>? vehicleConfidence,
    Expression<DateTime>? vehicleConfirmedAt,
    Expression<bool>? vehiclePredictionChanged,
    Expression<int>? stopCount,
    Expression<int>? summaryAlgorithmVersion,
    Expression<bool>? finishedAutomatically,
    Expression<String>? finishReason,
    Expression<bool>? arrivalCorrectedByUser,
    Expression<String>? deviceModel,
    Expression<String>? operatingSystem,
    Expression<String>? operatingSystemVersion,
    Expression<String>? appVersion,
    Expression<String>? phoneMountPosition,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (status != null) 'status': status,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (startLatitude != null) 'start_latitude': startLatitude,
      if (startLongitude != null) 'start_longitude': startLongitude,
      if (endLatitude != null) 'end_latitude': endLatitude,
      if (endLongitude != null) 'end_longitude': endLongitude,
      if (startAddress != null) 'start_address': startAddress,
      if (endAddress != null) 'end_address': endAddress,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (elapsedDurationSeconds != null)
        'elapsed_duration_seconds': elapsedDurationSeconds,
      if (movingDurationSeconds != null)
        'moving_duration_seconds': movingDurationSeconds,
      if (stoppedDurationSeconds != null)
        'stopped_duration_seconds': stoppedDurationSeconds,
      if (averageSpeedKmh != null) 'average_speed_kmh': averageSpeedKmh,
      if (movingAverageSpeedKmh != null)
        'moving_average_speed_kmh': movingAverageSpeedKmh,
      if (maximumSpeedKmh != null) 'maximum_speed_kmh': maximumSpeedKmh,
      if (detectedVehicleType != null)
        'detected_vehicle_type': detectedVehicleType,
      if (confirmedVehicleType != null)
        'confirmed_vehicle_type': confirmedVehicleType,
      if (vehicleConfidence != null) 'vehicle_confidence': vehicleConfidence,
      if (vehicleConfirmedAt != null)
        'vehicle_confirmed_at': vehicleConfirmedAt,
      if (vehiclePredictionChanged != null)
        'vehicle_prediction_changed': vehiclePredictionChanged,
      if (stopCount != null) 'stop_count': stopCount,
      if (summaryAlgorithmVersion != null)
        'summary_algorithm_version': summaryAlgorithmVersion,
      if (finishedAutomatically != null)
        'finished_automatically': finishedAutomatically,
      if (finishReason != null) 'finish_reason': finishReason,
      if (arrivalCorrectedByUser != null)
        'arrival_corrected_by_user': arrivalCorrectedByUser,
      if (deviceModel != null) 'device_model': deviceModel,
      if (operatingSystem != null) 'operating_system': operatingSystem,
      if (operatingSystemVersion != null)
        'operating_system_version': operatingSystemVersion,
      if (appVersion != null) 'app_version': appVersion,
      if (phoneMountPosition != null)
        'phone_mount_position': phoneMountPosition,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? status,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<double?>? startLatitude,
    Value<double?>? startLongitude,
    Value<double?>? endLatitude,
    Value<double?>? endLongitude,
    Value<String?>? startAddress,
    Value<String?>? endAddress,
    Value<double>? distanceMeters,
    Value<int>? elapsedDurationSeconds,
    Value<int>? movingDurationSeconds,
    Value<int>? stoppedDurationSeconds,
    Value<double>? averageSpeedKmh,
    Value<double>? movingAverageSpeedKmh,
    Value<double>? maximumSpeedKmh,
    Value<String>? detectedVehicleType,
    Value<String?>? confirmedVehicleType,
    Value<double?>? vehicleConfidence,
    Value<DateTime?>? vehicleConfirmedAt,
    Value<bool?>? vehiclePredictionChanged,
    Value<int>? stopCount,
    Value<int>? summaryAlgorithmVersion,
    Value<bool>? finishedAutomatically,
    Value<String?>? finishReason,
    Value<bool>? arrivalCorrectedByUser,
    Value<String?>? deviceModel,
    Value<String?>? operatingSystem,
    Value<String?>? operatingSystemVersion,
    Value<String?>? appVersion,
    Value<String?>? phoneMountPosition,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TripsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      startAddress: startAddress ?? this.startAddress,
      endAddress: endAddress ?? this.endAddress,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elapsedDurationSeconds:
          elapsedDurationSeconds ?? this.elapsedDurationSeconds,
      movingDurationSeconds:
          movingDurationSeconds ?? this.movingDurationSeconds,
      stoppedDurationSeconds:
          stoppedDurationSeconds ?? this.stoppedDurationSeconds,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      movingAverageSpeedKmh:
          movingAverageSpeedKmh ?? this.movingAverageSpeedKmh,
      maximumSpeedKmh: maximumSpeedKmh ?? this.maximumSpeedKmh,
      detectedVehicleType: detectedVehicleType ?? this.detectedVehicleType,
      confirmedVehicleType: confirmedVehicleType ?? this.confirmedVehicleType,
      vehicleConfidence: vehicleConfidence ?? this.vehicleConfidence,
      vehicleConfirmedAt: vehicleConfirmedAt ?? this.vehicleConfirmedAt,
      vehiclePredictionChanged:
          vehiclePredictionChanged ?? this.vehiclePredictionChanged,
      stopCount: stopCount ?? this.stopCount,
      summaryAlgorithmVersion:
          summaryAlgorithmVersion ?? this.summaryAlgorithmVersion,
      finishedAutomatically:
          finishedAutomatically ?? this.finishedAutomatically,
      finishReason: finishReason ?? this.finishReason,
      arrivalCorrectedByUser:
          arrivalCorrectedByUser ?? this.arrivalCorrectedByUser,
      deviceModel: deviceModel ?? this.deviceModel,
      operatingSystem: operatingSystem ?? this.operatingSystem,
      operatingSystemVersion:
          operatingSystemVersion ?? this.operatingSystemVersion,
      appVersion: appVersion ?? this.appVersion,
      phoneMountPosition: phoneMountPosition ?? this.phoneMountPosition,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (startLatitude.present) {
      map['start_latitude'] = Variable<double>(startLatitude.value);
    }
    if (startLongitude.present) {
      map['start_longitude'] = Variable<double>(startLongitude.value);
    }
    if (endLatitude.present) {
      map['end_latitude'] = Variable<double>(endLatitude.value);
    }
    if (endLongitude.present) {
      map['end_longitude'] = Variable<double>(endLongitude.value);
    }
    if (startAddress.present) {
      map['start_address'] = Variable<String>(startAddress.value);
    }
    if (endAddress.present) {
      map['end_address'] = Variable<String>(endAddress.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<double>(distanceMeters.value);
    }
    if (elapsedDurationSeconds.present) {
      map['elapsed_duration_seconds'] = Variable<int>(
        elapsedDurationSeconds.value,
      );
    }
    if (movingDurationSeconds.present) {
      map['moving_duration_seconds'] = Variable<int>(
        movingDurationSeconds.value,
      );
    }
    if (stoppedDurationSeconds.present) {
      map['stopped_duration_seconds'] = Variable<int>(
        stoppedDurationSeconds.value,
      );
    }
    if (averageSpeedKmh.present) {
      map['average_speed_kmh'] = Variable<double>(averageSpeedKmh.value);
    }
    if (movingAverageSpeedKmh.present) {
      map['moving_average_speed_kmh'] = Variable<double>(
        movingAverageSpeedKmh.value,
      );
    }
    if (maximumSpeedKmh.present) {
      map['maximum_speed_kmh'] = Variable<double>(maximumSpeedKmh.value);
    }
    if (detectedVehicleType.present) {
      map['detected_vehicle_type'] = Variable<String>(
        detectedVehicleType.value,
      );
    }
    if (confirmedVehicleType.present) {
      map['confirmed_vehicle_type'] = Variable<String>(
        confirmedVehicleType.value,
      );
    }
    if (vehicleConfidence.present) {
      map['vehicle_confidence'] = Variable<double>(vehicleConfidence.value);
    }
    if (vehicleConfirmedAt.present) {
      map['vehicle_confirmed_at'] = Variable<DateTime>(
        vehicleConfirmedAt.value,
      );
    }
    if (vehiclePredictionChanged.present) {
      map['vehicle_prediction_changed'] = Variable<bool>(
        vehiclePredictionChanged.value,
      );
    }
    if (stopCount.present) {
      map['stop_count'] = Variable<int>(stopCount.value);
    }
    if (summaryAlgorithmVersion.present) {
      map['summary_algorithm_version'] = Variable<int>(
        summaryAlgorithmVersion.value,
      );
    }
    if (finishedAutomatically.present) {
      map['finished_automatically'] = Variable<bool>(
        finishedAutomatically.value,
      );
    }
    if (finishReason.present) {
      map['finish_reason'] = Variable<String>(finishReason.value);
    }
    if (arrivalCorrectedByUser.present) {
      map['arrival_corrected_by_user'] = Variable<bool>(
        arrivalCorrectedByUser.value,
      );
    }
    if (deviceModel.present) {
      map['device_model'] = Variable<String>(deviceModel.value);
    }
    if (operatingSystem.present) {
      map['operating_system'] = Variable<String>(operatingSystem.value);
    }
    if (operatingSystemVersion.present) {
      map['operating_system_version'] = Variable<String>(
        operatingSystemVersion.value,
      );
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (phoneMountPosition.present) {
      map['phone_mount_position'] = Variable<String>(phoneMountPosition.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('status: $status, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('startLatitude: $startLatitude, ')
          ..write('startLongitude: $startLongitude, ')
          ..write('endLatitude: $endLatitude, ')
          ..write('endLongitude: $endLongitude, ')
          ..write('startAddress: $startAddress, ')
          ..write('endAddress: $endAddress, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elapsedDurationSeconds: $elapsedDurationSeconds, ')
          ..write('movingDurationSeconds: $movingDurationSeconds, ')
          ..write('stoppedDurationSeconds: $stoppedDurationSeconds, ')
          ..write('averageSpeedKmh: $averageSpeedKmh, ')
          ..write('movingAverageSpeedKmh: $movingAverageSpeedKmh, ')
          ..write('maximumSpeedKmh: $maximumSpeedKmh, ')
          ..write('detectedVehicleType: $detectedVehicleType, ')
          ..write('confirmedVehicleType: $confirmedVehicleType, ')
          ..write('vehicleConfidence: $vehicleConfidence, ')
          ..write('vehicleConfirmedAt: $vehicleConfirmedAt, ')
          ..write('vehiclePredictionChanged: $vehiclePredictionChanged, ')
          ..write('stopCount: $stopCount, ')
          ..write('summaryAlgorithmVersion: $summaryAlgorithmVersion, ')
          ..write('finishedAutomatically: $finishedAutomatically, ')
          ..write('finishReason: $finishReason, ')
          ..write('arrivalCorrectedByUser: $arrivalCorrectedByUser, ')
          ..write('deviceModel: $deviceModel, ')
          ..write('operatingSystem: $operatingSystem, ')
          ..write('operatingSystemVersion: $operatingSystemVersion, ')
          ..write('appVersion: $appVersion, ')
          ..write('phoneMountPosition: $phoneMountPosition, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripPointsTable extends TripPoints
    with TableInfo<$TripPointsTable, TripPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<double> altitude = GeneratedColumn<double>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _horizontalAccuracyMeta =
      const VerificationMeta('horizontalAccuracy');
  @override
  late final GeneratedColumn<double> horizontalAccuracy =
      GeneratedColumn<double>(
        'horizontal_accuracy',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _verticalAccuracyMeta = const VerificationMeta(
    'verticalAccuracy',
  );
  @override
  late final GeneratedColumn<double> verticalAccuracy = GeneratedColumn<double>(
    'vertical_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedAccuracyMeta = const VerificationMeta(
    'speedAccuracy',
  );
  @override
  late final GeneratedColumn<double> speedAccuracy = GeneratedColumn<double>(
    'speed_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headingMeta = const VerificationMeta(
    'heading',
  );
  @override
  late final GeneratedColumn<double> heading = GeneratedColumn<double>(
    'heading',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _headingAccuracyMeta = const VerificationMeta(
    'headingAccuracy',
  );
  @override
  late final GeneratedColumn<double> headingAccuracy = GeneratedColumn<double>(
    'heading_accuracy',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceNumberMeta = const VerificationMeta(
    'sequenceNumber',
  );
  @override
  late final GeneratedColumn<int> sequenceNumber = GeneratedColumn<int>(
    'sequence_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isMockedMeta = const VerificationMeta(
    'isMocked',
  );
  @override
  late final GeneratedColumn<bool> isMocked = GeneratedColumn<bool>(
    'is_mocked',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mocked" IN (0, 1))',
    ),
  );
  static const VerificationMeta _batteryLevelMeta = const VerificationMeta(
    'batteryLevel',
  );
  @override
  late final GeneratedColumn<double> batteryLevel = GeneratedColumn<double>(
    'battery_level',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    recordedAt,
    latitude,
    longitude,
    altitude,
    horizontalAccuracy,
    verticalAccuracy,
    speed,
    speedAccuracy,
    heading,
    headingAccuracy,
    sequenceNumber,
    source,
    isMocked,
    batteryLevel,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('horizontal_accuracy')) {
      context.handle(
        _horizontalAccuracyMeta,
        horizontalAccuracy.isAcceptableOrUnknown(
          data['horizontal_accuracy']!,
          _horizontalAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('vertical_accuracy')) {
      context.handle(
        _verticalAccuracyMeta,
        verticalAccuracy.isAcceptableOrUnknown(
          data['vertical_accuracy']!,
          _verticalAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('speed_accuracy')) {
      context.handle(
        _speedAccuracyMeta,
        speedAccuracy.isAcceptableOrUnknown(
          data['speed_accuracy']!,
          _speedAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('heading')) {
      context.handle(
        _headingMeta,
        heading.isAcceptableOrUnknown(data['heading']!, _headingMeta),
      );
    }
    if (data.containsKey('heading_accuracy')) {
      context.handle(
        _headingAccuracyMeta,
        headingAccuracy.isAcceptableOrUnknown(
          data['heading_accuracy']!,
          _headingAccuracyMeta,
        ),
      );
    }
    if (data.containsKey('sequence_number')) {
      context.handle(
        _sequenceNumberMeta,
        sequenceNumber.isAcceptableOrUnknown(
          data['sequence_number']!,
          _sequenceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sequenceNumberMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('is_mocked')) {
      context.handle(
        _isMockedMeta,
        isMocked.isAcceptableOrUnknown(data['is_mocked']!, _isMockedMeta),
      );
    }
    if (data.containsKey('battery_level')) {
      context.handle(
        _batteryLevelMeta,
        batteryLevel.isAcceptableOrUnknown(
          data['battery_level']!,
          _batteryLevelMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude'],
      ),
      horizontalAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}horizontal_accuracy'],
      ),
      verticalAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vertical_accuracy'],
      ),
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      ),
      speedAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_accuracy'],
      ),
      heading: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heading'],
      ),
      headingAccuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}heading_accuracy'],
      ),
      sequenceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence_number'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      isMocked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mocked'],
      ),
      batteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}battery_level'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $TripPointsTable createAlias(String alias) {
    return $TripPointsTable(attachedDatabase, alias);
  }
}

class TripPoint extends DataClass implements Insertable<TripPoint> {
  final String id;
  final String tripId;
  final DateTime recordedAt;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? horizontalAccuracy;
  final double? verticalAccuracy;

  /// Speed in m/s as reported by the platform.
  final double? speed;
  final double? speedAccuracy;
  final double? heading;
  final double? headingAccuracy;
  final int sequenceNumber;
  final String? source;
  final bool? isMocked;
  final double? batteryLevel;
  final String syncStatus;
  const TripPoint({
    required this.id,
    required this.tripId,
    required this.recordedAt,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.horizontalAccuracy,
    this.verticalAccuracy,
    this.speed,
    this.speedAccuracy,
    this.heading,
    this.headingAccuracy,
    required this.sequenceNumber,
    this.source,
    this.isMocked,
    this.batteryLevel,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<double>(altitude);
    }
    if (!nullToAbsent || horizontalAccuracy != null) {
      map['horizontal_accuracy'] = Variable<double>(horizontalAccuracy);
    }
    if (!nullToAbsent || verticalAccuracy != null) {
      map['vertical_accuracy'] = Variable<double>(verticalAccuracy);
    }
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || speedAccuracy != null) {
      map['speed_accuracy'] = Variable<double>(speedAccuracy);
    }
    if (!nullToAbsent || heading != null) {
      map['heading'] = Variable<double>(heading);
    }
    if (!nullToAbsent || headingAccuracy != null) {
      map['heading_accuracy'] = Variable<double>(headingAccuracy);
    }
    map['sequence_number'] = Variable<int>(sequenceNumber);
    if (!nullToAbsent || source != null) {
      map['source'] = Variable<String>(source);
    }
    if (!nullToAbsent || isMocked != null) {
      map['is_mocked'] = Variable<bool>(isMocked);
    }
    if (!nullToAbsent || batteryLevel != null) {
      map['battery_level'] = Variable<double>(batteryLevel);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  TripPointsCompanion toCompanion(bool nullToAbsent) {
    return TripPointsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      recordedAt: Value(recordedAt),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      horizontalAccuracy: horizontalAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(horizontalAccuracy),
      verticalAccuracy: verticalAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(verticalAccuracy),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
      speedAccuracy: speedAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(speedAccuracy),
      heading: heading == null && nullToAbsent
          ? const Value.absent()
          : Value(heading),
      headingAccuracy: headingAccuracy == null && nullToAbsent
          ? const Value.absent()
          : Value(headingAccuracy),
      sequenceNumber: Value(sequenceNumber),
      source: source == null && nullToAbsent
          ? const Value.absent()
          : Value(source),
      isMocked: isMocked == null && nullToAbsent
          ? const Value.absent()
          : Value(isMocked),
      batteryLevel: batteryLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryLevel),
      syncStatus: Value(syncStatus),
    );
  }

  factory TripPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripPoint(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<double?>(json['altitude']),
      horizontalAccuracy: serializer.fromJson<double?>(
        json['horizontalAccuracy'],
      ),
      verticalAccuracy: serializer.fromJson<double?>(json['verticalAccuracy']),
      speed: serializer.fromJson<double?>(json['speed']),
      speedAccuracy: serializer.fromJson<double?>(json['speedAccuracy']),
      heading: serializer.fromJson<double?>(json['heading']),
      headingAccuracy: serializer.fromJson<double?>(json['headingAccuracy']),
      sequenceNumber: serializer.fromJson<int>(json['sequenceNumber']),
      source: serializer.fromJson<String?>(json['source']),
      isMocked: serializer.fromJson<bool?>(json['isMocked']),
      batteryLevel: serializer.fromJson<double?>(json['batteryLevel']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<double?>(altitude),
      'horizontalAccuracy': serializer.toJson<double?>(horizontalAccuracy),
      'verticalAccuracy': serializer.toJson<double?>(verticalAccuracy),
      'speed': serializer.toJson<double?>(speed),
      'speedAccuracy': serializer.toJson<double?>(speedAccuracy),
      'heading': serializer.toJson<double?>(heading),
      'headingAccuracy': serializer.toJson<double?>(headingAccuracy),
      'sequenceNumber': serializer.toJson<int>(sequenceNumber),
      'source': serializer.toJson<String?>(source),
      'isMocked': serializer.toJson<bool?>(isMocked),
      'batteryLevel': serializer.toJson<double?>(batteryLevel),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  TripPoint copyWith({
    String? id,
    String? tripId,
    DateTime? recordedAt,
    double? latitude,
    double? longitude,
    Value<double?> altitude = const Value.absent(),
    Value<double?> horizontalAccuracy = const Value.absent(),
    Value<double?> verticalAccuracy = const Value.absent(),
    Value<double?> speed = const Value.absent(),
    Value<double?> speedAccuracy = const Value.absent(),
    Value<double?> heading = const Value.absent(),
    Value<double?> headingAccuracy = const Value.absent(),
    int? sequenceNumber,
    Value<String?> source = const Value.absent(),
    Value<bool?> isMocked = const Value.absent(),
    Value<double?> batteryLevel = const Value.absent(),
    String? syncStatus,
  }) => TripPoint(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    recordedAt: recordedAt ?? this.recordedAt,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
    horizontalAccuracy: horizontalAccuracy.present
        ? horizontalAccuracy.value
        : this.horizontalAccuracy,
    verticalAccuracy: verticalAccuracy.present
        ? verticalAccuracy.value
        : this.verticalAccuracy,
    speed: speed.present ? speed.value : this.speed,
    speedAccuracy: speedAccuracy.present
        ? speedAccuracy.value
        : this.speedAccuracy,
    heading: heading.present ? heading.value : this.heading,
    headingAccuracy: headingAccuracy.present
        ? headingAccuracy.value
        : this.headingAccuracy,
    sequenceNumber: sequenceNumber ?? this.sequenceNumber,
    source: source.present ? source.value : this.source,
    isMocked: isMocked.present ? isMocked.value : this.isMocked,
    batteryLevel: batteryLevel.present ? batteryLevel.value : this.batteryLevel,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  TripPoint copyWithCompanion(TripPointsCompanion data) {
    return TripPoint(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      horizontalAccuracy: data.horizontalAccuracy.present
          ? data.horizontalAccuracy.value
          : this.horizontalAccuracy,
      verticalAccuracy: data.verticalAccuracy.present
          ? data.verticalAccuracy.value
          : this.verticalAccuracy,
      speed: data.speed.present ? data.speed.value : this.speed,
      speedAccuracy: data.speedAccuracy.present
          ? data.speedAccuracy.value
          : this.speedAccuracy,
      heading: data.heading.present ? data.heading.value : this.heading,
      headingAccuracy: data.headingAccuracy.present
          ? data.headingAccuracy.value
          : this.headingAccuracy,
      sequenceNumber: data.sequenceNumber.present
          ? data.sequenceNumber.value
          : this.sequenceNumber,
      source: data.source.present ? data.source.value : this.source,
      isMocked: data.isMocked.present ? data.isMocked.value : this.isMocked,
      batteryLevel: data.batteryLevel.present
          ? data.batteryLevel.value
          : this.batteryLevel,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripPoint(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('horizontalAccuracy: $horizontalAccuracy, ')
          ..write('verticalAccuracy: $verticalAccuracy, ')
          ..write('speed: $speed, ')
          ..write('speedAccuracy: $speedAccuracy, ')
          ..write('heading: $heading, ')
          ..write('headingAccuracy: $headingAccuracy, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('source: $source, ')
          ..write('isMocked: $isMocked, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    recordedAt,
    latitude,
    longitude,
    altitude,
    horizontalAccuracy,
    verticalAccuracy,
    speed,
    speedAccuracy,
    heading,
    headingAccuracy,
    sequenceNumber,
    source,
    isMocked,
    batteryLevel,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripPoint &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.recordedAt == this.recordedAt &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.horizontalAccuracy == this.horizontalAccuracy &&
          other.verticalAccuracy == this.verticalAccuracy &&
          other.speed == this.speed &&
          other.speedAccuracy == this.speedAccuracy &&
          other.heading == this.heading &&
          other.headingAccuracy == this.headingAccuracy &&
          other.sequenceNumber == this.sequenceNumber &&
          other.source == this.source &&
          other.isMocked == this.isMocked &&
          other.batteryLevel == this.batteryLevel &&
          other.syncStatus == this.syncStatus);
}

class TripPointsCompanion extends UpdateCompanion<TripPoint> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<DateTime> recordedAt;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitude;
  final Value<double?> horizontalAccuracy;
  final Value<double?> verticalAccuracy;
  final Value<double?> speed;
  final Value<double?> speedAccuracy;
  final Value<double?> heading;
  final Value<double?> headingAccuracy;
  final Value<int> sequenceNumber;
  final Value<String?> source;
  final Value<bool?> isMocked;
  final Value<double?> batteryLevel;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const TripPointsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.horizontalAccuracy = const Value.absent(),
    this.verticalAccuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.speedAccuracy = const Value.absent(),
    this.heading = const Value.absent(),
    this.headingAccuracy = const Value.absent(),
    this.sequenceNumber = const Value.absent(),
    this.source = const Value.absent(),
    this.isMocked = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripPointsCompanion.insert({
    required String id,
    required String tripId,
    required DateTime recordedAt,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
    this.horizontalAccuracy = const Value.absent(),
    this.verticalAccuracy = const Value.absent(),
    this.speed = const Value.absent(),
    this.speedAccuracy = const Value.absent(),
    this.heading = const Value.absent(),
    this.headingAccuracy = const Value.absent(),
    required int sequenceNumber,
    this.source = const Value.absent(),
    this.isMocked = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       recordedAt = Value(recordedAt),
       latitude = Value(latitude),
       longitude = Value(longitude),
       sequenceNumber = Value(sequenceNumber);
  static Insertable<TripPoint> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<DateTime>? recordedAt,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitude,
    Expression<double>? horizontalAccuracy,
    Expression<double>? verticalAccuracy,
    Expression<double>? speed,
    Expression<double>? speedAccuracy,
    Expression<double>? heading,
    Expression<double>? headingAccuracy,
    Expression<int>? sequenceNumber,
    Expression<String>? source,
    Expression<bool>? isMocked,
    Expression<double>? batteryLevel,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (horizontalAccuracy != null) 'horizontal_accuracy': horizontalAccuracy,
      if (verticalAccuracy != null) 'vertical_accuracy': verticalAccuracy,
      if (speed != null) 'speed': speed,
      if (speedAccuracy != null) 'speed_accuracy': speedAccuracy,
      if (heading != null) 'heading': heading,
      if (headingAccuracy != null) 'heading_accuracy': headingAccuracy,
      if (sequenceNumber != null) 'sequence_number': sequenceNumber,
      if (source != null) 'source': source,
      if (isMocked != null) 'is_mocked': isMocked,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripPointsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<DateTime>? recordedAt,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitude,
    Value<double?>? horizontalAccuracy,
    Value<double?>? verticalAccuracy,
    Value<double?>? speed,
    Value<double?>? speedAccuracy,
    Value<double?>? heading,
    Value<double?>? headingAccuracy,
    Value<int>? sequenceNumber,
    Value<String?>? source,
    Value<bool?>? isMocked,
    Value<double?>? batteryLevel,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return TripPointsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      recordedAt: recordedAt ?? this.recordedAt,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      horizontalAccuracy: horizontalAccuracy ?? this.horizontalAccuracy,
      verticalAccuracy: verticalAccuracy ?? this.verticalAccuracy,
      speed: speed ?? this.speed,
      speedAccuracy: speedAccuracy ?? this.speedAccuracy,
      heading: heading ?? this.heading,
      headingAccuracy: headingAccuracy ?? this.headingAccuracy,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      source: source ?? this.source,
      isMocked: isMocked ?? this.isMocked,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<double>(altitude.value);
    }
    if (horizontalAccuracy.present) {
      map['horizontal_accuracy'] = Variable<double>(horizontalAccuracy.value);
    }
    if (verticalAccuracy.present) {
      map['vertical_accuracy'] = Variable<double>(verticalAccuracy.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (speedAccuracy.present) {
      map['speed_accuracy'] = Variable<double>(speedAccuracy.value);
    }
    if (heading.present) {
      map['heading'] = Variable<double>(heading.value);
    }
    if (headingAccuracy.present) {
      map['heading_accuracy'] = Variable<double>(headingAccuracy.value);
    }
    if (sequenceNumber.present) {
      map['sequence_number'] = Variable<int>(sequenceNumber.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (isMocked.present) {
      map['is_mocked'] = Variable<bool>(isMocked.value);
    }
    if (batteryLevel.present) {
      map['battery_level'] = Variable<double>(batteryLevel.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripPointsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('horizontalAccuracy: $horizontalAccuracy, ')
          ..write('verticalAccuracy: $verticalAccuracy, ')
          ..write('speed: $speed, ')
          ..write('speedAccuracy: $speedAccuracy, ')
          ..write('heading: $heading, ')
          ..write('headingAccuracy: $headingAccuracy, ')
          ..write('sequenceNumber: $sequenceNumber, ')
          ..write('source: $source, ')
          ..write('isMocked: $isMocked, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityEventsTable extends ActivityEvents
    with TableInfo<$ActivityEventsTable, ActivityEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activityTypeMeta = const VerificationMeta(
    'activityType',
  );
  @override
  late final GeneratedColumn<String> activityType = GeneratedColumn<String>(
    'activity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transitionTypeMeta = const VerificationMeta(
    'transitionType',
  );
  @override
  late final GeneratedColumn<String> transitionType = GeneratedColumn<String>(
    'transition_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _platformSourceMeta = const VerificationMeta(
    'platformSource',
  );
  @override
  late final GeneratedColumn<String> platformSource = GeneratedColumn<String>(
    'platform_source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawPayloadMeta = const VerificationMeta(
    'rawPayload',
  );
  @override
  late final GeneratedColumn<String> rawPayload = GeneratedColumn<String>(
    'raw_payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    recordedAt,
    activityType,
    transitionType,
    confidence,
    platformSource,
    rawPayload,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('activity_type')) {
      context.handle(
        _activityTypeMeta,
        activityType.isAcceptableOrUnknown(
          data['activity_type']!,
          _activityTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_activityTypeMeta);
    }
    if (data.containsKey('transition_type')) {
      context.handle(
        _transitionTypeMeta,
        transitionType.isAcceptableOrUnknown(
          data['transition_type']!,
          _transitionTypeMeta,
        ),
      );
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('platform_source')) {
      context.handle(
        _platformSourceMeta,
        platformSource.isAcceptableOrUnknown(
          data['platform_source']!,
          _platformSourceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_platformSourceMeta);
    }
    if (data.containsKey('raw_payload')) {
      context.handle(
        _rawPayloadMeta,
        rawPayload.isAcceptableOrUnknown(data['raw_payload']!, _rawPayloadMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      activityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_type'],
      )!,
      transitionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transition_type'],
      ),
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      ),
      platformSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform_source'],
      )!,
      rawPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_payload'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ActivityEventsTable createAlias(String alias) {
    return $ActivityEventsTable(attachedDatabase, alias);
  }
}

class ActivityEvent extends DataClass implements Insertable<ActivityEvent> {
  final String id;
  final String? tripId;
  final DateTime recordedAt;
  final String activityType;
  final String? transitionType;
  final double? confidence;
  final String platformSource;
  final String? rawPayload;
  final String syncStatus;
  const ActivityEvent({
    required this.id,
    this.tripId,
    required this.recordedAt,
    required this.activityType,
    this.transitionType,
    this.confidence,
    required this.platformSource,
    this.rawPayload,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || tripId != null) {
      map['trip_id'] = Variable<String>(tripId);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['activity_type'] = Variable<String>(activityType);
    if (!nullToAbsent || transitionType != null) {
      map['transition_type'] = Variable<String>(transitionType);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    map['platform_source'] = Variable<String>(platformSource);
    if (!nullToAbsent || rawPayload != null) {
      map['raw_payload'] = Variable<String>(rawPayload);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ActivityEventsCompanion toCompanion(bool nullToAbsent) {
    return ActivityEventsCompanion(
      id: Value(id),
      tripId: tripId == null && nullToAbsent
          ? const Value.absent()
          : Value(tripId),
      recordedAt: Value(recordedAt),
      activityType: Value(activityType),
      transitionType: transitionType == null && nullToAbsent
          ? const Value.absent()
          : Value(transitionType),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      platformSource: Value(platformSource),
      rawPayload: rawPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(rawPayload),
      syncStatus: Value(syncStatus),
    );
  }

  factory ActivityEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityEvent(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String?>(json['tripId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      activityType: serializer.fromJson<String>(json['activityType']),
      transitionType: serializer.fromJson<String?>(json['transitionType']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      platformSource: serializer.fromJson<String>(json['platformSource']),
      rawPayload: serializer.fromJson<String?>(json['rawPayload']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String?>(tripId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'activityType': serializer.toJson<String>(activityType),
      'transitionType': serializer.toJson<String?>(transitionType),
      'confidence': serializer.toJson<double?>(confidence),
      'platformSource': serializer.toJson<String>(platformSource),
      'rawPayload': serializer.toJson<String?>(rawPayload),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ActivityEvent copyWith({
    String? id,
    Value<String?> tripId = const Value.absent(),
    DateTime? recordedAt,
    String? activityType,
    Value<String?> transitionType = const Value.absent(),
    Value<double?> confidence = const Value.absent(),
    String? platformSource,
    Value<String?> rawPayload = const Value.absent(),
    String? syncStatus,
  }) => ActivityEvent(
    id: id ?? this.id,
    tripId: tripId.present ? tripId.value : this.tripId,
    recordedAt: recordedAt ?? this.recordedAt,
    activityType: activityType ?? this.activityType,
    transitionType: transitionType.present
        ? transitionType.value
        : this.transitionType,
    confidence: confidence.present ? confidence.value : this.confidence,
    platformSource: platformSource ?? this.platformSource,
    rawPayload: rawPayload.present ? rawPayload.value : this.rawPayload,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ActivityEvent copyWithCompanion(ActivityEventsCompanion data) {
    return ActivityEvent(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      activityType: data.activityType.present
          ? data.activityType.value
          : this.activityType,
      transitionType: data.transitionType.present
          ? data.transitionType.value
          : this.transitionType,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      platformSource: data.platformSource.present
          ? data.platformSource.value
          : this.platformSource,
      rawPayload: data.rawPayload.present
          ? data.rawPayload.value
          : this.rawPayload,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEvent(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('activityType: $activityType, ')
          ..write('transitionType: $transitionType, ')
          ..write('confidence: $confidence, ')
          ..write('platformSource: $platformSource, ')
          ..write('rawPayload: $rawPayload, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    recordedAt,
    activityType,
    transitionType,
    confidence,
    platformSource,
    rawPayload,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityEvent &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.recordedAt == this.recordedAt &&
          other.activityType == this.activityType &&
          other.transitionType == this.transitionType &&
          other.confidence == this.confidence &&
          other.platformSource == this.platformSource &&
          other.rawPayload == this.rawPayload &&
          other.syncStatus == this.syncStatus);
}

class ActivityEventsCompanion extends UpdateCompanion<ActivityEvent> {
  final Value<String> id;
  final Value<String?> tripId;
  final Value<DateTime> recordedAt;
  final Value<String> activityType;
  final Value<String?> transitionType;
  final Value<double?> confidence;
  final Value<String> platformSource;
  final Value<String?> rawPayload;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ActivityEventsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.activityType = const Value.absent(),
    this.transitionType = const Value.absent(),
    this.confidence = const Value.absent(),
    this.platformSource = const Value.absent(),
    this.rawPayload = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ActivityEventsCompanion.insert({
    required String id,
    this.tripId = const Value.absent(),
    required DateTime recordedAt,
    required String activityType,
    this.transitionType = const Value.absent(),
    this.confidence = const Value.absent(),
    required String platformSource,
    this.rawPayload = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       recordedAt = Value(recordedAt),
       activityType = Value(activityType),
       platformSource = Value(platformSource);
  static Insertable<ActivityEvent> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<DateTime>? recordedAt,
    Expression<String>? activityType,
    Expression<String>? transitionType,
    Expression<double>? confidence,
    Expression<String>? platformSource,
    Expression<String>? rawPayload,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (activityType != null) 'activity_type': activityType,
      if (transitionType != null) 'transition_type': transitionType,
      if (confidence != null) 'confidence': confidence,
      if (platformSource != null) 'platform_source': platformSource,
      if (rawPayload != null) 'raw_payload': rawPayload,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ActivityEventsCompanion copyWith({
    Value<String>? id,
    Value<String?>? tripId,
    Value<DateTime>? recordedAt,
    Value<String>? activityType,
    Value<String?>? transitionType,
    Value<double?>? confidence,
    Value<String>? platformSource,
    Value<String?>? rawPayload,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ActivityEventsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      recordedAt: recordedAt ?? this.recordedAt,
      activityType: activityType ?? this.activityType,
      transitionType: transitionType ?? this.transitionType,
      confidence: confidence ?? this.confidence,
      platformSource: platformSource ?? this.platformSource,
      rawPayload: rawPayload ?? this.rawPayload,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (activityType.present) {
      map['activity_type'] = Variable<String>(activityType.value);
    }
    if (transitionType.present) {
      map['transition_type'] = Variable<String>(transitionType.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (platformSource.present) {
      map['platform_source'] = Variable<String>(platformSource.value);
    }
    if (rawPayload.present) {
      map['raw_payload'] = Variable<String>(rawPayload.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityEventsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('activityType: $activityType, ')
          ..write('transitionType: $transitionType, ')
          ..write('confidence: $confidence, ')
          ..write('platformSource: $platformSource, ')
          ..write('rawPayload: $rawPayload, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SensorSamplesTable extends SensorSamples
    with TableInfo<$SensorSamplesTable, SensorSample> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SensorSamplesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accelerometerXMeta = const VerificationMeta(
    'accelerometerX',
  );
  @override
  late final GeneratedColumn<double> accelerometerX = GeneratedColumn<double>(
    'accelerometer_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelerometerYMeta = const VerificationMeta(
    'accelerometerY',
  );
  @override
  late final GeneratedColumn<double> accelerometerY = GeneratedColumn<double>(
    'accelerometer_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accelerometerZMeta = const VerificationMeta(
    'accelerometerZ',
  );
  @override
  late final GeneratedColumn<double> accelerometerZ = GeneratedColumn<double>(
    'accelerometer_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroscopeXMeta = const VerificationMeta(
    'gyroscopeX',
  );
  @override
  late final GeneratedColumn<double> gyroscopeX = GeneratedColumn<double>(
    'gyroscope_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroscopeYMeta = const VerificationMeta(
    'gyroscopeY',
  );
  @override
  late final GeneratedColumn<double> gyroscopeY = GeneratedColumn<double>(
    'gyroscope_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gyroscopeZMeta = const VerificationMeta(
    'gyroscopeZ',
  );
  @override
  late final GeneratedColumn<double> gyroscopeZ = GeneratedColumn<double>(
    'gyroscope_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _magnetometerXMeta = const VerificationMeta(
    'magnetometerX',
  );
  @override
  late final GeneratedColumn<double> magnetometerX = GeneratedColumn<double>(
    'magnetometer_x',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _magnetometerYMeta = const VerificationMeta(
    'magnetometerY',
  );
  @override
  late final GeneratedColumn<double> magnetometerY = GeneratedColumn<double>(
    'magnetometer_y',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _magnetometerZMeta = const VerificationMeta(
    'magnetometerZ',
  );
  @override
  late final GeneratedColumn<double> magnetometerZ = GeneratedColumn<double>(
    'magnetometer_z',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceOrientationMeta = const VerificationMeta(
    'deviceOrientation',
  );
  @override
  late final GeneratedColumn<String> deviceOrientation =
      GeneratedColumn<String>(
        'device_orientation',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _samplingRateMeta = const VerificationMeta(
    'samplingRate',
  );
  @override
  late final GeneratedColumn<double> samplingRate = GeneratedColumn<double>(
    'sampling_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activityStateMeta = const VerificationMeta(
    'activityState',
  );
  @override
  late final GeneratedColumn<String> activityState = GeneratedColumn<String>(
    'activity_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    recordedAt,
    accelerometerX,
    accelerometerY,
    accelerometerZ,
    gyroscopeX,
    gyroscopeY,
    gyroscopeZ,
    magnetometerX,
    magnetometerY,
    magnetometerZ,
    deviceOrientation,
    samplingRate,
    speed,
    activityState,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sensor_samples';
  @override
  VerificationContext validateIntegrity(
    Insertable<SensorSample> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    if (data.containsKey('accelerometer_x')) {
      context.handle(
        _accelerometerXMeta,
        accelerometerX.isAcceptableOrUnknown(
          data['accelerometer_x']!,
          _accelerometerXMeta,
        ),
      );
    }
    if (data.containsKey('accelerometer_y')) {
      context.handle(
        _accelerometerYMeta,
        accelerometerY.isAcceptableOrUnknown(
          data['accelerometer_y']!,
          _accelerometerYMeta,
        ),
      );
    }
    if (data.containsKey('accelerometer_z')) {
      context.handle(
        _accelerometerZMeta,
        accelerometerZ.isAcceptableOrUnknown(
          data['accelerometer_z']!,
          _accelerometerZMeta,
        ),
      );
    }
    if (data.containsKey('gyroscope_x')) {
      context.handle(
        _gyroscopeXMeta,
        gyroscopeX.isAcceptableOrUnknown(data['gyroscope_x']!, _gyroscopeXMeta),
      );
    }
    if (data.containsKey('gyroscope_y')) {
      context.handle(
        _gyroscopeYMeta,
        gyroscopeY.isAcceptableOrUnknown(data['gyroscope_y']!, _gyroscopeYMeta),
      );
    }
    if (data.containsKey('gyroscope_z')) {
      context.handle(
        _gyroscopeZMeta,
        gyroscopeZ.isAcceptableOrUnknown(data['gyroscope_z']!, _gyroscopeZMeta),
      );
    }
    if (data.containsKey('magnetometer_x')) {
      context.handle(
        _magnetometerXMeta,
        magnetometerX.isAcceptableOrUnknown(
          data['magnetometer_x']!,
          _magnetometerXMeta,
        ),
      );
    }
    if (data.containsKey('magnetometer_y')) {
      context.handle(
        _magnetometerYMeta,
        magnetometerY.isAcceptableOrUnknown(
          data['magnetometer_y']!,
          _magnetometerYMeta,
        ),
      );
    }
    if (data.containsKey('magnetometer_z')) {
      context.handle(
        _magnetometerZMeta,
        magnetometerZ.isAcceptableOrUnknown(
          data['magnetometer_z']!,
          _magnetometerZMeta,
        ),
      );
    }
    if (data.containsKey('device_orientation')) {
      context.handle(
        _deviceOrientationMeta,
        deviceOrientation.isAcceptableOrUnknown(
          data['device_orientation']!,
          _deviceOrientationMeta,
        ),
      );
    }
    if (data.containsKey('sampling_rate')) {
      context.handle(
        _samplingRateMeta,
        samplingRate.isAcceptableOrUnknown(
          data['sampling_rate']!,
          _samplingRateMeta,
        ),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('activity_state')) {
      context.handle(
        _activityStateMeta,
        activityState.isAcceptableOrUnknown(
          data['activity_state']!,
          _activityStateMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SensorSample map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SensorSample(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      accelerometerX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accelerometer_x'],
      ),
      accelerometerY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accelerometer_y'],
      ),
      accelerometerZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accelerometer_z'],
      ),
      gyroscopeX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyroscope_x'],
      ),
      gyroscopeY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyroscope_y'],
      ),
      gyroscopeZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gyroscope_z'],
      ),
      magnetometerX: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}magnetometer_x'],
      ),
      magnetometerY: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}magnetometer_y'],
      ),
      magnetometerZ: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}magnetometer_z'],
      ),
      deviceOrientation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_orientation'],
      ),
      samplingRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sampling_rate'],
      ),
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      ),
      activityState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}activity_state'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $SensorSamplesTable createAlias(String alias) {
    return $SensorSamplesTable(attachedDatabase, alias);
  }
}

class SensorSample extends DataClass implements Insertable<SensorSample> {
  final String id;
  final String tripId;
  final DateTime recordedAt;
  final double? accelerometerX;
  final double? accelerometerY;
  final double? accelerometerZ;
  final double? gyroscopeX;
  final double? gyroscopeY;
  final double? gyroscopeZ;
  final double? magnetometerX;
  final double? magnetometerY;
  final double? magnetometerZ;
  final String? deviceOrientation;
  final double? samplingRate;
  final double? speed;
  final String? activityState;
  final String syncStatus;
  const SensorSample({
    required this.id,
    required this.tripId,
    required this.recordedAt,
    this.accelerometerX,
    this.accelerometerY,
    this.accelerometerZ,
    this.gyroscopeX,
    this.gyroscopeY,
    this.gyroscopeZ,
    this.magnetometerX,
    this.magnetometerY,
    this.magnetometerZ,
    this.deviceOrientation,
    this.samplingRate,
    this.speed,
    this.activityState,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    if (!nullToAbsent || accelerometerX != null) {
      map['accelerometer_x'] = Variable<double>(accelerometerX);
    }
    if (!nullToAbsent || accelerometerY != null) {
      map['accelerometer_y'] = Variable<double>(accelerometerY);
    }
    if (!nullToAbsent || accelerometerZ != null) {
      map['accelerometer_z'] = Variable<double>(accelerometerZ);
    }
    if (!nullToAbsent || gyroscopeX != null) {
      map['gyroscope_x'] = Variable<double>(gyroscopeX);
    }
    if (!nullToAbsent || gyroscopeY != null) {
      map['gyroscope_y'] = Variable<double>(gyroscopeY);
    }
    if (!nullToAbsent || gyroscopeZ != null) {
      map['gyroscope_z'] = Variable<double>(gyroscopeZ);
    }
    if (!nullToAbsent || magnetometerX != null) {
      map['magnetometer_x'] = Variable<double>(magnetometerX);
    }
    if (!nullToAbsent || magnetometerY != null) {
      map['magnetometer_y'] = Variable<double>(magnetometerY);
    }
    if (!nullToAbsent || magnetometerZ != null) {
      map['magnetometer_z'] = Variable<double>(magnetometerZ);
    }
    if (!nullToAbsent || deviceOrientation != null) {
      map['device_orientation'] = Variable<String>(deviceOrientation);
    }
    if (!nullToAbsent || samplingRate != null) {
      map['sampling_rate'] = Variable<double>(samplingRate);
    }
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || activityState != null) {
      map['activity_state'] = Variable<String>(activityState);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  SensorSamplesCompanion toCompanion(bool nullToAbsent) {
    return SensorSamplesCompanion(
      id: Value(id),
      tripId: Value(tripId),
      recordedAt: Value(recordedAt),
      accelerometerX: accelerometerX == null && nullToAbsent
          ? const Value.absent()
          : Value(accelerometerX),
      accelerometerY: accelerometerY == null && nullToAbsent
          ? const Value.absent()
          : Value(accelerometerY),
      accelerometerZ: accelerometerZ == null && nullToAbsent
          ? const Value.absent()
          : Value(accelerometerZ),
      gyroscopeX: gyroscopeX == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroscopeX),
      gyroscopeY: gyroscopeY == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroscopeY),
      gyroscopeZ: gyroscopeZ == null && nullToAbsent
          ? const Value.absent()
          : Value(gyroscopeZ),
      magnetometerX: magnetometerX == null && nullToAbsent
          ? const Value.absent()
          : Value(magnetometerX),
      magnetometerY: magnetometerY == null && nullToAbsent
          ? const Value.absent()
          : Value(magnetometerY),
      magnetometerZ: magnetometerZ == null && nullToAbsent
          ? const Value.absent()
          : Value(magnetometerZ),
      deviceOrientation: deviceOrientation == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceOrientation),
      samplingRate: samplingRate == null && nullToAbsent
          ? const Value.absent()
          : Value(samplingRate),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
      activityState: activityState == null && nullToAbsent
          ? const Value.absent()
          : Value(activityState),
      syncStatus: Value(syncStatus),
    );
  }

  factory SensorSample.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SensorSample(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      accelerometerX: serializer.fromJson<double?>(json['accelerometerX']),
      accelerometerY: serializer.fromJson<double?>(json['accelerometerY']),
      accelerometerZ: serializer.fromJson<double?>(json['accelerometerZ']),
      gyroscopeX: serializer.fromJson<double?>(json['gyroscopeX']),
      gyroscopeY: serializer.fromJson<double?>(json['gyroscopeY']),
      gyroscopeZ: serializer.fromJson<double?>(json['gyroscopeZ']),
      magnetometerX: serializer.fromJson<double?>(json['magnetometerX']),
      magnetometerY: serializer.fromJson<double?>(json['magnetometerY']),
      magnetometerZ: serializer.fromJson<double?>(json['magnetometerZ']),
      deviceOrientation: serializer.fromJson<String?>(
        json['deviceOrientation'],
      ),
      samplingRate: serializer.fromJson<double?>(json['samplingRate']),
      speed: serializer.fromJson<double?>(json['speed']),
      activityState: serializer.fromJson<String?>(json['activityState']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'accelerometerX': serializer.toJson<double?>(accelerometerX),
      'accelerometerY': serializer.toJson<double?>(accelerometerY),
      'accelerometerZ': serializer.toJson<double?>(accelerometerZ),
      'gyroscopeX': serializer.toJson<double?>(gyroscopeX),
      'gyroscopeY': serializer.toJson<double?>(gyroscopeY),
      'gyroscopeZ': serializer.toJson<double?>(gyroscopeZ),
      'magnetometerX': serializer.toJson<double?>(magnetometerX),
      'magnetometerY': serializer.toJson<double?>(magnetometerY),
      'magnetometerZ': serializer.toJson<double?>(magnetometerZ),
      'deviceOrientation': serializer.toJson<String?>(deviceOrientation),
      'samplingRate': serializer.toJson<double?>(samplingRate),
      'speed': serializer.toJson<double?>(speed),
      'activityState': serializer.toJson<String?>(activityState),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  SensorSample copyWith({
    String? id,
    String? tripId,
    DateTime? recordedAt,
    Value<double?> accelerometerX = const Value.absent(),
    Value<double?> accelerometerY = const Value.absent(),
    Value<double?> accelerometerZ = const Value.absent(),
    Value<double?> gyroscopeX = const Value.absent(),
    Value<double?> gyroscopeY = const Value.absent(),
    Value<double?> gyroscopeZ = const Value.absent(),
    Value<double?> magnetometerX = const Value.absent(),
    Value<double?> magnetometerY = const Value.absent(),
    Value<double?> magnetometerZ = const Value.absent(),
    Value<String?> deviceOrientation = const Value.absent(),
    Value<double?> samplingRate = const Value.absent(),
    Value<double?> speed = const Value.absent(),
    Value<String?> activityState = const Value.absent(),
    String? syncStatus,
  }) => SensorSample(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    recordedAt: recordedAt ?? this.recordedAt,
    accelerometerX: accelerometerX.present
        ? accelerometerX.value
        : this.accelerometerX,
    accelerometerY: accelerometerY.present
        ? accelerometerY.value
        : this.accelerometerY,
    accelerometerZ: accelerometerZ.present
        ? accelerometerZ.value
        : this.accelerometerZ,
    gyroscopeX: gyroscopeX.present ? gyroscopeX.value : this.gyroscopeX,
    gyroscopeY: gyroscopeY.present ? gyroscopeY.value : this.gyroscopeY,
    gyroscopeZ: gyroscopeZ.present ? gyroscopeZ.value : this.gyroscopeZ,
    magnetometerX: magnetometerX.present
        ? magnetometerX.value
        : this.magnetometerX,
    magnetometerY: magnetometerY.present
        ? magnetometerY.value
        : this.magnetometerY,
    magnetometerZ: magnetometerZ.present
        ? magnetometerZ.value
        : this.magnetometerZ,
    deviceOrientation: deviceOrientation.present
        ? deviceOrientation.value
        : this.deviceOrientation,
    samplingRate: samplingRate.present ? samplingRate.value : this.samplingRate,
    speed: speed.present ? speed.value : this.speed,
    activityState: activityState.present
        ? activityState.value
        : this.activityState,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  SensorSample copyWithCompanion(SensorSamplesCompanion data) {
    return SensorSample(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      accelerometerX: data.accelerometerX.present
          ? data.accelerometerX.value
          : this.accelerometerX,
      accelerometerY: data.accelerometerY.present
          ? data.accelerometerY.value
          : this.accelerometerY,
      accelerometerZ: data.accelerometerZ.present
          ? data.accelerometerZ.value
          : this.accelerometerZ,
      gyroscopeX: data.gyroscopeX.present
          ? data.gyroscopeX.value
          : this.gyroscopeX,
      gyroscopeY: data.gyroscopeY.present
          ? data.gyroscopeY.value
          : this.gyroscopeY,
      gyroscopeZ: data.gyroscopeZ.present
          ? data.gyroscopeZ.value
          : this.gyroscopeZ,
      magnetometerX: data.magnetometerX.present
          ? data.magnetometerX.value
          : this.magnetometerX,
      magnetometerY: data.magnetometerY.present
          ? data.magnetometerY.value
          : this.magnetometerY,
      magnetometerZ: data.magnetometerZ.present
          ? data.magnetometerZ.value
          : this.magnetometerZ,
      deviceOrientation: data.deviceOrientation.present
          ? data.deviceOrientation.value
          : this.deviceOrientation,
      samplingRate: data.samplingRate.present
          ? data.samplingRate.value
          : this.samplingRate,
      speed: data.speed.present ? data.speed.value : this.speed,
      activityState: data.activityState.present
          ? data.activityState.value
          : this.activityState,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SensorSample(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('accelerometerX: $accelerometerX, ')
          ..write('accelerometerY: $accelerometerY, ')
          ..write('accelerometerZ: $accelerometerZ, ')
          ..write('gyroscopeX: $gyroscopeX, ')
          ..write('gyroscopeY: $gyroscopeY, ')
          ..write('gyroscopeZ: $gyroscopeZ, ')
          ..write('magnetometerX: $magnetometerX, ')
          ..write('magnetometerY: $magnetometerY, ')
          ..write('magnetometerZ: $magnetometerZ, ')
          ..write('deviceOrientation: $deviceOrientation, ')
          ..write('samplingRate: $samplingRate, ')
          ..write('speed: $speed, ')
          ..write('activityState: $activityState, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    recordedAt,
    accelerometerX,
    accelerometerY,
    accelerometerZ,
    gyroscopeX,
    gyroscopeY,
    gyroscopeZ,
    magnetometerX,
    magnetometerY,
    magnetometerZ,
    deviceOrientation,
    samplingRate,
    speed,
    activityState,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SensorSample &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.recordedAt == this.recordedAt &&
          other.accelerometerX == this.accelerometerX &&
          other.accelerometerY == this.accelerometerY &&
          other.accelerometerZ == this.accelerometerZ &&
          other.gyroscopeX == this.gyroscopeX &&
          other.gyroscopeY == this.gyroscopeY &&
          other.gyroscopeZ == this.gyroscopeZ &&
          other.magnetometerX == this.magnetometerX &&
          other.magnetometerY == this.magnetometerY &&
          other.magnetometerZ == this.magnetometerZ &&
          other.deviceOrientation == this.deviceOrientation &&
          other.samplingRate == this.samplingRate &&
          other.speed == this.speed &&
          other.activityState == this.activityState &&
          other.syncStatus == this.syncStatus);
}

class SensorSamplesCompanion extends UpdateCompanion<SensorSample> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<DateTime> recordedAt;
  final Value<double?> accelerometerX;
  final Value<double?> accelerometerY;
  final Value<double?> accelerometerZ;
  final Value<double?> gyroscopeX;
  final Value<double?> gyroscopeY;
  final Value<double?> gyroscopeZ;
  final Value<double?> magnetometerX;
  final Value<double?> magnetometerY;
  final Value<double?> magnetometerZ;
  final Value<String?> deviceOrientation;
  final Value<double?> samplingRate;
  final Value<double?> speed;
  final Value<String?> activityState;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const SensorSamplesCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.accelerometerX = const Value.absent(),
    this.accelerometerY = const Value.absent(),
    this.accelerometerZ = const Value.absent(),
    this.gyroscopeX = const Value.absent(),
    this.gyroscopeY = const Value.absent(),
    this.gyroscopeZ = const Value.absent(),
    this.magnetometerX = const Value.absent(),
    this.magnetometerY = const Value.absent(),
    this.magnetometerZ = const Value.absent(),
    this.deviceOrientation = const Value.absent(),
    this.samplingRate = const Value.absent(),
    this.speed = const Value.absent(),
    this.activityState = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SensorSamplesCompanion.insert({
    required String id,
    required String tripId,
    required DateTime recordedAt,
    this.accelerometerX = const Value.absent(),
    this.accelerometerY = const Value.absent(),
    this.accelerometerZ = const Value.absent(),
    this.gyroscopeX = const Value.absent(),
    this.gyroscopeY = const Value.absent(),
    this.gyroscopeZ = const Value.absent(),
    this.magnetometerX = const Value.absent(),
    this.magnetometerY = const Value.absent(),
    this.magnetometerZ = const Value.absent(),
    this.deviceOrientation = const Value.absent(),
    this.samplingRate = const Value.absent(),
    this.speed = const Value.absent(),
    this.activityState = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       recordedAt = Value(recordedAt);
  static Insertable<SensorSample> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<DateTime>? recordedAt,
    Expression<double>? accelerometerX,
    Expression<double>? accelerometerY,
    Expression<double>? accelerometerZ,
    Expression<double>? gyroscopeX,
    Expression<double>? gyroscopeY,
    Expression<double>? gyroscopeZ,
    Expression<double>? magnetometerX,
    Expression<double>? magnetometerY,
    Expression<double>? magnetometerZ,
    Expression<String>? deviceOrientation,
    Expression<double>? samplingRate,
    Expression<double>? speed,
    Expression<String>? activityState,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (accelerometerX != null) 'accelerometer_x': accelerometerX,
      if (accelerometerY != null) 'accelerometer_y': accelerometerY,
      if (accelerometerZ != null) 'accelerometer_z': accelerometerZ,
      if (gyroscopeX != null) 'gyroscope_x': gyroscopeX,
      if (gyroscopeY != null) 'gyroscope_y': gyroscopeY,
      if (gyroscopeZ != null) 'gyroscope_z': gyroscopeZ,
      if (magnetometerX != null) 'magnetometer_x': magnetometerX,
      if (magnetometerY != null) 'magnetometer_y': magnetometerY,
      if (magnetometerZ != null) 'magnetometer_z': magnetometerZ,
      if (deviceOrientation != null) 'device_orientation': deviceOrientation,
      if (samplingRate != null) 'sampling_rate': samplingRate,
      if (speed != null) 'speed': speed,
      if (activityState != null) 'activity_state': activityState,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SensorSamplesCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<DateTime>? recordedAt,
    Value<double?>? accelerometerX,
    Value<double?>? accelerometerY,
    Value<double?>? accelerometerZ,
    Value<double?>? gyroscopeX,
    Value<double?>? gyroscopeY,
    Value<double?>? gyroscopeZ,
    Value<double?>? magnetometerX,
    Value<double?>? magnetometerY,
    Value<double?>? magnetometerZ,
    Value<String?>? deviceOrientation,
    Value<double?>? samplingRate,
    Value<double?>? speed,
    Value<String?>? activityState,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return SensorSamplesCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      recordedAt: recordedAt ?? this.recordedAt,
      accelerometerX: accelerometerX ?? this.accelerometerX,
      accelerometerY: accelerometerY ?? this.accelerometerY,
      accelerometerZ: accelerometerZ ?? this.accelerometerZ,
      gyroscopeX: gyroscopeX ?? this.gyroscopeX,
      gyroscopeY: gyroscopeY ?? this.gyroscopeY,
      gyroscopeZ: gyroscopeZ ?? this.gyroscopeZ,
      magnetometerX: magnetometerX ?? this.magnetometerX,
      magnetometerY: magnetometerY ?? this.magnetometerY,
      magnetometerZ: magnetometerZ ?? this.magnetometerZ,
      deviceOrientation: deviceOrientation ?? this.deviceOrientation,
      samplingRate: samplingRate ?? this.samplingRate,
      speed: speed ?? this.speed,
      activityState: activityState ?? this.activityState,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (accelerometerX.present) {
      map['accelerometer_x'] = Variable<double>(accelerometerX.value);
    }
    if (accelerometerY.present) {
      map['accelerometer_y'] = Variable<double>(accelerometerY.value);
    }
    if (accelerometerZ.present) {
      map['accelerometer_z'] = Variable<double>(accelerometerZ.value);
    }
    if (gyroscopeX.present) {
      map['gyroscope_x'] = Variable<double>(gyroscopeX.value);
    }
    if (gyroscopeY.present) {
      map['gyroscope_y'] = Variable<double>(gyroscopeY.value);
    }
    if (gyroscopeZ.present) {
      map['gyroscope_z'] = Variable<double>(gyroscopeZ.value);
    }
    if (magnetometerX.present) {
      map['magnetometer_x'] = Variable<double>(magnetometerX.value);
    }
    if (magnetometerY.present) {
      map['magnetometer_y'] = Variable<double>(magnetometerY.value);
    }
    if (magnetometerZ.present) {
      map['magnetometer_z'] = Variable<double>(magnetometerZ.value);
    }
    if (deviceOrientation.present) {
      map['device_orientation'] = Variable<String>(deviceOrientation.value);
    }
    if (samplingRate.present) {
      map['sampling_rate'] = Variable<double>(samplingRate.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (activityState.present) {
      map['activity_state'] = Variable<String>(activityState.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SensorSamplesCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('accelerometerX: $accelerometerX, ')
          ..write('accelerometerY: $accelerometerY, ')
          ..write('accelerometerZ: $accelerometerZ, ')
          ..write('gyroscopeX: $gyroscopeX, ')
          ..write('gyroscopeY: $gyroscopeY, ')
          ..write('gyroscopeZ: $gyroscopeZ, ')
          ..write('magnetometerX: $magnetometerX, ')
          ..write('magnetometerY: $magnetometerY, ')
          ..write('magnetometerZ: $magnetometerZ, ')
          ..write('deviceOrientation: $deviceOrientation, ')
          ..write('samplingRate: $samplingRate, ')
          ..write('speed: $speed, ')
          ..write('activityState: $activityState, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TripStopsTable extends TripStops
    with TableInfo<$TripStopsTable, TripStop> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TripStopsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tripIdMeta = const VerificationMeta('tripId');
  @override
  late final GeneratedColumn<String> tripId = GeneratedColumn<String>(
    'trip_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _arrivalTimeMeta = const VerificationMeta(
    'arrivalTime',
  );
  @override
  late final GeneratedColumn<DateTime> arrivalTime = GeneratedColumn<DateTime>(
    'arrival_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departureTimeMeta = const VerificationMeta(
    'departureTime',
  );
  @override
  late final GeneratedColumn<DateTime> departureTime =
      GeneratedColumn<DateTime>(
        'departure_time',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _radiusMetersMeta = const VerificationMeta(
    'radiusMeters',
  );
  @override
  late final GeneratedColumn<double> radiusMeters = GeneratedColumn<double>(
    'radius_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stopTypeMeta = const VerificationMeta(
    'stopType',
  );
  @override
  late final GeneratedColumn<String> stopType = GeneratedColumn<String>(
    'stop_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unconfirmed'),
  );
  static const VerificationMeta _stopNoteMeta = const VerificationMeta(
    'stopNote',
  );
  @override
  late final GeneratedColumn<String> stopNote = GeneratedColumn<String>(
    'stop_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDestinationMeta = const VerificationMeta(
    'isDestination',
  );
  @override
  late final GeneratedColumn<bool> isDestination = GeneratedColumn<bool>(
    'is_destination',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_destination" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _confirmedByUserMeta = const VerificationMeta(
    'confirmedByUser',
  );
  @override
  late final GeneratedColumn<bool> confirmedByUser = GeneratedColumn<bool>(
    'confirmed_by_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("confirmed_by_user" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notificationSentAtMeta =
      const VerificationMeta('notificationSentAt');
  @override
  late final GeneratedColumn<DateTime> notificationSentAt =
      GeneratedColumn<DateTime>(
        'notification_sent_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tripId,
    arrivalTime,
    departureTime,
    durationSeconds,
    latitude,
    longitude,
    radiusMeters,
    address,
    stopType,
    stopNote,
    isDestination,
    confirmedByUser,
    notificationSentAt,
    syncStatus,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'trip_stops';
  @override
  VerificationContext validateIntegrity(
    Insertable<TripStop> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('trip_id')) {
      context.handle(
        _tripIdMeta,
        tripId.isAcceptableOrUnknown(data['trip_id']!, _tripIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tripIdMeta);
    }
    if (data.containsKey('arrival_time')) {
      context.handle(
        _arrivalTimeMeta,
        arrivalTime.isAcceptableOrUnknown(
          data['arrival_time']!,
          _arrivalTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_arrivalTimeMeta);
    }
    if (data.containsKey('departure_time')) {
      context.handle(
        _departureTimeMeta,
        departureTime.isAcceptableOrUnknown(
          data['departure_time']!,
          _departureTimeMeta,
        ),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('radius_meters')) {
      context.handle(
        _radiusMetersMeta,
        radiusMeters.isAcceptableOrUnknown(
          data['radius_meters']!,
          _radiusMetersMeta,
        ),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('stop_type')) {
      context.handle(
        _stopTypeMeta,
        stopType.isAcceptableOrUnknown(data['stop_type']!, _stopTypeMeta),
      );
    }
    if (data.containsKey('stop_note')) {
      context.handle(
        _stopNoteMeta,
        stopNote.isAcceptableOrUnknown(data['stop_note']!, _stopNoteMeta),
      );
    }
    if (data.containsKey('is_destination')) {
      context.handle(
        _isDestinationMeta,
        isDestination.isAcceptableOrUnknown(
          data['is_destination']!,
          _isDestinationMeta,
        ),
      );
    }
    if (data.containsKey('confirmed_by_user')) {
      context.handle(
        _confirmedByUserMeta,
        confirmedByUser.isAcceptableOrUnknown(
          data['confirmed_by_user']!,
          _confirmedByUserMeta,
        ),
      );
    }
    if (data.containsKey('notification_sent_at')) {
      context.handle(
        _notificationSentAtMeta,
        notificationSentAt.isAcceptableOrUnknown(
          data['notification_sent_at']!,
          _notificationSentAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TripStop map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TripStop(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tripId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trip_id'],
      )!,
      arrivalTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}arrival_time'],
      )!,
      departureTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}departure_time'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      radiusMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}radius_meters'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      stopType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_type'],
      )!,
      stopNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stop_note'],
      ),
      isDestination: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_destination'],
      )!,
      confirmedByUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}confirmed_by_user'],
      )!,
      notificationSentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}notification_sent_at'],
      ),
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TripStopsTable createAlias(String alias) {
    return $TripStopsTable(attachedDatabase, alias);
  }
}

class TripStop extends DataClass implements Insertable<TripStop> {
  final String id;
  final String tripId;
  final DateTime arrivalTime;
  final DateTime? departureTime;
  final int durationSeconds;
  final double latitude;
  final double longitude;
  final double? radiusMeters;
  final String? address;

  /// [StopType] name; `unconfirmed` until the user labels it.
  final String stopType;
  final String? stopNote;
  final bool isDestination;
  final bool confirmedByUser;
  final DateTime? notificationSentAt;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TripStop({
    required this.id,
    required this.tripId,
    required this.arrivalTime,
    this.departureTime,
    required this.durationSeconds,
    required this.latitude,
    required this.longitude,
    this.radiusMeters,
    this.address,
    required this.stopType,
    this.stopNote,
    required this.isDestination,
    required this.confirmedByUser,
    this.notificationSentAt,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['trip_id'] = Variable<String>(tripId);
    map['arrival_time'] = Variable<DateTime>(arrivalTime);
    if (!nullToAbsent || departureTime != null) {
      map['departure_time'] = Variable<DateTime>(departureTime);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || radiusMeters != null) {
      map['radius_meters'] = Variable<double>(radiusMeters);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    map['stop_type'] = Variable<String>(stopType);
    if (!nullToAbsent || stopNote != null) {
      map['stop_note'] = Variable<String>(stopNote);
    }
    map['is_destination'] = Variable<bool>(isDestination);
    map['confirmed_by_user'] = Variable<bool>(confirmedByUser);
    if (!nullToAbsent || notificationSentAt != null) {
      map['notification_sent_at'] = Variable<DateTime>(notificationSentAt);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TripStopsCompanion toCompanion(bool nullToAbsent) {
    return TripStopsCompanion(
      id: Value(id),
      tripId: Value(tripId),
      arrivalTime: Value(arrivalTime),
      departureTime: departureTime == null && nullToAbsent
          ? const Value.absent()
          : Value(departureTime),
      durationSeconds: Value(durationSeconds),
      latitude: Value(latitude),
      longitude: Value(longitude),
      radiusMeters: radiusMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(radiusMeters),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      stopType: Value(stopType),
      stopNote: stopNote == null && nullToAbsent
          ? const Value.absent()
          : Value(stopNote),
      isDestination: Value(isDestination),
      confirmedByUser: Value(confirmedByUser),
      notificationSentAt: notificationSentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(notificationSentAt),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TripStop.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TripStop(
      id: serializer.fromJson<String>(json['id']),
      tripId: serializer.fromJson<String>(json['tripId']),
      arrivalTime: serializer.fromJson<DateTime>(json['arrivalTime']),
      departureTime: serializer.fromJson<DateTime?>(json['departureTime']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      radiusMeters: serializer.fromJson<double?>(json['radiusMeters']),
      address: serializer.fromJson<String?>(json['address']),
      stopType: serializer.fromJson<String>(json['stopType']),
      stopNote: serializer.fromJson<String?>(json['stopNote']),
      isDestination: serializer.fromJson<bool>(json['isDestination']),
      confirmedByUser: serializer.fromJson<bool>(json['confirmedByUser']),
      notificationSentAt: serializer.fromJson<DateTime?>(
        json['notificationSentAt'],
      ),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tripId': serializer.toJson<String>(tripId),
      'arrivalTime': serializer.toJson<DateTime>(arrivalTime),
      'departureTime': serializer.toJson<DateTime?>(departureTime),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'radiusMeters': serializer.toJson<double?>(radiusMeters),
      'address': serializer.toJson<String?>(address),
      'stopType': serializer.toJson<String>(stopType),
      'stopNote': serializer.toJson<String?>(stopNote),
      'isDestination': serializer.toJson<bool>(isDestination),
      'confirmedByUser': serializer.toJson<bool>(confirmedByUser),
      'notificationSentAt': serializer.toJson<DateTime?>(notificationSentAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TripStop copyWith({
    String? id,
    String? tripId,
    DateTime? arrivalTime,
    Value<DateTime?> departureTime = const Value.absent(),
    int? durationSeconds,
    double? latitude,
    double? longitude,
    Value<double?> radiusMeters = const Value.absent(),
    Value<String?> address = const Value.absent(),
    String? stopType,
    Value<String?> stopNote = const Value.absent(),
    bool? isDestination,
    bool? confirmedByUser,
    Value<DateTime?> notificationSentAt = const Value.absent(),
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TripStop(
    id: id ?? this.id,
    tripId: tripId ?? this.tripId,
    arrivalTime: arrivalTime ?? this.arrivalTime,
    departureTime: departureTime.present
        ? departureTime.value
        : this.departureTime,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    radiusMeters: radiusMeters.present ? radiusMeters.value : this.radiusMeters,
    address: address.present ? address.value : this.address,
    stopType: stopType ?? this.stopType,
    stopNote: stopNote.present ? stopNote.value : this.stopNote,
    isDestination: isDestination ?? this.isDestination,
    confirmedByUser: confirmedByUser ?? this.confirmedByUser,
    notificationSentAt: notificationSentAt.present
        ? notificationSentAt.value
        : this.notificationSentAt,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TripStop copyWithCompanion(TripStopsCompanion data) {
    return TripStop(
      id: data.id.present ? data.id.value : this.id,
      tripId: data.tripId.present ? data.tripId.value : this.tripId,
      arrivalTime: data.arrivalTime.present
          ? data.arrivalTime.value
          : this.arrivalTime,
      departureTime: data.departureTime.present
          ? data.departureTime.value
          : this.departureTime,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      radiusMeters: data.radiusMeters.present
          ? data.radiusMeters.value
          : this.radiusMeters,
      address: data.address.present ? data.address.value : this.address,
      stopType: data.stopType.present ? data.stopType.value : this.stopType,
      stopNote: data.stopNote.present ? data.stopNote.value : this.stopNote,
      isDestination: data.isDestination.present
          ? data.isDestination.value
          : this.isDestination,
      confirmedByUser: data.confirmedByUser.present
          ? data.confirmedByUser.value
          : this.confirmedByUser,
      notificationSentAt: data.notificationSentAt.present
          ? data.notificationSentAt.value
          : this.notificationSentAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TripStop(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('arrivalTime: $arrivalTime, ')
          ..write('departureTime: $departureTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('address: $address, ')
          ..write('stopType: $stopType, ')
          ..write('stopNote: $stopNote, ')
          ..write('isDestination: $isDestination, ')
          ..write('confirmedByUser: $confirmedByUser, ')
          ..write('notificationSentAt: $notificationSentAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tripId,
    arrivalTime,
    departureTime,
    durationSeconds,
    latitude,
    longitude,
    radiusMeters,
    address,
    stopType,
    stopNote,
    isDestination,
    confirmedByUser,
    notificationSentAt,
    syncStatus,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TripStop &&
          other.id == this.id &&
          other.tripId == this.tripId &&
          other.arrivalTime == this.arrivalTime &&
          other.departureTime == this.departureTime &&
          other.durationSeconds == this.durationSeconds &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.radiusMeters == this.radiusMeters &&
          other.address == this.address &&
          other.stopType == this.stopType &&
          other.stopNote == this.stopNote &&
          other.isDestination == this.isDestination &&
          other.confirmedByUser == this.confirmedByUser &&
          other.notificationSentAt == this.notificationSentAt &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TripStopsCompanion extends UpdateCompanion<TripStop> {
  final Value<String> id;
  final Value<String> tripId;
  final Value<DateTime> arrivalTime;
  final Value<DateTime?> departureTime;
  final Value<int> durationSeconds;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> radiusMeters;
  final Value<String?> address;
  final Value<String> stopType;
  final Value<String?> stopNote;
  final Value<bool> isDestination;
  final Value<bool> confirmedByUser;
  final Value<DateTime?> notificationSentAt;
  final Value<String> syncStatus;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TripStopsCompanion({
    this.id = const Value.absent(),
    this.tripId = const Value.absent(),
    this.arrivalTime = const Value.absent(),
    this.departureTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.radiusMeters = const Value.absent(),
    this.address = const Value.absent(),
    this.stopType = const Value.absent(),
    this.stopNote = const Value.absent(),
    this.isDestination = const Value.absent(),
    this.confirmedByUser = const Value.absent(),
    this.notificationSentAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TripStopsCompanion.insert({
    required String id,
    required String tripId,
    required DateTime arrivalTime,
    this.departureTime = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    required double latitude,
    required double longitude,
    this.radiusMeters = const Value.absent(),
    this.address = const Value.absent(),
    this.stopType = const Value.absent(),
    this.stopNote = const Value.absent(),
    this.isDestination = const Value.absent(),
    this.confirmedByUser = const Value.absent(),
    this.notificationSentAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       tripId = Value(tripId),
       arrivalTime = Value(arrivalTime),
       latitude = Value(latitude),
       longitude = Value(longitude),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TripStop> custom({
    Expression<String>? id,
    Expression<String>? tripId,
    Expression<DateTime>? arrivalTime,
    Expression<DateTime>? departureTime,
    Expression<int>? durationSeconds,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? radiusMeters,
    Expression<String>? address,
    Expression<String>? stopType,
    Expression<String>? stopNote,
    Expression<bool>? isDestination,
    Expression<bool>? confirmedByUser,
    Expression<DateTime>? notificationSentAt,
    Expression<String>? syncStatus,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tripId != null) 'trip_id': tripId,
      if (arrivalTime != null) 'arrival_time': arrivalTime,
      if (departureTime != null) 'departure_time': departureTime,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (radiusMeters != null) 'radius_meters': radiusMeters,
      if (address != null) 'address': address,
      if (stopType != null) 'stop_type': stopType,
      if (stopNote != null) 'stop_note': stopNote,
      if (isDestination != null) 'is_destination': isDestination,
      if (confirmedByUser != null) 'confirmed_by_user': confirmedByUser,
      if (notificationSentAt != null)
        'notification_sent_at': notificationSentAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TripStopsCompanion copyWith({
    Value<String>? id,
    Value<String>? tripId,
    Value<DateTime>? arrivalTime,
    Value<DateTime?>? departureTime,
    Value<int>? durationSeconds,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? radiusMeters,
    Value<String?>? address,
    Value<String>? stopType,
    Value<String?>? stopNote,
    Value<bool>? isDestination,
    Value<bool>? confirmedByUser,
    Value<DateTime?>? notificationSentAt,
    Value<String>? syncStatus,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TripStopsCompanion(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      departureTime: departureTime ?? this.departureTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusMeters: radiusMeters ?? this.radiusMeters,
      address: address ?? this.address,
      stopType: stopType ?? this.stopType,
      stopNote: stopNote ?? this.stopNote,
      isDestination: isDestination ?? this.isDestination,
      confirmedByUser: confirmedByUser ?? this.confirmedByUser,
      notificationSentAt: notificationSentAt ?? this.notificationSentAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tripId.present) {
      map['trip_id'] = Variable<String>(tripId.value);
    }
    if (arrivalTime.present) {
      map['arrival_time'] = Variable<DateTime>(arrivalTime.value);
    }
    if (departureTime.present) {
      map['departure_time'] = Variable<DateTime>(departureTime.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (radiusMeters.present) {
      map['radius_meters'] = Variable<double>(radiusMeters.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (stopType.present) {
      map['stop_type'] = Variable<String>(stopType.value);
    }
    if (stopNote.present) {
      map['stop_note'] = Variable<String>(stopNote.value);
    }
    if (isDestination.present) {
      map['is_destination'] = Variable<bool>(isDestination.value);
    }
    if (confirmedByUser.present) {
      map['confirmed_by_user'] = Variable<bool>(confirmedByUser.value);
    }
    if (notificationSentAt.present) {
      map['notification_sent_at'] = Variable<DateTime>(
        notificationSentAt.value,
      );
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TripStopsCompanion(')
          ..write('id: $id, ')
          ..write('tripId: $tripId, ')
          ..write('arrivalTime: $arrivalTime, ')
          ..write('departureTime: $departureTime, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('radiusMeters: $radiusMeters, ')
          ..write('address: $address, ')
          ..write('stopType: $stopType, ')
          ..write('stopNote: $stopNote, ')
          ..write('isDestination: $isDestination, ')
          ..write('confirmedByUser: $confirmedByUser, ')
          ..write('notificationSentAt: $notificationSentAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $TripsTable trips = $TripsTable(this);
  late final $TripPointsTable tripPoints = $TripPointsTable(this);
  late final $ActivityEventsTable activityEvents = $ActivityEventsTable(this);
  late final $SensorSamplesTable sensorSamples = $SensorSamplesTable(this);
  late final $TripStopsTable tripStops = $TripStopsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    trips,
    tripPoints,
    activityEvents,
    sensorSamples,
    tripStops,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      required String id,
      required String email,
      Value<String?> displayName,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<String> id,
      Value<String> email,
      Value<String?> displayName,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> displayName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                email: email,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String email,
                Value<String?> displayName = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                email: email,
                displayName: displayName,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$TripsTableCreateCompanionBuilder =
    TripsCompanion Function({
      required String id,
      required String userId,
      required String status,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<double?> startLatitude,
      Value<double?> startLongitude,
      Value<double?> endLatitude,
      Value<double?> endLongitude,
      Value<String?> startAddress,
      Value<String?> endAddress,
      Value<double> distanceMeters,
      Value<int> elapsedDurationSeconds,
      Value<int> movingDurationSeconds,
      Value<int> stoppedDurationSeconds,
      Value<double> averageSpeedKmh,
      Value<double> movingAverageSpeedKmh,
      Value<double> maximumSpeedKmh,
      Value<String> detectedVehicleType,
      Value<String?> confirmedVehicleType,
      Value<double?> vehicleConfidence,
      Value<DateTime?> vehicleConfirmedAt,
      Value<bool?> vehiclePredictionChanged,
      Value<int> stopCount,
      Value<int> summaryAlgorithmVersion,
      Value<bool> finishedAutomatically,
      Value<String?> finishReason,
      Value<bool> arrivalCorrectedByUser,
      Value<String?> deviceModel,
      Value<String?> operatingSystem,
      Value<String?> operatingSystemVersion,
      Value<String?> appVersion,
      Value<String?> phoneMountPosition,
      Value<String> syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TripsTableUpdateCompanionBuilder =
    TripsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> status,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<double?> startLatitude,
      Value<double?> startLongitude,
      Value<double?> endLatitude,
      Value<double?> endLongitude,
      Value<String?> startAddress,
      Value<String?> endAddress,
      Value<double> distanceMeters,
      Value<int> elapsedDurationSeconds,
      Value<int> movingDurationSeconds,
      Value<int> stoppedDurationSeconds,
      Value<double> averageSpeedKmh,
      Value<double> movingAverageSpeedKmh,
      Value<double> maximumSpeedKmh,
      Value<String> detectedVehicleType,
      Value<String?> confirmedVehicleType,
      Value<double?> vehicleConfidence,
      Value<DateTime?> vehicleConfirmedAt,
      Value<bool?> vehiclePredictionChanged,
      Value<int> stopCount,
      Value<int> summaryAlgorithmVersion,
      Value<bool> finishedAutomatically,
      Value<String?> finishReason,
      Value<bool> arrivalCorrectedByUser,
      Value<String?> deviceModel,
      Value<String?> operatingSystem,
      Value<String?> operatingSystemVersion,
      Value<String?> appVersion,
      Value<String?> phoneMountPosition,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TripsTableFilterComposer extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLatitude => $composableBuilder(
    column: $table.startLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get startLongitude => $composableBuilder(
    column: $table.startLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLatitude => $composableBuilder(
    column: $table.endLatitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get endLongitude => $composableBuilder(
    column: $table.endLongitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startAddress => $composableBuilder(
    column: $table.startAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endAddress => $composableBuilder(
    column: $table.endAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get elapsedDurationSeconds => $composableBuilder(
    column: $table.elapsedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get movingDurationSeconds => $composableBuilder(
    column: $table.movingDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stoppedDurationSeconds => $composableBuilder(
    column: $table.stoppedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get movingAverageSpeedKmh => $composableBuilder(
    column: $table.movingAverageSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maximumSpeedKmh => $composableBuilder(
    column: $table.maximumSpeedKmh,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get detectedVehicleType => $composableBuilder(
    column: $table.detectedVehicleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get confirmedVehicleType => $composableBuilder(
    column: $table.confirmedVehicleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vehicleConfidence => $composableBuilder(
    column: $table.vehicleConfidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get vehicleConfirmedAt => $composableBuilder(
    column: $table.vehicleConfirmedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get vehiclePredictionChanged => $composableBuilder(
    column: $table.vehiclePredictionChanged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stopCount => $composableBuilder(
    column: $table.stopCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get summaryAlgorithmVersion => $composableBuilder(
    column: $table.summaryAlgorithmVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get finishedAutomatically => $composableBuilder(
    column: $table.finishedAutomatically,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get finishReason => $composableBuilder(
    column: $table.finishReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get arrivalCorrectedByUser => $composableBuilder(
    column: $table.arrivalCorrectedByUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatingSystem => $composableBuilder(
    column: $table.operatingSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operatingSystemVersion => $composableBuilder(
    column: $table.operatingSystemVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phoneMountPosition => $composableBuilder(
    column: $table.phoneMountPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLatitude => $composableBuilder(
    column: $table.startLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get startLongitude => $composableBuilder(
    column: $table.startLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLatitude => $composableBuilder(
    column: $table.endLatitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get endLongitude => $composableBuilder(
    column: $table.endLongitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startAddress => $composableBuilder(
    column: $table.startAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endAddress => $composableBuilder(
    column: $table.endAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get elapsedDurationSeconds => $composableBuilder(
    column: $table.elapsedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get movingDurationSeconds => $composableBuilder(
    column: $table.movingDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stoppedDurationSeconds => $composableBuilder(
    column: $table.stoppedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get movingAverageSpeedKmh => $composableBuilder(
    column: $table.movingAverageSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maximumSpeedKmh => $composableBuilder(
    column: $table.maximumSpeedKmh,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get detectedVehicleType => $composableBuilder(
    column: $table.detectedVehicleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get confirmedVehicleType => $composableBuilder(
    column: $table.confirmedVehicleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vehicleConfidence => $composableBuilder(
    column: $table.vehicleConfidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get vehicleConfirmedAt => $composableBuilder(
    column: $table.vehicleConfirmedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get vehiclePredictionChanged => $composableBuilder(
    column: $table.vehiclePredictionChanged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stopCount => $composableBuilder(
    column: $table.stopCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get summaryAlgorithmVersion => $composableBuilder(
    column: $table.summaryAlgorithmVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get finishedAutomatically => $composableBuilder(
    column: $table.finishedAutomatically,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishReason => $composableBuilder(
    column: $table.finishReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get arrivalCorrectedByUser => $composableBuilder(
    column: $table.arrivalCorrectedByUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatingSystem => $composableBuilder(
    column: $table.operatingSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operatingSystemVersion => $composableBuilder(
    column: $table.operatingSystemVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phoneMountPosition => $composableBuilder(
    column: $table.phoneMountPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripsTable> {
  $$TripsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<double> get startLatitude => $composableBuilder(
    column: $table.startLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get startLongitude => $composableBuilder(
    column: $table.startLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endLatitude => $composableBuilder(
    column: $table.endLatitude,
    builder: (column) => column,
  );

  GeneratedColumn<double> get endLongitude => $composableBuilder(
    column: $table.endLongitude,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startAddress => $composableBuilder(
    column: $table.startAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get endAddress => $composableBuilder(
    column: $table.endAddress,
    builder: (column) => column,
  );

  GeneratedColumn<double> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get elapsedDurationSeconds => $composableBuilder(
    column: $table.elapsedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get movingDurationSeconds => $composableBuilder(
    column: $table.movingDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stoppedDurationSeconds => $composableBuilder(
    column: $table.stoppedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageSpeedKmh => $composableBuilder(
    column: $table.averageSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get movingAverageSpeedKmh => $composableBuilder(
    column: $table.movingAverageSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maximumSpeedKmh => $composableBuilder(
    column: $table.maximumSpeedKmh,
    builder: (column) => column,
  );

  GeneratedColumn<String> get detectedVehicleType => $composableBuilder(
    column: $table.detectedVehicleType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get confirmedVehicleType => $composableBuilder(
    column: $table.confirmedVehicleType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get vehicleConfidence => $composableBuilder(
    column: $table.vehicleConfidence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get vehicleConfirmedAt => $composableBuilder(
    column: $table.vehicleConfirmedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get vehiclePredictionChanged => $composableBuilder(
    column: $table.vehiclePredictionChanged,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stopCount =>
      $composableBuilder(column: $table.stopCount, builder: (column) => column);

  GeneratedColumn<int> get summaryAlgorithmVersion => $composableBuilder(
    column: $table.summaryAlgorithmVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get finishedAutomatically => $composableBuilder(
    column: $table.finishedAutomatically,
    builder: (column) => column,
  );

  GeneratedColumn<String> get finishReason => $composableBuilder(
    column: $table.finishReason,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get arrivalCorrectedByUser => $composableBuilder(
    column: $table.arrivalCorrectedByUser,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceModel => $composableBuilder(
    column: $table.deviceModel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operatingSystem => $composableBuilder(
    column: $table.operatingSystem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operatingSystemVersion => $composableBuilder(
    column: $table.operatingSystemVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phoneMountPosition => $composableBuilder(
    column: $table.phoneMountPosition,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TripsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripsTable,
          Trip,
          $$TripsTableFilterComposer,
          $$TripsTableOrderingComposer,
          $$TripsTableAnnotationComposer,
          $$TripsTableCreateCompanionBuilder,
          $$TripsTableUpdateCompanionBuilder,
          (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
          Trip,
          PrefetchHooks Function()
        > {
  $$TripsTableTableManager(_$AppDatabase db, $TripsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> startLatitude = const Value.absent(),
                Value<double?> startLongitude = const Value.absent(),
                Value<double?> endLatitude = const Value.absent(),
                Value<double?> endLongitude = const Value.absent(),
                Value<String?> startAddress = const Value.absent(),
                Value<String?> endAddress = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> elapsedDurationSeconds = const Value.absent(),
                Value<int> movingDurationSeconds = const Value.absent(),
                Value<int> stoppedDurationSeconds = const Value.absent(),
                Value<double> averageSpeedKmh = const Value.absent(),
                Value<double> movingAverageSpeedKmh = const Value.absent(),
                Value<double> maximumSpeedKmh = const Value.absent(),
                Value<String> detectedVehicleType = const Value.absent(),
                Value<String?> confirmedVehicleType = const Value.absent(),
                Value<double?> vehicleConfidence = const Value.absent(),
                Value<DateTime?> vehicleConfirmedAt = const Value.absent(),
                Value<bool?> vehiclePredictionChanged = const Value.absent(),
                Value<int> stopCount = const Value.absent(),
                Value<int> summaryAlgorithmVersion = const Value.absent(),
                Value<bool> finishedAutomatically = const Value.absent(),
                Value<String?> finishReason = const Value.absent(),
                Value<bool> arrivalCorrectedByUser = const Value.absent(),
                Value<String?> deviceModel = const Value.absent(),
                Value<String?> operatingSystem = const Value.absent(),
                Value<String?> operatingSystemVersion = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<String?> phoneMountPosition = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion(
                id: id,
                userId: userId,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                startLatitude: startLatitude,
                startLongitude: startLongitude,
                endLatitude: endLatitude,
                endLongitude: endLongitude,
                startAddress: startAddress,
                endAddress: endAddress,
                distanceMeters: distanceMeters,
                elapsedDurationSeconds: elapsedDurationSeconds,
                movingDurationSeconds: movingDurationSeconds,
                stoppedDurationSeconds: stoppedDurationSeconds,
                averageSpeedKmh: averageSpeedKmh,
                movingAverageSpeedKmh: movingAverageSpeedKmh,
                maximumSpeedKmh: maximumSpeedKmh,
                detectedVehicleType: detectedVehicleType,
                confirmedVehicleType: confirmedVehicleType,
                vehicleConfidence: vehicleConfidence,
                vehicleConfirmedAt: vehicleConfirmedAt,
                vehiclePredictionChanged: vehiclePredictionChanged,
                stopCount: stopCount,
                summaryAlgorithmVersion: summaryAlgorithmVersion,
                finishedAutomatically: finishedAutomatically,
                finishReason: finishReason,
                arrivalCorrectedByUser: arrivalCorrectedByUser,
                deviceModel: deviceModel,
                operatingSystem: operatingSystem,
                operatingSystemVersion: operatingSystemVersion,
                appVersion: appVersion,
                phoneMountPosition: phoneMountPosition,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String status,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<double?> startLatitude = const Value.absent(),
                Value<double?> startLongitude = const Value.absent(),
                Value<double?> endLatitude = const Value.absent(),
                Value<double?> endLongitude = const Value.absent(),
                Value<String?> startAddress = const Value.absent(),
                Value<String?> endAddress = const Value.absent(),
                Value<double> distanceMeters = const Value.absent(),
                Value<int> elapsedDurationSeconds = const Value.absent(),
                Value<int> movingDurationSeconds = const Value.absent(),
                Value<int> stoppedDurationSeconds = const Value.absent(),
                Value<double> averageSpeedKmh = const Value.absent(),
                Value<double> movingAverageSpeedKmh = const Value.absent(),
                Value<double> maximumSpeedKmh = const Value.absent(),
                Value<String> detectedVehicleType = const Value.absent(),
                Value<String?> confirmedVehicleType = const Value.absent(),
                Value<double?> vehicleConfidence = const Value.absent(),
                Value<DateTime?> vehicleConfirmedAt = const Value.absent(),
                Value<bool?> vehiclePredictionChanged = const Value.absent(),
                Value<int> stopCount = const Value.absent(),
                Value<int> summaryAlgorithmVersion = const Value.absent(),
                Value<bool> finishedAutomatically = const Value.absent(),
                Value<String?> finishReason = const Value.absent(),
                Value<bool> arrivalCorrectedByUser = const Value.absent(),
                Value<String?> deviceModel = const Value.absent(),
                Value<String?> operatingSystem = const Value.absent(),
                Value<String?> operatingSystemVersion = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<String?> phoneMountPosition = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TripsCompanion.insert(
                id: id,
                userId: userId,
                status: status,
                startedAt: startedAt,
                endedAt: endedAt,
                startLatitude: startLatitude,
                startLongitude: startLongitude,
                endLatitude: endLatitude,
                endLongitude: endLongitude,
                startAddress: startAddress,
                endAddress: endAddress,
                distanceMeters: distanceMeters,
                elapsedDurationSeconds: elapsedDurationSeconds,
                movingDurationSeconds: movingDurationSeconds,
                stoppedDurationSeconds: stoppedDurationSeconds,
                averageSpeedKmh: averageSpeedKmh,
                movingAverageSpeedKmh: movingAverageSpeedKmh,
                maximumSpeedKmh: maximumSpeedKmh,
                detectedVehicleType: detectedVehicleType,
                confirmedVehicleType: confirmedVehicleType,
                vehicleConfidence: vehicleConfidence,
                vehicleConfirmedAt: vehicleConfirmedAt,
                vehiclePredictionChanged: vehiclePredictionChanged,
                stopCount: stopCount,
                summaryAlgorithmVersion: summaryAlgorithmVersion,
                finishedAutomatically: finishedAutomatically,
                finishReason: finishReason,
                arrivalCorrectedByUser: arrivalCorrectedByUser,
                deviceModel: deviceModel,
                operatingSystem: operatingSystem,
                operatingSystemVersion: operatingSystemVersion,
                appVersion: appVersion,
                phoneMountPosition: phoneMountPosition,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripsTable,
      Trip,
      $$TripsTableFilterComposer,
      $$TripsTableOrderingComposer,
      $$TripsTableAnnotationComposer,
      $$TripsTableCreateCompanionBuilder,
      $$TripsTableUpdateCompanionBuilder,
      (Trip, BaseReferences<_$AppDatabase, $TripsTable, Trip>),
      Trip,
      PrefetchHooks Function()
    >;
typedef $$TripPointsTableCreateCompanionBuilder =
    TripPointsCompanion Function({
      required String id,
      required String tripId,
      required DateTime recordedAt,
      required double latitude,
      required double longitude,
      Value<double?> altitude,
      Value<double?> horizontalAccuracy,
      Value<double?> verticalAccuracy,
      Value<double?> speed,
      Value<double?> speedAccuracy,
      Value<double?> heading,
      Value<double?> headingAccuracy,
      required int sequenceNumber,
      Value<String?> source,
      Value<bool?> isMocked,
      Value<double?> batteryLevel,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$TripPointsTableUpdateCompanionBuilder =
    TripPointsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<DateTime> recordedAt,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitude,
      Value<double?> horizontalAccuracy,
      Value<double?> verticalAccuracy,
      Value<double?> speed,
      Value<double?> speedAccuracy,
      Value<double?> heading,
      Value<double?> headingAccuracy,
      Value<int> sequenceNumber,
      Value<String?> source,
      Value<bool?> isMocked,
      Value<double?> batteryLevel,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$TripPointsTableFilterComposer
    extends Composer<_$AppDatabase, $TripPointsTable> {
  $$TripPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get horizontalAccuracy => $composableBuilder(
    column: $table.horizontalAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get verticalAccuracy => $composableBuilder(
    column: $table.verticalAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedAccuracy => $composableBuilder(
    column: $table.speedAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get headingAccuracy => $composableBuilder(
    column: $table.headingAccuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMocked => $composableBuilder(
    column: $table.isMocked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripPointsTable> {
  $$TripPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get horizontalAccuracy => $composableBuilder(
    column: $table.horizontalAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get verticalAccuracy => $composableBuilder(
    column: $table.verticalAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedAccuracy => $composableBuilder(
    column: $table.speedAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get heading => $composableBuilder(
    column: $table.heading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get headingAccuracy => $composableBuilder(
    column: $table.headingAccuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMocked => $composableBuilder(
    column: $table.isMocked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripPointsTable> {
  $$TripPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<double> get horizontalAccuracy => $composableBuilder(
    column: $table.horizontalAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get verticalAccuracy => $composableBuilder(
    column: $table.verticalAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<double> get speedAccuracy => $composableBuilder(
    column: $table.speedAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<double> get heading =>
      $composableBuilder(column: $table.heading, builder: (column) => column);

  GeneratedColumn<double> get headingAccuracy => $composableBuilder(
    column: $table.headingAccuracy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sequenceNumber => $composableBuilder(
    column: $table.sequenceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<bool> get isMocked =>
      $composableBuilder(column: $table.isMocked, builder: (column) => column);

  GeneratedColumn<double> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$TripPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripPointsTable,
          TripPoint,
          $$TripPointsTableFilterComposer,
          $$TripPointsTableOrderingComposer,
          $$TripPointsTableAnnotationComposer,
          $$TripPointsTableCreateCompanionBuilder,
          $$TripPointsTableUpdateCompanionBuilder,
          (
            TripPoint,
            BaseReferences<_$AppDatabase, $TripPointsTable, TripPoint>,
          ),
          TripPoint,
          PrefetchHooks Function()
        > {
  $$TripPointsTableTableManager(_$AppDatabase db, $TripPointsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitude = const Value.absent(),
                Value<double?> horizontalAccuracy = const Value.absent(),
                Value<double?> verticalAccuracy = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> speedAccuracy = const Value.absent(),
                Value<double?> heading = const Value.absent(),
                Value<double?> headingAccuracy = const Value.absent(),
                Value<int> sequenceNumber = const Value.absent(),
                Value<String?> source = const Value.absent(),
                Value<bool?> isMocked = const Value.absent(),
                Value<double?> batteryLevel = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripPointsCompanion(
                id: id,
                tripId: tripId,
                recordedAt: recordedAt,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                verticalAccuracy: verticalAccuracy,
                speed: speed,
                speedAccuracy: speedAccuracy,
                heading: heading,
                headingAccuracy: headingAccuracy,
                sequenceNumber: sequenceNumber,
                source: source,
                isMocked: isMocked,
                batteryLevel: batteryLevel,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required DateTime recordedAt,
                required double latitude,
                required double longitude,
                Value<double?> altitude = const Value.absent(),
                Value<double?> horizontalAccuracy = const Value.absent(),
                Value<double?> verticalAccuracy = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<double?> speedAccuracy = const Value.absent(),
                Value<double?> heading = const Value.absent(),
                Value<double?> headingAccuracy = const Value.absent(),
                required int sequenceNumber,
                Value<String?> source = const Value.absent(),
                Value<bool?> isMocked = const Value.absent(),
                Value<double?> batteryLevel = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripPointsCompanion.insert(
                id: id,
                tripId: tripId,
                recordedAt: recordedAt,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                horizontalAccuracy: horizontalAccuracy,
                verticalAccuracy: verticalAccuracy,
                speed: speed,
                speedAccuracy: speedAccuracy,
                heading: heading,
                headingAccuracy: headingAccuracy,
                sequenceNumber: sequenceNumber,
                source: source,
                isMocked: isMocked,
                batteryLevel: batteryLevel,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripPointsTable,
      TripPoint,
      $$TripPointsTableFilterComposer,
      $$TripPointsTableOrderingComposer,
      $$TripPointsTableAnnotationComposer,
      $$TripPointsTableCreateCompanionBuilder,
      $$TripPointsTableUpdateCompanionBuilder,
      (TripPoint, BaseReferences<_$AppDatabase, $TripPointsTable, TripPoint>),
      TripPoint,
      PrefetchHooks Function()
    >;
typedef $$ActivityEventsTableCreateCompanionBuilder =
    ActivityEventsCompanion Function({
      required String id,
      Value<String?> tripId,
      required DateTime recordedAt,
      required String activityType,
      Value<String?> transitionType,
      Value<double?> confidence,
      required String platformSource,
      Value<String?> rawPayload,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ActivityEventsTableUpdateCompanionBuilder =
    ActivityEventsCompanion Function({
      Value<String> id,
      Value<String?> tripId,
      Value<DateTime> recordedAt,
      Value<String> activityType,
      Value<String?> transitionType,
      Value<double?> confidence,
      Value<String> platformSource,
      Value<String?> rawPayload,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ActivityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transitionType => $composableBuilder(
    column: $table.transitionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platformSource => $composableBuilder(
    column: $table.platformSource,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transitionType => $composableBuilder(
    column: $table.transitionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platformSource => $composableBuilder(
    column: $table.platformSource,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityEventsTable> {
  $$ActivityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get activityType => $composableBuilder(
    column: $table.activityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transitionType => $composableBuilder(
    column: $table.transitionType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platformSource => $composableBuilder(
    column: $table.platformSource,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rawPayload => $composableBuilder(
    column: $table.rawPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ActivityEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityEventsTable,
          ActivityEvent,
          $$ActivityEventsTableFilterComposer,
          $$ActivityEventsTableOrderingComposer,
          $$ActivityEventsTableAnnotationComposer,
          $$ActivityEventsTableCreateCompanionBuilder,
          $$ActivityEventsTableUpdateCompanionBuilder,
          (
            ActivityEvent,
            BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>,
          ),
          ActivityEvent,
          PrefetchHooks Function()
        > {
  $$ActivityEventsTableTableManager(
    _$AppDatabase db,
    $ActivityEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> tripId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<String> activityType = const Value.absent(),
                Value<String?> transitionType = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                Value<String> platformSource = const Value.absent(),
                Value<String?> rawPayload = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion(
                id: id,
                tripId: tripId,
                recordedAt: recordedAt,
                activityType: activityType,
                transitionType: transitionType,
                confidence: confidence,
                platformSource: platformSource,
                rawPayload: rawPayload,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> tripId = const Value.absent(),
                required DateTime recordedAt,
                required String activityType,
                Value<String?> transitionType = const Value.absent(),
                Value<double?> confidence = const Value.absent(),
                required String platformSource,
                Value<String?> rawPayload = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ActivityEventsCompanion.insert(
                id: id,
                tripId: tripId,
                recordedAt: recordedAt,
                activityType: activityType,
                transitionType: transitionType,
                confidence: confidence,
                platformSource: platformSource,
                rawPayload: rawPayload,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityEventsTable,
      ActivityEvent,
      $$ActivityEventsTableFilterComposer,
      $$ActivityEventsTableOrderingComposer,
      $$ActivityEventsTableAnnotationComposer,
      $$ActivityEventsTableCreateCompanionBuilder,
      $$ActivityEventsTableUpdateCompanionBuilder,
      (
        ActivityEvent,
        BaseReferences<_$AppDatabase, $ActivityEventsTable, ActivityEvent>,
      ),
      ActivityEvent,
      PrefetchHooks Function()
    >;
typedef $$SensorSamplesTableCreateCompanionBuilder =
    SensorSamplesCompanion Function({
      required String id,
      required String tripId,
      required DateTime recordedAt,
      Value<double?> accelerometerX,
      Value<double?> accelerometerY,
      Value<double?> accelerometerZ,
      Value<double?> gyroscopeX,
      Value<double?> gyroscopeY,
      Value<double?> gyroscopeZ,
      Value<double?> magnetometerX,
      Value<double?> magnetometerY,
      Value<double?> magnetometerZ,
      Value<String?> deviceOrientation,
      Value<double?> samplingRate,
      Value<double?> speed,
      Value<String?> activityState,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$SensorSamplesTableUpdateCompanionBuilder =
    SensorSamplesCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<DateTime> recordedAt,
      Value<double?> accelerometerX,
      Value<double?> accelerometerY,
      Value<double?> accelerometerZ,
      Value<double?> gyroscopeX,
      Value<double?> gyroscopeY,
      Value<double?> gyroscopeZ,
      Value<double?> magnetometerX,
      Value<double?> magnetometerY,
      Value<double?> magnetometerZ,
      Value<String?> deviceOrientation,
      Value<double?> samplingRate,
      Value<double?> speed,
      Value<String?> activityState,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$SensorSamplesTableFilterComposer
    extends Composer<_$AppDatabase, $SensorSamplesTable> {
  $$SensorSamplesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelerometerX => $composableBuilder(
    column: $table.accelerometerX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelerometerY => $composableBuilder(
    column: $table.accelerometerY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accelerometerZ => $composableBuilder(
    column: $table.accelerometerZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroscopeX => $composableBuilder(
    column: $table.gyroscopeX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroscopeY => $composableBuilder(
    column: $table.gyroscopeY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gyroscopeZ => $composableBuilder(
    column: $table.gyroscopeZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get magnetometerX => $composableBuilder(
    column: $table.magnetometerX,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get magnetometerY => $composableBuilder(
    column: $table.magnetometerY,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get magnetometerZ => $composableBuilder(
    column: $table.magnetometerZ,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceOrientation => $composableBuilder(
    column: $table.deviceOrientation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get samplingRate => $composableBuilder(
    column: $table.samplingRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get activityState => $composableBuilder(
    column: $table.activityState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SensorSamplesTableOrderingComposer
    extends Composer<_$AppDatabase, $SensorSamplesTable> {
  $$SensorSamplesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelerometerX => $composableBuilder(
    column: $table.accelerometerX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelerometerY => $composableBuilder(
    column: $table.accelerometerY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accelerometerZ => $composableBuilder(
    column: $table.accelerometerZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroscopeX => $composableBuilder(
    column: $table.gyroscopeX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroscopeY => $composableBuilder(
    column: $table.gyroscopeY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gyroscopeZ => $composableBuilder(
    column: $table.gyroscopeZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get magnetometerX => $composableBuilder(
    column: $table.magnetometerX,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get magnetometerY => $composableBuilder(
    column: $table.magnetometerY,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get magnetometerZ => $composableBuilder(
    column: $table.magnetometerZ,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceOrientation => $composableBuilder(
    column: $table.deviceOrientation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get samplingRate => $composableBuilder(
    column: $table.samplingRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activityState => $composableBuilder(
    column: $table.activityState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SensorSamplesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SensorSamplesTable> {
  $$SensorSamplesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accelerometerX => $composableBuilder(
    column: $table.accelerometerX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accelerometerY => $composableBuilder(
    column: $table.accelerometerY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get accelerometerZ => $composableBuilder(
    column: $table.accelerometerZ,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gyroscopeX => $composableBuilder(
    column: $table.gyroscopeX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gyroscopeY => $composableBuilder(
    column: $table.gyroscopeY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gyroscopeZ => $composableBuilder(
    column: $table.gyroscopeZ,
    builder: (column) => column,
  );

  GeneratedColumn<double> get magnetometerX => $composableBuilder(
    column: $table.magnetometerX,
    builder: (column) => column,
  );

  GeneratedColumn<double> get magnetometerY => $composableBuilder(
    column: $table.magnetometerY,
    builder: (column) => column,
  );

  GeneratedColumn<double> get magnetometerZ => $composableBuilder(
    column: $table.magnetometerZ,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceOrientation => $composableBuilder(
    column: $table.deviceOrientation,
    builder: (column) => column,
  );

  GeneratedColumn<double> get samplingRate => $composableBuilder(
    column: $table.samplingRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<String> get activityState => $composableBuilder(
    column: $table.activityState,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$SensorSamplesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SensorSamplesTable,
          SensorSample,
          $$SensorSamplesTableFilterComposer,
          $$SensorSamplesTableOrderingComposer,
          $$SensorSamplesTableAnnotationComposer,
          $$SensorSamplesTableCreateCompanionBuilder,
          $$SensorSamplesTableUpdateCompanionBuilder,
          (
            SensorSample,
            BaseReferences<_$AppDatabase, $SensorSamplesTable, SensorSample>,
          ),
          SensorSample,
          PrefetchHooks Function()
        > {
  $$SensorSamplesTableTableManager(_$AppDatabase db, $SensorSamplesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SensorSamplesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SensorSamplesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SensorSamplesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<double?> accelerometerX = const Value.absent(),
                Value<double?> accelerometerY = const Value.absent(),
                Value<double?> accelerometerZ = const Value.absent(),
                Value<double?> gyroscopeX = const Value.absent(),
                Value<double?> gyroscopeY = const Value.absent(),
                Value<double?> gyroscopeZ = const Value.absent(),
                Value<double?> magnetometerX = const Value.absent(),
                Value<double?> magnetometerY = const Value.absent(),
                Value<double?> magnetometerZ = const Value.absent(),
                Value<String?> deviceOrientation = const Value.absent(),
                Value<double?> samplingRate = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<String?> activityState = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SensorSamplesCompanion(
                id: id,
                tripId: tripId,
                recordedAt: recordedAt,
                accelerometerX: accelerometerX,
                accelerometerY: accelerometerY,
                accelerometerZ: accelerometerZ,
                gyroscopeX: gyroscopeX,
                gyroscopeY: gyroscopeY,
                gyroscopeZ: gyroscopeZ,
                magnetometerX: magnetometerX,
                magnetometerY: magnetometerY,
                magnetometerZ: magnetometerZ,
                deviceOrientation: deviceOrientation,
                samplingRate: samplingRate,
                speed: speed,
                activityState: activityState,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required DateTime recordedAt,
                Value<double?> accelerometerX = const Value.absent(),
                Value<double?> accelerometerY = const Value.absent(),
                Value<double?> accelerometerZ = const Value.absent(),
                Value<double?> gyroscopeX = const Value.absent(),
                Value<double?> gyroscopeY = const Value.absent(),
                Value<double?> gyroscopeZ = const Value.absent(),
                Value<double?> magnetometerX = const Value.absent(),
                Value<double?> magnetometerY = const Value.absent(),
                Value<double?> magnetometerZ = const Value.absent(),
                Value<String?> deviceOrientation = const Value.absent(),
                Value<double?> samplingRate = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<String?> activityState = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SensorSamplesCompanion.insert(
                id: id,
                tripId: tripId,
                recordedAt: recordedAt,
                accelerometerX: accelerometerX,
                accelerometerY: accelerometerY,
                accelerometerZ: accelerometerZ,
                gyroscopeX: gyroscopeX,
                gyroscopeY: gyroscopeY,
                gyroscopeZ: gyroscopeZ,
                magnetometerX: magnetometerX,
                magnetometerY: magnetometerY,
                magnetometerZ: magnetometerZ,
                deviceOrientation: deviceOrientation,
                samplingRate: samplingRate,
                speed: speed,
                activityState: activityState,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SensorSamplesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SensorSamplesTable,
      SensorSample,
      $$SensorSamplesTableFilterComposer,
      $$SensorSamplesTableOrderingComposer,
      $$SensorSamplesTableAnnotationComposer,
      $$SensorSamplesTableCreateCompanionBuilder,
      $$SensorSamplesTableUpdateCompanionBuilder,
      (
        SensorSample,
        BaseReferences<_$AppDatabase, $SensorSamplesTable, SensorSample>,
      ),
      SensorSample,
      PrefetchHooks Function()
    >;
typedef $$TripStopsTableCreateCompanionBuilder =
    TripStopsCompanion Function({
      required String id,
      required String tripId,
      required DateTime arrivalTime,
      Value<DateTime?> departureTime,
      Value<int> durationSeconds,
      required double latitude,
      required double longitude,
      Value<double?> radiusMeters,
      Value<String?> address,
      Value<String> stopType,
      Value<String?> stopNote,
      Value<bool> isDestination,
      Value<bool> confirmedByUser,
      Value<DateTime?> notificationSentAt,
      Value<String> syncStatus,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TripStopsTableUpdateCompanionBuilder =
    TripStopsCompanion Function({
      Value<String> id,
      Value<String> tripId,
      Value<DateTime> arrivalTime,
      Value<DateTime?> departureTime,
      Value<int> durationSeconds,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> radiusMeters,
      Value<String?> address,
      Value<String> stopType,
      Value<String?> stopNote,
      Value<bool> isDestination,
      Value<bool> confirmedByUser,
      Value<DateTime?> notificationSentAt,
      Value<String> syncStatus,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TripStopsTableFilterComposer
    extends Composer<_$AppDatabase, $TripStopsTable> {
  $$TripStopsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get departureTime => $composableBuilder(
    column: $table.departureTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stopType => $composableBuilder(
    column: $table.stopType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stopNote => $composableBuilder(
    column: $table.stopNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDestination => $composableBuilder(
    column: $table.isDestination,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get confirmedByUser => $composableBuilder(
    column: $table.confirmedByUser,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get notificationSentAt => $composableBuilder(
    column: $table.notificationSentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TripStopsTableOrderingComposer
    extends Composer<_$AppDatabase, $TripStopsTable> {
  $$TripStopsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tripId => $composableBuilder(
    column: $table.tripId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get departureTime => $composableBuilder(
    column: $table.departureTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopType => $composableBuilder(
    column: $table.stopType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stopNote => $composableBuilder(
    column: $table.stopNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDestination => $composableBuilder(
    column: $table.isDestination,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get confirmedByUser => $composableBuilder(
    column: $table.confirmedByUser,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get notificationSentAt => $composableBuilder(
    column: $table.notificationSentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TripStopsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TripStopsTable> {
  $$TripStopsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tripId =>
      $composableBuilder(column: $table.tripId, builder: (column) => column);

  GeneratedColumn<DateTime> get arrivalTime => $composableBuilder(
    column: $table.arrivalTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get departureTime => $composableBuilder(
    column: $table.departureTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get radiusMeters => $composableBuilder(
    column: $table.radiusMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get stopType =>
      $composableBuilder(column: $table.stopType, builder: (column) => column);

  GeneratedColumn<String> get stopNote =>
      $composableBuilder(column: $table.stopNote, builder: (column) => column);

  GeneratedColumn<bool> get isDestination => $composableBuilder(
    column: $table.isDestination,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get confirmedByUser => $composableBuilder(
    column: $table.confirmedByUser,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get notificationSentAt => $composableBuilder(
    column: $table.notificationSentAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TripStopsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TripStopsTable,
          TripStop,
          $$TripStopsTableFilterComposer,
          $$TripStopsTableOrderingComposer,
          $$TripStopsTableAnnotationComposer,
          $$TripStopsTableCreateCompanionBuilder,
          $$TripStopsTableUpdateCompanionBuilder,
          (TripStop, BaseReferences<_$AppDatabase, $TripStopsTable, TripStop>),
          TripStop,
          PrefetchHooks Function()
        > {
  $$TripStopsTableTableManager(_$AppDatabase db, $TripStopsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TripStopsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TripStopsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TripStopsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> tripId = const Value.absent(),
                Value<DateTime> arrivalTime = const Value.absent(),
                Value<DateTime?> departureTime = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> radiusMeters = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> stopType = const Value.absent(),
                Value<String?> stopNote = const Value.absent(),
                Value<bool> isDestination = const Value.absent(),
                Value<bool> confirmedByUser = const Value.absent(),
                Value<DateTime?> notificationSentAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TripStopsCompanion(
                id: id,
                tripId: tripId,
                arrivalTime: arrivalTime,
                departureTime: departureTime,
                durationSeconds: durationSeconds,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                address: address,
                stopType: stopType,
                stopNote: stopNote,
                isDestination: isDestination,
                confirmedByUser: confirmedByUser,
                notificationSentAt: notificationSentAt,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String tripId,
                required DateTime arrivalTime,
                Value<DateTime?> departureTime = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                required double latitude,
                required double longitude,
                Value<double?> radiusMeters = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String> stopType = const Value.absent(),
                Value<String?> stopNote = const Value.absent(),
                Value<bool> isDestination = const Value.absent(),
                Value<bool> confirmedByUser = const Value.absent(),
                Value<DateTime?> notificationSentAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TripStopsCompanion.insert(
                id: id,
                tripId: tripId,
                arrivalTime: arrivalTime,
                departureTime: departureTime,
                durationSeconds: durationSeconds,
                latitude: latitude,
                longitude: longitude,
                radiusMeters: radiusMeters,
                address: address,
                stopType: stopType,
                stopNote: stopNote,
                isDestination: isDestination,
                confirmedByUser: confirmedByUser,
                notificationSentAt: notificationSentAt,
                syncStatus: syncStatus,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TripStopsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TripStopsTable,
      TripStop,
      $$TripStopsTableFilterComposer,
      $$TripStopsTableOrderingComposer,
      $$TripStopsTableAnnotationComposer,
      $$TripStopsTableCreateCompanionBuilder,
      $$TripStopsTableUpdateCompanionBuilder,
      (TripStop, BaseReferences<_$AppDatabase, $TripStopsTable, TripStop>),
      TripStop,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$TripsTableTableManager get trips =>
      $$TripsTableTableManager(_db, _db.trips);
  $$TripPointsTableTableManager get tripPoints =>
      $$TripPointsTableTableManager(_db, _db.tripPoints);
  $$ActivityEventsTableTableManager get activityEvents =>
      $$ActivityEventsTableTableManager(_db, _db.activityEvents);
  $$SensorSamplesTableTableManager get sensorSamples =>
      $$SensorSamplesTableTableManager(_db, _db.sensorSamples);
  $$TripStopsTableTableManager get tripStops =>
      $$TripStopsTableTableManager(_db, _db.tripStops);
}
