/// Every tunable threshold used by trip detection, recording, filtering and
/// summary calculation lives here so the rules can be adjusted in one place.
/// These are starting values for field testing — expect to retune them.
class TripDetectionConfig {
  const TripDetectionConfig({
    // --- activity trigger ---
    this.minActivityConfidence = 0.70,
    // --- speed-based candidate trigger (no activity event needed) ---
    this.candidateVehicleSpeedKmh = 10,
    this.strongVehicleSpeedKmh = 20,
    this.candidateEntrySpeedDuration = const Duration(seconds: 10),
    this.candidateEntryDisplacementMeters = 50,
    // --- possibleTrip -> recording validation ---
    this.minimumDisplacementMeters = 80,
    this.minimumMovementDuration = const Duration(seconds: 15),
    this.minimumConsistentPoints = 3,
    this.possibleTripTimeout = const Duration(minutes: 5),
    // --- GPS acceptance ---
    this.maximumAcceptedAccuracyMeters = 40,
    this.maxHorizontalAccuracyMeters = 35,
    this.maxRealisticSpeedKmh = 220,
    this.stationarySpeedCeilingKmh = 4,
    this.minimumJitterDisplacementMeters = 12,
    this.maxSpeedSpikeFactor = 3.0,
    this.gpsWarmupPoints = 2,
    // --- stop lifecycle ---
    this.stopSpeedThresholdKmh = 3,
    this.stopLocationJitterMeters = 30,
    this.shortStopAfter = const Duration(seconds: 60),
    this.mediumStopAfter = const Duration(minutes: 5),
    this.restStopQuestionAfter = const Duration(minutes: 30),
    this.destinationCandidateAfter = const Duration(hours: 5),
    this.autoFinishGrace = const Duration(minutes: 30),
    this.stopRadiusMinMeters = 50,
    this.stopRadiusMaxMeters = 100,
    this.finishAfterStopped = const Duration(minutes: 6),
    // --- adaptive GPS sampling ---
    this.movingSamplingInterval = const Duration(seconds: 3),
    this.slowSamplingInterval = const Duration(seconds: 7),
    this.stoppedSamplingInterval = const Duration(seconds: 20),
    this.slowSpeedThresholdKmh = 15,
    // --- trip validity ---
    this.minTripDistanceMeters = 300,
    this.minTripPoints = 10,
    this.minTripDuration = const Duration(seconds: 60),
    // --- summary ---
    this.speedSmoothingWindow = 3,
    this.minStopDurationForSummary = const Duration(seconds: 60),
  });

  // --- activity trigger ---

  /// Minimum activity-recognition confidence (0..1) for a vehicle event to
  /// move the machine into possibleTrip.
  final double minActivityConfidence;

  // --- speed-based candidate trigger ---

  /// Speed considered "possibly a vehicle" (0 -> >10 km/h from standstill).
  final double candidateVehicleSpeedKmh;

  /// Speed that on its own is strong vehicle evidence (~20 km/h) — still
  /// needs several consistent points, never a single fix.
  final double strongVehicleSpeedKmh;

  /// How long candidate-level speed must persist before entering
  /// possibleTrip without an activity event.
  final Duration candidateEntrySpeedDuration;

  /// Displacement that must accompany the candidate-speed window.
  final double candidateEntryDisplacementMeters;

  // --- possibleTrip -> recording ---

  /// Displacement from the anchor that validates a trip.
  final double minimumDisplacementMeters;

  /// Sustained candidate-speed duration that validates a trip.
  final Duration minimumMovementDuration;

  /// Consecutive consistent moving points that validate a trip.
  final int minimumConsistentPoints;

  /// possibleTrip falls back to idle when nothing validates within this.
  final Duration possibleTripTimeout;

  // --- GPS acceptance ---

  /// Fixes worse than this are ignored by the DETECTOR (decision-making).
  final double maximumAcceptedAccuracyMeters;

  /// Fixes worse than this are dropped from STORAGE/summary.
  final double maxHorizontalAccuracyMeters;

  /// Below this speed a small displacement is treated as GPS jitter, not
  /// movement — the fix is not stored, which keeps stationary periods from
  /// drawing zigzags and inflating distance.
  final double stationarySpeedCeilingKmh;

  /// Minimum displacement (or the fix accuracy, whichever is larger) needed
  /// to store a new point while at stationary speeds.
  final double minimumJitterDisplacementMeters;

  /// Implied/reported speeds above this are impossible: treated as GPS jump.
  final double maxRealisticSpeedKmh;

  /// Spike factor vs neighbors for the summary filter.
  final double maxSpeedSpikeFactor;

  /// First fixes after GPS wakes up are ignored for detection decisions
  /// (fresh GPS is often unstable).
  final int gpsWarmupPoints;

  // --- stop lifecycle ---

  final double stopSpeedThresholdKmh;
  final double stopLocationJitterMeters;

  /// Low speed & stable this long -> shortStop (red light class, no UI).
  final Duration shortStopAfter;

  /// Stationary this long -> temporarilyStopped (medium stop, marked).
  final Duration mediumStopAfter;

  /// Stationary this long -> restStopCandidate + "arrived or resting?"
  /// question.
  final Duration restStopQuestionAfter;

  /// Stationary this long -> destinationCandidate (trip likely over).
  final Duration destinationCandidateAfter;

  /// After destinationCandidate, auto-finish when the user does not respond
  /// within this grace period.
  final Duration autoFinishGrace;

  /// Dynamic "same location" radius bounds; actual radius adapts to GPS
  /// accuracy within [stopRadiusMinMeters, stopRadiusMaxMeters].
  final double stopRadiusMinMeters;
  final double stopRadiusMaxMeters;

  /// Non-vehicle activity + stable location for this long finishes the trip.
  final Duration finishAfterStopped;

  // --- adaptive GPS sampling ---

  final Duration movingSamplingInterval;
  final Duration slowSamplingInterval;
  final Duration stoppedSamplingInterval;
  final double slowSpeedThresholdKmh;

  // --- trip validity ---

  final double minTripDistanceMeters;
  final int minTripPoints;
  final Duration minTripDuration;

  // --- summary ---

  final int speedSmoothingWindow;
  final Duration minStopDurationForSummary;

  /// Dynamic stop radius for the given GPS accuracy.
  double stopRadiusFor(double? accuracyMeters) {
    final acc = accuracyMeters ?? stopRadiusMinMeters;
    return (acc * 2).clamp(stopRadiusMinMeters, stopRadiusMaxMeters);
  }
}

/// Version of the summary algorithm, stored with every trip so results can be
/// traced back when the algorithm changes.
const int tripSummaryAlgorithmVersion = 2;

/// Default configuration used in production.
const TripDetectionConfig defaultTripDetectionConfig = TripDetectionConfig();
