import 'package:intl/intl.dart';

/// Locale-aware formatting for distances, speeds, durations and timestamps.
/// Units are km, km/jam (km/h), jam (h) and menit (min) per product decision.
class Formatters {
  Formatters._();

  static String distanceKm(double meters, {String locale = 'id'}) {
    final km = meters / 1000.0;
    final f = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: km >= 100 ? 0 : 1,
    );
    return '${f.format(km)} km';
  }

  static String speedKmh(double kmh, {String locale = 'id'}) {
    final f = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    );
    final unit = locale == 'id' ? 'km/jam' : 'km/h';
    return '${f.format(kmh)} $unit';
  }

  static String duration(Duration d, {String locale = 'id'}) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final hourUnit = locale == 'id' ? 'jam' : 'h';
    final minUnit = locale == 'id' ? 'menit' : 'min';
    if (hours > 0) return '$hours $hourUnit $minutes $minUnit';
    if (minutes > 0) return '$minutes $minUnit';
    return '${d.inSeconds} ${locale == 'id' ? 'detik' : 's'}';
  }

  static String time(DateTime t, {String locale = 'id'}) =>
      DateFormat.Hm(locale).format(t.toLocal());

  /// Format lokal Indonesia: "23 Juli 2026, 07.49" (bulan penuh, koma,
  /// jam dengan titik). English keeps the conventional "Jul 23, 2026 07:49".
  static String dateTime(DateTime t, {String locale = 'id'}) {
    if (locale == 'id') {
      return DateFormat('d MMMM y, HH.mm', 'id').format(t.toLocal());
    }
    return DateFormat.yMMMd(locale).add_Hm().format(t.toLocal());
  }

  static String date(DateTime t, {String locale = 'id'}) =>
      DateFormat.yMMMMd(locale).format(t.toLocal());
}
