// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // #E6FAFC -> Warna utama untuk background aplikasi
  static const Color background = Color(0xFF111827);

  // #9CFC97 -> Warna cerah untuk aksen, highlight, atau status sukses
  static const Color accent = Color(0xFFFACC15);

  // #6BA368 -> Warna utama brand untuk AppBar, Tombol, dll.
  static const Color primary = Color(0xFF1F2937);

  // #515B3A -> Warna teks sekunder atau border
  static const Color textSecondary = Color(0xFF9CA3AF);

  // #353D2F -> Warna teks utama yang lebih lembut dari hitam pekat
  static const Color textPrimary = Color(0xFFE5E7EB);

  // Kita tetap butuh warna putih untuk teks di atas background gelap
  static const Color white = Colors.white;

  static const Color card = Color(0xFF1F2937);
}
