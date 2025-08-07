import 'package:quiz_app/models/duel/duel_response.dart';
import 'package:quiz_app/models/question/DuelQuestion.dart';

class DuelConverter {
  // Convert API DuelResponse to list of Questions for game state
  static List<Question> convertToGameQuestions(DuelResponse duelResponse, [String language = 'en']) {
    return duelResponse.duel.duelQuestions.map((duelQuestion) {
      final questionData = duelQuestion.question;
      
      return Question(
        questionText: questionData.getQuestionText(language),
        options: questionData.getOptionTexts(language),
        correctOptionIndex: questionData.getCorrectOptionIndex(),
        points: _calculatePoints(questionData.level),
      );
    }).toList();
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