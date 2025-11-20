import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:quiz_app/core/services/authoritative_duel.dart';
import 'package:quiz_app/screens/messages/message_model.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/core/services/duel_service.dart';

class GlobalChatService {
  static const _wsHost = '116.203.188.209';
  static const _wsPort = 6002;
  static const _pusherKey = 'localkey'; // public channel “global”
  static const _apiBase = 'http://116.203.188.209/api';
  List<GlobalChatMessage> get snapshot =>
      List.unmodifiable(_messages); 
  WebSocketChannel? _channel;
  final _messagesCtrl = StreamController<List<GlobalChatMessage>>.broadcast();
  final _connCtrl = StreamController<String>.broadcast();
 String? _sessionToken;

  final Set<int> _seenIds = <int>{};
  int _currentPage = 0;
  int _lastPage = 1; // varsayılan
  bool get hasMore => _currentPage < _lastPage;
  bool _fetching = false;
  // in-memory list (newest last)
  final List<GlobalChatMessage> _messages = [];
  bool _subscribed = false;


  Completer<void>? _connected;

  Stream<List<GlobalChatMessage>> get messagesStream => _messagesCtrl.stream;
  Stream<String> get connectionStream => _connCtrl.stream;

  static final GlobalChatService _instance = GlobalChatService._internal();
  factory GlobalChatService() => _instance;
  GlobalChatService._internal();



  Future<void> initialize() async {
    if (_channel != null) return;
    _connected = Completer<void>();

    final wsUrl =
        'ws://$_wsHost:$_wsPort/app/$_pusherKey?protocol=7&client=js&version=7.2.0&flash=false';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

    _channel!.stream.listen(
      (raw) {
        _connCtrl.add('message');
        _handleWs(raw);
      },
      onError: (e) {
        _connCtrl.add('error:$e');
      },
      onDone: () {
        _connCtrl.add('closed');
        _channel = null;
        _subscribed = false;
      },
    );

    // pusher:subscribe (public channel “global”)
    await Future.delayed(const Duration(milliseconds: 150));
    final subscribe = {
      'event': 'pusher:subscribe',
      'data': {'channel': 'global'}
    };
    _channel!.sink.add(jsonEncode(subscribe));
  }

  Future<void> dispose() async {
    await _channel?.sink.close();
    await _messagesCtrl.close();
    await _connCtrl.close();
    _channel = null;
  }

Future<void> fetchRecent({int perPage = 30}) async {
  if (_fetching) return;
  _fetching = true;
  try {
    _currentPage = 1;
    final uri = Uri.parse('$_apiBase/global-messages?per_page=$perPage&page=$_currentPage');

    final token = await _getAuthToken();
    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final resp = await http.get(uri, headers: headers);
    print('[GlobalChat] status=${resp.statusCode}');
    print('[GlobalChat] body=${resp.body}');

    if (resp.statusCode != 200) return;

    final j = jsonDecode(resp.body);
    final items = (j is Map && j['data'] is List)
        ? (j['data'] as List)
        : (j is List ? j : const []);
    final meta = (j is Map && j['meta'] is Map) ? (j['meta'] as Map) : null;
    _lastPage = meta?['last_page'] is int ? meta!['last_page'] as int : 1;

    // ✅ Tam reset: eski dedupe set’ini sıfırla
    _seenIds.clear();

    // ✅ API’den geleni doğrudan yükle, sonra sete ekle
    final parsed = <GlobalChatMessage>[];
    for (final e in items) {
      try {
        final m = GlobalChatMessage.fromJson(Map<String, dynamic>.from(e));
        parsed.add(m);
      } catch (err) {
        print('[GlobalChat] parse_err=$err item=$e');
      }
    }
    parsed.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    _messages
      ..clear()
      ..addAll(parsed);

 
    for (final m in parsed) {
      _seenIds.add(m.id);
    }

    _messagesCtrl.add(List.unmodifiable(_messages));
    print('[GlobalChat] state_messages=${_messages.length}');
  } catch (e) {
    print('[GlobalChat] fetchRecent EX: $e');
  } finally {
    _fetching = false;
  }
}


