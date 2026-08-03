import 'dart:convert';

import 'location_models.dart';

/// One auto-started background recording read back from the native
/// persistence file: when it started and every GPS point captured while the
/// app was closed.
class BackgroundTrackSegment {
  const BackgroundTrackSegment({required this.startedAt, required this.points});

  final DateTime startedAt;
  final List<RecordedLocation> points;
}

/// Parses the JSON-lines file written by the native `BackgroundTrackStore`.
/// A `{"type":"start","startedAtMillis":...}` line begins a segment; every
/// other line is a location map in the live event-stream format. Malformed
/// lines are skipped — a partially written last line (process killed
/// mid-write) must not lose the whole trip.
class BackgroundTrackParser {
  static List<BackgroundTrackSegment> parse(List<String> lines) {
    final segments = <BackgroundTrackSegment>[];
    DateTime? currentStart;
    var currentPoints = <RecordedLocation>[];

    void flush() {
      final startedAt = currentStart;
      if (startedAt != null) {
        segments.add(
          BackgroundTrackSegment(startedAt: startedAt, points: currentPoints),
        );
      }
      currentPoints = <RecordedLocation>[];
    }

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      Map<String, dynamic> map;
      try {
        map = jsonDecode(trimmed) as Map<String, dynamic>;
      } catch (_) {
        continue;
      }
      if (map['type'] == 'start') {
        flush();
        final millis = (map['startedAtMillis'] as num?)?.toInt();
        currentStart = millis == null || millis <= 0
            ? null
            : DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true);
        continue;
      }
      if (currentStart == null) continue;
      if (map['latitude'] is! num || map['longitude'] is! num) continue;
      currentPoints.add(RecordedLocation.fromMap(map));
    }
    flush();
    return segments;
  }
}
