import '../constants/enums.dart';

/// One activity-recognition result, normalized across platforms.
class DetectedActivity {
  const DetectedActivity({
    required this.recordedAt,
    required this.type,
    required this.transition,
    required this.platformSource,
    this.confidence,
    this.rawValue,
  });

  final DateTime recordedAt;
  final DetectedActivityType type;

  /// Android Transition API delivers enter/exit; iOS delivers samples.
  final ActivityTransition transition;

  /// 0..1 when the platform provides one (iOS maps low/medium/high).
  final double? confidence;

  /// `android` | `ios` | `simulator`.
  final String platformSource;

  /// Raw platform payload for debugging.
  final String? rawValue;

  factory DetectedActivity.fromMap(Map<Object?, Object?> map) {
    return DetectedActivity(
      recordedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['timestampMs'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
        isUtc: true,
      ),
      type: DetectedActivityType.fromName(map['activityType'] as String?),
      transition: ActivityTransition.fromName(map['transition'] as String?),
      confidence: (map['confidence'] as num?)?.toDouble(),
      platformSource: (map['platformSource'] as String?) ?? 'unknown',
      rawValue: map['rawValue'] as String?,
    );
  }

  Map<String, Object?> toMap() => {
        'timestampMs': recordedAt.millisecondsSinceEpoch,
        'activityType': type.name,
        'transition': transition.name,
        'confidence': confidence,
        'platformSource': platformSource,
        'rawValue': rawValue,
      };

  @override
  String toString() =>
      'DetectedActivity(${type.name}/${transition.name} conf=$confidence)';
}
