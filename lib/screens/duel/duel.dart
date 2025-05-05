import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_flags/country_flags.dart';
import 'dart:async';
import 'dart:math';
import 'package:quiz_app/screens/duel/victory_modal.dart';

// Question model
class Question {
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final int points;

  Question({
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.points = 10,
  });
}

// Player model
class Player {
  final String avatarUrl;
  final String countryCode;
  final String username;
  int score;

  Player({
    required this.avatarUrl,
    required this.countryCode,
    required this.username,
    this.score = 0,
  });

  // Eksik olan copyWith metodu
  Player copyWith({
    String? avatarUrl,
    String? countryCode,
    String? username,
    int? score,
  }) {
    return Player(
      avatarUrl: avatarUrl ?? this.avatarUrl,
      countryCode: countryCode ?? this.countryCode,
      username: username ?? this.username,
      score: score ?? this.score,
    );
  }
}

// Sample questions
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

// Player providers
final player1Provider = StateProvider<Player>((ref) {
  return Player(
    username: 'Player 1',
    countryCode: 'AZ',
    avatarUrl: 'assets/player1.png',
  );
});

final player2Provider = StateProvider<Player>((ref) {
  return Player(
    username: 'Player 2',
    countryCode: 'DE',
    avatarUrl: 'assets/player2.png',
  );
});

// Game state provider
final gameStateProvider = StateNotifierProvider<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

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

class DuelScreen extends ConsumerStatefulWidget {
  const DuelScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends ConsumerState<DuelScreen> {
 bool _showVictoryModal = false;
final int _coinsEarned = 50;

void _showVictoryCelebration() {
  setState(() {
    _showVictoryModal = true;
  });
}

void _hideVictoryModal() {
  print("Modal kapatılıyor"); // Debug
  setState(() {
    _showVictoryModal = false;
  });
}

void _playAgain() {
  setState(() {
    _showVictoryModal = false;
  });
  ref.refresh(gameStateProvider);
}
  

  @override
  void initState() {
    super.initState();
    // Start AI player simulation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      final gameNotifier = ref.read(gameStateProvider.notifier);
      gameNotifier.simulatePlayer2Answer();
    });
  }

 

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final player1 = ref.watch(player1Provider);
    final player2 = ref.watch(player2Provider);
    
    // Listen for question changes to simulate player 2
    ref.listen(gameStateProvider.select((state) => state.currentQuestionIndex), 
      (previous, current) {
        if (previous != current) {
          // Delay added to ensure the UI has been updated before simulating
          Future.delayed(const Duration(milliseconds: 500), () {
            final gameNotifier = ref.read(gameStateProvider.notifier);
            gameNotifier.simulatePlayer2Answer();
          });
        }
      }
    );

    // Calculate scores based on results
    int player1Score = 0;
    int player2Score = 0;
    
    for (int i = 0; i < gameState.player1Results.length; i++) {
      if (gameState.player1Results[i] == true) {
        player1Score += gameState.questions[i].points;
      }
      if (gameState.player2Results[i] == true) {
        player2Score += gameState.questions[i].points;
      }
    }

  // Check if game is over and player 1 won
  if (gameState.isGameOver && player1Score > player2Score && !_showVictoryModal) {
    // Show victory modal after a short delay
    Future.delayed(Duration.zero, () {
      _showVictoryCelebration();
    });
  }



    // Update player scores in the providers
