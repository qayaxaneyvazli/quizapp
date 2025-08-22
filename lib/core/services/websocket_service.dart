import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/core/services/duel_service.dart';

class WebSocketService {
  static const String _wsHost = '116.203.188.209';
  static const int _wsPort = 6002;
  static const String _pusherKey = 'localkey';
  static const String _authUrl = 'http://116.203.188.209/api/broadcasting/auth';
  
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _eventController;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  
  // Singleton pattern
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  // Get event stream
  Stream<Map<String, dynamic>> get eventStream {
    _eventController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _eventController!.stream;
  }

  // Initialize WebSocket connection
  Future<bool> initialize() async {
    try {
      print('🔌 Initializing WebSocket connection...');
      
      // Get authentication token
      final token = await _getAuthToken();
      if (token == null) {
        print('❌ Failed to get authentication token');
        return false;
      }

      return await _connect(token);
    } catch (e) {
      print('❌ Error initializing WebSocket: $e');
      return false;
    }
  }

  // Connect to WebSocket
  Future<bool> _connect(String token) async {
    if (_isConnecting) return false;
    
    _isConnecting = true;
    
    try {
      // Create WebSocket connection with authentication
      final wsUrl = 'ws://$_wsHost:$_wsPort/app/$_pusherKey?protocol=7&client=js&version=7.2.0&flash=false';
      
      print('🔌 Connecting to WebSocket: $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Listen to incoming messages
      _channel!.stream.listen(
        (message) => _handleMessage(message),
        onError: (error) => _handleError(error),
        onDone: () => _handleDisconnect(),
      );

      // Send authentication message
      await _sendAuthMessage(token);
      
      // Start ping timer to keep connection alive
      _startPingTimer();
      
      _isConnecting = false;
      _reconnectAttempts = 0;
      
      print('✅ WebSocket connection established');
      return true;
    } catch (e) {
      _isConnecting = false;
      print('❌ Error connecting to WebSocket: $e');
      return false;
    }
  }

  // Send authentication message
  Future<void> _sendAuthMessage(String token) async {
    try {
      // First, wait for connection to be established
      await Future.delayed(Duration(milliseconds: 500));
      
      // Don't send subscription message immediately
      // We'll send it when we actually want to subscribe to a specific channel
      print('🔐 WebSocket ready for authentication');
    } catch (e) {
      print('❌ Error in auth message setup: $e');
    }
  }

  // Subscribe to duel channel
  Future<bool> subscribeToDuel(int duelId) async {
    try {
      if (_channel == null) {
        print('❌ WebSocket not connected');
        return false;
      }

      print('📡 Subscribing to duel channel: presence-duel.$duelId');
      
      // Get authentication token for this specific channel
      final token = await _getAuthToken();
      if (token == null) {
        print('❌ Failed to get auth token for channel subscription');
        return false;
      }
      
      final subscribeMessage = {
        'event': 'pusher:subscribe',
        'data': {
          'auth': token,
          'channel': 'presence-duel.$duelId',
        }
      };
      
      _channel?.sink.add(jsonEncode(subscribeMessage));
      
      // Emit subscription event
      _emitEvent('subscription_requested', {
        'duel_id': duelId,
        'channel': 'presence-duel.$duelId',
      });
      
      return true;
    } catch (e) {
      print('❌ Error subscribing to duel: $e');
      return false;
    }
  }

  // Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      print('📨 Received message: $message');
      
      if (message is String) {
        final data = jsonDecode(message);
        
        // Handle different message types
        if (data['event'] != null) {
          final event = data['event'] as String;
          final eventData = data['data'];
          
          switch (event) {
            case 'pusher:connection_established':
              _emitEvent('connection_established', eventData);
              break;
              
            case 'pusher:subscription_succeeded':
              _emitEvent('subscription_succeeded', eventData);
              break;
              
            case 'pusher:member_added':
              _emitEvent('member_added', eventData);
              break;
              
            case 'pusher:member_removed':
              _emitEvent('member_removed', eventData);
              break;
              
            case 'duel.matched':
              _emitEvent('duel.matched', eventData);
              break;
              
            case 'duel.started':
              _emitEvent('duel.started', eventData);
              break;
              
            case 'duel.answer_submitted':
              _emitEvent('duel.answer_submitted', eventData);
              break;
              
            case 'duel.score_updated':
              _emitEvent('duel.score_updated', eventData);
              break;
              
            case 'duel.ended':
              _emitEvent('duel.ended', eventData);
              break;
              
            default:
              _emitEvent('unknown_event', {
                'event': event,
                'data': eventData,
              });
          }
        }
      }
    } catch (e) {
      print('❌ Error handling message: $e');
    }
  }

  // Handle connection errors
  void _handleError(dynamic error) {
    print('❌ WebSocket error: $error');
    _emitEvent('error', {'error': error.toString()});
    
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  // Handle disconnection
  void _handleDisconnect() {
    print('🔌 WebSocket disconnected');
    _emitEvent('disconnected', {});
    
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }

  // Schedule reconnection
  void _scheduleReconnect() {
    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2); // Exponential backoff
    
    print('🔄 Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds} seconds');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () async {
      if (_shouldReconnect) {
        await _reconnect();
      }
    });
  }

  // Reconnect to WebSocket
  Future<void> _reconnect() async {
    print('🔄 Attempting to reconnect...');
    
    // Clean up existing connection
    _channel?.sink.close();
    _pingTimer?.cancel();
    
    // Get new token and reconnect
    final token = await _getAuthToken();
    if (token != null) {
      await _connect(token);
    }
  }

  // Start ping timer
  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_channel != null) {
        try {
          final pingMessage = {
            'event': 'pusher:ping',
            'data': {},
          };
          _channel?.sink.add(jsonEncode(pingMessage));
          print('🏓 Sent ping');
        } catch (e) {
          print('❌ Error sending ping: $e');
        }
      }
    });
  }

  // Unsubscribe from current duel
  void unsubscribeFromDuel() {
    try {
      if (_channel != null) {
        final unsubscribeMessage = {
          'event': 'pusher:unsubscribe',
          'data': {
            'channel': 'presence-duel.134', // Default channel
          }
        };
        
        _channel?.sink.add(jsonEncode(unsubscribeMessage));
        print('📡 Unsubscribed from duel channel');
      }
    } catch (e) {
      print('❌ Error unsubscribing from duel: $e');
    }
  }

  // Disconnect WebSocket
  void disconnect() {
    try {
      _shouldReconnect = false;
      _reconnectTimer?.cancel();
      _pingTimer?.cancel();
      _channel?.sink.close(status.goingAway);
      _channel = null;
      _eventController?.close();
      _eventController = null;
      print('🔌 WebSocket disconnected');
    } catch (e) {
      print('❌ Error disconnecting WebSocket: $e');
    }
  }

  // Get authentication token
  Future<String?> _getAuthToken() async {
    try {
      // Get Firebase user token
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ No authenticated user found');
        return null;
      }

      final String? idToken = await user.getIdToken();
      if (idToken == null) {
        print('❌ Failed to get Firebase ID token');
        return null;
      }

      // Get backend session token using existing DuelService
      final authResult = await DuelService.authenticateWithBackend(idToken);
      if (authResult['success'] == true) {
        final sessionToken = authResult['data']?['token'] ?? 
                           authResult['data']?['access_token'] ??
                           authResult['data']?['api_token'];
        
        if (sessionToken != null) {
          print('✅ Got session token for WebSocket auth');
          return sessionToken.toString();
        }
      }

      print('❌ Failed to get backend session token');
      return null;
    } catch (e) {
      print('❌ Error getting auth token: $e');
      return null;
    }
  }

  // Emit event to stream
  void _emitEvent(String eventType, dynamic data) {
    if (_eventController != null && !_eventController!.isClosed) {
      _eventController!.add({
        'type': eventType,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }
  }

  // Check if connected
  bool get isConnected => _channel != null;

  // Get connection state
  String get connectionState {
    if (_channel == null) return 'Disconnected';
    if (_isConnecting) return 'Connecting';
    return 'Connected';
  }
} 