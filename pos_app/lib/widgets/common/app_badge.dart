/// الشارات والعلامات - App Badges
///
/// مجموعة شارات وعلامات متناسقة للتطبيق
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// نوع الشارة
enum AppBadgeVariant { filled, outlined, soft }

/// حجم الشارة
enum AppBadgeSize { small, medium, large }

/// الشارة الموحدة
class AppBadge extends StatelessWidget {
  /// النص
  final String label;

  /// اللون
  final Color color;

  /// النوع
  final AppBadgeVariant variant;

  /// الحجم
  final AppBadgeSize size;

  /// الأيقونة
  final IconData? icon;

  /// عند الضغط
  final VoidCallback? onTap;

  /// عند الحذف
  final VoidCallback? onDelete;

  const AppBadge({
    super.key,
    required this.label,
    this.color = AppColors.primary,
    this.variant = AppBadgeVariant.filled,
    this.size = AppBadgeSize.medium,
    this.icon,
    this.onTap,
    this.onDelete,
  });

  /// شارة النجاح
  factory AppBadge.success(String label, {AppBadgeSize size = AppBadgeSize.medium}) {
    return AppBadge(
      label: label,
      color: AppColors.success,
      variant: AppBadgeVariant.soft,
      size: size,
    );
  }

  /// شارة التحذير
  factory AppBadge.warning(String label, {AppBadgeSize size = AppBadgeSize.medium}) {
    return AppBadge(
      label: label,
      color: AppColors.warning,
      variant: AppBadgeVariant.soft,
      size: size,
    );
  }

  /// شارة الخطأ
  factory AppBadge.error(String label, {AppBadgeSize size = AppBadgeSize.medium}) {
    return AppBadge(
      label: label,
      color: AppColors.error,
      variant: AppBadgeVariant.soft,
      size: size,
    );
  }

  /// شارة المعلومات
  factory AppBadge.info(String label, {AppBadgeSize size = AppBadgeSize.medium}) {
    return AppBadge(
      label: label,
      color: AppColors.info,
      variant: AppBadgeVariant.soft,
      size: size,
    );
  }

  /// شارة المخزون
  factory AppBadge.stock(int quantity, {int minQuantity = 5}) {
    if (quantity <= 0) {
      return const AppBadge(
        label: 'نفذ',
        color: AppColors.stockOut,
        variant: AppBadgeVariant.soft,
        size: AppBadgeSize.small,
      );
    }
    if (quantity <= minQuantity) {
      return AppBadge(
        label: 'قليل ($quantity)',
        color: AppColors.stockLow,
        variant: AppBadgeVariant.soft,
        size: AppBadgeSize.small,
      );
    }
    return AppBadge(
      label: 'متوفر ($quantity)',
      color: AppColors.stockAvailable,
      variant: AppBadgeVariant.soft,
      size: AppBadgeSize.small,
    );
  }

  /// شارة طريقة الدفع
  factory AppBadge.paymentMethod(String method) {
    final color = AppColors.getPaymentMethodColor(method);
    String label;
    IconData icon;

    switch (method.toLowerCase()) {
      case 'cash':
      case 'نقد':
        label = 'نقد';
        icon = Icons.payments_outlined;
        break;
      case 'card':
      case 'بطاقة':
        label = 'بطاقة';
        icon = Icons.credit_card;
        break;
      case 'credit':
      case 'آجل':
        label = 'آجل';
        icon = Icons.access_time;
        break;
      default:
        label = method;
        icon = Icons.payment;
    }

    return AppBadge(
      label: label,
      color: color,
      variant: AppBadgeVariant.soft,
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getPaddingH(),
          vertical: _getPaddingV(),
        ),
        decoration: _getDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: _getIconSize(),
                color: _getContentColor(),
              ),
              SizedBox(width: _getSpacing()),
            ],
            Text(
              label,
              style: _getTextStyle().copyWith(
                color: _getContentColor(),
              ),
            ),
            if (onDelete != null) ...[
              SizedBox(width: _getSpacing()),
              GestureDetector(
                onTap: onDelete,
                child: Icon(
                  Icons.close,
                  size: _getIconSize(),
                  color: _getContentColor(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  BoxDecoration _getDecoration() {
    switch (variant) {
      case AppBadgeVariant.filled:
        return BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.full),
        );
      case AppBadgeVariant.outlined:
        return BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: color, width: 1.5),
        );
      case AppBadgeVariant.soft:
        return BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.full),
        );
    }
  }

  Color _getContentColor() {
    switch (variant) {
      case AppBadgeVariant.filled:
        return AppColors.white;
      case AppBadgeVariant.outlined:
      case AppBadgeVariant.soft:
        return color;
    }
  }

  double _getPaddingH() {
    switch (size) {
      case AppBadgeSize.small:
        return AppSpacing.sm;
      case AppBadgeSize.medium:
        return AppSpacing.md;
      case AppBadgeSize.large:
        return AppSpacing.lg;
    }
  }

  double _getPaddingV() {
    switch (size) {
      case AppBadgeSize.small:
        return AppSpacing.xxs;
      case AppBadgeSize.medium:
        return AppSpacing.xs;
      case AppBadgeSize.large:
        return AppSpacing.sm;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AppBadgeSize.small:
        return 12;
      case AppBadgeSize.medium:
        return 14;
      case AppBadgeSize.large:
        return 16;
    }
  }

  double _getSpacing() {
    switch (size) {
      case AppBadgeSize.small:
        return AppSpacing.xxs;
      case AppBadgeSize.medium:
        return AppSpacing.xs;
      case AppBadgeSize.large:
        return AppSpacing.sm;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppBadgeSize.small:
        return AppTypography.badge;
      case AppBadgeSize.medium:
        return AppTypography.labelSmall;
      case AppBadgeSize.large:
        return AppTypography.labelMedium;
    }
  }
}

