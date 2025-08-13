import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_flags/country_flags.dart';
import '../../providers/theme_mode_provider.dart';
import '../../providers/leaderboard/leaderboard_provider.dart';
import '../../models/leaderboard/leaderboard.dart';
import '../../providers/user_stats/user_stats_provider.dart' as stats;

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



class RankScreen extends ConsumerWidget {
  const RankScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    User? user = FirebaseAuth.instance.currentUser;
    String displayName = user?.displayName ?? 'Guest';
    String email = user?.email ?? '';
    String photoUrl = user?.photoURL ?? '';

    final leaderboardAsync = ref.watch(leaderboardProvider);
    final userStatsAsync = ref.watch(stats.userStatsProvider);
    final isDarkMode = ref.watch(themeModeProvider) == ThemeMode.dark;
    final selectedTabIndex = ref.watch(selectedTabProvider);
    
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (leaderboardAsync is AsyncData && leaderboardAsync.value == null) {
        print('🏆 Rank screen triggering leaderboard fetch...');
        ref.read(leaderboardProvider.notifier).fetchLeaderboard();
      }
      if (userStatsAsync is AsyncData && userStatsAsync.value == null) {
        print('🏆 Rank screen triggering user stats fetch...');
        ref.read(stats.userStatsProvider.notifier).fetchUserStats();
      }
    });
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Background image section instead of trophy section
          buildRangTrophySection(),
          
          // Tab bar for World, Duel, Event
          buildTabBar(context, ref, selectedTabIndex),
          

          
                     // Leaderboard section with yellow items
           Expanded(
             child: buildLeaderboard(context, leaderboardAsync, isDarkMode, ref, selectedTabIndex),
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
      color: Color(0xFF6A1B9A),
      height: 50,
      child: Stack(
        children: [
          // Tab buttons
          Row(
            children: List.generate(
              tabs.length,
              (index) => Expanded(
                                 child: InkWell(
                   onTap: () {
                     ref.read(selectedTabProvider.notifier).state = index;
                     // Refresh leaderboard when tab changes
                     ref.read(leaderboardProvider.notifier).refreshLeaderboard();
                   },
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



     Widget buildLeaderboard(BuildContext context, AsyncValue<LeaderboardResponse?> leaderboardAsync, bool isDarkMode, WidgetRef ref, int selectedTabIndex) {
    return leaderboardAsync.when(
      data: (leaderboardResponse) {
        if (leaderboardResponse == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading leaderboard...'),
              ],
            ),
          );
        }
        
        final leaderboard = leaderboardResponse.leaderboard;
        
        // Get current user info
        User? user = FirebaseAuth.instance.currentUser;
        String displayName = user?.displayName ?? 'Guest';
        String userEmail = user?.email ?? '';
        String photoUrl = user?.photoURL ?? '';
        
                 // Get user stats for score based on selected tab
         final userStatsAsync = ref.watch(stats.userStatsProvider);
         int userScore = 0;
         
         userStatsAsync.whenData((userStats) {
           if (userStats != null) {
             // Get score based on selected tab
             switch (selectedTabIndex) {
               case 0: // World (Quiz)
                 userScore = userStats.quizScore;
                 break;
               case 1: // Duel
                 userScore = userStats.duelScore;
                 break;
               case 2: // Event
                 userScore = userStats.eventScore;
                 break;
               default:
                 userScore = userStats.quizScore;
             }
           }
         });
        
        // Create combined leaderboard with current user
        List<Map<String, dynamic>> combinedLeaderboard = [];
        
        // Add API leaderboard entries
        for (int i = 0; i < leaderboard.length; i++) {
          final entry = leaderboard[i];
          combinedLeaderboard.add({
            'userId': entry.userId,
            'name': entry.name,
            'score': entry.totalScore,
            'stars': entry.totalStars,
            'isCurrentUser': false,
            'photoUrl': '',
            'countryCode': 'az',
          });
        }
        
        // Add current user if not already in the list
        // Check by email first, then by name as fallback
        bool userExists = combinedLeaderboard.any((entry) => 
          entry['name'] == userEmail || entry['name'] == displayName
        );
        
        print('🏆 User check:');
        print('   - User email: $userEmail');
        print('   - User display name: $displayName');
        print('   - User exists in leaderboard: $userExists');
        
        if (!userExists) {
          combinedLeaderboard.add({
            'userId': 0, // Special ID for current user
            'name': displayName,
            'score': userScore,
            'stars': 0,
            'isCurrentUser': true,
            'photoUrl': photoUrl,
            'countryCode': 'az',
          });
        } else {
          // If user exists in API data, mark them as current user and update their data
          for (int i = 0; i < combinedLeaderboard.length; i++) {
            if (combinedLeaderboard[i]['name'] == userEmail || combinedLeaderboard[i]['name'] == displayName) {
              print('🏆 Found user in leaderboard, updating...');
              combinedLeaderboard[i]['isCurrentUser'] = true;
              combinedLeaderboard[i]['photoUrl'] = photoUrl;
              // Update score with current user's score if it's higher
              if (userScore > combinedLeaderboard[i]['score']) {
                combinedLeaderboard[i]['score'] = userScore;
                print('🏆 Updated user score to: $userScore');
              }
              break;
            }
          }
        }
        
        // Sort by score (highest first)
        combinedLeaderboard.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));
        
        // Calculate ranks
        for (int i = 0; i < combinedLeaderboard.length; i++) {
          combinedLeaderboard[i]['rank'] = i + 1;
        }
        
        return ListView.builder(
          itemCount: combinedLeaderboard.length,
          padding: EdgeInsets.all(8),
          itemBuilder: (context, index) {
            final entry = combinedLeaderboard[index];
            final isCurrentUser = entry['isCurrentUser'] as bool;
            
                         return Container(
               margin: EdgeInsets.only(bottom: isCurrentUser ? 12 : 8),
               decoration: BoxDecoration(
                 color: isCurrentUser ? Color(0xFF8AEA92) : Color(0xFFFCE93D), // Green for current user, Yellow for others
                 borderRadius: BorderRadius.circular(8),
                 border: isCurrentUser ? Border.all(color: Color(0xFF4CAF50), width: 2) : null, // Border for current user
                 boxShadow: [
                   BoxShadow(
                     color: isCurrentUser ? Colors.green.withOpacity(0.3) : Colors.black12,
                     blurRadius: isCurrentUser ? 4 : 2,
                     offset: Offset(0, isCurrentUser ? 3 : 2),
                   ),
                 ],
               ),
               child: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 16, vertical: isCurrentUser ? 16 : 12),
                child: Row(
                  children: [
                                         // Rank
                     Text(
                       "${entry['rank']}",
                       style: TextStyle(
                         fontSize: isCurrentUser ? 22 : 18,
                         fontWeight: FontWeight.bold,
                         color: Colors.black87,
                       ),
                     ),
                    SizedBox(width: 12),
                    
                                         // Avatar
                     _buildUserAvatar(entry['countryCode'], entry['photoUrl'], isCurrentUser),
                    SizedBox(width: 12),
                    
                                         // Username
                     Text(
                       entry['name'],
                       style: TextStyle(
                         fontSize: isCurrentUser ? 20 : 16,
                         fontWeight: FontWeight.bold,
                         color: Colors.black87,
                       ),
                     ),
                    
                    Spacer(),
                    
                                         // Score
                     Text(
                       "${entry['score']}",
                       style: TextStyle(
                         fontSize: isCurrentUser ? 22 : 18,
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
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading leaderboard...'),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 48, color: Colors.red),
            SizedBox(height: 16),
            Text('Failed to load leaderboard'),
            SizedBox(height: 8),
            Text('$error'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String countryCode, String photoUrl, [bool isCurrentUser = false]) {
    final radius = isCurrentUser ? 25.0 : 20.0;
    final iconSize = isCurrentUser ? 30.0 : 24.0;
    final flagSize = isCurrentUser ? 20.0 : 16.0;
    
    return Stack(
      children: [
        // Avatar background - show user photo if available
        CircleAvatar(
          radius: radius,
          backgroundColor: Colors.grey[300],
          backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
          child: photoUrl.isEmpty ? Icon(
            Icons.person,
            size: iconSize,
            color: Colors.grey[700],
          ) : null,
        ),
        
                 // Country flag
         Positioned(
           bottom: 0,
           right: 0,
           child: Container(
             width: flagSize,
             height: flagSize,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               border: Border.all(color: Colors.white, width: 1),
             ),
             child: ClipOval(
               child: CountryFlag.fromCountryCode(
                 countryCode,
                 height: flagSize,
                 width: flagSize,
               ),
             ),
           ),
         ),
      ],
    );
  }
}