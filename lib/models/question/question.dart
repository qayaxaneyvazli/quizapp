class QuizQuestion {
  final int id;          // <--- Yeni eklendi
  final String question;
  final String? imagePath;
  final List<String> options;
  final int correctAnswerIndex;
  final String answer;   // <--- Yeni eklendi (Metin olarak cevap)
  final bool isTrueFalse;

  QuizQuestion({
    required this.id,    // <--- Constructor'a eklendi
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.answer, // <--- Constructor'a eklendi
    this.isTrueFalse = false,
    this.imagePath,
  });

  // API'den gelen JSON verisini bu modele çevirmek için:
  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      imagePath: json['image_path'], // API'deki isme göre değişebilir
      // Options API'den liste olarak geliyorsa:
      options: List<String>.from(json['options'] ?? []),
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
      answer: json['answer'] ?? '',
      isTrueFalse: json['is_true_false'] ?? false,
    );
  }
}