// Update player scores in the providers
WidgetsBinding.instance.addPostFrameCallback((_) {
  ref.read(player1Provider.notifier).update((state) => 
    Player(
      avatarUrl: state.avatarUrl,
      countryCode: state.countryCode, 
      username: state.username,
      score: player1Score
    )
  );
  
  ref.read(player2Provider.notifier).update((state) => 
    Player(
      avatarUrl: state.avatarUrl,
      countryCode: state.countryCode, 
      username: state.username,
      score: player2Score
    )
  );
});

    return Scaffold(
      backgroundColor: Colors.white,
      body: gameState.isGameOver 
          ? _buildGameOverScreen(player1Score, player2Score, player1, player2) 
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Back Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.cyan,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () {
                              // Handle navigation
                            },
                          ),
                        ),
                        Text(
                          'Question ${gameState.currentQuestionIndex + 1}/${gameState.questions.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Player 1 and Results
                    Row(
                      children: [
                        // Player 1
                        Expanded(
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage(player1.avatarUrl),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: CountryFlag.fromCountryCode(
                                      player1.countryCode,
                                      height: 15,
                                      width: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                           
                              const SizedBox(width: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                      gameState.currentQuestionIndex,
                                      (index) {
                                        final result = gameState.player1Results[index];
                                        if (result == null) {
                                          return const SizedBox(width: 24);
                                        }
                                        return Container(
                                          margin: const EdgeInsets.only(right: 4),
                                          child: Icon(
                                            result ? Icons.check_circle : Icons.cancel,
                                            color: result ? Colors.green : Colors.red,
                                            size: 24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Player 2 and Results
                    Row(
                      children: [
                        // Player 2
                        Expanded(
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: AssetImage(player2.avatarUrl),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: CountryFlag.fromCountryCode(
                                      player2.countryCode,
                                      height: 15,
                                      width: 20,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                          
                              const SizedBox(width: 8),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List.generate(
                                      gameState.currentQuestionIndex,
                                      (index) {
                                        final result = gameState.player2Results[index];
                                        if (result == null) {
                                          return const SizedBox(width: 24);
                                        }
                                        return Container(
                                          margin: const EdgeInsets.only(right: 4),
                                          child: Icon(
                                            result ? Icons.check_circle : Icons.cancel,
                                            color: result ? Colors.green : Colors.red,
                                            size: 24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Question Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.blue.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  gameState.currentQuestion.questionText,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '${gameState.currentQuestion.points}',
                                      style: TextStyle(
                                        color: Colors.orange.shade900,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.stars,
                                      size: 16,
                                      color: Colors.orange.shade900,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Timer Progress Bar or Time's Up Button
                    gameState.timeUp
                        ? Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                              onPressed: null, // Disabled button
                              child: const Text(
                                "Time's Up!",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          )
                        : LinearProgressIndicator(
                            value: gameState.progressValue,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              gameState.progressValue < 0.3 ? Colors.red : 
                              gameState.progressValue < 0.7 ? Colors.orange : 
                              Colors.green
                            ),
                            minHeight: 8,
                          ),

                    const SizedBox(height: 20),

                    // Answer Options
                    ...List.generate(
                      gameState.currentQuestion.options.length,
                      (index) {
                        // Determine button color
                       Color buttonColor = Colors.blue; // Default color for all buttons
    
  if (gameState.isAnswerRevealed) {
      // Show correct answer in green
      if (index == gameState.currentQuestion.correctOptionIndex) {
        buttonColor = Colors.green;
      }
      // Show player 2's wrong selection in red
      else if (gameState.player2SelectedOption == index && 
               gameState.player2SelectedOption != gameState.currentQuestion.correctOptionIndex) {
        buttonColor = Colors.red;
      }
      // Show player 1's wrong selection in red
      else if (gameState.player1SelectedOption == index && 
               gameState.player1SelectedOption != gameState.currentQuestion.correctOptionIndex) {
        buttonColor = Colors.red;
      }
      // Other options remain blue
    }


                        // Debug print to verify state when clicking
                        return   Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnswerButton(
        text: gameState.currentQuestion.options[index],
        color: buttonColor,
        onPressed: () {
          if (gameState.timeUp || gameState.isAnswerRevealed) {
            return;
          }
          if (gameState.player1SelectedOption == null) {
            ref.read(gameStateProvider.notifier).selectAnswer(1, index);
          }
        },
        player1Selected: gameState.player1SelectedOption == index,
        player2Selected: gameState.player2SelectedOption == index,
        player1: player1,
        player2: player2,
        isCorrect: gameState.isAnswerRevealed && 
                  index == gameState.currentQuestion.correctOptionIndex,
        isWrong: gameState.isAnswerRevealed && 
                ((gameState.player1SelectedOption == index && 
                  gameState.player1SelectedOption != gameState.currentQuestion.correctOptionIndex) ||
                 (gameState.player2SelectedOption == index && 
                  gameState.player2SelectedOption != gameState.currentQuestion.correctOptionIndex)),
        timeUp: gameState.timeUp,
        isAnswerRevealed: gameState.isAnswerRevealed,
      ),
    );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
// In _DuelScreenState

// Replace the existing _buildGameOverScreen with this:
Widget _buildGameOverScreen(int player1Score, int player2Score, Player player1, Player player2) {
  final winner = player1Score > player2Score ? player1 : 
                 player2Score > player1Score ? player2 : null;
  
  // If player 1 won, show the victory modal
  if (winner == player1 && !_showVictoryModal) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showVictoryCelebration();
    });
  }

  return Stack(
    children: [
      // Original game over screen (hidden behind modal if shown)
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            
            if (winner != null) ...[
              Text(
                '${winner.username} Wins!',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(winner.avatarUrl),
              ),
            ] else
              const Text(
                'It\'s a Tie!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            
            const SizedBox(height: 30),
            
            Text(
              'Final Score',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 10),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(player1.avatarUrl),
                    ),
                    const SizedBox(height: 5),
                    Text(player1.username),
                    Text(
                      '$player1Score pts',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'vs',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ),
                
                Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(player2.avatarUrl),
                    ),
                    const SizedBox(height: 5),
                    Text(player2.username),
                    Text(
                      '$player2Score pts',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ref.refresh(gameStateProvider);
              },
              child: const Text(
                'Play Again',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
      
      // Victory modal overlay
      if (_showVictoryModal)
        VictoryModal(
          coins : _coinsEarned,
          onPlayAgain: _playAgain,
          onClose: _hideVictoryModal,
        ),
    ],
  );
}
}

class AnswerButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;
  final bool player1Selected;
  final bool player2Selected;
  final Player player1;
  final Player player2;
  final bool isCorrect;
  final bool isWrong;
  final bool timeUp;
  final bool isAnswerRevealed;

  const AnswerButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
    required this.player1,
    required this.player2,
    this.player1Selected = false,
    this.player2Selected = false,
    this.isCorrect = false,
       this.isWrong = false,
    required this.timeUp,
    required this.isAnswerRevealed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine when to show player 2's selection
    // Only show it if:
    // 1. Time is up, OR
    // 2. Answer is revealed, OR
    // 3. Player 1 has already selected an answer
    final showPlayer2Selection = timeUp || isAnswerRevealed || player1Selected;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle, color: Colors.white),
            Row(
              children: [
                if (player1Selected)
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: AssetImage(player1.avatarUrl),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CountryFlag.fromCountryCode(
                          player1.countryCode,
                          height: 8,
                          width: 10,
                        ),
                      ),
                    ],
                  ),
                if (player1Selected && showPlayer2Selection && player2Selected) 
                  const SizedBox(width: 4),
                if (showPlayer2Selection && player2Selected)
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: AssetImage(player2.avatarUrl),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CountryFlag.fromCountryCode(
                          player2.countryCode,
                          height: 8,
                          width: 10,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}