class LeaderboardResponse {
  final String scope;
  final String? type;
  final List<LeaderboardEntry> leaderboard;

  LeaderboardResponse({
    required this.scope,
    this.type,
    required this.leaderboard,
  });

  factory LeaderboardResponse.fromJson(Map<String, dynamic> json) {
    return LeaderboardResponse(
      scope: json['scope'] ?? '',
      type: json['type'],
      leaderboard: (json['leaderboard'] as List<dynamic>?)
          ?.map((entry) => LeaderboardEntry.fromJson(entry))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scope': scope,
      'type': type,
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
      totalScore: json['score'] ?? json['total_score'] ?? 0, // Try 'score' first, then 'total_score'
      totalStars: json['stars'] ?? json['total_stars'] ?? 0, // Try 'stars' first, then 'total_stars'
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'score': totalScore,
      'stars': totalStars,
    };
  }
} 