import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/models/duel/duel_response.dart';

class DuelService {
  static const String _baseUrl = 'http://116.203.188.209/api';
  
  // Cache for session token to avoid too many auth requests
  static String? _cachedSessionToken;
  static DateTime? _tokenExpiry;
  
  // Clear cached token (call on logout)
  static void clearTokenCache() {
    _cachedSessionToken = null;
    _tokenExpiry = null;
    print('Token cache cleared');
  }
  

  

// Bu metodu DuelService class'ının içine, createDuel metodundan sonra ekleyin:
// Send answer for current question
static Future<Map<String, dynamic>> sendAnswer({
  required int duelId,
  required int optionId,
  String? answerKey,
}) async {
  try {
    print('📤 Sending answer for duel $duelId, optionId: $optionId, answerKey: $answerKey');

    // Get authenticated headers
    final headers = await _getAuthenticatedHeaders();
    if (headers == null) {
      return {
        'success': false,
        'error': 'Failed to get authentication headers',
      };
    }

    // Prepare request body
    final Map<String, dynamic> requestBody = {};
    if (optionId != null && optionId > 0) {
      requestBody['option_id'] = optionId;
    }
    if (answerKey != null && answerKey.isNotEmpty) {
      requestBody['answer_key'] = answerKey;
    }

    // Force-close after request to prevent half-open issues
    final requestHeaders = {
      ...headers,
      'Connection': 'close',
    };

    final uri = Uri.parse('$_baseUrl/duels/$duelId/answer');

    Future<http.Response> doPost(http.Client client) {
      return client
          .post(
            uri,
            headers: requestHeaders,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 8));
    }

    http.Client client = http.Client();
    http.Response response;
    try {
      response = await doPost(client);
    } on Exception catch (e) {
      print('Answer API first attempt failed: $e');
      client.close();
      // Brief backoff then retry once with a fresh client
      await Future.delayed(const Duration(milliseconds: 400));
      client = http.Client();
      response = await doPost(client);
    } finally {
      client.close();
    }

    print('Answer API response status: ${response.statusCode}');
    print('Answer API response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return {
        'success': true,
        'data': responseData,
        'result': responseData['result'],
      };
    } else {
      String errorMessage = 'Failed to send answer';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorMessage;
      } catch (e) {
        // Use default error message if parsing fails
      }
      
