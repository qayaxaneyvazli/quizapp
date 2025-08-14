import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/leaderboard/leaderboard.dart';
import '../../core/services/leaderboard_service.dart';

// Provider for leaderboard data
final leaderboardProvider = StateNotifierProvider<LeaderboardNotifier, AsyncValue<LeaderboardResponse?>>((ref) {
  return LeaderboardNotifier();
});

class LeaderboardNotifier extends StateNotifier<AsyncValue<LeaderboardResponse?>> {
  LeaderboardNotifier() : super(const AsyncValue.data(null));

  // Fetch leaderboard data from API
  Future<void> fetchLeaderboard({String? type}) async {
    try {
      state = const AsyncValue.loading();
      
      final result = await LeaderboardService.getLeaderboard(type: type);
      
      if (result['success'] == true) {
        final leaderboardResponse = result['data'] as LeaderboardResponse;
        
        print('✅ Successfully fetched leaderboard:');
        print('   - Scope: ${leaderboardResponse.scope}');
        print('   - Type: ${leaderboardResponse.type}');
        print('   - Entries count: ${leaderboardResponse.leaderboard.length}');
        for (int i = 0; i < leaderboardResponse.leaderboard.length; i++) {
          final entry = leaderboardResponse.leaderboard[i];
          print('   - Entry ${i + 1}: ${entry.name} - Score: ${entry.totalScore} - Stars: ${entry.totalStars}');
        }
        
        state = AsyncValue.data(leaderboardResponse);
      } else {
        print('❌ Failed to fetch leaderboard: ${result['error']}');
        state = AsyncValue.error(result['error'], StackTrace.current);
      }
    } catch (e, stack) {
      print('❌ Error in fetchLeaderboard: $e');
      state = AsyncValue.error(e, stack);
    }
  }

  // Refresh leaderboard data
  Future<void> refreshLeaderboard({String? type}) async {
    await fetchLeaderboard(type: type);
  }

  // Clear leaderboard data
  void clearLeaderboard() {
    state = const AsyncValue.data(null);
  }
} 