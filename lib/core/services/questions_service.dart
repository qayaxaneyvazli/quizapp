import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/models/question/api_question.dart';

class QuestionsService {
  static const String _baseUrl = 'http://116.203.188.209/api';
  
  // Cache for session token to avoid too many auth requests
  static String? _cachedSessionToken;
  static DateTime? _tokenExpiry;
  
  /// Fetch questions for a specific level from the backend
  static Future<List<ApiQuestion>> fetchQuestionsForLevel(int levelId) async {
    try {
      // Get authenticated headers with proper session token
      final headers = await _getAuthenticatedHeaders();
      if (headers == null) {
        print('❌ Failed to get authenticated headers for questions fetch');
        throw Exception('Authentication failed');
      }

      print('📤 Fetching questions for level $levelId...');

      // Make the API call
      final response = await http.get(
        Uri.parse('$_baseUrl/levels/$levelId/questions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final questions = data.map((json) => ApiQuestion.fromJson(json)).toList();
        
        print('✅ Successfully fetched ${questions.length} questions for level $levelId');
        return questions;
      } else {
        print('❌ Failed to fetch questions with status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
        throw Exception('Failed to fetch questions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching questions: $e');
      throw Exception('Error fetching questions: $e');
    }
  }

  // Helper method to get authenticated headers with session token
  static Future<Map<String, String>?> _getAuthenticatedHeaders() async {
    try {
      // Get current Firebase user and token
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user found for questions fetch');
        return null;
      }

      // Get the ID token
      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        print('❌ Failed to get ID token for questions fetch');
        return null;
      }

      print('🔑 Got Firebase ID token for questions fetch');

      // Check if we have a valid cached session token
      if (_cachedSessionToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
        print('✅ Using cached session token for questions fetch');
        return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_cachedSessionToken',
          'Accept': 'application/json',
        };
      }

      print('⚠️ No valid cached token, need to authenticate with backend for questions fetch');
      
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
          
          print('✅ Got new session token for questions fetch, cached for 30 minutes');
          return {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $sessionToken',
            'Accept': 'application/json',
          };
        }
      }
      
      print('❌ Backend auth failed for questions fetch, cannot proceed');
      return null;
      
    } catch (e) {
      print('❌ Error getting authenticated headers for questions fetch: $e');
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

  // Clear cached token (call on logout)
  static void clearTokenCache() {
    _cachedSessionToken = null;
    _tokenExpiry = null;
    print('Questions service token cache cleared');
  }
} 