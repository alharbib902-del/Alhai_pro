/// بطاقة التوصية - Recommendation Card
///
/// تعرض توصية منتج مع حاوية صورة والسبب ونسبة الثقة
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/ai_customer_recommendations_service.dart';

/// بطاقة توصية المنتج
class RecommendationCard extends StatelessWidget {
  final RecommendedProduct product;
  final VoidCallback? onAddToCart;
  final bool compact;

  const RecommendationCard({
    super.key,
    required this.product,
    this.onAddToCart,
    this.compact = false,
  });

  Color _getConfidenceColor() {
    if (product.confidence >= 0.8) return AppColors.success;
    if (product.confidence >= 0.6) return AppColors.warning;
    return AppColors.info;
  }

  IconData _getCategoryIcon() {
    switch (product.category) {
      case 'أرز':
        return Icons.rice_bowl_rounded;
      case 'لحوم':
        return Icons.set_meal_rounded;
      case 'ألبان':
        return Icons.water_drop_rounded;
      case 'مشروبات':
        return Icons.local_cafe_rounded;
      case 'مخبوزات':
        return Icons.bakery_dining_rounded;
      case 'أطفال':
        return Icons.child_care_rounded;
      case 'حلويات':
        return Icons.cookie_rounded;
      case 'زيوت':
        return Icons.oil_barrel_rounded;
      default:
        return Icons.shopping_bag_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confColor = _getConfidenceColor();

    if (compact) {
      return _buildCompact(isDark, confColor);
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image placeholder + category icon
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_getCategoryIcon(), color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (product.category != null)
                      Text(
                        product.category!,
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              // Price
              if (product.price > 0)
                Text(
                  '${product.price.toStringAsFixed(1)} ر.س', // SAR
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // Reason
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.grey50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.warning),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    product.reason,
                    style: TextStyle(
                      color: isDark ? Colors.white.withValues(alpha: 0.7) : AppColors.textSecondary,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Confidence + interval + action
          Row(
            children: [
              // Confidence
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: confColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.psychology_rounded, size: 12, color: confColor),
                    const SizedBox(width: 4),
                    Text(
                      '${(product.confidence * 100).toInt()}%',
                      style: TextStyle(
                        color: confColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Purchase interval
              if (product.avgPurchaseInterval > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.grey100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 12,
                        color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'كل ${product.avgPurchaseInterval} يوم', // Every X days
                        style: TextStyle(
                          color: isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // Add to cart button
              if (onAddToCart != null)
                IconButton(
                  onPressed: onAddToCart,
                  icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
                  color: AppColors.primary,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompact(bool isDark, Color confColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.grey50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getCategoryIcon(), color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              product.name,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: confColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${(product.confidence * 100).toInt()}%',
              style: TextStyle(color: confColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
