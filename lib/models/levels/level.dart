 
class LevelModel {
  final int id;
  final String name;
  final String difficulty;
  final int questionCount;
  final int starsEarned;
  final int maxStars;
  final bool isCompleted;
  final bool isLocked;
  final int completionPercent;

  LevelModel({
    required this.id,
    required this.name,
    required this.difficulty,
    required this.questionCount,
    required this.starsEarned,
    required this.maxStars,
    required this.isCompleted,
    required this.isLocked,
    required this.completionPercent,
  });

  factory LevelModel.fromJson(Map<String, dynamic> json) {
    return LevelModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      difficulty: json['difficulty'] ?? 'Easy',
      questionCount: json['questionCount'] ?? 10,
      starsEarned: json['starsEarned'] ?? 0,
      maxStars: json['maxStars'] ?? 3,
      isCompleted: json['isCompleted'] ?? false,
      isLocked: json['isLocked'] ?? true,
      completionPercent: json['completionPercent'] ?? 0,
    );
  }
}