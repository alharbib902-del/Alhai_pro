/// لوحة سجل الاستعلامات
///
/// تعرض قائمة الاستعلامات السابقة مع إمكانية إعادة التنفيذ والمسح
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../services/ai_chat_with_data_service.dart';

/// لوحة سجل الاستعلامات
class QueryHistoryPanel extends StatelessWidget {
  final List<QueryResult> history;
  final ValueChanged<String> onRerun;
  final VoidCallback? onClearAll;
  final VoidCallback? onClose;

  const QueryHistoryPanel({
    super.key,
    required this.history,
    required this.onRerun,
    this.onClearAll,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              AlhaiSpacing.md,
              AlhaiSpacing.md,
              AlhaiSpacing.md,
              AlhaiSpacing.xs,
            ),
            child: Row(
              children: [
                const Icon(Icons.history, color: AppColors.primary, size: 20),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  'سجل الاستعلامات',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (history.isNotEmpty && onClearAll != null)
                  TextButton.icon(
                    onPressed: onClearAll,
                    icon: const Icon(
                      Icons.delete_sweep,
                      color: AppColors.error,
                      size: 16,
                    ),
                    label: const Text(
                      'مسح الكل',
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                if (onClose != null)
                  IconButton(
                    onPressed: onClose,
                    icon: Icon(Icons.close, color: subtextColor, size: 18),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),

          // القائمة
          if (history.isEmpty)
            Padding(
              padding: const EdgeInsets.all(AlhaiSpacing.xl),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: isDark ? Colors.white24 : AppColors.grey300,
                      size: 40,
                    ),
                    const SizedBox(height: AlhaiSpacing.sm),
                    Text(
                      'لا يوجد استعلامات سابقة',
                      style: TextStyle(color: subtextColor, fontSize: 14),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      'اسأل سؤالاً عن بياناتك للبدء',
                      style: TextStyle(
                        color: isDark ? Colors.white38 : AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AlhaiSpacing.xxs),
                itemCount: history.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : AppColors.grey100,
                ),
                itemBuilder: (context, index) {
                  final item = history[index];
                  return _buildHistoryItem(
                    context,
                    item,
                    isDark,
                    textColor,
                    subtextColor,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    QueryResult item,
    bool isDark,
    Color textColor,
    Color subtextColor,
  ) {
    final typeIcon = _getTypeIcon(item.resultType);
    final typeColor = _getTypeColor(item.resultType);
    final timeAgo = _formatTimeAgo(item.query.timestamp);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onRerun(item.query.query),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md,
            vertical: AlhaiSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة النوع
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(typeIcon, color: typeColor, size: 16),
              ),
              const SizedBox(width: AlhaiSpacing.sm),

              // التفاصيل
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.query.query,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Row(
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(color: subtextColor, fontSize: 11),
                        ),
                        Text(
                          '  |  ',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : AppColors.grey300,
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: isDark
                                ? Colors.white38
                                : AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // زر إعادة التنفيذ
              IconButton(
                onPressed: () => onRerun(item.query.query),
                icon: const Icon(
                  Icons.replay,
                  color: AppColors.primary,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: 'إعادة تنفيذ',
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(QueryResultType type) {
    switch (type) {
      case QueryResultType.number:
        return Icons.pin;
      case QueryResultType.table:
        return Icons.table_chart;
      case QueryResultType.barChart:
        return Icons.bar_chart;
      case QueryResultType.lineChart:
        return Icons.show_chart;
      case QueryResultType.pieChart:
        return Icons.pie_chart;
    }
  }

  Color _getTypeColor(QueryResultType type) {
    switch (type) {
      case QueryResultType.number:
        return const Color(0xFF10B981);
      case QueryResultType.table:
        return const Color(0xFF3B82F6);
      case QueryResultType.barChart:
        return const Color(0xFF8B5CF6);
      case QueryResultType.lineChart:
        return const Color(0xFFF59E0B);
      case QueryResultType.pieChart:
        return const Color(0xFFEC4899);
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'الآن';
    if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
