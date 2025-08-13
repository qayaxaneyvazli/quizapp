import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_stats/user_stats.dart';

class UserStatsService {
  static const String _baseUrl = 'http://116.203.188.209/api';
  
  // Cache for session token to avoid too many auth requests
  static String? _cachedSessionToken;
  static DateTime? _tokenExpiry;
  
  // Clear cached token (call on logout)
  static void clearTokenCache() {
    _cachedSessionToken = null;
    _tokenExpiry = null;
    print('User stats token cache cleared');
  }
  
  // Helper method to get authenticated headers (similar to DuelService)
  static Future<Map<String, String>?> getAuthenticatedHeaders() async {
    try {
      // Get current Firebase user and token
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user found');
        return null;
      }

      // Get the ID token
      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        print('❌ Failed to get ID token');
        return null;
      }

      print('🔑 Got Firebase ID token for user stats');

      // Check if we have a valid cached session token
      if (_cachedSessionToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
        print('✅ Using cached session token for user stats');
        return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_cachedSessionToken',
          'Accept': 'application/json',
        };
      }

      print('⚠️ No valid cached token, need to authenticate with backend for user stats');
      
      // Try to get session token
      final backendResponse = await _authenticateWithBackend(idToken);
      if (backendResponse['success'] == true) {
        final sessionToken = backendResponse['data']?['token'] ?? 
                           backendResponse['data']?['access_token'] ??
                           backendResponse['data']?['api_token'];
        
        if (sessionToken != null) {
          // Cache the token for 30 minutes
          _cachedSessionToken = sessionToken.toString();
          _tokenExpiry = DateTime.now().add(Duration(minutes: 30));
          
          print('✅ Got new session token for user stats, cached for 30 minutes');
          return {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $sessionToken',
            'Accept': 'application/json',
          };
        }
      }
      
      print('❌ Backend auth failed for user stats, cannot proceed');
      return null;
      
    } catch (e) {
      print('❌ Error getting authenticated headers for user stats: $e');
      return null;
    }
  }

  // Authenticate with backend using Firebase token
  static Future<Map<String, dynamic>> _authenticateWithBackend(String idToken) async {
    try {
      const String backendUrl = '$_baseUrl/auth/firebase-login';
      
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
        }),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 429) {
        return {
          'success': false,
          'rateLimited': true,
          'error': 'Rate limited',
        };
      } else {
        return {
          'success': false,
          'error': 'Backend authentication failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Backend connection error: $e',
      };
    }
  }

  // Fetch user stats from the API
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      print('📊 Fetching user stats...');
      
      // Get authenticated headers
      final headers = await getAuthenticatedHeaders();
      if (headers == null) {
        return {
          'success': false,
          'error': 'Authentication failed',
        };
      }

      // Make GET request to user stats endpoint with timeout
      const String statsUrl = '$_baseUrl/user/stats';
      final response = await http.get(
        Uri.parse(statsUrl),
        headers: headers,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout - server took too long to respond');
        },
      );

      print('📊 User stats response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ API Response received: $data');
        print('🔍 Hearts field in API response: ${data['hearts']} (type: ${data['hearts']?.runtimeType})');
        
        // Parse the response into UserStats model
        final userStats = UserStats.fromJson(data);
        
        return {
          'success': true,
          'data': userStats,
        };
      } else if (response.statusCode == 401) {
        // Token might be expired, clear cache and retry once
        clearTokenCache();
        print('🔄 Token expired, retrying with fresh token...');
        
        final retryHeaders = await getAuthenticatedHeaders();
        if (retryHeaders != null) {
          final retryResponse = await http.get(
            Uri.parse(statsUrl),
            headers: retryHeaders,
          );
          
          if (retryResponse.statusCode == 200) {
            final data = jsonDecode(retryResponse.body);
            final userStats = UserStats.fromJson(data);
            
            return {
              'success': true,
              'data': userStats,
            };
          }
        }
        
        return {
          'success': false,
          'error': 'Authentication failed after retry',
        };
      } else {
        print('❌ Failed to fetch user stats: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Failed to fetch user stats: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error fetching user stats: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}