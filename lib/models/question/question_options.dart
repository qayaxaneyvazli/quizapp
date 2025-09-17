import 'package:quiz_app/models/duel/duel_response.dart';

class QuestionOption {
  final int id;
  final String text;
  final int isCorrect; // bool yerine int yapın (0 veya 1)
  final int questionId;
  final String createdAt;
  final String updatedAt;
  final List<OptionTranslation> translations;

  QuestionOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.questionId,
    required this.createdAt,
    required this.updatedAt,
    required this.translations,
  });

  // Dil bazında text almak için
  String getText([String language = 'en']) {
    try {
      final translation = translations.firstWhere(
        (t) => t.language == language,
        orElse: () => translations.isNotEmpty ? translations.first : 
          throw Exception('No translation found'),
      );
      return translation.optionText;
    } catch (e) {
      return text; // Fallback
    }
  }

  // Helper method - doğru cevap mı kontrol et
  bool get isCorrectAnswer => isCorrect == 1;
}