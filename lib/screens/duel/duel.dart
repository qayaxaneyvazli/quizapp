// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';

import 'package:country_flags/country_flags.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/core/services/authoritative_duel.dart';
import 'package:quiz_app/models/game/game_state.dart';
import 'package:quiz_app/models/player/player.dart';
import 'package:quiz_app/models/duel/duel_response.dart';
import 'package:quiz_app/core/utils/duel_converter.dart';
import 'package:quiz_app/core/services/duel_service.dart';
import 'package:quiz_app/providers/duel/duel_state_provider.dart';
import 'package:quiz_app/providers/game/game_state.dart';
import 'package:quiz_app/screens/duel/answer_button.dart';
import 'package:quiz_app/screens/duel/defeat_modal.dart';
import 'package:quiz_app/screens/duel/draw_modal.dart';
import 'package:quiz_app/screens/duel/victory_modal.dart';
import 'package:quiz_app/core/services/websocket_service.dart';

// Game state provider
final gameStateProvider = StateNotifierProvider.autoDispose<GameStateNotifier, GameState>((ref) {
  return GameStateNotifier();
});

class DuelScreen extends ConsumerStatefulWidget {
  final bool isPlayingWithBot;
  
  // Opponent data
  final String opponentName;
  final String opponentCountry;
  final String userCountryCode; 
  final String? userPhotoUrl;
  final String? opponentPhotoUrl;
  final DuelResponse? duelResponse;
  
  const DuelScreen({
    super.key,
    required this.isPlayingWithBot,
    required this.opponentName,
    required this.opponentCountry,
    required this.userCountryCode,
    this.opponentPhotoUrl,
    this.userPhotoUrl,
    this.duelResponse,
  });

  @override
  ConsumerState<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends ConsumerState<DuelScreen> {
  bool _showVictoryModal = false;
  bool _showDefeatModal = false;
  bool _showDrawModal = false;
  // Coins earned on victory
  final int _coinsEarned = 50;
  
  // API integration variables
  int? _duelId;
  bool _isUsingAPI = false;
  List<Map<String, dynamic>> _playerAnswers = [];
  bool _answersSubmitted = false;
  
  // WebSocket integration
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;
  bool _gameStarted = false;
  bool _sentGameStart = false;
  bool _sentReadySignal = false;
  bool _waitingForOpponent = false;
  bool _opponentReady = false;
  Timer? _timerSyncTimer;
  bool _currentAnswerSent = false;

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
    final _ = ref.refresh(gameStateProvider);
  }

  // Initialize WebSocket connection
Future<void> _initializeWebSocket() async {
  try {
    print('🔌 DuelScreen: Initializing WebSocket for duel $_duelId');

    final ok = await _webSocketService.initialize();
    if (!ok) {
      print('❌ DuelScreen: WS init fail');
      return;
    }

    // Event stream’i ÖNCE bağla ki connection_established’ı yakalayalım
    _webSocketSubscription?.cancel();
     await _webSocketService.waitConnected();
    _webSocketSubscription = _webSocketService.eventStream.listen((event) async {
      final type = event['type'] as String?;
      if (type == 'connection_established') {
        print('✅ DuelScreen: connection_established geldi; subscribe ediyorum...');
        final subscribed = await _webSocketService.subscribeToDuel(_duelId!);
        if (!subscribed) {
          print('❌ DuelScreen: subscribe başarısız');
          return;
        }
        print('✅ DuelScreen: subscribe OK');
      } else if (type == 'pusher:subscription_succeeded' || type == 'subscription_succeeded') {
        print('✅ DuelScreen: subscription_succeeded');
      } else {
        _handleWebSocketEvent(event);
      }
    });

    print('✅ DuelScreen: WS init OK (subscribe, connection_established bekleniyor)');
  } catch (e) {
    print('❌ DuelScreen: Error initializing WebSocket: $e');
  }
}


