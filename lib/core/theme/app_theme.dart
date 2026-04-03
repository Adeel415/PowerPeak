import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Brand Colors
  static const Color primary = Color(0xFF5D3A1A);
  static const Color primaryDark = Color(0xFF3B200A);
  static const Color primaryLight = Color(0xFF8B5A2B);
  static const Color accent = Color(0xFFD4A054);
  static const Color accentLight = Color(0xFFF0C875);
  static const Color background = Color(0xFF1A1008);
  static const Color surface = Color(0xFF2A1A0A);
  static const Color surfaceLight = Color(0xFF3D2610);
  static const Color textPrimary = Color(0xFFF5ECD7);
  static const Color textSecondary = Color(0xFFB8956A);
  static const Color textHint = Color(0xFF7A5C3A);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color cardBorder = Color(0xFF4A2E10);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      onPrimary: textPrimary,
      secondary: accent,
      onSecondary: background,
      surface: surface,
      onSurface: textPrimary,
      error: error,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryDark,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: cardBorder, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: accent,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceLight,
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: const TextStyle(color: textHint),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
      bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
      bodySmall: TextStyle(color: textHint, fontSize: 12),
      labelLarge: TextStyle(
        color: textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme:
    const DividerThemeData(color: cardBorder, thickness: 0.5),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: primaryDark,
      selectedItemColor: accent,
      unselectedItemColor: textHint,
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: accent,
      inactiveTrackColor: surfaceLight,
      thumbColor: accent,
      overlayColor: accent.withOpacity(0.2),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: accent,
      linearTrackColor: surfaceLight,
    ),
  );
}