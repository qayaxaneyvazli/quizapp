import 'package:flutter/material.dart';

class Message {
  final String username;
  final String messageText;
  final String time;
  final Color? backgroundColor;
  final IconData? avatarIcon;

  Message({
    required this.username,
    required this.messageText,
    required this.time,
    this.backgroundColor,
    this.avatarIcon,
  });
}