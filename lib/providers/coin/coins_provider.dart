import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoinsNotifier extends StateNotifier<int> {
  CoinsNotifier() : super(0);

  void add(int amount) => state += amount;
  void reset()        => state  = 0;
}

final coinsProvider =
    StateNotifierProvider<CoinsNotifier, int>((ref) => CoinsNotifier());
