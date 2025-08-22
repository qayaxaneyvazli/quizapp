import 'package:flutter/material.dart';
import 'package:quiz_app/core/services/websocket_service.dart';

class WebSocketTestScreen extends StatefulWidget {
  const WebSocketTestScreen({super.key});

  @override
  State<WebSocketTestScreen> createState() => _WebSocketTestScreenState();
}

class _WebSocketTestScreenState extends State<WebSocketTestScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  String _connectionStatus = 'Disconnected';
  String _lastEvent = 'No events yet';
  List<String> _eventLog = [];

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
  }

  Future<void> _initializeWebSocket() async {
    setState(() {
      _connectionStatus = 'Connecting...';
    });

    try {
      final success = await _webSocketService.initialize();
      if (success) {
        setState(() {
          _connectionStatus = 'Connected';
        });

        // Listen to events
        _webSocketService.eventStream.listen((event) {
          setState(() {
            _lastEvent = '${event['type']}: ${event['timestamp']}';
            _eventLog.add('${DateTime.now().toString().substring(11, 19)} - ${event['type']}');
            if (_eventLog.length > 10) {
              _eventLog.removeAt(0);
            }
          });
        });
      } else {
        setState(() {
          _connectionStatus = 'Failed to connect';
        });
      }
    } catch (e) {
      setState(() {
        _connectionStatus = 'Error: $e';
      });
    }
  }

  Future<void> _subscribeToDuel(int duelId) async {
    try {
      setState(() {
        _eventLog.add('${DateTime.now().toString().substring(11, 19)} - Attempting to subscribe to duel $duelId');
      });
      
      final success = await _webSocketService.subscribeToDuel(duelId);
      if (success) {
        setState(() {
          _eventLog.add('${DateTime.now().toString().substring(11, 19)} - Successfully subscribed to duel $duelId');
        });
      } else {
        setState(() {
          _eventLog.add('${DateTime.now().toString().substring(11, 19)} - Failed to subscribe to duel $duelId');
        });
      }
    } catch (e) {
      setState(() {
        _eventLog.add('${DateTime.now().toString().substring(11, 19)} - Error: $e');
      });
    }
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Test'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Connection Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connection Status:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _connectionStatus,
                      style: TextStyle(
                        color: _connectionStatus == 'Connected' 
                          ? Colors.green 
                          : _connectionStatus == 'Connecting...' 
                            ? Colors.orange 
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Test Buttons
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Actions:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () => _subscribeToDuel(134),
                          child: const Text('Subscribe to Duel 134'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _subscribeToDuel(999),
                          child: const Text('Subscribe to Duel 999'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Last Event
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Event:',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(_lastEvent),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Event Log
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Event Log:',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _eventLog.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                              child: Text(
                                _eventLog[index],
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 