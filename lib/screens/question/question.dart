import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
 
import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/providers/quiz/quiz_controller.dart';
import 'package:quiz_app/providers/quiz/quiz_provider.dart';
import 'package:quiz_app/providers/heart/heart_provider.dart';
import 'package:quiz_app/screens/question/not_enough_heart_modal.dart';
class QuizScreen extends ConsumerWidget {
    final int levelId;
  final String levelName;
  final int chapterNumber;

  const QuizScreen({
    Key? key,
    required this.levelId,
    required this.levelName,
    required this.chapterNumber,
  }) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerWithLevelProvider(levelId));
    final currentQuestionIndex = quizState.currentQuestionIndex;
    final hearts = ref.watch(heartsProvider);
    
    // Check if questions are still loading
    final questionsAsync = ref.watch(questionsForLevelProvider(levelId));
    
    return questionsAsync.when(
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(context, error.toString()),
      data: (questions) {
        // If no questions loaded, show error
        if (questions.isEmpty) {
          return _buildErrorScreen(context, 'No questions available for this level');
        }
        
        return _buildQuizScreen(context, ref, quizState, currentQuestionIndex, hearts);
      },
    );
  }
  
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF8539A8),
            ),
            SizedBox(height: 20),
            Text(
              'Loading questions...',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF8539A8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorScreen(BuildContext context, String errorMessage) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              'Error loading questions',
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              errorMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Refresh the questions - we'll handle this in the main build method
                Navigator.pop(context);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuizScreen(BuildContext context, WidgetRef ref, QuizState quizState, int currentQuestionIndex, int hearts) {
    
     WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hearts <= 0) {
        showNotEnoughHeartsModal(
          context,
          onGetTickets: () {
            Navigator.of(context).pop();
            // Navigate to tickets/shop screen
            // Navigator.pushNamed(context, '/shop');
          },
          onOk: () {
            Navigator.of(context).pop();
            Navigator.of(context).pop(); // Go back to previous screen
          },
        );
      }
    });

     if (hearts <= 0) {
      return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF8539A8),
          ),
        ),
      );
    }

    if (currentQuestionIndex >= quizState.questions.length) {
      return _buildResultScreen(context, quizState);
    }
    final question = quizState.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(45.h),
        child: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/back_icon.svg',
              width: 35,
              height: 35,
            ),
            onPressed: () => Navigator.pop(context),
            iconSize: 22,
            padding: EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          titleSpacing: 0,
          title: Row(
            children: [
              SizedBox(width: 15.w),
              Text(
                "Quiz",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          centerTitle: false,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Saat ve üst bar
            Padding(
              padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 4),
              child: Row(
                children: [
                  Text(
                    "22:58",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.image, color: Colors.white, size: 18),
                  const SizedBox(width: 3),
                  Icon(Icons.cloud, color: Colors.white, size: 18),
                  const SizedBox(width: 3),
                  Icon(Icons.phone_android, color: Colors.white, size: 18),
                  const Spacer(),
                  Icon(Icons.signal_wifi_4_bar, color: Colors.white, size: 16),
                  Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
                  Icon(Icons.battery_full, color: Colors.white, size: 16),
                  SizedBox(width: 3),
                  Text(
                    "55%",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),

            // Cevap geçmişi (tik ve çarpı ikonları)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: quizState.answerResults.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final result = entry.value;
                    if (idx >= currentQuestionIndex) return SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: CircleAvatar(
  backgroundColor: result == true
      ? Colors.green
      : (result == false ? Colors.red : Colors.grey),
  child: result == true
      ? SvgPicture.asset(
          'assets/icons/true_answer.svg',
          width: 24,
          height: 24,
        )
      : (result == false
          ? SvgPicture.asset(
              'assets/icons/wrong_answer.svg',
              width: 24,
              height: 24,
            )
          : null),
  radius: 16,
),
                    );
                  }).toList(),
                ),
              ),
            ),

         
         Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      height: 160,
      color: Colors.grey[200],
      child: question.imagePath != null && question.imagePath!.isNotEmpty
          ? Image.asset(
              question.imagePath!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  child: Icon(
                    Icons.image_not_supported,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                );
              },
            )
          : Container(
              color: Colors.grey[200],
              child: Icon(
                Icons.image,
                size: 60,
                color: Colors.grey[400],
              ),
            ),
    ),
  ),
),

            // Soru kutusu
            Container(
               constraints: BoxConstraints(minHeight: 100),
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.purple,width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      question.question,
                      style: TextStyle(
                        color: AppColors.primary ,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        '${currentQuestionIndex + 1}',
                        style: TextStyle(
                            color:AppColors.primary ,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Icon(Icons.public, color: Colors.blue[400], size: 18),
                    ],
                  ),
                ],
              ),
            ),

            // Progress bar (kısa çizgi)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Stack(
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: quizState.timerValue,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Şıklar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: question.isTrueFalse
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int index = 0; index < 2; index++)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12,vertical:32),
                              child: GestureDetector(
                                onTap: quizState.isAnswerRevealed
                                    ? null
                                    : () {
                                        ref
                                            .read(quizControllerWithLevelProvider(levelId).notifier)
                                            .selectAnswer(index);
                                      },
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 180),
                                  height: 110,
                                  decoration: BoxDecoration(
                                    color: quizState.selectedAnswerIndex == index
                                        ? (index == question.correctAnswerIndex && quizState.isAnswerRevealed
                                            ? Colors.green
                                            : quizState.isAnswerRevealed
                                                ? Colors.red
                                                : AppColors.primary)
                                        : AppColors.primary,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                        color: quizState.selectedAnswerIndex == index
                                            ? Colors.amber
                                            : Colors.transparent,
                                        width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 3,
                                        offset: Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      index == 0 ? "True" : "False",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    )
                  : Column(
                      children: List.generate(
                        question.options.length,
                        (index) {
                          final isEliminated = quizState.eliminatedOptions != null &&
                              quizState.eliminatedOptions!.contains(index);
                          final isSelected = quizState.selectedAnswerIndex == index;
                          final isCorrect = index == question.correctAnswerIndex;
                          final showAsCorrect =
                              isCorrect && (quizState.isAnswerRevealed || quizState.showCorrectAnswer);

                          Color buttonColor = AppColors.primary;
                          Color textColor = Colors.white;
                          if (isEliminated) {
                            buttonColor = Colors.grey.shade200;
                            textColor = Colors.grey;
                          } else if (quizState.isAnswerRevealed) {
                            if (isSelected) {
                              buttonColor = isCorrect ? Colors.green : Colors.red;
                              textColor = Colors.white;
                            } else if (isCorrect) {
                              buttonColor = Colors.green;
                              textColor = Colors.white;
                            }
                          } else if (showAsCorrect) {
                            buttonColor = Colors.green;
                            textColor = Colors.white;
                          } else if (isSelected) {
                            buttonColor = Colors.yellow.shade100;
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: GestureDetector(
                              onTap: isEliminated || quizState.isAnswerRevealed
                                  ? null
                                  : () {
                                      ref
                                          .read(quizControllerWithLevelProvider(levelId).notifier)
                                          .selectAnswer(index);
                                    },
                              child: AnimatedContainer(
                                duration: Duration(milliseconds: 180),
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: buttonColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                      color: isSelected
                                          ? Colors.amber
                                          : Colors.transparent,
                                      width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 3,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    question.options[index],
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 17,
                                        color: textColor),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),

            
        Spacer(),
            // Next butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: GestureDetector(
                onTap: quizState.isAnswerRevealed
                    ? () {
                        ref.read(quizControllerWithLevelProvider(levelId).notifier).goToNextQuestion();
                      }
                    : null,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.yellow, Colors.orange],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow.withOpacity(0.2),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Next",
                      style: TextStyle(
                          color: Colors.purple.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 19),
                    ),
                  ),
                ),
              ),
            ),
