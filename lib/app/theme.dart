import 'package:flutter/material.dart';

/// Motivox brand theme (per the brand sheet):
/// aqua teal #00E5CC, cyan #00B4D8, teal #009688, deep navy #0A1F2E,
/// slate gray #5B6770, mint gray #E6F2F2. Dark mode lives on deep navy;
/// light mode on white/mint with teal-cyan accents.
class AppTheme {
  AppTheme._();

  static const _teal = Color(0xFF009688);
  static const _cyan = Color(0xFF00B4D8);
  static const _aqua = Color(0xFF00E5CC);
  static const _navy = Color(0xFF0A1F2E);
  static const _navyCard = Color(0xFF12293A);
  static const _mint = Color(0xFFF2F9F8);

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    var scheme = ColorScheme.fromSeed(
      seedColor: _teal,
      brightness: brightness,
    ).copyWith(secondary: _cyan, tertiary: _aqua);
    if (isDark) {
      scheme = scheme.copyWith(
        primary: _aqua,
        onPrimary: _navy,
        surface: _navy,
        surfaceContainerLowest: const Color(0xFF071823),
        surfaceContainerLow: _navyCard,
        surfaceContainer: const Color(0xFF15303F),
        surfaceContainerHigh: const Color(0xFF1A3846),
        surfaceContainerHighest: const Color(0xFF20404F),
        primaryContainer: const Color(0xFF0F3A3F),
        onPrimaryContainer: _aqua,
        secondaryContainer: const Color(0xFF0E3644),
        onSecondaryContainer: const Color(0xFF9BE8F5),
      );
    }
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? _navy : _mint,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: isDark ? _navyCard : Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF0E2635) : Colors.white,
        indicatorColor: scheme.secondaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      listTileTheme: const ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
