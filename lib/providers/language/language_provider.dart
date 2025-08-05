// lib/providers/language_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Language state notifier
class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _loadLanguage();
  }

  static const String _languageKey = 'selected_language';

  // SharedPreferences-dan dili yüklə
  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString(_languageKey) ?? 'en';
      state = savedLanguage;
    } catch (e) {
      print('Error loading language: $e');
      state = 'en'; // Default dil
    }
  }

 
  Future<void> setLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
      state = languageCode;
    } catch (e) {
      print('Error saving language: $e');
    }
  }
 
  String get currentLanguage => state;
}
 
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

 
final currentLanguageProvider = Provider<String>((ref) {
  return ref.watch(languageProvider);
});