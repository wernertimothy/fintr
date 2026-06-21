import 'package:flutter/material.dart';

/// Light + dark themes using Claude's palette: a warm cream off-white, a warm
/// dark grey, and the signature coral accent.
class AppTheme {
  AppTheme._();

  // Brand accent (Claude coral / clay).
  static const Color _coral = Color(0xFFD97757);

  // Light — warm off-white / cream.
  static const Color _creamSurface = Color(0xFFFAF9F5); // scaffold
  static const Color _inkLight = Color(0xFF1F1E1D); // text
  static const Color _inkLightMuted = Color(0xFF6B6A63); // secondary text

  // Dark — warm dark grey.
  static const Color _greySurface = Color(0xFF262624); // scaffold
  static const Color _inkDark = Color(0xFFF2F0E9); // off-white text
  static const Color _inkDarkMuted = Color(0xFFBFBDB4); // secondary text

  static const Color _error = Color(0xFFBA1A1A);

  static final ColorScheme _lightScheme =
      ColorScheme.fromSeed(seedColor: _coral, brightness: Brightness.light)
          .copyWith(
    primary: _coral,
    onPrimary: Colors.white,
    secondary: _coral,
    onSecondary: Colors.white,
    error: _error,
    surface: _creamSurface,
    onSurface: _inkLight,
    onSurfaceVariant: _inkLightMuted,
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    surfaceContainerLow: const Color(0xFFF5F3EC),
    surfaceContainer: const Color(0xFFF0EEE6),
    surfaceContainerHigh: const Color(0xFFEAE8DF),
    surfaceContainerHighest: const Color(0xFFE4E2D8), // progress track
    outlineVariant: const Color(0xFFDCDACF),
  );

  static final ColorScheme _darkScheme =
      ColorScheme.fromSeed(seedColor: _coral, brightness: Brightness.dark)
          .copyWith(
    primary: _coral,
    onPrimary: const Color(0xFF1F1E1D),
    secondary: _coral,
    onSecondary: const Color(0xFF1F1E1D),
    error: const Color(0xFFFFB4AB),
    surface: _greySurface,
    onSurface: _inkDark,
    onSurfaceVariant: _inkDarkMuted,
    surfaceContainerLowest: const Color(0xFF1C1B1A),
    surfaceContainerLow: const Color(0xFF2B2A28),
    surfaceContainer: const Color(0xFF302F2D),
    surfaceContainerHigh: const Color(0xFF3A3937),
    surfaceContainerHighest: const Color(0xFF45443F), // progress track
    outlineVariant: const Color(0xFF45443F),
  );

  static ThemeData get light => _build(_lightScheme);
  static ThemeData get dark => _build(_darkScheme);

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    // Bold all titles, headlines, and labels (headers throughout the app).
    TextStyle? bold(TextStyle? s) => s?.copyWith(fontWeight: FontWeight.bold);
    final textTheme = base.textTheme.copyWith(
      headlineLarge: bold(base.textTheme.headlineLarge),
      headlineMedium: bold(base.textTheme.headlineMedium),
      headlineSmall: bold(base.textTheme.headlineSmall),
      titleLarge: bold(base.textTheme.titleLarge),
      titleMedium: bold(base.textTheme.titleMedium),
      titleSmall: bold(base.textTheme.titleSmall),
      labelLarge: bold(base.textTheme.labelLarge),
    );

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
    );
  }
}
