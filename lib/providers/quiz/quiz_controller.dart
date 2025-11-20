import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/core/services/quiz_submission.dart';
 
class QuizState {
  final int fiftyFiftyCount;
  final int hintCount;
  final int timePauseCount;
  final int correctAnswerHintCount;
  final List<QuizQuestion> questions;
  final int currentQuestionIndex;
  final List<bool?> answerResults; // null: unanswered, true: correct, false: incorrect
  final int? selectedAnswerIndex;
  final bool isAnswerRevealed;
  final double timerValue;
  final bool isTimerPaused;
  final bool hasUsedFiftyFifty;
  final bool hasUsedHint;
  final bool hasUsedTimePause;
  final List<int>? eliminatedOptions; // Make sure this can be null
  final bool showCorrectAnswer;
  final bool hasInfo; // <------ yeni alan
  final int levelId; // Add level ID for quiz submission
  final List<double> answerTimes; // Track time taken for each answer
  final List<int?> selectedAnswers; // Track the actual selected answers
  final DateTime? quizStartTime; // Track when quiz started

  QuizState({
    this.fiftyFiftyCount = 2,
    this.hintCount = 2,
    this.timePauseCount = 1,
    this.correctAnswerHintCount = 1,
    required this.questions,
    this.currentQuestionIndex = 0,
    this.answerResults = const [],
    this.selectedAnswerIndex,
    this.isAnswerRevealed = false,
    this.timerValue = 1.0,
    this.isTimerPaused = false,
    this.hasUsedFiftyFifty = false,
    this.hasUsedHint = false,
    this.hasUsedTimePause = false,
    this.eliminatedOptions, // No default value, can be null
    this.showCorrectAnswer = false,
    this.hasInfo = false,
    this.levelId = 0, // Default level ID
    this.answerTimes = const [], // Track time taken for each answer
    this.selectedAnswers = const [], // Track the actual selected answers
    this.quizStartTime, // Track when quiz started
  });

  // Make sure copyWith handles null correctly
  QuizState copyWith({
    List<QuizQuestion>? questions,
    int? currentQuestionIndex,
    List<bool?>? answerResults,
    int? selectedAnswerIndex,
    bool? isAnswerRevealed,
    double? timerValue,
    bool? isTimerPaused,
    bool? hasUsedFiftyFifty,
    bool? hasUsedHint,
    bool? hasUsedTimePause,
    List<int>? eliminatedOptions,
    bool? showCorrectAnswer,
    bool? hasInfo,
    int? fiftyFiftyCount,
    int? hintCount,
    int? timePauseCount,
    int? correctAnswerHintCount,
    int? levelId,
    List<double>? answerTimes,
    List<int?>? selectedAnswers,
    DateTime? quizStartTime,
    bool resetEliminatedOptions = false, // New parameter to explicitly reset
  }) {
          return QuizState(
        questions: questions ?? this.questions,
        currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
        answerResults: answerResults ?? this.answerResults,
        selectedAnswerIndex: selectedAnswerIndex,
        isAnswerRevealed: isAnswerRevealed ?? this.isAnswerRevealed,
        timerValue: timerValue ?? this.timerValue,
        isTimerPaused: isTimerPaused ?? this.isTimerPaused,
        hasUsedFiftyFifty: hasUsedFiftyFifty ?? this.hasUsedFiftyFifty,
        hasUsedHint: hasUsedHint ?? this.hasUsedHint,
        hasUsedTimePause: hasUsedTimePause ?? this.hasUsedTimePause,
        eliminatedOptions: resetEliminatedOptions ? null : (eliminatedOptions ?? this.eliminatedOptions),
        showCorrectAnswer: showCorrectAnswer ?? this.showCorrectAnswer,
        hasInfo: hasInfo ?? this.hasInfo,
        levelId: levelId ?? this.levelId,
        answerTimes: answerTimes ?? this.answerTimes,
        selectedAnswers: selectedAnswers ?? this.selectedAnswers,
        quizStartTime: quizStartTime ?? this.quizStartTime,
        fiftyFiftyCount: fiftyFiftyCount ?? this.fiftyFiftyCount,
        hintCount: hintCount ?? this.hintCount,
        timePauseCount: timePauseCount ?? this.timePauseCount,
        correctAnswerHintCount: correctAnswerHintCount ?? this.correctAnswerHintCount,
      );
  }
}

