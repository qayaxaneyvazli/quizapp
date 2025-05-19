import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/providers/music/music_provider.dart';
import 'package:quiz_app/providers/notifications/duel_notifications_provider.dart';
import 'package:quiz_app/providers/notifications/notifications_provider.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';
import 'package:quiz_app/screens/language/language.dart';
import 'package:quiz_app/screens/settings/faq.dart';
// LanguageModal widget'ını import et!
  // yolunu kendine göre düzelt

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
            icon: SvgPicture.asset('assets/icons/Music.svg'),
            iconColor: colorScheme.primary,
            onChanged: (val) => ref.read(musicEnabledProvider.notifier).toggle(),
          ),
          _buildSwitchTile(
            title: 'Dark Mode',
            value: isDarkModeOn,
            icon: SvgPicture.asset('assets/icons/Dark_Light_Mode.svg'),
            iconColor: isDarkModeOn ? Colors.white70 : Colors.amber,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),
          _buildSwitchTile(
            title: 'Notifications',
            value: isNotificationsOn,
            icon: SvgPicture.asset('assets/icons/Notification.svg'),
            iconColor: isNotificationsOn ? colorScheme.secondary : colorScheme.onSurface.withOpacity(0.7),
            onChanged: (val) => ref.read(notificationsEnabledProvider.notifier).toggle(),
          ),
          _buildSwitchTile(
            title: 'Notifications for Duel',
            value: isDuelNotificationsOn,
            icon: SvgPicture.asset('assets/icons/Notification_Duel.svg'),
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
                      if (menuItems[index] == 'Language') {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => LanguageModal(
                            onClose: () => Navigator.of(context).pop(),
                            onLanguageSelected: (code) {
                              // Dili burada değiştir, provider/locale işlemini burada yazabilirsin.
                              print("Seçilen dil: $code");
                              Navigator.of(context).pop();
                            },
                          ),
                        );
                      } else if (menuItems[index] == 'FAQ') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FaqScreen()),
                        );
                      }
                      // Diğer itemler için burada başka işlem yok.
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            menuItems[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Container(), // Ok/ikon yok
                        ],
                      ),
                    ),
                  ),
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
    required SvgPicture icon,
    required Color iconColor,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          alignment: Alignment.centerLeft,
          child: icon,
        ),
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
