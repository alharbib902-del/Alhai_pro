/// Modern Product Card - بطاقة منتج عصرية
///
/// تصميم احترافي للمنتجات مع:
/// - تأثيرات Hover متحركة
/// - Gradient overlays
/// - Quick actions
/// - Stock badges
/// - Haptic feedback
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// بطاقة منتج عصرية
class ModernProductCard extends StatefulWidget {
  /// معرف المنتج
  final String id;

  /// اسم المنتج
  final String name;

  /// السعر
  final double price;

  /// سعر التكلفة
  final double? costPrice;

  /// رابط الصورة
  final String? imageUrl;

  /// الكمية المتوفرة
  final int? stockQty;

  /// الحد الأدنى للمخزون
  final int? minQty;

  /// اسم الفئة
  final String? category;

  /// الباركود
  final String? barcode;

  /// الوحدة
  final String? unit;

  /// نشط أم لا
  final bool isActive;

  /// حدث الضغط
  final VoidCallback? onTap;

  /// حدث الضغط الطويل
  final VoidCallback? onLongPress;

  /// حدث إضافة للسلة
  final VoidCallback? onAddToCart;

  /// حدث التعديل
  final VoidCallback? onEdit;

  /// نوع العرض
  final ProductCardVariant variant;

  const ModernProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.price,
    this.costPrice,
    this.imageUrl,
    this.stockQty,
    this.minQty,
    this.category,
    this.barcode,
    this.unit,
    this.isActive = true,
    this.onTap,
    this.onLongPress,
    this.onAddToCart,
    this.onEdit,
    this.variant = ProductCardVariant.grid,
  });

  @override
  State<ModernProductCard> createState() => _ModernProductCardState();
}

class _ModernProductCardState extends State<ModernProductCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isOutOfStock => (widget.stockQty ?? 0) <= 0;
  bool get _isLowStock =>
      widget.stockQty != null &&
      widget.minQty != null &&
      widget.stockQty! > 0 &&
      widget.stockQty! <= widget.minQty!;

  Color get _stockColor {
    if (_isOutOfStock) return AppColors.error;
    if (_isLowStock) return AppColors.warning;
    return AppColors.success;
  }

  String get _stockText {
    if (_isOutOfStock) return 'نفد';
    if (_isLowStock) return 'منخفض';
    return 'متوفر';
  }

  @override
  Widget build(BuildContext context) {
    return widget.variant == ProductCardVariant.grid
        ? _buildGridCard()
        : _buildListCard();
  }

  Widget _buildGridCard() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTapDown: (_) {
                _controller.forward();
                HapticFeedback.selectionClick();
              },
              onTapUp: (_) {
                _controller.reverse();
              },
              onTapCancel: () {
                _controller.reverse();
              },
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.grey800
                      : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                  border: Border.all(
                    color: _isHovered
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.border,
                    width: _isHovered ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.black.withValues(alpha: 0.05),
                      blurRadius: _isHovered ? 20 : 8,
                      offset: Offset(0, _isHovered ? 8 : 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // صورة المنتج
                    Expanded(
                      flex: 3,
                      child: _buildImageSection(),
                    ),

                    // معلومات المنتج
                    Expanded(
                      flex: 2,
                      child: _buildInfoSection(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSection() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // الصورة
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLg),
          ),
          child: Container(
            color: AppColors.grey100,
            child: widget.imageUrl != null
                ? Image.network(
                    widget.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
        ),

        // Gradient overlay on hover
        if (_isHovered)
          Positioned.fill(
            child: AnimatedContainer(
              duration: AppDurations.fast,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppSizes.radiusLg),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),

        // شارة المخزون
        Positioned(
          top: AppSizes.sm,
          right: AppSizes.sm,
          child: _buildStockBadge(),
        ),

        // شارة الفئة
        if (widget.category != null)
          Positioned(
            top: AppSizes.sm,
            left: AppSizes.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: AppSizes.xxs,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
              ),
              child: Text(
                widget.category!,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),

        // زر إضافة سريعة عند التحويم
        if (_isHovered && widget.onAddToCart != null && !_isOutOfStock)
          Positioned(
            bottom: AppSizes.sm,
            right: AppSizes.sm,
            child: _buildQuickAddButton(),
          ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: AppColors.grey400,
      ),
    );
  }

  Widget _buildStockBadge() {
    return AnimatedContainer(
      duration: AppDurations.fast,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.sm,
        vertical: AppSizes.xxs,
      ),
      decoration: BoxDecoration(
        color: _stockColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        boxShadow: [
          BoxShadow(
            color: _stockColor.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isOutOfStock
                ? Icons.error
                : (_isLowStock ? Icons.warning_amber : Icons.check_circle),
            size: 12,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            widget.stockQty != null ? '${widget.stockQty}' : _stockText,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton() {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      elevation: 4,
      shadowColor: AppColors.primary.withValues(alpha: 0.4),
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          widget.onAddToCart?.call();
        },
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(
            Icons.add_shopping_cart,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // اسم المنتج
          Text(
            widget.name,
            style: AppTypography.titleSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // السعر والوحدة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.price.toStringAsFixed(2)} ر.س',
                      style: AppTypography.priceMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    if (widget.unit != null)
                      Text(
                        '/ ${widget.unit}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                  ],
                ),
              ),

              // زر إضافة (في حالة عدم التحويم)
              if (!_isHovered && widget.onAddToCart != null && !_isOutOfStock)
                IconButton(
                  onPressed: widget.onAddToCart,
                  icon: const Icon(
                    Icons.add_circle,
                    color: AppColors.primary,
                  ),
                  iconSize: 28,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListCard() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTapDown: (_) {
                _controller.forward();
                HapticFeedback.selectionClick();
              },
              onTapUp: (_) {
                _controller.reverse();
              },
              onTapCancel: () {
                _controller.reverse();
              },
              onTap: widget.onTap,
              onLongPress: widget.onLongPress,
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.all(AppSizes.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.grey800
                      : Colors.white,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  border: Border.all(
                    color: _isHovered
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.03),
                      blurRadius: _isHovered ? 12 : 4,
                      offset: Offset(0, _isHovered ? 4 : 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // الصورة
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      ),
                      child: widget.imageUrl != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusMd),
                              child: Image.network(
                                widget.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              ),
                            )
                          : _buildPlaceholder(),
                    ),

                    const SizedBox(width: AppSizes.md),

                    // المعلومات
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.name,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSizes.xxs),
                          Row(
                            children: [
                              if (widget.barcode != null) ...[
                                const Icon(
                                  Icons.qr_code,
                                  size: 12,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.barcode!,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: AppSizes.sm),
                              ],
                              _buildStockBadge(),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: AppSizes.md),

                    // السعر والأزرار
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${widget.price.toStringAsFixed(2)} ر.س',
                          style: AppTypography.priceMedium.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                        if (widget.unit != null)
                          Text(
                            '/ ${widget.unit}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),

                    if (widget.onAddToCart != null && !_isOutOfStock) ...[
                      const SizedBox(width: AppSizes.md),
                      IconButton(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          widget.onAddToCart?.call();
                        },
                        icon: const Icon(
                          Icons.add_shopping_cart,
                          color: AppColors.primary,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primarySurface,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// نوع عرض بطاقة المنتج
enum ProductCardVariant {
  /// عرض شبكي
  grid,

  /// عرض قائمة
  list,
}
