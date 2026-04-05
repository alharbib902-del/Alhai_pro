/// بطاقة تنبيه الاحتيال - Fraud Alert Card
///
/// تعرض تفاصيل تنبيه الاحتيال مع مستوى الخطورة والإجراء المقترح
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_fraud_detection_service.dart';

/// بطاقة تنبيه الاحتيال
class FraudAlertCard extends StatelessWidget {
  final FraudAlert alert;
  final VoidCallback? onTap;
  final VoidCallback? onReview;
  final bool isSelected;

  const FraudAlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onReview,
    this.isSelected = false,
  });

  Color _getSeverityColor() {
    switch (alert.severity) {
      case FraudSeverity.critical:
        return const Color(0xFFDC2626);
      case FraudSeverity.high:
        return const Color(0xFFEA580C);
      case FraudSeverity.medium:
        return const Color(0xFFF59E0B);
      case FraudSeverity.low:
        return const Color(0xFF3B82F6);
    }
  }

  String _getSeverityLabel(AppLocalizations l10n) {
    switch (alert.severity) {
      case FraudSeverity.critical:
        return l10n.critical;
      case FraudSeverity.high:
        return l10n.high;
      case FraudSeverity.medium:
        return l10n.medium;
      case FraudSeverity.low:
        return l10n.low;
    }
  }

  IconData _getPatternIcon() {
    switch (alert.pattern) {
      case FraudPattern.unusualRefund:
        return Icons.assignment_return_rounded;
      case FraudPattern.afterHoursTransaction:
        return Icons.nightlight_round;
      case FraudPattern.repeatedVoid:
        return Icons.cancel_rounded;
      case FraudPattern.largeDiscount:
        return Icons.discount_rounded;
      case FraudPattern.splitTransaction:
        return Icons.call_split_rounded;
      case FraudPattern.cashDrawerAnomaly:
        return Icons.point_of_sale_rounded;
    }
  }

  String _getPatternLabel() {
    switch (alert.pattern) {
      case FraudPattern.unusualRefund:
        return 'استرجاع غير اعتيادي'; // Unusual Refund
      case FraudPattern.afterHoursTransaction:
        return 'معاملة بعد الدوام'; // After Hours
      case FraudPattern.repeatedVoid:
        return 'إلغاء متكرر'; // Repeated Void
      case FraudPattern.largeDiscount:
        return 'خصم كبير'; // Large Discount
      case FraudPattern.splitTransaction:
        return 'تقسيم معاملة'; // Split Transaction
      case FraudPattern.cashDrawerAnomaly:
        return 'شذوذ درج النقد'; // Cash Drawer Anomaly
    }
  }

  String _formatTimeAgo(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 60) {
      return 'منذ ${diff.inMinutes} دقيقة'; // X minutes ago
    }
    if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة'; // X hours ago
    return 'منذ ${diff.inDays} يوم'; // X days ago
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final severityColor = _getSeverityColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? severityColor
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.border),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? severityColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: isSelected ? 12 : 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Severity badge + Pattern + Time
              Row(
                children: [
                  // Severity indicator
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: severityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  // Pattern icon
                  Container(
                    padding: const EdgeInsets.all(AlhaiSpacing.xs),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _getPatternIcon(),
                      color: severityColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPatternLabel(),
                          style: TextStyle(
                            color:
                                isDark ? Colors.white : AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AlhaiSpacing.xxxs),
                        Text(
                          _formatTimeAgo(alert.timestamp),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.5)
                                : AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Severity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: AlhaiSpacing.xxs),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: severityColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _getSeverityLabel(l10n),
                      style: TextStyle(
                        color: severityColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AlhaiSpacing.sm),

              // Description
              Text(
                alert.description,
                style: TextStyle(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: AlhaiSpacing.sm),

              // Cashier + Amount row
              Row(
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.5)
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: AlhaiSpacing.xxs),
                  Text(
                    alert.cashierName,
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${alert.amount.toStringAsFixed(0)} ر.س', // SAR
                    style: TextStyle(
                      color: severityColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AlhaiSpacing.xs),

              // Confidence + Review button
              Row(
                children: [
                  // Confidence
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.xs, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.backgroundSecondary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'الثقة: ${(alert.confidence * 100).toInt()}%', // Confidence: X%
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (!alert.isReviewed && onReview != null)
                    TextButton.icon(
                      onPressed: onReview,
                      icon: const Icon(Icons.visibility_rounded, size: 16),
                      label: Text(l10n.review),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AlhaiSpacing.sm,
                            vertical: AlhaiSpacing.xxs),
                        textStyle: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    )
                  else if (alert.isReviewed)
                    const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 16, color: AppColors.success),
                        SizedBox(width: AlhaiSpacing.xxs),
                        Text(
                          'تمت المراجعة', // Reviewed
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
