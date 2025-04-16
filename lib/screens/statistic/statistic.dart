import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:country_flags/country_flags.dart';

// Provider for leaderboard data
final leaderboardProvider = StateProvider<List<LeaderboardUser>>((ref) {
  return [
    LeaderboardUser(id: 1, username: "Player333", score: 30000, countryCode: "az"),
    LeaderboardUser(id: 2, username: "Spieler999", score: 28450, countryCode: "tr"),
    LeaderboardUser(id: 3, username: "Abigail", score: 27000, countryCode: "tr"),
    LeaderboardUser(id: 4, username: "SuperHirn", score: 25000, countryCode: "tr"),
    // Add more users as needed
  ];
});

// Provider for current user stats
final userStatsProvider = StateProvider<UserStats>((ref) {
  return UserStats(
    stars: 1000,
    heartsDuration: const Duration(hours: 7, minutes: 30, seconds: 25),
    coins: 2500,
    rank: 1635,
    username: "Melikmemmed",
    score: 560,
    countryCode: "az",
  );
});

class UserStats {
  final int stars;
  final Duration heartsDuration;
  final int coins;
  final int rank;
  final String username;
  final int score;
  final String countryCode;

  UserStats({
    required this.stars,
    required this.heartsDuration,
    required this.coins,
    required this.rank,
    required this.username,
    required this.score,
    required this.countryCode,
  });
}

class LeaderboardUser {
  final int id;
  final String username;
  final int score;
  final String countryCode;

  LeaderboardUser({
    required this.id,
    required this.username,
    required this.score,
    required this.countryCode,
  });
}

class StatisticScreen extends ConsumerWidget {
  const StatisticScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final userStats = ref.watch(userStatsProvider);
    
    // Format the hearts duration
    String formattedHeartsDuration = _formatDuration(userStats.heartsDuration);
    
    // Get screen dimensions to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Top stats section
       
          
          // Trophy section
          Expanded(
            flex: 2,
            child: Container(
              color: const Color(0xFFFFD700), // Gold color
              width: double.infinity,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTrophy(color: Colors.brown, scale: 0.9),
                    SizedBox(width: 10.w),
                    _buildTrophy(color: Colors.grey, scale: 1.0),
                    SizedBox(width: 10.w),
                    _buildTrophy(color: Colors.redAccent, scale: 0.9),
                  ],
                ),
              ),
            ),
          ),
          
          // Current user section
          Container(
            color: const Color(0xFFAAFF99), // Light green
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
            child: Row(
              children: [
                Text(
                  userStats.rank.toString(),
                  style: TextStyle(
                    fontSize: isTablet ? 18.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 12.w),
                _buildUserAvatar(userStats.countryCode),
                SizedBox(width: 12.w),
                Text(
                  userStats.username,
                  style: TextStyle(
                    fontSize: isTablet ? 16.sp : 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  userStats.score.toString(),
                  style: TextStyle(
                    fontSize: isTablet ? 18.sp : 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.star,
                  color: Colors.purple,
                  size: isTablet ? 20.r : 24.r,
                ),
              ],
            ),
          ),
          
          // Leaderboard section
          Expanded(
            flex: 3,
            child: Container(
              color: const Color(0xFFFFD700), // Gold color
              child: ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final user = leaderboard[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(8.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          user.id.toString(),
                          style: TextStyle(
                            fontSize: isTablet ? 16.sp : 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        _buildUserAvatar(user.countryCode),
                        SizedBox(width: 12.w),
                        Text(
                          user.username,
                          style: TextStyle(
                            fontSize: isTablet ? 14.sp : 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          user.score.toString(),
                          style: TextStyle(
                            fontSize: isTablet ? 16.sp : 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.star,
                          color: Colors.purple,
                          size: isTablet ? 18.r : 22.r,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Column(
      children: [
        Container(
          width: 50.r,
          height: 50.r,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 30.r,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrophy({required Color color, required double scale}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100.r,
        height: 140.r,
        child: Column(
          children: [
            Container(
              width: 80.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.r),
                  topRight: Radius.circular(40.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 15.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20.r),
                        bottomRight: Radius.circular(20.r),
                      ),
                    ),
                  ),
                  Container(
                    width: 15.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        bottomLeft: Radius.circular(20.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40.r,
              height: 20.r,
              color: color.withOpacity(0.8),
            ),
            Container(
              width: 60.r,
              height: 20.r,
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String countryCode) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 25.r,
          backgroundColor: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: 30.r,
            color: Colors.grey[700],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20.r,
            height: 20.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: CountryFlag.fromCountryCode(
                countryCode,
                height: 20.r,
                width: 20.r,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }
}