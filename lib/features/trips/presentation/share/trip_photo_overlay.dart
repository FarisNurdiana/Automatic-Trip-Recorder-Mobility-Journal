import 'dart:io';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;

import '../../../../core/utils/formatters.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../trip_detail_page.dart';
import 'trip_share_poster.dart' show RoutePosterPainter;

/// The translucent stat block used by the photo-overlay and sticker exports:
/// right-aligned white labels/values with soft shadows, a small route
/// outline, and the RUTEKU wordmark — the style of Strava's photo shares.
class TripStatsOverlay extends StatelessWidget {
  const TripStatsOverlay({
    super.key,
    required this.data,
    required this.points,
    this.showMaxSpeed = false,
  });

  final TripDetailData data;
  final List<LatLng> points;
  final bool showMaxSpeed;

  static const _shadows = [
    Shadow(color: Colors.black54, blurRadius: 6),
    Shadow(color: Colors.black38, blurRadius: 16),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final trip = data.trip;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _stat(
          l10n.tripDistance,
          Formatters.distanceKm(trip.distanceMeters, locale: locale),
        ),
        const SizedBox(height: 14),
        _stat(
          l10n.tripDuration,
          Formatters.duration(
            Duration(seconds: trip.elapsedDurationSeconds),
            locale: locale,
          ),
        ),
        const SizedBox(height: 14),
        _stat(
          l10n.tripAvgSpeed,
          Formatters.speedKmh(trip.averageSpeedKmh, locale: locale),
        ),
        if (showMaxSpeed) ...[
          const SizedBox(height: 14),
          _stat(
            l10n.tripMaxSpeed,
            Formatters.speedKmh(trip.maximumSpeedKmh, locale: locale),
          ),
        ],
        if (points.length >= 2) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: 110,
            height: 110,
            child: CustomPaint(
              painter: RoutePosterPainter(
                points,
                strokeColor: Colors.white,
                showEndDots: false,
                shadowed: true,
              ),
            ),
          ),
        ],
        const SizedBox(height: 10),
        // The brand mark by itself — no chip, no wordmark text.
        const BrandLogo(size: 44),
      ],
    );
  }

  Widget _stat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        label,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          shadows: _shadows,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.3,
          shadows: _shadows,
        ),
      ),
    ],
  );
}

/// Photo-overlay export: the user's own photo full-bleed in a 9:16 frame
/// with [TripStatsOverlay] on the right — like sharing a Strava activity
/// over a photo.
class TripPhotoShareCard extends StatelessWidget {
  const TripPhotoShareCard({
    super.key,
    required this.photo,
    required this.data,
    required this.points,
    this.showMaxSpeed = false,
  });

  final File photo;
  final TripDetailData data;
  final List<LatLng> points;
  final bool showMaxSpeed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 360,
      height: 640,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(photo, fit: BoxFit.cover),
          // Subtle scrim keeps white text readable on bright photos.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.transparent, Colors.black26],
              ),
            ),
          ),
          Positioned(
            right: 18,
            top: 0,
            bottom: 0,
            child: Center(
              child: TripStatsOverlay(
                data: data,
                points: points,
                showMaxSpeed: showMaxSpeed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Transparent sticker export: only the overlay on a fully transparent
/// canvas, for pasting onto videos/stories in other apps (CapCut, IG, ...).
class TripStickerCard extends StatelessWidget {
  const TripStickerCard({
    super.key,
    required this.data,
    required this.points,
    this.showMaxSpeed = false,
  });

  final TripDetailData data;
  final List<LatLng> points;
  final bool showMaxSpeed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: TripStatsOverlay(
        data: data,
        points: points,
        showMaxSpeed: showMaxSpeed,
      ),
    );
  }
}
