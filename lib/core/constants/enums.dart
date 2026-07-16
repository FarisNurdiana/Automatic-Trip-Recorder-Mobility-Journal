/// Core domain enums shared across the whole app.
///
/// Values are persisted by [name] in the local database and in Supabase, so
/// renaming an entry is a breaking schema change.
library;

/// Internal activity type, mapped from both Android Activity Recognition and
/// iOS CMMotionActivityManager.
enum DetectedActivityType {
  still,
  walking,
  running,
  cycling,
  vehicle,
  unknown;

  static DetectedActivityType fromName(String? name) =>
      DetectedActivityType.values.asNameMap()[name] ??
      DetectedActivityType.unknown;
}

/// Whether an activity event is a transition into or out of an activity, or
/// a plain periodic sample (iOS delivers samples, Android delivers
/// enter/exit transitions).
enum ActivityTransition {
  enter,
  exit,
  sample;

  static ActivityTransition fromName(String? name) =>
      ActivityTransition.values.asNameMap()[name] ?? ActivityTransition.sample;
}

/// Explicit trip recording state machine states.
enum TripRecordingState {
  idle,
  possibleTrip,
  recording,
  temporarilyStopped,
  finishing,
  finished,
  cancelled;

  static TripRecordingState fromName(String? name) =>
      TripRecordingState.values.asNameMap()[name] ?? TripRecordingState.idle;

  /// States in which a trip row exists and points are being collected.
  bool get isActiveTrip =>
      this == recording || this == temporarilyStopped || this == finishing;
}

/// Vehicle types the user can confirm after a trip.
enum VehicleType {
  car,
  motorcycle,
  bus,
  truck,
  train,
  other,
  unknown;

  static VehicleType fromName(String? name) =>
      VehicleType.values.asNameMap()[name] ?? VehicleType.unknown;
}

/// Sync lifecycle of a local row.
enum SyncStatus {
  pending,
  syncing,
  synced,
  failed;

  static SyncStatus fromName(String? name) =>
      SyncStatus.values.asNameMap()[name] ?? SyncStatus.pending;
}

/// Where the phone is mounted during a trip. Strongly affects accelerometer
/// and gyroscope characteristics, so it is stored as dataset metadata.
enum PhoneMountPosition {
  dashboardHolder,
  handlebarHolder,
  pocket,
  bag,
  cupHolder,
  unknown;

  static PhoneMountPosition fromName(String? name) =>
      PhoneMountPosition.values.asNameMap()[name] ?? PhoneMountPosition.unknown;
}
