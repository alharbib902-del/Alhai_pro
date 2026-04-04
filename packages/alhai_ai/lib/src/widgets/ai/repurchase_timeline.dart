/// الجدول الزمني لإعادة الشراء - Repurchase Timeline
///
/// عرض مرئي لتواريخ إعادة الشراء المتوقعة
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../services/ai_customer_recommendations_service.dart';

/// الجدول الزمني لإعادة الشراء
class RepurchaseTimeline extends StatelessWidget {
  final List<RepurchaseReminder> reminders;
  final ValueChanged<RepurchaseReminder>? onReminderTap;
  final ValueChanged<RepurchaseReminder>? onSendWhatsApp;

  const RepurchaseTimeline({
    super.key,
    required this.reminders,
    this.onReminderTap,
    this.onSendWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const Icon(Icons.event_repeat_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: AlhaiSpacing.xs),
              Text(
                'تذكيرات إعادة الشراء', // Repurchase Reminders
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AlhaiSpacing.xs, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${reminders.where((r) => r.isOverdue).length} متأخر', // X overdue
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.md),

          // Timeline items
          ...reminders.asMap().entries.map((entry) {
            final index = entry.key;
            final reminder = entry.value;
            final isLast = index == reminders.length - 1;

            return _RepurchaseTimelineItem(
              reminder: reminder,
              isLast: isLast,
              isDark: isDark,
              onTap: () => onReminderTap?.call(reminder),
              onWhatsApp: () => onSendWhatsApp?.call(reminder),
            );
          }),
        ],
      ),
    );
  }
}

/// عنصر الجدول الزمني - Timeline Item
class _RepurchaseTimelineItem extends StatelessWidget {
  final RepurchaseReminder reminder;
  final bool isLast;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onWhatsApp;

  const _RepurchaseTimelineItem({
    required this.reminder,
    required this.isLast,
    required this.isDark,
    this.onTap,
    this.onWhatsApp,
  });

  String _formatDate(DateTime date) {
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = reminder.isOverdue ? AppColors.error : AppColors.success;

    return IntrinsicHeight(
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline dot and line
            SizedBox(
              width: 28,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : AppColors.grey200,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: AlhaiSpacing.sm),

            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: AlhaiSpacing.md),
                padding: const EdgeInsets.all(AlhaiSpacing.sm),
                decoration: BoxDecoration(
                  color: reminder.isOverdue
                      ? AppColors.error.withValues(alpha: 0.05)
                      : (isDark
                          ? Colors.white.withValues(alpha: 0.03)
                          : AppColors.grey50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: reminder.isOverdue
                        ? AppColors.error.withValues(alpha: 0.15)
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.05)
                            : AppColors.grey200),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reminder.customerName,
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AlhaiSpacing.xxxs),
                              Text(
                                reminder.productName,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AlhaiSpacing.xs, vertical: 3),
                          decoration: BoxDecoration(
                            color: reminder.isOverdue
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reminder.isOverdue
                                ? 'متأخر'
                                : 'قادم', // Overdue / Upcoming
                            style: TextStyle(
                              color: reminder.isOverdue
                                  ? AppColors.error
                                  : AppColors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AlhaiSpacing.xs),

                    // Details row
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text(
                          'آخر شراء: منذ ${reminder.daysSinceLastPurchase} يوم', // Last purchase: X days ago
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: AlhaiSpacing.sm),
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.4)
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text(
                          _formatDate(reminder.expectedDate),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AlhaiSpacing.xs),

                    // WhatsApp button
                    if (reminder.phone != null && onWhatsApp != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: onWhatsApp,
                          icon: const Icon(Icons.message_rounded, size: 14),
                          label: const Text(
                              'إرسال تذكير واتساب'), // Send WhatsApp Reminder
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF25D366),
                            side: const BorderSide(color: Color(0xFF25D366)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            textStyle: const TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
