import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/models/player/player.dart';
import 'package:quiz_app/screens/duel/defeat_modal.dart';
import 'dart:async';
import 'dart:math';
import 'package:quiz_app/screens/duel/victory_modal.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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