import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode');
      if (savedTheme != null) {
        state = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      }
    } catch (e) {
      // Fallback to light theme if there's an error
      state = ThemeMode.light;
    }
  }

  // Save theme preference
  Future<void> _saveThemePreference(ThemeMode mode) async {
    try {
      /* final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'theme_mode', mode == ThemeMode.dark ? 'dark' : 'light'); */
    } catch (e) {
      // Ignore errors when saving preferences
    }
  }

  void toggleTheme() {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = newMode;
    _saveThemePreference(newMode);
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveThemePreference(mode);
  }
}

// Theme mode provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Light theme with modern colors
ThemeData getLightTheme() {
  // Light theme colors as specified
  const primaryColor = Color(0xFF4A90E2); // Blue
  const secondaryColor = Color(0xFF50E3C2); // Turquoise
  const backgroundColor = Color(0xFFF5F7FA); // Soft Grayish White
  const surfaceColor = Color(0xFFFFFFFF); // Pure White
  const textPrimaryColor = Color(0xFF2C3E50); // Dark Blue Gray
  const textSecondaryColor = Color(0xFF7F8C8D); // Muted Gray
  const errorColor = Color(0xFFD32F2F); // Red

  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: Colors.white,
    secondary: secondaryColor,
    onSecondary: Colors.black,
    error: errorColor,
    onError: Colors.white,
    surface: surfaceColor,
    onSurface: textPrimaryColor,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: surfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: textSecondaryColor.withAlpha(100), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: textSecondaryColor.withAlpha(100), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      filled: true,
      fillColor: surfaceColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textSecondaryColor),
    ),
    textTheme: const TextTheme(
      headlineMedium:
          TextStyle(fontWeight: FontWeight.bold, color: textPrimaryColor),
      titleLarge:
          TextStyle(fontWeight: FontWeight.w600, color: textPrimaryColor),
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
    ),
    iconTheme: const IconThemeData(
      color: primaryColor,
    ),
  );
}

// Dark theme with modern colors
ThemeData getDarkTheme() {
  // Dark theme colors as specified
  const primaryColor = Color(0xFF64B5F6); // Light Blue
  const secondaryColor = Color(0xFF26A69A); // Teal
  const backgroundColor = Color(0xFF121212); // Deep Black
  const surfaceColor = Color(0xFF1E1E1E); // Dark Gray
  const textPrimaryColor = Color(0xFFECEFF1); // Light Gray
  const textSecondaryColor = Color(0xFFB0BEC5); // Muted Blue-Gray
  const errorColor = Color(0xFFEF5350); // Light Red
  const inputFillColor =
      Color(0xFF2C2C2C); // Slightly lighter than surface for better contrast

  const colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryColor,
    onPrimary: Colors.black,
    secondary: secondaryColor,
    onSecondary: Colors.black,
    error: errorColor,
    onError: Colors.black,
    surface: surfaceColor,
    onSurface: textPrimaryColor,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      centerTitle: true,
      backgroundColor: surfaceColor,
      foregroundColor: textPrimaryColor,
    ),
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: surfaceColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.black,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: textSecondaryColor.withAlpha(100), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: textSecondaryColor.withAlpha(100), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: primaryColor, width: 1.5),
      ),
      filled: true,
      fillColor: inputFillColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: textSecondaryColor),
    ),
    textTheme: const TextTheme(
      headlineMedium:
          TextStyle(fontWeight: FontWeight.bold, color: textPrimaryColor),
      titleLarge:
          TextStyle(fontWeight: FontWeight.w600, color: textPrimaryColor),
      bodyLarge: TextStyle(color: textPrimaryColor),
      bodyMedium: TextStyle(color: textPrimaryColor),
    ),
    iconTheme: const IconThemeData(
      color: primaryColor,
    ),
  );
}
