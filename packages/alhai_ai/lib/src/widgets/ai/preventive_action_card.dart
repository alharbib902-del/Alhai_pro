/// بطاقة الإجراء الوقائي
///
/// تعرض إجراء وقائي مقترح لتقليل المرتجعات مع وصف وتوفير متوقع
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_return_prediction_service.dart';

/// بطاقة الإجراء الوقائي
class PreventiveActionCard extends StatelessWidget {
  final PreventiveAction action;
  final VoidCallback? onApply;
  final VoidCallback? onDismiss;

  const PreventiveActionCard({
    super.key,
    required this.action,
    this.onApply,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;
    final typeColor = _getTypeColor(action.type);
    final typeIcon = _getTypeIcon(action.type);

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الصف العلوي: أيقونة النوع + العنوان
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    colors: [
                      typeColor,
                      typeColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: typeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(typeIcon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.xs,
                          vertical: AlhaiSpacing.xxxs),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AiReturnPredictionService.getPreventiveTypeLabel(
                            action.type),
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.sm),

          // الوصف
          Text(
            action.description,
            style: TextStyle(
              color: subtextColor,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          // التوفير المتوقع
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xs),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.successSurface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.savings_outlined,
                  color: AppColors.success,
                  size: 18,
                ),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  'التوفير المتوقع:',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.xxs),
                Text(
                  '${action.estimatedSavings.toStringAsFixed(2)} ر.س',
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close, size: 16),
                  label: Text(l10n.cancel),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: subtextColor,
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.15)
                          : AppColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('تطبيق الإجراء'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: typeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(PreventiveType type) {
    switch (type) {
      case PreventiveType.qualityCheck:
        return const Color(0xFF3B82F6);
      case PreventiveType.followUp:
        return const Color(0xFF8B5CF6);
      case PreventiveType.extendedWarranty:
        return const Color(0xFF10B981);
      case PreventiveType.exchangeOffer:
        return const Color(0xFFF59E0B);
      case PreventiveType.discountOnNext:
        return const Color(0xFFEC4899);
    }
  }

  IconData _getTypeIcon(PreventiveType type) {
    switch (type) {
      case PreventiveType.qualityCheck:
        return Icons.verified_outlined;
      case PreventiveType.followUp:
        return Icons.phone_callback_outlined;
      case PreventiveType.extendedWarranty:
        return Icons.shield_outlined;
      case PreventiveType.exchangeOffer:
        return Icons.swap_horiz;
      case PreventiveType.discountOnNext:
        return Icons.loyalty_outlined;
    }
  }
}
