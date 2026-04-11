/// الشارات والعلامات - App Badges
///
/// مجموعة شارات وعلامات متناسقة للتطبيق
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

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
  factory AppBadge.success(
    String label, {
    AppBadgeSize size = AppBadgeSize.medium,
  }) {
    return AppBadge(
      label: label,
      color: AppColors.success,
      variant: AppBadgeVariant.soft,
      size: size,
    );
  }

  /// شارة التحذير
  factory AppBadge.warning(
    String label, {
    AppBadgeSize size = AppBadgeSize.medium,
  }) {
    return AppBadge(
      label: label,
      color: AppColors.warning,
      variant: AppBadgeVariant.soft,
      size: size,
    );
  }

  /// شارة الخطأ
  factory AppBadge.error(
    String label, {
    AppBadgeSize size = AppBadgeSize.medium,
  }) {
    return AppBadge(
      label: label,
      color: AppColors.error,
      variant: AppBadgeVariant.soft,
      size: size,
    );
  }

  /// شارة المعلومات
  factory AppBadge.info(
    String label, {
    AppBadgeSize size = AppBadgeSize.medium,
  }) {
    return AppBadge(
      label: label,
      color: AppColors.info,
      variant: AppBadgeVariant.soft,
      size: size,
    );
  }

  /// شارة المخزون
  static AppBadge stock(
    BuildContext context,
    double quantity, {
    double minQuantity = 5,
  }) {
    final l10n = AppLocalizations.of(context);
    if (quantity <= 0) {
      return AppBadge(
        label: l10n.soldOut,
        color: AppColors.stockOut,
        variant: AppBadgeVariant.soft,
        size: AppBadgeSize.small,
      );
    }
    if (quantity <= minQuantity) {
      return AppBadge(
        label: '${l10n.lowStockLabel} (${quantity.round()})',
        color: AppColors.stockLow,
        variant: AppBadgeVariant.soft,
        size: AppBadgeSize.small,
      );
    }
    return AppBadge(
      label: '${l10n.available} ($quantity)',
      color: AppColors.stockAvailable,
      variant: AppBadgeVariant.soft,
      size: AppBadgeSize.small,
    );
  }

  /// شارة طريقة الدفع
  static AppBadge paymentMethod(BuildContext context, String method) {
    final l10n = AppLocalizations.of(context);
    final color = AppColors.getPaymentMethodColor(method);
    String label;
    IconData icon;

    switch (method.toLowerCase()) {
      case 'cash':
      case 'نقد':
        label = l10n.cash;
        icon = Icons.payments_outlined;
        break;
      case 'card':
      case 'بطاقة':
        label = l10n.card;
        icon = Icons.credit_card;
        break;
      case 'credit':
      case 'آجل':
        label = l10n.credit;
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
              Icon(icon, size: _getIconSize(), color: _getContentColor()),
              SizedBox(width: _getSpacing()),
            ],
            Text(
              label,
              style: _getTextStyle().copyWith(color: _getContentColor()),
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
      constraints: BoxConstraints(minWidth: size, minHeight: size),
      padding: EdgeInsets.symmetric(horizontal: count > 9 ? size * 0.25 : 0),
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
  static AppStatusBadge online(BuildContext context, {bool isOnline = true}) {
    final l10n = AppLocalizations.of(context);
    return AppStatusBadge(
      isActive: isOnline,
      label: isOnline ? l10n.online : l10n.offline,
      pulse: isOnline,
    );
  }

  /// حالة النشاط
  static AppStatusBadge active(BuildContext context, {bool isActive = true}) {
    final l10n = AppLocalizations.of(context);
    return AppStatusBadge(
      isActive: isActive,
      label: isActive ? l10n.active : l10n.inactive,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : inactiveColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dot
        _StatusDot(color: color, size: dotSize, pulse: pulse && isActive),

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
      duration: AlhaiDurations.shimmer,
    );
    _animation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: AlhaiMotion.fadeOut));
    if (widget.pulse) {
      _controller.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.stop();
      _controller.value = 0;
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
                    color: widget.color.withValues(
                      alpha: _animation.value * 0.3,
                    ),
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
          color: isSelected
              ? effectiveColor
              : effectiveColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: effectiveColor, width: isSelected ? 2 : 1),
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
