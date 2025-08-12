import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_flags/country_flags.dart';
import 'package:quiz_app/providers/ticket/tickets_provider.dart';
import 'package:quiz_app/screens/chapters/chapters.dart';
import 'package:quiz_app/screens/duel/duelloading.dart';
import 'package:quiz_app/screens/event/event.dart';
import 'package:quiz_app/screens/event/no_ticket_dialog.dart';
import 'package:quiz_app/screens/market/market.dart';
import 'package:quiz_app/screens/messages/messages.dart';
import 'package:quiz_app/screens/rank/rank.dart';
import 'package:quiz_app/screens/rewards/rewards.dart';
import 'package:quiz_app/screens/settings/settings.dart';
import 'package:quiz_app/widgets/topbar.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/bottom_nav_provider.dart';
import '../../providers/theme_mode_provider.dart';
// removed unused imports
import 'package:quiz_app/widgets/translation_helper.dart';
import 'package:quiz_app/providers/user_stats/user_stats_provider.dart' as stats;

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});


String _getPageTitle(int navIndex, WidgetRef ref) {
    switch (navIndex) {
      case 0:
        return ref.tr('menu.messages');
      case 1:
        return ref.tr('menu.rank');
      case 2:
        return ref.tr('menu.home');
      case 3:
        return ref.tr('menu.market');
      case 4:
        return ref.tr('menu.settings');
      default:
        return ref.tr('menu.home');
    }
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize user stats when home screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userStatsAsync = ref.read(stats.userStatsProvider);
      if (userStatsAsync is AsyncData && userStatsAsync.value == null) {
        print('🏠 Home screen triggering user stats fetch...');
        ref.read(stats.userStatsProvider.notifier).fetchUserStats();
      }
    });
   
    final navController = ref.watch(bottomNavProvider);
    final userStatsAsync = ref.watch(stats.userStatsProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    
    // Helper functions to get display values
    String getCoinsDisplay() {
      return userStatsAsync.when(
        data: (userStats) => userStats?.coins.toString() ?? "0",
        loading: () => "...",
        error: (_, __) => "0",
      );
    }
    
    String getHeartsDisplay() {
      return userStatsAsync.when(
        data: (userStats) {
          if (userStats == null) return "0";
          if (userStats.hasInfiniteHearts) {
            // Show countdown timer if we have hearts_infinite_until timestamp
            final timeString = userStats.infiniteHeartsTimeString;
            if (timeString.isNotEmpty) {
              return timeString; // Show remaining time like "7:30:25"
            }
            return "∞"; // Fallback to infinity symbol
          }
          return userStats.heartsDisplayValue.toString();
        },
        loading: () => "...",
        error: (_, __) => "0",
      );
    }
    
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(75.h), // AppBar yüksekliğini artırıyoruz
        child: AppBar(
          backgroundColor: appBarColor,
          elevation: 0,
          flexibleSpace: SafeArea(
            child: Column(
              children: [
                // Üst kısım - İkonlar ve drawer button
                Container(
                  height: 50.h, // Standart AppBar yüksekliği
                  padding: EdgeInsets.symmetric(horizontal: 104.w),
                  child: Row(
                    children: [
                      // Drawer button
                      
                      
                      const Spacer(),
                      
                      // Coins counter
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.r),
                              decoration: const BoxDecoration(
                                color: Colors.amber,
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                "assets/icons/coin_top_menu_first.svg",
                                width: 20.w,
                                height: 20.w,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              getCoinsDisplay(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Timer (Heart)
                      Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/heart_top_menu.svg",
                              width: 24.w,
                              height: 24.w,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              getHeartsDisplay(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,   
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Money
                      Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/coin_top_menu.svg",
                              width: 22.w,
                              height: 22.w,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              getCoinsDisplay(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Alt kısım - Sayfa başlığı
                Container(
                  height: 25.h,
                  child: Center(
                    child: Text(
                      _getPageTitle(navController, ref),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21.sp, // Biraz küçülttük
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: appBarColor,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: navController,
        onTap: (index) {
          ref.read(bottomNavProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottombar_messages.svg",
              width: navController == 0 ? 32.w : 24.w,
              height: navController == 0 ? 32.h : 24.h,
            ),
            label: ref.tr('menu.messages'),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottombar_rank.svg",
              width: navController == 1 ? 32.w : 24.w,
              height: navController == 1 ? 32.h : 24.h,
            ),
            label: ref.tr('menu.rank'),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottombar_home.svg",
              width: navController == 2 ? 32.w : 24.w,
              height: navController == 2 ? 32.h : 24.h,
            ),
            label: ref.tr('menu.home'),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/images/bottombar_market.svg",
              width: navController == 3 ? 29.w : 21.w,
              height: navController == 3 ? 29.h : 21.h,
            ),
            label: ref.tr('menu.market'),
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/settings.svg",
              width: navController == 4 ? 32.w : 24.w,
              height: navController == 4 ? 32.h : 24.h,
            ),
            label: ref.tr('menu.settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top status bar (artık gereksiz olabilir)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: isTablet ? 8.h : 12.h),
            color: appBarColor,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
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
    User? user = FirebaseAuth.instance.currentUser;
String displayName = user?.displayName ?? 'Guest';
String? photoUrl = user?.photoURL;
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    
    // Get screen dimensions to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    final double flagRight = isTablet ? 12.w : 3.w;
final double flagTop = isTablet ? 150.h : 70.h;
    
    // Calculate appropriate sizes based on device
    final avatarSize = isTablet ? 80.r : 120.r;
    final avatarInnerSize = isTablet ? 64.r : 90.r;
    final flagSize = isTablet ? 20.r : 32.r;
    final usernameSize = isTablet ? 12.sp : 20.sp;
    
    // For tablets, we'll create a wider layout with more grid columns
    final gridCrossAxisCount = isTablet ? 4 : 2;
    final gridPadding = isTablet ? 12.w : 30.w;
    final gridItemSpacing = isTablet ? 10.w : 26.w;
final double flagPadding = isTablet ? 3.r : 5.r;
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
                  child: ClipOval(
                    child: SizedBox.expand(
                      child: (photoUrl != null && photoUrl.isNotEmpty && photoUrl.startsWith('http'))
                          ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: avatarInnerSize * 0.75,
                                  color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                );
                              },
                            )
                          : Image.asset(
                              'assets/images/avatar.png',
                              fit: BoxFit.cover,
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
                ),

                      Positioned(
  right: flagRight,
  top: flagTop,
  child: Container(
    padding: EdgeInsets.all(flagPadding),
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
                displayName,
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
                  //width: 24.w, height: 24.h
                  child: _buildMenuTile(
                    icon: SvgPicture.asset('assets/icons/play_quiz.svg', width: 34.w, height: 34.h),
                    title: ref.tr("home.play_quiz"),
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
                    icon: SvgPicture.asset('assets/icons/duel.svg', width: 42.w, height: 42.h),
                    title: ref.tr("home.duel"),
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
                    icon: SvgPicture.asset('assets/icons/present.svg', width: 34.w, height: 34.h),
                    title: ref.tr("home.daily_login"),
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
 
    ref.read(ticketsProvider.notifier).state--;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EventScreen()),
                    );
                  },                    
                 child: _buildMenuTile(
                    icon: SvgPicture.asset('assets/icons/trophy.svg', width: 34.w, height: 34.h),
                    title: ref.tr("home.event"),
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
  required SvgPicture icon,
  required String title,
  Gradient? gradient, // color yerine gradient
  required bool isTablet,
  Widget? customIcon,
}) {
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
        icon,
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