import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/sensor_config.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/fuel_estimator.dart';

/// User preferences persisted in SharedPreferences.
class SettingsState {
  const SettingsState({
    this.autoDetectionEnabled = true,
    this.sensorConfig = const SensorSamplingConfig(),
    this.mountPosition = PhoneMountPosition.unknown,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.onboardingCompleted = false,
    this.localMode = false,
    this.fuelProfile = const FuelProfile(),
  });

  final bool autoDetectionEnabled;
  final SensorSamplingConfig sensorConfig;
  final PhoneMountPosition mountPosition;
  final ThemeMode themeMode;

  /// null = follow system; supported: id (default), en.
  final Locale? locale;
  final bool onboardingCompleted;

  /// Using the app without a Supabase account.
  final bool localMode;

  /// User-entered km/L + fuel price for per-trip fuel estimates.
  final FuelProfile fuelProfile;

  SettingsState copyWith({
    bool? autoDetectionEnabled,
    SensorSamplingConfig? sensorConfig,
    PhoneMountPosition? mountPosition,
    ThemeMode? themeMode,
    Locale? locale,
    bool clearLocale = false,
    bool? onboardingCompleted,
    bool? localMode,
    FuelProfile? fuelProfile,
  }) => SettingsState(
    autoDetectionEnabled: autoDetectionEnabled ?? this.autoDetectionEnabled,
    sensorConfig: sensorConfig ?? this.sensorConfig,
    mountPosition: mountPosition ?? this.mountPosition,
    themeMode: themeMode ?? this.themeMode,
    locale: clearLocale ? null : (locale ?? this.locale),
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    localMode: localMode ?? this.localMode,
    fuelProfile: fuelProfile ?? this.fuelProfile,
  );
}

class SettingsController extends StateNotifier<SettingsState> {
  SettingsController(this._prefs) : super(_load(_prefs));

  final SharedPreferences _prefs;

  static SettingsState _load(SharedPreferences prefs) {
    final localeCode = prefs.getString('locale');
    return SettingsState(
      autoDetectionEnabled: prefs.getBool('autoDetection') ?? true,
      sensorConfig: SensorSamplingConfig(
        enabled: prefs.getBool('sensorLogging') ?? false,
        rawSamplingHz: prefs.getInt('sensorRawHz') ?? 20,
        storedSamplingHz: prefs.getInt('sensorStoredHz') ?? 5,
      ),
      mountPosition: PhoneMountPosition.fromName(
        prefs.getString('mountPosition'),
      ),
      themeMode: switch (prefs.getString('themeMode')) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      locale: localeCode == null ? null : Locale(localeCode),
      onboardingCompleted: prefs.getBool('onboardingCompleted') ?? false,
      localMode: prefs.getBool('localMode') ?? false,
      fuelProfile: FuelProfile(
        motorcycleKmPerLiter: prefs.getDouble('fuelKmPerLiterMotorcycle'),
        carKmPerLiter: prefs.getDouble('fuelKmPerLiterCar'),
        fuelPricePerLiter: prefs.getDouble('fuelPricePerLiter'),
      ),
    );
  }

  /// Stores one fuel-profile field; null clears it (no estimate shown).
  Future<void> setFuelProfileValue(String key, double? value) async {
    assert(
      key == 'fuelKmPerLiterMotorcycle' ||
          key == 'fuelKmPerLiterCar' ||
          key == 'fuelPricePerLiter',
    );
    if (value == null || value <= 0) {
      await _prefs.remove(key);
    } else {
      await _prefs.setDouble(key, value);
    }
    final p = state.fuelProfile;
    state = state.copyWith(
      fuelProfile: FuelProfile(
        motorcycleKmPerLiter: key == 'fuelKmPerLiterMotorcycle'
            ? (value != null && value > 0 ? value : null)
            : p.motorcycleKmPerLiter,
        carKmPerLiter: key == 'fuelKmPerLiterCar'
            ? (value != null && value > 0 ? value : null)
            : p.carKmPerLiter,
        fuelPricePerLiter: key == 'fuelPricePerLiter'
            ? (value != null && value > 0 ? value : null)
            : p.fuelPricePerLiter,
      ),
    );
  }

  Future<void> setAutoDetection(bool value) async {
    await _prefs.setBool('autoDetection', value);
    state = state.copyWith(autoDetectionEnabled: value);
  }

  Future<void> setSensorLogging(bool value) async {
    await _prefs.setBool('sensorLogging', value);
    state = state.copyWith(
      sensorConfig: state.sensorConfig.copyWith(enabled: value),
    );
  }

  Future<void> setMountPosition(PhoneMountPosition value) async {
    await _prefs.setString('mountPosition', value.name);
    state = state.copyWith(mountPosition: value);
  }

  Future<void> setThemeMode(ThemeMode value) async {
    await _prefs.setString('themeMode', value.name);
    state = state.copyWith(themeMode: value);
  }

  Future<void> setLocale(Locale? value) async {
    if (value == null) {
      await _prefs.remove('locale');
      state = state.copyWith(clearLocale: true);
    } else {
      await _prefs.setString('locale', value.languageCode);
      state = state.copyWith(locale: value);
    }
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool('onboardingCompleted', true);
    state = state.copyWith(onboardingCompleted: true);
  }

  Future<void> setLocalMode(bool value) async {
    await _prefs.setBool('localMode', value);
    state = state.copyWith(localMode: value);
  }
}