Spacer(),
            // Joker ve alt bar
            Container(
  margin: EdgeInsets.zero, // margin yok
  padding: EdgeInsets.zero,
              height: 50,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
               _jokerButton(
    svgPath: 'assets/icons/wrong_answer.svg',
    enabled: quizState.hintCount > 0 && !quizState.isAnswerRevealed,
    onTap: () {
      ref.read(quizControllerWithLevelProvider(levelId).notifier).useHint();
    }),
_jokerButton(
    svgPath:'assets/icons/fifty_fifty.svg',
    enabled: quizState.fiftyFiftyCount > 0 && !quizState.isAnswerRevealed,
    onTap: () {
      ref.read(quizControllerWithLevelProvider(levelId).notifier).useFiftyFifty();
    }),
_jokerButton(
    svgPath: 'assets/icons/true_answer.svg',
    enabled: quizState.correctAnswerHintCount > 0 && !quizState.isAnswerRevealed,
    onTap: () {
      ref.read(quizControllerWithLevelProvider(levelId).notifier).showCorrectAnswerHint();
    }),
_jokerButton(
    svgPath: 'assets/icons/freeze_time.svg',
    enabled: quizState.timePauseCount > 0 && !quizState.isAnswerRevealed,
    onTap: () {
      ref.read(quizControllerWithLevelProvider(levelId).notifier).useTimePause();
    }),
                  _jokerButton(
                     svgPath: quizState.hasInfo ? 'assets/icons/info.svg' : 'assets/icons/link.svg',
                      
                      enabled: true,
                      onTap: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Joker butonu widget
Widget _jokerButton({
  required String svgPath, // Artık iconData değil, SVG yolu al
  required bool enabled,
  required VoidCallback onTap, 
}) {
  return Expanded(
    child: GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 78, // Buton boyutu
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary,
        
        ),
        alignment: Alignment.center,
        child: SvgPicture.asset(
          svgPath,
          color: enabled ? null : Colors.grey, // Renk durum
          width: 35, // İkon boyutu
          height: 35, 
        ),
      ),
    ),
  );
}

