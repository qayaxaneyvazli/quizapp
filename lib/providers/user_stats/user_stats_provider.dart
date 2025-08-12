import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_stats/user_stats.dart';
import '../../core/services/user_stats_service.dart';

// Provider for user stats
final userStatsProvider = StateNotifierProvider<UserStatsNotifier, AsyncValue<UserStats?>>((ref) {
  return UserStatsNotifier();
});

class UserStatsNotifier extends StateNotifier<AsyncValue<UserStats?>> {
  UserStatsNotifier() : super(const AsyncValue.data(null));

  // Fetch user stats from API
  Future<void> fetchUserStats() async {
    print('🔄 Starting to fetch user stats...');
    state = const AsyncValue.loading();
    
    try {
      final response = await UserStatsService.getUserStats();
      print('📊 User stats service response: $response');
      
      if (response['success'] == true) {
        final userStats = response['data'] as UserStats;
        print('✅ Successfully parsed user stats:');
        print('   - Coins: ${userStats.coins}');
        print('   - Hearts Count: ${userStats.heartsCount}');
        print('   - Hearts Infinite Until: ${userStats.heartsInfiniteUntil}');
        print('   - Has Infinite Hearts: ${userStats.hasInfiniteHearts}');
        if (userStats.hasInfiniteHearts && userStats.infiniteHeartsTimeString.isNotEmpty) {
          print('   - Infinite Hearts Countdown: ${userStats.infiniteHeartsTimeString}');
        }
        state = AsyncValue.data(userStats);
      } else {
        print('❌ User stats fetch failed: ${response['error']}');
        state = AsyncValue.error(
          response['error'] ?? 'Unknown error occurred',
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      print('❌ Exception in fetchUserStats: $error');
      
      // For development/testing purposes, provide fallback data if API fails
      if (error.toString().contains('timeout') || 
          error.toString().contains('SocketException') ||
          error.toString().contains('Connection')) {
        print('🔄 API connection failed, using fallback data for testing...');
        
        // Create mock user stats for testing with infinite hearts
        final futureTime = DateTime.now().add(Duration(hours: 7, minutes: 30, seconds: 25));
        final mockStats = {
          "id": 1,
          "name": "Test User",
          "avatar_url": "",
          "coins": 2500,
          "hearts_count": "infinite", // Set to infinite for testing
          "joker_fifty_fifty": 3,
          "joker_freeze_time": 2,
          "joker_wrong_answer": 1,
          "joker_true_answer": 4,
          "ticket_event": 1,
          "ticket_replay": 2,
          "ticket_duel": 3,
          "hearts_infinite_until": futureTime.toIso8601String() // Set future timestamp
        };
        
        try {
          final fallbackUserStats = UserStats.fromJson(mockStats);
          state = AsyncValue.data(fallbackUserStats);
          print('✅ Using fallback user stats for testing');
          return;
        } catch (e) {
          print('❌ Failed to create fallback stats: $e');
        }
      }
      
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Refresh user stats
  Future<void> refreshUserStats() async {
    await fetchUserStats();
  }

  // Clear user stats (call on logout)
  void clearUserStats() {
    state = const AsyncValue.data(null);
    UserStatsService.clearTokenCache();
  }
}