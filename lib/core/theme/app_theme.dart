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

final List<AppTheme> appThemes = [hijauAlamTheme];
