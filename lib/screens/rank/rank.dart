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
    LeaderboardUser(id: 5, username: "Woman55", score: 24380, countryCode: "tr"),
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

// Provider for selected tab index
final selectedTabProvider = StateProvider<int>((ref) => 0);

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
    final selectedTabIndex = ref.watch(selectedTabProvider);
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Background image section instead of trophy section
          buildRangTrophySection(),
          
          // Tab bar for World, Duel, Event
          buildTabBar(context, ref, selectedTabIndex),
          
          // Current user section with green background
          buildUserSection(context, userStats, isDarkMode),
          
          // Leaderboard section with yellow items
          Expanded(
            child: buildLeaderboard(context, leaderboard, isDarkMode),
          ),
        ],
      ),
    );
  }

Widget buildRangTrophySection() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Rang-Trophys.jpeg'),
          fit: BoxFit.cover, // Changed from cover to fitWidth to show more of the image
          alignment: Alignment.center, // Centers the image
          scale: 1.5, // Adds scaling to zoom out (values greater than 1 zoom out)
        ),
        // Add a subtle gradient overlay to ensure text readability if needed
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.1),
          ],
        ),
      ),
      // You can also use FractionallySizedBox to control how much of the image is shown
      child: FractionallySizedBox(
        widthFactor: 1.0,
        heightFactor: 1.0,
        child: Container(
          decoration: BoxDecoration(
            // This is an alternative way to adjust the image if needed
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }

  Widget buildTabBar(BuildContext context, WidgetRef ref, int selectedTabIndex) {
    final tabs = ["World", "Duel", "Event"];
    
    return Container(
      color: Color(0xFF6978ED),
      height: 50,
      child: Stack(
        children: [
          // Tab buttons
          Row(
            children: List.generate(
              tabs.length,
              (index) => Expanded(
                child: InkWell(
                  onTap: () => ref.read(selectedTabProvider.notifier).state = index,
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        color: selectedTabIndex == index ? Color(0xFFFFEB3B) : Colors.white,
                        fontSize: 18,
                        fontWeight: selectedTabIndex == index ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Indicator
          Positioned(
            bottom: 0,
            left: MediaQuery.of(context).size.width / 3 * selectedTabIndex,
            child: Container(
              width: MediaQuery.of(context).size.width / 3,
              height: 4,
              color: Color(0xFFFFEB3B),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildUserSection(BuildContext context, UserStats userStats, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Color(0xFF8AEA92), // Light green
      child: Row(
        children: [
          // Left side - Rank & Score
          Text(
            "${userStats.rank}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 12),
          
          // User avatar
          _buildUserAvatar(userStats.countryCode),
          SizedBox(width: 12),
          
          // Username
          Text(
            userStats.username,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          
          Spacer(),
          
          // Score
          Text(
            "${userStats.score}",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 6),
          
          // Star icon
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Color(0xFF2196F3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.star,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildLeaderboard(BuildContext context, List<LeaderboardUser> leaderboard, bool isDarkMode) {
    return ListView.builder(
      itemCount: leaderboard.length,
      padding: EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final user = leaderboard[index];
        return Container(
          margin: EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Color(0xFFFCE93D), // Yellow
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 2,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Rank
                Text(
                  "${user.id}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 12),
                
                // Avatar
                _buildUserAvatar(user.countryCode),
                SizedBox(width: 12),
                
                // Username
                Text(
                  user.username,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                Spacer(),
                
                // Score
                Text(
                  "${user.score}",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(width: 6),
                
                // Star icon - matches the gold icon in the image
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFAB00),
                    shape: BoxShape.circle,
                    border: Border.all(color: Color(0xFFE65100), width: 1),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserAvatar(String countryCode) {
    return Stack(
      children: [
        // Avatar background
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey[300],
          child: Icon(
            Icons.person,
            size: 24,
            color: Colors.grey[700],
          ),
        ),
        
        // Country flag
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
            child: ClipOval(
              child: CountryFlag.fromCountryCode(
                countryCode,
                height: 16,
                width: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}