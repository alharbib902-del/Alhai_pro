/// Top Selling Products Widget - الأكثر مبيعاً
///
/// قائمة المنتجات الأكثر مبيعاً في لوحة التحكم
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../core/utils/currency_formatter.dart';

/// بيانات منتج الأكثر مبيعاً
class TopSellingProduct {
  final String id;
  final String name;
  final String? imageUrl;
  final int soldCount;
  final double revenue;
  final String? category;

  const TopSellingProduct({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.soldCount,
    required this.revenue,
    this.category,
  });
}

/// قائمة الأكثر مبيعاً
class TopSellingList extends StatelessWidget {
  final List<TopSellingProduct> products;
  final VoidCallback? onViewAll;
  final String Function(double)? formatCurrency;

  const TopSellingList({
    super.key,
    required this.products,
    this.onViewAll,
    this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    String formatAmount(double amount) {
      if (formatCurrency != null) return formatCurrency!(amount);
      return CurrencyFormatter.formatCompactWithContext(context, amount);
    }

    return Container(
      padding: const EdgeInsets.all(AlhaiSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.topSelling,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: Text(
                    l10n.viewAll,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AlhaiSpacing.md),
          
          // قائمة المنتجات
          ...products.take(5).map((product) => _TopSellingItem(
            product: product,
            formatAmount: formatAmount,
            isDarkMode: isDarkMode,
          )),
        ],
      ),
    );
  }
}

/// عنصر منتج أكثر مبيعاً
class _TopSellingItem extends StatelessWidget {
  final TopSellingProduct product;
  final String Function(double) formatAmount;
  final bool isDarkMode;

  const _TopSellingItem({
    required this.product,
    required this.formatAmount,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AlhaiSpacing.sm),
      child: Row(
        children: [
          // صورة المنتج أو أيقونة
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.white.withValues(alpha: 0.1) 
                  : AppColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 100,
                      memCacheHeight: 100,
                      placeholder: (_, __) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.coffee_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  )
                : Icon(
                    Icons.inventory_2_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
          ),
          
          SizedBox(width: AlhaiSpacing.sm),
          
          // معلومات المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: AlhaiSpacing.xxxs),
                Text(
                  '${product.soldCount} مبيع',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // المبلغ
          Text(
            formatAmount(product.revenue),
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
