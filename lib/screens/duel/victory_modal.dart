import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

import 'package:quiz_app/core/constants/app_colors.dart';

class VictoryModal extends StatefulWidget {
  final int coins;
  final VoidCallback onPlayAgain;
  final VoidCallback onClose;

  const VictoryModal({
    Key? key,
    required this.coins,
    required this.onPlayAgain,
    required this.onClose,
  }) : super(key: key);

  @override
  State<VictoryModal> createState() => _VictoryModalState();
}

class _VictoryModalState extends State<VictoryModal> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 10));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  // Özel yıldız şekli oluşturucu fonksiyon
  Path drawStar(Size size) {
    // Yıldız için bir path oluştur
    double halfWidth = size.width / 2;
    double halfHeight = size.height / 2;
    
    double outerRadius = halfWidth;
    double innerRadius = halfWidth / 2;
    int numPoints = 5;
    
    double angle = (2 * pi) / numPoints;
    
    Path path = Path();
    
    for (int i = 0; i < numPoints; i++) {
      // Dış nokta
      double outerX = halfWidth + outerRadius * cos(i * angle - pi / 2);
      double outerY = halfHeight + outerRadius * sin(i * angle - pi / 2);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      
      // İç nokta
      double innerX = halfWidth + innerRadius * cos((i + 0.5) * angle - pi / 2);
      double innerY = halfHeight + innerRadius * sin((i + 0.5) * angle - pi / 2);
      
      path.lineTo(innerX, innerY);
    }
    
    // Yolu kapat
    path.close();
    
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Semi-transparent background overlay
        GestureDetector(
          onTap: widget.onClose,
          child: Container(
            color: Colors.black.withOpacity(0.3), // Daha az opak yapıldı
          ),
        ),
        
        // Modal content - merkeze yerleştirildi
        Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'You have won the duel!',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${widget.coins}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.star,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'You have earned ${widget.coins} coins!',
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Play Again button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onPlayAgain,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Play Again',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Close button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (mounted) {
                            widget.onClose();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Confetti effects - Merkezden başlayıp her yöne yayılan
        // Ana confetti - yukarıdan aşağıya
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 2, // Aşağı yön
            maxBlastForce: 20,
            minBlastForce: 15,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.3,
            shouldLoop: false,
            createParticlePath: drawStar,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.cyan,
            ],
          ),
        ),
        
        // Sol üst confetti
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -3 * pi / 4, // Sol üst
            maxBlastForce: 15,
            minBlastForce: 10,
            emissionFrequency: 0.03,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
            createParticlePath: drawStar,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.cyan,
            ],
          ),
        ),
        
        // Sağ üst confetti
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 4, // Sağ üst
            maxBlastForce: 15,
            minBlastForce: 10,
            emissionFrequency: 0.03,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
            createParticlePath: drawStar,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.cyan,
            ],
          ),
        ),
        
        // Sol confetti
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi, // Sol
            maxBlastForce: 18,
            minBlastForce: 12,
            emissionFrequency: 0.04,
            numberOfParticles: 25,
            gravity: 0.1,
            shouldLoop: false,
            createParticlePath: drawStar,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.cyan,
            ],
          ),
        ),
        
        // Sağ confetti
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 0, // Sağ
            maxBlastForce: 18,
            minBlastForce: 12,
            emissionFrequency: 0.04,
            numberOfParticles: 25,
            gravity: 0.1,
            shouldLoop: false,
            createParticlePath: drawStar,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.cyan,
            ],
          ),
        ),
        
        // Sol alt confetti
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 3 * pi / 4, // Sol alt
            maxBlastForce: 15,
            minBlastForce: 10,
            emissionFrequency: 0.03,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
            createParticlePath: drawStar,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.cyan,
            ],
          ),
        ),
        
        // Sağ alt confetti
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: pi / 4, // Sağ alt
            maxBlastForce: 15,
            minBlastForce: 10,
            emissionFrequency: 0.03,
            numberOfParticles: 20,
            gravity: 0.2,
            shouldLoop: false,
            createParticlePath: drawStar,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.cyan,
            ],
          ),
        ),
        
        // Yukarı confetti
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2, // Yukarı
            maxBlastForce: 20,
            minBlastForce: 15,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.3,
            shouldLoop: false,
            createParticlePath: drawStar,
            colors: const [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.cyan,
            ],
          ),
        ),
      ],
    );
  }
}