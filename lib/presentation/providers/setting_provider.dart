// lib/presentation/providers/settings_provider.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. Model yang menampung SEMUA pengaturan
class AppSettings {
  final bool isLocationCheckDisabled;
  final bool isDateManipulationEnabled;

  const AppSettings({
    this.isLocationCheckDisabled = false,
    this.isDateManipulationEnabled = false,
  });

  AppSettings copyWith({
    bool? isLocationCheckDisabled,
    bool? isDateManipulationEnabled,
  }) {
    return AppSettings(
      isLocationCheckDisabled:
          isLocationCheckDisabled ?? this.isLocationCheckDisabled,
      isDateManipulationEnabled:
          isDateManipulationEnabled ?? this.isDateManipulationEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'isLocationCheckDisabled': isLocationCheckDisabled,
    'isDateManipulationEnabled': isDateManipulationEnabled,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    isLocationCheckDisabled: json['isLocationCheckDisabled'] ?? false,
    isDateManipulationEnabled: json['isDateManipulationEnabled'] ?? false,
  );
}

// 2. Notifier sekarang dideklarasikan untuk mengelola objek 'AppSettings'
class SettingsNotifier extends StateNotifier<AppSettings> {
  // 3. Nilai awal yang diberikan ke super() juga sebuah objek 'AppSettings'
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('app_settings');
    if (settingsJson != null) {
      if (mounted) {
        state = AppSettings.fromJson(jsonDecode(settingsJson));
      }
    }
  }

  Future<void> _saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_settings', jsonEncode(settings.toJson()));
    state = settings;
  }

  void setLocationCheckEnabled(bool isEnabled) {
    _saveSettings(state.copyWith(isLocationCheckDisabled: isEnabled));
  }

  void setDateManipulationEnabled(bool isEnabled) {
    _saveSettings(state.copyWith(isDateManipulationEnabled: isEnabled));
  }
}

// 4. Provider juga dideklarasikan dengan tipe 'AppSettings'
final settingsNotifierProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
      return SettingsNotifier();
    });