class QuizController extends StateNotifier<QuizState> {
  Timer? _timer;
  Timer? _nextQuestionTimer;
  final int _timerDuration = 15; // seconds
  DateTime? _questionStartTime;
  
QuizController(List<QuizQuestion> questions, {int levelId = 0})
      : super(QuizState(
          questions: questions,
          // Use safety check for List.filled size
          answerResults: questions.isEmpty ? [] : List.filled(questions.length, null),
          levelId: levelId,
          quizStartTime: DateTime.now(),
        )) {
    
    // Only start timer and tracking if we actually have questions
    if (questions.isNotEmpty) {
      _startTimer();
      _questionStartTime = DateTime.now();
    }
  }

  void restartQuiz() {
  state = QuizState(
    questions: state.questions,
    currentQuestionIndex: 0,
    selectedAnswerIndex: null,
    timerValue: 1.0,
    answerResults: [],
    answerTimes: [],
    selectedAnswers: [],
    eliminatedOptions: null,
    isAnswerRevealed: false,
    hasUsedHint: false,
    hasUsedFiftyFifty: false,
    showCorrectAnswer: false,
    hasUsedTimePause: false,
    quizStartTime: DateTime.now(),
  );
  
  // Timer'ı yeniden başlat
  _startTimer();
  _questionStartTime = DateTime.now();
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
   
    
    // Calculate time taken for this answer (full time)
    double timeTaken = _timerDuration.toDouble();
    if (_questionStartTime != null) {
      final now = DateTime.now();
      timeTaken = now.difference(_questionStartTime!).inMilliseconds / 1000.0;
    }
    
    // Bu soruyu yanlış olarak işaretle
    final newResults = List<bool?>.from(state.answerResults);
    newResults[state.currentQuestionIndex] = false;
    
    final newAnswerTimes = List<double>.from(state.answerTimes);
    newAnswerTimes.add(timeTaken);
    
    final newSelectedAnswers = List<int?>.from(state.selectedAnswers);
    newSelectedAnswers.add(null); // No answer selected due to timeout
    
    state = state.copyWith(
      answerResults: newResults,
      answerTimes: newAnswerTimes,
      selectedAnswers: newSelectedAnswers,
      isAnswerRevealed: true,
    );
    
    // Kısa bir bekleme süresi sonra sonraki soruya geç
    //_moveToNextQuestion();
  }
  void goToNextQuestion() {
  _moveToNextQuestion();
}

