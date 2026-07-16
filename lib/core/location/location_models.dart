/// A single location fix as delivered by the platform (or the simulator).
class RecordedLocation {
  const RecordedLocation({
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
    this.source,
    this.isMocked,
    this.batteryLevel,
  });

  final DateTime recordedAt;
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? horizontalAccuracy;
  final double? verticalAccuracy;

  /// m/s.
  final double? speed;
  final double? speedAccuracy;
  final double? heading;
  final double? headingAccuracy;

  /// e.g. `fused`, `gps`, `core_location`, `simulator`.
  final String? source;
  final bool? isMocked;

  /// 0..1 when available.
  final double? batteryLevel;

  double? get speedKmh => speed == null ? null : speed! * 3.6;

  factory RecordedLocation.fromMap(Map<Object?, Object?> map) {
    double? d(Object? v) => (v as num?)?.toDouble();
    return RecordedLocation(
      recordedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['timestampMs'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
        isUtc: true,
      ),
      latitude: d(map['latitude']) ?? 0,
      longitude: d(map['longitude']) ?? 0,
      altitude: d(map['altitude']),
      horizontalAccuracy: d(map['horizontalAccuracy']),
      verticalAccuracy: d(map['verticalAccuracy']),
      speed: d(map['speed']),
      speedAccuracy: d(map['speedAccuracy']),
      heading: d(map['heading']),
      headingAccuracy: d(map['headingAccuracy']),
      source: map['source'] as String?,
      isMocked: map['isMocked'] as bool?,
      batteryLevel: d(map['batteryLevel']),
    );
  }

  Map<String, Object?> toMap() => {
        'timestampMs': recordedAt.millisecondsSinceEpoch,
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'horizontalAccuracy': horizontalAccuracy,
        'verticalAccuracy': verticalAccuracy,
        'speed': speed,
        'speedAccuracy': speedAccuracy,
        'heading': heading,
        'headingAccuracy': headingAccuracy,
        'source': source,
        'isMocked': isMocked,
        'batteryLevel': batteryLevel,
      };
}

/// Adaptive sampling profiles requested from the native tracker.
enum LocationSamplingProfile { moving, slow, stopped }

/// Actions coming back from the persistent notification (Android).
enum TrackingNotificationAction { pause, resume, stop }
