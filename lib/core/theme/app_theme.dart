import 'package:flutter/material.dart';

class AppTheme {
  final String name;
  final ThemeData themeData;

  const AppTheme({required this.name, required this.themeData});
}

final AppTheme hijauAlamTheme = AppTheme(
  name: 'Hijau Alam',
  themeData: ThemeData(
    useMaterial3: true,
    primaryColor: const Color(0xFF6BA368),
    scaffoldBackgroundColor: const Color(0xFFE6FAFC),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6BA368),
      primary: const Color(0xFF6BA368),
      secondary: const Color(0xFF9CFC97),
      background: const Color(0xFFE6FAFC),
      surface: Colors.white,
      onPrimary: Colors.white,
      onBackground: const Color(0xFF353D2F),
      onSurface: const Color(0xFF353D2F),
      error: Colors.redAccent,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF6BA368),
      foregroundColor: Colors.white,
      elevation: 1.0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFF353D2F)),
      bodyLarge: TextStyle(color: Color(0xFF353D2F)),
      titleMedium: TextStyle(color: Color(0xFF515B3A)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6BA368),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF6BA368),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
    ),
  ),
);

final AppTheme hijauAlamDarkTheme = AppTheme(
  name: 'Hijau Alam (Gelap)',
  themeData: ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: const Color(0xFF85C982),
    scaffoldBackgroundColor: const Color(0xFF1A282D),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6BA368),
      brightness: Brightness.dark,
      primary: const Color(0xFF85C982),
      secondary: const Color(0xFF9CFC97),
      background: const Color(0xFF1A282D),
      surface: const Color(0xFF2C3E3B),
      onPrimary: const Color(0xFF0F1F0E),
      onBackground: const Color(0xFFE1E3DE),
      onSurface: const Color(0xFFE1E3DE),
      error: const Color(0xFFFFB4AB),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2C3E3B),
      foregroundColor: Color(0xFFE1E3DE),
      elevation: 1.0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFFE1E3DE)),
      bodyLarge: TextStyle(color: Color(0xFFE1E3DE)),
      titleMedium: TextStyle(color: Color(0xFFCFD2CC)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF85C982),
        foregroundColor: const Color(0xFF0F1F0E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF2C3E3B),
      selectedItemColor: Color(0xFF85C982),
      unselectedItemColor: Colors.grey,
    ),
  ),
);

final List<AppTheme> appThemes = [hijauAlamTheme, hijauAlamDarkTheme];
