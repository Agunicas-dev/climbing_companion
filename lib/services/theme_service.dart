import 'package:flutter/material.dart';

/*Service in charge of building the themes for the app based on the user's settings, including theme mode,
font size and seed color. It also includes utility functions to convert between color formats and to get the ThemeMode from a string representation.*/
class ThemeService {
  static ThemeData buildTheme(
    Brightness brightness,
    String fontSize,
    Color seedColor,
  ) {
    // Font size multiplier
    final fontSizeMultiplier = fontSize == 'large'
        ? 1.35
        : fontSize == 'medium'
        ? 1.18
        : 1.0;

    /*Build the ThemeData using Material 3, with a color scheme generated from the seed color and brightness,
    and a text theme that applies the font size multiplier to all text styles.*/
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
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
        bodyLarge: TextStyle(fontSize: 16 * fontSizeMultiplier),
        bodyMedium: TextStyle(fontSize: 14 * fontSizeMultiplier),
        bodySmall: TextStyle(fontSize: 12 * fontSizeMultiplier),
        labelLarge: TextStyle(
          fontSize: 14 * fontSizeMultiplier,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  //Function to get the ThemeMode from a string representation, used when
  //loading the settings to apply the correct theme mode based on the user's preference.
  static ThemeMode themeModeFromString(String themeName) {
    switch (themeName) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  //Function to convert a hex color string to a Color object, used when loading the seed color from the settings to apply it to the theme.
  static Color seedColorFromHex(String hexColor) {
    final buffer = StringBuffer();
    var value = hexColor.trim();
    if (value.startsWith('#')) {
      value = value.substring(1);
    }
    if (value.length == 6) {
      buffer.write('ff');
    }
    buffer.write(value);
    return Color(int.parse(buffer.toString(), radix: 16));
  }
  //Function to convert a Color object to a hex color string, used when saving the seed color to the settings.
  static String colorToHex(Color color) {
    final value = color.toARGB32();
    final r = ((value >> 16) & 0xFF).toRadixString(16).padLeft(2, '0');
    final g = ((value >> 8) & 0xFF).toRadixString(16).padLeft(2, '0');
    final b = (value & 0xFF).toRadixString(16).padLeft(2, '0');
    return '#${r.toUpperCase()}${g.toUpperCase()}${b.toUpperCase()}';
  }
}