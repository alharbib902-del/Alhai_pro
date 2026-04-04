import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../data/chat_datasource.dart';
import '../providers/chat_providers.dart';

// ─── Local message status model ────────────────────────────────────────────

enum _SendStatus { sending, sent, failed }

class _LocalMessage {
  final String id;
  final String text;
  _SendStatus status = _SendStatus.sending;

  _LocalMessage({
    required this.id,
    required this.text,
  });
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class ChatScreen extends ConsumerStatefulWidget {
  final String orderId;

  const ChatScreen({super.key, required this.orderId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  /// Messages sent by the driver in this session, tracked locally for status
  /// indicators (sending / sent / failed). Confirmed messages appear via
  /// Realtime stream and are shown without a local indicator.
  final List<_LocalMessage> _pendingMessages = [];

  @override
  void initState() {
    super.initState();
    GetIt.instance<ChatDatasource>().markAsRead(widget.orderId);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 120), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _controller.clear();
    HapticFeedback.lightImpact();

    final localId = const Uuid().v4();
    final msg = _LocalMessage(id: localId, text: trimmed);
    setState(() => _pendingMessages.add(msg));
    _scrollToBottom();

    await _doSend(msg);
  }

  Future<void> _retry(_LocalMessage msg) async {
    HapticFeedback.mediumImpact();
    setState(() => msg.status = _SendStatus.sending);
    await _doSend(msg);
  }

  Future<void> _doSend(_LocalMessage msg) async {
    final ds = GetIt.instance<ChatDatasource>();
    try {
      await ds.sendMessage(
        orderId: widget.orderId,
        text: msg.text,
      );
      if (mounted) {
        setState(() => msg.status = _SendStatus.sent);
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) setState(() => msg.status = _SendStatus.failed);
    }
  }

  Future<void> _refresh() async {
    // Realtime stream is always live; invalidating the provider re-fetches
    // the initial snapshot and reconnects.
    ref.invalidate(chatMessagesProvider(widget.orderId));
    await GetIt.instance<ChatDatasource>().markAsRead(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatMessagesProvider(widget.orderId));
    final theme = Theme.of(context);
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثة'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.when(
              data: (list) {
                // Ids confirmed from server — remove from pending
                final confirmedIds = list
                    .where((m) => m['sender_type'] == 'driver')
                    .map((m) => m['text'] as String?)
                    .toSet();

                // Filter pending: only keep those not yet in stream
                final stillPending = _pendingMessages
                    .where((pm) =>
                        pm.status != _SendStatus.sent ||
                        !confirmedIds.contains(pm.text))
                    .toList();

                final isEmpty = list.isEmpty && stillPending.isEmpty;

                if (isEmpty) {
                  return Center(
                    child: Text(
                      'لا توجد رسائل بعد',
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AlhaiSpacing.md),
                    // Server messages + still-pending messages
                    itemCount: list.length + stillPending.length,
                    addAutomaticKeepAlives: false,
                    itemBuilder: (context, index) {
                      if (index < list.length) {
                        final msg = list[index];
                        final msgId = msg['id']?.toString() ?? '$index';
                        final isMe = msg['sender_id'] == currentUserId;
                        final isSystem = msg['is_system'] == true;

                        if (isSystem) {
                          return Padding(
                            key: ValueKey('sys_$msgId'),
                            padding: const EdgeInsets.symmetric(
                                vertical: AlhaiSpacing.xs),
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

                        return _MessageBubble(
                          key: ValueKey(msgId),
                          text: msg['text'] as String? ?? '',
                          isMe: isMe,
                          senderType: msg['sender_type'] as String? ?? '',
                          time: DateTime.tryParse(
                                  msg['created_at'] as String? ?? '') ??
                              DateTime.now(),
                          sendStatus: _SendStatus.sent,
                          onRetry: null,
                        );
                      }

                      // Pending (local) messages
                      final pm = stillPending[index - list.length];
                      return _MessageBubble(
                        key: ValueKey('pending_${pm.id}'),
                        text: pm.text,
                        isMe: true,
                        senderType: 'driver',
                        time: DateTime.now(),
                        sendStatus: pm.status,
                        onRetry: pm.status == _SendStatus.failed
                            ? () => _retry(pm)
                            : null,
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('حدث خطأ في تحميل الرسائل'),
                    const SizedBox(height: AlhaiSpacing.sm),
                    OutlinedButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Quick messages
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md),
              itemCount: quickMessages.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(width: AlhaiSpacing.xs),
              itemBuilder: (context, index) {
                return Semantics(
                  label: 'رسالة سريعة: ${quickMessages[index]}',
                  button: true,
                  child: ActionChip(
                    label: Text(
                      quickMessages[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => _send(quickMessages[index]),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),

          // Input field
          Container(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AlhaiSpacing.md,
              AlhaiSpacing.xs,
              AlhaiSpacing.md,
              AlhaiSpacing.md,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'حقل كتابة الرسالة',
                      textField: true,
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.send,
                        onSubmitted: _send,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.md,
                            vertical: 10,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Semantics(
                    label: 'إرسال الرسالة',
                    button: true,
                    child: IconButton.filled(
                      onPressed: () => _send(_controller.text),
                      icon: const Icon(Icons.send),
                    ),
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

// ─── Message bubble ──────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String senderType;
  final DateTime time;
  final _SendStatus sendStatus;
  final VoidCallback? onRetry;

  const _MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.senderType,
    required this.time,
    required this.sendStatus,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeStr =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

    final semanticsLabel = isMe
        ? 'رسالتك: $text، $timeStr، ${_statusLabel(sendStatus)}'
        : 'رسالة: $text، $timeStr';

    return Semantics(
      label: semanticsLabel,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: sendStatus == _SendStatus.failed
                ? theme.colorScheme.errorContainer
                : isMe
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 4),
              bottomRight: Radius.circular(isMe ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: sendStatus == _SendStatus.failed
                      ? theme.colorScheme.onErrorContainer
                      : isMe
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10,
                      color: sendStatus == _SendStatus.failed
                          ? theme.colorScheme.onErrorContainer
                              .withValues(alpha: 0.7)
                          : isMe
                              ? theme.colorScheme.onPrimary
                                  .withValues(alpha: 0.7)
                              : theme.colorScheme.outline,
                    ),
                  ),
                  if (isMe) ...[
                    const SizedBox(width: 4),
                    ExcludeSemantics(
                      child: _SendStatusIcon(
                        status: sendStatus,
                        onRetry: onRetry,
                        foreground: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLabel(_SendStatus s) {
    switch (s) {
      case _SendStatus.sending:
        return 'جاري الإرسال';
      case _SendStatus.sent:
        return 'تم الإرسال';
      case _SendStatus.failed:
        return 'فشل الإرسال';
    }
  }
}

// ─── Send status icon ────────────────────────────────────────────────────────

class _SendStatusIcon extends StatelessWidget {
  final _SendStatus status;
  final VoidCallback? onRetry;
  final Color foreground;

  const _SendStatusIcon({
    required this.status,
    required this.onRetry,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _SendStatus.sending:
        return SizedBox(
          width: 10,
          height: 10,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: foreground.withValues(alpha: 0.7),
          ),
        );
      case _SendStatus.sent:
        return Icon(Icons.done,
            size: 12, color: foreground.withValues(alpha: 0.7));
      case _SendStatus.failed:
        return GestureDetector(
          onTap: onRetry,
          child: Icon(
            Icons.refresh,
            size: 14,
            color: Theme.of(context).colorScheme.onErrorContainer,
          ),
        );
    }
  }
}
