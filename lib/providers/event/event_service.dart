import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/models/question/api_question.dart';
import 'package:quiz_app/models/question/question.dart';

class EventService {
  static const String _baseUrl = 'http://116.203.188.209/api';
  
  // Token Cache mekanizması (QuestionsService ile aynı mantık)
  static String? _cachedSessionToken;
  static DateTime? _tokenExpiry;

  /// Event sorularını API'den çeker ve QuizQuestion listesine çevirir
  static Future<List<QuizQuestion>> fetchEventQuestions() async {
    try {
      // 1. Yetkilendirilmiş header'ları al
      final headers = await _getAuthenticatedHeaders();
      if (headers == null) {
        print('❌ Event Service: Header alınamadı (Auth hatası)');
        throw Exception('Authentication failed');
      }

      print('📤 Event soruları isteniyor...');

      // 2. Event Endpoint'ine istek at
      // NOT: Backend'deki gerçek event endpoint adresinizi buraya yazmalısınız.
      // Örnek: '$_baseUrl/events/active/questions' veya '$_baseUrl/questions?type=event'
      final response = await http.get(
        Uri.parse('$_baseUrl/questions'), // <-- BURAYI BACKEND'E GÖRE GÜNCELLEYİN
        headers: headers,
      );

      if (response.statusCode == 200) {
        // 3. Gelen veriyi işle
        final dynamic decodedBody = jsonDecode(response.body);
        
        // API yanıt yapısına göre data'yı bul (Genelde data: [...] şeklinde olur)
        // Eğer direkt liste dönüyorsa: final List<dynamic> data = decodedBody;
        final List<dynamic> data = decodedBody is List ? decodedBody : decodedBody['data'];

        // 4. Önce ApiQuestion'a, sonra QuizQuestion'a çevir
        final questions = data.map((json) {
          final apiQuestion = ApiQuestion.fromJson(json);
          return apiQuestion.toQuizQuestion(); // Dönüştürme işlemi burada yapılır
        }).toList();
        
        print('✅ Başarılı: ${questions.length} adet event sorusu getirildi.');
        return questions;
      } else {
        print('❌ Event soruları alınamadı. Status: ${response.statusCode}');
        print('📥 Response body: ${response.body}');
        throw Exception('Failed to fetch questions: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Event Service Hatası: $e');
      // Hata durumunda boş liste dönmek isterseniz: return [];
      throw Exception('Error fetching questions: $e');
    }
  }

  // --- AŞAĞIDAKİ KISIM QUESTIONS SERVICE İLE AYNIDIR (Auth Mantığı) ---

  static Future<Map<String, String>?> _getAuthenticatedHeaders() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Auth user yok');
        return null;
      }

      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        print('❌ ID token alınamadı');
        return null;
      }

      // Cache kontrolü
      if (_cachedSessionToken != null && _tokenExpiry != null && DateTime.now().isBefore(_tokenExpiry!)) {
        return {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_cachedSessionToken',
          'Accept': 'application/json',
        };
      }

      print('⚠️ Cache boş veya süresi dolmuş, backend login yapılıyor...');
      
      final backendResponse = await _authenticateWithBackend(idToken);
      if (backendResponse['success'] == true) {
        final sessionToken = backendResponse['data']?['token'] ?? 
                           backendResponse['data']?['access_token'] ??
                           backendResponse['data']?['api_token'];
        
        if (sessionToken != null) {
          _cachedSessionToken = sessionToken.toString();
          _tokenExpiry = DateTime.now().add(Duration(minutes: 30));
          
          return {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $sessionToken',
            'Accept': 'application/json',
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Auth Header hatası: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>> _authenticateWithBackend(String idToken) async {
    try {
      const String backendUrl = '$_baseUrl/auth/firebase-login';
      
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': idToken}),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'success': false,
          'error': 'Backend auth failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection error: $e',
      };
    }
  }
}