import 'dart:io';
import 'dart:typed_data' show BytesBuilder;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Tile provider with a persistent disk cache: every downloaded map tile is
/// stored under the app-support directory and served from disk afterwards,
/// so areas the user has already viewed keep working offline and repeat
/// browsing costs no mobile data.
class DiskCachingTileProvider extends TileProvider {
  DiskCachingTileProvider({required this.userAgent});

  final String userAgent;

  static Directory? _dir;

  static Future<Directory> _cacheDir() async {
    if (_dir != null) return _dir!;
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, 'tile_cache'));
    await dir.create(recursive: true);
    _dir = dir;
    _trimIfHuge(dir);
    return dir;
  }

  /// Best-effort cap: when the cache grows past ~4000 tiles (~150-300 MB
  /// worst case), delete the oldest third. Runs once per app start.
  static void _trimIfHuge(Directory dir) {
    Future(() async {
      final files = await dir
          .list()
          .where((e) => e is File)
          .cast<File>()
          .toList();
      if (files.length <= 4000) return;
      files.sort(
        (a, b) => a.statSync().modified.compareTo(b.statSync().modified),
      );
      for (final file in files.take(files.length ~/ 3)) {
        try {
          await file.delete();
        } catch (_) {
          // Ignore races; the trim is opportunistic.
        }
      }
    });
  }

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      _DiskCachedTile(
        url: getTileUrl(coordinates, options),
        userAgent: userAgent,
      );
}

class _DiskCachedTile extends ImageProvider<_DiskCachedTile> {
  const _DiskCachedTile({required this.url, required this.userAgent});

  final String url;
  final String userAgent;

  String get _fileName => url.replaceAll(RegExp('[^A-Za-z0-9]'), '_');

  @override
  Future<_DiskCachedTile> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture(this);

  @override
  ImageStreamCompleter loadImage(
    _DiskCachedTile key,
    ImageDecoderCallback decode,
  ) => MultiFrameImageStreamCompleter(
    codec: _loadCodec(decode),
    scale: 1,
    debugLabel: url,
  );

  Future<ui.Codec> _loadCodec(ImageDecoderCallback decode) async {
    final dir = await DiskCachingTileProvider._cacheDir();
    final file = File(p.join(dir.path, _fileName));
    Uint8List bytes;
    if (await file.exists()) {
      bytes = await file.readAsBytes();
    } else {
      final client = HttpClient()
        ..connectionTimeout = const Duration(seconds: 10);
      try {
        final request = await client.getUrl(Uri.parse(url));
        request.headers.set(HttpHeaders.userAgentHeader, userAgent);
        final response = await request.close();
        if (response.statusCode != 200) {
          throw HttpException(
            'tile status ${response.statusCode}',
            uri: request.uri,
          );
        }
        final builder = BytesBuilder(copy: false);
        await for (final chunk in response) {
          builder.add(chunk);
        }
        bytes = builder.takeBytes();
        // Persist for offline reuse; a failed write must not fail the tile.
        try {
          await file.writeAsBytes(bytes, flush: false);
        } catch (_) {}
      } finally {
        client.close(force: true);
      }
    }
    return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
  }

  @override
  bool operator ==(Object other) =>
      other is _DiskCachedTile && other.url == url;

  @override
  int get hashCode => url.hashCode;
}
