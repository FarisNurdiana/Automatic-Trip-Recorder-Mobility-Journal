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
///
/// Stop-related states are graded by duration so a red light, a rest stop,
/// and an actual arrival are treated differently:
///  * [shortStop] — < ~5 minutes (red light/congestion), no questions asked;
///  * [temporarilyStopped] — medium stop (5–30 min) or manual pause;
///  * [restStopCandidate] — ~30 min stationary, user asked rest/arrived;
///  * [destinationCandidate] — hours stationary, trip likely finished.
enum TripRecordingState {
  idle,
  possibleTrip,
  recording,
  shortStop,
  temporarilyStopped,
  restStopCandidate,
  destinationCandidate,
  finishing,
  finished,
  cancelled;

  static TripRecordingState fromName(String? name) =>
      TripRecordingState.values.asNameMap()[name] ?? TripRecordingState.idle;

  /// States in which a trip row exists and points are being collected.
  bool get isActiveTrip =>
      this == recording ||
      this == shortStop ||
      this == temporarilyStopped ||
      this == restStopCandidate ||
      this == destinationCandidate ||
      this == finishing;

  /// Stopped-flavored states (vehicle not moving).
  bool get isStoppedLike =>
      this == shortStop ||
      this == temporarilyStopped ||
      this == restStopCandidate ||
      this == destinationCandidate;
}

/// Vehicle types the user can confirm after a trip.
enum VehicleType {
  car,
  motorcycle,
  bus,
  truck,
  train,
  bicycle,
  other,
  unknown;

  static VehicleType fromName(String? name) =>
      VehicleType.values.asNameMap()[name] ?? VehicleType.unknown;
}

/// User-assigned label for a stop within a trip. Optional ground truth for
/// understanding trip structure (rest vs parking vs destination).
enum StopType {
  rest,
  parking,
  food,
  fuel,
  visit,
  traffic,
  destination,
  other,
  unconfirmed;

  static StopType fromName(String? name) =>
      StopType.values.asNameMap()[name] ?? StopType.unconfirmed;
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

/// Character style for the trip playback animation (chibi rider marker).
enum RiderStyle {
  normal,
  cute,
  fierce;

  static RiderStyle fromName(String? name) =>
      RiderStyle.values.asNameMap()[name] ?? RiderStyle.normal;
}

/// Basemap style, switchable like Google Maps' layer picker.
enum MapStyle {
  /// CARTO Voyager/Dark Matter — the clean brand look.
  motivox,

  /// Standard OpenStreetMap — richest place detail (warung, shops, banks).
  osm,

  /// Esri World Imagery with a label overlay.
  satellite;

  static MapStyle fromName(String? name) =>
      MapStyle.values.asNameMap()[name] ?? MapStyle.osm;
}
