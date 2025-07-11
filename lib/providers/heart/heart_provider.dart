
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final heartsProvider = StateNotifierProvider<HeartsNotifier, int>((ref) {
  return HeartsNotifier();
});

class HeartsNotifier extends StateNotifier<int> {
  HeartsNotifier() : super(5); // Start with 5 hearts

  void useHeart() {
    if (state > 0) {
      state = state - 1;
    }
  }

  void addHearts(int amount) {
    state = state + amount;
  }

  void resetHearts() {
    state = 5;
  }
}