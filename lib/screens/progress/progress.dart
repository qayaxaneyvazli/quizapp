import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// Provider for quiz progress data
final quizProgressProvider = StateProvider<List<QuizQuestion>>((ref) {
  return [
    QuizQuestion(
      question: "What is the capital of Azerbaijan?",
      userAnswer: "Baku",
      correctAnswer: "Baku",
      imageUrl: "assets/images/baku.jpg",
      isCorrect: true,
    ),
    QuizQuestion(
      question: "What is the largest planet in our solar system?",
      userAnswer: "Jupiter",
      correctAnswer: "Jupiter",
      imageUrl: null,
      isCorrect: true,
    ),
    QuizQuestion(
      question: "What is 2 + 2?",
      userAnswer: "4",
      correctAnswer: "4",
      imageUrl: null,
      isCorrect: true,
    ),
    QuizQuestion(
      question: "Which famous Japanese electronic company was originally founded as a rice cooker manufacturer?",
      userAnswer: "Panasonic",
      correctAnswer: "Sony",
      imageUrl: null,
      isCorrect: false,
    ),
  ];
});

class QuizQuestion {
  final String question;
  final String userAnswer;
  final String correctAnswer;
  final String? imageUrl;
  final bool isCorrect;

  QuizQuestion({
    required this.question,
    required this.userAnswer,
    required this.correctAnswer,
    this.imageUrl,
    required this.isCorrect,
  });
}

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizQuestions = ref.watch(quizProgressProvider);
    
    return Scaffold(
      backgroundColor: const Color(0xFFCCF2F4), // Light mint background
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            Container(
              color: const Color(0xFF5B8DEF),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
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
                          color: Colors.white,
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
                  color: const Color.fromARGB(255, 49, 48, 48),
                  thickness: 2.h,
                  indent: 16.w,
                  endIndent: 16.w,
                ),
                itemBuilder: (context, index) {
                  final question = quizQuestions[index];
                  return _buildQuestionItem(question);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(QuizQuestion question) {
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
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 40.r,
                          color: Colors.grey[600],
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
              color: Colors.black,
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
          color: Colors.white,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}