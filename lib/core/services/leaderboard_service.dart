import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/leaderboard/leaderboard.dart';
import 'user_stats_service.dart';

class LeaderboardService {
  static const String _baseUrl = 'http://116.203.188.209/api';

  // Fetch leaderboard data from API
  static Future<Map<String, dynamic>> getLeaderboard() async {
    try {
      print('🏆 Fetching leaderboard...');
      
      // Get authenticated headers
      final headers = await UserStatsService.getAuthenticatedHeaders();
      if (headers == null) {
        return {
          'success': false,
          'error': 'Authentication failed',
        };
      }

      // Make GET request to leaderboard endpoint
      const String leaderboardUrl = '$_baseUrl/score/leaderboard';
      final response = await http.get(
        Uri.parse(leaderboardUrl),
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - server took too long to respond');
        },
      );

      print('🏆 Leaderboard response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Leaderboard API Response received: $data');
        
        // Parse the response into LeaderboardResponse model
        final leaderboardResponse = LeaderboardResponse.fromJson(data);
        
        return {
          'success': true,
          'data': leaderboardResponse,
        };
      } else if (response.statusCode == 401) {
        // Token might be expired, clear cache and retry once
        UserStatsService.clearTokenCache();
        print('🔄 Token expired, retrying with fresh token...');
        
        final retryHeaders = await UserStatsService.getAuthenticatedHeaders();
        if (retryHeaders != null) {
          final retryResponse = await http.get(
            Uri.parse(leaderboardUrl),
            headers: retryHeaders,
          );
          
          if (retryResponse.statusCode == 200) {
            final data = jsonDecode(retryResponse.body);
            final leaderboardResponse = LeaderboardResponse.fromJson(data);
            
            return {
              'success': true,
              'data': leaderboardResponse,
            };
          }
        }
        
        return {
          'success': false,
          'error': 'Authentication failed after retry',
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to fetch leaderboard: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Leaderboard fetch error: $e');
      
      // Return fallback data for testing
      if (e.toString().contains('SocketException') || 
          e.toString().contains('timeout')) {
        print('🔄 Using fallback leaderboard data...');
        final fallbackData = {
          "scope": "global",
          "leaderboard": [
            {
              "user_id": 1,
              "name": "rasulzadeamin@gmail.com",
              "total_score": 29000,
              "total_stars": 9
            },
            {
              "user_id": 2,
              "name": "test@example.com",
              "total_score": 25000,
              "total_stars": 8
            },
            {
              "user_id": 3,
              "name": "demo@example.com",
              "total_score": 22000,
              "total_stars": 7
            }
          ]
        };
        
        final leaderboardResponse = LeaderboardResponse.fromJson(fallbackData);
        return {
          'success': true,
          'data': leaderboardResponse,
        };
      }
      
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
} 