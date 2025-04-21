import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider to store the current theme mode
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemePreference();
  }

  // Load saved theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  // Save theme preference
  Future<void> _saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  // Toggle between light and dark mode
  void toggle() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    _saveThemePreference(state == ThemeMode.dark);
  }

  // Set specific theme mode
  void setThemeMode(ThemeMode mode) {
    state = mode;
    _saveThemePreference(mode == ThemeMode.dark);
  }
}