  // Handle WebSocket events
  void _handleWebSocketEvent(Map<String, dynamic> event) {
    final eventType = event['type'] as String?;
    final data = event['data'];
    final timestamp = event['timestamp'];
    
    // Skip heartbeat and internal events for cleaner logging
    if (eventType == 'unknown_event' && data?['event']?.startsWith('pusher:') == true) {
      return; // Skip Pusher internal events
    }
    
    print('📡 DuelScreen received WebSocket event: $eventType');
    print('📡 Event data: $data');
    print('📡 Event timestamp: $timestamp');
    
    switch (eventType) {
  
      case 'duel.matched':
        print('🎯 Duel matched with opponent');
        print('🎯 Match data: $data');
        break;
        
      case 'duel.started':
       if (!_gameStarted) {
      _gameStarted = true;
      _waitingForOpponent = false;
       
    }
   final qIndex = data['question_index'];
  final optionId = data['option_id'];
  final isCorrect = data['is_correct'];
  final answeredBy = data['answered_by'];
  
  final gameNotifier = ref.read(gameStateProvider.notifier);
  gameNotifier.applyAuthoritativeAnswer(
    qIndex: qIndex,
    answeredBy: answeredBy,
    optionId: optionId,
    isCorrect: isCorrect,
  );
  break;
      
        
      case 'duel.answer_submitted':
        print('📝 Opponent submitted answer: $data');
        // Handle opponent's answer submission
        _handleOpponentAnswer(data);
        break;
   case 'duel.update':
      print('📊 Duel update event received $data');
      _handleDuelUpdate(data);
      break;
        case 'duel.answer_result':
  print('📝 Duel answer result event');
  print('📝 Answer result data: $data');
  
  // Parse the result
  if (data != null && data is Map) {
    final isCorrect = data['is_correct'] ?? false;
    final scores = data['scores'] ?? {};
    final answeredBy = data['answered_by'];
    
    print('📊 Player $answeredBy answered: ${isCorrect ? "CORRECT" : "WRONG"}');
    print('📊 Current scores: $scores');
    
    // Update UI if needed
    // You can show a quick animation or update score display
  }
  break;
        
      case 'duel.score_updated':
        print('📊 Score updated: $data');
        // Update scores if needed
        break;
        
      case 'duel.ended':
        print('🏁 Duel ended: $data');
        // Handle duel end
        break;
        
      case 'member_added':
        print('👤 New member joined duel: $data');
        break;
        
      case 'member_removed':
        print('👤 Member left duel: $data');
        break;
        
      case 'connection_established':
        print('✅ WebSocket connection established in DuelScreen');
        break;
        
      case 'subscription_succeeded':
        print('📡 WebSocket subscription succeeded in DuelScreen');
        // After successful subscription, send ready signal and wait for opponent
        if (_duelId != null && !_sentReadySignal) {
          setState(() {
            _waitingForOpponent = true;
          });
          print('⏳ Waiting for opponent to be ready...');
          
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && !_sentReadySignal) {
              print('📤 Sending ready signal for duel $_duelId');
              _webSocketService.sendDuelReady(_duelId!);
              _sentReadySignal = true;
            }
          });
        }
        break;
        
      case 'duel.ready':
        print('🎯 Duel ready signal received in DuelScreen');
        // Mark opponent as ready
        setState(() {
          _opponentReady = true;
        });
        print('✅ Opponent is ready');
        
        // If both players are ready, send start signal
        if (_sentReadySignal && _opponentReady && !_sentGameStart) {
          print('🎯 Both players ready, starting game...');
          setState(() {
            _waitingForOpponent = false;
          });
          
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted && !_sentGameStart) {
              print('📤 Sending game start signal for duel $_duelId');
              _webSocketService.sendGameStart(_duelId!);
              _sentGameStart = true;
            }
          });
        }
        break;
        
      case 'duel.start':
        print('🚀 Game start signal received in DuelScreen');
        if (!_gameStarted) {
          _gameStarted = true;
          // Game is already started, just mark as synchronized
          print('✅ Game synchronized via WebSocket');
        }
        break;
        
      case 'pusher_error':
        print('❌ Pusher error in DuelScreen: $data');
        // Don't block the game for WebSocket errors
        // The game will continue with local fallback
        break;
        
      case 'subscription_error':
        print('❌ Subscription error in DuelScreen: $data');
        // Don't block the game for WebSocket errors
        // The game will continue with local fallback
        break;
        
      case 'error':
        print('❌ WebSocket error in DuelScreen: $data');
        break;
        
      case 'disconnected':
        print('🔌 WebSocket disconnected in DuelScreen');
        break;
        
      default:
        if (eventType != null && !eventType.startsWith('pusher_')) {
          print('❓ Unknown WebSocket event in DuelScreen: $eventType');
          print('❓ Full event data: $event');
        }
    }
  }
