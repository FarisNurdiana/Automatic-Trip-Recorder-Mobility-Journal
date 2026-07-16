import 'package:triplog/core/activity/activity_models.dart';
import 'package:triplog/core/constants/enums.dart';
import 'package:triplog/core/location/location_models.dart';

/// Base timestamp used by tests (arbitrary fixed moment, UTC).
final t0 = DateTime.utc(2026, 7, 16, 8, 0, 0);

/// ~111.19 m per 0.001 degree of latitude.
const metersPerLatDegree = 111194.9;

RecordedLocation loc({
  required int secondsFromStart,
  double lat = -6.2000,
  double lon = 106.8000,
  double? speedKmh,
  double accuracy = 8,
  bool? isMocked,
}) {
  return RecordedLocation(
    recordedAt: t0.add(Duration(seconds: secondsFromStart)),
    latitude: lat,
    longitude: lon,
    horizontalAccuracy: accuracy,
    speed: speedKmh == null ? null : speedKmh / 3.6,
    source: 'test',
    isMocked: isMocked,
  );
}

DetectedActivity activity({
  required int secondsFromStart,
  DetectedActivityType type = DetectedActivityType.vehicle,
  ActivityTransition transition = ActivityTransition.enter,
  double? confidence = 0.9,
}) {
  return DetectedActivity(
    recordedAt: t0.add(Duration(seconds: secondsFromStart)),
    type: type,
    transition: transition,
    confidence: confidence,
    platformSource: 'test',
  );
}

/// A straight-line track: [movingSeconds] of movement at [speedKmh], then
/// [stoppedSeconds] stationary, then [movingSeconds] moving again.
/// Points are emitted every [intervalSeconds].
List<RecordedLocation> straightTrack({
  int movingSeconds = 300,
  int stoppedSeconds = 120,
  double speedKmh = 36,
  int intervalSeconds = 10,
}) {
  final points = <RecordedLocation>[];
  var lat = -6.2000;
  const lon = 106.8000;
  var t = 0;
  final metersPerTick = speedKmh / 3.6 * intervalSeconds;
  final latPerTick = metersPerTick / metersPerLatDegree;

  void move(int seconds, double speed, double dLat) {
    for (var s = 0; s < seconds; s += intervalSeconds) {
      points.add(loc(secondsFromStart: t, lat: lat, lon: lon, speedKmh: speed));
      lat += dLat;
      t += intervalSeconds;
    }
  }

  move(movingSeconds, speedKmh, latPerTick);
  move(stoppedSeconds, 0, 0);
  move(movingSeconds, speedKmh, latPerTick);
  return points;
}
