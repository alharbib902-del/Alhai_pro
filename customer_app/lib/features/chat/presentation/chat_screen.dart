import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/chat_providers.dart';
import 'widgets/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String orderId;

  const ChatScreen({super.key, required this.orderId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  int _lastMessageCount = 0;
  bool _canSend = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(sendMessageControllerProvider.notifier)
            .markAsRead(widget.orderId);
      }
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _canSend) {
      setState(() => _canSend = hasText);
    }
  }

  void _autoScrollIfNeeded(int newCount) {
    if (newCount > _lastMessageCount && _scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
    _lastMessageCount = newCount;
  }

  Future<void> _send() async {
    final text = _textController.text;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref
        .read(sendMessageControllerProvider.notifier)
        .send(orderId: widget.orderId, text: text);
    if (!mounted) return;
    if (ok) {
      _textController.clear();
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('تعذّر إرسال الرسالة، حاول مرة أخرى')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messagesAsync = ref.watch(messageStreamProvider(widget.orderId));
    final sendState = ref.watch(sendMessageControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'رجوع',
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messagesAsync.when(
                loading: () => const _LoadingList(),
                error: (err, _) => Center(
                  child: AlhaiEmptyState.error(
                    title: 'تعذّر تحميل المحادثة',
                    description: 'تحقق من اتصالك بالإنترنت ثم حاول مرة أخرى',
                    actionText: 'إعادة المحاولة',
                    onAction: () => ref
                        .invalidate(messageStreamProvider(widget.orderId)),
                  ),
                ),
                data: (messages) {
                  if (messages.isEmpty) {
                    return Center(
                      child: AlhaiEmptyState.noData(
                        title: 'ابدأ محادثتك',
                        description:
                            'أرسل أول رسالة للتواصل بشأن طلبك',
                      ),
                    );
                  }
                  _autoScrollIfNeeded(messages.length);
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      vertical: AlhaiSpacing.sm,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[messages.length - 1 - index];
                      return MessageBubble(message: msg);
                    },
                  );
                },
              ),
            ),
            _Composer(
              controller: _textController,
              canSend: _canSend,
              sending: sendState.sending,
              onSend: _send,
              dividerColor: theme.dividerColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return AlhaiShimmer(
      child: ListView.builder(
        padding: const EdgeInsets.all(AlhaiSpacing.md),
        itemCount: 6,
        itemBuilder: (_, index) {
          final isMine = index.isEven;
          return Align(
            alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
              child: AlhaiSkeleton(
                width: 180 + (index * 12).toDouble(),
                height: 44,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final bool canSend;
  final bool sending;
  final VoidCallback onSend;
  final Color dividerColor;

  const _Composer({
    required this.controller,
    required this.canSend,
    required this.sending,
    required this.onSend,
    required this.dividerColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = canSend && !sending;
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: dividerColor)),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.sm,
        vertical: AlhaiSpacing.xs,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              textInputAction: TextInputAction.newline,
              textDirection: TextDirection.rtl,
              enabled: !sending,
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك...',
                hintTextDirection: TextDirection.rtl,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: dividerColor),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.md,
                  vertical: AlhaiSpacing.sm,
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Material(
            color: enabled
                ? AlhaiColors.primary
                : theme.colorScheme.surfaceContainerHighest,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: enabled ? onSend : null,
              child: SizedBox(
                width: 48,
                height: 48,
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AlhaiColors.onPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.send,
                        color: enabled
                            ? AlhaiColors.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
