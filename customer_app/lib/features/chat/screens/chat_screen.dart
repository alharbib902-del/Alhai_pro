import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/chat_datasource.dart';
import '../providers/chat_providers.dart';

class CustomerChatScreen extends ConsumerStatefulWidget {
  final String orderId;

  const CustomerChatScreen({super.key, required this.orderId});

  @override
  ConsumerState<CustomerChatScreen> createState() =>
      _CustomerChatScreenState();
}

class _CustomerChatScreenState extends ConsumerState<CustomerChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    GetIt.instance<CustomerChatDatasource>().markAsRead(widget.orderId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();

    final ds = GetIt.instance<CustomerChatDatasource>();
    await ds.sendMessage(orderId: widget.orderId, text: text);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages =
        ref.watch(customerChatMessagesProvider(widget.orderId));
    final theme = Theme.of(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثة مع السائق'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.when(
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد رسائل بعد\nيمكنك التواصل مع السائق هنا',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final msg = list[index];
                    final isMe = msg['sender_id'] == currentUserId;
                    final isSystem = msg['is_system'] == true;

                    if (isSystem) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xs),
                        child: Center(
                          child: Text(
                            msg['text'] as String? ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      );
                    }

                    return _Bubble(
                      text: msg['text'] as String? ?? '',
                      isMe: isMe,
                      time: DateTime.tryParse(
                              msg['created_at'] as String? ?? '') ??
                          DateTime.now(),
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطأ: $e')),
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(AlhaiSpacing.md, AlhaiSpacing.xs, AlhaiSpacing.md, AlhaiSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.md,
                          vertical: AlhaiSpacing.xs,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  IconButton.filled(
                    onPressed: _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final DateTime time;

  const _Bubble({
    required this.text,
    required this.isMe,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
        padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xs),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 4 : 16),
            bottomRight: Radius.circular(isMe ? 16 : 4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isMe
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxs),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isMe
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