      return {
        'success': false,
        'error': errorMessage,
        'statusCode': response.statusCode,
      };
    }
  } catch (e) {
    print('Exception in sendAnswer: $e');
    return {
      'success': false,
      'error': 'Network error: $e',
    };
  }
}
  // Send ready signal for duel
  static Future<Map<String, dynamic>> sendReady(int duelId) async {
    try {
      print('Sending ready signal for duel $duelId');

      // Get authenticated headers
      final headers = await _getAuthenticatedHeaders();
      if (headers == null) {
        return {
          'success': false,
          'error': 'Failed to get authentication headers',
        };
      }

      // Force-close after request to prevent half-open issues on some servers
      final requestHeaders = {
        ...headers,
        'Connection': 'close',
      };

      final uri = Uri.parse('$_baseUrl/duels/$duelId/ready');

      Future<http.Response> doPost(http.Client client) {
        return client
            .post(
              uri,
              headers: requestHeaders,
              body: jsonEncode({'ready': true}),
            )
            .timeout(const Duration(seconds: 8));
      }

      http.Client client = http.Client();
      http.Response response;
      try {
        response = await doPost(client);
      } on Exception catch (e) {
        print('Ready API first attempt failed: $e');
        client.close();
        // Brief backoff then retry once with a fresh client
        await Future.delayed(const Duration(milliseconds: 400));
        client = http.Client();
        response = await doPost(client);
      } finally {
        client.close();
      }

      print('Ready API response status: ${response.statusCode}');
      print('Ready API response body: ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        String errorMessage = 'Failed to send ready signal';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Use default error message if parsing fails
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception in sendReady: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Helper method to get authenticated headers
  static Future<Map<String, String>?> _getAuthenticatedHeaders() async {
    try {
      // Get current Firebase user and token
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user found');
        return null;
      }

      // Get the ID token (Firebase auth is already handled in firebase_auth.dart)
      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        print('❌ Failed to get ID token');
        return null;
      }

      print('🔑 Got Firebase ID token: ${idToken.substring(0, 20)}...');

      // Check if we have a valid cached session token
      if (_cachedSessionToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
        print('✅ Using cached session token (expires: $_tokenExpiry)');
        return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_cachedSessionToken',
          'Accept': 'application/json',
        };
      }

      print('⚠️ No valid cached token, need to authenticate with backend');
      
      // Try to get session token, but with careful rate limiting
      final backendResponse = await authenticateWithBackend(idToken);
      if (backendResponse['success'] == true) {
        final sessionToken = backendResponse['data']?['token'] ?? 
                           backendResponse['data']?['access_token'] ??
                           backendResponse['data']?['api_token'];
        
        if (sessionToken != null) {
          // Cache the token for 30 minutes (longer cache to reduce requests)
          _cachedSessionToken = sessionToken.toString();
          _tokenExpiry = DateTime.now().add(Duration(minutes: 30));
          
          print('✅ Got new session token, cached for 30 minutes');
          return {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $sessionToken',
            'Accept': 'application/json',
          };
        }
      } else if (backendResponse['rateLimited'] == true) {
        print('🔄 Rate limited, will retry with exponential backoff');
        // Wait and retry once with exponential backoff
        await Future.delayed(Duration(seconds: 2));
        
        final retryResponse = await authenticateWithBackend(idToken);
        if (retryResponse['success'] == true) {
          final sessionToken = retryResponse['data']?['token'] ?? 
                             retryResponse['data']?['access_token'] ??
                             retryResponse['data']?['api_token'];
          
          if (sessionToken != null) {
            _cachedSessionToken = sessionToken.toString();
            _tokenExpiry = DateTime.now().add(Duration(minutes: 30));
            
            print('✅ Got session token after retry');
            return {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $sessionToken',
              'Accept': 'application/json',
            };
          }
        }
      }
      
      print('❌ Backend auth failed completely, cannot proceed');
      return null;
      
    } catch (e) {
      print('❌ Error getting authenticated headers: $e');
      return null;
    }
  }

  // Authenticate with backend using Firebase token
  static Future<Map<String, dynamic>> authenticateWithBackend(String idToken) async {
    try {
      print('Authenticating with backend...');
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/firebase-login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': idToken,
        }),
      );

      print('Backend auth response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('Backend auth response body: ${response.body}');
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else if (response.statusCode == 429) {
        print('Rate limited by backend - too many requests');
        return {
          'success': false,
          'error': 'Rate limited - too many requests',
          'rateLimited': true,
        };
      } else {
        print('Backend auth failed with status: ${response.statusCode}');
        return {
          'success': false,
          'error': 'Backend authentication failed',
        };
      }
    } catch (e) {
      print('Exception in backend authentication: $e');
      return {
        'success': false,
        'error': 'Backend connection error: $e',
      };
    }
  }
  
  // Create a new duel
  static Future<Map<String, dynamic>> createDuel() async {
    try {
      print('Creating duel...');

      // Get authenticated headers
      final headers = await _getAuthenticatedHeaders();
      if (headers == null) {
        return {
          'success': false,
          'error': 'Failed to get authentication headers',
        };
      }

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/duels'),
        headers: headers,
      );
      
      print('Duel API response status: ${response.statusCode}');
      print('Duel API response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        try {
          final DuelResponse duelResponse = DuelResponse.fromJson(responseData);
          return {
            'success': true,
            'data': duelResponse,
          };
        } catch (e) {
          print('Error parsing duel response: $e');
          return {
            'success': false,
            'error': 'Failed to parse response data: $e',
            'rawData': responseData,
          };
        }
      } else {
        String errorMessage = 'Failed to create duel';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Use default error message if parsing fails
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception in createDuel: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Submit all answers for a duel
  static Future<Map<String, dynamic>> submitAnswers({
    required int duelId,
    required List<Map<String, dynamic>> answers,
    bool botSubmission = false,
  }) async {
    try {
      print('Submitting answers for duel $duelId');
      print('Answers: $answers');

      // Get authenticated headers
      final headers = await _getAuthenticatedHeaders();
      if (headers == null) {
        return {
          'success': false,
          'error': 'Failed to get authentication headers',
        };
      }

      // Prepare request body
      final requestBody = {
        'duel_id': duelId,
        'bot_submission': botSubmission,
        'answers': answers,
      };

      print('Request body: ${jsonEncode(requestBody)}');
      print('Bot submission flag: $botSubmission');

      // Make API request
      final response = await http.post(
        Uri.parse('$_baseUrl/duel/submit-answers'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('Submit answers response status: ${response.statusCode}');
      print('Submit answers response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        
        // If this was player submission, also submit bot answers
        if (!botSubmission) {
          print('Player answers submitted successfully, now submitting bot answers...');
          
          // Generate bot answers with same structure
          List<Map<String, dynamic>> botAnswers = answers.map((answer) {
            // Bot picks random answer (1-4 options typically)
            int randomOption = 1 + ((answer['duel_question_id'] as int) % 4);
            return {
              'duel_question_id': answer['duel_question_id'],
              'selected_option_id': randomOption,
              'time_taken': 2.0 + ((answer['duel_question_id'] as int) % 3), // 2-5 seconds
            };
          }).toList();
          
          // Submit bot answers
          final botResult = await submitAnswers(
            duelId: duelId,
            answers: botAnswers,
            botSubmission: true,
          );
          
          print('Bot answers submission result: ${botResult['success']}');
        }
        
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        String errorMessage = 'Failed to submit answers';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Use default error message if parsing fails
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception in submitAnswers: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Submit both player and bot answers for a duel
  static Future<Map<String, dynamic>> submitAllAnswers({
    required int duelId,
    required List<Map<String, dynamic>> playerAnswers,
    required List<Map<String, dynamic>> botAnswers,
  }) async {
    try {
      // First submit player answers
      final playerResult = await submitAnswers(
        duelId: duelId,
        answers: playerAnswers,
        botSubmission: false,
      );
      
      if (!playerResult['success']) {
        return playerResult; // Return error if player submission fails
      }
      
      // Then submit bot answers
      final botResult = await submitAnswers(
        duelId: duelId,
        answers: botAnswers,
        botSubmission: true,
      );
      
      return botResult; // Return bot submission result
    } catch (e) {
      print('Exception in submitAllAnswers: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Helper method to submit a single answer (for backward compatibility)
  static Future<Map<String, dynamic>> submitAnswer({
    required int duelId,
    required int duelQuestionId,
    required int selectedOptionId,
    double timeTaken = 5.0,
  }) async {
    // Create single answer in the expected format
    final answers = [
      {
        'duel_question_id': duelQuestionId,
        'selected_option_id': selectedOptionId,
        'time_taken': timeTaken,
      }
    ];

    return await submitAnswers(
      duelId: duelId,
      answers: answers,
      botSubmission: false,
    );
  }

  // Get duel status/results
  static Future<Map<String, dynamic>> getDuelStatus(int duelId) async {
    try {
      print('Getting duel status for duel $duelId');

      // Get authenticated headers
      final headers = await _getAuthenticatedHeaders();
      if (headers == null) {
        return {
          'success': false,
          'error': 'Failed to get authentication headers',
        };
      }

      // Make API request
      final response = await http.get(
        Uri.parse('$_baseUrl/duels/$duelId'),
        headers: headers,
      );

      print('Get duel status response status: ${response.statusCode}');
      print('Get duel status response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        String errorMessage = 'Failed to get duel status';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          // Use default error message if parsing fails
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      print('Exception in getDuelStatus: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }
}