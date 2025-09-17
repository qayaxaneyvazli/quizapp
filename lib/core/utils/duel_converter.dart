import 'package:quiz_app/models/duel/duel_response.dart';
import 'package:quiz_app/models/question/DuelQuestion.dart';
import 'package:quiz_app/models/question/DuelQuestion.dart' as G;

class DuelConverter {
  // Convert API DuelResponse to list of Questions for game state
static List<G.Question> convertToGameQuestions(
    DuelResponse resp, {
    String lang = 'en',
  }) {
    final duel = resp.duel;
    final items = [...duel.duelQuestions]
      ..sort((a, b) => a.orderNumber.compareTo(b.orderNumber));

    return items.map((dq) {
      final q = dq.question;
      final optionTexts = q.getOptionTexts(lang);      // translations -> option_text
      final correctIdx = q.getCorrectOptionIndex();    // isCorrect == 1 olanın index’i

      return G.Question(
        questionText: q.getQuestionText(lang),         // translations -> question_text
        options: optionTexts,
        correctOptionIndex: correctIdx >= 0 ? correctIdx : 0,
        points: 1,
      );
    }).toList(growable: false);
  }

  // Calculate points based on question level
  static int _calculatePoints(int level) {
    switch (level) {
      case 1:
        return 10;
      case 2:
        return 15;
      case 3:
        return 20;
      case 4:
        return 25;
      case 5:
        return 30;
      default:
        return 10;
    }
  }

  // Get opponent name from duel response
  static String getOpponentName(DuelResponse duelResponse) {
    return duelResponse.opponent.name;
  }

  // Get opponent avatar URL from duel response
  static String getOpponentAvatarUrl(DuelResponse duelResponse) {
    return duelResponse.opponent.avatarUrl;
  }

  // Check if opponent is bot
  static bool isOpponentBot(DuelResponse duelResponse) {
    return duelResponse.isBot;
  }

  // Get duel ID
  static int getDuelId(DuelResponse duelResponse) {
    return duelResponse.duel.id;
  }

  // Get duel question ID by index (for submit-answers API)
  static int getDuelQuestionId(DuelResponse duelResponse, int questionIndex) {
    if (questionIndex < 0 || questionIndex >= duelResponse.duel.duelQuestions.length) {
      return 0;
    }
    return duelResponse.duel.duelQuestions[questionIndex].id;
  }

  // Get question ID by index (for backward compatibility)
  static int getQuestionId(DuelResponse duelResponse, int questionIndex) {
    if (questionIndex < 0 || questionIndex >= duelResponse.duel.duelQuestions.length) {
      return 0;
    }
    return duelResponse.duel.duelQuestions[questionIndex].question.id;
  }

  // Get option ID by question index and option index
  static int getOptionId(DuelResponse duelResponse, int questionIndex, int optionIndex) {
    if (questionIndex < 0 || questionIndex >= duelResponse.duel.duelQuestions.length) {
      return 0;
    }
    
    final question = duelResponse.duel.duelQuestions[questionIndex].question;
    if (optionIndex < 0 || optionIndex >= question.options.length) {
      return 0;
    }
    
    return question.options[optionIndex].id;
  }
}