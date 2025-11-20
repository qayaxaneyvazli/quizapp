import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/core/services/duel_service.dart';

class GlobalChatMessage {
  final int id;
  final String body;
  final int? userId;
  final String? userName;
  final DateTime createdAt;

  GlobalChatMessage({
    required this.id,
    required this.body,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  factory GlobalChatMessage.fromJson(Map<String, dynamic> j) {
   
    String? extractedName;
 
    if (j['user_name'] != null) {
      extractedName = j['user_name'].toString();
    } 
     
    else if (j['user'] != null && j['user'] is Map) {
      extractedName = j['user']['name']?.toString() ?? j['user']['username']?.toString();
    }
    
    return GlobalChatMessage(
      id: j['id'] is int ? j['id'] : int.tryParse('${j['id']}') ?? 0,
      body: (j['body'] ?? j['message'] ?? '').toString(),
      userId: j['user_id'] is int ? j['user_id'] : int.tryParse('${j['user_id']}'),
       
      userName: extractedName, 
      
      createdAt: DateTime.tryParse(j['created_at']?.toString() ?? '') ?? DateTime.now().toUtc(),
    );
  }
}