/// بطاقة العرض الترويجي المولّد
///
/// تعرض تفاصيل عرض ترويجي مولّد بالذكاء الاصطناعي
/// مع شارة النوع والمنتجات والعائد المتوقع
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../services/ai_promotion_designer_service.dart';

/// بطاقة العرض الترويجي
class GeneratedPromotionCard extends StatelessWidget {
  final GeneratedPromotion promotion;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  const GeneratedPromotionCard({
    super.key,
    required this.promotion,
    this.isSelected = false,
    this.onTap,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final typeColor = Color(
        AiPromotionDesignerService.getPromotionTypeColorValue(promotion.type));
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.white70 : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(AlhaiSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? typeColor
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AppColors.border),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: typeColor.withValues(alpha: 0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الصف العلوي: شارة النوع + الثقة
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(promotion.type),
                          color: typeColor,
                          size: 14,
                        ),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text(
                          AiPromotionDesignerService.getPromotionTypeLabel(
                              promotion.type),
                          style: TextStyle(
                            color: typeColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // شارة الثقة
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.xs,
                        vertical: AlhaiSpacing.xxs),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppColors.grey50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: AppColors.warning,
                          size: 12,
                        ),
                        const SizedBox(width: AlhaiSpacing.xxs),
                        Text(
                          '${(promotion.confidence * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: subtextColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AlhaiSpacing.sm),

              // العنوان
              Text(
                promotion.title,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 6),

              // الوصف
              Text(
                promotion.description,
                style: TextStyle(
                  color: subtextColor,
                  fontSize: 12,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: AlhaiSpacing.sm),

              // المنتجات
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: promotion.products.take(3).map((product) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AlhaiSpacing.xs, vertical: 3),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppColors.grey100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product,
                      style: TextStyle(
                        color: subtextColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 14),

              // الخصم + ROI
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.04)
                      : AppColors.grey50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    if (promotion.discountAmount > 0) ...[
                      _buildMetric(
                        l10n.discount,
                        '${promotion.discountAmount.toStringAsFixed(0)}%',
                        typeColor,
                        subtextColor,
                      ),
                      _buildDivider(isDark),
                    ],
                    _buildMetric(
                      'الإيراد المتوقع',
                      '${(promotion.projectedRevenue / 1000).toStringAsFixed(1)}K',
                      AppColors.success,
                      subtextColor,
                    ),
                    _buildDivider(isDark),
                    _buildMetric(
                      'ROI',
                      '${promotion.roi.toStringAsFixed(0)}%',
                      const Color(0xFF8B5CF6),
                      subtextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AlhaiSpacing.sm),

              // أزرار
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: subtextColor,
                        side: BorderSide(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.15)
                              : AppColors.border,
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: AlhaiSpacing.xs),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(l10n.details,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: typeColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: AlhaiSpacing.xs),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(l10n.apply,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric(
      String label, String value, Color valueColor, Color labelColor) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xxxs),
          Text(
            label,
            style: TextStyle(color: labelColor, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 30,
      color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.grey200,
    );
  }

  IconData _getTypeIcon(PromotionType type) {
    switch (type) {
      case PromotionType.percentOff:
        return Icons.percent;
      case PromotionType.buyXGetY:
        return Icons.card_giftcard;
      case PromotionType.bundle:
        return Icons.inventory_2_outlined;
      case PromotionType.flashSale:
        return Icons.flash_on;
      case PromotionType.loyaltyBonus:
        return Icons.stars;
      case PromotionType.seasonalDeal:
        return Icons.celebration;
    }
  }
}
