import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../app/providers.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../../shared/widgets/status_widgets.dart';
import '../data/traffic_signs_data.dart';
import '../domain/traffic_sign.dart';
import 'sign_illustration.dart';

/// Daftar favorit disimpan lokal (id rambu) di SharedPreferences.
final signFavoritesProvider =
    StateNotifierProvider<SignFavoritesController, Set<String>>(
      (ref) => SignFavoritesController(ref.watch(sharedPreferencesProvider)),
    );

class SignFavoritesController extends StateNotifier<Set<String>> {
  SignFavoritesController(this._prefs)
    : super((_prefs.getStringList('signFavorites') ?? const []).toSet());

  final SharedPreferences _prefs;

  Future<void> toggle(String id) async {
    final next = Set<String>.from(state);
    if (!next.remove(id)) next.add(id);
    await _prefs.setStringList('signFavorites', next.toList());
    state = next;
  }
}

String signCategoryLabel(AppLocalizations l10n, TrafficSignCategory c) =>
    switch (c) {
      TrafficSignCategory.peringatan => l10n.signsCatWarning,
      TrafficSignCategory.larangan => l10n.signsCatProhibition,
      TrafficSignCategory.perintah => l10n.signsCatMandatory,
      TrafficSignCategory.petunjuk => l10n.signsCatGuide,
      TrafficSignCategory.sementara => l10n.signsCatTemporary,
      TrafficSignCategory.marka => l10n.signsCatMarking,
    };

/// Menu "Rambu lalu lintas": pencarian, filter kategori, favorit, detail.
class TrafficSignsPage extends ConsumerStatefulWidget {
  const TrafficSignsPage({super.key});

  @override
  ConsumerState<TrafficSignsPage> createState() => _TrafficSignsPageState();
}

class _TrafficSignsPageState extends ConsumerState<TrafficSignsPage> {
  String _query = '';
  TrafficSignCategory? _category;
  bool _favoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final favorites = ref.watch(signFavoritesProvider);

    final filtered = trafficSigns
        .where((s) => _category == null || s.category == _category)
        .where((s) => !_favoritesOnly || favorites.contains(s.id))
        .where((s) => s.matches(_query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.signsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              l10n.signsSubtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: l10n.signsSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: Text(l10n.signsAll),
                  selected: _category == null && !_favoritesOnly,
                  onSelected: (_) => setState(() {
                    _category = null;
                    _favoritesOnly = false;
                  }),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  avatar: const Icon(Icons.star, size: 16),
                  label: Text(l10n.signsFavorites),
                  selected: _favoritesOnly,
                  onSelected: (_) =>
                      setState(() => _favoritesOnly = !_favoritesOnly),
                ),
                for (final c in TrafficSignCategory.values) ...[
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(signCategoryLabel(l10n, c)),
                    selected: _category == c,
                    onSelected: (_) =>
                        setState(() => _category = _category == c ? null : c),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? EmptyStateView(
                    message: l10n.signsEmpty,
                    icon: Icons.signpost_outlined,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final sign = filtered[index];
                      return Card(
                        child: ListTile(
                          leading: SignIllustration(sign: sign, size: 48),
                          title: Text(sign.name),
                          subtitle: Text(
                            signCategoryLabel(l10n, sign.category),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              favorites.contains(sign.id)
                                  ? Icons.star
                                  : Icons.star_border,
                              color: favorites.contains(sign.id)
                                  ? Colors.amber
                                  : null,
                            ),
                            onPressed: () => ref
                                .read(signFavoritesProvider.notifier)
                                .toggle(sign.id),
                          ),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => TrafficSignDetailPage(sign: sign),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class TrafficSignDetailPage extends StatelessWidget {
  const TrafficSignDetailPage({super.key, required this.sign});

  final TrafficSign sign;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(sign.name)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(child: SignIllustration(sign: sign, size: 160)),
          const SizedBox(height: 8),
          Center(
            child: Chip(label: Text(signCategoryLabel(l10n, sign.category))),
          ),
          const SizedBox(height: 16),
          _section(context, l10n.signsMeaning, sign.meaning),
          _section(context, l10n.signsAction, sign.action),
          if (sign.safetyNote != null)
            _section(context, l10n.signsSafetyNote, sign.safetyNote!),
          const SizedBox(height: 24),
          Text(
            l10n.signsSourceNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(body, style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );
}
