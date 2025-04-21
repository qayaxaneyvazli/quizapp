import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/models/progress/progress.dart';

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