import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';
import 'package:quiz_app/providers/translations/translation_provider.dart';
import 'package:quiz_app/widgets/translation_helper.dart';
import 'package:quiz_app/screens/account/profile.dart';
import 'package:quiz_app/screens/inventory/inventory.dart';
import 'package:quiz_app/screens/progress/progress.dart';
import 'package:quiz_app/screens/statistic/statistic.dart';

class TopBar extends ConsumerWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user = FirebaseAuth.instance.currentUser;
    String displayName = user?.displayName ?? 'Guest';
String? email = user?.email;
String? photoUrl = user?.photoURL;
    // Get current theme mode
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    
    return Drawer(
      // Use theme's background color instead of hardcoded value
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Profile header section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24),
              // Use primary color from theme
              color: isDarkMode ? theme.colorScheme.primary.withOpacity(0.7) : const Color(0xFF6A1B9A),
              child: Column(
                children: [
                  // Avatar container
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDarkMode ? theme.colorScheme.surface : const Color(0xFFE8E4FF),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: Image.asset(
                        'assets/images/avatar.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.person, size: 48, 
                              color: isDarkMode ? Colors.white : Colors.grey);
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  // Username
                  Text(
                    displayName ?? ref.tr('common.guest'),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),
            ),
            
            // Navigation items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    context: context,
                    isDarkMode: isDarkMode,
                    icon: SvgPicture.asset(
                      'assets/icons/progress.svg',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.trending_up, size: 24, 
                            color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 8, 8, 8));
                      },
                    ),
                    label: ref.tr('menu.progress'),
                    leading: SvgPicture.asset(
                      'assets/icons/progress.svg',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.trending_up, size: 24, 
                            color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 8, 8, 8));
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to progress screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProgressScreen()),
                      );
                    },
                  ),
                  
                  _buildMenuItem(
                    context: context,
                    isDarkMode: isDarkMode,
                    icon: SvgPicture.asset(
                      'assets/icons/statistic.svg',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.trending_up, size: 24, 
                            color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 8, 8, 8));
                      },
                    ),
                    label: ref.tr('menu.statistic'),
                    leading: Image.asset(
                      'assets/images/stats_icon.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.bar_chart, size: 24, 
                            color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 8, 8, 8));
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);

                         Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StatisticScreen()),
                      );
                      // Navigate to statistics screen
                    },
                  ),
                  
                  _buildMenuItem(
                    context: context,
                    isDarkMode: isDarkMode,
                    icon: SvgPicture.asset(
                      'assets/icons/account.svg',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.trending_up, size: 24, 
                            color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 8, 8, 8));
                      },
                    ),
                    label: ref.tr('menu.account'),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to account screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountPage()),
                      );
                    },
                  ),
                  
                  _buildMenuItem(
                    context: context,
                    isDarkMode: isDarkMode,
                    icon: SvgPicture.asset(
                      'assets/icons/inventory.svg',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.trending_up, size: 24, 
                            color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 8, 8, 8));
                      },
                    ),
                    label: ref.tr('menu.inventory'),
                    leading: Image.asset(
                      'assets/images/inventory_icon.png',
                      width: 24,
                      height: 24,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.work, size: 24, 
                            color: isDarkMode ? Colors.white70 : const Color.fromARGB(255, 15, 15, 15));
                      },
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to inventory screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => InventoryScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            // Bottom settings button
            // Container(
            //   width: double.infinity,
            //   // Use slightly darker variant of primary color for the settings button
            //   color: isDarkMode ? theme.colorScheme.primary.withOpacity(0.5) : const Color(0xFF2C4A9A),
            //   padding: EdgeInsets.symmetric(vertical: 16),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Icon(
            //         Icons.settings,
            //         color: Colors.white,
            //         size: 22,
            //       ),
            //       SizedBox(width: 8),
            //       Text(
            //         "Settings",
            //         style: TextStyle(
            //           color: Colors.white,
            //           fontSize: 16,
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required bool isDarkMode,
    required SvgPicture  icon,
    required String label,
    Widget? leading,
    required VoidCallback onTap,
  }) {
    final textColor = isDarkMode ? Colors.white70 : const Color.fromARGB(255, 12, 12, 12);
    final iconColor = isDarkMode ? Colors.white70 : const Color.fromARGB(255, 14, 13, 13);
    
    return ListTile(
      leading: icon,
      title: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 16,
        ),
      ),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
    );
  }
}