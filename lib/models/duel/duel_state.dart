 

class DuelState {
  final int? currentQuestionId;              // aktif question_id
  final int currentQIndex;                   // server'dan gelen 1-based q_index
  final Map<int, List<int>> qidToOptionIds;  // question_id -> option_id[] (UI sırası)
  final Map<int, int> orderToQid;            // order_number (1-based) -> question_id
  final String status;
  final DateTime? deadlineAt;
  final Map<String, int> scores;

  const DuelState({
    this.currentQuestionId,
    this.currentQIndex = 0,
    this.qidToOptionIds = const {},
    this.orderToQid = const {},
    this.status = 'ready_wait',
    this.deadlineAt,
    this.scores = const {},
  });

  DuelState copyWith({
    int? currentQuestionId,
    int? currentQIndex,
    Map<int, List<int>>? qidToOptionIds,
    Map<int, int>? orderToQid,
    String? status,
    DateTime? deadlineAt,
    Map<String, int>? scores,
  }) {
    return DuelState(
      currentQuestionId: currentQuestionId ?? this.currentQuestionId,
      currentQIndex: currentQIndex ?? this.currentQIndex,
      qidToOptionIds: qidToOptionIds ?? this.qidToOptionIds,
      orderToQid: orderToQid ?? this.orderToQid,
      status: status ?? this.status,
      deadlineAt: deadlineAt ?? this.deadlineAt,
      scores: scores ?? this.scores,
    );
  }

  int? getOptionIdForIndex(int optionIndex) {
    final qid = currentQuestionId;
    if (qid == null) return null;
    final list = qidToOptionIds[qid];
    if (list == null || optionIndex < 0 || optionIndex >= list.length) return null;
    return list[optionIndex];
  }
}