void _handleDuelUpdate(dynamic data) {
  if (!mounted) return;
  final Map<String, dynamic> update =
      data is String ? (jsonDecode(data) as Map<String,dynamic>) : Map<String,dynamic>.from(data);

  // 1) Otorite state’i güncelle
  final duelNotifier = ref.read(duelStateProvider.notifier);
  duelNotifier.updateFromWebSocket(update);

  // 2) UI indexine çevir ve GameState’i yalnızca farklıysa ilerlet
  final newZeroBased = duelNotifier.getZeroBasedIndex();
  if (newZeroBased != null && newZeroBased != ref.read(gameStateProvider).currentQuestionIndex) {
    ref.read(gameStateProvider.notifier).goToQuestion(newZeroBased);
    _currentAnswerSent = false;
  }

  // 3) status’e göre bitiş kontrolü
  final status = ref.read(duelStateProvider).status;
  if (status == 'finished') {
    ref.read(gameStateProvider.notifier).endGame();
  }
}
  // Handle opponent's answer submission
  void _handleOpponentAnswer(dynamic data) {
    // This will be called when opponent submits an answer
    // You can update the UI or game state accordingly
    print('Opponent answer data: $data');
  }

  // Collect answer for later submission
 // Send answer immediately to API when selected
Future<void> _sendAnswerToAPIImmediately(int questionIndex, int selectedOptionIndex) async {

  
  if (_duelId == null) return;
  if (_currentAnswerSent) return;
  print('1ci govde');
  final optionId = _webSocketService.store.optionIdForUiIndex(_duelId!, selectedOptionIndex);
  print('store snapshot: ${_webSocketService.store.snapshot(_duelId!)}');
print('optionIdForUiIndex($selectedOptionIndex) => $optionId');
  if (optionId == null || optionId <= 0) {
    // Henüz question_id gelmemiş olabilir -> butonları geçici kapatmak daha iyi
    print('❌ Option mapping not ready. Waiting for duel.update...');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Soru senkronize ediliyor, lütfen bekleyin.')),
    );
    return;
  } print('2ci govde');
  final result = await DuelService.sendAnswer(duelId: _duelId!, optionId: optionId);
  if (result['success'] == true) {
     print('2ci govde ici');
    _currentAnswerSent = true;
  } else {
     print('2ci govde colu');
    final msg = result['error'] ?? 'Unknown error';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cevap gönderilemedi: $msg'), backgroundColor: Colors.red),
    );
  }
  
}
  // Submit all collected answers to API (called at game end)
  Future<void> _submitAllAnswersToAPI() async {
    if (widget.duelResponse == null || _duelId == null || _playerAnswers.isEmpty) return;
    
    try {
      print('Submitting all answers to API: $_playerAnswers');
      
      final result = await DuelService.submitAnswers(
        duelId: _duelId!,
        answers: _playerAnswers,
        botSubmission: false,
      );
      
      if (result['success'] == true) {
        print('✅ All answers submitted successfully');
        print('📊 API response: ${result['data']}');
        
        // Log final game results for debugging
        final gameState = ref.read(gameStateProvider);
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
        
        String gameResult = player1Score > player2Score ? 'WON' : 
                          player2Score > player1Score ? 'LOST' : 'DRAW';
        
        print('🏆 Final Result: Player1: $player1Score, Player2: $player2Score - $gameResult');
      } else {
        print('❌ Failed to submit answers: ${result['error']}');
      }
    } catch (e) {
      print('❌ Exception in _submitAllAnswersToAPI: $e');
    }
  }

  // Submit answer to API (immediate submission - kept for backward compatibility)
  Future<void> _submitAnswerToAPI(int questionIndex, int selectedOptionIndex) async {
    if (widget.duelResponse == null || _duelId == null) return;
    
    try {
      final duelQuestionId = DuelConverter.getDuelQuestionId(widget.duelResponse!, questionIndex);
      final optionId = DuelConverter.getOptionId(widget.duelResponse!, questionIndex, selectedOptionIndex);
      
      print('Submitting answer: duelId=$_duelId, duelQuestionId=$duelQuestionId, optionId=$optionId');
      
      final result = await DuelService.submitAnswer(
        duelId: _duelId!,
        duelQuestionId: duelQuestionId,
        selectedOptionId: optionId,
        timeTaken: 5.0, // Default time, could be calculated from timer
      );
      
      if (result['success'] == true) {
        print('Answer submitted successfully');
      } else {
        print('Failed to submit answer: ${result['error']}');
      }
    } catch (e) {
      print('Exception in _submitAnswerToAPI: $e');
    }
  }

