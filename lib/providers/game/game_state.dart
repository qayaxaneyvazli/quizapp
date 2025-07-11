import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/models/game/game_state.dart';
import 'package:quiz_app/models/player/player.dart';
import 'package:quiz_app/models/question/DuelQuestion.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/screens/duel/answer_button.dart';
import 'package:quiz_app/screens/duel/defeat_modal.dart';
import 'dart:async';
import 'dart:math';
import 'package:quiz_app/screens/duel/victory_modal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final List<Question> sampleQuestions = [
  Question(
    questionText: 'What is the fastest land animal in the world?',
    options: ['Cheetah', 'Pronghorn Antelope', 'Lion', 'Thomson\'s Gazelle'],
    correctOptionIndex: 0,
  ),
  Question(
    questionText: 'Which planet is known as the Red Planet?',
    options: ['Venus', 'Mars', 'Jupiter', 'Mercury'],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: 'What is the chemical symbol for gold?',
    options: ['Gd', 'Au', 'Ag', 'Fe'],
    correctOptionIndex: 1,
  ),
  Question(
    questionText: 'Which country has the largest population in the world?',
    options: ['India', 'China', 'USA', 'Indonesia'],
    correctOptionIndex: 0,
  ),
  Question(
    questionText: 'What is the largest ocean on Earth?',
    options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
    correctOptionIndex: 3,
  ),
];

// Player providers - AutoDispose əlavə edildi
final player1Provider = StateProvider.autoDispose<Player>((ref) {
  return Player(
    username: 'Player 1',
    countryCode: 'AZ',
    avatarUrl: 'assets/player1.png',
  );
});

final player2Provider = StateProvider.autoDispose<Player>((ref) {
  return Player(
    username: 'Player 2',
    countryCode: 'DE',
    avatarUrl: 'assets/player2.png',
  );
});

// Game state provider - AutoDispose əlavə edildi
final gameStateProvider = StateNotifierProvider.autoDispose<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

class GameStateNotifier extends StateNotifier<GameState> {
  Timer? _timer;
  static const questionTimeInSeconds = 10;
  static const timerInterval = Duration(milliseconds: 100);
  static const decrementValue = 1.0 / (questionTimeInSeconds * 10); // For smooth progress bar
  static const revealAnswerDuration = Duration(seconds: 2);
  
  GameStateNotifier()
      : super(GameState(
          player1Results: List.filled(sampleQuestions.length, null),
          player2Results: List.filled(sampleQuestions.length, null),
          currentQuestionIndex: 0,
          questions: sampleQuestions,
        )) {
    startTimer();
  }
  
  void startTimer() {
    _timer?.cancel();
    
    // Important: Reset selections for the new question
    state = GameState(
      player1Results: state.player1Results,
      player2Results: state.player2Results,
      currentQuestionIndex: state.currentQuestionIndex,
      questions: state.questions,
      timeUp: false,
      progressValue: 1.0,
      player1SelectedOption: null,
      player2SelectedOption: null,
      isAnswerRevealed: false,
      isGameOver: state.isGameOver,
    );
    
    _timer = Timer.periodic(timerInterval, (timer) {
      if (state.progressValue <= 0) {
        timer.cancel();
        revealAnswer();
      } else {
        state = state.copyWith(progressValue: state.progressValue - decrementValue);
      }
    });
  }

  void selectAnswer(int playerNumber, int optionIndex) {
    // If time is up or answer is already revealed, do nothing
    if (state.timeUp || state.isAnswerRevealed) return;
    
    // Update player's selection
    if (playerNumber == 1 && state.player1SelectedOption == null) {
      state = state.copyWith(player1SelectedOption: optionIndex);
      
      // If both players have answered, reveal the answer
      if (state.player2SelectedOption != null) {
        _timer?.cancel();
        revealAnswer();
      }
    } else if (playerNumber == 2 && state.player2SelectedOption == null) {
      state = state.copyWith(player2SelectedOption: optionIndex);
      
      // If both players have answered, reveal the answer
      if (state.player1SelectedOption != null) {
        _timer?.cancel();
        revealAnswer();
      }
    }
  }
  
  void revealAnswer() {
    // Update results based on selections
    final List<bool?> player1Results = List.from(state.player1Results);
    final List<bool?> player2Results = List.from(state.player2Results);
    
    final correctAnswer = state.currentQuestion.correctOptionIndex;
    
    // Check player 1's answer
    if (state.player1SelectedOption != null) {
      player1Results[state.currentQuestionIndex] = 
          state.player1SelectedOption == correctAnswer;
    } else {
      // No answer is considered wrong
      player1Results[state.currentQuestionIndex] = false;
    }
    
    // Check player 2's answer
    if (state.player2SelectedOption != null) {
      player2Results[state.currentQuestionIndex] = 
          state.player2SelectedOption == correctAnswer;
    } else {
      // No answer is considered wrong
      player2Results[state.currentQuestionIndex] = false;
    }
    
    // Update state to reveal answer
    state = state.copyWith(
      player1Results: player1Results,
      player2Results: player2Results,
      timeUp: true,
      isAnswerRevealed: true,
    );
    
    // Wait for a moment before moving to next question
    Timer(revealAnswerDuration, moveToNextQuestion);
  }
  
  void moveToNextQuestion() {
    final nextQuestionIndex = state.currentQuestionIndex + 1;
    
    // Check if game is over
    if (nextQuestionIndex >= state.questions.length) {
      state = state.copyWith(isGameOver: true);
      return;
    }
    
    // Move to next question and reset timer
    state = state.copyWith(
      currentQuestionIndex: nextQuestionIndex,
      // Explicitly reset selected options to null
      player1SelectedOption: null,
      player2SelectedOption: null,
      isAnswerRevealed: false,
      timeUp: false,
      progressValue: 1.0,
    );
    
    // Start the timer for the new question
    startTimer();
  }

  // For testing purposes: simulate player 2 answers (AI or remote player)
  void simulatePlayer2Answer() {
    if (state.player2SelectedOption == null && !state.timeUp && !state.isAnswerRevealed) {
      // Random delay before answering (1-3 seconds)
      final delay = Duration(milliseconds: Random().nextInt(3000) + 1000);
      
      Timer(delay, () {
        // If the game hasn't moved on yet
        if (!state.timeUp && !state.isAnswerRevealed && mounted) {
          // 50% chance to select correct answer (adjustable difficulty)
          final correctAnswer = state.currentQuestion.correctOptionIndex;
          final willSelectCorrect = Random().nextDouble() < 0.5;
          
          int selectedOption;
          if (willSelectCorrect) {
            selectedOption = correctAnswer;
          } else {
            // Pick a random wrong answer
            List<int> wrongOptions = List.generate(
              state.currentQuestion.options.length, 
              (i) => i
            ).where((i) => i != correctAnswer).toList();
            
            selectedOption = wrongOptions[Random().nextInt(wrongOptions.length)];
          }
          
          selectAnswer(2, selectedOption);
        }
      });
    }
  }
  
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}