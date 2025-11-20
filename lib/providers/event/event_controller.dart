import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/question/question.dart';

// 1. STATE: Sadece Event'e özel durumlar
class EventState {
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final List<bool?> answerResults;
  final int? selectedAnswerIndex;
  final bool isAnswerRevealed;
  final double timerValue;
  final bool isTimerPaused;
  
  // Joker hakları (Event için farklı sayılar verebilirsiniz)
  final int fiftyFiftyCount;
  final int hintCount;
  final int timePauseCount;
  final int correctAnswerHintCount;
  
  // Kullanım durumları
  final bool hasUsedFiftyFifty;
  final bool hasUsedHint;
  final bool hasUsedTimePause;
  final bool showCorrectAnswer;
  final List<int>? eliminatedOptions;
  final bool hasInfo;

  EventState({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.answerResults = const [],
    this.selectedAnswerIndex,
    this.isAnswerRevealed = false,
    this.timerValue = 1.0,
    this.isTimerPaused = false,
    this.fiftyFiftyCount = 1, // Örn: Event daha zor olabilir, haklar az
    this.hintCount = 1,
    this.timePauseCount = 1,
    this.correctAnswerHintCount = 1,
    this.hasUsedFiftyFifty = false,
    this.hasUsedHint = false,
    this.hasUsedTimePause = false,
    this.showCorrectAnswer = false,
    this.eliminatedOptions,
    this.hasInfo = false,
  });

  EventState copyWith({
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    List<bool?>? answerResults,
    int? selectedAnswerIndex,
    bool? isAnswerRevealed,
    double? timerValue,
    bool? isTimerPaused,
    int? fiftyFiftyCount,
    int? hintCount,
    int? timePauseCount,
    int? correctAnswerHintCount,
    bool? hasUsedFiftyFifty,
    bool? hasUsedHint,
    bool? hasUsedTimePause,
    bool? showCorrectAnswer,
    List<int>? eliminatedOptions,
    bool? hasInfo,
    bool resetEliminatedOptions = false,
  }) {
    return EventState(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answerResults: answerResults ?? this.answerResults,
      selectedAnswerIndex: selectedAnswerIndex,
      isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
      timerValue: timerValue ?? this.timerValue,
      isTimerPaused: isTimerPaused ?? this.isTimerPaused,
      fiftyFiftyCount: fiftyFiftyCount ?? this.fiftyFiftyCount,
      hintCount: hintCount ?? this.hintCount,
      timePauseCount: timePauseCount ?? this.timePauseCount,
      correctAnswerHintCount: correctAnswerHintCount ?? this.correctAnswerHintCount,
      hasUsedFiftyFifty: hasUsedFiftyFifty ?? this.hasUsedFiftyFifty,
      hasUsedHint: hasUsedHint ?? this.hasUsedHint,
      hasUsedTimePause: hasUsedTimePause ?? this.hasUsedTimePause,
      showCorrectAnswer: showCorrectAnswer ?? this.showCorrectAnswer,
      eliminatedOptions: resetEliminatedOptions ? null : (eliminatedOptions ?? this.eliminatedOptions),
      hasInfo: hasInfo ?? this.hasInfo,
    );
  }
}

// 2. CONTROLLER: Event mantığını yönetir
class EventController extends StateNotifier<EventState> {
  Timer? _timer;
  final int _timerDuration = 15; // Saniye

  EventController(List<QuizQuestion> questions)
      : super(EventState(
          questions: questions,
          answerResults: questions.isEmpty ? [] : List.filled(questions.length, null),
        )) {
    if (questions.isNotEmpty) {
      _startTimer();
    }
  }