  void _answerQuestion(int selectedIndex) {
    if (state.isAnswerRevealed) return;
    
    // Zamanlayıcıyı durdur
    _timer?.cancel();
    
    // Calculate time taken for this answer
    double timeTaken = 0.0;
    if (_questionStartTime != null) {
      final now = DateTime.now();
      timeTaken = now.difference(_questionStartTime!).inMilliseconds / 1000.0;
    }
    
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final isCorrect = selectedIndex == currentQuestion.correctAnswerIndex;
    
    // Update answer results and times
    final newResults = List<bool?>.from(state.answerResults);
    newResults[state.currentQuestionIndex] = isCorrect;
    
    final newAnswerTimes = List<double>.from(state.answerTimes);
    newAnswerTimes.add(timeTaken);
    
    final newSelectedAnswers = List<int?>.from(state.selectedAnswers);
    newSelectedAnswers.add(selectedIndex);
    
    // Reveal answer
    state = state.copyWith(
      selectedAnswerIndex: selectedIndex,
      isAnswerRevealed: true,
      answerResults: newResults,
      answerTimes: newAnswerTimes,
      selectedAnswers: newSelectedAnswers,
    );
    
    // Move to next question after delay
    //_moveToNextQuestion();
  }

void _moveToNextQuestion() {
  // Eğer zaten bir sonraki soruya geçiş bekleniyorsa, ek bir timer oluşturma
  if (_nextQuestionTimer != null && _nextQuestionTimer!.isActive) {
    return;
  }
  
  _nextQuestionTimer = Timer(Duration(seconds: 2), () {
    // Eğer son sorudaysak quiz'i bitir
    if (state.currentQuestionIndex >= state.questions.length - 1) {
      print("Quiz tamamlandı!");
      // Submit quiz data to backend
      _submitQuizData();
      // Quiz bitince yapılacak işlemler
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1, // Son sorudan bir sonraki indekse geç (sonuç ekranını göstermek için)
      );
      return;
    }
    
    // Bir sonraki soruya geç - use the new resetEliminatedOptions parameter
    state = state.copyWith(
      currentQuestionIndex: state.currentQuestionIndex + 1,
      selectedAnswerIndex: null,
      isAnswerRevealed: false,
      timerValue: 1.0,
      isTimerPaused: false,
      resetEliminatedOptions: true, // Explicitly request to reset eliminatedOptions
      showCorrectAnswer: false,
      hasUsedFiftyFifty: false,
      hasUsedHint: false,
      hasUsedTimePause: false,
    );
    
    // Reset question start time for next question
    _questionStartTime = DateTime.now();
    
    // Add debug print to confirm state
    print("Eliminated options after reset: ${state.eliminatedOptions}");
    
    // Yeni soru için timer'ı yeniden başlat
    _startTimer();
    
    print("Sonraki soruya geçildi: ${state.currentQuestionIndex + 1}");
  });
}
  void selectAnswer(int index) {
    if (state.isAnswerRevealed || state.eliminatedOptions?.contains(index) == true) {
      return;
    }
    
    print("Cevap seçildi: $index");
    _answerQuestion(index);
  }

void useHint() {
  if (state.hintCount <= 0  || state.isAnswerRevealed) return;
  
  final currentQuestion = state.questions[state.currentQuestionIndex];
  final correctIndex = currentQuestion.correctAnswerIndex;
  
  // Find wrong options to eliminate one
  List<int> wrongOptions = [];
  for (int i = 0; i < currentQuestion.options.length; i++) {
    if (i != correctIndex) {
      wrongOptions.add(i);
    }
  }
  
  // Randomly select one wrong option to eliminate
  wrongOptions.shuffle();
  
  List<int> newEliminatedOptions = state.eliminatedOptions?.toList() ?? [];
  newEliminatedOptions.add(wrongOptions[0]);
  
  print("X jokeri kullanıldı, elenen şık: ${wrongOptions[0]}");
  
  state = state.copyWith(
    hasUsedHint: true,
    eliminatedOptions: newEliminatedOptions,
    hintCount: state.hintCount - 1,
  );
  
  // Check if all wrong options are now eliminated
  // This happens when 50/50 is used (eliminates 2 wrong options)
  // and then X joker is used (eliminates the last wrong option)
  if (newEliminatedOptions.length >= currentQuestion.options.length - 1) {
    _checkAllWrongOptionsEliminated();
  }
}

void useFiftyFifty() {
  if (state.fiftyFiftyCount  <= 0 || state.isAnswerRevealed) return;
  
  final currentQuestion = state.questions[state.currentQuestionIndex];
  final correctIndex = currentQuestion.correctAnswerIndex;
  
  // Find wrong options
  List<int> wrongOptions = [];
  for (int i = 0; i < currentQuestion.options.length; i++) {
    if (i != correctIndex) {
      wrongOptions.add(i);
    }
  }
  
  // Shuffle and eliminate two wrong options
  wrongOptions.shuffle();
  List<int> optionsToEliminate = wrongOptions.sublist(0, 2);
  
  print("50/50 jokeri kullanıldı, elenen şıklar: $optionsToEliminate");
  
  state = state.copyWith(
    hasUsedFiftyFifty: true,
    eliminatedOptions: optionsToEliminate,
    fiftyFiftyCount: state.fiftyFiftyCount - 1,
  );
  
  // Check if all wrong options are now eliminated
  // This could happen if X joker was used first and eliminated the third wrong option
  if (optionsToEliminate.length >= currentQuestion.options.length - 1) {
    _checkAllWrongOptionsEliminated();
  }
}

