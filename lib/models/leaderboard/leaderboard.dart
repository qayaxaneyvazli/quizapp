class LeaderboardResponse {
  final String scope;
  final List<LeaderboardEntry> leaderboard;

  LeaderboardResponse({
    required this.scope,
    required this.leaderboard,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      scope: json['scope'] ?? '',
      leaderboard: (json['leaderboard'] as List<dynamic>?)
          ?.map((entry) => LeaderboardEntry.fromJson(entry))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scope': scope,
      'leaderboard': leaderboard.map((entry) => entry.toJson()).toList(),
    };
  }
}

class LeaderboardEntry {
  final int userId;
  final String name;
  final int totalScore;
  final int totalStars;

  LeaderboardEntry({
    required this.userId,
    required this.name,
    required this.totalScore,
    required this.totalStars,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      totalScore: json['total_score'] ?? 0,
      totalStars: json['total_stars'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'total_score': totalScore,
      'total_stars': totalStars,
    };
  }
} 