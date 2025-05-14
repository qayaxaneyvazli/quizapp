import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/music/music_provider.dart';
import 'package:quiz_app/providers/notifications/notifications_provider.dart';
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
                      } else {
                        setState(() {
                          expanded[index] = !expanded[index];
                        });
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            menuItems[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Change icon for FAQ to forward arrow
                          Icon(
                            menuItems[index] == 'FAQ' 
                                ? Icons.arrow_forward_ios 
                                : expanded[index] 
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                            size: menuItems[index] == 'FAQ' ? 16 : 20,
                            color: colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Show other menu items' content
                  if (menuItems[index] != 'FAQ')
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