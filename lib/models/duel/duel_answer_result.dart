class DuelAnswerResult {
  final int duelId;
  final int orderNumber;
  final int answeredBy;
  final int optionId;
  final bool isCorrect;
  final Map<String, int> scores;

  DuelAnswerResult({
    required this.duelId,
    required this.orderNumber,
    required this.answeredBy,
    required this.optionId,
    required this.isCorrect,
    required this.scores,
  });

  factory DuelAnswerResult.fromJson(Map<String, dynamic> json) {
    // result objesi içindeki verileri al
    final result = json['result'] ?? json;
    
    return DuelAnswerResult(
      duelId: result['duel_id'] ?? 0,
      orderNumber: result['order_number'] ?? 0,
      answeredBy: result['answered_by'] ?? 0,
      optionId: result['option_id'] ?? 0,
      isCorrect: result['is_correct'] ?? false,
      scores: Map<String, int>.from(result['scores'] ?? {}),
    );
  }

  bool isMyAnswer(int currentUserId) => answeredBy == currentUserId;
}