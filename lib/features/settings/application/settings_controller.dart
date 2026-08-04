import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/sensor_config.dart';
import '../../../core/constants/enums.dart';
import '../../../core/utils/fuel_estimator.dart';

/// Per-vehicle-type service reminder settings: how often (km) and the
/// odometer reading (total recorded km) at the last service.
class ServiceProfile {
  const ServiceProfile({
    this.intervalKmMotorcycle,
    this.intervalKmCar,
    this.baseKmMotorcycle = 0,
    this.baseKmCar = 0,
  });

  final double? intervalKmMotorcycle;
  final double? intervalKmCar;
  final double baseKmMotorcycle;
  final double baseKmCar;

  double? intervalFor(VehicleType type) => switch (type) {
    VehicleType.motorcycle => intervalKmMotorcycle,
    VehicleType.car => intervalKmCar,
    _ => null,
  };

  double baseFor(VehicleType type) => switch (type) {
    VehicleType.motorcycle => baseKmMotorcycle,
    VehicleType.car => baseKmCar,
    _ => 0,
  };
}

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
    this.keepScreenOn = true,
    this.speedLimitKmh,
    this.roadSpeedLimitEnabled = true,
    this.riderStyle = RiderStyle.normal,
    this.serviceProfile = const ServiceProfile(),
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

  /// Keep the screen awake while a trip is recording (holder use).
  final bool keepScreenOn;

  /// Warn (visual + vibration) above this speed; null disables the warning.
  final double? speedLimitKmh;

  /// Use the current road's OSM maxspeed as the alarm limit while
  /// recording (sends the position to the OpenStreetMap Overpass server).
  final bool roadSpeedLimitEnabled;

  /// Chibi rider character used by the trip playback animation.
  final RiderStyle riderStyle;

  /// Service reminder configuration per vehicle type.
  final ServiceProfile serviceProfile;

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
    bool? keepScreenOn,
    double? speedLimitKmh,
    bool clearSpeedLimit = false,
    bool? roadSpeedLimitEnabled,
    RiderStyle? riderStyle,
    ServiceProfile? serviceProfile,
  }) => SettingsState(
    autoDetectionEnabled: autoDetectionEnabled ?? this.autoDetectionEnabled,
    sensorConfig: sensorConfig ?? this.sensorConfig,
    mountPosition: mountPosition ?? this.mountPosition,
    themeMode: themeMode ?? this.themeMode,
    locale: clearLocale ? null : (locale ?? this.locale),
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    localMode: localMode ?? this.localMode,
    fuelProfile: fuelProfile ?? this.fuelProfile,
    keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    speedLimitKmh: clearSpeedLimit
        ? null
        : (speedLimitKmh ?? this.speedLimitKmh),
    roadSpeedLimitEnabled: roadSpeedLimitEnabled ?? this.roadSpeedLimitEnabled,
    riderStyle: riderStyle ?? this.riderStyle,
    serviceProfile: serviceProfile ?? this.serviceProfile,
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
      keepScreenOn: prefs.getBool('keepScreenOn') ?? true,
      speedLimitKmh: prefs.getDouble('speedLimitKmh'),
      roadSpeedLimitEnabled: prefs.getBool('roadSpeedLimitEnabled') ?? true,
      riderStyle: RiderStyle.fromName(prefs.getString('riderStyle')),
      serviceProfile: ServiceProfile(
        intervalKmMotorcycle: prefs.getDouble('serviceIntervalKmMotorcycle'),
        intervalKmCar: prefs.getDouble('serviceIntervalKmCar'),
        baseKmMotorcycle: prefs.getDouble('serviceBaseKmMotorcycle') ?? 0,
        baseKmCar: prefs.getDouble('serviceBaseKmCar') ?? 0,
      ),
    );
  }

  Future<void> setSpeedLimit(double? value) async {
    if (value == null || value <= 0) {
      await _prefs.remove('speedLimitKmh');
      state = state.copyWith(clearSpeedLimit: true);
    } else {
      await _prefs.setDouble('speedLimitKmh', value);
      state = state.copyWith(speedLimitKmh: value);
    }
  }

  Future<void> setRiderStyle(RiderStyle value) async {
    await _prefs.setString('riderStyle', value.name);
    state = state.copyWith(riderStyle: value);
  }

  Future<void> setRoadSpeedLimitEnabled(bool value) async {
    await _prefs.setBool('roadSpeedLimitEnabled', value);
    state = state.copyWith(roadSpeedLimitEnabled: value);
  }

  Future<void> setServiceInterval(VehicleType type, double? value) async {
    final key = type == VehicleType.motorcycle
        ? 'serviceIntervalKmMotorcycle'
        : 'serviceIntervalKmCar';
    if (value == null || value <= 0) {
      await _prefs.remove(key);
    } else {
      await _prefs.setDouble(key, value);
    }
    final p = state.serviceProfile;
    state = state.copyWith(
      serviceProfile: ServiceProfile(
        intervalKmMotorcycle: type == VehicleType.motorcycle
            ? (value != null && value > 0 ? value : null)
            : p.intervalKmMotorcycle,
        intervalKmCar: type == VehicleType.car
            ? (value != null && value > 0 ? value : null)
            : p.intervalKmCar,
        baseKmMotorcycle: p.baseKmMotorcycle,
        baseKmCar: p.baseKmCar,
      ),
    );
  }

  /// Records "serviced now": the reminder counts from this odometer value.
  Future<void> markServiced(VehicleType type, double odometerKm) async {
    final key = type == VehicleType.motorcycle
        ? 'serviceBaseKmMotorcycle'
        : 'serviceBaseKmCar';
    await _prefs.setDouble(key, odometerKm);
    final p = state.serviceProfile;
    state = state.copyWith(
      serviceProfile: ServiceProfile(
        intervalKmMotorcycle: p.intervalKmMotorcycle,
        intervalKmCar: p.intervalKmCar,
        baseKmMotorcycle: type == VehicleType.motorcycle
            ? odometerKm
            : p.baseKmMotorcycle,
        baseKmCar: type == VehicleType.car ? odometerKm : p.baseKmCar,
      ),
    );
  }

  Future<void> setKeepScreenOn(bool value) async {
    await _prefs.setBool('keepScreenOn', value);
    state = state.copyWith(keepScreenOn: value);
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
