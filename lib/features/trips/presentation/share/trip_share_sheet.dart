import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/polyline_simplifier.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/geojson_exporter.dart';
import '../../domain/gpx_exporter.dart';
import '../../domain/share_privacy.dart';
import '../trip_detail_page.dart';
import '../widgets/trip_map.dart';
import '../widgets/vehicle_ui.dart';
import 'trip_photo_overlay.dart';
import 'trip_share_poster.dart';

/// Which PNG layout to render and capture.
enum ShareImageMode { card, poster, photo, sticker }

/// Entry point: "Bagikan perjalanan" bottom sheet with PNG / GPX / GeoJSON /
/// copy-summary options. PNG goes through the privacy dialog first.
Future<void> showTripShareSheet(
  BuildContext context,
  TripDetailData data, {
  AppUser? user,
}) async {
  final l10n = AppLocalizations.of(context);
  if (data.rawPoints.length < 2) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.tripExportFailed)));
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              l10n.shareTripTitle,
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.image_outlined),
            title: Text(l10n.sharePng),
            onTap: () {
              Navigator.pop(ctx);
              _sharePng(context, data, user: user);
            },
          ),
          ListTile(
            leading: const Icon(Icons.wallpaper_outlined),
            title: Text(l10n.sharePoster),
            onTap: () {
              Navigator.pop(ctx);
              _sharePng(context, data, user: user, mode: ShareImageMode.poster);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_a_photo_outlined),
            title: Text(l10n.sharePhotoOverlay),
            subtitle: Text(l10n.sharePhotoOverlayDesc),
            onTap: () {
              Navigator.pop(ctx);
              _sharePng(context, data, user: user, mode: ShareImageMode.photo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sticky_note_2_outlined),
            title: Text(l10n.shareSticker),
            subtitle: Text(l10n.shareStickerDesc),
            onTap: () {
              Navigator.pop(ctx);
              _sharePng(
                context,
                data,
                user: user,
                mode: ShareImageMode.sticker,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.route_outlined),
            title: Text(l10n.shareGpx),
            onTap: () {
              Navigator.pop(ctx);
              _shareGpx(context, data);
            },
          ),
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(l10n.shareGeoJson),
            onTap: () {
              Navigator.pop(ctx);
              _shareGeoJson(context, data);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy_all_outlined),
            title: Text(l10n.shareCopySummary),
            onTap: () {
              Navigator.pop(ctx);
              _copySummary(context, data);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

String _summaryText(BuildContext context, TripDetailData data) {
  final l10n = AppLocalizations.of(context);
  final locale = Localizations.localeOf(context).languageCode;
  final trip = data.trip;
  final vehicle = VehicleType.fromName(
    trip.confirmedVehicleType ?? trip.detectedVehicleType,
  );
  return [
    'Motivox — ${Formatters.date(trip.startedAt, locale: locale)}',
    '${l10n.tripDistance}: ${Formatters.distanceKm(trip.distanceMeters, locale: locale)}',
    '${l10n.tripDuration}: ${Formatters.duration(Duration(seconds: trip.elapsedDurationSeconds), locale: locale)}',
    '${l10n.tripMovingTime}: ${Formatters.duration(Duration(seconds: trip.movingDurationSeconds), locale: locale)}',
    '${l10n.tripAvgSpeed}: ${Formatters.speedKmh(trip.averageSpeedKmh, locale: locale)}',
    if (vehicle != VehicleType.unknown)
      '${l10n.vehicleConfirmTitle}: ${vehicleLabel(l10n, vehicle)}',
  ].join('\n');
}

Future<File> _writeTempFile(String name, String contents) async {
  final dir = await getTemporaryDirectory();
  final file = File(p.join(dir.path, name));
  await file.writeAsString(contents);
  return file;
}

String _stamp(DateTime t) =>
    t.toIso8601String().replaceAll(':', '-').split('.').first;

Future<void> _shareGpx(BuildContext context, TripDetailData data) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final summary = _summaryText(context, data);
  try {
    final gpx = const GpxExporter().build(
      name: 'Motivox ${_stamp(data.trip.startedAt)}',
      description: summary,
      points: data.rawPoints,
    );
    final file = await _writeTempFile(
      'motivox_${_stamp(data.trip.startedAt)}.gpx',
      gpx,
    );
    await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/gpx+xml'),
    ], text: summary);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
  }
}

