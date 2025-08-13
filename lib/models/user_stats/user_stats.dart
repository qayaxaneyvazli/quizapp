class UserStats {
  final int id;
  final String name;
  final String avatarUrl;
  final int coins;
  final String heartsCount;
  final int jokerFiftyFifty;
  final int jokerFreezeTime;
  final int jokerWrongAnswer;
  final int jokerTrueAnswer;
  final int ticketEvent;
  final int ticketReplay;
  final int ticketDuel;
  final String heartsInfiniteUntil;

  UserStats({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.coins,
    required this.heartsCount,
    required this.jokerFiftyFifty,
    required this.jokerFreezeTime,
    required this.jokerWrongAnswer,
    required this.jokerTrueAnswer,
    required this.ticketEvent,
    required this.ticketReplay,
    required this.ticketDuel,
    required this.heartsInfiniteUntil,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      coins: json['coins'] ?? 0,
      heartsCount: json['hearts']?.toString() ?? '0',
      jokerFiftyFifty: json['joker_fifty_fifty'] ?? 0,
      jokerFreezeTime: json['joker_freeze_time'] ?? 0,
      jokerWrongAnswer: json['joker_wrong_answer'] ?? 0,
      jokerTrueAnswer: json['joker_true_answer'] ?? 0,
      ticketEvent: json['ticket_event'] ?? 0,
      ticketReplay: json['ticket_replay'] ?? 0,
      ticketDuel: json['ticket_duel'] ?? 0,
      heartsInfiniteUntil: json['hearts_infinite_until'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'coins': coins,
      'hearts': heartsCount,
      'joker_fifty_fifty': jokerFiftyFifty,
      'joker_freeze_time': jokerFreezeTime,
      'joker_wrong_answer': jokerWrongAnswer,
      'joker_true_answer': jokerTrueAnswer,
      'ticket_event': ticketEvent,
      'ticket_replay': ticketReplay,
      'ticket_duel': ticketDuel,
      'hearts_infinite_until': heartsInfiniteUntil,
    };
  }

  // Helper method to get hearts display value
  int get heartsDisplayValue {
    if (heartsCount.toLowerCase() == 'infinite') {
      return 999; // Display as high number for infinite
    }
    return int.tryParse(heartsCount) ?? 0;
  }

  // Helper method to check if hearts are infinite
  bool get hasInfiniteHearts {
    return heartsCount.toLowerCase() == 'infinite';
  }

  // Helper method to get remaining time for infinite hearts
  Duration? get infiniteHeartsRemainingTime {
    if (hasInfiniteHearts && heartsInfiniteUntil.isNotEmpty) {
      try {
        final infiniteUntilDate = DateTime.parse(heartsInfiniteUntil);
        final now = DateTime.now();
        if (infiniteUntilDate.isAfter(now)) {
          return infiniteUntilDate.difference(now);
        }
      } catch (e) {
        print('❌ Failed to parse hearts_infinite_until date for duration: $heartsInfiniteUntil');
      }
    }
    return null;
  }

  // Helper method to format remaining infinite hearts time as string (HH:MM:SS)
  String get infiniteHeartsTimeString {
    final remainingTime = infiniteHeartsRemainingTime;
    if (remainingTime != null) {
      final hours = remainingTime.inHours;
      final minutes = remainingTime.inMinutes % 60;
      final seconds = remainingTime.inSeconds % 60;
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '';
  }
}