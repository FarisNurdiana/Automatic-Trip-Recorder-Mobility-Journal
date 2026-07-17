import '../../../core/location/location_models.dart';

/// Builds a GPX 1.1 document from recorded trip points.
///
/// GPX is the de-facto exchange format for GPS tracks: the resulting file can
/// be imported into Strava, Google Earth, komoot, and most mapping tools.
/// Timestamps are included per point so importers can reconstruct duration
/// and speed, not just the route shape.
class GpxExporter {
  const GpxExporter();

  /// [name] becomes the track name (e.g. "TripLog 16 Jul 2026 08:00").
  /// [points] must be ordered by time; pass filtered points so exported
  /// tracks do not contain GPS outliers.
  String build({
    required String name,
    required List<RecordedLocation> points,
    String? description,
  }) {
    final buffer = StringBuffer()
      ..writeln('<?xml version="1.0" encoding="UTF-8"?>')
      ..writeln(
        '<gpx version="1.1" creator="TripLog" '
        'xmlns="http://www.topografix.com/GPX/1/1" '
        'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
        'xsi:schemaLocation="http://www.topografix.com/GPX/1/1 '
        'http://www.topografix.com/GPX/1/1/gpx.xsd">',
      );

    buffer.writeln('  <metadata>');
    buffer.writeln('    <name>${_escape(name)}</name>');
    if (description != null) {
      buffer.writeln('    <desc>${_escape(description)}</desc>');
    }
    if (points.isNotEmpty) {
      buffer.writeln('    <time>${_time(points.first.recordedAt)}</time>');
    }
    buffer.writeln('  </metadata>');

    buffer.writeln('  <trk>');
    buffer.writeln('    <name>${_escape(name)}</name>');
    buffer.writeln('    <type>driving</type>');
    buffer.writeln('    <trkseg>');
    for (final p in points) {
      buffer.write(
        '      <trkpt lat="${p.latitude.toStringAsFixed(7)}" '
        'lon="${p.longitude.toStringAsFixed(7)}">',
      );
      if (p.altitude != null) {
        buffer.write('<ele>${p.altitude!.toStringAsFixed(1)}</ele>');
      }
      buffer.write('<time>${_time(p.recordedAt)}</time>');
      buffer.writeln('</trkpt>');
    }
    buffer.writeln('    </trkseg>');
    buffer.writeln('  </trk>');
    buffer.writeln('</gpx>');
    return buffer.toString();
  }

  /// GPX requires UTC ISO-8601 without fractional seconds ambiguity.
  static String _time(DateTime t) {
    final utc = t.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${utc.year.toString().padLeft(4, '0')}-${two(utc.month)}-'
        '${two(utc.day)}T${two(utc.hour)}:${two(utc.minute)}:'
        '${two(utc.second)}Z';
  }

  static String _escape(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
