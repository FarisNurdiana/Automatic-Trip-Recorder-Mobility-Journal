import '../../../core/location/location_models.dart';
import '../../../core/utils/geo_utils.dart';

/// Options chosen in the share privacy dialog.
class SharePrivacyOptions {
  const SharePrivacyOptions({
    this.showStartLocation = true,
    this.showEndLocation = true,
    this.showUserName = false,
    this.showMaxSpeed = true,
    this.privacyMode = false,
    this.trimMeters = 300,
  });

  final bool showStartLocation;
  final bool showEndLocation;
  final bool showUserName;
  final bool showMaxSpeed;

  /// Privacy mode trims [trimMeters] from both route ends so home/work
  /// locations stay hidden.
  final bool privacyMode;
  final double trimMeters;

  SharePrivacyOptions copyWith({
    bool? showStartLocation,
    bool? showEndLocation,
    bool? showUserName,
    bool? showMaxSpeed,
    bool? privacyMode,
  }) => SharePrivacyOptions(
    showStartLocation: showStartLocation ?? this.showStartLocation,
    showEndLocation: showEndLocation ?? this.showEndLocation,
    showUserName: showUserName ?? this.showUserName,
    showMaxSpeed: showMaxSpeed ?? this.showMaxSpeed,
    privacyMode: privacyMode ?? this.privacyMode,
    trimMeters: trimMeters,
  );

  /// Applies privacy-mode trimming: removes points within [trimMeters]
  /// (along the path) of the start and the end. Always keeps at least two
  /// points so exports stay valid.
  List<RecordedLocation> applyTo(List<RecordedLocation> points) {
    if (!privacyMode || points.length < 4) return points;

    var startIndex = 0;
    var traveled = 0.0;
    for (var i = 1; i < points.length; i++) {
      traveled += GeoUtils.haversineMeters(
        points[i - 1].latitude,
        points[i - 1].longitude,
        points[i].latitude,
        points[i].longitude,
      );
      if (traveled >= trimMeters) {
        startIndex = i;
        break;
      }
    }

    var endIndex = points.length - 1;
    traveled = 0.0;
    for (var i = points.length - 2; i >= 0; i--) {
      traveled += GeoUtils.haversineMeters(
        points[i].latitude,
        points[i].longitude,
        points[i + 1].latitude,
        points[i + 1].longitude,
      );
      if (traveled >= trimMeters) {
        endIndex = i;
        break;
      }
    }

    if (endIndex - startIndex < 2) return points;
    return points.sublist(startIndex, endIndex + 1);
  }
}
