import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quiz_app/models/levels/level.dart';
import 'package:quiz_app/screens/question/question.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
class LevelScreen extends StatefulWidget {
  final String chapterName;
  final int chapterNumber;
  final String language;
  
  const LevelScreen({
    Key? key, 
    required this.chapterName,
    required this.chapterNumber,
    this.language = 'en',
  }) : super(key: key);

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  List<LevelModel> levels = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchLevels();
  }

  Future<void> fetchLevels() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await http.get(
        Uri.parse('http://116.203.188.209/api/levelsbyChapter/${widget.chapterNumber}?lang=${widget.language}'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          levels = data.map((json) => LevelModel.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load levels: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading levels: $e';
        isLoading = false;
      });
    }
  }

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
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchLevels,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          else
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
                        widget.chapterName,
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
                      itemCount: levels.length,
                      itemBuilder: (context, index) {
                        final level = levels[index];
                        return _buildLevelCard(context, level, index);
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

  Widget _buildLevelCard(BuildContext context, LevelModel level, int index) {
    // First level is always unlocked, others depend on API data
    bool isLocked = index == 0 ? false : level.isLocked;
    bool isCompleted = level.isCompleted;
    int stars = level.starsEarned;
    String difficulty = level.difficulty;
    int questions = level.questionCount;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: isLocked ? null : () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QuizScreen(
              levelId: level.id,
              levelName: level.name,
              chapterNumber: widget.chapterNumber,
            ),
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
                    '${index + 1}',
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
              level.name.isNotEmpty ? level.name : 'Level ${index + 1}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
                    children: List.generate(level.maxStars, (index) {
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

  String _getDifficultyIcon(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'assets/icons/Star.svg';
      case 'medium':
        return 'assets/icons/Point.svg';
      case 'hard':
        return 'assets/icons/Brain.svg';
      case 'expert':
        return 'assets/icons/Coins.svg';
      default:
        return 'assets/icons/Star.svg';
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      case 'expert':
        return Colors.purple;
      default:
        return Colors.white;
    }
  }
}