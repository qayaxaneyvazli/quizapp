import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/duel/duel_state.dart';
import 'package:quiz_app/models/duel/duel_response.dart';
class DuelStateNotifier extends StateNotifier<DuelState> {
  DuelStateNotifier() : super(const DuelState());

  /// duel.create cevabından tüm haritaları doldur
  void initializeFromDuelResponse(DuelResponse resp) {
 final duel = resp.duel;
  if (duel == null) return;

  final Map<int,int> orderToQid = {};
  final Map<int,List<int>> qidToOptionIds = {};

  for (final dq in duel.duelQuestions) {
    final q = dq.question;
    if (q == null) continue;
    orderToQid[dq.orderNumber] = q.id;
    qidToOptionIds[q.id] = q.options.map((o) => o.id).toList();
  }

  final firstQuestionId = orderToQid[1]; // ilk sorunun id’si

  state = state.copyWith(
    qidToOptionIds: qidToOptionIds,
    orderToQid: orderToQid,
    status: duel.status,
    currentQIndex: duel.qIndex ?? 0,
    currentQuestionId: firstQuestionId,   // 🔴 ilk soru burada set ediliyor
  );

  print('✅ Mapping hazırlandı: currentQuestionId=$firstQuestionId');
  print('qidToOptionIds=$qidToOptionIds');
  }

  /// duel.update (veya duel.started) ile otorite güncelle
  void updateFromWebSocket(Map<String, dynamic> data) {
    final String status = (data['status'] as String?) ?? state.status;
    final int qIndex = (data['q_index'] as int?) ?? state.currentQIndex; // 1-based
    final Map<String,int> scores = (data['scores'] is Map)
      ? Map<String,int>.from(data['scores'])
      : state.scores;

    DateTime? deadline;
    final dl = data['deadline_at'];
    if (dl is String) {
      deadline = DateTime.tryParse(dl);
    }

    int? questionId = state.currentQuestionId;
    final qObj = data['question'];
    if (qObj is Map) {
      final int? orderNum = qObj['order_number'] as int?;
      final int? qid = qObj['question_id'] as int?;
      // Sunucu zaten question_id yolluyorsa onu kullan
      if (qid != null) {
        questionId = qid;
      } else if (orderNum != null) {
        questionId = state.orderToQid[orderNum];
      }
    } else if (qIndex > 0) {
      // question objesi yoksa order_number = qIndex varsayımıyla çöz
      questionId = state.orderToQid[qIndex] ?? state.currentQuestionId;
    }

    state = state.copyWith(
      status: status,
      currentQIndex: qIndex,
      currentQuestionId: questionId,
      deadlineAt: deadline ?? state.deadlineAt,
      scores: scores,
    );
  }

  /// Yardımcı: 0-based UI indexine çevir
  int? getZeroBasedIndex() {
    if (state.currentQIndex <= 0) return null;
    return state.currentQIndex - 1;
  }
}

final duelStateProvider =
    StateNotifierProvider<DuelStateNotifier, DuelState>((ref) {
  return DuelStateNotifier();
});