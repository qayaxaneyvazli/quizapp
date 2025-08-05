import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/core/services/firebase_auth.dart';
import 'package:quiz_app/providers/chapter/chapter_provider.dart';
import 'package:quiz_app/providers/language/language_provider.dart';
import 'package:quiz_app/providers/music/music_provider.dart';
import 'package:quiz_app/providers/translations/translation_provider.dart';
import 'package:quiz_app/widgets/translation_helper.dart';
import 'package:quiz_app/providers/notifications/duel_notifications_provider.dart';
import 'package:quiz_app/providers/notifications/notifications_provider.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';
 
import 'package:quiz_app/screens/language/language.dart';
import 'package:quiz_app/screens/login/login.dart';
import 'package:quiz_app/screens/settings/faq.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final List<String> menuItems = [
    'settings.language',
    'settings.terms_of_service',
    'settings.privacy_policy',
    'settings.rate_us',
    'settings.connect_account',  
    'settings.reset_game',
    'settings.FAQ',
    'settings.report_a_problem',
  ];

  late List<bool> expanded;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    expanded = List.generate(menuItems.length, (index) => false);
  }

  // Google hesabının bağlı olup olmadığını kontrol eden fonksiyon
  bool _isGoogleAccountConnected() {
    return _authService.currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkModeOn = ref.watch(themeModeProvider) == ThemeMode.dark;
    final isMusicOn = ref.watch(musicEnabledProvider);
    final isNotificationsOn = ref.watch(notificationsEnabledProvider);
    final isDuelNotificationsOn = ref.watch(duelnotificationsEnabledProvider);
    final currentLanguage = ref.watch(languageProvider);  
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isGoogleConnected = _isGoogleAccountConnected();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildSwitchTile(
            title: ref.tr('settings.music'),
            value: isMusicOn,
            icon: SvgPicture.asset('assets/icons/Music.svg'),
            iconColor: colorScheme.primary,
            onChanged: (val) => ref.read(musicEnabledProvider.notifier).toggle(),
          ),
          _buildSwitchTile(
            title: ref.tr('settings.dark_mode'),
            value: isDarkModeOn,
            icon: SvgPicture.asset('assets/icons/Dark_Light_Mode.svg'),
            iconColor: isDarkModeOn ? Colors.white70 : Colors.amber,
            onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
          ),
          _buildSwitchTile(
            title: ref.tr('settings.notifications'),
            value: isNotificationsOn,
            icon: SvgPicture.asset('assets/icons/Notification.svg'),
            iconColor: isNotificationsOn ? colorScheme.secondary : colorScheme.onSurface.withOpacity(0.7),
            onChanged: (val) => ref.read(notificationsEnabledProvider.notifier).toggle(),
          ),
          _buildSwitchTile(
            title: ref.tr('settings.notifications_duel'),
            value: isDuelNotificationsOn,
            icon: SvgPicture.asset('assets/icons/Notification_Duel.svg'),
            iconColor: isDuelNotificationsOn ? colorScheme.secondary : colorScheme.onSurface.withOpacity(0.7),
            onChanged: (val) => ref.read(duelnotificationsEnabledProvider.notifier).toggle(),
            subtitle: ref.tr('settings.notifications_duel_subtitle'),
          ),
          const SizedBox(height: 20),
          Column(
            children: List.generate(menuItems.length, (index) {
              String itemTitle = ref.tr(menuItems[index]);
              
              if (menuItems[index] == 'settings.connect_account') {
                itemTitle = isGoogleConnected ? ref.tr('settings.disconnect_account') : ref.tr('settings.connect_account');
              }
              
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      if (menuItems[index] == 'settings.language') {
                        showDialog(
                          context: context,
                          barrierDismissible: true,
                          builder: (_) => LanguageModal(
                            onClose: () => Navigator.of(context).pop(),
                            onLanguageSelected: (code) async {
   
  await ref.read(languageProvider.notifier).setLanguage(code);
  print("Seçilen və saxlanılan dil: $code");
  Navigator.of(context).pop();
  
 
  ref.invalidate(chapterProvider);
  ref.invalidate(translationProvider);
  
  // Uğurlu mesaj göstər
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Language changed to $code'),
      backgroundColor: Colors.green,
    ),
  );
},
                          ),
                        );
                      } else if (menuItems[index] == 'settings.FAQ') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const FaqScreen()),
                        );
                      }
                      else if (menuItems[index] == 'settings.connect_account') {
                        if (isGoogleConnected) {
                          _disconnectGoogleAccount();
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      }
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 13.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            itemTitle,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Əgər Language seçimidir, hazırkı dili göstər
                          if (menuItems[index] == 'settings.language')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                currentLanguage.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Container(),
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

  void _disconnectGoogleAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ref.tr('settings.disconnect_account')),
        content: Text('Are you sure you want to disconnect your Google account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _authService.signOut();
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Google account disconnected successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to disconnect account: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Disconnect'),
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
    String? subtitle,
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
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[700])) : null,
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