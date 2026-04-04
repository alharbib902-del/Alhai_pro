/// Gradient Button Widget - زر مع Gradient
///
/// زر عصري مع:
/// - تدرج لوني جذاب
/// - تأثيرات متحركة
/// - Haptic feedback
/// - Loading state
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// زر مع تدرج لوني
class GradientButton extends StatefulWidget {
  /// النص
  final String label;

  /// الأيقونة (اختياري)
  final IconData? icon;

  /// موقع الأيقونة
  final IconPosition iconPosition;

  /// حدث الضغط
  final VoidCallback? onPressed;

  /// حدث الضغط الطويل
  final VoidCallback? onLongPress;

  /// التدرج اللوني
  final Gradient? gradient;

  /// نصف قطر الحواف
  final double borderRadius;

  /// الارتفاع
  final double height;

  /// العرض (اختياري)
  final double? width;

  /// حالة التحميل
  final bool isLoading;

  /// معطل
  final bool isDisabled;

  /// حجم الزر
  final GradientButtonSize size;

  /// أيقونة فقط
  final bool iconOnly;

  /// ظل
  final bool hasShadow;

  const GradientButton({
    super.key,
    required this.label,
    this.icon,
    this.iconPosition = IconPosition.leading,
    this.onPressed,
    this.onLongPress,
    this.gradient,
    this.borderRadius = 12,
    this.height = 52,
    this.width,
    this.isLoading = false,
    this.isDisabled = false,
    this.size = GradientButtonSize.medium,
    this.iconOnly = false,
    this.hasShadow = true,
  });

  /// زر أساسي
  factory GradientButton.primary({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return GradientButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      gradient: LinearGradient(
        colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
    );
  }

  /// زر ثانوي
  factory GradientButton.secondary({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return GradientButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      gradient: LinearGradient(
        colors: [
          AppColors.secondary,
          AppColors.secondary.withValues(alpha: 0.8)
        ],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
    );
  }

  /// زر نجاح
  factory GradientButton.success({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return GradientButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      gradient: const LinearGradient(
        colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
    );
  }

  /// زر خطر
  factory GradientButton.danger({
    Key? key,
    required String label,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return GradientButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      gradient: const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
    );
  }

  /// زر مع ألوان مخصصة
  factory GradientButton.custom({
    Key? key,
    required String label,
    required List<Color> colors,
    IconData? icon,
    VoidCallback? onPressed,
    bool isLoading = false,
    bool isDisabled = false,
    double? width,
  }) {
    return GradientButton(
      key: key,
      label: label,
      icon: icon,
      onPressed: onPressed,
      isLoading: isLoading,
      isDisabled: isDisabled,
      width: width,
      gradient: LinearGradient(
        colors: colors,
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      ),
    );
  }

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AlhaiDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading;

  Gradient get _gradient =>
      widget.gradient ??
      LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.primary.withValues(alpha: 0.8),
        ],
        begin: AlignmentDirectional.topStart,
        end: AlignmentDirectional.bottomEnd,
      );

  double get _height {
    switch (widget.size) {
      case GradientButtonSize.small:
        return 36;
      case GradientButtonSize.medium:
        return 44;
      case GradientButtonSize.large:
        return 52;
    }
  }

  double get _fontSize {
    switch (widget.size) {
      case GradientButtonSize.small:
        return 13;
      case GradientButtonSize.medium:
        return 14;
      case GradientButtonSize.large:
        return 16;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case GradientButtonSize.small:
        return 16;
      case GradientButtonSize.medium:
        return 18;
      case GradientButtonSize.large:
        return 20;
    }
  }

  EdgeInsets get _padding {
    switch (widget.size) {
      case GradientButtonSize.small:
        return const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xs);
      case GradientButtonSize.medium:
        return const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md, vertical: 10);
      case GradientButtonSize.large:
        return const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.lg, vertical: 14);
    }
  }

  void _handleTapDown(TapDownDetails details) {
    if (_isEnabled) {
      setState(() => _isPressed = true);
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onTap: _isEnabled ? widget.onPressed : null,
            onLongPress: _isEnabled ? widget.onLongPress : null,
            child: AnimatedContainer(
              duration: AppDurations.fast,
              height: _height,
              width: widget.iconOnly ? _height : widget.width,
              decoration: BoxDecoration(
                gradient: _isEnabled ? _gradient : null,
                color: _isEnabled ? null : AppColors.grey300,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: widget.hasShadow && _isEnabled
                    ? [
                        BoxShadow(
                          color: (_gradient.colors.first).withValues(
                            alpha: _isPressed ? 0.4 : 0.3,
                          ),
                          blurRadius: _isPressed ? 16 : 12,
                          offset: Offset(0, _isPressed ? 6 : 4),
                        ),
                      ]
                    : null,
              ),
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: widget.iconOnly ? EdgeInsets.zero : _padding,
                  child: _buildContent(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      return Center(
        child: SizedBox(
          width: _iconSize,
          height: _iconSize,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor:
                AlwaysStoppedAnimation(Colors.white.withValues(alpha: 0.9)),
          ),
        ),
      );
    }

    if (widget.iconOnly && widget.icon != null) {
      return Center(
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: _iconSize,
        ),
      );
    }

    final textWidget = Text(
      widget.label,
      style: TextStyle(
        color: Colors.white,
        fontSize: _fontSize,
        fontWeight: FontWeight.w600,
        fontFamily: AppTypography.fontFamily,
      ),
    );

    if (widget.icon == null) {
      return Center(child: textWidget);
    }

    final iconWidget = Icon(
      widget.icon,
      color: Colors.white,
      size: _iconSize,
    );

    final spacing =
        SizedBox(width: widget.size == GradientButtonSize.small ? 6 : 8);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.iconPosition == IconPosition.leading
          ? [iconWidget, spacing, textWidget]
          : [textWidget, spacing, iconWidget],
    );
  }
}

/// حجم الزر
enum GradientButtonSize {
  small,
  medium,
  large,
}

/// موقع الأيقونة
enum IconPosition {
  leading,
  trailing,
}

/// زر أيقونة دائري مع Gradient
class GradientIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final double size;
  final String? tooltip;
  final bool isLoading;
  final bool isDisabled;

  const GradientIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.gradient,
    this.size = 44,
    this.tooltip,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<GradientIconButton> createState() => _GradientIconButtonState();
}

class _GradientIconButtonState extends State<GradientIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AlhaiDurations.fast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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

  bool get _isEnabled => !widget.isDisabled && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final button = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: (_) {
              if (_isEnabled) {
                _controller.forward();
                HapticFeedback.lightImpact();
              }
            },
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            onTap: _isEnabled ? widget.onPressed : null,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                gradient: _isEnabled
                    ? (widget.gradient ??
                        LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ],
                        ))
                    : null,
                color: _isEnabled ? null : AppColors.grey300,
                shape: BoxShape.circle,
                boxShadow: _isEnabled
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: widget.size * 0.4,
                        height: widget.size * 0.4,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : Icon(
                        widget.icon,
                        color: Colors.white,
                        size: widget.size * 0.5,
                      ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return button;
  }
}