Future<void> _shareGeoJson(BuildContext context, TripDetailData data) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final summary = _summaryText(context, data);
  try {
    final geojson = const GeoJsonExporter().build(
      name: 'Motivox ${_stamp(data.trip.startedAt)}',
      points: data.rawPoints,
      properties: {
        'distance_meters': data.trip.distanceMeters,
        'elapsed_seconds': data.trip.elapsedDurationSeconds,
      },
    );
    final file = await _writeTempFile(
      'motivox_${_stamp(data.trip.startedAt)}.geojson',
      geojson,
    );
    await Share.shareXFiles([
      XFile(file.path, mimeType: 'application/geo+json'),
    ], text: summary);
  } catch (_) {
    messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
  }
}

Future<void> _copySummary(BuildContext context, TripDetailData data) async {
  final l10n = AppLocalizations.of(context);
  await Clipboard.setData(ClipboardData(text: _summaryText(context, data)));
  if (context.mounted) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.shareCopied)));
  }
}

// ---------------------------------------------------------------------------
// PNG export
// ---------------------------------------------------------------------------

Future<void> _sharePng(
  BuildContext context,
  TripDetailData data, {
  AppUser? user,
  ShareImageMode mode = ShareImageMode.card,
}) async {
  // Photo overlay needs the user's photo first; cancelling the picker
  // cancels the whole export.
  File? photo;
  if (mode == ShareImageMode.photo) {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 2160,
    );
    if (picked == null) return;
    photo = File(picked.path);
  }
  if (!context.mounted) return;
  final options = await _askPrivacyOptions(context);
  if (options == null || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _ShareCapturePage(
        data: data,
        options: options,
        mode: mode,
        photo: photo,
        userName: options.showUserName ? user?.displayName : null,
      ),
    ),
  );
}

/// Privacy-trimmed + smoothed + simplified route points for share images.
List<LatLng> _shareDisplayPoints(
  TripDetailData data,
  SharePrivacyOptions options,
) {
  final trimmed = options.applyTo(data.rawPoints);
  final display = PolylineSimplifier.simplify(
    PolylineSimplifier.smooth([
      for (final p in trimmed) SimplePoint(p.latitude, p.longitude),
    ]),
  );
  return [for (final p in display) LatLng(p.latitude, p.longitude)];
}

Future<SharePrivacyOptions?> _askPrivacyOptions(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  var options = const SharePrivacyOptions();
  return showDialog<SharePrivacyOptions>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(l10n.sharePrivacyTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.shareShowStart),
                value: options.showStartLocation,
                onChanged: (v) => setState(
                  () => options = options.copyWith(showStartLocation: v),
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.shareShowEnd),
                value: options.showEndLocation,
                onChanged: (v) => setState(
                  () => options = options.copyWith(showEndLocation: v),
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.shareShowUserName),
                value: options.showUserName,
                onChanged: (v) =>
                    setState(() => options = options.copyWith(showUserName: v)),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.shareShowMaxSpeed),
                value: options.showMaxSpeed,
                onChanged: (v) =>
                    setState(() => options = options.copyWith(showMaxSpeed: v)),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.sharePrivacyMode),
                subtitle: Text(l10n.sharePrivacyModeDesc),
                value: options.privacyMode,
                onChanged: (v) =>
                    setState(() => options = options.copyWith(privacyMode: v)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, options),
            child: Text(l10n.shareContinue),
          ),
        ],
      ),
    ),
  );
}

/// Renders the share card off the main page, waits for map tiles, captures
/// the RepaintBoundary at high resolution, opens the system share sheet, and
/// pops. Any failure ends with a snackbar — never a crash.
class _ShareCapturePage extends ConsumerStatefulWidget {
  const _ShareCapturePage({
    required this.data,
    required this.options,
    this.mode = ShareImageMode.card,
    this.photo,
    this.userName,
  });

  final TripDetailData data;
  final SharePrivacyOptions options;
  final ShareImageMode mode;

  /// User photo for [ShareImageMode.photo].
  final File? photo;
  final String? userName;

  @override
  ConsumerState<_ShareCapturePage> createState() => _ShareCapturePageState();
}

