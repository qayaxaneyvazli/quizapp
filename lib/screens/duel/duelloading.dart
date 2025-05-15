import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/screens/duel/opponent_found.dart';

// Provider to track if a duel opponent has been found
final duelOpponentProvider = StateProvider<bool>((ref) => false);

class DuelLoadingScreen extends ConsumerStatefulWidget {
  const DuelLoadingScreen({super.key});

  @override
  ConsumerState<DuelLoadingScreen> createState() => _DuelLoadingScreenState();
}

class _DuelLoadingScreenState extends ConsumerState<DuelLoadingScreen> {
  @override
  void initState() {
    super.initState();
    
    // Simulate finding an opponent after some time (for demo purposes)
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        ref.read(duelOpponentProvider.notifier).state = true;
           Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OpponentFoundScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final foundOpponent = ref.watch(duelOpponentProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[600],
      body: Center(
        child: Container(
          width: 300,
          height:450,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF6A1B9A),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                foundOpponent ? "Opponent found!" : "Looking for a duel...",
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                 
                child: Image.asset(
                  'assets/images/glass_animation.gif', 
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                foundOpponent
                    ? "Preparing the duel..."
                    : "Please wait while we find a suitable opponent.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 