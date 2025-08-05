import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
 
import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/providers/quiz/quiz_controller.dart';
import 'package:quiz_app/providers/quiz/quiz_provider.dart';
import 'package:quiz_app/providers/translations/translation_provider.dart';
import 'package:quiz_app/widgets/translation_helper.dart';

class EventScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);
    final currentQuestionIndex = quizState.currentQuestionIndex;

    // Quiz bitti ise sonuç ekranı
    if (currentQuestionIndex >= quizState.questions.length) {
      return _buildResultScreen(context, quizState, ref);
    }
    final question = quizState.questions[currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.white, // Beyaz arka plan
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back_icon.svg',
            width: 40,
            height: 40,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          ref.tr('home.event'),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [


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
                        child: Icon(
                          result == true
                              ? Icons.check
                              : (result == false ? Icons.close : null),
                          color: Colors.white,
                        ),
                        radius: 16,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Soruya ait görsel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  // Kendi asset yolunu buraya koy, örnek:
                  'assets/images/azerbaijan_baku.jpg',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 160,
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
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: List.generate(question.options.length, (index) {
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
                                  .read(quizControllerProvider.notifier)
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
                }),
              ),
            ),

            
        Spacer(),
            // Next butonu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: GestureDetector(
                onTap: quizState.isAnswerRevealed
                    ? () {
                        ref.read(quizControllerProvider.notifier).goToNextQuestion();
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
                      ref.tr("event.next"),
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
               
                      enabled: !quizState.hasUsedHint && !quizState.isAnswerRevealed,
                      onTap: () {
                        ref.read(quizControllerProvider.notifier).useHint();
                      }),
                  _jokerButton(
                      svgPath:'assets/icons/fifty_fifty.svg',
                    
                      enabled: !quizState.hasUsedFiftyFifty && !quizState.isAnswerRevealed,
                      onTap: () {
                        ref.read(quizControllerProvider.notifier).useFiftyFifty();
                      }),
                  _jokerButton(
                      svgPath: 'assets/icons/true_answer.svg',
                    
                      enabled: !quizState.showCorrectAnswer && !quizState.isAnswerRevealed,
                      onTap: () {
                        ref.read(quizControllerProvider.notifier).showCorrectAnswerHint();
                      }),
                  _jokerButton(
                      svgPath: 'assets/icons/freeze_time.svg',
                
                      enabled: !quizState.hasUsedTimePause && !quizState.isAnswerRevealed,
                      onTap: () {
                        ref.read(quizControllerProvider.notifier).useTimePause();
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

  // Quiz sonu ekranı
  Widget _buildResultScreen(BuildContext context, QuizState state, WidgetRef ref) {
    int correctAnswers = state.answerResults.where((result) => result == true).length;
    int totalQuestions = state.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFF8539A8),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                ref.tr('event.quiz_completed'),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                '${ref.tr("event.your_score")}: $correctAnswers / $totalQuestions',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Yeniden başlat
                },
                child: Text(ref.tr('event.restart')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
