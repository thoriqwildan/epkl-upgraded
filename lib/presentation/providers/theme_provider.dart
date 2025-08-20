// lib/presentation/providers/theme_provider.dart

import 'package:epkl/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeNameKey = 'app_theme_name';

class ThemeNotifier extends StateNotifier<AppTheme> {
  ThemeNotifier() : super(hijauAlamTheme) {
    // Set tema default
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString(_themeNameKey);

    // Cari tema di list berdasarkan nama yang tersimpan
    final theme = appThemes.firstWhere(
      (t) => t.name == themeName,
      orElse: () => hijauAlamTheme, // Jika tidak ketemu, gunakan default
    );
    state = theme;
  }

  void setTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();

    final theme = appThemes.firstWhere(
      (t) => t.name == themeName,
      orElse: () => hijauAlamTheme,
    );

    await prefs.setString(_themeNameKey, themeName);
    state = theme;
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, AppTheme>((
  ref,
) {
  return ThemeNotifier();
});
