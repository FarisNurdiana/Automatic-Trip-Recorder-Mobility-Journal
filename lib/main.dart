import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/config/env.dart';
import 'core/errors/app_logger.dart';
import 'features/trips/data/trip_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppLogger.instance.init();
  AppLogger.instance.installGlobalHandlers();

  final env = await Env.load();
  if (env.isSupabaseConfigured) {
    try {
      await Supabase.initialize(
        url: env.supabaseUrl,
        // SUPABASE_ANON_KEY also accepts the newer publishable key format.
        // ignore: deprecated_member_use
        anonKey: env.supabaseAnonKey,
      );
    } catch (e) {
      debugPrint('Supabase init failed: $e');
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final metadata = await _collectDeviceMetadata();

  runApp(
    ProviderScope(
      overrides: [
        envProvider.overrideWithValue(env),
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceMetadataProvider.overrideWithValue(metadata),
      ],
      child: const TripLogApp(),
    ),
  );
}

Future<TripDeviceMetadata> _collectDeviceMetadata() async {
  String? deviceModel;
  String? os;
  String? osVersion;
  String? appVersion;
  try {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    final deviceInfo = DeviceInfoPlugin();
    if (!kIsWeb && Platform.isAndroid) {
      final android = await deviceInfo.androidInfo;
      deviceModel = '${android.manufacturer} ${android.model}';
      os = 'android';
      osVersion = android.version.release;
    } else if (!kIsWeb && Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      deviceModel = ios.utsname.machine;
      os = 'ios';
      osVersion = ios.systemVersion;
    }
  } catch (e) {
    debugPrint('device metadata unavailable: $e');
  }
  return TripDeviceMetadata(
    deviceModel: deviceModel,
    operatingSystem: os,
    operatingSystemVersion: osVersion,
    appVersion: appVersion,
  );
}
