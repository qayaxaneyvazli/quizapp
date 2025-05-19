import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/question/question.dart';
 
class QuizState {
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

  QuizState({
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
    );
  }
}

class QuizController extends StateNotifier<QuizState> {
  Timer? _timer;
  Timer? _nextQuestionTimer;
  final int _timerDuration = 15; // seconds
  
  QuizController(List<QuizQuestion> questions) 
      : super(QuizState(
          questions: questions,
          answerResults: List.filled(questions.length, null),
        )) {
    _startTimer();
  }

  void restartQuiz() {
  state = QuizState(
    questions: state.questions,
    currentQuestionIndex: 0,
    selectedAnswerIndex: null,
    timerValue: 1.0,
    answerResults: [],
    eliminatedOptions: null,
    isAnswerRevealed: false,
    hasUsedHint: false,
    hasUsedFiftyFifty: false,
    showCorrectAnswer: false,
    hasUsedTimePause: false,
  );
  
  // Timer'ı yeniden başlat
  _startTimer();
}

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!state.isTimerPaused) {
        final newValue = state.timerValue - 0.1 / _timerDuration;
        if (newValue <= 0) {
          timer.cancel();
          _answerTimeout();  // Süre dolduğunda bu fonksiyonu çağır
        } else {
          state = state.copyWith(timerValue: newValue);
        }
      }
    });
  }

  // Süre dolduğunda çağrılacak fonksiyon
  void _answerTimeout() {
    print("Süre doldu, bir sonraki soruya geçiliyor");
    
    // Bu soruyu yanlış olarak işaretle
    final newResults = List<bool?>.from(state.answerResults);
    newResults[state.currentQuestionIndex] = false;
    
    state = state.copyWith(
      answerResults: newResults,
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
    
    final currentQuestion = state.questions[state.currentQuestionIndex];
    final isCorrect = selectedIndex == currentQuestion.correctAnswerIndex;
    
    // Update answer results
    final newResults = List<bool?>.from(state.answerResults);
    newResults[state.currentQuestionIndex] = isCorrect;
    
    // Reveal answer
    state = state.copyWith(
      selectedAnswerIndex: selectedIndex,
      isAnswerRevealed: true,
      answerResults: newResults,
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
      // Her soru için joker kullanımını sıfırlama
      hasUsedFiftyFifty: false,
      hasUsedHint: false,
      hasUsedTimePause: false,
    );
    
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
  if (state.hasUsedHint || state.isAnswerRevealed) return;
  
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
  );
  
  // Check if all wrong options are now eliminated
  // This happens when 50/50 is used (eliminates 2 wrong options)
  // and then X joker is used (eliminates the last wrong option)
  if (newEliminatedOptions.length >= currentQuestion.options.length - 1) {
    _checkAllWrongOptionsEliminated();
  }
}

void useFiftyFifty() {
  if (state.hasUsedFiftyFifty || state.isAnswerRevealed) return;
  
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
    
    // Reveal the correct answer
    state = state.copyWith(
      selectedAnswerIndex: correctIndex,
      isAnswerRevealed: true,
      answerResults: newResults,
    );
    
    // Move to next question after delay
    //_moveToNextQuestion();
  }
}


  void useTimePause() {
    if (state.hasUsedTimePause || state.isAnswerRevealed) return;
    
    state = state.copyWith(
      hasUsedTimePause: true,
      isTimerPaused: true,
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
  print("Doğru cevap jokeri kullanıldı");
  
  // Stop the timer
  _timer?.cancel();
  
  // Mark this question as incorrect
  final newResults = List<bool?>.from(state.answerResults);
  newResults[state.currentQuestionIndex] = false;
  
  state = state.copyWith(
    showCorrectAnswer: true,
    isAnswerRevealed: true, // This will effectively reveal the answer
    answerResults: newResults,
  );
  
  // Move to next question after delay (reuse existing method)
  _moveToNextQuestion();
}

  @override
  void dispose() {
    _timer?.cancel();
    _nextQuestionTimer?.cancel();
    super.dispose();
  }
}







