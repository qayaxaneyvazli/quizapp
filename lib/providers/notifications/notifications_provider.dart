import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Key for storing notification preference in SharedPreferences
const String _notificationsEnabledKey = 'notifications_enabled';

// Provider to check if notifications are enabled
final notificationsEnabledProvider = StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<bool> {
  NotificationsNotifier() : super(true) {
    _loadPreference();
  }

  // Load saved preference from SharedPreferences
  Future<void> _loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_notificationsEnabledKey) ?? true;
      state = enabled;
    } catch (e) {
      // Fallback to default value if there's an error
    }
  }

  // Save preference to SharedPreferences
  Future<void> _savePreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, value);
    } catch (e) {
      // Handle error if needed
    }
  }

  // Toggle notifications on/off
  Future<void> toggle() async {
    state = !state;
    await _savePreference(state);
    // Here you would add code to register/unregister for Firebase notifications
    // when this is ready
    if (state) {
      // TODO: When Firebase is ready, implement:
      // FirebaseMessaging.instance.requestPermission();
      // FirebaseMessaging.instance.subscribeToTopic('all');
    } else {
      // TODO: When Firebase is ready, implement:
      // FirebaseMessaging.instance.unsubscribeFromTopic('all');
    }
  }

  // Set notifications explicitly to a value
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (state != enabled) {
      state = enabled;
      await _savePreference(state);
      // Similar Firebase logic would go here
    }
  }
}