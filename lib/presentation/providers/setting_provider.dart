import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _locationCheckKey = 'isLocationCheckEnabled';

class SettingsNotifier extends StateNotifier<bool> {
  SettingsNotifier() : super(true) {
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_locationCheckKey) ?? true;
  }

  Future<void> setLocationCheckEnabled(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_locationCheckKey, isEnabled);
    state = isEnabled;
  }
}

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, bool>((
  ref,
) {
  return SettingsNotifier();
});
