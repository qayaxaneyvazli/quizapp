import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/question/question.dart';
 
import 'quiz_controller.dart';


final questionsProvider = Provider<List<QuizQuestion>>((ref) {
  // Sample questions
  return [
    QuizQuestion(
      question: 'What is the capital of Azerbaijan?',
      options: ['Baku', 'Ankara', 'Tbilisi', 'Yerevan'],
      correctAnswerIndex: 0,
    ),
    QuizQuestion(
      question: 'Which river is the longest in the world?',
      options: ['Amazon', 'Nile', 'Mississippi', 'Yangtze'],
      correctAnswerIndex: 1,
    ),
    QuizQuestion(
      question: 'Who painted the Mona Lisa?',
      options: ['Van Gogh', 'Picasso', 'Da Vinci', 'Michelangelo'],
      correctAnswerIndex: 2,
    ),
       QuizQuestion(
      question: 'Who coded you?',
      options: ['Chat Gpt', 'Qayaxan Eyvazli', 'Elon Musk', 'Mark Zuckerberg'],
      correctAnswerIndex: 1,
    ),
        QuizQuestion(
      question: 'President of America?',
      options: ['Trump', 'Biden', 'Bush', 'Obama'],
      correctAnswerIndex: 1,
    )
    
  ];
});


final quizControllerProvider = StateNotifierProvider<QuizController, QuizState>((ref) {
  final questions = ref.watch(questionsProvider);
  return QuizController(questions);
});