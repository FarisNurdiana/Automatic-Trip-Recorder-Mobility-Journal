import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../core/activity/activity_recognition_service.dart';
import '../core/activity/method_channel_activity_service.dart';
import '../core/config/env.dart';
import '../core/location/location_tracking_service.dart';
import '../core/location/method_channel_location_service.dart';
import '../core/sensors/sensor_collection_service.dart';
import '../core/sensors/sensors_plus_collection_service.dart';
import '../core/storage/app_database.dart';
import '../core/sync/sync_service.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/recording/application/trip_recording_controller.dart';
import '../features/recording/domain/trip_state_machine.dart';
import '../features/settings/application/permissions_service.dart';
import '../features/settings/application/settings_controller.dart';
import '../features/trips/data/local_trip_data_source.dart';
import '../features/trips/data/remote_trip_data_source.dart';
import '../features/trips/data/trip_repository.dart';
import '../features/trips/domain/trip_summary_calculator.dart';

// --- bootstrap-provided values (overridden in main) ---

final envProvider = Provider<Env>((ref) => throw UnimplementedError());

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(),
);

/// Device/app metadata captured once at startup.
final deviceMetadataProvider = Provider<TripDeviceMetadata>(
  (ref) => const TripDeviceMetadata(),
);

// --- storage ---

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
});

final localTripDataSourceProvider = Provider<LocalTripDataSource>(
  (ref) => DriftTripDataSource(ref.watch(databaseProvider)),
);

final tripSummaryCalculatorProvider = Provider<TripSummaryCalculator>(
  (ref) => DefaultTripSummaryCalculator(),
);

final tripRepositoryProvider = Provider<TripRepository>(
  (ref) => DefaultTripRepository(
    local: ref.watch(localTripDataSourceProvider),
    summaryCalculator: ref.watch(tripSummaryCalculatorProvider),
  ),
);

// --- auth ---

final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  final env = ref.watch(envProvider);
  if (!env.isSupabaseConfigured) return null;
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null
      ? const UnavailableAuthRepository()
      : SupabaseAuthRepository(client);
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      repository: ref.watch(authRepositoryProvider),
      localModeEnabled: () => ref.read(settingsControllerProvider).localMode,
      onLocalModeChanged: (value) =>
          ref.read(settingsControllerProvider.notifier).setLocalMode(value),
    );
  },
);

// --- settings & permissions ---

final settingsControllerProvider =
    StateNotifierProvider<SettingsController, SettingsState>(
      (ref) => SettingsController(ref.watch(sharedPreferencesProvider)),
    );

final permissionsServiceProvider = Provider<PermissionsService>(
  (ref) => PermissionsService(),
);

final permissionsSnapshotProvider = FutureProvider<PermissionsSnapshot>(
  (ref) => ref.watch(permissionsServiceProvider).snapshot(),
);

// --- platform services (override with simulated versions in tests) ---

final locationTrackingServiceProvider = Provider<LocationTrackingService>(
  (ref) => MethodChannelLocationTrackingService(),
);

final activityRecognitionServiceProvider = Provider<ActivityRecognitionService>(
  (ref) => MethodChannelActivityRecognitionService(),
);

final sensorCollectionServiceProvider = Provider<SensorCollectionService>(
  (ref) => SensorsPlusCollectionService(),
);

final tripStateMachineProvider = Provider<TripStateMachine>(
  (ref) => DefaultTripStateMachine(),
);

// --- recording ---

final tripRecordingControllerProvider =
    StateNotifierProvider<TripRecordingController, RecordingUiState>((ref) {
      final controller = TripRecordingController(
        stateMachine: ref.watch(tripStateMachineProvider),
        locationService: ref.watch(locationTrackingServiceProvider),
        activityService: ref.watch(activityRecognitionServiceProvider),
        sensorService: ref.watch(sensorCollectionServiceProvider),
        repository: ref.watch(tripRepositoryProvider),
        userIdProvider: () => ref.read(authControllerProvider).user?.id ?? '',
        metadataProvider: () => ref.read(deviceMetadataProvider),
        mountPositionProvider: () =>
            ref.read(settingsControllerProvider).mountPosition,
        autoDetectionEnabledProvider: () =>
            ref.read(settingsControllerProvider).autoDetectionEnabled,
        sensorConfigProvider: () =>
            ref.read(settingsControllerProvider).sensorConfig,
      );
      controller.init();
      return controller;
    });

// --- sync ---

final remoteTripDataSourceProvider = Provider<RemoteTripDataSource?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client == null ? null : SupabaseTripDataSource(client);
});

final syncServiceProvider = Provider<SyncService?>((ref) {
  final remote = ref.watch(remoteTripDataSourceProvider);
  if (remote == null) return null;
  final service = DefaultSyncService(
    local: ref.watch(localTripDataSourceProvider),
    remote: remote,
    connectivity: Connectivity(),
  );
  service.startAutoSync(() {
    final auth = ref.read(authControllerProvider);
    // Never upload local-mode data.
    if (auth.user == null || auth.user!.isLocal) return '';
    return auth.user!.id;
  });
  ref.onDispose(service.dispose);
  return service;
});

final syncStateProvider = StreamProvider<SyncState>((ref) {
  final service = ref.watch(syncServiceProvider);
  if (service == null) return const Stream.empty();
  return service.stateStream;
});

// --- trips ---

final tripsStreamProvider = StreamProvider<List<Trip>>((ref) {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return Stream.value(const []);
  return ref.watch(tripRepositoryProvider).watchTrips(user.id);
});

final tripTotalsProvider = FutureProvider<(int, double)>((ref) async {
  final user = ref.watch(authControllerProvider).user;
  if (user == null) return (0, 0.0);
  // Refresh totals whenever the trip list changes.
  ref.watch(tripsStreamProvider);
  return ref.watch(tripRepositoryProvider).totalsForUser(user.id);
});
