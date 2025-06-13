import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quiz_app/screens/question/question.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LevelScreen extends StatelessWidget {
  final String chapterName;
  final int chapterNumber;
  
  const LevelScreen({
    Key? key, 
    required this.chapterName,
    required this.chapterNumber,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EAD6),  
      body: Stack(
        children: [
          // --- BACKGROUND IMAGE ---
          Positioned.fill(
            child: Image.asset(
              'assets/images/Chapter_Background_Image.png',  
              fit: BoxFit.fill,
            ),
          ),

          // --- Main Content ---
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 70), // Space for back button
                  
                  // Chapter Title
                  Container(
                    margin: const EdgeInsets.only(bottom: 30),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 120, 84, 160),
                          Color.fromARGB(255, 80, 50, 120),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      chapterName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  // Level Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: 12, // 12 level per chapter
                    itemBuilder: (context, index) {
                      return _buildLevelCard(
                        context,
                        index + 1,
                        _getLevelData(index + 1),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 80), // Space for bottom nav bar
                ],
              ),
            ),
          ),

          // Back button positioned at the top left
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SvgPicture.asset(
                  'assets/icons/back_icon.svg',
                  width: 44,
                  height: 44,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, int levelNumber, Map<String, dynamic> levelData) {
    bool isLocked = levelData['locked'];
    bool isCompleted = levelData['completed'];
    int stars = levelData['stars'];
    String difficulty = levelData['difficulty'];
    int questions = levelData['questions'];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isLocked ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(), // Level-specific quiz screen
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLocked
                ? [
                    const Color.fromARGB(255, 120, 120, 120),
                    const Color.fromARGB(255, 80, 80, 80),
                  ]
                : isCompleted
                    ? [
                        const Color.fromARGB(255, 46, 125, 50),
                        const Color.fromARGB(255, 27, 94, 32),
                      ]
                    : [
                        const Color.fromARGB(255, 77, 77, 73),
                        const Color.fromARGB(255, 13, 13, 12),
                      ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: isCompleted
              ? Border.all(color: Colors.amber, width: 2)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Level Number with Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$levelNumber',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SvgPicture.asset(
                  _getDifficultyIcon(difficulty),
                  width: 24,
                  height: 24,
                  color: _getDifficultyColor(difficulty),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Level Title
            Text(
              'Level $levelNumber',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Difficulty
            Text(
              difficulty,
              style: TextStyle(
                fontSize: 12,
                color: _getDifficultyColor(difficulty),
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            if (isLocked)
              Icon(
                Icons.lock,
                size: 40,
                color: Colors.white.withOpacity(0.7),
              )
            else
              Column(
                children: [
                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 2),
                        child: SvgPicture.asset(
                          'assets/icons/Star.svg',
                          width: 16,
                          height: 16,
                          color: index < stars ? Colors.amber : Colors.grey,
                        ),
                      );
                    }),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Questions count
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/Brain.svg',
                        width: 16,
                        height: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$questions Q',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  
                  // Completion indicator
                  if (isCompleted)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'COMPLETED',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getLevelData(int levelNumber) {
    // Simulated level data - bu gerçek uygulamada API'den gelecek
    List<Map<String, dynamic>> levelsData = [
      {'locked': false, 'completed': true, 'stars': 3, 'difficulty': 'Easy', 'questions': 10},
      {'locked': false, 'completed': true, 'stars': 2, 'difficulty': 'Easy', 'questions': 10},
      {'locked': false, 'completed': true, 'stars': 3, 'difficulty': 'Easy', 'questions': 12},
      {'locked': false, 'completed': false, 'stars': 1, 'difficulty': 'Medium', 'questions': 15},
      {'locked': false, 'completed': false, 'stars': 0, 'difficulty': 'Medium', 'questions': 15},
      {'locked': true, 'completed': false, 'stars': 0, 'difficulty': 'Medium', 'questions': 18},
      {'locked': true, 'completed': false, 'stars': 0, 'difficulty': 'Hard', 'questions': 20},
      {'locked': true, 'completed': false, 'stars': 0, 'difficulty': 'Hard', 'questions': 20},
      {'locked': true, 'completed': false, 'stars': 0, 'difficulty': 'Hard', 'questions': 22},
      {'locked': true, 'completed': false, 'stars': 0, 'difficulty': 'Expert', 'questions': 25},
      {'locked': true, 'completed': false, 'stars': 0, 'difficulty': 'Expert', 'questions': 25},
      {'locked': true, 'completed': false, 'stars': 0, 'difficulty': 'Expert', 'questions': 30},
    ];
    
    return levelsData[levelNumber - 1];
  }

  String _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return 'assets/icons/Star.svg';
      case 'Medium':
        return 'assets/icons/Point.svg';
      case 'Hard':
        return 'assets/icons/Brain.svg';
      case 'Expert':
        return 'assets/icons/Coins.svg';
      default:
        return 'assets/icons/Star.svg';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      case 'Expert':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }
}