// Quiz sonu ekranı - Replace the _buildResultScreen method with this
Widget _buildResultScreen(BuildContext context, QuizState state) {
  int correctAnswers = state.answerResults.where((result) => result == true).length;
  int totalQuestions = state.questions.length;
  double percentage = (correctAnswers / totalQuestions) * 100;
  
  // Star rating calculation (out of 5 stars)
  int starCount = 0;
  if (percentage >= 90) starCount = 5;
  else if (percentage >= 70) starCount = 4;
  else if (percentage >= 50) starCount = 3;
  else if (percentage >= 30) starCount = 2;
  else if (percentage >= 10) starCount = 1;

  return Scaffold(
    backgroundColor: AppColors.primary,
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // Status bar
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Row(
                children: [
                  Text(
                    "22:53",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.cloud, color: Colors.white, size: 18),
                  Icon(Icons.tablet_android, color: Colors.white, size: 18),
                  Icon(Icons.phone_android, color: Colors.white, size: 18),
                  const Spacer(),
                  Icon(Icons.volume_off, color: Colors.white, size: 16),
                  Icon(Icons.signal_wifi_4_bar, color: Colors.white, size: 16),
                  Icon(Icons.signal_cellular_4_bar, color: Colors.white, size: 16),
                  Icon(Icons.battery_std, color: Colors.white, size: 16),
                  SizedBox(width: 3),
                  Text(
                    "71%",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Quiz Ended Title
                  Text(
                    'Quiz Ended',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  SizedBox(height: 40),
                  
                  // Stars Rating
                  Container(
                    height: 100,
                    width: 300,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Left stars (lower positions)
                        Positioned(
                          left: 40,
                          top: 30,
                          child: Icon(
                            Icons.star,
                            size: 50,
                            color: 0 < starCount ? Colors.amber : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        Positioned(
                          left: 80,
                          top: 15,
                          child: Icon(
                            Icons.star,
                            size: 50,
                            color: 1 < starCount ? Colors.amber : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        // Center star (highest position - curved upward)
                        Positioned(
                          left: 125,
                          top: 5,
                          child: Icon(
                            Icons.star,
                            size: 50,
                            color: 2 < starCount ? Colors.amber : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        // Right stars (lower positions)
                        Positioned(
                          left: 170,
                          top: 15,
                          child: Icon(
                            Icons.star,
                            size: 50,
                            color: 3 < starCount ? Colors.amber : Colors.white.withOpacity(0.3),
                          ),
                        ),
                        Positioned(
                          left: 220,
                          top: 40,
                          child: Icon(
                            Icons.star,
                            size: 50,
                            color: 4 < starCount ? Colors.amber : Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 50),
                  
                  // Right Answers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Right Answers: ',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      Text(
                        '$correctAnswers/$totalQuestions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 30),
                  
                  // Score with coin icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        '${(correctAnswers * 56)}/2000', // Example score calculation
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Money with coin stack icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        '${(correctAnswers * 112)}/4000', // Example money calculation
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 20),
                  
                  // Percentage with circular icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          Icons.pie_chart,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        '${percentage.toInt()} %',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // OK Button
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 120,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Color(0xFF8539A8),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

}
