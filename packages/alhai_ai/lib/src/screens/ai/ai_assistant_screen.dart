/// شاشة المساعد الذكي - AI Assistant Screen
///
/// واجهة محادثة مع المساعد الذكي لإدارة المتجر
/// يدعم الأسئلة السريعة والمحادثة الحرة
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import '../../providers/ai_assistant_providers.dart';
import '../../services/ai_assistant_service.dart';
import '../../widgets/ai/chat_message_bubble.dart';
import '../../widgets/ai/ai_quick_templates.dart';
import '../../widgets/ai/ai_chat_input.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// شاشة المساعد الذكي
class AiAssistantScreen extends ConsumerStatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  ConsumerState<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends ConsumerState<AiAssistantScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(String text) {
    ref.read(chatMessagesProvider.notifier).sendMessage(text);
    _scrollToBottom();
    Future.delayed(const Duration(milliseconds: 500), _scrollToBottom);
  }

  void _handleActionTap(String action) {
    // إذا كان route، ننتقل إليه
    if (action.startsWith('/')) {
      context.push(action);
      return;
    }
    // وإلا نرسله كرسالة
    _handleSendMessage(action);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final messages = ref.watch(chatMessagesProvider);
    final isProcessing = ref.watch(isProcessingProvider);
    final templates = ref.watch(quickTemplatesProvider);

    // التمرير التلقائي عند إضافة رسالة جديدة
    ref.listen(chatMessagesProvider, (_, __) => _scrollToBottom());

    return Column(
      children: [
        AppHeader(
          title: l10n.aiAssistant,
          subtitle: l10n.aiAskAboutStore,
          onMenuTap: isWideScreen
              ? null
              : () => Scaffold.of(context).openDrawer(),
          actions: [
            // زر مسح المحادثة
            IconButton(
              onPressed: () {
                ref.read(chatMessagesProvider.notifier).clearChat();
              },
              icon: Icon(
                Icons.delete_outline_rounded,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
              tooltip: l10n.aiClearChat,
            ),
          ],
        ),
        Expanded(
          child: _buildChatArea(
            messages,
            isProcessing,
            templates,
            isDark,
            isWideScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildChatArea(
    List<ChatMessage> messages,
    bool isProcessing,
    List<QuickTemplate> templates,
    bool isDark,
    bool isWideScreen,
  ) {
    return Container(
      margin: isWideScreen
          ? EdgeInsetsDirectional.fromSTEB(
              AlhaiSpacing.lg,
              AlhaiSpacing.zero,
              AlhaiSpacing.lg,
              AlhaiSpacing.zero,
            )
          : EdgeInsets.zero,
      decoration: isWideScreen
          ? BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: Column(
        children: [
          // القوالب السريعة
          AiQuickTemplates(
            templates: templates,
            onTap: (template) => _handleSendMessage(template.query),
          ),

          // خط فاصل
          Divider(
            height: 1,
            color: isDark
                ? Colors.white.withValues(alpha: 0.06)
                : AppColors.border,
          ),

          // قائمة الرسائل
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: AlhaiSpacing.md,
                    ),
                    itemCount: messages.length + (isProcessing ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isProcessing) {
                        return _buildTypingIndicator(isDark);
                      }
                      return ChatMessageBubble(
                        message: messages[index],
                        onActionTap: _handleActionTap,
                      );
                    },
                  ),
          ),

          // حقل الإدخال
          AiChatInput(onSend: _handleSendMessage, isProcessing: isProcessing),
        ],
      ),
    );
  }

  /// الحالة الفارغة
  Widget _buildEmptyState(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.mdl),
          Text(
            l10n.aiAssistantReady,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            l10n.aiAskAboutSalesStock,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.white54 : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// مؤشر الكتابة
  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.xxs,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AlhaiSpacing.md,
              vertical: AlhaiSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0, isDark),
                const SizedBox(width: AlhaiSpacing.xxs),
                _buildDot(1, isDark),
                const SizedBox(width: AlhaiSpacing.xxs),
                _buildDot(2, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index, bool isDark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + index * 200),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.3 + value * 0.5),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}
