// lib/main.dart

import 'package:epkl/core/theme/app_colors.dart';
import 'package:epkl/presentation/ui/pages/auth_checker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  // 1. Jadikan async
  // 2. Baris ini wajib ada sebelum memanggil await sebelum runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inisialisasi data locale untuk Bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // 4. Jalankan aplikasi seperti biasa
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi EPKL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,

        // Skema warna utama aplikasi
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          background: AppColors.background,
          surface: AppColors.background,
          onPrimary: AppColors.white, // Teks/ikon di atas warna primary
          onBackground:
              AppColors.textPrimary, // Teks/ikon di atas warna background
          onSurface: AppColors
              .textPrimary, // Teks/ikon di atas warna surface (misal: Card)
          error: Colors.redAccent, // Warna untuk error
        ),

        // Tema default untuk AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor:
              AppColors.white, // Warna untuk title dan ikon di AppBar
          elevation: 1.0,
        ),

        // Tema default untuk semua teks
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: AppColors.textPrimary),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          titleMedium: TextStyle(color: AppColors.textSecondary),
        ),

        // Tema default untuk Tombol
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Tema default untuk Bottom Navigation Bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.primary,
          selectedItemColor: AppColors.white,
          unselectedItemColor:
              AppColors.white, // Sedikit redup untuk item non-aktif
        ),

        cardTheme: const CardThemeData(color: AppColors.card),
      ),
      home: const AuthCheckerPage(),
    );
  }
}
