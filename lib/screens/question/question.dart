
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/models/question/question.dart';
import 'package:quiz_app/providers/quiz/quiz_controller.dart';
import 'package:quiz_app/providers/quiz/quiz_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Model for Quiz Question
// Model for Quiz Question
import 'package:flutter/material.dart';
 
import 'dart:async';

 
class QuizScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizState = ref.watch(quizControllerProvider);
    final currentQuestionIndex = quizState.currentQuestionIndex;
    
    print("Current eliminated options: ${quizState.eliminatedOptions}");
    // Tüm sorular bittiyse sonuç ekranı göster
    if (currentQuestionIndex >= quizState.questions.length) {
      return _buildResultScreen(context, quizState);
    }
    
    final question = quizState.questions[currentQuestionIndex];
    
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Answer history
            Container(
              padding: EdgeInsets.all(10),
              color: Colors.grey[200],
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      // Handle back button
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: quizState.answerResults.asMap().entries.map((entry) {
                          int index = entry.key;
                          bool? result = entry.value;
                          
                          // Henüz cevaplanmamış sorular için boşluk göster
                          if (index >= currentQuestionIndex) return SizedBox.shrink();
                          
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 2),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: result == null ? Colors.grey[300] : (result ? Colors.green : Colors.red),
                            ),
                            child: Icon(
                              result == null ? null : (result ? Icons.check : Icons.close),
                              color: Colors.white,
                              size: 20,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Question area
            Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      question.question,
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  Text('${currentQuestionIndex + 1}/${quizState.questions.length}'),
                ],
              ),
            ),
            
            // Timer
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: quizState.timerValue,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                minHeight: 12,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Options
            ...List.generate(4, (index) {
              final isEliminated = quizState.eliminatedOptions != null && 
                     quizState.eliminatedOptions!.contains(index);
              final isSelected = quizState.selectedAnswerIndex == index;
              final isCorrect = index == question.correctAnswerIndex;
              final showAsCorrect = isCorrect && (quizState.isAnswerRevealed || quizState.showCorrectAnswer);
              
              Color buttonColor = Colors.blue;
              if (isEliminated) {
                buttonColor = Colors.grey;
              } else if (quizState.isAnswerRevealed) {
                if (isSelected) {
                  buttonColor = isCorrect ? Colors.green : Colors.red;
                } else if (isCorrect) {
                  buttonColor = Colors.green;
                }
              } else if (showAsCorrect) {
                buttonColor = Colors.green;
              }
              
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Opacity(
                  opacity: isEliminated ? 0.5 : 1.0,
                  child: ElevatedButton(
                    onPressed: isEliminated || quizState.isAnswerRevealed ? null : () {
                      ref.read(quizControllerProvider.notifier).selectAnswer(index);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      disabledBackgroundColor: buttonColor,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    child: Text(
                      question.options[index],
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              );
            }),
            
            Spacer(),
            
            // Jokers
            Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey))
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: quizState.hasUsedHint || quizState.isAnswerRevealed ? null : () {
                        ref.read(quizControllerProvider.notifier).useHint();
                      },
                      child: Icon(Icons.close, color: quizState.hasUsedHint ? Colors.grey : Colors.red),
                    ),
                  ),
                  Container(width: 1, height: double.infinity, color: Colors.grey),
                  Expanded(
                    child: TextButton(
                      onPressed: quizState.hasUsedFiftyFifty || quizState.isAnswerRevealed ? null : () {
                        ref.read(quizControllerProvider.notifier).useFiftyFifty();
                      },
                      child: Text(
                        '50/50',
                        style: TextStyle(
                          color: quizState.hasUsedFiftyFifty ? Colors.grey : Colors.green,
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: double.infinity, color: Colors.grey),
                  Expanded(
                    child: TextButton(
                      onPressed: quizState.showCorrectAnswer || quizState.isAnswerRevealed ? null : () {
                        ref.read(quizControllerProvider.notifier).showCorrectAnswerHint();
                      },
                      child: Icon(Icons.check, color: quizState.showCorrectAnswer ? Colors.grey : Colors.green),
                    ),
                  ),
                  Container(width: 1, height: double.infinity, color: Colors.grey),
                  Expanded(
                    child: TextButton(
                      onPressed: quizState.hasUsedTimePause || quizState.isAnswerRevealed ? null : () {
                        ref.read(quizControllerProvider.notifier).useTimePause();
                      },
                      child: Icon(
                        Icons.notifications_off,
                        color: quizState.hasUsedTimePause ? Colors.grey : Colors.red,
                      ),
                    ),
                  ),
                  Container(width: 1, height: double.infinity, color: Colors.grey),
                  Expanded(
                    child: TextButton(
                      onPressed: null,
                      child: Icon(Icons.info_outline, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Quiz sonu ekranı
  Widget _buildResultScreen(BuildContext context, QuizState state) {
    int correctAnswers = state.answerResults.where((result) => result == true).length;
    int totalQuestions = state.questions.length;
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Quiz Tamamlandı!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(
                'Skorunuz: $correctAnswers / $totalQuestions',
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Yeniden başlat
                },
                child: Text('Yeniden Başla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

 