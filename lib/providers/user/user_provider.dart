
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/models/user_profile/user_profile.dart';
// User profile state provider
final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});



class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier() : super(UserProfile());

  void updateUsername(String username) {
    state = state.copyWith(username: username);
  }

  void updateAvatar(String avatarUrl) {
    state = state.copyWith(avatarUrl: avatarUrl);
  }

  void updateCountryCode(String countryCode) {
    state = state.copyWith(countryCode: countryCode);
  }
}