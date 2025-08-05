import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quiz_app/models/chapter/chapter.dart';
import 'package:quiz_app/providers/chapter/chapter_provider.dart';
import 'package:quiz_app/screens/level/level_screen.dart';
import 'package:quiz_app/screens/question/question.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/core/services/chapter_service.dart';

class ChapterScreen extends ConsumerStatefulWidget {
  final String language;
  
  const ChapterScreen({Key? key, this.language = 'en'}) : super(key: key);

  @override
  ConsumerState<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends ConsumerState<ChapterScreen> {
  @override
  void initState() {
    super.initState();
    // Dil parametresi varsa, o dil ile yeniden yükle
    if (widget.language != 'en') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chapterProvider.notifier).refreshChapters(language: widget.language);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chaptersAsync = ref.watch(chapterProvider);

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
          chaptersAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    error.toString(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(chapterProvider.notifier).refreshChapters(language: widget.language);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (chapters) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 70), // Space for back button
                    
                    // Generate chapter cards from API data
                    ...chapters.asMap().entries.map((entry) {
                      int index = entry.key;
                      ChapterModel chapter = entry.value;
                      
                      // First chapter (index 0) is always unlocked, others depend on completion
                      bool isLocked = index == 0 ? false : chapter.completionPercent == 0;
                      
                      return Column(
                        children: [
                          Align(
                            alignment: index % 2 == 0 ? Alignment.centerLeft : Alignment.centerRight,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: isLocked ? null : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => LevelScreen(
                                    chapterName: chapter.name,
                                    chapterNumber: chapter.id,
                                  ),
                                ),
                              ),
                              child: _buildChapterCard(
                                chapter.name,
                                locked: isLocked,
                                stars: chapter.starsOutOf5,
                                coinProgress: "${chapter.earnedCoins} / ${chapter.maxCoins}",
                                gemProgress: "${chapter.earnedStars} / ${chapter.maxStars}",
                                percentComplete: "${chapter.completionPercent} %",  
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    }).toList(),
                    
                    const SizedBox(height: 80), // Space for bottom nav bar
                  ],
                ),
              ),
            ),
          ),

          // Back button positioned at the top left
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              icon: SvgPicture.asset(
                'assets/icons/back_icon.svg',
                width: 40,
                height: 40,
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

  Widget _buildChapterCard(
    String title, {
    bool locked = false,
    int stars = 0,
    required String coinProgress,
    required String gemProgress,
    required String percentComplete,
  }) {
    return Container(
      width: 240,
      height: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: locked
              ? [
                  const Color.fromARGB(255, 50, 50, 50),
                  const Color.fromARGB(255, 30, 30, 30),
                ]
              : [
                  const Color.fromARGB(255, 77, 77, 73),
                  const Color.fromARGB(255, 13, 13, 12),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: locked ? Colors.grey : Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 2),
                child: SvgPicture.asset(
                  'assets/icons/Star.svg',
                  width: 20,
                  height: 20,
                  color: index < stars 
                      ? Colors.amber 
                      : (locked ? Colors.grey.shade600 : Colors.grey),
                ),
              );
            }),
          ),
          const SizedBox(height: 15),
          if (locked)
            Center(
              child: Icon(
                Icons.lock,
                size: 60,
                color: Colors.deepPurple.withOpacity(0.7),
              ),
            )
          else
            Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Point.svg',
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      coinProgress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Coins.svg',
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      gemProgress,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SvgPicture.asset(
                      'assets/icons/Brain.svg',
                      width: 28,
                      height: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      percentComplete,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}