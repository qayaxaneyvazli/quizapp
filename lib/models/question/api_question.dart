// Import the existing QuizQuestion model
import 'question.dart';

class ApiQuestion {
  final int id;
  final String type;
  final int levelId;
  final int categoryId;
  final String questionText;
  final String info;
  final String imageUrl;
  final List<ApiQuestionOption> options;

  ApiQuestion({
    required this.id,
    required this.type,
    required this.levelId,
    required this.categoryId,
    required this.questionText,
    required this.info,
    required this.imageUrl,
    required this.options,
  });

  factory ApiQuestion.fromJson(Map<String, dynamic> json) {
    return ApiQuestion(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'mcq',
      levelId: json['level_id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      questionText: json['question_text'] ?? '',
      info: json['info'] ?? '',
      imageUrl: json['image_url'] ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((option) => ApiQuestionOption.fromJson(option))
              .toList() ??
          [],
    );
  }

  // Convert to QuizQuestion for compatibility with existing quiz logic
  QuizQuestion toQuizQuestion() {
    // Find the correct answer index
    int correctAnswerIndex = 0;
    for (int i = 0; i < options.length; i++) {
      if (options[i].isCorrect == 1) {
        correctAnswerIndex = i;
        break;
      }
    }

    return QuizQuestion(
      question: questionText,
      options: options.map((option) => option.optionText).toList(),
      correctAnswerIndex: correctAnswerIndex,
      isTrueFalse: type == 'true_false',
      imagePath: imageUrl.isNotEmpty ? imageUrl : null,
    );
  }
}

class ApiQuestionOption {
  final int id;
  final int isCorrect;
  final String optionText;

  ApiQuestionOption({
    required this.id,
    required this.isCorrect,
    required this.optionText,
  });

  factory ApiQuestionOption.fromJson(Map<String, dynamic> json) {
    return ApiQuestionOption(
      id: json['id'] ?? 0,
      isCorrect: json['is_correct'] ?? 0,
      optionText: json['option_text'] ?? '',
    );
  }
} 