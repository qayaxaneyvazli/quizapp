// quiz_submission_service.dart - Bu dosyayı yeni oluştur
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class QuizSubmissionService {
  static const String _baseUrl = 'http://116.203.188.209/api';
  
  // Cache for session token to avoid too many auth requests
  static String? _cachedSessionToken;
  static DateTime? _tokenExpiry;
  
  /// Submit quiz answers to the backend
  /// This method runs in the background and doesn't affect the UI
  static Future<void> submitQuizAnswers({
    required int levelId,
    required int duration,
    required List<QuizAnswer> answers,
  }) async {
    try {
      // Get authenticated headers with proper session token
      final headers = await _getAuthenticatedHeaders();
      if (headers == null) {
        print('❌ Failed to get authenticated headers for quiz submission');
        return;
      }

      // Prepare the request body
      final Map<String, dynamic> requestBody = {
        'level_id': levelId,
        'duration': duration,
        'answers': answers.map((answer) => answer.toJson()).toList(),
      };

      print('📤 Submitting quiz data to backend...');
      print('📊 Level ID: $levelId, Duration: $duration, Answers: ${answers.length}');
      
      // Debug: Print the exact data being sent
      print('📋 Request body: ${jsonEncode(requestBody)}');

      // Make the API call
      final response = await http.post(
        Uri.parse('$_baseUrl/quiz/submit'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('✅ Quiz submission successful');
        final responseData = jsonDecode(response.body);
        print('📥 Response: $responseData');
      } else {
        print('❌ Quiz submission failed with status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ Error submitting quiz answers: $e');
    }
  }

  // Helper method to get authenticated headers with session token
  static Future<Map<String, String>?> _getAuthenticatedHeaders() async {
    try {
      // Get current Firebase user and token
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user found for quiz submission');
        return null;
      }

      // Get the ID token
      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        print('❌ Failed to get ID token for quiz submission');
        return null;
      }

      print('🔑 Got Firebase ID token for quiz submission');

      // Check if we have a valid cached session token
      if (_cachedSessionToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
        print('✅ Using cached session token for quiz submission');
        return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_cachedSessionToken',
          'Accept': 'application/json',
        };
      }

      print('⚠️ No valid cached token, need to authenticate with backend for quiz submission');
      
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
          
          print('✅ Got new session token for quiz submission, cached for 30 minutes');
          return {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $sessionToken',
            'Accept': 'application/json',
          };
        }
      }
      
      print('❌ Backend auth failed for quiz submission, cannot proceed');
      return null;
      
    } catch (e) {
      print('❌ Error getting authenticated headers for quiz submission: $e');
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
    print('Quiz submission token cache cleared');
  }
}

/// Model class for quiz answers
class QuizAnswer {
  final int questionId;
  final int? optionId; // For single choice questions
  final List<int>? optionIds; // For multiple choice questions
  final double time; // Time taken to answer in seconds

  QuizAnswer({
    required this.questionId,
    this.optionId,
    this.optionIds,
    required this.time,
  }) : assert(optionId != null || optionIds != null, 'Either optionId or optionIds must be provided');

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'question_id': questionId,
      'time': time,
    };

    if (optionId != null) {
      json['option_id'] = optionId;
    } else if (optionIds != null) {
      json['option_ids'] = optionIds;
    }

    return json;
  }
}