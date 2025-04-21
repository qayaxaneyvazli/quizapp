import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/models/progress/progress.dart';
import 'package:quiz_app/providers/progress/progress_provider.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';

// Provider for quiz progress data



class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizQuestions = ref.watch(quizProgressProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      // For light mode, use the original light mint color, for dark mode use theme background
      backgroundColor: isDarkMode ? theme.scaffoldBackgroundColor : const Color(0xFFCCF2F4),
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            Container(
              // Use the original blue for light mode, theme primary for dark mode
              color: isDarkMode ? colorScheme.primary : const Color(0xFF5B8DEF),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white, // White works on both blue backgrounds
                      size: 24.r,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        "Progress",
                        style: TextStyle(
                          color: Colors.white, // White works on both blue backgrounds
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w), // Balance for back button
                ],
              ),
            ),
            
            // Quiz questions list
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                itemCount: quizQuestions.length,
                separatorBuilder: (context, index) => Divider(
                  // Use a dark color that works in both modes
                  color: const Color.fromARGB(255, 49, 48, 48),
                  thickness: 2.h,
                  indent: 16.w,
                  endIndent: 16.w,
                ),
                itemBuilder: (context, index) {
                  final question = quizQuestions[index];
                  return _buildQuestionItem(question, isDarkMode);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(QuizQuestion question, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question image if available
          if (question.imageUrl != null)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  question.imageUrl!,
                  width: double.infinity,
                  height: 200.h,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200.h,
                      // Use appropriate color for error placeholder
                      color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40.r,
                          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          
          // Question text
          Text(
            question.question,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              // Black text for light mode, white text for dark mode
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // User answer button
          if (question.isCorrect)
            _buildAnswerButton(
              answer: question.userAnswer,
              isCorrect: true,
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User's incorrect answer
                _buildAnswerButton(
                  answer: "Your Answer: ${question.userAnswer}",
                  isCorrect: false,
                  isUserAnswer: true,
                ),
                
                SizedBox(height: 12.h),
                
                // Correct answer
                _buildAnswerButton(
                  answer: "Correct Answer: ${question.correctAnswer}",
                  isCorrect: true,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton({
    required String answer,
    required bool isCorrect,
    bool isUserAnswer = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Text(
        answer,
        style: TextStyle(
          color: Colors.white, // White text works well on both green and red
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}