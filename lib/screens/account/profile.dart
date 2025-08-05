import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/providers/user/user_provider.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';
import 'package:quiz_app/providers/translations/translation_provider.dart';
import 'package:quiz_app/widgets/translation_helper.dart';

class AccountPage extends ConsumerWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    
    // Get screen dimensions to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? theme.colorScheme.primary.withOpacity(0.7) : AppColors.primary,
        elevation: 0,
        title: Text(
          ref.tr('menu.account'),
          style: TextStyle(
            color: Colors.white,
            fontSize: isTablet ? 20.sp : 24.sp,
            fontWeight: FontWeight.bold,
          ), 
        ),
        centerTitle: true,
     leading: IconButton(
  icon: SvgPicture.asset(
    'assets/icons/back_icon.svg',  
 
    width: 40,  
    height: 40,
  ),
  onPressed: () => Navigator.of(context).pop(),
),
      ),
      body: Column(
        children: [
          // Stats section at top
  //         Container(
  //           padding: EdgeInsets.symmetric(vertical: 16.h),
  //           color: isDarkMode ? theme.colorScheme.primary.withOpacity(0.7) : AppColors.primary,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               _buildStatItem(
  //                iconWidget: SvgPicture.asset(
  //   'assets/icons/coin_top_menu_first.svg',
  //   width: isTablet ? 20.r : 25.r,
  //   height: isTablet ? 20.r : 25.r,
  //   // color: Colors.amber,  // svg'in rengi içeriden veriliyorsa burada kullanabilirsin
  // ),
  //                 value: userProfile.stars.toString(),
  //                 color: Colors.amber,
  //                 isTablet: isTablet,
  //               ),
  //               SizedBox(width: isTablet ? 32.w : 40.w),
  //               _buildStatItem(
  //                iconWidget: SvgPicture.asset(
  //   'assets/icons/heart_top_menu.svg',
  //   width: isTablet ? 20.r : 25.r,
  //   height: isTablet ? 20.r : 25.r,
  //   // color: Colors.amber,  // svg'in rengi içeriden veriliyorsa burada kullanabilirsin
  // ),
  //                 value: userProfile.hearts.toString(),
  //                 color: Colors.red,
  //                 isTablet: isTablet,
  //               ),
  //               SizedBox(width: isTablet ? 32.w : 40.w),
  //               _buildStatItem(
  //                iconWidget: SvgPicture.asset(
  //   'assets/icons/coin_top_menu.svg',
  //   width: isTablet ? 20.r : 25.r,
  //   height: isTablet ? 20.r : 25.r,
  //   // color: Colors.amber,  // svg'in rengi içeriden veriliyorsa burada kullanabilirsin
  // ),
  //                 value: userProfile.coins.toString(),
  //                 color: Colors.amber,
  //                 isTablet: isTablet,
  //               ),
  //             ],
  //           ),
  //         ),
          
          // Profile Items
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    // Avatar
                    _buildProfileItem(
                      context: context,
                      isDarkMode: isDarkMode,
                      child: CircleAvatar(
                        radius: isTablet ? 40.r : 50.r,
                        backgroundColor: isDarkMode ? theme.colorScheme.surface : const Color(0xFFEFE5FF),
                        backgroundImage: userProfile.avatarUrl.isNotEmpty
                            ? NetworkImage(userProfile.avatarUrl)
                            : null,
                        child: userProfile.avatarUrl.isEmpty
                            ? Icon(Icons.person, 
                                size: isTablet ? 40.r : 50.r, 
                                color: isDarkMode ? Colors.white54 : Colors.grey)
                            : null,
                      ),
                      onEdit: () {
                        // Avatar selection dialog
                      },
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20.h),
                    
                    // Country flag
                    _buildProfileItem(
                      context: context,
                      isDarkMode: isDarkMode,
                      child: Container(
                        width: isTablet ? 80.r : 100.r,
                        height: isTablet ? 80.r : 100.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDarkMode ? Colors.white30 : Colors.transparent,
                            width: 1.h,
                          ),
                        ),
                        child: CountryFlag.fromCountryCode(
                          userProfile.countryCode,
                          height: isTablet ? 80.r : 100.r,
                          width: isTablet ? 80.r : 100.r,
                          shape: const Circle(),
                        ),
                      ),
                      onEdit: () {
                        // Flag selection dialog
                      },
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20.h),
                    
                    // Username field
                    _buildProfileItem(
                      context: context,
                      isDarkMode: isDarkMode,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: TextField(
                          controller: TextEditingController(text: userProfile.username),
                          decoration: InputDecoration(
                            hintText: ref.tr('account.enter_username'),
                            hintStyle: TextStyle(
                              color: isDarkMode ? Colors.white38 : Colors.grey[400],
                            ),
                            border: InputBorder.none,
                          ),
                          style: TextStyle(
                            fontSize: isTablet ? 14.sp : 16.sp,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                          onChanged: (value) {
                            ref.read(userProfileProvider.notifier).updateUsername(value);
                          },
                        ),
                      ),
                      onEdit: () {
                        // Focus username field
                      },
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20.h),
                    
                    // User ID with copy button
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: [
                          Text(
                            '${ref.tr("account.user_id_label")}: ${userProfile.userId}',
                            style: TextStyle(
                              fontSize: isTablet ? 14.sp : 16.sp,
                              color: isDarkMode ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(
                              Icons.copy, 
                              size: isTablet ? 20.r : 24.r,
                              color: isDarkMode ? Colors.white70 : Colors.black87,
                            ),
                            onPressed: () {
                              // Copy ID to clipboard
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    ref.tr('account.id_copied'),
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                  backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildStatItem({
  required Widget iconWidget, // IconData yerine Widget alıyoruz!
  required String value, 
  required Color color,
  required bool isTablet,
}) {
  return Column(
    children: [
      Container(
        width: isTablet ? 40.r : 50.r,
        height: isTablet ? 40.r : 50.r,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: iconWidget,
        ),
      ),
      SizedBox(height: 5.h),
      Text(
        value,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTablet ? 16.sp : 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

  Widget _buildProfileItem({
    required BuildContext context,
    required bool isDarkMode,
    required Widget child, 
    required VoidCallback onEdit,
    required bool isTablet,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDarkMode ? Colors.white24 : Colors.grey[300]!,
            width: 1.h,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: child,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: isDarkMode ? Colors.white70 : Colors.black,
              size: isTablet ? 20.r : 24.r,
            ),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}