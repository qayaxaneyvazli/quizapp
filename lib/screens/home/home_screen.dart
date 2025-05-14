import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_flags/country_flags.dart';
import 'package:quiz_app/providers/ticket/tickets_provider.dart';
import 'package:quiz_app/screens/chapters/chapters.dart';
import 'package:quiz_app/screens/duel/duel.dart';
import 'package:quiz_app/screens/duel/duelloading.dart';
import 'package:quiz_app/screens/event/event.dart';
import 'package:quiz_app/screens/event/no_ticket_dialog.dart';
import 'package:quiz_app/screens/inventory/inventory.dart';
import 'package:quiz_app/screens/market/market.dart';
import 'package:quiz_app/screens/messages/messages.dart';
import 'package:quiz_app/screens/rank/rank.dart';
import 'package:quiz_app/screens/rewards/rewards.dart';
import 'package:quiz_app/screens/settings/settings.dart';
import 'package:quiz_app/screens/statistic/statistic.dart';
import 'package:quiz_app/widgets/topbar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import '../../providers/theme_mode_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.watch(bottomNavProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    
    // Get screen width to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    // Define colors based on theme
    final backgroundColor = isDarkMode 
        ? theme.scaffoldBackgroundColor 
        : const Color(0xFFF0F0F0);
    
        final appBarColor = AppColors.primary;  // Keep blue for both modes

    return Scaffold(
      drawer: TopBar(),
      backgroundColor: backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: appBarColor,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: navController, // Use the provider value
        
        onTap: (index) {
          ref.read(bottomNavProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        
        items:   [
      BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottombar_messages.svg",
              width: 24.w,
              height: 24.h,
             
            ),
            label: 'Messages',
          ),
         BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottombar_rank.svg",
              width: 24.w,
              height: 24.h,
           
            ),
            label: 'Rank',
          ),
             BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottombar_home.svg",
              width: 24.w,
              height: 24.h,
           
            ),
            label: 'Home',
          ),
         BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottombar_market.svg",
              width: 21.w,
              height: 21.h,
             
            ),
            label: 'Market',
          ),
        BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottombar_settings.svg",
              width: 24.w,
              height: 24.h,
            
            ),
            label: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Top status bar with coins and timer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: isTablet ? 8.h : 12.h),
            color: appBarColor,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Builder(
                    builder: (context) => InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: const Icon(Icons.menu, color: Colors.white),
                    ),
                  ),
                  const Spacer(flex: 1),
                  // Coins counter
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.r),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          "assets/icons/coin_top_menu_first.svg",
                          width: 27.w,
                          height: 27.w,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "1000",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  // Timer
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/heart_top_menu.svg",
                        width: 35.w,
                        height: 35.w,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "7:30:25",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,   
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  // Money
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        "assets/icons/coin_top_menu.svg",
                        width: 30.w,
                        height: 30.w,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        "2500",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),
                ],
              ),
            ),
          ),
          
          // Body content based on navigation selection
          Expanded(
            child: _buildBody(navController),
          ),
        ],
      ),
    );
  }
  
  // Method to return different body content based on navigation index
  Widget _buildBody(int navIndex) {
    switch (navIndex) {
      case 0:
        return MessagesScreen();
      case 1:
        return RankScreen();
      case 2:
        return const HomeContentScreen(); // Default home screen
      case 3:
        return MarketScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const HomeContentScreen();
    }
  }
}

class HomeContentScreen extends ConsumerWidget {
  const HomeContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    
    // Get screen dimensions to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    // Calculate appropriate sizes based on device
    final avatarSize = isTablet ? 80.r : 120.r;
    final avatarInnerSize = isTablet ? 64.r : 90.r;
    final flagSize = isTablet ? 20.r : 32.r;
    final usernameSize = isTablet ? 12.sp : 20.sp;
    
    // For tablets, we'll create a wider layout with more grid columns
    final gridCrossAxisCount = isTablet ? 4 : 2;
    final gridPadding = isTablet ? 12.w : 30.w;
    final gridItemSpacing = isTablet ? 10.w : 26.w;

    // Define colors based on theme mode
    final avatarBgColor = isDarkMode ? const Color.fromARGB(255, 121, 48, 48) : const Color(0xFFE8E4FF);
    final avatarBorderColor = isDarkMode ? Colors.grey[700] : const Color(0xFF6A1B9A);
    final usernameColor = isDarkMode ? Color.fromARGB(255, 250, 197, 24) : Colors.black;
    final tileBgGradient = LinearGradient(
  colors: [
    Color(0xFFF4ED0D), // sarı
    Color(0xFFF8AE02), // turuncumsu
  ],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
); // Keep consistent purple for menu tiles
    
