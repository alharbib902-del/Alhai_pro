/// Modern Card Widget - بطاقة عصرية مع Glassmorphism
///
/// مميزات:
/// - تأثير Glass morphism
/// - Gradient borders
/// - Hover animations
/// - Shadow متغير
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';

/// نوع البطاقة
enum ModernCardVariant {
  /// بطاقة عادية
  normal,

  /// بطاقة زجاجية (Glassmorphism)
  glass,

  /// بطاقة مع gradient
  gradient,

  /// بطاقة مرتفعة
  elevated,

  /// بطاقة مسطحة
  flat,
}

/// بطاقة عصرية محسنة
class ModernCard extends ConsumerStatefulWidget {
  final Widget child;
  final ModernCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double? borderRadius;
  final bool hasBorder;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableHover;
  final bool enablePress;
  final double? width;
  final double? height;
  final List<BoxShadow>? customShadow;
  final double blurAmount;

  const ModernCard({
    super.key,
    required this.child,
    this.variant = ModernCardVariant.normal,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.borderRadius,
    this.hasBorder = false,
    this.borderColor,
    this.borderWidth = 1,
    this.onTap,
    this.onLongPress,
    this.enableHover = true,
    this.enablePress = true,
    this.width,
    this.height,
    this.customShadow,
    this.blurAmount = 10,
  });

  /// بطاقة زجاجية
  factory ModernCard.glass({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    VoidCallback? onTap,
    double blurAmount = 15,
  }) {
    return ModernCard(
      key: key,
      variant: ModernCardVariant.glass,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      blurAmount: blurAmount,
      child: child,
    );
  }

  /// بطاقة مع gradient
  factory ModernCard.gradient({
    Key? key,
    required Widget child,
    required Gradient gradient,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? borderRadius,
    VoidCallback? onTap,
  }) {
    return ModernCard(
      key: key,
      variant: ModernCardVariant.gradient,
      gradient: gradient,
      padding: padding,
      margin: margin,
      borderRadius: borderRadius,
      onTap: onTap,
      child: child,
    );
  }

  /// بطاقة إحصائيات
  factory ModernCard.stat({
    Key? key,
    required String title,
    required String value,
    IconData? icon,
    Color? iconColor,
    double? change,
    String? changeLabel,
    VoidCallback? onTap,
    Gradient? gradient,
  }) {
    return ModernCard(
      key: key,
      variant: gradient != null ? ModernCardVariant.gradient : ModernCardVariant.elevated,
      gradient: gradient,
      onTap: onTap,
      child: _StatContent(
        title: title,
        value: value,
        icon: icon,
        iconColor: iconColor,
        change: change,
        changeLabel: changeLabel,
        hasGradient: gradient != null,
      ),
    );
  }

  @override
  ConsumerState<ModernCard> createState() => _ModernCardState();
}

