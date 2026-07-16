import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Snapshot of every permission the app cares about, for the diagnostics
/// page and the home dashboard.
class PermissionsSnapshot {
  const PermissionsSnapshot({
    this.location = false,
    this.backgroundLocation = false,
    this.activityRecognition = false,
    this.motionFitness = false,
    this.notifications = false,
    this.batteryOptimizationExempt = false,
  });

  final bool location;
  final bool backgroundLocation;
  final bool activityRecognition;
  final bool motionFitness;
  final bool notifications;
  final bool batteryOptimizationExempt;

  bool get allCoreGranted => location && backgroundLocation && notifications;
}

/// Wraps permission_handler with a staged, explain-first request flow.
/// Never tries to bypass Android/iOS permission policies.
class PermissionsService {
  Future<PermissionsSnapshot> snapshot() async {
    if (kIsWeb) return const PermissionsSnapshot();
    final location = await Permission.locationWhenInUse.status;
    final background = await Permission.locationAlways.status;
    final notifications = await Permission.notification.status;
    var activity = PermissionStatus.granted;
    var motion = PermissionStatus.granted;
    var battery = PermissionStatus.granted;
    if (Platform.isAndroid) {
      activity = await Permission.activityRecognition.status;
      battery = await Permission.ignoreBatteryOptimizations.status;
    } else if (Platform.isIOS) {
      motion = await Permission.sensors.status;
    }
    return PermissionsSnapshot(
      location: location.isGranted,
      backgroundLocation: background.isGranted,
      activityRecognition: activity.isGranted,
      motionFitness: motion.isGranted,
      notifications: notifications.isGranted,
      batteryOptimizationExempt: battery.isGranted,
    );
  }

  Future<bool> requestLocation() async =>
      (await Permission.locationWhenInUse.request()).isGranted;

  /// Background location must be requested only after while-in-use has been
  /// granted (Android 11+ sends the user to settings).
  Future<bool> requestBackgroundLocation() async =>
      (await Permission.locationAlways.request()).isGranted;

  Future<bool> requestActivityRecognition() async {
    if (!kIsWeb && Platform.isAndroid) {
      return (await Permission.activityRecognition.request()).isGranted;
    }
    return true;
  }

  Future<bool> requestMotionFitness() async {
    if (!kIsWeb && Platform.isIOS) {
      return (await Permission.sensors.request()).isGranted;
    }
    return true;
  }

  Future<bool> requestNotifications() async =>
      (await Permission.notification.request()).isGranted;

  Future<bool> requestBatteryOptimizationExemption() async {
    if (!kIsWeb && Platform.isAndroid) {
      return (await Permission.ignoreBatteryOptimizations.request()).isGranted;
    }
    return true;
  }

  Future<void> openSettings() => openAppSettings();
}
