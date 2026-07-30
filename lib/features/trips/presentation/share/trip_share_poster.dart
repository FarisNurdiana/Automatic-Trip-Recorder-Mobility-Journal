import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/utils/formatters.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../trip_detail_page.dart';
import '../../domain/share_privacy.dart';

/// Poster-style share image: solid brand-blue background with the route
/// drawn as a bold white line (no map tiles), a big heading, and three key
/// stats at the bottom — inspired by route-poster prints.
class TripSharePoster extends StatelessWidget {
  const TripSharePoster({
    super.key,
    required this.data,
    required this.options,
    required this.points,
    this.userName,
  });

  static const _bg = Color(0xFF0A1F2E);
  static const _accent = Color(0xFF00E5CC);

  final TripDetailData data;
  final SharePrivacyOptions options;

  /// Privacy-trimmed, simplified route points.
  final List<LatLng> points;
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final trip = data.trip;

    return Container(
      width: 360,
      color: _bg,
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Brand mark + wordmark (mark shown as-is, no chip).
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandLogo(size: 34),
              const SizedBox(width: 10),
              const Text(
                'MOTIVOX',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            l10n
                .shareTripHeading(
                  Formatters.date(trip.startedAt, locale: locale),
                )
                .toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              height: 1.2,
            ),
          ),
          if (userName != null) ...[
            const SizedBox(height: 4),
            Text(
              userName!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(painter: RoutePosterPainter(points)),
          ),
          const SizedBox(height: 18),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.25)),
          const SizedBox(height: 14),
          Row(
            children: [
              _stat(
                l10n.tripDistance,
                Formatters.distanceKm(trip.distanceMeters, locale: locale),
              ),
              _stat(
                l10n.tripDuration,
                Formatters.duration(
                  Duration(seconds: trip.elapsedDurationSeconds),
                  locale: locale,
                ),
              ),
              _stat(
                l10n.tripAvgSpeed,
                Formatters.speedKmh(trip.averageSpeedKmh, locale: locale),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'motivox • know your route, master your fuel',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 10,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Expanded(
    child: Column(
      children: [
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 10,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

/// Draws the route as a bold polyline scaled to fit the canvas, optionally
/// with a start dot (white) and end dot (cyan). Longitude is corrected by
/// the cosine of the mid latitude so shapes keep their real proportions.
class RoutePosterPainter extends CustomPainter {
  const RoutePosterPainter(
    this.points, {
    this.strokeColor = Colors.white,
    this.showEndDots = true,
    this.shadowed = true,
  });

  final List<LatLng> points;
  final Color strokeColor;
  final bool showEndDots;
  final bool shadowed;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    var minLat = points.first.latitude, maxLat = minLat;
    var minLon = points.first.longitude, maxLon = minLon;
    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLon = math.min(minLon, p.longitude);
      maxLon = math.max(maxLon, p.longitude);
    }
    final midLat = (minLat + maxLat) / 2;
    final lonScale = math.cos(midLat * math.pi / 180);

    final widthDeg = math.max((maxLon - minLon) * lonScale, 1e-9);
    final heightDeg = math.max(maxLat - minLat, 1e-9);
    const pad = 18.0;
    final scale = math.min(
      (size.width - pad * 2) / widthDeg,
      (size.height - pad * 2) / heightDeg,
    );
    final drawnWidth = widthDeg * scale;
    final drawnHeight = heightDeg * scale;
    final offsetX = (size.width - drawnWidth) / 2;
    final offsetY = (size.height - drawnHeight) / 2;

    Offset project(LatLng p) => Offset(
      offsetX + (p.longitude - minLon) * lonScale * scale,
      // Latitude grows north, canvas grows down.
      offsetY + (maxLat - p.latitude) * scale,
    );

    final path = Path()
      ..moveTo(project(points.first).dx, project(points.first).dy);
    for (final p in points.skip(1)) {
      final o = project(p);
      path.lineTo(o.dx, o.dy);
    }

    // Soft shadow pass, then the route line.
    if (shadowed) {
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.black.withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = strokeColor,
    );

    if (showEndDots) {
      final start = project(points.first);
      final end = project(points.last);
      canvas.drawCircle(start, 7, Paint()..color = Colors.white);
      canvas.drawCircle(start, 4, Paint()..color = TripSharePoster._bg);
      canvas.drawCircle(end, 7, Paint()..color = Colors.white);
      canvas.drawCircle(end, 4.5, Paint()..color = TripSharePoster._accent);
    }
  }

  @override
  bool shouldRepaint(covariant RoutePosterPainter oldDelegate) =>
      oldDelegate.points != points;
}
