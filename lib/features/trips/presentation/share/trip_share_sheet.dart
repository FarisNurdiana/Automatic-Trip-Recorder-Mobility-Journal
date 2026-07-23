import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/enums.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/polyline_simplifier.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/geojson_exporter.dart';
import '../../domain/gpx_exporter.dart';
import '../../domain/share_privacy.dart';
import '../trip_detail_page.dart';
import '../widgets/trip_map.dart';
import '../widgets/vehicle_ui.dart';

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
    'Ruteku — ${Formatters.date(trip.startedAt, locale: locale)}',
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
      name: 'Ruteku ${_stamp(data.trip.startedAt)}',
      description: summary,
      points: data.rawPoints,
    );
    final file = await _writeTempFile(
      'ruteku_${_stamp(data.trip.startedAt)}.gpx',
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
      name: 'Ruteku ${_stamp(data.trip.startedAt)}',
      points: data.rawPoints,
      properties: {
        'distance_meters': data.trip.distanceMeters,
        'elapsed_seconds': data.trip.elapsedDurationSeconds,
      },
    );
    final file = await _writeTempFile(
      'ruteku_${_stamp(data.trip.startedAt)}.geojson',
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
}) async {
  final options = await _askPrivacyOptions(context);
  if (options == null || !context.mounted) return;
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      fullscreenDialog: true,
      builder: (_) => _ShareCapturePage(
        data: data,
        options: options,
        userName: options.showUserName ? user?.displayName : null,
      ),
    ),
  );
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
    this.userName,
  });

  final TripDetailData data;
  final SharePrivacyOptions options;
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
      // Give the map tiles time to load before the snapshot.
      await Future<void>.delayed(const Duration(milliseconds: 2500));
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
        p.join(dir.path, 'ruteku_${_stamp(widget.data.trip.startedAt)}.png'),
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
                child: TripShareCard(
                  data: widget.data,
                  options: widget.options,
                  userName: widget.userName,
                ),
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

/// The visual share card: brand header, map, key stats, watermark.
class TripShareCard extends StatelessWidget {
  TripShareCard({
    super.key,
    required this.data,
    required this.options,
    this.userName,
  });

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

    final trimmed = options.applyTo(data.rawPoints);
    final display = PolylineSimplifier.simplify(
      PolylineSimplifier.smooth([
        for (final p in trimmed) SimplePoint(p.latitude, p.longitude),
      ]),
    );
    final points = [for (final p in display) LatLng(p.latitude, p.longitude)];

    return Container(
      width: 360,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(Icons.route, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Ruteku',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                Text(
                  Formatters.date(trip.startedAt, locale: locale),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          if (userName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                userName!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          SizedBox(
            height: 260,
            child: TripMap(
              controller: _mapController,
              points: points,
              stops: const [],
              interactive: false,
              showControls: false,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _stat(
                      context,
                      l10n.tripDistance,
                      Formatters.distanceKm(
                        trip.distanceMeters,
                        locale: locale,
                      ),
                    ),
                    _stat(
                      context,
                      l10n.tripDuration,
                      Formatters.duration(
                        Duration(seconds: trip.elapsedDurationSeconds),
                        locale: locale,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _stat(
                      context,
                      l10n.tripMovingTime,
                      Formatters.duration(
                        Duration(seconds: trip.movingDurationSeconds),
                        locale: locale,
                      ),
                    ),
                    _stat(
                      context,
                      l10n.tripAvgSpeed,
                      Formatters.speedKmh(trip.averageSpeedKmh, locale: locale),
                    ),
                  ],
                ),
                if (options.showMaxSpeed) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _stat(
                        context,
                        l10n.tripMaxSpeed,
                        Formatters.speedKmh(
                          trip.maximumSpeedKmh,
                          locale: locale,
                        ),
                      ),
                      if (vehicle != VehicleType.unknown)
                        _stat(
                          context,
                          l10n.vehicleConfirmTitle,
                          vehicleLabel(l10n, vehicle),
                        ),
                    ],
                  ),
                ],
                if (options.showStartLocation && trip.startLatitude != null)
                  _coordRow(
                    context,
                    l10n.tripStart,
                    trip.startLatitude!,
                    trip.startLongitude!,
                  ),
                if (options.showEndLocation && trip.endLatitude != null)
                  _coordRow(
                    context,
                    l10n.tripEnd,
                    trip.endLatitude!,
                    trip.endLongitude!,
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'ruteku • catat perjalanan otomatis',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
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

  Widget _stat(BuildContext context, String label, String value) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _coordRow(
    BuildContext context,
    String label,
    double lat,
    double lon,
  ) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      '$label: ${lat.toStringAsFixed(5)}, ${lon.toStringAsFixed(5)}',
      style: Theme.of(context).textTheme.bodySmall,
    ),
  );
}
