import 'package:flutter_riverpod/flutter_riverpod.dart';

class JokerCount {
  final int freeCount;
  final int extraCount;

  JokerCount({required this.freeCount, required this.extraCount});

  int get totalCount => freeCount + extraCount;

  JokerCount copyWith({int? freeCount, int? extraCount}) {
    return JokerCount(
      freeCount: freeCount ?? this.freeCount,
      extraCount: extraCount ?? this.extraCount,
    );
  }
}

class JokerState {
  final JokerCount hint;
  final JokerCount fiftyFifty;
  final JokerCount timePause;
  final JokerCount showCorrect;
  final DateTime lastResetTime;

  JokerState({
    required this.hint,
    required this.fiftyFifty,
    required this.timePause,
    required this.showCorrect,
    required this.lastResetTime,
  });

  JokerState copyWith({
    JokerCount? hint,
    JokerCount? fiftyFifty,
    JokerCount? timePause,
    JokerCount? showCorrect,
    DateTime? lastResetTime,
  }) {
    return JokerState(
      hint: hint ?? this.hint,
      fiftyFifty: fiftyFifty ?? this.fiftyFifty,
      timePause: timePause ?? this.timePause,
      showCorrect: showCorrect ?? this.showCorrect,
      lastResetTime: lastResetTime ?? this.lastResetTime,
    );
  }
}

class JokerController extends StateNotifier<JokerState> {
  static const int freeDefault = 5;

  JokerController()
      : super(JokerState(
          hint: JokerCount(freeCount: freeDefault, extraCount: 0),
          fiftyFifty: JokerCount(freeCount: freeDefault, extraCount: 0),
          timePause: JokerCount(freeCount: freeDefault, extraCount: 0),
          showCorrect: JokerCount(freeCount: freeDefault, extraCount: 0),
          lastResetTime: DateTime.now(),
        ));

  // Joker kullanımı: önce free hakkı, free biterse extra'dan düşülür.
  void useJoker(String type) {
    _resetIfNeeded();
    switch (type) {
      case 'hint':
        state = state.copyWith(
          hint: _decrementJokerCount(state.hint),
        );
        break;
      case 'fiftyFifty':
        state = state.copyWith(
          fiftyFifty: _decrementJokerCount(state.fiftyFifty),
        );
        break;
      case 'timePause':
        state = state.copyWith(
          timePause: _decrementJokerCount(state.timePause),
        );
        break;
      case 'showCorrect':
        state = state.copyWith(
          showCorrect: _decrementJokerCount(state.showCorrect),
        );
        break;
      default:
        break;
    }
  }

  JokerCount _decrementJokerCount(JokerCount jokerCount) {
    if (jokerCount.freeCount > 0) {
      return jokerCount.copyWith(freeCount: jokerCount.freeCount - 1);
    } else if (jokerCount.extraCount > 0) {
      return jokerCount.copyWith(extraCount: jokerCount.extraCount - 1);
    } else {
      // Yeterli hak kalmadı.
      return jokerCount;
    }
  }

  // Reklam izleyip/para ile ekstra joker eklemek için
  void addExtra(String type, int amount) {
    _resetIfNeeded();
    switch (type) {
      case 'hint':
        state = state.copyWith(
          hint: state.hint.copyWith(extraCount: state.hint.extraCount + amount),
        );
        break;
      case 'fiftyFifty':
        state = state.copyWith(
          fiftyFifty:
              state.fiftyFifty.copyWith(extraCount: state.fiftyFifty.extraCount + amount),
        );
        break;
      case 'timePause':
        state = state.copyWith(
          timePause:
              state.timePause.copyWith(extraCount: state.timePause.extraCount + amount),
        );
        break;
      case 'showCorrect':
        state = state.copyWith(
          showCorrect:
              state.showCorrect.copyWith(extraCount: state.showCorrect.extraCount + amount),
        );
        break;
      default:
        break;
    }
  }

  // Günlük reset: Eğer 24 saat geçtiyse, free hakları default'a (5) sıfırlıyoruz.
  void _resetIfNeeded() {
    final now = DateTime.now();
    final diff = now.difference(state.lastResetTime);
    if (diff.inHours >= 24) {
      state = state.copyWith(
        hint: state.hint.copyWith(freeCount: freeDefault),
        fiftyFifty: state.fiftyFifty.copyWith(freeCount: freeDefault),
        timePause: state.timePause.copyWith(freeCount: freeDefault),
        showCorrect: state.showCorrect.copyWith(freeCount: freeDefault),
        lastResetTime: now,
      );
    }
  }
}

final jokerProvider = StateNotifierProvider<JokerController, JokerState>((ref) {
  return JokerController();
});
