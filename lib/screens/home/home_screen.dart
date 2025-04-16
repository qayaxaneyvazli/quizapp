import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:quiz_app/screens/chapters/chapters.dart';
import 'package:quiz_app/screens/inventory/inventory.dart';
import 'package:quiz_app/screens/market/market.dart';
import 'package:quiz_app/screens/messages/messages.dart';
import 'package:quiz_app/screens/rank/rank.dart';
import 'package:quiz_app/screens/settings/settings.dart';
import 'package:quiz_app/screens/statistic/statistic.dart';
import 'package:quiz_app/widgets/topbar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 import 'package:country_flags/country_flags.dart';
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.watch(bottomNavProvider);
    // Get screen width to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      drawer: TopBar(),
      backgroundColor: const Color(0xFFF0F0F0),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF4A7DFF),
        selectedItemColor: AppColors.gold,
        unselectedItemColor: Colors.white.withOpacity(0.7),
        currentIndex: navController, // Use the provider value
        
        onTap: (index) {
          ref.read(bottomNavProvider.notifier).state = index;
        },
        type: BottomNavigationBarType.fixed,
        
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Rank',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Top status bar with coins and timer
       Container(
  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: isTablet ? 8.h : 12.h),
  color: const Color(0xFF4A7DFF),
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
              child: Icon(Icons.monetization_on, color: Colors.white, size: 20.r),
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
              width: 30.w,
              height: 30.w,
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
        return   MessagesScreen();
      case 1:
        return   RankScreen();
      case 2:
        return const HomeContentScreen(); // Default home screen
      case 3:
        return   MarketScreen();
      case 4:
        return const SettingsScreen();
      default:
        return const HomeContentScreen();
    }
  }
}

class HomeContentScreen extends StatelessWidget {
  const HomeContentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    
    // Calculate appropriate sizes based on device
    final avatarSize = isTablet ? 80.r : 100.r;
    final avatarInnerSize = isTablet ? 64.r : 80.r;
    final flagSize = isTablet ? 20.r : 24.r;
    final usernameSize = isTablet ? 12.sp : 20.sp;
    
    // For tablets, we'll create a wider layout with more grid columns
    final gridCrossAxisCount = isTablet ? 4 : 2;
    final gridPadding = isTablet ? 12.w : 16.w;
    final gridItemSpacing = isTablet ? 10.w : 16.w;
    
    return Column(
      children: [
        // Profile section
        SizedBox(height: isTablet ? 16.h : 24.h),
        Center(
          child: Column(
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8E4FF),
                  border: Border.all(color: const Color(0xFFD5CFFF), width: isTablet ? 3.r : 4.r),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/avatar.png', // Replace with your avatar image
                    width: avatarInnerSize,
                    height: avatarInnerSize,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: avatarInnerSize * 0.75, color: Colors.grey);
                    },
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 6.h : 8.h),
              // Country flag icon
   Container(
  padding: EdgeInsets.all(isTablet ? 3.r : 4.r),
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
              SizedBox(height: isTablet ? 6.h : 8.h),
              // Username
              Text(
                "Melikmemmed",
                style: TextStyle(
                  fontSize: usernameSize,
                  fontWeight: FontWeight.bold,
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
    color: const Color(0xFFD5ACFF),
    isTablet: isTablet,
  ),
),
                // Duel button
                _buildMenuTile(
                  icon: Icons.shield,
                  title: "Duell",
                  color: const Color(0xFFD5ACFF),
                  isTablet: isTablet,
                  customIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.ac_unit_rounded, color: Colors.blue, size: isTablet ? 20.r : 24.r),
                      Icon(Icons.ac_unit_rounded, color: Colors.red, size: isTablet ? 20.r : 24.r),
                    ],
                  ),
                ),
                // Daily login button
                _buildMenuTile(
                  icon: Icons.calendar_today,
                  title: "Daily Login\nRewards",
                  color: const Color(0xFFD5ACFF),
                  isTablet: isTablet,
                ),
                // Event button
                _buildMenuTile(
                  icon: Icons.emoji_events,
                  title: "Event",
                  color: const Color(0xFFD5ACFF),
                  isTablet: isTablet,
                ),
                // For tablet layout, add more menu items to fill the grid
                // if (isTablet) 
                //   _buildMenuTile(
                //     icon: Icons.star,
                //     title: "Achievements",
                //     color: const Color(0xFFD5ACFF),
                //     isTablet: isTablet,
                //   ),
                // if (isTablet)
                //   _buildMenuTile(
                //     icon: Icons.history,
                //     title: "History",
                //     color: const Color(0xFFD5ACFF),
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
    required Color color,
    required bool isTablet,
    Widget? customIcon,
  }) {
    // Adjust sizes for tablet
    final iconSize = isTablet ? 30.r : 36.r;
    final fontSize = isTablet ? 16.sp : 18.sp;
    
    return Container(
      decoration: BoxDecoration(
        color: color,
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