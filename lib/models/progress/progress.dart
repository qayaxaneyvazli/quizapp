import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



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