StreamSubscription<DuelWireState>? _duelStateSub;
int? _lastAppliedQIndex;
@override
void initState() {
  super.initState();
  _isUsingAPI = !widget.isPlayingWithBot;
  if (widget.duelResponse != null) {
    _duelId = widget.duelResponse!.duel.id;
    _webSocketService.store.preloadFromCreate(widget.duelResponse!);  // 🔴
    

    WidgetsBinding.instance.addPostFrameCallback((_) {
    if (widget.duelResponse != null) {
        final duelResp = widget.duelResponse!;
    _duelId = duelResp.duel.id;
     _webSocketService.store.preloadFromCreate(duelResp);
    ref.read(duelStateProvider.notifier).initializeFromDuelResponse(duelResp);
      final qs = DuelConverter.convertToGameQuestions(widget.duelResponse!);
      ref.read(gameStateProvider.notifier).initializeWithQuestions(qs);
    }
  });

    _initializeWebSocket();

    // Otorite stream’i dinle
    _duelStateSub = _webSocketService.duelStateStream(_duelId!).listen((snap) {
      // 1) Soru indexini UI’ya uygula (1-based -> 0-based)
        final newUiIndex = (snap.qIndex > 0) ? snap.qIndex - 1 : 0;
  if (_lastAppliedQIndex != snap.qIndex) {
        ref.read(gameStateProvider.notifier).goToQuestion(newUiIndex);
        _currentAnswerSent = false; // yeni soruda tekrar cevap gönderebilelim
        _lastAppliedQIndex = snap.qIndex;

        // (opsiyonel) log
        print('🎯 Authoritative jump -> qIndex=${snap.qIndex} (ui=$newUiIndex), qid=${snap.currentQuestionId}');
      }

      // 2) Bitiş
      if (snap.status == 'finished') {
        ref.read(gameStateProvider.notifier).endGame();
      }
      // (İsteğe bağlı) deadline/scores UI update
    });
  }
}

  @override
  void dispose() {
    // Clean up WebSocket resources
    _webSocketSubscription?.cancel();
    _webSocketService.unsubscribeFromDuel();
    super.dispose();
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
      // Reset answer sent flag for new question
      _currentAnswerSent = false;
      
      // Delay added to ensure the UI has been updated before simulating
     if (widget.isPlayingWithBot) {
    Future.delayed(const Duration(milliseconds: 500), () {
      ref.read(gameStateProvider.notifier).simulatePlayer2Answer();
    });
  }

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
      // Submit all answers to API if using API integration (only once)
      if (_isUsingAPI && _duelId != null && _playerAnswers.isNotEmpty && !_answersSubmitted) {
        _answersSubmitted = true; // Prevent multiple submissions
        Future.delayed(Duration.zero, () {
          _submitAllAnswersToAPI();
        });
      }
      
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
          // Waiting for opponent overlay
          if (_waitingForOpponent)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Waiting for opponent...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_opponentReady)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Opponent is ready!',
                          style: TextStyle(
                            color: Colors.green[300],
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        
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
  backgroundImage: player1.avatarUrl.isNotEmpty && player1.avatarUrl.startsWith('http')
    ? NetworkImage(player1.avatarUrl) 
    : null,
  onBackgroundImageError: player1.avatarUrl.isNotEmpty && player1.avatarUrl.startsWith('http')
    ? (exception, stackTrace) {
        print('Error loading player1 avatar: $exception');
      }
    : null,
  child: player1.avatarUrl.isEmpty || !player1.avatarUrl.startsWith('http')
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
  backgroundImage: player2.avatarUrl.isNotEmpty && player2.avatarUrl.startsWith('http')
    ? NetworkImage(player2.avatarUrl) 
    : null,
  onBackgroundImageError: player2.avatarUrl.isNotEmpty && player2.avatarUrl.startsWith('http')
    ? (exception, stackTrace) {
        print('Error loading player2 avatar: $exception');
      }
    : null,
  child: player2.avatarUrl.isEmpty || !player2.avatarUrl.startsWith('http')
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
    // Select answer locally
    ref.read(gameStateProvider.notifier).selectAnswer(1, index);
     print('--- AnswerButton pressed ---');
        print('_isUsingAPI = $_isUsingAPI');
        print('_duelId = $_duelId');
        print('widget.duelResponse = ${widget.duelResponse}');
        print('gameState.currentQuestionIndex = ${gameState.currentQuestionIndex}');
        print('index (selectedOptionIndex) = $index');
        print('----------------------------');
    // Send answer to API immediately if using API integration
    if (_isUsingAPI && _duelId != null && widget.duelResponse != null) {
      print('is using api true');
      _sendAnswerToAPIImmediately(gameState.currentQuestionIndex, index);
    }
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