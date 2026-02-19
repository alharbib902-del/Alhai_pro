/// بطاقات التطبيق الموحدة - App Cards
///
/// مجموعة بطاقات متناسقة للتطبيق
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import '../../l10n/generated/app_localizations.dart';

/// البطاقة الموحدة
class AppCard extends StatefulWidget {
  /// محتوى البطاقة
  final Widget child;

  /// عند الضغط
  final VoidCallback? onTap;

  /// عند الضغط المطول
  final VoidCallback? onLongPress;

  /// الـ padding الداخلي
  final EdgeInsetsGeometry? padding;

  /// الـ margin الخارجي
  final EdgeInsetsGeometry? margin;

  /// لون الخلفية
  final Color? backgroundColor;

  /// لون الحدود
  final Color? borderColor;

  /// هل محدد؟
  final bool isSelected;

  /// لون التحديد
  final Color? selectedColor;

  /// نصف قطر الحواف
  final double? borderRadius;

  /// الظل
  final List<BoxShadow>? boxShadow;

  /// Elevation
  final double elevation;

  /// Widget للزاوية
  final Widget? cornerWidget;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.isSelected = false,
    this.selectedColor,
    this.borderRadius,
    this.boxShadow,
    this.elevation = 0,
    this.cornerWidget,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = widget.isSelected
        ? (widget.selectedColor ?? AppColors.primary)
        : widget.borderColor ?? AppColors.border;

    final effectiveBackgroundColor = widget.isSelected
        ? (widget.selectedColor ?? AppColors.primary).withValues(alpha: 0.05)
        : widget.backgroundColor ?? AppColors.surface;

    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: AppDurations.fast,
          decoration: BoxDecoration(
            color: effectiveBackgroundColor,
            borderRadius: BorderRadius.circular(
              widget.borderRadius ?? AppRadius.lg,
            ),
            border: Border.all(
              color: effectiveBorderColor,
              width: widget.isSelected ? 2 : 1,
            ),
            boxShadow: widget.boxShadow ??
                (widget.elevation > 0 || _isHovered ? AppShadows.md : AppShadows.sm),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? AppRadius.lg,
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: widget.padding ??
                        const EdgeInsets.all(AppCardSize.paddingMd),
                    child: widget.child,
                  ),

                  // Corner Widget (Badge, Checkbox, etc.)
                  if (widget.cornerWidget != null)
                    PositionedDirectional(
                      top: AppSpacing.sm,
                      start: AppSpacing.sm,
                      child: widget.cornerWidget!,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// بطاقة إحصائية
class StatCard extends StatelessWidget {
  /// العنوان
  final String title;

  /// القيمة
  final String value;

  /// الأيقونة
  final IconData icon;

  /// لون الأيقونة
  final Color? iconColor;

  /// لون الخلفية للأيقونة
  final Color? iconBackgroundColor;

  /// التغيير (نسبة مئوية)
  final double? change;

  /// وصف التغيير
  final String? changeLabel;

  /// عند الضغط
  final VoidCallback? onTap;

  /// العرض الكامل
  final bool fullWidth;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.change,
    this.changeLabel,
    this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? AppColors.primary;
    final effectiveIconBgColor =
        iconBackgroundColor ?? effectiveIconColor.withValues(alpha: 0.1);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: effectiveIconBgColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  icon,
                  color: effectiveIconColor,
                  size: AppIconSize.md,
                ),
              ),

              const SizedBox(width: AppSpacing.md),

