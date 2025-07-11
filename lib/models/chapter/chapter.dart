class ChapterModel {
  final int id;
  final String name;
  final int earnedCoins;
  final int maxCoins;
  final int earnedStars;
  final int maxStars;
  final int completionPercent;
  final int starsOutOf5;
  final String iconUrl;

  ChapterModel({
    required this.id,
    required this.name,
    required this.earnedCoins,
    required this.maxCoins,
    required this.earnedStars,
    required this.maxStars,
    required this.completionPercent,
    required this.starsOutOf5,
    required this.iconUrl,
  });

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      earnedCoins: json['earned_coins'] ?? 0,
      maxCoins: json['max_coins'] ?? 0,
      earnedStars: json['earned_stars'] ?? 0,
      maxStars: json['max_stars'] ?? 0,
      completionPercent: json['completion_percent'] ?? 0,
      starsOutOf5: json['stars_out_of_5'] ?? 0,
      iconUrl: json['icon_url'] ?? '',
    );
  }
}