import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Model for Quiz Question
class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final bool isTrueFalse; // true for true/false questions, false for multiple choice

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    this.isTrueFalse = false,
  });
}