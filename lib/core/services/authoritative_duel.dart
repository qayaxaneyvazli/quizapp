// 1) Otoritatif durumu temsil eden model
import 'package:quiz_app/models/duel/duel_response.dart';

class DuelWireState {
  final int duelId;
  final String status;                // running | ready_wait | finished
  final int qIndex;                   // 1-based
  final int? currentQuestionId;
  final Map<String,int> scores;
  final DateTime? deadlineAt;
  final int stateVersion;             // her güncellemede +1

  DuelWireState({
    required this.duelId,
    required this.status,
    required this.qIndex,
    required this.currentQuestionId,
    required this.scores,
    required this.deadlineAt,
    required this.stateVersion,
  });
}

// 2) Otorite cache (duelId -> state + mappingler)
class AuthoritativeDuelStore {
  final Map<int, DuelWireState> _states = {};
  final Map<int, Map<int, List<int>>> _qidToOptionIds = {}; // duelId -> (question_id -> option_id[])
  final Map<int, Map<int, int>> _orderToQid = {};           // duelId -> (order_number -> question_id)
  final Map<int, int> _versions = {};                       // duelId -> version

void preloadFromCreate(DuelResponse resp) {
  final duelId = resp.duel.id;

  // order_number -> qid
  final Map<int, int> orderToQid = {};
  final Map<int, List<int>> qidToOptionIds = {};

  for (final dq in resp.duel.duelQuestions) {
    final q = dq.question;
    orderToQid[dq.orderNumber] = q.id;
    qidToOptionIds[q.id] = q.options.map((o) => o.id).toList(growable: false);
  }

  _orderToQid[duelId] = orderToQid;
  _qidToOptionIds[duelId] = qidToOptionIds;

  // 🔑 İlk sorunun id’sini al (order 1 → qid)
  final firstQid = orderToQid[1];

  _versions[duelId] = 0;
  _states[duelId] = DuelWireState(
    duelId: duelId,
    status: resp.duel.status,
    qIndex: resp.duel.qIndex ?? 0,
    currentQuestionId: firstQid, // ✅ artık null değil
    scores: const {},
    deadlineAt: null,
    stateVersion: 0,
  );

  print('✅ preloadFromCreate called for duelId=$duelId');
  print('qidToOptionIds=$qidToOptionIds');
  print('✅ Mapping hazırlandı: currentQuestionId=$firstQid');
}


  DuelWireState applyWs(int duelId, Map<String, dynamic> data) {
    final prev = _states[duelId];
    final nextVersion = (_versions[duelId] ?? 0) + 1;
    _versions[duelId] = nextVersion;

    final status = (data['status'] as String?) ?? prev?.status ?? 'ready_wait';
    final qIdx = (data['q_index'] as int?) ?? prev?.qIndex ?? 0;

    DateTime? deadline = prev?.deadlineAt;
    final dl = data['deadline_at'];
    if (dl is String) deadline = DateTime.tryParse(dl);

    int? questionId = prev?.currentQuestionId;
    final qObj = data['question'];
    if (qObj is Map) {
      final int? qid = qObj['question_id'] as int?;
      final int? ord = qObj['order_number'] as int?;
      if (qid != null) {
        questionId = qid;
      } else if (ord != null) {
        final ordMap = _orderToQid[duelId] ?? const {};
        questionId = ordMap[ord] ?? questionId;
      }
    } else if (questionId == null && qIdx > 0) {
      final ordMap = _orderToQid[duelId] ?? const {};
      questionId = ordMap[qIdx] ?? questionId;
    }

    final scores = (data['scores'] is Map)
        ? Map<String,int>.from(data['scores'])
        : (prev?.scores ?? const {});

    final next = DuelWireState(
      duelId: duelId,
      status: status,
      qIndex: qIdx,
      currentQuestionId: questionId,
      scores: scores,
      deadlineAt: deadline,
      stateVersion: nextVersion,
    );
    _states[duelId] = next;
    return next;
  }

  DuelWireState? snapshot(int duelId) => _states[duelId];

  /// UI index (0-based) -> option_id
  int? optionIdForUiIndex(int duelId, int uiOptionIndex) {
    final st = _states[duelId];
    if (st == null || st.currentQuestionId == null) return null;
    final map = _qidToOptionIds[duelId] ?? const {};
    final list = map[st.currentQuestionId];
    if (list == null) return null;
    if (uiOptionIndex < 0 || uiOptionIndex >= list.length) return null;
    return list[uiOptionIndex];
  }
}