import 'package:flutter/material.dart';

import '../../../../core/geo/reverse_geocoder.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/congestion_estimator.dart';

/// "Titik macet" card on the trip detail page: the worst jam stretches with
/// how long each lasted and (once the reverse geocoder answers) around
/// which street. The same stretches are painted orange on the map above.
class CongestionSpotsCard extends StatefulWidget {
  const CongestionSpotsCard({super.key, required this.segments});

  final List<CongestionSegment> segments;

  @override
  State<CongestionSpotsCard> createState() => _CongestionSpotsCardState();
}

class _CongestionSpotsCardState extends State<CongestionSpotsCard> {
  static const _maxSpots = 3;

  late final List<CongestionSegment> _worst;
  final Map<int, String> _streets = {};

  @override
  void initState() {
    super.initState();
    _worst = List.of(widget.segments)
      ..sort((a, b) => b.duration.compareTo(a.duration));
    if (_worst.length > _maxSpots) _worst.removeRange(_maxSpots, _worst.length);
    _resolveStreets();
  }

  /// Reverse-geocodes each jam's midpoint serially (Nominatim usage policy:
  /// max ~1 request/second), abandoning quietly when the page closes.
  Future<void> _resolveStreets() async {
    final geocoder = NominatimReverseGeocoder();
    for (var i = 0; i < _worst.length; i++) {
      if (!mounted) return;
      final mid = _worst[i].midpoint;
      final label = await geocoder.shortLabel(mid.latitude, mid.longitude);
      if (!mounted) return;
      if (label != null) setState(() => _streets[i] = label);
      await Future<void>.delayed(const Duration(milliseconds: 1100));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.traffic,
                  size: 18,
                  color: Colors.deepOrange.shade600,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.congestionSpotsTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < _worst.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.congestionSpotEntry(
                          Formatters.duration(
                            _worst[i].duration,
                            locale: locale,
                          ),
                          _streets[i] ??
                              '${_worst[i].midpoint.latitude.toStringAsFixed(4)}, '
                                  '${_worst[i].midpoint.longitude.toStringAsFixed(4)}',
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Text(
              l10n.congestionSpotsNote,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
