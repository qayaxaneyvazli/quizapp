import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_flags/country_flags.dart';
import 'package:quiz_app/screens/duel/duel.dart';

class OpponentFoundScreen extends ConsumerStatefulWidget {
  const OpponentFoundScreen({super.key});

  @override
  ConsumerState<OpponentFoundScreen> createState() => _OpponentFoundScreenState();
}

class _OpponentFoundScreenState extends ConsumerState<OpponentFoundScreen> {
  bool _readyToDuel = false;
  
  @override
  void initState() {
    super.initState();
    
    // Wait for 5 seconds and then set ready to duel
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _readyToDuel = true;
        });
        
        // Navigate to the actual duel screen after changing state
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            // TODO: Replace with your actual navigation to duel screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => DuelScreen()),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              // Top user (MrBrain)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 40),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/user_mrbrain.png',
                                fit: BoxFit.cover,
                              ),
                            ),
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
                                child: CountryFlag.fromCountryCode(
                                  'DE', // Germany
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "MrBrain",
                        style: TextStyle(
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
              
              // Bottom user (Melikmemmed)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blue, width: 2),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/user_melikmemmed.png',
                                fit: BoxFit.cover,
                              ),
                            ),
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
                                child: CountryFlag.fromCountryCode(
                                  'AZ', // Azerbaijan
                                  height: 24,
                                  width: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Melikmemmed",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),
              
          
            ],
          ),
        ),
      ),
    );
  }
}