class _ShareCapturePageState extends ConsumerState<_ShareCapturePage> {
  final _boundaryKey = GlobalKey();
  bool _capturing = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  Future<void> _capture() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    try {
      // Give the map tiles time to load before the snapshot; tile-free
      // layouts only need a frame to settle.
      await Future<void>.delayed(
        widget.mode == ShareImageMode.card
            ? const Duration(milliseconds: 2500)
            : const Duration(milliseconds: 400),
      );
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('boundary missing');
      final image = await boundary.toImage(pixelRatio: 2.5);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('png encode failed');
      final dir = await getTemporaryDirectory();
      final file = File(
        p.join(dir.path, 'motivox_${_stamp(widget.data.trip.startedAt)}.png'),
      );
      await file.writeAsBytes(bytes.buffer.asUint8List());
      await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')]);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.commonError)));
    } finally {
      if (mounted) {
        setState(() => _capturing = false);
        navigator.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.shareTripTitle)),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: RepaintBoundary(
                key: _boundaryKey,
                child: switch (widget.mode) {
                  ShareImageMode.card => TripShareCard(
                    data: widget.data,
                    options: widget.options,
                    userName: widget.userName,
                  ),
                  ShareImageMode.poster => TripSharePoster(
                    data: widget.data,
                    options: widget.options,
                    points: _shareDisplayPoints(widget.data, widget.options),
                    userName: widget.userName,
                  ),
                  ShareImageMode.photo => TripPhotoShareCard(
                    photo: widget.photo!,
                    data: widget.data,
                    points: _shareDisplayPoints(widget.data, widget.options),
                    showMaxSpeed: widget.options.showMaxSpeed,
                  ),
                  ShareImageMode.sticker => TripStickerCard(
                    data: widget.data,
                    points: _shareDisplayPoints(widget.data, widget.options),
                    showMaxSpeed: widget.options.showMaxSpeed,
                  ),
                },
              ),
            ),
          ),
          if (_capturing)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black38,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(
                        l10n.sharePreparing,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Strava-style share card: a clean light map with a bold route on top, then
/// a white panel with avatar/name/date, a big heading, and a centered stat
/// grid (small label above a big bold value). The card is always rendered in
/// light colors regardless of the app theme, like Strava's share images.
class TripShareCard extends StatelessWidget {
  TripShareCard({
    super.key,
    required this.data,
    required this.options,
    this.userName,
  });

  static const _ink = Color(0xFF16181C);
  static const _inkSoft = Color(0xFF6B7280);

  final TripDetailData data;
  final SharePrivacyOptions options;
  final String? userName;
  final _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final trip = data.trip;
    final vehicle = VehicleType.fromName(
      trip.confirmedVehicleType ?? trip.detectedVehicleType,
    );

    final points = _shareDisplayPoints(data, options);

    final stats = <(String, String)>[
      (
        l10n.tripDistance,
        Formatters.distanceKm(trip.distanceMeters, locale: locale),
      ),
      (
        l10n.tripDuration,
        Formatters.duration(
          Duration(seconds: trip.elapsedDurationSeconds),
          locale: locale,
        ),
      ),
      (
        l10n.tripMovingTime,
        Formatters.duration(
          Duration(seconds: trip.movingDurationSeconds),
          locale: locale,
        ),
      ),
      (
        l10n.tripAvgSpeed,
        Formatters.speedKmh(trip.averageSpeedKmh, locale: locale),
      ),
      if (options.showMaxSpeed)
        (
          l10n.tripMaxSpeed,
          Formatters.speedKmh(trip.maximumSpeedKmh, locale: locale),
        ),
      if (vehicle != VehicleType.unknown)
        (l10n.vehicleConfirmTitle, vehicleLabel(l10n, vehicle)),
    ];

    return Container(
      width: 360,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 280,
            child: TripMap(
              controller: _mapController,
              points: points,
              stops: const [],
              interactive: false,
              showControls: false,
              lightTiles: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar + name + date, like a Strava activity header.
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const BrandLogo(size: 26),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName ?? 'Motivox',
                            style: const TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            Formatters.dateTime(trip.startedAt, locale: locale),
                            style: const TextStyle(
                              color: _inkSoft,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.shareTripHeading(
                    Formatters.date(trip.startedAt, locale: locale),
                  ),
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
                // Centered two-column stat grid, Strava style.
                for (var i = 0; i < stats.length; i += 2) ...[
                  Row(
                    children: [
                      _stat(stats[i].$1, stats[i].$2),
                      if (i + 1 < stats.length)
                        _stat(stats[i + 1].$1, stats[i + 1].$2)
                      else
                        const Spacer(),
                    ],
                  ),
                  if (i + 2 < stats.length)
                    const Divider(height: 20, color: Color(0xFFE5E7EB)),
                ],
                if (options.showStartLocation && trip.startLatitude != null)
                  _coordRow(
                    l10n.tripStart,
                    trip.startLatitude!,
                    trip.startLongitude!,
                  ),
                if (options.showEndLocation && trip.endLatitude != null)
                  _coordRow(
                    l10n.tripEnd,
                    trip.endLatitude!,
                    trip.endLongitude!,
                  ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'motivox • know your route, master your fuel',
                    style: TextStyle(
                      color: _inkSoft,
                      fontSize: 11,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ],
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
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _inkSoft, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _ink,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
      ],
    ),
  );

  Widget _coordRow(String label, double lat, double lon) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      '$label: ${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}',
      style: const TextStyle(color: _inkSoft, fontSize: 12),
    ),
  );
}
