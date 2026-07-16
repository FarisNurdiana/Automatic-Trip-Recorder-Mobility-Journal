import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../l10n/gen/app_localizations.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final auth = ref.watch(authControllerProvider);
    final totals = ref.watch(tripTotalsProvider);
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              child: Text(
                (user?.displayName?.isNotEmpty == true
                        ? user!.displayName![0]
                        : (user?.email.isNotEmpty == true
                            ? user!.email[0]
                            : '?'))
                    .toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              user?.displayName ?? user?.email ?? '-',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Center(
            child: Text(
              auth.isLocalMode ? l10n.authLocalModeInfo : (user?.email ?? ''),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.straighten),
                  title: Text(l10n.homeTotalDistance),
                  trailing: Text(totals.maybeWhen(
                    data: (t) => Formatters.distanceKm(t.$2, locale: locale),
                    orElse: () => '—',
                  )),
                ),
                ListTile(
                  leading: const Icon(Icons.map_outlined),
                  title: Text(l10n.homeTripCount),
                  trailing: Text(totals.maybeWhen(
                    data: (t) => '${t.$1}',
                    orElse: () => '—',
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(l10n.settingsTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(l10n.settingsPrivacy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/settings/privacy'),
          ),
        ],
      ),
    );
  }
}
