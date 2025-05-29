import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/models/question/message.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_mode_provider.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen> with SingleTickerProviderStateMixin {
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNotificationItem(
          title: "Heart",
          icon: Icons.favorite,
          iconColor: Colors.red,
          backgroundColor: colorScheme.surface,
        ),
        const SizedBox(height: 12),
        _buildNotificationItem(
          title: "Super package",
          icon: Icons.card_giftcard,
          iconColor: Colors.red[400]!,
          backgroundColor: colorScheme.surface,
        ),
        const SizedBox(height: 12),
        _buildNotificationItem(
          title: "System update",
          icon: Icons.error,
          iconColor: Colors.red[400]!,
          backgroundColor: colorScheme.surface,
        ),
        const SizedBox(height: 12),
        _buildNotificationItem(
          title: "Notifications",
          icon: Icons.notifications,
          iconColor: Colors.pink[400]!,
          backgroundColor: colorScheme.surface,
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
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.onSurface,
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
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: theme.dividerColor, width: 2.2),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF304D00) : const Color(0xBBD9FF99),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDarkMode ? Colors.green[800]! : Colors.green[200]!, 
          width: 0.5
        ),
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurface,
                  ),
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
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.colorScheme.surface : Colors.grey[200],
        borderRadius: BorderRadius.circular(30),
      ),
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type a message',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6)),
              ),
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
       
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.send,
              
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Custom Tab Bar
          Container(
            color: theme.colorScheme.primary,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.yellow,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: theme.colorScheme.onPrimary,
              unselectedLabelColor: theme.colorScheme.onPrimary.withOpacity(0.7),
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