import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logging/logging.dart';

import '../../features/trips/data/local_trip_data_source.dart';
import '../../features/trips/data/remote_trip_data_source.dart';
import '../constants/enums.dart';

/// Aggregate sync state exposed to the UI.
class SyncState {
  const SyncState({
    required this.status,
    this.pendingTrips = 0,
    this.lastSyncedAt,
    this.lastError,
  });

  final SyncStatus status;
  final int pendingTrips;
  final DateTime? lastSyncedAt;
  final String? lastError;

  SyncState copyWith({
    SyncStatus? status,
    int? pendingTrips,
    DateTime? lastSyncedAt,
    String? lastError,
  }) => SyncState(
    status: status ?? this.status,
    pendingTrips: pendingTrips ?? this.pendingTrips,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    lastError: lastError,
  );
}

/// Offline-first synchronization contract.
abstract interface class SyncService {
  Stream<SyncState> get stateStream;
  SyncState get state;

  /// Uploads all pending finished trips (points, activity events, sensor
  /// samples) for [userId]. Safe to call repeatedly; operations are
  /// idempotent and local data is never deleted on failure.
  Future<void> syncNow(String userId);

  /// Starts watching connectivity and syncing automatically.
  void startAutoSync(String Function() userIdProvider);

  Future<void> dispose();
}

/// Batched, retrying sync engine.
///
///  * data is written locally first — this engine only uploads;
///  * uploads run when connectivity is available;
///  * failures never delete local data (status returns to `failed`);
///  * retries use exponential backoff;
///  * UUID-keyed upserts keep every operation idempotent (no duplicates).
class DefaultSyncService implements SyncService {
  DefaultSyncService({
    required this.local,
    required this.remote,
    Connectivity? connectivity,
    this.pointBatchSize = 500,
    this.sensorBatchSize = 500,
    this.maxRetries = 4,
    this.baseBackoff = const Duration(seconds: 2),
    Future<void> Function(Duration)? delay,
  }) : _delay = delay ?? Future<void>.delayed {
    _connectivity = connectivity;
  }

  final LocalTripDataSource local;
  final RemoteTripDataSource remote;
  late final Connectivity? _connectivity;
  final int pointBatchSize;
  final int sensorBatchSize;
  final int maxRetries;
  final Duration baseBackoff;
  final Future<void> Function(Duration) _delay;

  final _log = Logger('SyncService');
  final _stateController = StreamController<SyncState>.broadcast();
  SyncState _state = const SyncState(status: SyncStatus.synced);
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  bool _syncing = false;

  @override
  Stream<SyncState> get stateStream => _stateController.stream;

  @override
  SyncState get state => _state;

  void _emit(SyncState next) {
    _state = next;
    if (!_stateController.isClosed) _stateController.add(next);
  }

  @override
  void startAutoSync(String Function() userIdProvider) {
    _connectivitySub ??= _connectivity?.onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      final userId = userIdProvider();
      if (online && userId.isNotEmpty) {
        unawaited(syncNow(userId));
      }
    });
  }

  @override
  Future<void> syncNow(String userId) async {
    if (_syncing || userId.isEmpty) return;
    _syncing = true;
    try {
      final pending = await local.tripsWithSyncStatus(userId, [
        SyncStatus.pending,
        SyncStatus.failed,
      ]);
      if (pending.isEmpty) {
        _emit(_state.copyWith(status: SyncStatus.synced, pendingTrips: 0));
        return;
      }
      _emit(
        SyncState(
          status: SyncStatus.syncing,
          pendingTrips: pending.length,
          lastSyncedAt: _state.lastSyncedAt,
        ),
      );

      var failures = 0;
      var remaining = pending.length;
      for (final trip in pending) {
        final ok = await _syncTripWithRetry(userId, trip.id);
        if (ok) {
          remaining--;
        } else {
          failures++;
        }
        _emit(
          _state.copyWith(status: SyncStatus.syncing, pendingTrips: remaining),
        );
      }

      _emit(
        SyncState(
          status: failures > 0 ? SyncStatus.failed : SyncStatus.synced,
          pendingTrips: remaining,
          lastSyncedAt: failures > 0 ? _state.lastSyncedAt : DateTime.now(),
          lastError: failures > 0 ? '$failures trip(s) failed to sync' : null,
        ),
      );
    } finally {
      _syncing = false;
    }
  }

  Future<bool> _syncTripWithRetry(String userId, String tripId) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        await _syncTrip(userId, tripId);
        return true;
      } catch (e) {
        _log.warning('sync attempt ${attempt + 1} failed for $tripId: $e');
        await local.setTripSyncStatus(tripId, SyncStatus.failed);
        if (attempt < maxRetries) {
          await _delay(baseBackoff * (1 << attempt));
        }
      }
    }
    return false;
  }

  Future<void> _syncTrip(String userId, String tripId) async {
    final trip = await local.getTrip(tripId);
    if (trip == null) return;
    await local.setTripSyncStatus(tripId, SyncStatus.syncing);

    // 1. Trip row first (points reference it).
    await remote.upsertTrip(trip);

    // 2. Points in batches so big trips do not blow request limits.
    final points = await local.pointsForTrip(tripId);
    for (var i = 0; i < points.length; i += pointBatchSize) {
      final batch = points.sublist(
        i,
        i + pointBatchSize > points.length ? points.length : i + pointBatchSize,
      );
      await remote.upsertPoints(batch);
    }
    await local.setPointsSyncStatus(tripId, SyncStatus.synced);

    // 3. Activity events tied to this trip.
    final events = await local.activityEventsForTrip(tripId);
    await remote.upsertActivityEvents(userId, events);
    await local.setActivityEventsSyncStatus([
      for (final e in events) e.id,
    ], SyncStatus.synced);

    // 4. Sensor samples in batches.
    final samples = await local.sensorSamplesForTrip(tripId);
    for (var i = 0; i < samples.length; i += sensorBatchSize) {
      final batch = samples.sublist(
        i,
        i + sensorBatchSize > samples.length
            ? samples.length
            : i + sensorBatchSize,
      );
      await remote.upsertSensorSamples(batch);
    }
    await local.setSensorSamplesSyncStatus(tripId, SyncStatus.synced);

    await local.setTripSyncStatus(tripId, SyncStatus.synced);
  }

  @override
  Future<void> dispose() async {
    await _connectivitySub?.cancel();
    await _stateController.close();
  }
}
