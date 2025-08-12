import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'user_stats_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '325381610850-3dfkdgtprcngfv04cjk2bkhs26gjutg5.apps.googleusercontent.com',
    // Firebase Console-dan Web client ID-ni götürün və buraya əlavə edin
    // serverClientId: 'your-web-client-id.googleusercontent.com',
  );

  // Firebase istifadəçi məlumatlarını al
  User? get currentUser => _firebaseAuth.currentUser;

  // Auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Email/Password ilə giriş
  Future<Map<String, dynamic>> signInWithEmailPassword(String email, String password) async {
    try {
      const String apiUrl = 'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyBJOuRp-gNOmmNheMuBwy_eo1LayO1HVco';
      
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Backend'ə token göndər
        final backendResponse = await _sendTokenToBackend(data['idToken']);
        
        return {
          'success': true,
          'data': data,
          'backendResponse': backendResponse,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['error']['message'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Google ilə giriş
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Əvvəlcə mövcud session-u təmizlə
      await _googleSignIn.signOut();
      
      print('Starting Google Sign In...');
      
      // Google giriş prosesi
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google sign in cancelled by user');
        return {
          'success': false,
          'error': 'Google sign in cancelled',
        };
      }

      print('Google user: ${googleUser.email}');
      print('Getting Google authentication...');

      // Google authentication məlumatlarını al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Access token: ${googleAuth.accessToken != null ? 'Available' : 'NULL'}');
      print('ID token: ${googleAuth.idToken != null ? 'Available' : 'NULL'}');

      // Token-ləri yoxla
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        print('Google tokens are null');
        
        // Token-ləri yenidən almağa çalış
        await googleUser.clearAuthCache();
        final GoogleSignInAuthentication retryAuth = await googleUser.authentication;
        
        if (retryAuth.accessToken == null || retryAuth.idToken == null) {
          return {
            'success': false,
            'error': 'Failed to get Google tokens after retry',
          };
        }
        
        // Retry auth istifadə et
        final credential = GoogleAuthProvider.credential(
          accessToken: retryAuth.accessToken,
          idToken: retryAuth.idToken,
        );

        print('Creating Firebase credential with retry tokens...');
        final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
        
        final String? idToken = await userCredential.user?.getIdToken();
        
        if (idToken != null) {
          final backendResponse = await _sendTokenToBackend(idToken);
          return {
            'success': true,
            'user': userCredential.user,
            'backendResponse': backendResponse,
          };
        }
      }

      // Firebase credential yarat
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print('Creating Firebase credential...');
      
      // Firebase ilə giriş et
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      print('Firebase sign in successful');
      
      // ID token al
      final String? idToken = await userCredential.user?.getIdToken();
      
      if (idToken != null) {
        print('ID token received');
        // Backend'ə token göndər
        final backendResponse = await _sendTokenToBackend(idToken);
        
        return {
          'success': true,
          'user': userCredential.user,
          'backendResponse': backendResponse,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to get ID token',
        };
      }
    } on PlatformException catch (e) {
      print('PlatformException: ${e.code} - ${e.message}');
      String errorMessage = 'Google sign in failed';
      
      switch (e.code) {
        case 'sign_in_failed':
          errorMessage = 'Google sign in failed. Please try again.';
          break;
        case 'network_error':
          errorMessage = 'Network error. Please check your internet connection.';
          break;
        case 'sign_in_canceled':
          errorMessage = 'Sign in was canceled by user.';
          break;
        case 'sign_in_required':
          errorMessage = 'Sign in is required.';
          break;
        default:
          errorMessage = 'Google sign in error: ${e.message}';
      }
      
      return {
        'success': false,
        'error': errorMessage,
      };
    } catch (e) {
      print('General exception: $e');
      return {
        'success': false,
        'error': 'Google sign in error: $e',
      };
    }
  }

  // Backend'ə token göndər
  Future<Map<String, dynamic>> _sendTokenToBackend(String idToken) async {
    try {
      const String backendUrl = 'http://116.203.188.209/api/auth/firebase-login';
      
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
          'error': 'Backend authentication failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Backend connection error: $e',
      };
    }
  }

  // Çıxış
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    
    // Clear user stats cache
    UserStatsService.clearTokenCache();
  }
}