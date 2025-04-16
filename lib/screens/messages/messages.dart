import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/models/question/message.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  // New method that combines the chat tab with the input field
  Widget _buildChatTabWithInput() {
    return Column(
      children: [
        Expanded(
          child: _buildChatTab(),
        ),
        _buildMessageInputField(),
      ],
    );
  }

  Widget _buildSystemTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNotificationItem(
          title: "Heart",
          icon: Icons.favorite,
          iconColor: Colors.red,
          backgroundColor: Colors.yellow[200]!,
        ),
        const SizedBox(height: 12),
        _buildNotificationItem(
          title: "Super package",
          icon: Icons.card_giftcard,
          iconColor: Colors.red[400]!,
          backgroundColor: Colors.grey[100]!,
        ),
        const SizedBox(height: 12),
        _buildNotificationItem(
          title: "System update",
          icon: Icons.error,
          iconColor: Colors.red[400]!,
          backgroundColor: Colors.grey[100]!,
        ),
        const SizedBox(height: 12),
        _buildNotificationItem(
          title: "Notifications",
          icon: Icons.notifications,
          iconColor: Colors.pink[400]!,
          backgroundColor: Colors.grey[100]!,
        ),
      ],
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 192, 188, 188).withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _buildMessage(
          name: "SuperHirn",
          message: "Hello, how are you?",
          time: "10:30 AM",
          avatarText: "👩‍🦱",
          avatarColor: Colors.purple[100],
          isReceived: true,
        ),
        _buildMessage(
          name: "Spring777",
          message: "I am fine and you?",
          time: "10:35 AM",
          avatarText: "👱‍♀️",
          avatarColor: Colors.purple[100],
          isReceived: true,
        ),
        _buildMessage(
          name: "Player",
          message: "Let's play duel",
          time: "10:40 AM",
          avatarText: "👩‍🦳",
          avatarColor: Colors.purple[100],
          isReceived: true,
        ),
        _buildMessage(
          name: "SilentDeath",
          message: "Are you ready for the quiz?",
          time: "10:45 AM",
          avatarText: "👨‍🦰",
          avatarColor: Colors.purple[100],
          isReceived: true,
        ),
        _buildMessage(
          name: "Melikmemmed",
          message: "I am ready!",
          time: "11:17 AM",
          avatarText: "👨‍💼",
          avatarColor: Colors.blue[200],
          isReceived: false,
        ),
        _buildMessage(
          name: "Spieler",
          message: "Spielen wir ein quiz?",
          time: "11:18 AM",
          avatarText: "👨‍🦲",
          avatarColor: Colors.purple[100],
          isReceived: true,
        ),
      ],
    );
  }

  Widget _buildMessage({
    required String name,
    required String message,
    required String time,
    required String avatarText,
    Color? avatarColor,
    required bool isReceived,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: isReceived 
        ? _buildReceivedMessageBubble(name, message, time, avatarText, avatarColor)
        : _buildSentMessageBubble(name, message, time, avatarText, avatarColor),
    );
  }

  Widget _buildReceivedMessageBubble(
    String name, 
    String message, 
    String time, 
    String avatarText, 
    Color? avatarColor
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: Colors.grey[300]!, width: 2.2),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: avatarColor ?? Colors.purple[100],
            radius: 25,
            child: Text(
              avatarText,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentMessageBubble(
    String name, 
    String message, 
    String time, 
    String avatarText, 
    Color? avatarColor
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xBBD9FF99), // Transparan açık yeşil
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green[200]!, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: avatarColor ?? Colors.blue[200],
            radius: 25,
            child: Text(
              avatarText,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: const Color(0xFF4D79FF), // Mavi arka plan
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.yellow,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Chat'),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('System'),
                      SizedBox(width: 5),
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 10,
                        child: Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Chat Tab with input field
                _buildChatTabWithInput(),
                
                // System Tab without input field
                _buildSystemTab()
              ],
            ),
          ),
        ],
      ),
    );
  }
}