  Future<bool> send(String text) async {
    final token = await _getAuthToken();  
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    
    final url = Uri.parse('$_apiBase/global-messages');
    final bodyAttempt1 = jsonEncode({'body': text});
    final resp1 = await http.post(url, headers: headers, body: bodyAttempt1);

    if (resp1.statusCode == 200 || resp1.statusCode == 201) {
      _tryAppendFromResponse(resp1.body);
      return true;
    }
    // fallback: {"message": "..."} (guide) :contentReference[oaicite:4]{index=4}
    final bodyAttempt2 = jsonEncode({'message': text});
    final resp2 = await http.post(url, headers: headers, body: bodyAttempt2);
    if (resp2.statusCode == 200 || resp2.statusCode == 201) {
      _tryAppendFromResponse(resp2.body);
      return true;
    }
    return false;
  }

Future<void> loadMore({int perPage = 30}) async {
    if (_fetching || !hasMore) return;
    _fetching = true;
    try {
      final nextPage = _currentPage + 1;
      final uri = Uri.parse('$_apiBase/global-messages?per_page=$perPage&page=$nextPage');

      final token = await _getAuthToken();
      final headers = {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token', // ✅
      };

      print('[GlobalChat] GET $uri');
      final resp = await http.get(uri, headers: headers);
      print('[GlobalChat] status=${resp.statusCode}');
      print('[GlobalChat] body=${resp.body}');

      if (resp.statusCode != 200) {
        print('[GlobalChat] non-200 on loadMore');
        return;
      }

      final j = jsonDecode(resp.body);
      final items = (j is Map && j['data'] is List)
          ? (j['data'] as List)
          : (j is List ? j : const []);
      final meta = (j is Map && j['meta'] is Map) ? (j['meta'] as Map) : null;
      _lastPage = meta?['last_page'] is int ? meta!['last_page'] as int : _lastPage;

      final older = <GlobalChatMessage>[];
      for (final e in items) {
        try {
          final m = GlobalChatMessage.fromJson(Map<String, dynamic>.from(e));
          if (_seenIds.add(m.id)) older.add(m);
        } catch (err) {
          print('[GlobalChat] parse_err=$err item=$e');
        }
      }
      older.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      _messages.insertAll(0, older);
      _messagesCtrl.add(List.unmodifiable(_messages));
      _currentPage = nextPage;

      print('[GlobalChat] loadMore ok; total=${_messages.length} page=$_currentPage/$_lastPage');
    } catch (e) {
      print('[GlobalChat] loadMore EX: $e');
    } finally {
      _fetching = false;
    }
  }

  void _tryAppendFromResponse(String body) {
    try {
      final j = jsonDecode(body);
      final m = GlobalChatMessage.fromJson(Map<String, dynamic>.from(j));
      _messages.add(m);
      _messagesCtrl.add(List.unmodifiable(_messages));
    } catch (_) {}
  }

  void _handleWs(dynamic raw) {
    try {
      final msg = raw is String ? jsonDecode(raw) : raw;
      final event = msg['event'];
      final dataRaw = msg['data'];

      if (event == 'pusher:subscription_succeeded') {
        _subscribed = true;
        _connCtrl.add('subscribed');
        _connected?.complete();
        return;
      }

      // GlobalMessageCreated payload (guide) :contentReference[oaicite:5]{index=5}
      if (event == 'GlobalMessageCreated') {
        final data = dataRaw is String ? jsonDecode(dataRaw) : dataRaw;
        final m = GlobalChatMessage.fromJson(Map<String, dynamic>.from(data));
        _messages.add(m);
        _messagesCtrl.add(List.unmodifiable(_messages));
        return;
      }

      // Opsiyonel: başka event’ler de test HTML’de görünebilir :contentReference[oaicite:6]{index=6}
      if (event == 'message.created' || event == 'chat.message') {
        final data = dataRaw is String ? jsonDecode(dataRaw) : dataRaw;
        final m = GlobalChatMessage.fromJson(Map<String, dynamic>.from(data));
        _messages.add(m);
        _messagesCtrl.add(List.unmodifiable(_messages));
        return;
      }
    } catch (_) {
      // yut
    }
  }

Future<String?> _getAuthToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final idToken = await user.getIdToken();
      if (idToken == null) return null;

      // cache varsa kullan
      if (_sessionToken != null) return _sessionToken;

      final authResult = await DuelService.authenticateWithBackend(idToken);
      if (authResult['success'] == true) {
        _sessionToken = authResult['data']?['token']
            ?? authResult['data']?['access_token']
            ?? authResult['data']?['api_token'];
        print('[GlobalChat] got backend token=${_sessionToken != null}');
        return _sessionToken;
      }
      return null;
    } catch (e) {
      print('[GlobalChat] _getAuthToken EX: $e');
      return null;
    }
  }
}