class _ModernCardState extends ConsumerState<ModernCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AlhaiDurations.quick,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: AlhaiMotion.standard),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.enablePress && widget.onTap != null) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.enablePress) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (widget.enablePress) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderRadius = widget.borderRadius ?? AppSizes.radiusLg;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.enablePress ? _scaleAnimation.value : 1.0,
          child: _buildCard(context, isDark, borderRadius),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, bool isDark, double borderRadius) {
    switch (widget.variant) {
      case ModernCardVariant.glass:
        return _buildGlassCard(context, isDark, borderRadius);
      case ModernCardVariant.gradient:
        return _buildGradientCard(context, borderRadius);
      case ModernCardVariant.elevated:
        return _buildElevatedCard(context, isDark, borderRadius);
      case ModernCardVariant.flat:
        return _buildFlatCard(context, isDark, borderRadius);
      case ModernCardVariant.normal:
        return _buildNormalCard(context, isDark, borderRadius);
    }
  }

  Widget _buildGlassCard(BuildContext context, bool isDark, double borderRadius) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: widget.blurAmount,
            sigmaY: widget.blurAmount,
          ),
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: widget.onTap,
            onLongPress: widget.onLongPress,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: widget.padding ?? const EdgeInsets.all(AppSizes.lg),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  color: isDark
                      ? Colors.white.withValues(alpha: _isHovered ? 0.15 : 0.1)
                      : Colors.white.withValues(alpha: _isHovered ? 0.9 : 0.7),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: _isHovered ? 20 : 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientCard(BuildContext context, double borderRadius) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: widget.padding ?? const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: widget.gradient ?? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (widget.gradient?.colors.first ?? AppColors.primary)
                      .withValues(alpha: _isHovered ? 0.4 : 0.3),
                  blurRadius: _isHovered ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedCard(BuildContext context, bool isDark, double borderRadius) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: widget.padding ?? const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: widget.backgroundColor ??
                  Theme.of(context).colorScheme.surface,
              border: widget.hasBorder
                  ? Border.all(
                      color: widget.borderColor ?? AppColors.border,
                      width: widget.borderWidth,
                    )
                  : null,
              boxShadow: widget.customShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                      blurRadius: _isHovered ? 24 : 16,
                      offset: Offset(0, _isHovered ? 8 : 4),
                    ),
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                  ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildFlatCard(BuildContext context, bool isDark, double borderRadius) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: widget.padding ?? const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: _isHovered
                  ? (isDark ? AppColors.grey700 : AppColors.grey100)
                  : (widget.backgroundColor ??
                      (isDark ? AppColors.grey800 : AppColors.grey50)),
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : (widget.borderColor ?? AppColors.border),
                width: widget.borderWidth,
              ),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget _buildNormalCard(BuildContext context, bool isDark, double borderRadius) {
    return Container(
      width: widget.width,
      height: widget.height,
      margin: widget.margin,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        child: MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: widget.padding ?? const EdgeInsets.all(AppSizes.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              color: widget.backgroundColor ??
                  Theme.of(context).colorScheme.surface,
              border: Border.all(
                color: _isHovered
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : (widget.borderColor ?? AppColors.border),
                width: widget.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
                  blurRadius: _isHovered ? 12 : 8,
                  offset: Offset(0, _isHovered ? 4 : 2),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// محتوى بطاقة الإحصائيات
class _StatContent extends StatelessWidget {
  final String title;
  final String value;
  final IconData? icon;
  final Color? iconColor;
  final double? change;
  final String? changeLabel;
  final bool hasGradient;

  const _StatContent({
    required this.title,
    required this.value,
    this.icon,
    this.iconColor,
    this.change,
    this.changeLabel,
    this.hasGradient = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = hasGradient ? colorScheme.onPrimary : colorScheme.onSurface;
    final mutedColor = hasGradient
        ? colorScheme.onPrimary.withValues(alpha: 0.8)
        : colorScheme.onSurfaceVariant;
    final effectiveIconColor = hasGradient
        ? colorScheme.onPrimary.withValues(alpha: 0.9)
        : (iconColor ?? colorScheme.primary);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: mutedColor,
              ),
            ),
            if (icon != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasGradient
                      ? colorScheme.onPrimary.withValues(alpha: 0.2)
                      : effectiveIconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: effectiveIconColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        if (change != null) ...[
          const SizedBox(height: AppSizes.sm),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: change! >= 0
                      ? (hasGradient
                          ? colorScheme.onPrimary.withValues(alpha: 0.2)
                          : AppColors.successSurface)
                      : (hasGradient
                          ? colorScheme.onPrimary.withValues(alpha: 0.2)
                          : AppColors.errorSurface),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      change! >= 0 ? Icons.trending_up : Icons.trending_down,
                      size: 14,
                      color: change! >= 0
                          ? (hasGradient ? colorScheme.onPrimary : AppColors.success)
                          : (hasGradient ? colorScheme.onPrimary : AppColors.error),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${change!.abs().toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: change! >= 0
                            ? (hasGradient ? Colors.white : AppColors.success)
                            : (hasGradient ? Colors.white : AppColors.error),
                      ),
                    ),
                  ],
                ),
              ),
              if (changeLabel != null) ...[
                const SizedBox(width: AppSizes.xs),
                Text(
                  changeLabel!,
                  style: TextStyle(
                    fontSize: 11,
                    color: mutedColor,
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}