  void _startTimer() {
    if (state.questions.isEmpty) return;
    
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!state.isTimerPaused) {
        final newValue = state.timerValue - 0.1 / _timerDuration;
        if (newValue <= 0) {
          timer.cancel();
          _answerTimeout();
        } else {
          state = state.copyWith(timerValue: newValue);
        }
      }
    });
  }

  void _answerTimeout() {
    if (state.questions.isEmpty || state.currentQuestionIndex >= state.answerResults.length) {
       _timer?.cancel();
       return;
    }

    final newResults = List<bool?>.from(state.answerResults);
    newResults[state.currentQuestionIndex] = false; // Süre bitti, yanlış say
    
    state = state.copyWith(
      answerResults: newResults,
      isAnswerRevealed: true,
    );
  }

  void selectAnswer(int index) {
    if (state.isAnswerRevealed || (state.eliminatedOptions?.contains(index) ?? false)) return;

    _timer?.cancel();
    
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final isCorrect = index == currentQuestion.correctAnswerIndex;
    
    final newResults = List<bool?>.from(state.answerResults);
    newResults[state.currentQuestionIndex] = isCorrect;

    state = state.copyWith(
      selectedAnswerIndex: index,
      isAnswerRevealed: true,
      answerResults: newResults,
    );
  }

  void goToNextQuestion() {
    if (state.currentQuestionIndex >= state.questions.length - 1) {
      // Quiz bitti, state'i bir fazlasına artır ki UI bitiş ekranını anlasın
      state = state.copyWith(currentQuestionIndex: state.currentQuestionIndex + 1);
      _timer?.cancel();
      return;
    }

    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      selectedAnswerIndex: null,
      isAnswerRevealed: false,
      timerValue: 1.0,
      isTimerPaused: false,
      resetEliminatedOptions: true,
      showCorrectAnswer: false,
      hasUsedFiftyFifty: false,
      hasUsedHint: false,
      hasUsedTimePause: false,
    );
    
    _startTimer();
  }

  // --- Joker Metotları (Aynı mantık) ---
  void useHint() {
    if (state.hintCount <= 0 || state.isAnswerRevealed) return;
    
    final currentQuestion = state.questions[state.currentQuestionIndex];
    List<int> wrongOptions = [];
    for (int i = 0; i < currentQuestion.options.length; i++) {
      if (i != currentQuestion.correctAnswerIndex) wrongOptions.add(i);
    }
    wrongOptions.shuffle();
    
    List<int> newEliminated = state.eliminatedOptions?.toList() ?? [];
    newEliminated.add(wrongOptions.first);
    
    state = state.copyWith(
      hintCount: state.hintCount - 1,
      hasUsedHint: true,
      eliminatedOptions: newEliminated,
    );
  }

  void useFiftyFifty() {
    if (state.fiftyFiftyCount <= 0 || state.isAnswerRevealed) return;
    
    final currentQuestion = state.questions[state.currentQuestionIndex];
    List<int> wrongOptions = [];
    for (int i = 0; i < currentQuestion.options.length; i++) {
      if (i != currentQuestion.correctAnswerIndex) wrongOptions.add(i);
    }
    wrongOptions.shuffle();
    
    state = state.copyWith(
      fiftyFiftyCount: state.fiftyFiftyCount - 1,
      hasUsedFiftyFifty: true,
      eliminatedOptions: wrongOptions.take(2).toList(),
    );
  }
  
  void showCorrectAnswerHint() {
     if (state.correctAnswerHintCount <= 0 || state.isAnswerRevealed) return;
     _timer?.cancel();
     
     final currentQuestion = state.questions[state.currentQuestionIndex];
     final newResults = List<bool?>.from(state.answerResults);
     newResults[state.currentQuestionIndex] = false; // Kopya kullandığı için puan alamayabilir veya alabilir, mantığınıza bağlı

     state = state.copyWith(
       correctAnswerHintCount: state.correctAnswerHintCount - 1,
       showCorrectAnswer: true,
       isAnswerRevealed: true,
       selectedAnswerIndex: currentQuestion.correctAnswerIndex,
       answerResults: newResults,
     );
  }

  void useTimePause() {
    if (state.timePauseCount <= 0 || state.isAnswerRevealed) return;
    state = state.copyWith(timePauseCount: state.timePauseCount - 1, isTimerPaused: true, hasUsedTimePause: true);
    Future.delayed(Duration(seconds: 5), () {
       if (!state.isAnswerRevealed) state = state.copyWith(isTimerPaused: false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}