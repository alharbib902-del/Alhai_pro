/// بطاقة توقع الهدر - Waste Prediction Card
///
/// بطاقة منتج مع عد تنازلي لانتهاء الصلاحية ونسبة الهدر والإجراء المقترح
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_smart_inventory_service.dart';

/// بطاقة توقع الهدر
class WastePredictionCard extends StatelessWidget {
  final WastePrediction prediction;
  final VoidCallback? onActionTap;

  const WastePredictionCard({
    super.key,
    required this.prediction,
    this.onActionTap,
  });

  Color _getUrgencyColor() {
    if (prediction.daysToExpiry <= 1) return AppColors.error;
    if (prediction.daysToExpiry <= 3) return const Color(0xFFEA580C);
    if (prediction.daysToExpiry <= 7) return AppColors.warning;
    return AppColors.success;
  }

  IconData _getActionIcon() {
    switch (prediction.suggestedAction) {
      case WasteSuggestedAction.discount:
        return Icons.discount_rounded;
      case WasteSuggestedAction.transfer:
        return Icons.swap_horiz_rounded;
      case WasteSuggestedAction.donate:
        return Icons.volunteer_activism_rounded;
      case WasteSuggestedAction.none:
        return Icons.check_circle_outline_rounded;
    }
  }

  String _getActionLabel(AppLocalizations l10n) {
    switch (prediction.suggestedAction) {
      case WasteSuggestedAction.discount:
        return 'تخفيض السعر'; // Discount
      case WasteSuggestedAction.transfer:
        return 'نقل لفرع آخر'; // Transfer
      case WasteSuggestedAction.donate:
        return l10n.donate;
      case WasteSuggestedAction.none:
        return 'لا إجراء'; // No action
    }
  }

  Color _getActionColor() {
    switch (prediction.suggestedAction) {
      case WasteSuggestedAction.discount:
        return AppColors.warning;
      case WasteSuggestedAction.transfer:
        return AppColors.info;
      case WasteSuggestedAction.donate:
        return AppColors.primary;
      case WasteSuggestedAction.none:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final urgencyColor = _getUrgencyColor();
    final actionColor = _getActionColor();

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: prediction.daysToExpiry <= 3
              ? urgencyColor.withValues(alpha: 0.3)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: prediction.daysToExpiry <= 3
                ? urgencyColor.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Product name + Expiry countdown
          Row(
            children: [
              // Expiry countdown
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${prediction.daysToExpiry}',
                      style: TextStyle(
                        color: urgencyColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      prediction.daysToExpiry == 1 ? l10n.day : l10n.days,
                      style: TextStyle(
                        color: urgencyColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AlhaiSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                    Text(
                      'المخزون: ${prediction.currentStock} وحدة', // Stock: X units
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.5)
                            : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'معدل البيع: ${prediction.sellRate.toStringAsFixed(1)} وحدة/يوم', // Sell rate: X units/day
                      style: TextStyle(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.4)
                            : AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Waste prediction bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الهدر المتوقع', // Predicted Waste
                    style: TextStyle(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.6)
                          : AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${prediction.predictedWaste.toStringAsFixed(0)}% (${prediction.predictedWasteUnits} وحدة)', // X% (X units)
                    style: TextStyle(
                      color: urgencyColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: prediction.predictedWaste / 100,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : AppColors.grey200,
                  valueColor: AlwaysStoppedAnimation<Color>(urgencyColor),
                  minHeight: 8,
                ),
              ),
            ],
          ),

          const SizedBox(height: AlhaiSpacing.sm),

          // Estimated loss
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.money_off_rounded,
                    color: AppColors.error, size: 18),
                const SizedBox(width: AlhaiSpacing.xs),
                Text(
                  'الخسارة المتوقعة: ', // Estimated Loss:
                  style: TextStyle(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.6)
                        : AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${prediction.estimatedLoss.toStringAsFixed(0)} ر.س', // SAR
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AlhaiSpacing.sm),

          // Suggested action button
          if (prediction.suggestedAction != WasteSuggestedAction.none)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onActionTap,
                icon: Icon(_getActionIcon(), size: 18),
                label: Text(
                  _getActionLabel(l10n),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            )
          else
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
                SizedBox(width: 6),
                Text(
                  'لا إجراء مطلوب حالياً', // No action needed
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
    );
  }
}
