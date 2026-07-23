import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/gen/app_localizations.dart';
import 'providers.dart';
import 'router.dart';
import 'theme.dart';

class TripLogApp extends ConsumerWidget {
  const TripLogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(settingsControllerProvider);

    // Navigate to vehicle confirmation whenever a trip finishes.
    ref.listen(tripRecordingControllerProvider, (previous, next) {
      final finishedId = next.finishedTripId;
      if (finishedId != null && previous?.finishedTripId != finishedId) {
        ref
            .read(tripRecordingControllerProvider.notifier)
            .consumeFinishedTrip();
        router.push('/trips/$finishedId/confirm-vehicle');
      }
    });

    return MaterialApp.router(
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
      builder: (context, child) => _ConnectivityWrapper(child: child),
    );
  }
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
