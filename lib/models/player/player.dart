class Player {
  final String avatarUrl;
  final String countryCode;
  final String username;
  int score;

  Player({
    required this.avatarUrl,
    required this.countryCode,
    required this.username,
    this.score = 0,
  });

  // Eksik olan copyWith metodu
  Player copyWith({
    String? avatarUrl,
    String? countryCode,
    String? username,
    int? score,
  }) {
    return Player(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      countryCode: countryCode ?? this.countryCode,
      username: username ?? this.username,
      score: score ?? this.score,
    );
  }
}