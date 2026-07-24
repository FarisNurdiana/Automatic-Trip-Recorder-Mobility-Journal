import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/login_page.dart';
import '../features/settings/presentation/detection_log_page.dart';
import '../features/auth/presentation/onboarding_page.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/reset_password_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/home/presentation/splash_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/recording/presentation/current_trip_page.dart';
import '../features/settings/presentation/permission_diagnostics_page.dart';
import '../features/settings/presentation/privacy_page.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/trips/presentation/trip_detail_page.dart';
import '../features/trips/presentation/trip_history_page.dart';
import '../features/traffic_signs/presentation/traffic_signs_page.dart';
import '../features/trips/presentation/trip_map_page.dart';
import '../features/trips/presentation/vehicle_confirmation_page.dart';
import 'app_shell.dart';
import 'providers.dart';

/// Bridges a Stream into GoRouter's refreshListenable.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  // Re-evaluate redirects when auth or onboarding state changes.
  final authListenable = _StreamListenable(
    ref.watch(authControllerProvider.notifier).stream,
  );
  final settingsListenable = _StreamListenable(
    ref.watch(settingsControllerProvider.notifier).stream,
  );
  ref.onDispose(authListenable.dispose);
  ref.onDispose(settingsListenable.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([authListenable, settingsListenable]),
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final settings = ref.read(settingsControllerProvider);
      final location = state.matchedLocation;

      if (auth.initializing) {
        return location == '/splash' ? null : '/splash';
      }
      if (!settings.onboardingCompleted) {
        return location == '/onboarding' ? null : '/onboarding';
      }
      final authPages = {'/login', '/register', '/reset-password'};
      if (!auth.isSignedIn) {
        return authPages.contains(location) ? null : '/login';
      }
      if (location == '/splash' ||
          location == '/onboarding' ||
          location == '/login') {
        return '/';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashPage()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterPage()),
      GoRoute(
        path: '/reset-password',
        builder: (_, _) => const ResetPasswordPage(),
      ),
      // Main tabs live inside the bottom-navigation shell; detail pages are
      // plain top-level routes so they cover the nav bar when pushed.
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [GoRoute(path: '/', builder: (_, _) => const HomePage())],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                builder: (_, _) => const TripHistoryPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/signs',
                builder: (_, _) => const TrafficSignsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (_, _) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/current-trip',
        builder: (_, _) => const CurrentTripPage(),
      ),
      GoRoute(
        path: '/trips/:id',
        builder: (_, state) =>
            TripDetailPage(tripId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/trips/:id/map',
        builder: (_, state) => TripMapPage(tripId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/trips/:id/confirm-vehicle',
        builder: (_, state) =>
            VehicleConfirmationPage(tripId: state.pathParameters['id']!),
      ),
      GoRoute(path: '/profile', builder: (_, _) => const ProfilePage()),
      GoRoute(
        path: '/settings/permissions',
        builder: (_, _) => const PermissionDiagnosticsPage(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (_, _) => const PrivacyPage(),
      ),
      GoRoute(
        path: '/settings/detection-log',
        builder: (_, _) => const DetectionLogPage(),
      ),
    ],
  );
});