    return Column(
      children: [
        // Profile section
        SizedBox(height: isTablet ? 16.h : 24.h),
        Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: avatarBgColor,
                    border: Border.all(color: avatarBorderColor!, width: isTablet ? 3.r : 2.r),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/avatar.png', // Replace with your avatar image
                      width: avatarInnerSize,
                      height: avatarInnerSize,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person, 
                          size: avatarInnerSize * 0.75, 
                          color: isDarkMode ? Colors.grey[400] : Colors.grey,
                        );
                      },
                    ),
                  ),
                ),

                           Positioned(
                             right:3,
                             top:95,
                             child: Container(
                                             padding: EdgeInsets.all(isTablet ? 3.r : 5.r),
                                             decoration: const BoxDecoration(
                                               shape: BoxShape.circle,
                                             ),
                                             child: CountryFlag.fromCountryCode(
                                               'AZ',
                                               height: flagSize,
                                               width: flagSize,
                                               shape: const Circle(),
                                             ),
                                           ),
                           ),
            ]),
         
              // Country flag icon
   
              SizedBox(height: isTablet ? 6.h : 8.h),
              // Username
              Text(
                "Melikmemmed",
                style: TextStyle(
                  fontSize: usernameSize,
                  fontWeight: FontWeight.bold,
                  color: usernameColor,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: isTablet ? 24.h : 32.h),
        
        // Menu grid - responsive layout for tablet
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: gridPadding),
            child: GridView.count(
              crossAxisCount: gridCrossAxisCount,
              mainAxisSpacing: gridItemSpacing,
              crossAxisSpacing: gridItemSpacing,
              childAspectRatio: isTablet ? 1.3 : 1.0, // Wider tiles on tablet
              children: [
                // Quiz button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChapterScreen()),
                    );
                  },
                  child: _buildMenuTile(
                    icon: Icons.play_arrow,
                    title: "Quizz Spielen",
                    gradient: tileBgGradient,
                    isTablet: isTablet,
                  ),
                ),
                // Duel button
                GestureDetector(
                      onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DuelLoadingScreen()),
                    );
                  },
                  child: _buildMenuTile(
                    icon: Icons.shield,
                    title: "Duell",
                    gradient: tileBgGradient,
                    isTablet: isTablet,
                    customIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ac_unit_rounded, color: Colors.blue, size: isTablet ? 20.r : 24.r),
                        Icon(Icons.ac_unit_rounded, color: Colors.red, size: isTablet ? 20.r : 24.r),
                      ],
                    ),
                  ),
                ),
                // Daily login button
                GestureDetector(
                      onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginRewardsScreen()),
                    );
                  },
                  child: _buildMenuTile(
                    icon: Icons.calendar_today,
                    title: "Daily Login\nRewards",
                    gradient: tileBgGradient,
                    isTablet: isTablet,
                  ),
                ),
                // Event button
                GestureDetector(
                    onTap: () {
                         final tickets = ref.read(ticketsProvider);

    if (tickets <= 0) {
      showNoTicketDialog(context);        // ❶ Modal
      return;
    }

    // ❷ Bilet düş ve Event’e geç
    ref.read(ticketsProvider.notifier).state--;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventScreen()),
                    );
                  },                    
                 child: _buildMenuTile(
                    icon: Icons.emoji_events,
                    title: "Event",
                    gradient: tileBgGradient,
                    isTablet: isTablet,
                  ),
                ),
                // For tablet layout, add more menu items to fill the grid
                // if (isTablet) 
                //   _buildMenuTile(
                //     icon: Icons.star,
                //     title: "Achievements",
                //     color: tileBgColor,
                //     isTablet: isTablet,
                //   ),
                // if (isTablet)
                //   _buildMenuTile(
                //     icon: Icons.history,
                //     title: "History",
                //     color: tileBgColor,
                //     isTablet: isTablet,
                //   ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
Widget _buildMenuTile({
  required IconData icon,
  required String title,
  Gradient? gradient, // color yerine gradient
  required bool isTablet,
  Widget? customIcon,
}) {
  final iconSize = isTablet ? 30.r : 36.r;
  final fontSize = isTablet ? 16.sp : 18.sp;

  return Container(
    decoration: BoxDecoration(
      gradient: gradient, // gradient varsa uygula
      color: gradient == null ? Colors.grey : null, // gradient yoksa fallback
      borderRadius: BorderRadius.circular(isTablet ? 12.r : 16.r),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        customIcon ?? Icon(icon, size: iconSize, color: Colors.white),
        SizedBox(height: isTablet ? 6.h : 8.h),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

}