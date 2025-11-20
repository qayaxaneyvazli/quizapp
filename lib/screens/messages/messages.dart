// lib/screens/messages/messages_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quiz_app/core/constants/app_colors.dart';
import 'package:quiz_app/core/services/global_chat_service.dart';
import 'package:quiz_app/providers/theme_mode_provider.dart';
import 'package:quiz_app/screens/messages/message_model.dart';

class MessagesScreen extends ConsumerStatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);
  @override
  ConsumerState<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends ConsumerState<MessagesScreen>
    with SingleTickerProviderStateMixin {
  final _svc = GlobalChatService(); // ✅ singleton
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late TabController _tabs;

  bool _loading = true;        // ✅ ilk yükleme
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _boot();                    // ✅ sadece 1 kez
    _scrollCtrl.addListener(_onScrollTopLoadMore);
  }

  Future<void> _boot() async {
    try {
      await _svc.initialize();             // no-op ise hızlı döner
      await _svc.fetchRecent(perPage: 50); // eski mesajları API'den çek
    } catch (_) {
      // yut
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    // _svc.dispose() YOK! (singleton)
    _tabs.dispose();
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScrollTopLoadMore() async {
    if (_loadingMore || !_svc.hasMore) return;
    if (_scrollCtrl.hasClients && _scrollCtrl.position.pixels <= 80) {
      _loadingMore = true;
      final prevMax = _scrollCtrl.position.maxScrollExtent;
      await _svc.loadMore(perPage: 50);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollCtrl.hasClients) return;
        final newMax = _scrollCtrl.position.maxScrollExtent;
        _scrollCtrl.jumpTo(_scrollCtrl.position.pixels + (newMax - prevMax));
        _loadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    ref.watch(themeModeProvider); // dark/light reactivity

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.primary,
            child: TabBar(
              controller: _tabs,
              indicatorColor: Colors.yellow,
              indicatorWeight: 3,
              labelColor: theme.colorScheme.onPrimary,
              unselectedLabelColor:
                  theme.colorScheme.onPrimary.withOpacity(0.7),
              tabs: const [Tab(text: 'Chat'), Tab(text: 'System')],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _buildChatTabWithInput(),
                _buildSystemTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTabWithInput() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _svc.fetchRecent(perPage: 50), // reset
            child: _buildChatList(),
          ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChatList() {
    return StreamBuilder<List<GlobalChatMessage>>(
      stream: _svc.messagesStream,
      initialData: _svc.snapshot, // ✅ cache’i anında bas
      builder: (context, snap) {
        final list = snap.data ?? const <GlobalChatMessage>[];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollCtrl.hasClients) {
            _scrollCtrl.animateTo(
              _scrollCtrl.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });

        if (list.isEmpty) {
          // Artık buraya düşmemeli; düşerse fetchRecent başarısızdır.
          return ListView(
            controller: _scrollCtrl,
            children: const [
              SizedBox(height: 200),
              Center(child: Text('No messages')),
            ],
          );
        }

        return ListView.builder(
          controller: _scrollCtrl,
          padding: const EdgeInsets.all(12),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final m = list[i];
            final time = DateFormat('HH:mm').format(m.createdAt.toLocal());
            return _bubble(
              name: m.userName ?? 'User',
              message: m.body,
              time: time,
              isMine: false,
            );
          },
        );
      },
    );
  }

  Widget _bubble({
    required String name,
    required String message,
    required String time,
    required bool isMine,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (!isMine) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: theme.dividerColor, width: 1.6),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(radius: 18, child: Text('👤')),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface)),
                          Text(time,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.6))),
                        ]),
                    const SizedBox(height: 6),
                    Text(message,
                        style: TextStyle(
                            color: theme.colorScheme.onSurface, fontSize: 15)),
                  ]),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF304D00) : const Color(0xBBD9FF99),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isDark ? Colors.green[800]! : Colors.green[200]!, width: .7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(name,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface)),
                  Text(time,
                      style: TextStyle(
                          fontSize: 12,
                          color:
                              theme.colorScheme.onSurface.withOpacity(0.7))),
                ]),
                const SizedBox(height: 6),
                Text(message,
                    style: TextStyle(
                        color: theme.colorScheme.onSurface, fontSize: 15)),
              ])),
          const SizedBox(width: 10),
          const CircleAvatar(radius: 18, child: Text('😎')),
        ],
      ),
    );
  }

  Widget _buildSystemTab() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    Widget item(String title, IconData icon, Color iconColor) => Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500)),
            CircleAvatar(
                radius: 18, backgroundColor: iconColor, child: Icon(icon, color: Colors.white)),
          ]),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        item('System update', Icons.system_update, Colors.orange),
        item('Maintenance window', Icons.settings, Colors.blue),
        item('New feature', Icons.new_releases, Colors.purple),
      ],
    );
  }

  Widget _buildMessageInput() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.6)),
                ),
                style: TextStyle(color: theme.colorScheme.onSurface),
                onSubmitted: (_) => _send(),
              ),
            ),
            InkWell(
              onTap: _send,
              borderRadius: BorderRadius.circular(20),
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.send, color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    FocusScope.of(context).unfocus();

    final ok = await _svc.send(text);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mesaj gönderilemedi')),
      );
    }
  }
}
