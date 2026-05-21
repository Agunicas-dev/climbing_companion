import 'package:flutter/material.dart';

class ThemeService {
  static Future<ThemeData> buildTheme(String themeName, String fontSize) async {
    final isDark = themeName == 'dark';
    final isLight = themeName == 'light';
    
    final brightness = (!isDark && !isLight)
        ? Brightness.light // Default to light if 'system'
        : isDark
            ? Brightness.dark
            : Brightness.light;

    // Font size multiplier
    final fontSizeMultiplier = fontSize == 'small'
        ? 0.85
        : fontSize == 'large'
            ? 1.15
            : 1.0;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: brightness,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontSize: 32 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          fontSize: 28 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          fontSize: 24 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          fontSize: 20 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          fontSize: 18 * fontSizeMultiplier,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          fontSize: 16 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          fontSize: 16 * fontSizeMultiplier,
        ),
        bodyMedium: TextStyle(
          fontSize: 14 * fontSizeMultiplier,
        ),
        bodySmall: TextStyle(
          fontSize: 12 * fontSizeMultiplier,
        ),
        labelLarge: TextStyle(
          fontSize: 14 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
