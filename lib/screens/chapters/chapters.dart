import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
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
      backgroundColor: const Color(0xFFF0EAD6), // Arka plan rengi Fallback
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 70), // Space for back button

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
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(),
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
  child: IconButton(
    icon: SvgPicture.asset(
      'assets/icons/back_icon.svg', // SVG dosyanın yolu
      width: 40, // isteğe bağlı, boyut ayarı
      height: 40,
      // SVG'nin rengini değiştirir (SVG içi 'currentColor' destekliyorsa)
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
      height:270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 77, 77, 73),
            Color.fromARGB(255, 13, 13, 12),
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
        color: index < stars ? Colors.amber : Colors.grey, // Sihir burada!
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
