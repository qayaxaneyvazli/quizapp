import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
    String? _socketId;        
  String? _sessionToken;     
  Completer<void>? _connectedCompleter;   
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
    if (_eventController == null || _eventController!.isClosed) {
      print('🔄 WebSocket: Creating new event stream controller');
      _eventController = StreamController<Map<String, dynamic>>.broadcast();
    }
    return _eventController!.stream;
  }

 
  Future<bool> initialize() async {
    try {
        if (_connectedCompleter != null && _connectedCompleter!.isCompleted) {
      return true;
    }
    _connectedCompleter = Completer<void>(); // EKLE

      print('🔌 Initializing WebSocket connection...');
      
      // Get authentication token
      final token = await _getAuthToken();
      _sessionToken=token;
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
  Future<void> waitConnected({Duration timeout = const Duration(seconds: 5)}) async {
     
    if (_connectedCompleter == null) {
      _connectedCompleter = Completer<void>();
    }
    await _connectedCompleter!.future.timeout(timeout, onTimeout: () {
      throw TimeoutException('WS connection_established timed out');
    });
  }
  // Connect to WebSocket
  Future<bool> _connect(String token) async {
    if (_isConnecting) {
      print('⚠️ WebSocket connection already in progress, skipping...');
      return false;
    }
    
    _isConnecting = true;
    print('🔄 WebSocket: Starting connection process...');
    
    try {
      // Create WebSocket connection with authentication
      final wsUrl = 'ws://$_wsHost:$_wsPort/app/$_pusherKey?protocol=7&client=js&version=7.2.0&flash=false';
      
      print('🔌 WebSocket: Connecting to: $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      print('🔌 WebSocket: Channel created, setting up listeners...');
      
      // Listen to incoming messages
      _channel!.stream.listen(
        (message) {
          print('📨 WebSocket: Raw message received from server');
          _handleMessage(message);
        },
        onError: (error) {
          print('❌ WebSocket: Stream error: $error');
          _handleError(error);
        },
        onDone: () {
          print('🔌 WebSocket: Stream done (connection closed)');
          _handleDisconnect();
        },
      );

      print('🔌 WebSocket: Stream listeners set up, sending auth message...');
      // Send authentication message
      await _sendAuthMessage(token);
      
      // Start ping timer to keep connection alive
      _startPingTimer();
      
      _isConnecting = false;
      _reconnectAttempts = 0;
      
      print('✅ WebSocket: Connection established successfully');
      return true;
    } catch (e) {
      _isConnecting = false;
      print('❌ WebSocket: Error connecting: $e');
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
  final channelName = 'presence-duel.$duelId';
  print('WS subscribe begin; token=$_sessionToken socketId=$_socketId');

  if (_channel == null) {
    print('❌ WS: channel null');
    return false;
  }

  // socket_id bekle (connection_established sonrası set ediliyor)
  for (var i = 0; i < 50 && _socketId == null; i++) {
    await Future.delayed(const Duration(milliseconds: 100));
  }



   if (_connectedCompleter == null || !_connectedCompleter!.isCompleted) {
      try {
        await waitConnected();
      } catch (_) {
        print('❌ WS: socket_id yok; subscribe edemem');
        return false;
      }
    }
    if (_socketId == null) {
      print('❌ WS: socket_id null; subscribe edemem');
      return false;
    }
    if (_sessionToken == null) {
      _sessionToken = await _getAuthToken();
      if (_sessionToken == null) {
        print('❌ WS: session token null; subscribe edemem');
        return false;
      }
    }

  // 🔴 ÖNEMLİ: Laravel broadcasting/auth çoğu kurulumda form-encoded bekler
  final authRes = await http.post(
    Uri.parse(_authUrl),
    headers: {
      'Authorization': 'Bearer $_sessionToken',
      'Accept': 'application/json',
      // Content-Type BIRAK: http lib kendisi x-www-form-urlencoded ayarlayacak
    },
    body: {
      'channel_name': channelName,
      'socket_id': _socketId!,
    },
  );

  print('AUTH status=${authRes.statusCode} body=${authRes.body}');
  if (authRes.statusCode != 200) {
    _emitEvent('subscription_error', {'status': authRes.statusCode, 'body': authRes.body});
    return false;
  }

  final authPayload = jsonDecode(authRes.body);
  final subscribeMessage = {
    'event': 'pusher:subscribe',
    'data': {
      'channel': channelName,
      'auth': authPayload['auth'],
      if (authPayload['channel_data'] != null) 'channel_data': authPayload['channel_data'],
    }
  };

  _channel!.sink.add(jsonEncode(subscribeMessage));
  print('📡 WS: subscribe sent -> $channelName');
  _emitEvent('subscription_requested', {'channel': channelName});
  return true;
}


  // Handle incoming messages
  void _handleMessage(dynamic message) {
    try {
      print('📨 Received WebSocket message: $message');
      
      if (message is String) {
        final data = jsonDecode(message);
        
        // Handle different message types
        if (data['event'] != null) {
          final event = data['event'] as String;
          final eventData = data['data'];


              if (event == 'pusher:connection_established') {
      final payload = jsonDecode(data['data']); // data string -> json
      _socketId = payload['socket_id'];        // KRİTİK
      print('✅ WS socket_id=$_socketId');     // LOG ekle
      if (_connectedCompleter != null && !_connectedCompleter!.isCompleted) {
        _connectedCompleter!.complete();       // EKLE
      }
      _emitEvent('connection_established', payload);
      return;
    }
          print('🔍 Processing WebSocket event: $event');
          print('📊 Event data: $eventData');
          
          switch (event) {
            case 'pusher:connection_established':
              print('✅ WebSocket connection established');
              _emitEvent('connection_established', eventData);
              break;
              
            case 'pusher:subscription_succeeded':
            case 'pusher_internal:subscription_succeeded':
              print('📡 WebSocket subscription succeeded');
              _emitEvent('subscription_succeeded', eventData);
              break;
              
            case 'pusher:member_added':
              print('👤 WebSocket member added: $eventData');
              _emitEvent('member_added', eventData);
              break;
              
            case 'pusher:member_removed':
              print('👤 WebSocket member removed: $eventData');
              _emitEvent('member_removed', eventData);
              break;
              
            case 'pusher:pong':
              // This is a heartbeat response from the server, no need to emit
              print('🏓 WebSocket pong received (heartbeat)');
              break;
              
            case 'pusher:error':
              print('❌ Pusher error: $eventData');
              _emitEvent('pusher_error', eventData);
              break;
              
            case 'pusher:subscription_error':
              print('❌ Pusher subscription error: $eventData');
              _emitEvent('subscription_error', eventData);
              break;
              
            case 'DuelMatched':
              print('🎯 Duel matched event: $eventData');
              _emitEvent('DuelMatched', eventData);
              break;
              
            case 'DuelStarted':
              print('🚀 Duel started event: $eventData');
              _emitEvent('DuelStarted', eventData);
              break;
              
            case 'duel.ready':
              print('🎯 Duel ready event: $eventData');
              _emitEvent('duel.ready', eventData);
              break;
              
            case 'duel.answer_submitted':
              print('📝 Duel answer submitted: $eventData');
              _emitEvent('duel.answer_submitted', eventData);
              break;
              
            case 'duel.score_updated':
              print('📊 Duel score updated: $eventData');
              _emitEvent('duel.score_updated', eventData);
              break;
              
            case 'duel.ended':
              print('🏁 Duel ended: $eventData');
              _emitEvent('duel.ended', eventData);
              break;
              
            default:
              // Only log unknown events that are not Pusher internal events
              if (!event.startsWith('pusher:')) {
                print('❓ Unknown WebSocket event: $event with data: $eventData');
                _emitEvent('unknown_event', {
                  'event': event,
                  'data': eventData,
                });
              } else {
                print('🔧 Pusher internal event: $event (not emitting)');
              }
          }
        } else {
          print('⚠️ WebSocket message without event field: $data');
        }
      } else {
        print('⚠️ WebSocket message is not a string: ${message.runtimeType}');
      }
    } catch (e) {
      print('❌ Error handling WebSocket message: $e');
      print('❌ Raw message was: $message');
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
            'channel': 'public-duel.134', // Default channel
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
      print('🔌 WebSocket: Starting disconnect process...');
      _shouldReconnect = false;
      _reconnectTimer?.cancel();
      _pingTimer?.cancel();
      _channel?.sink.close(status.goingAway);
      _channel = null;
      
      // Only close the event controller if it exists and isn't already closed
      if (_eventController != null && !_eventController!.isClosed) {
        print('🔌 WebSocket: Closing event stream controller');
        _eventController!.close();
      }
      _eventController = null;
      print('🔌 WebSocket disconnected successfully');
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
    print('📤 Emitting WebSocket event: $eventType');
    print('📤 Event payload: $data');
    
    // Ensure we have a valid stream controller
    if (_eventController == null || _eventController!.isClosed) {
      print('🔄 WebSocket: Stream controller is null or closed, creating new one');
      _eventController = StreamController<Map<String, dynamic>>.broadcast();
    }
    
    try {
      final eventPayload = {
        'type': eventType,
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _eventController!.add(eventPayload);
      print('✅ Event emitted successfully to stream');
    } catch (e) {
      print('❌ Error emitting event: $e');
      // If there's an error, try to recreate the controller
      try {
        _eventController?.close();
        _eventController = StreamController<Map<String, dynamic>>.broadcast();
        print('🔄 WebSocket: Recreated stream controller after error');
      } catch (recreateError) {
        print('❌ Failed to recreate stream controller: $recreateError');
      }
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
  
  // Check if stream controller is valid
  bool get isStreamControllerValid => 
    _eventController != null && !_eventController!.isClosed;
  
  // Get stream controller status
  String get streamControllerStatus {
    if (_eventController == null) return 'Null';
    if (_eventController!.isClosed) return 'Closed';
    return 'Active';
  }
  
  // Send duel ready signal
  Future<bool> sendDuelReady(int duelId) async {
    try {
      if (_channel == null) {
        print('❌ WebSocket not connected');
        return false;
      }

      final readyMessage = {
        'event': 'duel.ready',
        'data': {
          'duel_id': duelId,
          'timestamp': DateTime.now().toIso8601String(),
        }
      };
      
      print('📤 Sending duel ready message: ${jsonEncode(readyMessage)}');
      _channel?.sink.add(jsonEncode(readyMessage));
      print('✅ Sent duel ready signal for duel $duelId');
      return true;
    } catch (e) {
      print('❌ Error sending duel ready: $e');
      return false;
    }
  }

  // Send game start signal
  Future<bool> sendGameStart(int duelId) async {
    try {
      if (_channel == null) {
        print('❌ WebSocket not connected');
        return false;
      }

      final startMessage = {
        'event': 'duel.start',
        'data': {
          'duel_id': duelId,
          'timestamp': DateTime.now().toIso8601String(),
        }
      };
      
      print('📤 Sending game start message: ${jsonEncode(startMessage)}');
      _channel?.sink.add(jsonEncode(startMessage));
      print('✅ Sent game start signal for duel $duelId');
      return true;
    } catch (e) {
      print('❌ Error sending game start: $e');
      return false;
    }
  }
} 