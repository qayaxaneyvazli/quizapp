import 'package:quiz_app/models/duel/duel_response.dart';

class OptionMapper {
  final DuelResponse duelResponse;
  
  OptionMapper(this.duelResponse);
  
  /// Option ID'den option index'e çevir
  int? getOptionIndexFromId(int questionId, int optionId) {
    try {
      // Question'ı bul
      final duelQuestion = duelResponse.duel.duelQuestions.firstWhere(
        (dq) => dq.question.id == questionId,
      );
      
      // Option'ları kontrol et
      final options = duelQuestion.question.options;
      for (int i = 0; i < options.length; i++) {
        if (options[i].id == optionId) {
          return i;
        }
      }
      
      return null; // Option bulunamadı
      
    } catch (e) {
      print('Error mapping option ID to index: $e');
      return null;
    }
  }
    int? getQuestionIdFromOrder(int orderNumber) {
    try {
      final duelQuestion = duelResponse.duel.duelQuestions.firstWhere(
        (dq) => dq.orderNumber == orderNumber,
      );
      return duelQuestion.question.id;
    } catch (e) {
      print('Error getting question ID from order: $e');
      return null;
    }
  }
}