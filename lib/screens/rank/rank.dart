import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_flags/country_flags.dart';
import '../../providers/theme_mode_provider.dart';

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

class RankScreen extends ConsumerWidget {
  const RankScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaderboard = ref.watch(leaderboardProvider);
    final userStats = ref.watch(userStatsProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final theme = Theme.of(context);
    
    // Colors for dark and light mode
    final trophyBackgroundColor = isDarkMode 
        ? Color(0xFF8B7500) // Darker gold for dark mode
        : Color(0xFFFFD700); // Original gold for light mode
        
    final userSectionColor = isDarkMode
        ? Color(0xFF2E4027) // Dark green for dark mode
        : Color(0xFFAAFF99); // Light green for light mode
    
    // Format the hearts duration
    String formattedHeartsDuration = _formatDuration(userStats.heartsDuration);
    
    // Get screen dimensions to determine if we're on a tablet
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Trophy section
          Expanded(
            flex: 2,
            child: Container(
              color: trophyBackgroundColor,
              width: double.infinity,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTrophy(color: Colors.brown, scale: 0.9, isDarkMode: isDarkMode),
                    SizedBox(width: 10),
                    _buildTrophy(color: isDarkMode ? Colors.grey[700]! : Colors.grey, scale: 1.0, isDarkMode: isDarkMode),
                    SizedBox(width: 10),
                    _buildTrophy(color: isDarkMode ? Colors.red[900]! : Colors.redAccent, scale: 0.9, isDarkMode: isDarkMode),
                  ],
                ),
              ),
            ),
          ),
          
          // Current user section
          Container(
            color: userSectionColor,
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Text(
                  userStats.rank.toString(),
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 12),
                _buildUserAvatar(userStats.countryCode, isDarkMode),
                SizedBox(width: 12),
                Text(
                  userStats.username,
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Text(
                  userStats.score.toString(),
                  style: TextStyle(
                    fontSize: isTablet ? 18 : 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.star,
                  color: isDarkMode ? Colors.purpleAccent : Colors.purple,
                  size: isTablet ? 20 : 24,
                ),
              ],
            ),
          ),
          
          // Leaderboard section
          Expanded(
            flex: 3,
            child: Container(
              color: trophyBackgroundColor,
              child: ListView.builder(
                itemCount: leaderboard.length,
                itemBuilder: (context, index) {
                  final user = leaderboard[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: isDarkMode 
                          ? Color(0xFF6B5900) // Slightly lighter gold for dark mode items
                          : const Color(0xFFFFD700),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode 
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.1),
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
                            fontSize: isTablet ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: 12),
                        _buildUserAvatar(user.countryCode, isDarkMode),
                        SizedBox(width: 12),
                        Text(
                          user.username,
                          style: TextStyle(
                            fontSize: isTablet ? 14 : 18,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          user.score.toString(),
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 20,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.star,
                          color: isDarkMode ? Colors.purpleAccent : Colors.purple,
                          size: isTablet ? 18 : 22,
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
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: iconColor,
              size: 30,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTrophy({required Color color, required double scale, required bool isDarkMode}) {
    // Adjust colors for better visibility in dark mode
    final baseColor = isDarkMode ? color.withOpacity(0.8) : color;
    final detailColor = isDarkMode ? Colors.brown[700]! : Colors.brown.withOpacity(0.8);
    
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100,
        height: 140,
        child: Column(
          children: [
            Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: baseColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 15,
                    height: 40,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                    ),
                  ),
                  Container(
                    width: 15,
                    height: 40,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 40,
              height: 20,
              color: baseColor.withOpacity(0.8),
            ),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: detailColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String countryCode, bool isDarkMode) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[300],
          child: Icon(
            Icons.person,
            size: 30,
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isDarkMode ? Colors.black : Colors.white, width: 2),
            ),
            child: ClipOval(
              child: CountryFlag.fromCountryCode(
                countryCode,
                height: 20,
                width: 20,
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