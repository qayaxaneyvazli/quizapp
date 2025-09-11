import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_flags/country_flags.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quiz_app/core/services/websocket_service.dart';
import 'package:quiz_app/screens/duel/duel.dart';
import 'package:quiz_app/core/services/duel_service.dart';
import 'package:quiz_app/models/duel/duel_response.dart';
import 'package:quiz_app/core/utils/duel_converter.dart';
import 'dart:math';
import 'dart:async';



StreamSubscription<Map<String, dynamic>>? _wsLogSub;

// Requires: import 'dart:convert';

/// Normalizes WS event `data` (Map<dynamic,dynamic> or JSON String)
/// to a `Map<String, dynamic>?`. Returns null if it's not an object.
Map<String, dynamic>? _toMap(dynamic data) {
  if (data == null) return null;

 
  if (data is Map) {
    return data.map((k, v) => MapEntry(k.toString(), v));
  }

 
  if (data is String && data.isNotEmpty) {
    try {
      final decoded = jsonDecode(data);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {
      // ignore parse errors
    }
  }

  // Not an object
  return null;
}


void _attachWsLogger() {
  _wsLogSub?.cancel();
  _wsLogSub = WebSocketService().eventStream.listen((e) {
    final type = e['type'];
    final data = e['data'];
    final ts = e['timestamp'];
    String payload;
    try {
      payload = data is String
          ? data
          : const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      payload = data.toString();
    }
    debugPrint('🎯 WS [$ts] $type\n$payload');
  }, onError: (err, st) {
    debugPrint('WS LOGGER ERROR: $err');
  });
}



class OpponentFoundScreen extends ConsumerStatefulWidget {
  const OpponentFoundScreen({super.key});

  @override
  ConsumerState<OpponentFoundScreen> createState() => _OpponentFoundScreenState();
}

class _OpponentFoundScreenState extends ConsumerState<OpponentFoundScreen> {
  bool _readyToDuel = false;
  String _userCountryCode = 'AZ'; // Default value
  bool _isLoadingLocation = true;
  bool _isSearchingForPlayer = true;
  bool _isPlayingWithBot = false;
 
  // API integration
  DuelResponse? _duelResponse;
  String? _errorMessage;
  
  // Opponent data
 // Real opponent data
String? _realOpponentName;
String? _realOpponentCountry;
String? _realOpponentPhotoUrl;

// Bot opponent data
String? _botOpponentName;
String? _botOpponentCountry;
String? _botOpponentPhotoUrl;

  bool _isOpponentReal = false;
  
  // WebSocket integration for real-time sync
  final WebSocketService _webSocketService = WebSocketService();
  StreamSubscription<Map<String, dynamic>>? _webSocketSubscription;
  bool _sentReadySignal = false;
  bool _bothPlayersReady = false;
  
  final Random _random = Random();
  bool _isPlayerReady = false;
  bool _isOpponentReady = false;
  bool _waitingForDuelStart = false;
  StreamSubscription<Map<String, dynamic>>? _eventSubscription;
  // Search timeout duration (in seconds) - kept for potential future use
  // static const int _searchTimeout = 10;
  
  // Realistic bot profiles with matching names and countries
  final Map<String, List<String>> _botProfiles = {
    'US': ['James Miller', 'Sarah Johnson', 'Michael Brown', 'Emily Davis', 'David Wilson', 'Jessica Garcia', 'Christopher Rodriguez', 'Ashley Martinez', 'Matthew Anderson', 'Amanda Taylor'],
    'GB': ['Oliver Smith', 'Emma Jones', 'Harry Williams', 'Isla Brown', 'George Davis', 'Ava Miller', 'Noah Wilson', 'Sophia Moore', 'Jack Taylor', 'Grace Anderson'],
    'DE': ['Maximilian Weber', 'Emma Schmidt', 'Alexander Müller', 'Mia Fischer', 'Paul Wagner', 'Hannah Becker', 'Leon Schulz', 'Lina Hoffmann', 'Felix Koch', 'Lea Richter'],
    'FR': ['Louis Martin', 'Emma Bernard', 'Gabriel Dubois', 'Jade Thomas', 'Raphaël Robert', 'Louise Petit', 'Arthur Durand', 'Alice Leroy', 'Hugo Moreau', 'Chloé Simon'],
    'ES': ['Hugo García', 'Lucía Rodríguez', 'Martín López', 'Sofía Martínez', 'Daniel Sánchez', 'María Pérez', 'Pablo Gómez', 'Carmen Martín', 'Alejandro Jiménez', 'Elena Ruiz'],
    'IT': ['Francesco Rossi', 'Sofia Russo', 'Alessandro Ferrari', 'Giulia Esposito', 'Lorenzo Romano', 'Aurora Colombo', 'Matteo Ricci', 'Ginevra Marino', 'Gabriele Greco', 'Alice Conti'],
    'RU': ['Alexander Petrov', 'Anastasia Ivanova', 'Dmitri Volkov', 'Ekaterina Smirnova', 'Maxim Kozlov', 'Daria Popova', 'Nikita Sokolov', 'Polina Lebedeva', 'Ivan Morozov', 'Arina Novikova'],
    'TR': ['Mehmet Yılmaz', 'Zeynep Kaya', 'Mustafa Demir', 'Elif Çelik', 'Ahmet Şahin', 'Ayşe Yıldız', 'Emre Özkan', 'Sude Arslan', 'Burak Doğan', 'Ecrin Kılıç'],
    'JP': ['Hiroshi Tanaka', 'Yuki Suzuki', 'Takeshi Watanabe', 'Sakura Ito', 'Kenji Yamamoto', 'Hana Nakamura', 'Ryo Kobayashi', 'Mei Kato', 'Shun Yoshida', 'Rin Yamada'],
    'KR': ['Min-jun Kim', 'So-young Lee', 'Jae-hyun Park', 'Ji-woo Choi', 'Seung-ho Jung', 'Ye-jin Kang', 'Dong-hyun Cho', 'Min-ji Yoon', 'Hyun-woo Lim', 'Seo-yeon Han'],
    'BR': ['Gabriel Silva', 'Ana Santos', 'Lucas Oliveira', 'Beatriz Costa', 'Mateus Souza', 'Larissa Lima', 'Pedro Ferreira', 'Camila Rodrigues', 'João Almeida', 'Isabela Pereira'],
    'IN': ['Arjun Sharma', 'Priya Patel', 'Rohan Gupta', 'Ananya Singh', 'Vikram Kumar', 'Shreya Agarwal', 'Aditya Verma', 'Kavya Reddy', 'Rahul Jain', 'Pooja Mishra'],
    'CA': ['Liam MacDonald', 'Emma Thompson', 'Noah Campbell', 'Olivia Stewart', 'William Clark', 'Ava Lewis', 'James Walker', 'Sophie Hall', 'Benjamin Young', 'Chloe King'],
    'AU': ['Oliver Johnson', 'Charlotte Smith', 'Jack Williams', 'Amelia Brown', 'William Jones', 'Isla Davis', 'Thomas Wilson', 'Mia Taylor', 'Lucas Anderson', 'Grace White'],
    'NL': ['Daan de Jong', 'Emma van den Berg', 'Sem Bakker', 'Tess Janssen', 'Lucas Visser', 'Julia Smit', 'Milan de Vries', 'Zoë van Dijk', 'Bram Mulder', 'Lotte Bos'],
    'SE': ['William Andersson', 'Alice Johansson', 'Lucas Karlsson', 'Maja Nilsson', 'Oliver Eriksson', 'Ella Larsson', 'Hugo Olsson', 'Astrid Persson', 'Liam Svensson', 'Elsa Gustafsson']
  };
  
  final List<String> _availableCountries = ['US', 'GB', 'DE', 'FR', 'ES', 'IT', 'RU', 'TR', 'JP', 'KR', 'BR', 'IN', 'CA', 'AU', 'NL', 'SE'];
  
  @override
  void initState() {
    super.initState();
    _attachWsLogger();
    _getUserLocation();
    _startPlayerSearch();
      _listenToWebSocketEvents();
  }

@override
void dispose() {
  _wsLogSub?.cancel();
  super.dispose();
}

  void _startPlayerSearch() {
    setState(() {
      _isSearchingForPlayer = true;
      _errorMessage = null;
    });
    
    // Call the API to create a duel
    _createDuelFromAPI();
  }
  
Future<void> _sendReadySignal() async {
    if (_duelResponse == null) {
      print('❌ No duel response available');
      return;
    }
    
    setState(() {
      _isPlayerReady = true;
      _waitingForDuelStart = true;
    });
    
    final duelId = DuelConverter.getDuelId(_duelResponse!);
    print('📤 Sending ready signal for duel $duelId');
    
    // Ensure WebSocket is connected and subscribed
    if (!_webSocketService.isConnected) {
      print('⚠️ WebSocket not connected, initializing first...');
      await _initializeWebSocketConnection();
      await Future.delayed(const Duration(seconds: 1));
    }
    
    // Send ready via API
    final result = await DuelService.sendReady(duelId);
    
    if (result['success'] == true) {
      print('✅ Ready signal sent successfully');
      print('📥 Ready response: ${result['data']}');
      
      // If playing with bot, bot should also send ready automatically
      if (_isPlayingWithBot) {
        print('🤖 Playing with bot, bot should auto-ready on backend');
        
        // Wait a bit for backend to process
        await Future.delayed(const Duration(seconds: 2));
        
        // If still no duel.started event, navigate anyway
        if (mounted && _waitingForDuelStart) {
          print('⏰ Timeout waiting for duel.started with bot, starting anyway...');
          _navigateToDuel();
        }
      } else {
        print('👥 Playing with real player, waiting for opponent ready...');
      }
    } else {
      print('❌ Failed to send ready signal: ${result['error']}');
      setState(() {
        _isPlayerReady = false;
        _waitingForDuelStart = false;
      });
      
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hazır sinyali gönderilemedi: ${result['error']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
   Future<void> _initializeWebSocketConnection() async {
    try {
      print('🔌 Initializing WebSocket connection...');
      final success = await _webSocketService.initialize();
      
      if (success && _duelResponse != null) {
        final duelId = DuelConverter.getDuelId(_duelResponse!);
        print('📡 WebSocket connected, subscribing to duel: $duelId');
        
        await Future.delayed(const Duration(milliseconds: 500));
        await _webSocketService.subscribeToDuel(duelId);
        
        // Re-setup listener after connection
        _listenToWebSocketEvents();
      } else {
        print('❌ Failed to initialize WebSocket');
      }
    } catch (e) {
      print('❌ Error initializing WebSocket: $e');
    }
  }
  
 void _listenToWebSocketEvents() {
  print('🔌 Setting up WebSocket event listener in OpponentFoundScreen');

  _eventSubscription?.cancel();

  if (!_webSocketService.isConnected) {
    print('⚠️ WebSocket not connected, initializing...');
    _initializeWebSocketConnection();
    return;
  }

  _eventSubscription = _webSocketService.eventStream.listen((event) {
    final type = event['type'] as String?;
    final dataMap = _toMap(event['data']) ?? const <String, dynamic>{};
    final currentDuelId =
        _duelResponse != null ? DuelConverter.getDuelId(_duelResponse!) : null;

    // Handle transport-level events regardless of duel id
    switch (type) {
      case 'connection_established':
        print('✅ WebSocket connection established');
        if (_duelResponse != null) {
          final duelId = DuelConverter.getDuelId(_duelResponse!);
          print('📡 Subscribing to duel channel: $duelId');
          _webSocketService.subscribeToDuel(duelId);
        }
        return;

      case 'subscription_succeeded':
        print('✅ Successfully subscribed to duel channel');
        return;
    }

    // From here on, ignore events that don't belong to this duel
    if (currentDuelId == null) return;
    final payloadDuelId = (dataMap['duel_id'] ?? dataMap['match_id']);
    if (payloadDuelId is int && payloadDuelId != currentDuelId) return;
    if (payloadDuelId is String &&
        int.tryParse(payloadDuelId) != currentDuelId) return;

    switch (type) {
      case 'duel.ready':
        // Only UI hint; do NOT navigate
        if (mounted) {
          setState(() {
            _isOpponentReady = true;
          });
        }
        break;

      case 'duel.started':
        // Countdown/overlay; navigation will occur on first running update
        if (mounted) {
          setState(() {
            _isOpponentReady = true;
            _waitingForDuelStart = true;
          });
        }
        break; // <-- important to prevent fall-through

      case 'duel.update': {
        final status = dataMap['status'];
        final qIdxRaw = dataMap['q_index'] ?? dataMap['question_index'];
        final qIndex = qIdxRaw is int ? qIdxRaw : int.tryParse('$qIdxRaw') ?? 0;

        if (status == 'running' && qIndex >= 1) {
          _navigateToDuel();
        }
        break;
      }

      case 'duel.state': {
        // If backend emits a consolidated state event
        final state = dataMap['state'];
        final qRaw = dataMap['question_index'];
        final q = qRaw is int ? qRaw : int.tryParse('$qRaw') ?? 0;

        if ((state == 'running' || state == 'qN_active' || state == 'q1_active') &&
            q >= 1) {
          _navigateToDuel();
        }
        break;
      }

      default:
        if (type != null && !type.startsWith('pusher:')) {
          print('❓ Unknown event: $type');
        }
    }
  });
}
  // _createDuelFromAPI metodunu şu şekilde güncelleyin:

  // _createDuelFromAPI metodunu şu şekilde güncelleyin:

  Future<void> _createDuelFromAPI() async {
    try {
      print('🎮 Creating duel from API...');
      final result = await DuelService.createDuel();
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        final DuelResponse duelResponse = result['data'] as DuelResponse;
        final duelId = DuelConverter.getDuelId(duelResponse);
        
        print('✅ Duel created successfully with ID: $duelId');
        
        setState(() {
          _duelResponse = duelResponse;
          _isSearchingForPlayer = false;
          _isPlayingWithBot = DuelConverter.isOpponentBot(duelResponse);
          _isOpponentReal = !_isPlayingWithBot;
          
          // Set opponent data from API response
          if (_isPlayingWithBot) {
            // For API bots, use realistic names
            final selectedCountry = _availableCountries[_random.nextInt(_availableCountries.length)];
            final namesForCountry = _botProfiles[selectedCountry]!;
            final selectedName = namesForCountry[_random.nextInt(namesForCountry.length)];
            
            _botOpponentName = selectedName;
            _botOpponentCountry = selectedCountry;
            _botOpponentPhotoUrl = null;
            
            print('🤖 Playing with bot disguised as: $selectedName from $selectedCountry');
          } else {
            _realOpponentName = DuelConverter.getOpponentName(duelResponse);
            _realOpponentCountry = 'US'; // This would come from real player data
            _realOpponentPhotoUrl = DuelConverter.getOpponentAvatarUrl(duelResponse);
            print('👥 Playing with real player: $_realOpponentName');
          }
        });
        
        // Initialize WebSocket and subscribe to duel channel
        print('🔌 Initializing WebSocket for duel $duelId...');
        final wsSuccess = await _webSocketService.initialize();
        
        if (wsSuccess) {
          print('✅ WebSocket initialized successfully');
          
          // Wait a bit for connection to establish
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Subscribe to duel channel
          print('📡 Subscribing to duel channel: private-duel.$duelId');
          final subscribeSuccess = await _webSocketService.subscribeToDuel(duelId);
          
          if (subscribeSuccess) {
            print('✅ Successfully subscribed to duel channel');
          } else {
            print('⚠️ Failed to subscribe to duel channel, continuing anyway...');
          }
        } else {
          print('⚠️ Failed to initialize WebSocket, continuing without real-time updates');
        }
        
        // For bot games, we might want to auto-ready after a delay
        if (_isPlayingWithBot) {
          print('🤖 Bot game detected, showing ready button');
          // Don't auto-ready, let user click the button
        }
        
      } else {
        setState(() {
          _isSearchingForPlayer = false;
          _errorMessage = result['error'] ?? 'Failed to create duel';
        });
        print('❌ Failed to create duel: ${result['error']}');
        
        // Handle errors...
        if (result['error']?.toString().contains('Unauthenticated') == true || 
            result['error']?.toString().contains('authentication') == true ||
            result['error']?.toString().contains('Rate limited') == true) {
          print('🤖 Authentication issue detected, switching to local bot');
          _activateLocalBot();
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isSearchingForPlayer = false;
        _errorMessage = 'Network error: $e';
      });
      print('❌ Exception in _createDuelFromAPI: $e');
    }
  }


  Future<void> _searchForRealPlayer() async {
    // This method is kept for backward compatibility but not used anymore
    // The API handles matchmaking automatically
  }

  void _setRealPlayerAsOpponent() {
    if (!mounted) return;
    
    // Set real player data (this would come from your matchmaking service)
    setState(() {
      _isSearchingForPlayer = false;
      _isOpponentReal = true;
      _realOpponentName  = "RealPlayer${_random.nextInt(999)}"; // This would be actual player name
      _realOpponentCountry  = _availableCountries[_random.nextInt(_availableCountries.length)];
      _realOpponentPhotoUrl  = null; // Real player photo URL would come from server
    });
    
    _startDuel();
  }

void _activateLocalBot() {
  if (!mounted) return;
  
  // Select a random country and matching name
  final selectedCountry = _availableCountries[_random.nextInt(_availableCountries.length)];
  final namesForCountry = _botProfiles[selectedCountry]!;
  final selectedName = namesForCountry[_random.nextInt(namesForCountry.length)];
  
  setState(() {
    _isSearchingForPlayer = false;
    _isPlayingWithBot = true;
    _isOpponentReal = false;
    _botOpponentName = selectedName;
    _botOpponentCountry = selectedCountry;
    _botOpponentPhotoUrl = null; // Will use initials from realistic name
  });
  
  print('🤖 Local bot activated: $selectedName from $selectedCountry');
  _startDuel();
}

  // void _generateRandomOpponent() {
  //   _realOpponentName = _randomNames[_random.nextInt(_randomNames.length)];
  //   _realOpponentCountry = _countryCodes[_random.nextInt(_countryCodes.length)];
  //   _realOpponentPhotoUrl = null;  
  // }
Future<bool> _waitForDuelStarted(int duelId, {Duration timeout = const Duration(seconds: 8)}) async {
  try {
    final event = await WebSocketService()
        .eventStream
        .firstWhere((e) {
          final type = (e['type'] as String? ?? '');
          if (type != 'DuelStarted') return false;

          // data string olabilir, map olabilir
          final raw = e['data'];
          final map = raw is String ? jsonDecode(raw) : raw as Map<String, dynamic>?;
          if (map == null) return false;

          return map['duel_id'] == duelId;
        })
        .timeout(timeout);
           
    return event != null; // bulunduysa true
  } catch (_) {
    return false; // timeout vs.
  }
}

void _startDuel() {
  if (_isPlayingWithBot) {
    // For bot games, start immediately
    _startDuelImmediately();
  } else {
    // For real player games, start with a delay to simulate waiting for opponent
    print('🎯 Real player duel, starting with delay...');
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        print('🚀 Starting duel for real player');
        _startDuelImmediately();
      }
    });
  }
}

void _startDuelImmediately() {
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      setState(() {
        _readyToDuel = true;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _navigateToDuel();
        }
      });
    }
  });
}

  void _navigateToDuel() {
    if (!mounted) return;
    
    setState(() {
      _waitingForDuelStart = false;
    });
    
    User? user = FirebaseAuth.instance.currentUser;
    String? userPhotoUrl = user?.photoURL;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => DuelScreen(
          isPlayingWithBot: _isPlayingWithBot,
          opponentName: _isOpponentReal ? _realOpponentName! : _botOpponentName!,
          opponentCountry: _isOpponentReal ? _realOpponentCountry! : _botOpponentCountry!,
          userCountryCode: _userCountryCode,
          userPhotoUrl: userPhotoUrl,
          opponentPhotoUrl: _isOpponentReal ? _realOpponentPhotoUrl : _botOpponentPhotoUrl,
          duelResponse: _duelResponse,
        ),
      ),
    );
  }

