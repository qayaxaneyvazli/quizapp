import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

class UserProfile {
  final int stars;
  final int hearts;
  final int coins;
  final String avatarUrl;
  final String countryCode;
  final String username;
  final String userId;

  UserProfile({
    this.stars = 1000,
    this.hearts = 5,
    this.coins = 2500,
    this.avatarUrl = '',
    this.countryCode = 'AZ',
    this.username = '',
    this.userId = '1234567890',
  });

  UserProfile copyWith({
    int? stars,
    int? hearts,
    int? coins,
    String? avatarUrl,
    String? countryCode,
    String? username,
    String? userId,
  }) {
    return UserProfile(
      stars: stars ?? this.stars,
      hearts: hearts ?? this.hearts,
      coins: coins ?? this.coins,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      countryCode: countryCode ?? this.countryCode,
      username: username ?? this.username,
      userId: userId ?? this.userId,
    );
  }
}