/// شارة العدد (للإشعارات)
class AppCountBadge extends StatelessWidget {
  /// العدد
  final int count;

  /// اللون
  final Color color;

  /// الحجم
  final double size;

  /// إظهار الصفر
  final bool showZero;

  /// الحد الأقصى للعرض
  final int maxCount;

  const AppCountBadge({
    super.key,
    required this.count,
    Color color = AppColors.error,
    Color? backgroundColor, // alias for color
    this.size = 20,
    this.showZero = false,
    this.maxCount = 99,
  }) : color = backgroundColor ?? color;

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && !showZero) {
      return const SizedBox.shrink();
    }

    final displayText = count > maxCount ? '$maxCount+' : count.toString();

    return Container(
      constraints: BoxConstraints(
        minWidth: size,
        minHeight: size,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: count > 9 ? size * 0.25 : 0,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: AppColors.white,
            fontSize: size * 0.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// شارة الحالة (Online/Offline, Active/Inactive)
class AppStatusBadge extends StatelessWidget {
  /// النص
  final String? label;

  /// الحالة
  final bool isActive;

  /// لون الحالة النشطة
  final Color activeColor;

  /// لون الحالة غير النشطة
  final Color inactiveColor;

  /// إظهار النص
  final bool showLabel;

  /// حجم النقطة
  final double dotSize;

  /// Pulse animation
  final bool pulse;

  const AppStatusBadge({
    super.key,
    this.label,
    required this.isActive,
    this.activeColor = AppColors.success,
    this.inactiveColor = AppColors.grey400,
    this.showLabel = true,
    this.dotSize = 8,
    this.pulse = false,
  });

  /// حالة الاتصال
  factory AppStatusBadge.online({bool isOnline = true}) {
    return AppStatusBadge(
      isActive: isOnline,
      label: isOnline ? 'متصل' : 'غير متصل',
      pulse: isOnline,
    );
  }

  /// حالة النشاط
  factory AppStatusBadge.active({bool isActive = true}) {
    return AppStatusBadge(
      isActive: isActive,
      label: isActive ? 'نشط' : 'غير نشط',
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dot
        _StatusDot(
          color: color,
          size: dotSize,
          pulse: pulse && isActive,
        ),

        // Label
        if (showLabel && label != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            label!,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _StatusDot extends StatefulWidget {
  final Color color;
  final double size;
  final bool pulse;

  const _StatusDot({
    required this.color,
    required this.size,
    required this.pulse,
  });

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    if (widget.pulse) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(_StatusDot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pulse && !oldWidget.pulse) {
      _controller.repeat();
    } else if (!widget.pulse && oldWidget.pulse) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 2,
      height: widget.size * 2,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse Ring
          if (widget.pulse)
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: widget.size * 2 * (1 + _animation.value * 0.5),
                  height: widget.size * 2 * (1 + _animation.value * 0.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.color.withValues(alpha: _animation.value * 0.3),
                  ),
                );
              },
            ),

          // Main Dot
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}

/// شارة التصنيف
class AppCategoryBadge extends StatelessWidget {
  /// اسم التصنيف
  final String category;

  /// اللون (اختياري - يُحسب تلقائياً)
  final Color? color;

  /// عند الضغط
  final VoidCallback? onTap;

  /// محدد
  final bool isSelected;

  const AppCategoryBadge({
    super.key,
    required this.category,
    this.color,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.getCategoryColor(category);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? effectiveColor : effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: effectiveColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          category,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? AppColors.white : effectiveColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
