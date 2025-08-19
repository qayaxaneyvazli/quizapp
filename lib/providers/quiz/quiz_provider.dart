import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/models/question/api_question.dart';
import 'package:quiz_app/core/services/questions_service.dart';
 
import 'quiz_controller.dart';

// Provider that fetches questions for a specific level
final questionsForLevelProvider = FutureProvider.family<List<QuizQuestion>, int>((ref, levelId) async {
  try {
    final apiQuestions = await QuestionsService.fetchQuestionsForLevel(levelId);
    return apiQuestions.map((apiQuestion) => apiQuestion.toQuizQuestion()).toList();
  } catch (e) {
    print('Error fetching questions for level $levelId: $e');
    // Return empty list as fallback
    return [];
  }
});

// Legacy provider for backward compatibility (returns empty list)
final questionsProvider = Provider<List<QuizQuestion>>((ref) {
  return [];
});


final quizControllerProvider = StateNotifierProvider.autoDispose<QuizController, QuizState>((ref) {
  final questions = ref.watch(questionsProvider);
  return QuizController(questions);
});

// Provider that accepts levelId parameter and fetches questions dynamically
final quizControllerWithLevelProvider = StateNotifierProvider.family<QuizController, QuizState, int>((ref, levelId) {
  final questionsAsync = ref.watch(questionsForLevelProvider(levelId));
  
  return questionsAsync.when(
    data: (questions) => QuizController(questions, levelId: levelId),
    loading: () => QuizController([], levelId: levelId), // Empty questions while loading
    error: (error, stack) => QuizController([], levelId: levelId), // Empty questions on error
  );
});