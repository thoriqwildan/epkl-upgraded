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
        primaryColor: AppColors.primaryColor,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryColor),
        scaffoldBackgroundColor: AppColors.background,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.primaryColor,
          selectedItemColor: AppColors.white,
          unselectedItemColor: AppColors.white,
        ),
      ),
      home: const AuthCheckerPage(),
    );
  }
}
