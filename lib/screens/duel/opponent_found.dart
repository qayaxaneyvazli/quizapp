import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_flags/country_flags.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quiz_app/screens/duel/duel.dart';
import 'dart:math';

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
  
  final Random _random = Random();
  
  // Search timeout duration (in seconds)
  static const int _searchTimeout = 10;
  
  // Lists for random generation
  final List<String> _randomNames = [
    'BrainMaster',
    'QuizKing',
    'ThinkFast',
    'MindReader',
    'SmartGuy',
    'LogicLord',
    'WisdomWolf',
    'CleverCat',
    'GeniusOne',
    'BrainStorm',
    'QuickWit',
    'MasterMind',
    'PuzzlePro',
    'ThinkTank',
    'BrainBox',
    'IQHero',
    'SmartStar',
    'WiseOwl',
    'QuizWhiz',
    'MindBender',
    'BrainWave',
    'LogicLover',
    'PuzzleKing',
    'SmartCookie',
    'ThinkGiant',
    'WisdomSeeker',
    'BrainPower',
    'QuizMaster',
    'MindGames',
    'LogicNinja'
  ];
  
  final List<String> _countryCodes = [
    'US', 'GB', 'DE', 'FR', 'ES', 'IT', 'CA', 'AU', 'JP', 'KR',
    'CN', 'RU', 'BR', 'MX', 'AR', 'IN', 'PK', 'BD', 'ID', 'PH',
    'VN', 'TH', 'MY', 'SG', 'NL', 'BE', 'CH', 'AT', 'SE', 'NO',
    'DK', 'FI', 'PL', 'CZ', 'SK', 'HU', 'RO', 'BG', 'HR', 'SI',
    'EE', 'LV', 'LT', 'GR', 'TR', 'EG', 'SA', 'AE', 'QA', 'KW',
    'IL', 'JO', 'LB', 'SY', 'IQ', 'IR', 'AF', 'PK', 'NP', 'LK',
    'MM', 'KH', 'LA', 'MN', 'KZ', 'UZ', 'TM', 'KG', 'TJ', 'GE',
    'AM', 'BY', 'UA', 'MD', 'LT', 'LV', 'EE', 'PT', 'IE', 'IS',
    'MT', 'CY', 'LU', 'MC', 'LI', 'SM', 'VA', 'AD', 'MA', 'TN',
    'DZ', 'LY', 'SD', 'ET', 'KE', 'UG', 'TZ', 'RW', 'BI', 'DJ'
  ];
  
  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _startPlayerSearch();
  }

  void _startPlayerSearch() {
    setState(() {
      _isSearchingForPlayer = true;
    });
    
    // Simulate searching for a real player
    _searchForRealPlayer();
    
    // Set timeout for player search
    Future.delayed(Duration(seconds: _searchTimeout), () {
      if (mounted && _isSearchingForPlayer) {
        // No real player found, activate bot
        _activateBot();
      }
    });
  }

  Future<void> _searchForRealPlayer() async {
    // TODO: Implement real player search logic here
    // This would typically involve:
    // 1. Connecting to your matchmaking service
    // 2. Searching for available players
    // 3. If found, set opponent data and mark as real player
    
    // For now, we'll simulate a random chance of finding a real player
    await Future.delayed(Duration(seconds: 2));
    
    if (mounted) {
      // Simulate 20% chance of finding a real player
      bool foundRealPlayer = _random.nextDouble() < 0.2;
      
      if (foundRealPlayer) {
        _setRealPlayerAsOpponent();
      }
      // If no real player found, the timeout will handle bot activation
    }
  }

  void _setRealPlayerAsOpponent() {
    if (!mounted) return;
    
    // Set real player data (this would come from your matchmaking service)
    setState(() {
      _isSearchingForPlayer = false;
      _isOpponentReal = true;
      _realOpponentName  = "RealPlayer${_random.nextInt(999)}"; // This would be actual player name
      _realOpponentCountry  = _countryCodes[_random.nextInt(_countryCodes.length)];
      _realOpponentPhotoUrl  = null; // Real player photo URL would come from server
    });
    
    _startDuel();
  }

void _activateBot() {
  if (!mounted) return;
  
  setState(() {
    _isSearchingForPlayer = false;
    _isPlayingWithBot = true;
    _isOpponentReal = false;
    _botOpponentName = _randomNames[_random.nextInt(_randomNames.length)];
    _botOpponentCountry = _countryCodes[_random.nextInt(_countryCodes.length)];
    _botOpponentPhotoUrl = null;
  });
  
  _startDuel();
}

  // void _generateRandomOpponent() {
  //   _realOpponentName = _randomNames[_random.nextInt(_randomNames.length)];
  //   _realOpponentCountry = _countryCodes[_random.nextInt(_countryCodes.length)];
  //   _realOpponentPhotoUrl = null;  
  // }

void _startDuel() {
  Future.delayed(const Duration(seconds: 2), () {
    if (mounted) {
      setState(() {
        _readyToDuel = true;
      });
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
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
              ),
            ),
          );
        }
      });
    }
  });
}

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
    if (_isSearchingForPlayer) {
      return 'Oyunçu axtarılır...';
    } else if (_isPlayingWithBot) {
      return 'Oyunçu tapıldı!';
    } else if (_isOpponentReal) {
      return 'Oyunçu tapıldı!';
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
      body: Center(
        child: AnimatedOpacity(
          opacity: _readyToDuel ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 500),
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
              
              // Top user (Opponent or placeholder)
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
                                size:80,
name: _isOpponentReal ? (_realOpponentName ?? 'Player') : (_botOpponentName ?? 'Bot'),
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
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
              // Search progress indicator
              if (_isSearchingForPlayer)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(
                      'Oyunçu axtarılır...',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              
              // Debug info (remove in production)
              if (!_isSearchingForPlayer)
                Column(
                  children: [
                    Text(
                      'Your Country: $_userCountryCode',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  Text(
  'Opponent: ${_isOpponentReal ? (_realOpponentName ?? 'Unknown') : (_botOpponentName ?? 'Bot')} (${_isOpponentReal ? (_realOpponentCountry ?? 'Unknown') : (_botOpponentCountry ?? 'Unknown')})',
  style: const TextStyle(
    fontSize: 12,
    color: Colors.grey,
  ),
),
                    Text(
                      _isPlayingWithBot ? 'Bot ilə oyun' : 'Real oyunçu ilə oyun',
                      style: TextStyle(
                        fontSize: 12,
                        color: _isPlayingWithBot ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}