              // Title & Value
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      value,
                      style: AppTypography.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Change indicator
          if (change != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  change! >= 0 ? Icons.trending_up : Icons.trending_down,
                  size: AppIconSize.sm,
                  color: change! >= 0 ? AppColors.success : AppColors.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${change! >= 0 ? '+' : ''}${change!.toStringAsFixed(1)}%',
                  style: AppTypography.labelMedium.copyWith(
                    color: change! >= 0 ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (changeLabel != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    changeLabel!,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// بطاقة منتج
class ProductCard extends StatelessWidget {
  /// اسم المنتج
  final String name;

  /// السعر
  final double price;

  /// العملة
  final String currency;

  /// صورة المنتج
  final String? imageUrl;

  /// الأيقونة البديلة
  final IconData? fallbackIcon;

  /// الكمية المتوفرة
  final int? quantity;

  /// التصنيف
  final String? category;

  /// لون التصنيف
  final Color? categoryColor;

  /// هل محدد؟
  final bool isSelected;

  /// عند الضغط
  final VoidCallback? onTap;

  /// عند الإضافة للسلة
  final VoidCallback? onAddToCart;

  /// السعر القديم (للعروض)
  final double? oldPrice;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    this.currency = 'ر.س',
    this.imageUrl,
    this.fallbackIcon,
    this.quantity,
    this.category,
    this.categoryColor,
    this.isSelected = false,
    this.onTap,
    this.onAddToCart,
    this.oldPrice,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final stockStatus = _getStockStatus(l10n);

    return AppCard(
      onTap: onTap,
      isSelected: isSelected,
      padding: EdgeInsets.zero,
      cornerWidget: category != null
          ? _buildCategoryBadge()
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.grey100,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg - 1),
                ),
              ),
              child: imageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppRadius.lg - 1),
                      ),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildFallbackImage(),
                      ),
                    )
                  : _buildFallbackImage(),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  name,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppSpacing.xs),

                // Price Row
                Row(
                  children: [
                    // Current Price
                    Text(
                      '${price.toStringAsFixed(2)} $currency',
                      style: AppTypography.priceMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),

                    // Old Price
                    if (oldPrice != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        oldPrice!.toStringAsFixed(2),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),

                // Stock Status
                if (quantity != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: stockStatus.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        stockStatus.label,
                        style: AppTypography.labelSmall.copyWith(
                          color: stockStatus.color,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Add to Cart Button
          if (onAddToCart != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: quantity != null && quantity! > 0
                      ? onAddToCart
                      : null,
                  icon: const Icon(Icons.add_shopping_cart, size: 18),
                  label: Text(l10n.add),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Center(
      child: Icon(
        fallbackIcon ?? Icons.inventory_2_outlined,
        size: AppIconSize.xxl,
        color: AppColors.grey400,
      ),
    );
  }

  Widget _buildCategoryBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: categoryColor ?? AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        category!,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  ({String label, Color color}) _getStockStatus(AppLocalizations l10n) {
    if (quantity == null || quantity! <= 0) {
      return (label: l10n.soldOut, color: AppColors.stockOut);
    }
    if (quantity! <= 5) {
      return (label: '${l10n.lowStock} ($quantity)', color: AppColors.stockLow);
    }
    return (label: '${l10n.inStock} ($quantity)', color: AppColors.stockAvailable);
  }
}

/// بطاقة عميل
class CustomerCard extends StatelessWidget {
  /// اسم العميل
  final String name;

  /// رقم الهاتف
  final String? phone;

  /// الرصيد
  final double? balance;

  /// العملة
  final String currency;

  /// محدد؟
  final bool isSelected;

  /// عند الضغط
  final VoidCallback? onTap;

  /// أحرف الاسم للصورة الرمزية
  final String? initials;

  const CustomerCard({
    super.key,
    required this.name,
    this.phone,
    this.balance,
    this.currency = 'ر.س',
    this.isSelected = false,
    this.onTap,
    this.initials,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayInitials = initials ?? _getInitials(name);
    final balanceColor = AppColors.getBalanceColor(balance ?? 0);

    return AppCard(
      onTap: onTap,
      isSelected: isSelected,
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 24,
            backgroundColor: isSelected
                ? AppColors.primary
                : AppColors.primarySurface,
            child: Text(
              displayInitials,
              style: AppTypography.titleMedium.copyWith(
                color: isSelected ? AppColors.white : AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                if (phone != null) ...[
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    phone!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Balance
          if (balance != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  balance! > 0 ? l10n.owes : balance! < 0 ? l10n.due : l10n.balanced,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  '${balance!.abs().toStringAsFixed(2)} $currency',
                  style: AppTypography.priceSmall.copyWith(
                    color: balanceColor,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return name.isNotEmpty ? name[0] : '?';
  }
}
