import 'package:quiz_app/models/question/DuelQuestion.dart';

class GameState {
  final List<bool?> player1Results; // null means not answered yet
  final List<bool?> player2Results;
  final int currentQuestionIndex;
  final List<Question> questions;
  final bool timeUp;
  final double progressValue;
  final int? player1SelectedOption; // null means not selected
  final int? player2SelectedOption;
  final bool isAnswerRevealed;
  final bool isGameOver;

  GameState({
    required this.player1Results,
    required this.player2Results,
    required this.currentQuestionIndex,
    required this.questions,
    this.timeUp = false,
    this.progressValue = 1.0,
    this.player1SelectedOption,
    this.player2SelectedOption,
    this.isAnswerRevealed = false,
    this.isGameOver = false,
  });

  Question get currentQuestion => questions[currentQuestionIndex];

  GameState copyWith({
    List<bool?>? player1Results,
    List<bool?>? player2Results,
    int? currentQuestionIndex,
    List<Question>? questions,
    bool? timeUp,
    double? progressValue,
    int? player1SelectedOption,
    int? player2SelectedOption,
    bool? isAnswerRevealed,
    bool? isGameOver,
  }) {
    return GameState(
      player1Results: player1Results ?? this.player1Results,
      player2Results: player2Results ?? this.player2Results,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      questions: questions ?? this.questions,
      timeUp: timeUp ?? this.timeUp,
      progressValue: progressValue ?? this.progressValue,
      player1SelectedOption: player1SelectedOption != null ? player1SelectedOption : this.player1SelectedOption,
      player2SelectedOption: player2SelectedOption != null ? player2SelectedOption : this.player2SelectedOption,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      isGameOver: isGameOver ?? this.isGameOver,
    );
  }
}