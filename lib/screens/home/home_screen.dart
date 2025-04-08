import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quiz_app/screens/market/market.dart';
import 'package:quiz_app/screens/messages/messages.dart';
import 'package:quiz_app/screens/rank/rank.dart';
import 'package:quiz_app/screens/settings/settings.dart';
import 'package:quiz_app/widgets/topbar.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_padding.dart';
import '../../providers/bottom_nav_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navController = ref.watch(bottomNavProvider);

    return Scaffold(
      drawer:   TopBar(),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
                  const Spacer(),
                  // Coins counter
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.monetization_on, color: Colors.white, size: 20.r),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    "1000",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Timer
                  const Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 4.w),
                  Text(
                    "7:30:25",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // Money
                  const Icon(Icons.attach_money, color: Colors.amber),
                  SizedBox(width: 4.w),
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
        return const MessagesScreen();
      case 1:
        return const RankScreen();
      case 2:
        return const HomeContentScreen(); // Default home screen
      case 3:
        return const MarketScreen();
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
    return Column(
      children: [
        // Profile section
        SizedBox(height: 24.h),
        Center(
          child: Column(
            children: [
              Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8E4FF),
                  border: Border.all(color: const Color(0xFFD5CFFF), width: 4.r),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/avatar.png', // Replace with your avatar image
                    width: 80.r,
                    height: 80.r,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.person, size: 60.r, color: Colors.grey);
                    },
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              // Country flag icon
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/azerbaijan_flag.png', // Replace with your flag image
                  width: 24.r,
                  height: 24.r,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 24.r,
                      height: 24.r,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Colors.blue, Colors.red, Colors.green],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 8.h),
              // Username
              Text(
                "Melikmemmed",
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 32.h),
        
        // Menu grid
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16.h,
              crossAxisSpacing: 16.w,
              children: [
                // Quiz button
                _buildMenuTile(
                  icon: Icons.play_arrow,
                  title: "Quizz Spielen",
                  color: const Color(0xFFD5ACFF),
                ),
                // Duel button
                _buildMenuTile(
                  icon: Icons.shield,
                  title: "Duell",
                  color: const Color(0xFFD5ACFF),
                  customIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.ac_unit_rounded, color: Colors.blue, size: 24.r),
                      Icon(Icons.ac_unit_rounded, color: Colors.red, size: 24.r),
                    ],
                  ),
                ),
                // Daily login button
                _buildMenuTile(
                  icon: Icons.calendar_today,
                  title: "Daily Login\nRewards",
                  color: const Color(0xFFD5ACFF),
                ),
                // Event button
                _buildMenuTile(
                  icon: Icons.emoji_events,
                  title: "Event",
                  color: const Color(0xFFD5ACFF),
                ),
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
    Widget? customIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          customIcon ?? Icon(icon, size: 36.r, color: Colors.white),
          SizedBox(height: 8.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


