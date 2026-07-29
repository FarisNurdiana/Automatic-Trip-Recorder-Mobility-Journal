import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/constants/enums.dart';
import '../../../core/storage/app_database.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/ruteku_logo.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../../recording/presentation/state_labels.dart';
import '../../trips/presentation/widgets/vehicle_ui.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static String _greeting(AppLocalizations l10n, String? displayName) {
    final name = displayName?.trim();
    if (name == null || name.isEmpty) return l10n.homeGreetingAnon;
    return l10n.homeGreetingNamed(name.split(' ').first);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final recording = ref.watch(tripRecordingControllerProvider);
    final trips = ref.watch(tripsStreamProvider);
    final totals = ref.watch(tripTotalsProvider);
    final permissions = ref.watch(permissionsSnapshotProvider);
    final syncState = ref.watch(syncStateProvider);
    final auth = ref.watch(authControllerProvider);
    final settings = ref.watch(settingsControllerProvider);

    final isActive = recording.machineState.isActiveTrip;

    // Service reminders: total recorded km per vehicle type vs the interval.
    final finishedTrips = (trips.valueOrNull ?? const <Trip>[])
        .where((t) => t.status == TripRecordingState.finished.name)
        .toList();
    double kmFor(VehicleType type) =>
        finishedTrips
            .where(
              (t) =>
                  VehicleType.fromName(
                    t.confirmedVehicleType ?? t.detectedVehicleType,
                  ) ==
                  type,
            )
            .fold<double>(0, (sum, t) => sum + t.distanceMeters) /
        1000;
    final serviceDue = <(VehicleType, double, double)>[];
    for (final type in [VehicleType.motorcycle, VehicleType.car]) {
      final interval = settings.serviceProfile.intervalFor(type);
      if (interval == null) continue;
      final total = kmFor(type);
      final since = total - settings.serviceProfile.baseFor(type);
      if (since >= interval) serviceDue.add((type, since, total));
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const RutekuLogo(size: 28),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(permissionsSnapshotProvider);
          ref.invalidate(tripTotalsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            // --- greeting ---
            Padding(
              padding: const EdgeInsets.only(bottom: 12, left: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _greeting(l10n, auth.user?.displayName),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.date(DateTime.now(), locale: locale),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _HeroCard(
              isActive: isActive,
              statusLabel: tripStateLabel(l10n, recording.machineState),
              subtitle: isActive
                  ? l10n.homeHeroActiveDesc
                  : l10n.homeHeroReadyDesc,
              distance: Formatters.distanceKm(
                recording.liveDistanceMeters,
                locale: locale,
              ),
              duration: Formatters.duration(
                recording.liveElapsed,
                locale: locale,
              ),
              buttonLabel: isActive
                  ? l10n.tripCurrentTitle
                  : l10n.homeStartTrip,
              onPressed: () async {
                if (isActive) {
                  context.push('/current-trip');
                  return;
                }
                await ref
                    .read(tripRecordingControllerProvider.notifier)
                    .startManual();
                if (context.mounted) context.push('/current-trip');
              },
            ),
            const SizedBox(height: 12),

            // --- service reminders ---
            for (final (type, sinceKm, totalKm) in serviceDue) ...[
              Card(
                color: Theme.of(context).colorScheme.tertiaryContainer,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.build,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n.serviceDueTitle(
                                vehicleLabel(l10n, type).toLowerCase(),
                              ),
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.serviceDueBody(sinceKm.round()),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonal(
                          onPressed: () async {
                            await ref
                                .read(settingsControllerProvider.notifier)
                                .markServiced(type, totalKm);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.serviceMarked)),
                              );
                            }
                          },
                          child: Text(l10n.serviceMarkDone),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // --- totals ---
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: l10n.homeTotalDistance,
                    icon: Icons.straighten,
                    value: totals.maybeWhen(
                      data: (t) => Formatters.distanceKm(t.$2, locale: locale),
                      orElse: () => '—',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatTile(
                    label: l10n.homeTripCount,
                    icon: Icons.map_outlined,
                    value: totals.maybeWhen(
                      data: (t) => '${t.$1}',
                      orElse: () => '—',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- last trip ---
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.homeLastTrip,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/trips'),
                  child: Text(l10n.homeSeeAll),
                ),
              ],
            ),
            const SizedBox(height: 4),
            trips.when(
              loading: () => const LoadingView(),
              error: (e, _) => ErrorView(message: l10n.commonError),
              data: (list) {
                final finished = list
                    .where((t) => t.status == TripRecordingState.finished.name)
                    .toList();
                if (finished.isEmpty) {
                  return Card(
                    child: EmptyStateView(
                      message: l10n.homeNoTrips,
                      icon: Icons.route_outlined,
                    ),
                  );
                }
                return _LastTripCard(trip: finished.first, locale: locale);
              },
            ),
            const SizedBox(height: 20),

            // --- health: permissions + sync ---
            Text(
              l10n.homeQuickMenu,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const _LeadingBadge(icon: Icons.local_gas_station),
                    title: Text(l10n.poiSheetTitle),
                    subtitle: Text(l10n.poiDisclaimer),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/nearby'),
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  ListTile(
                    leading: permissions.maybeWhen(
                      data: (p) => _LeadingBadge(
                        icon: p.allCoreGranted
                            ? Icons.verified_user
                            : Icons.gpp_maybe_outlined,
                        color: p.allCoreGranted
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                      ),
                      orElse: () =>
                          const _LeadingBadge(icon: Icons.verified_user),
                    ),
                    title: Text(l10n.homePermissions),
                    subtitle: permissions.maybeWhen(
                      data: (p) => Text(
                        p.allCoreGranted
                            ? l10n.homePermissionsComplete
                            : l10n.homePermissionsIncomplete,
                      ),
                      orElse: () => Text(l10n.commonLoading),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/permissions'),
                  ),
                  Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  ListTile(
                    leading: const _LeadingBadge(icon: Icons.sync),
                    title: Text(l10n.homeSyncStatus),
                    subtitle: Text(
                      auth.isLocalMode
                          ? l10n.syncLocalOnly
                          : syncState.maybeWhen(
                              data: (s) => switch (s.status) {
                                SyncStatus.pending => l10n.syncPending,
                                SyncStatus.syncing =>
                                  '${l10n.syncSyncing} (${s.pendingTrips})',
                                SyncStatus.synced => l10n.syncSynced,
                                SyncStatus.failed => l10n.syncFailed,
                              },
                              orElse: () => l10n.syncSynced,
                            ),
                    ),
                    trailing: auth.isLocalMode
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: l10n.syncNow,
                            onPressed: () {
                              final userId = auth.user?.id;
                              final sync = ref.read(syncServiceProvider);
                              if (userId != null && sync != null) {
                                sync.syncNow(userId);
                              }
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient hero card: detection status + primary action. When a trip is
/// active it shows live distance/duration and a pulsing recording dot.
class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.isActive,
    required this.statusLabel,
    required this.subtitle,
    required this.distance,
    required this.duration,
    required this.buttonLabel,
    required this.onPressed,
  });

  final bool isActive;
  final String statusLabel;
  final String subtitle;
  final String distance;
  final String duration;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            scheme.primary,
            Color.lerp(scheme.primary, scheme.secondary, 0.55)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Oversized brand watermark peeking from the corner.
          Positioned(
            right: -18,
            bottom: -26,
            child: Opacity(
              opacity: 0.14,
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcATop,
                ),
                child: const RutekuLogo(size: 140),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: _heroContent(context, scheme),
          ),
        ],
      ),
    );
  }

  Widget _heroContent(BuildContext context, ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (isActive)
              const _PulsingDot()
            else
              Icon(
                Icons.radar,
                size: 18,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.85),
            fontSize: 13,
          ),
        ),
        if (isActive) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              _HeroStat(icon: Icons.straighten, value: distance),
              const SizedBox(width: 16),
              _HeroStat(icon: Icons.schedule, value: duration),
            ],
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: scheme.primary,
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: onPressed,
          icon: Icon(isActive ? Icons.navigation : Icons.play_arrow),
          label: Text(buttonLabel),
        ),
      ],
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Small red dot that pulses while recording.
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_controller),
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFFFF5252),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _LastTripCard extends StatelessWidget {
  const _LastTripCard({required this.trip, required this.locale});

  final Trip trip;
  final String locale;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final vehicle = VehicleType.fromName(
      trip.confirmedVehicleType ?? trip.detectedVehicleType,
    );
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: scheme.secondaryContainer,
          child: Icon(vehicleIcon(vehicle), color: scheme.onSecondaryContainer),
        ),
        title: Text(
          Formatters.dateTime(trip.startedAt, locale: locale),
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${Formatters.distanceKm(trip.distanceMeters, locale: locale)} • '
            '${Formatters.duration(Duration(seconds: trip.elapsedDurationSeconds), locale: locale)} • '
            '${vehicleLabel(l10n, vehicle)}',
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/trips/${trip.id}'),
      ),
    );
  }
}

class _LeadingBadge extends StatelessWidget {
  const _LeadingBadge({required this.icon, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, size: 22, color: color ?? scheme.onSecondaryContainer),
    );
  }
}