void _checkAllWrongOptionsEliminated() {
  final currentQuestion = state.questions[state.currentQuestionIndex];
  final correctIndex = currentQuestion.correctAnswerIndex;
  
  // Count how many options are eliminated
  int eliminatedCount = state.eliminatedOptions?.length ?? 0;
  
  // If all wrong options are eliminated (usually 3 in a 4-option quiz)
  if (eliminatedCount >= currentQuestion.options.length - 1) {
    print("Tüm yanlış şıklar elendi, doğru cevap otomatik olarak seçildi");
    
    // Stop the timer
    _timer?.cancel();
    
    // Mark this question as correct
    final newResults = List<bool?>.from(state.answerResults);
    newResults[state.currentQuestionIndex] = true;
    
    final newSelectedAnswers = List<int?>.from(state.selectedAnswers);
    newSelectedAnswers.add(correctIndex);
    
    // Reveal the correct answer
    state = state.copyWith(
      selectedAnswerIndex: correctIndex,
      isAnswerRevealed: true,
      answerResults: newResults,
      selectedAnswers: newSelectedAnswers,
    );
    
    // Move to next question after delay
    //_moveToNextQuestion();
  }
}


  void useTimePause() {
    if (state.timePauseCount <= 0  || state.isAnswerRevealed) return;
    
    state = state.copyWith(
      hasUsedTimePause: true,
      isTimerPaused: true,
       timePauseCount: state.timePauseCount - 1,
    );
    
    // Resume after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      if (!state.isAnswerRevealed) {
        state = state.copyWith(isTimerPaused: false);
      }
    });
  }
  
  // Doğru cevabı gösterme jokeri
void showCorrectAnswerHint() {
 
  if (state.correctAnswerHintCount <= 0 || state.isAnswerRevealed) return;
  // Stop the timer
  _timer?.cancel();
  
  final currentQuestion = state.questions[state.currentQuestionIndex];
  
  // Mark this question as incorrect
  final newResults = List<bool?>.from(state.answerResults);
  newResults[state.currentQuestionIndex] = false;
  
  final newSelectedAnswers = List<int?>.from(state.selectedAnswers);
  newSelectedAnswers.add(currentQuestion.correctAnswerIndex); // Show correct answer (0-based)
  
  state = state.copyWith(
    showCorrectAnswer: true,
    isAnswerRevealed: true, // This will effectively reveal the answer
    answerResults: newResults,
    selectedAnswers: newSelectedAnswers,
    correctAnswerHintCount: state.correctAnswerHintCount - 1,
  );
  
  // Move to next question after delay (reuse existing method)
  _moveToNextQuestion();
}

  /// Submit quiz data to backend when quiz is completed
  void _submitQuizData() {
    try {
      // Calculate total duration
      int totalDuration = 0;
      if (state.quizStartTime != null) {
        final now = DateTime.now();
        totalDuration = now.difference(state.quizStartTime!).inSeconds;
      }
      
      // Prepare answers for submission
      List<QuizAnswer> answers = [];
      
      // Use the actual selected answers
      for (int i = 0; i < state.questions.length && i < state.answerTimes.length; i++) {
        final question = state.questions[i];
        final timeTaken = state.answerTimes[i];
        final selectedAnswer = i < state.selectedAnswers.length ? state.selectedAnswers[i] : null;
        
        // Only add answers that were actually answered
        if (selectedAnswer != null) {
          final convertedOptionId = selectedAnswer + 1; // Convert 0-based index to 1-based for backend
          print('📝 Question ${i + 1}: Selected answer ${selectedAnswer} (0-based) -> option_id ${convertedOptionId} (1-based)');
          
          answers.add(QuizAnswer(
            questionId: i + 1, // Assuming question IDs start from 1
            optionId: convertedOptionId,
            time: timeTaken,
          ));
        }
      }
      
      // Submit to backend in background
      QuizSubmissionService.submitQuizAnswers(
        levelId: state.levelId,
        duration: totalDuration,
        answers: answers,
      );
      
      print('Quiz data submitted to backend');
    } catch (e) {
      print('Error submitting quiz data: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nextQuestionTimer?.cancel();
    super.dispose();
  }
}







