import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/screens/question/question.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class ChapterScreen extends StatelessWidget {
  const ChapterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EAD6), // Beige background color
      body: Stack(
        children: [
          // Background science illustrations would be here in a real app
          // For this example, we'll focus on the chapter cards
          
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 70), // Space for back button
                  
                  // Chapters laid out in a staggered way as shown in the image
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildChapterCard(
                      "Chapter 4", 
                      locked: true,
                      stars: 0,
                      coinProgress: "0 / 20000",
                      gemProgress: "0 / 40000",
                      percentComplete: "0 %",
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _buildChapterCard(
                      "Chapter 3", 
                      stars: 1,
                      coinProgress: "4000 / 20000",
                      gemProgress: "8000 / 40000",
                      percentComplete: "20 %",
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildChapterCard(
                      "Chapter 2", 
                      stars: 5,
                      coinProgress: "20000 / 20000",
                      gemProgress: "40000 / 40000",
                      percentComplete: "100 %",
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
             Align(
  alignment: Alignment.centerLeft,
  child: InkWell(                         // ① tap algılama
    borderRadius: BorderRadius.circular(12), // kartın kenarlarıyla uyumlu olsun
    onTap: () => Navigator.push(         // ② yönlendirme
      context,
      MaterialPageRoute(
        builder: (_) =>   QuizScreen(),
      ),
    ),
    child: _buildChapterCard(
      "Chapter 1",
      stars: 3,
      coinProgress: "11000 / 20000",
      gemProgress: "22000 / 40000",
      percentComplete: "55 %",
    ),
  ),
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
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.7),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black54),
                onPressed: () {
                  // Navigate back to the previous screen
                  Navigator.pop(context);
                },
              ),
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
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD7A9E3), // Light purple
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 10),
          
          // Star rating
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < stars ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 20,
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
                // Coin progress
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.monetization_on, color: Colors.white, size: 14),
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
                
                // Gem progress
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.diamond, color: Colors.white, size: 14),
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
                
                // Percentage complete
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.purpleAccent,
                      child: Icon(Icons.emoji_events, color: Colors.white, size: 14),
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

// Usage example
class ScienceLearningApp extends StatelessWidget {
  const ScienceLearningApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ChapterScreen(),
    );
  }
}