import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:quiz_app/providers/music/music_provider.dart';
import 'package:quiz_app/providers/notifications/notifications_provider.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';

// Create a class to hold FAQ data
class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

// Create a separate FAQ screen
class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<FaqItem> faqItems = [
    FaqItem(
      question: 'How can players earn coins and how are they calculated?',
      answer: 'Players can earn coins by playing levels. The faster they answer, the more coins they get:\n'
          '• Answer within 8 seconds: 200 coins\n'
          '• Answer in 9-12 seconds: 140 coins\n'
          '• Answer in 13-15 seconds: 100 coins\n'
          '• Answer in 16-17 seconds: 60 coins\n'
          '• Answer in 18-20 seconds: 40 coins',
    ),
    FaqItem(
      question: 'How are points calculated in the game?',
      answer: 'Points are based on how quickly you answer:\n'
          '• 8 seconds or less: 100 points\n'
          '• 9-12 seconds: 70 points\n'
          '• 13-15 seconds: 50 points\n'
          '• 16-17 seconds: 30 points\n'
          '• 18-20 seconds: 20 points',
    ),
    FaqItem(
      question: 'How are stars awarded for levels?',
      answer: '• 17-20 correct answers: 5 stars\n'
          '• 14-16 correct answers: 4 stars\n'
          '• 10-13 correct answers: 3 stars\n'
          '• 6-9 correct answers: 2 stars\n'
          '• 5 or fewer correct answers: 1 star',
    ),
    FaqItem(
      question: 'How can players get hearts (lives)?',
      answer: 'Each wrong answer costs 1 heart. Players can have up to 5 hearts. Lost hearts are restored over time (1 heart every 10 minutes). Players can also get hearts through daily login or the shop.',
    ),
    FaqItem(
      question: 'How can players get Duel Tickets?',
      answer: 'Every day players get 2 Duel Tickets. If they don\'t use them, they won\'t get extra tickets the next day. Players can also earn tickets by daily login, event rankings, or buying them from the shop.',
    ),
    FaqItem(
      question: 'What is a Duel and how does it work?',
      answer: 'When a player joins a duel, the system invites other active players. The duel has 10 questions. If you win, you get 50 duel points. If you lose, you lose 20 duel points.',
    ),
    FaqItem(
      question: 'What is an Event and how is it played?',
      answer: 'Events happen weekly and have 10 questions. Players must answer within 15 seconds:\n'
          '• Answer in 11-15 seconds: 200 event points\n'
          '• Answer in 6-10 seconds: 150 event points\n'
          '• Answer in 5 seconds or less: 80 event points',
    ),
    FaqItem(
      question: 'How can players get Event Tickets?',
      answer: 'Players get an Event Ticket when they finish a level with 5 stars. Tickets can also be bought in the shop.',
    ),
    FaqItem(
      question: 'What is Freeze Time?',
      answer: 'Freeze Time stops the timer for 10 seconds, giving players more time to think and earn more points and coins. Players can get it from daily login, event rankings, or the shop.',
    ),
    FaqItem(
      question: 'Where can I read information about a question?',
      answer: 'After answering a question, the Info button appears at the bottom right corner. Click it to see more details about the question.',
    ),
    FaqItem(
      question: 'How can I use power-ups?',
      answer: 'During the game, tap the icon of the power-up you want to use. Each has a special function. For example, 50/50 removes two wrong answers, True Answer shows the correct answer, and Wrong Answer removes one wrong option.',
    ),
    FaqItem(
      question: 'What is the Reset Game function?',
      answer: 'Reset Game resets your account. You will lose all your coins and level progress. You will start again from level 1. However, your power-ups won\'t be deleted and can still be used.',
    ),
    FaqItem(
      question: 'What is a Replay Ticket and how can it be used?',
      answer: 'Replay Tickets let you replay any completed level. If you replay a level, your previous score will be replaced with your new score. Replay Tickets can be bought from the shop.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor, // Use app theme's primary color
        foregroundColor: Colors.white,
             leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icons/back_icon.svg',
        
            width: 28,
            height: 28,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:   Text('Frequently Asked Questions',style:TextStyle(color: Colors.white),),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: faqItems.map((faqItem) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      faqItem.isExpanded = !faqItem.isExpanded;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            faqItem.question,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Transform.rotate(
                          angle: faqItem.isExpanded ? pi : 0,
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            size: 20,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // FAQ Answer
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: ConstrainedBox(
                    constraints: faqItem.isExpanded
                        ? const BoxConstraints()
                        : const BoxConstraints(maxHeight: 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.only(bottom: 16.0, left: 8.0, right: 8.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        faqItem.answer,
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
 