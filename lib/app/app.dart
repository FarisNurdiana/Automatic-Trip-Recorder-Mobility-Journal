import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../l10n/gen/app_localizations.dart';
import 'providers.dart';
import 'router.dart';
import 'theme.dart';

final _messengerKey = GlobalKey<ScaffoldMessengerState>();

class TripLogApp extends ConsumerWidget {
  const TripLogApp({super.key});

  /// Localized message for a recording-pipeline error key; null hides it.
  static String? _errorMessage(AppLocalizations l10n, String key) =>
      switch (key) {
        'tripTooShort' => l10n.tripTooShort,
        'tripNoGps' => l10n.errorTripNoGps,
        'gpsDisabled' => l10n.errorGpsDisabled,
        'permissionDenied' => l10n.errorPermissionDenied,
        'database' => l10n.errorDatabase,
        'notSignedIn' => l10n.errorNotSignedIn,
        'sensorUnavailable' => l10n.errorSensorUnavailable,
        // Informational; the settings page already explains this state.
        'activityUnavailable' => null,
        _ => null,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsControllerProvider);

    // Navigate to vehicle confirmation whenever a trip finishes, and surface
    // recording errors as snackbars — a discarded trip must never be silent.
    ref.listen(tripRecordingControllerProvider, (previous, next) {
      // Keep the screen awake while a trip is active (holder use). Gated by
      // the user setting; wakelock only applies while the app is visible.
      final wasActive = previous?.machineState.isActiveTrip ?? false;
      final isActive = next.machineState.isActiveTrip;
      if (isActive != wasActive) {
        final keepOn = ref.read(settingsControllerProvider).keepScreenOn;
        unawaited(
          isActive && keepOn ? WakelockPlus.enable() : WakelockPlus.disable(),
        );
      }

      final finishedId = next.finishedTripId;
      if (finishedId != null && previous?.finishedTripId != finishedId) {
        ref
            .read(tripRecordingControllerProvider.notifier)
            .consumeFinishedTrip();
        final messenger = _messengerKey.currentState;
        final l10n = _messengerKey.currentContext == null
            ? null
            : AppLocalizations.of(_messengerKey.currentContext!);
        if (messenger != null && l10n != null) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.tripSaved)));
        }
        // Label the endpoints with human-readable places (best effort).
        final repo = ref.read(tripRepositoryProvider);
        final resolver = ref.read(tripAddressResolverProvider);
        unawaited(
          repo.getTrip(finishedId).then((trip) {
            if (trip != null) return resolver.ensure(trip);
          }),
        );
        router.push('/trips/$finishedId/confirm-vehicle');
      }

      final errorKey = next.errorKey;
      if (errorKey != null && previous?.errorKey != errorKey) {
        final messenger = _messengerKey.currentState;
        final ctx = _messengerKey.currentContext;
        if (messenger != null && ctx != null) {
          final message = _errorMessage(AppLocalizations.of(ctx), errorKey);
          if (message != null) {
            messenger.showSnackBar(
              SnackBar(
                content: Text(message),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
        ref.read(tripRecordingControllerProvider.notifier).clearError();
      }
    });

    return MaterialApp.router(
      scaffoldMessengerKey: _messengerKey,
      title: 'Ruteku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      locale: settings.locale ?? const Locale('id'),
      supportedLocales: const [Locale('id'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) =>
          _QuickActionHandler(child: _ConnectivityWrapper(child: child)),
    );
  }
}

/// Consumes pending quick actions (Quick Settings tile) from the platform:
/// checked at startup and every time the app returns to the foreground.
class _QuickActionHandler extends ConsumerStatefulWidget {
  const _QuickActionHandler({required this.child});

  final Widget child;

  @override
  ConsumerState<_QuickActionHandler> createState() =>
      _QuickActionHandlerState();
}

class _QuickActionHandlerState extends ConsumerState<_QuickActionHandler>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('triplog/shortcuts');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Give the router/auth a moment to settle before acting on a cold start.
    Future<void>.delayed(const Duration(milliseconds: 600), _consume);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _consume();
  }

  Future<void> _consume() async {
    String? action;
    try {
      action = await _channel.invokeMethod<String>('consumePendingAction');
    } catch (_) {
      return; // Not supported on this platform.
    }
    if (action != 'start_trip' || !mounted) return;
    final recording = ref.read(tripRecordingControllerProvider);
    if (!recording.machineState.isActiveTrip) {
      await ref.read(tripRecordingControllerProvider.notifier).startManual();
    }
    if (mounted) ref.read(routerProvider).push('/current-trip');
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Shows a persistent offline banner above every page.
class _ConnectivityWrapper extends StatefulWidget {
  const _ConnectivityWrapper({this.child});

  final Widget? child;

  @override
  State<_ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<_ConnectivityWrapper> {
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      if (offline != _offline && mounted) {
        setState(() => _offline = offline);
      }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_offline) return widget.child ?? const SizedBox.shrink();
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);
    final message =
        l10n?.commonOfflineBanner ??
        'Offline — data disimpan lokal dan akan disinkronkan nanti';
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: double.infinity,
          color: scheme.tertiaryContainer,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 4,
            bottom: 6,
            left: 16,
            right: 16,
          ),
          child: Text(
            message,
            textDirection: TextDirection.ltr,
            style: TextStyle(fontSize: 12, color: scheme.onTertiaryContainer),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: widget.child ?? const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
