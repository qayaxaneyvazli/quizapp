import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/core/services/firebase_auth.dart';
import 'package:quiz_app/providers/music/music_provider.dart';
import 'package:quiz_app/providers/notifications/duel_notifications_provider.dart';
import 'package:quiz_app/providers/notifications/notifications_provider.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';
import 'package:quiz_app/screens/language/language.dart';
import 'package:quiz_app/screens/login/login.dart';
import 'package:quiz_app/screens/settings/faq.dart';
 // AuthService import et
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
    'Connect Account', // Bu dinamik olarak değişecek
    'Reset Game',
    'FAQ',
    'Report a Problem',
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

     
    final isGoogleConnected = _isGoogleAccountConnected();

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
            subtitle: 'Get notifications for Duel only if you are online',
          ),
          const SizedBox(height: 20),
          Column(
            children: List.generate(menuItems.length, (index) {
              String itemTitle = menuItems[index];
              
              
              if (menuItems[index] == 'Connect Account') {
                itemTitle = isGoogleConnected ? 'Disconnect Account' : 'Connect Account';
              }
              
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
                      else if (menuItems[index] == 'Connect Account') {
                        if (isGoogleConnected) {
                          // Google hesabı bağlıysa, bağlantıyı kes
                          _disconnectGoogleAccount();
                        } else {
                          // Google hesabı bağlı değilse, bağlantı kurma ekranına git
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        }
                      }
                      // Diğer itemler için burada başka işlem yok.
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

  // Google hesabı bağlantısını kesen fonksiyon
  void _disconnectGoogleAccount() {
    // Confirmation dialog göster
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Disconnect Account'),
        content: Text('Are you sure you want to disconnect your Google account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // AuthService kullanarak çıkış yap
                await _authService.signOut();
                Navigator.pop(context);
                
                // UI'yi güncelle
                setState(() {});
                
                // Başarılı mesaj göster
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Google account disconnected successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                // Hata mesajı göster
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