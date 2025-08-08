import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_flags/country_flags.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quiz_app/screens/duel/duel.dart';
import 'package:quiz_app/core/services/duel_service.dart';
import 'package:quiz_app/models/duel/duel_response.dart';
import 'package:quiz_app/core/utils/duel_converter.dart';
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
  
  final Random _random = Random();
  
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
    _getUserLocation();
    _startPlayerSearch();
  }

  void _startPlayerSearch() {
    setState(() {
      _isSearchingForPlayer = true;
      _errorMessage = null;
    });
    
    // Call the API to create a duel
    _createDuelFromAPI();
  }

  Future<void> _createDuelFromAPI() async {
    try {
      print('Creating duel from API...');
      final result = await DuelService.createDuel();
      
      if (!mounted) return;
      
      if (result['success'] == true) {
        final DuelResponse duelResponse = result['data'] as DuelResponse;
        setState(() {
          _duelResponse = duelResponse;
          _isSearchingForPlayer = false;
          _isPlayingWithBot = DuelConverter.isOpponentBot(duelResponse);
          _isOpponentReal = !_isPlayingWithBot;
          
          // Set opponent data from API response
          if (_isPlayingWithBot) {
            // For API bots, use realistic names instead of generic "Bot"
            final selectedCountry = _availableCountries[_random.nextInt(_availableCountries.length)];
            final namesForCountry = _botProfiles[selectedCountry]!;
            final selectedName = namesForCountry[_random.nextInt(namesForCountry.length)];
            
            _botOpponentName = selectedName;
            _botOpponentCountry = selectedCountry;
            _botOpponentPhotoUrl = null; // Use initials from realistic name
            
            print('🤖 API bot disguised as: $selectedName from $selectedCountry');
          } else {
            _realOpponentName = DuelConverter.getOpponentName(duelResponse);
            _realOpponentCountry = 'US'; // This would come from real player data
            _realOpponentPhotoUrl = DuelConverter.getOpponentAvatarUrl(duelResponse);
          }
        });
        
        print('Duel created successfully. Opponent: ${DuelConverter.getOpponentName(duelResponse)}, isBot: ${DuelConverter.isOpponentBot(duelResponse)}');
        _startDuel();
      } else {
        setState(() {
          _isSearchingForPlayer = false;
          _errorMessage = result['error'] ?? 'Failed to create duel';
        });
        print('❌ Failed to create duel: ${result['error']}');
        
        // Immediate fallback to local bot for authentication issues
        if (result['error']?.toString().contains('Unauthenticated') == true || 
            result['error']?.toString().contains('authentication') == true ||
            result['error']?.toString().contains('Rate limited') == true) {
          print('🤖 Authentication issue detected, immediately switching to local bot');
          _activateLocalBot();
        } else {
          // Other errors - wait 3 seconds before fallback
          if (!_isPlayingWithBot && !_isOpponentReal) {
            Future.delayed(const Duration(seconds: 3), () {
              if (mounted && _duelResponse == null && !_isPlayingWithBot && !_isOpponentReal) {
                print('⚠️ API failed, activating local bot as fallback');
                _activateLocalBot();
              }
            });
          }
        }
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isSearchingForPlayer = false;
        _errorMessage = 'Network error: $e';
      });
      print('Exception in _createDuelFromAPI: $e');
      
      // Fallback to local bot after 3 seconds (only if not already done)
      if (!_isPlayingWithBot && !_isOpponentReal) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _duelResponse == null && !_isPlayingWithBot && !_isOpponentReal) {
            print('⚠️ Exception occurred, activating local bot as fallback');
            _activateLocalBot();
          }
        });
      }
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
                duelResponse: _duelResponse, // Pass the duel response
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
    if (_errorMessage != null) {
      return 'Xəta baş verdi. Bot ilə oyun başlayır...';
    } else if (_isSearchingForPlayer) {
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