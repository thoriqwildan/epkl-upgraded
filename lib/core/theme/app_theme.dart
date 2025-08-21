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
    brightness:
        Brightness.dark, // Penting untuk menandakan ini adalah tema gelap
    primaryColor: const Color(
      0xFF85C982,
    ), // Versi hijau yang lebih terang untuk kontras
    scaffoldBackgroundColor: const Color(
      0xFF1A282D,
    ), // Latar belakang utama yang sangat gelap
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6BA368),
      brightness: Brightness.dark, // Pastikan ColorScheme juga dalam mode gelap
      primary: const Color(0xFF85C982), // Hijau terang sebagai warna utama
      secondary: const Color(
        0xFF9CFC97,
      ), // Hijau neon tetap cocok sebagai aksen
      background: const Color(0xFF1A282D), // Warna background utama
      surface: const Color(
        0xFF2C3E3B,
      ), // Warna permukaan (Card, Dialog) sedikit lebih terang
      onPrimary: const Color(
        0xFF0F1F0E,
      ), // Warna teks di atas tombol primer (kontras tinggi)
      onBackground: const Color(0xFFE1E3DE), // Warna teks utama (putih pudar)
      onSurface: const Color(
        0xFFE1E3DE,
      ), // Warna teks di atas permukaan (putih pudar)
      error: const Color(
        0xFFFFB4AB,
      ), // Warna merah yang lebih terang agar terlihat di background gelap
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(
        0xFF2C3E3B,
      ), // Menggunakan warna surface untuk AppBar
      foregroundColor: Color(0xFFE1E3DE), // Warna ikon dan judul di AppBar
      elevation: 1.0,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Color(0xFFE1E3DE)), // Teks default
      bodyLarge: TextStyle(color: Color(0xFFE1E3DE)), // Teks default
      titleMedium: TextStyle(
        color: Color(0xFFCFD2CC),
      ), // Judul dengan kontras sedikit lebih rendah
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF85C982), // Warna primer
        foregroundColor: const Color(0xFF0F1F0E), // Teks di atas tombol
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(
        0xFF2C3E3B,
      ), // Warna surface, konsisten dengan AppBar
      selectedItemColor: Color(0xFF85C982), // Warna primer untuk item aktif
      unselectedItemColor: Colors.grey, // Abu-abu untuk item tidak aktif
    ),
  ),
);

final List<AppTheme> appThemes = [hijauAlamTheme, hijauAlamDarkTheme];
