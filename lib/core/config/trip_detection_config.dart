/// Every tunable threshold used by trip detection, recording, filtering and
/// summary calculation lives here so the rules can be adjusted in one place.
class TripDetectionConfig {
  const TripDetectionConfig({
    this.minActivityConfidence = 0.70,
    this.possibleTripMinDisplacementMeters = 150,
    this.possibleTripMinSpeedKmh = 8,
    this.possibleTripMinSpeedDuration = const Duration(seconds: 20),
    this.possibleTripMinConsistentPoints = 4,
    this.possibleTripTimeout = const Duration(minutes: 5),
    this.stopSpeedThresholdKmh = 3,
    this.stopLocationJitterMeters = 30,
    this.stopMinDuration = const Duration(seconds: 90),
    this.finishAfterStopped = const Duration(minutes: 6),
    this.movingSamplingInterval = const Duration(seconds: 3),
    this.slowSamplingInterval = const Duration(seconds: 7),
    this.stoppedSamplingInterval = const Duration(seconds: 20),
    this.slowSpeedThresholdKmh = 15,
    this.maxHorizontalAccuracyMeters = 50,
    this.maxRealisticSpeedKmh = 220,
    this.maxSpeedSpikeFactor = 3.0,
    this.minTripDistanceMeters = 300,
    this.minTripPoints = 10,
    this.minTripDuration = const Duration(seconds: 60),
    this.speedSmoothingWindow = 3,
    this.minStopDurationForSummary = const Duration(seconds: 60),
  });

  // --- idle -> possibleTrip ---

  /// Minimum activity-recognition confidence (0..1) for a vehicle event to
  /// move the machine into [TripRecordingState.possibleTrip].
  final double minActivityConfidence;

  // --- possibleTrip -> recording (any single condition validates) ---

  /// Displacement from the location where the possible trip was flagged.
  final double possibleTripMinDisplacementMeters;

  /// Sustained speed threshold...
  final double possibleTripMinSpeedKmh;

  /// ...held for at least this long.
  final Duration possibleTripMinSpeedDuration;

  /// Number of consecutive valid GPS points showing consistent movement.
  final int possibleTripMinConsistentPoints;

  /// possibleTrip falls back to idle when nothing validates within this time.
  final Duration possibleTripTimeout;

  // --- recording -> temporarilyStopped ---

  /// Speed below which the vehicle is considered stationary.
  final double stopSpeedThresholdKmh;

  /// Location is "stable" when it stays inside this radius.
  final double stopLocationJitterMeters;

  /// Low speed + stable location must last this long before pausing.
  final Duration stopMinDuration;

  // --- temporarilyStopped -> finishing ---

  /// Non-vehicle activity + stable location for this long finishes the trip.
  final Duration finishAfterStopped;

  // --- adaptive GPS sampling ---

  final Duration movingSamplingInterval;
  final Duration slowSamplingInterval;
  final Duration stoppedSamplingInterval;

  /// Below this speed the tracker switches to the slow sampling interval.
  final double slowSpeedThresholdKmh;

  // --- GPS point filtering (summary + live) ---

  /// Points with worse horizontal accuracy are discarded.
  final double maxHorizontalAccuracyMeters;

  /// Implied or reported speeds above this are impossible for MVP vehicles.
  final double maxRealisticSpeedKmh;

  /// A speed sample further than this factor from its neighbors' median is
  /// treated as an inconsistent spike.
  final double maxSpeedSpikeFactor;

  // --- trip validity ---

  final double minTripDistanceMeters;
  final int minTripPoints;
  final Duration minTripDuration;

  // --- summary ---

  /// Window size (odd) for the median speed smoothing filter.
  final int speedSmoothingWindow;

  /// Minimum stationary duration for a cluster to count as a "stop" in the
  /// trip summary.
  final Duration minStopDurationForSummary;
}

/// Version of the summary algorithm, stored with every trip so results can be
/// traced back when the algorithm changes.
const int tripSummaryAlgorithmVersion = 1;

/// Default configuration used in production.
const TripDetectionConfig defaultTripDetectionConfig = TripDetectionConfig();