// WebSocket methods removed for now - using simple fallback mechanism

  Future<void> _getUserLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission(); 
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );

      // Get country from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty && mounted) {
        String? countryCode = placemarks.first.isoCountryCode;
        if (countryCode != null) {
          setState(() {
            _userCountryCode = countryCode;
            _isLoadingLocation = false;
          });
        } else {
          setState(() {
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

 String _getStatusText() {
    if (_errorMessage != null) {
      return 'Xəta baş verdi. Bot ilə oyun başlayır...';
    } else if (_isSearchingForPlayer) {
      return 'Oyunçu axtarılır...';
    } else if (_waitingForDuelStart) {
      if (_isOpponentReady) {
        return 'Oyun başladılır...';
      } else {
        return 'Rəqib gözlənilir...';
      }
    } else if (_isPlayerReady) {
      return 'Hazırsınız!';
    } else if (_duelResponse != null) {
      return 'Rəqib tapıldı! Hazır olduğunuzda "HAZIRIM" düyməsinə basın';
    } else {
      return 'Hazırlanır...';
    }
  }

  // Helper method to get initials from name
  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    List<String> words = name.split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    } else {
      return (words[0][0] + words[1][0]).toUpperCase();
    }
  }

  // Helper method to build avatar widget
  Widget _buildAvatar({
    required String name,
    String? photoUrl,
    required double size,
    bool isBot = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.blue, width: 2),
      ),
      child: ClipOval(
        child: photoUrl != null
            ? Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.blue[100],
                    child: Center(
                      child: Text(
                        _getInitials(name),
                        style: TextStyle(
                          fontSize: size * 0.4,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: Colors.blue[100],
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        _getInitials(name),
                        style: TextStyle(
                          fontSize: size * 0.4,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                    if (isBot)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.smart_toy,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

 @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    String? displayName = user?.displayName;
    String? photoUrl = user?.photoURL;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Main content
          Center(
            child: AnimatedOpacity(
              opacity: _waitingForDuelStart ? 0.5 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // Status text
                  Text(
                    _getStatusText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Top user (Opponent)
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 40),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              _isSearchingForPlayer
                                  ? Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.grey, width: 2),
                                      ),
                                      child: ClipOval(
                                        child: Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.search,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    )
                                  : _buildAvatar(
                                      name: _isOpponentReal ? (_realOpponentName ?? 'Player') : (_botOpponentName ?? 'Bot'),
                                      photoUrl: _isOpponentReal ? _realOpponentPhotoUrl : _botOpponentPhotoUrl,
                                      size: 80,
                                      isBot: _isPlayingWithBot,
                                    ),
                              if (!_isSearchingForPlayer)
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: ClipOval(
                                      child: CountryFlag.fromCountryCode(
                                        _isOpponentReal ? (_realOpponentCountry ?? 'US') : (_botOpponentCountry ?? 'US'),
                                        height: 24,
                                        width: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              // Ready indicator for opponent
                              if (_isOpponentReady)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isSearchingForPlayer ? '???' : (_isOpponentReal ? (_realOpponentName ?? 'Player') : (_botOpponentName ?? 'Bot')),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isOpponentReady)
                            const Text(
                              'HAZIR',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Middle brain logo
                  Container(
                    width: 180,
                    height: 180,
                    child: SvgPicture.asset(
                      'assets/images/opponentfound_brain.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Bottom user (Current user)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 40),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              _buildAvatar(
                                name: displayName ?? 'Player',
                                photoUrl: photoUrl,
                                size: 80,
                              ),
                              Positioned(
                                bottom: -2,
                                right: -2,
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: ClipOval(
                                    child: _isLoadingLocation
                                        ? Container(
                                            color: Colors.grey[300],
                                            child: const SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : CountryFlag.fromCountryCode(
                                            _userCountryCode,
                                            height: 24,
                                            width: 24,
                                          ),
                                  ),
                                ),
                              ),
                              // Ready indicator for player
                              if (_isPlayerReady)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayName ?? 'Player',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_isPlayerReady)
                            const Text(
                              'HAZIR',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  
                  // Ready button or status
                  if (!_isSearchingForPlayer && _duelResponse != null)
                    Column(
                      children: [
                        if (!_isPlayerReady)
                          ElevatedButton.icon(
                            onPressed: _sendReadySignal,
                            icon: const Icon(Icons.check_circle),
                            label: const Text(
                              'HAZIRIM',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                          ),
                        
                        if (_isPlayerReady && !_isPlayingWithBot)
                          Column(
                            children: [
                              const CircularProgressIndicator(
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _isOpponentReady 
                                  ? 'Oyun başlatılıyor...' 
                                  : 'Rəqib gözlənilir...',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  
                  // Search progress indicator
                  if (_isSearchingForPlayer)
                    Column(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 10),
                        const Text(
                          'Oyuncu axtarılır...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          
          // Waiting overlay
          if (_waitingForDuelStart)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          _isOpponentReady 
                            ? 'Oyun başlayır...' 
                            : 'Rəqib gözlənilir...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}