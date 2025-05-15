import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/music/music_provider.dart';
import 'package:quiz_app/providers/notifications/duel_notifications_provider.dart';
import 'package:quiz_app/providers/notifications/notifications_provider.dart';
import 'package:quiz_app/providers/notifications/duel_notifications_provider.dart'; // Import the duel notifications provider
import 'package:quiz_app/providers/theme_mode_provider.dart';
import 'package:quiz_app/screens/settings/faq.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final List<String> menuItems = [
    'Language',
    'Terms of Service',
    'Privacy Policy',
    'Rate Us',
    'Connect Account',
    'Reset Game',
    'FAQ',
    'Report a Problem',
  ];

  late List<bool> expanded;

  @override
  void initState() {
    super.initState();
    expanded = List.generate(menuItems.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkModeOn = ref.watch(themeModeProvider) == ThemeMode.dark;
    final isMusicOn = ref.watch(musicEnabledProvider);
    final isNotificationsOn = ref.watch(notificationsEnabledProvider);
    // Use the correct duel notifications provider
    final isDuelNotificationsOn = ref.watch(duelnotificationsEnabledProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Music',
            value: isMusicOn,
            icon: Icons.music_note,
            iconColor: colorScheme.primary,
            onChanged: (val) => ref.read(musicEnabledProvider.notifier).toggle(),
          ),
          _buildSwitchTile(
            title: 'Dark Mode',
            value: isDarkModeOn,
            icon: isDarkModeOn ? Icons.dark_mode : Icons.light_mode,
            iconColor: isDarkModeOn ? Colors.white70 : Colors.amber,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),
          _buildSwitchTile(
            title: 'Notifications',
            value: isNotificationsOn,
            icon: Icons.notifications,
            iconColor: isNotificationsOn ? colorScheme.secondary : colorScheme.onSurface.withOpacity(0.7),
            onChanged: (val) => ref.read(notificationsEnabledProvider.notifier).toggle(),
          ),
          _buildSwitchTile(
            title: 'Notifications for Duel',
            value: isDuelNotificationsOn,
            icon: Icons.notifications,
            iconColor: isDuelNotificationsOn ? colorScheme.secondary : colorScheme.onSurface.withOpacity(0.7),
            onChanged: (val) => ref.read(duelnotificationsEnabledProvider.notifier).toggle(),
          ),
          const SizedBox(height: 20),
          Column(
            children: List.generate(menuItems.length, (index) {
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      // Navigate to FAQ Screen when FAQ is tapped
                      if (menuItems[index] == 'FAQ') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FaqScreen()),
                        );
                      }
                      // Remove animation expansion for other menu items
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0), // Increased spacing between items
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green, // Changed background color to green
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            menuItems[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white, // Changed text color to white for better contrast
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Only show forward arrow for FAQ, no arrows for other items
                         Container(), // Empty container instead of down arrow
                        ],
                      ),
                    ),
                  ),
                  // Remove the animation content for menu items (except FAQ)
                  if (false) // This condition is always false to not show the expanded content
                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      child: ConstrainedBox(
                        constraints: expanded[index]
                            ? const BoxConstraints()
                            : const BoxConstraints(maxHeight: 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16.0),
                          margin: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            'Detaylar buraya gelecek...',
                            style: TextStyle(
                              fontSize: 14, 
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required IconData icon,
    required Color iconColor,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: theme.colorScheme.primary,
          trackColor: MaterialStateProperty.resolveWith<Color>((states) {
            return states.contains(MaterialState.selected)
                ? theme.colorScheme.primary 
                : theme.colorScheme.onSurface.withOpacity(0.3);
          }),
          thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
            return states.contains(MaterialState.selected)
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface.withOpacity(0.9);
          }),
        ),
      ),
    );
  }
}