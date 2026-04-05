/// فقاعة رسالة المحادثة - Chat Message Bubble
///
/// عرض رسالة واحدة في المحادثة مع دعم البيانات والإجراءات المقترحة
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_assistant_service.dart';

/// فقاعة رسالة المحادثة
class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSuggestedAction;
  final ValueChanged<String>? onActionTap;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onSuggestedAction,
    this.onActionTap,
  });

  bool get _isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.xxs),
      child: Row(
        mainAxisAlignment:
            _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_isUser) _buildAvatar(isDark),
          if (!_isUser) const SizedBox(width: AlhaiSpacing.xs),
          Flexible(child: _buildBubble(context, isDark, l10n)),
          if (_isUser) const SizedBox(width: AlhaiSpacing.xs),
          if (_isUser) _buildUserAvatar(isDark),
        ],
      ),
    );
  }

  /// أيقونة المساعد
  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(
        Icons.smart_toy_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }

  /// أيقونة المستخدم
  Widget _buildUserAvatar(bool isDark) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : AppColors.grey200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.person_rounded,
        color: isDark ? Colors.white70 : AppColors.grey600,
        size: 20,
      ),
    );
  }

  /// الفقاعة الرئيسية
  Widget _buildBubble(
      BuildContext context, bool isDark, AppLocalizations l10n) {
    final bgColor = _isUser
        ? AppColors.primary
        : isDark
            ? const Color(0xFF1E293B)
            : Colors.white;

    final textColor = _isUser
        ? Colors.white
        : isDark
            ? Colors.white
            : AppColors.textPrimary;

    final maxBubbleWidth = (context.screenWidth * 0.65).clamp(0.0, 600.0);

    return Container(
      constraints: BoxConstraints(
        maxWidth: maxBubbleWidth,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(_isUser ? 16 : 4),
          bottomRight: Radius.circular(_isUser ? 4 : 16),
        ),
        border: _isUser
            ? null
            : Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : AppColors.border,
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // محتوى الرسالة
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                14, AlhaiSpacing.sm, 14, AlhaiSpacing.xs),
            child: SelectableText(
              message.content,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),

          // بيانات مرفقة
          if (message.data != null && !_isUser) _buildDataSection(isDark, l10n),

          // إجراءات مقترحة
          if (message.suggestedActions != null &&
              message.suggestedActions!.isNotEmpty &&
              !_isUser)
            _buildSuggestedActions(isDark),

          // الوقت + زر النسخ
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
                14, AlhaiSpacing.zero, AlhaiSpacing.xs, AlhaiSpacing.xs),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: _isUser
                        ? Colors.white.withValues(alpha: 0.7)
                        : isDark
                            ? Colors.white38
                            : AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                if (!_isUser) ...[
                  const SizedBox(width: AlhaiSpacing.xxs),
                  InkWell(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: message.content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم النسخ'), // Copied
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(AlhaiSpacing.xxs),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// قسم البيانات المرفقة
  Widget _buildDataSection(bool isDark, AppLocalizations l10n) {
    final data = message.data!;
    if (data.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsetsDirectional.fromSTEB(
          14, AlhaiSpacing.zero, 14, AlhaiSpacing.xs),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
      ),
      child: Column(
        children: data.entries
            .where((e) => e.value is num || e.value is String)
            .take(6)
            .map((entry) {
          final label = _formatDataKey(entry.key, l10n);
          final value = entry.value is double
              ? (entry.value as double).toStringAsFixed(2)
              : entry.value.toString();
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxxs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// إجراءات مقترحة
  Widget _buildSuggestedActions(bool isDark) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          14, AlhaiSpacing.zero, 14, AlhaiSpacing.xs),
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        children: message.suggestedActions!.map((action) {
          return InkWell(
            onTap: () {
              if (action.route != null) {
                onActionTap?.call(action.route!);
              } else {
                onActionTap?.call(action.label);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AlhaiSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (action.icon != null) ...[
                    Icon(
                      action.icon,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: AlhaiSpacing.xxs),
                  ],
                  Text(
                    action.label,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// تنسيق الوقت
  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// تنسيق مفتاح البيانات
  String _formatDataKey(String key, AppLocalizations l10n) {
    final map = {
      'todayTotal': 'إجمالي اليوم',
      'todayCount': 'عدد الفواتير',
      'avgTicket': 'متوسط الفاتورة',
      'yesterdayTotal': 'مبيعات الأمس',
      'changePercent': 'نسبة التغير',
      'lowStockCount': 'مخزون منخفض',
      'outOfStockCount': 'نفد المخزون',
      'totalProducts': 'إجمالي المنتجات',
      'totalDebt': 'إجمالي الديون',
      'debtorsCount': 'عدد المدينين',
      'total': l10n.total,
      'active': l10n.active,
      'inactive': 'غير نشط',
    };
    return map[key] ?? key;
  }
}
