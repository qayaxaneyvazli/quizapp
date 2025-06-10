

class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final int points;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.points = 10,
  });
}