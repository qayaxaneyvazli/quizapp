// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/models/game/game_state.dart';
import 'package:quiz_app/models/player/player.dart';
import 'package:quiz_app/models/question/DuelQuestion.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/providers/game/game_state.dart';
import 'package:quiz_app/screens/duel/answer_button.dart';
import 'package:quiz_app/screens/duel/defeat_modal.dart';
import 'package:quiz_app/screens/duel/draw_modal.dart';
import 'package:quiz_app/screens/duel/victory_modal.dart';

// Game state provider
final gameStateProvider = StateNotifierProvider.autoDispose<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

class DuelScreen extends ConsumerStatefulWidget {


    bool  isPlayingWithBot;
  
  // Opponent data
  late String  opponentName;
  late String  opponentCountry;
  late String userCountryCode; 
  late String?  userPhotoUrl;
  late String?opponentPhotoUrl;
    DuelScreen({
    required this.isPlayingWithBot,
    required this. opponentName,
    required this. opponentCountry,
    required this.userCountryCode,
      this.opponentPhotoUrl,
      this.userPhotoUrl
  }) : super( );

  @override
  ConsumerState<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends ConsumerState<DuelScreen> {
  bool _showVictoryModal = false;
  bool _showDefeatModal = false;
  bool _showDrawModal = false;
  // Coins earned on victory
  final int _coinsEarned = 50;

  void _showDefeat() {
    setState(() {
      _showDefeatModal = true;
    });
  }
String _getInitials(String name) {
  if (name.isEmpty) return '?';
  
  List<String> words = name.split(' ');
  if (words.length == 1) {
    return words[0][0].toUpperCase();
  } else {
    return (words[0][0] + words[1][0]).toUpperCase();
  }
}
  void _hideDefeat() {
    setState(() {
      _showDefeatModal = false;
    });
  }

  void _showVictoryCelebration() {
    setState(() {
      _showVictoryModal = true;
    });
  }

  void _hideVictoryModal() {
      
    setState(() {
      _showVictoryModal = false;
    });
  }

  void _showDraw() {
    setState(() {
      _showDrawModal = true;
    });
  }

  void _hideDraw() {
    setState(() {
      _showDrawModal = false;
    });
  }

  void _playAgain() {
    setState(() {
      _showVictoryModal = false;
      _showDefeatModal = false;
      _showDrawModal = false;
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

  String _getPageTitle(int navIndex) {
    switch (navIndex) {
      case 0:
        return 'Messages';
      case 1:
        return 'Rank';
      case 2:
        return 'Home';
      case 3:
        return 'Market';
      case 4:
        return 'Settings';
      case 5:
        return 'Duel';
      default:
        return 'Home';
    }
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

    // Check if game is over and show appropriate modal
    if (gameState.isGameOver) {
      if (player1Score > player2Score && !_showVictoryModal) {
        // Show victory modal after a short delay
        Future.delayed(Duration.zero, () {
          _showVictoryCelebration();
        });
      } else if (player2Score > player1Score && !_showDefeatModal) {
        // Show defeat modal after a short delay
        Future.delayed(Duration.zero, () {
          _showDefeat();
        });
      } else if (player1Score == player2Score && !_showDrawModal) {
        // Show draw modal after a short delay
        Future.delayed(Duration.zero, () {
          _showDraw();
        });
      }
    }

    // Update player scores in the providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
        User? user = FirebaseAuth.instance.currentUser;
  String currentUsername = user?.displayName ?? 'Player';
      ref.read(player1Provider.notifier).update((state) => 
        Player(
          avatarUrl: widget.userPhotoUrl ?? '',
          countryCode: widget.userCountryCode, 
          username: currentUsername,
          score: player1Score
        )
      );
      
      ref.read(player2Provider.notifier).update((state) => 
        Player(
          avatarUrl: widget.opponentPhotoUrl ?? '',
           countryCode: widget.opponentCountry,
          username: widget.opponentName,
          score: player2Score
        )
      );
    });

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45.h),
        child: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back_icon.svg',
              width: 35,
              height: 35,
            ),
            onPressed: () => Navigator.pop(context),
            iconSize: 22,
            padding: EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              SizedBox(width: 15.w),
              Text(
                _getPageTitle(5),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
      ),
      body: Stack(
        children: [
        
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Back Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
  radius: 20,
  backgroundColor: Colors.blue[100],
  backgroundImage: player1.avatarUrl.isNotEmpty 
    ? NetworkImage(player1.avatarUrl) 
    : null,
  onBackgroundImageError: (exception, stackTrace) {
    print('Error loading player1 avatar: $exception');
  },
  child: player1.avatarUrl.isEmpty 
    ? Text(
        _getInitials(player1.username),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      )
    : null,
),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: ClipOval(
                                    child: CountryFlag.fromCountryCode(
                                      player1.countryCode,
                                      height: 15,
                                      width: 15,
                                    ),
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
                                        child: result
                                            ? SvgPicture.asset(
                                                'assets/icons/true_answer.svg',
                                                width: 24,
                                                height: 24,
                                              )
                                            : SvgPicture.asset(
                                                'assets/icons/wrong_answer.svg',
                                                width: 24,
                                                height: 24,
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
  backgroundImage: player2.avatarUrl.isNotEmpty 
    ? NetworkImage(player2.avatarUrl) 
    : null,
  child: player2.avatarUrl.isEmpty 
    ? Text(
        _getInitials(player2.username),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      )
    : null,
  backgroundColor: Colors.blue[100],
),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: ClipOval(
                                    child: CountryFlag.fromCountryCode(
                                      player2.countryCode,
                                      height: 15,
                                      width: 15,
                                    ),
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
                                        child: result
                                            ? SvgPicture.asset(
                                                'assets/icons/true_answer.svg',
                                                width: 24,
                                                height: 24,
                                              )
                                            : SvgPicture.asset(
                                                'assets/icons/wrong_answer.svg',
                                                width: 24,
                                                height: 24,
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
                    constraints: BoxConstraints(
                      minHeight: 140,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 2),
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
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              child: Column(
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
                              disabledBackgroundColor: Colors.red,
                              disabledForegroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            onPressed: null,
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

                  const SizedBox(height: 100),

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

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 22),
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
          
           
          if (_showVictoryModal)
            VictoryModal(
              coins: _coinsEarned,
              onPlayAgain: _playAgain,
              onClose: _hideVictoryModal,
            ),
          
           
          if (_showDefeatModal)
            DefeatModal(
              onPlayAgain: _playAgain,
              onClose: _hideDefeat,
            ),

          // Draw Modal
          if (_showDrawModal)
            DrawModal(
              onPlayAgain: _playAgain,
              onClose: _hideDraw,
            ),
        ],
      ),
    );
  }
}