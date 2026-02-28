/// أزرار التطبيق الموحدة - App Buttons
///
/// مجموعة أزرار متناسقة للتطبيق
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// حجم الزر
enum ButtonSize { small, medium, large }

/// نوع الزر
enum AppButtonVariant { filled, outlined, ghost, soft }

/// الزر الموحد
class AppButton extends StatefulWidget {
  /// نص الزر
  final String label;

  /// عند الضغط
  final VoidCallback? onPressed;

  /// أيقونة قبل النص
  final IconData? icon;

  /// أيقونة بعد النص
  final IconData? suffixIcon;

  /// حجم الزر
  final ButtonSize size;

  /// نوع الزر
  final AppButtonVariant variant;

  /// لون مخصص
  final Color? color;

  /// هل يأخذ كامل العرض؟
  final bool fullWidth;

  /// هل يُحمّل؟
  final bool isLoading;

  /// معطل
  final bool disabled;

  /// ويدجت مخصص للتحميل
  final Widget? loadingWidget;

  /// Keyboard shortcut hint
  final String? shortcutHint;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.suffixIcon,
    this.size = ButtonSize.medium,
    this.variant = AppButtonVariant.filled,
    this.color,
    this.fullWidth = false,
    this.isLoading = false,
    this.disabled = false,
    this.loadingWidget,
    this.shortcutHint,
  });

  /// زر أساسي
  factory AppButton.primary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    ButtonSize size = ButtonSize.medium,
    bool fullWidth = false,
    bool isFullWidth = false, // alias for fullWidth
    bool isLoading = false,
    bool disabled = false,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      size: size,
      variant: AppButtonVariant.filled,
      color: AppColors.primary,
      fullWidth: fullWidth || isFullWidth,
      isLoading: isLoading,
      disabled: disabled,
    );
  }

  /// زر ثانوي
  factory AppButton.secondary({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    ButtonSize size = ButtonSize.medium,
    bool fullWidth = false,
    bool isFullWidth = false, // alias for fullWidth
    bool isLoading = false,
    bool disabled = false,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      size: size,
      variant: AppButtonVariant.outlined,
      color: AppColors.primary,
      fullWidth: fullWidth || isFullWidth,
      isLoading: isLoading,
      disabled: disabled,
    );
  }

  /// زر خطر
  factory AppButton.danger({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    ButtonSize size = ButtonSize.medium,
    bool fullWidth = false,
    bool isFullWidth = false, // alias for fullWidth
    bool isLoading = false,
    bool disabled = false,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      size: size,
      variant: AppButtonVariant.filled,
      color: AppColors.error,
      fullWidth: fullWidth || isFullWidth,
      isLoading: isLoading,
      disabled: disabled,
    );
  }

  /// زر نجاح
  factory AppButton.success({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    ButtonSize size = ButtonSize.medium,
    bool fullWidth = false,
    bool isFullWidth = false, // alias for fullWidth
    bool isLoading = false,
    bool disabled = false,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      size: size,
      variant: AppButtonVariant.filled,
      color: AppColors.success,
      fullWidth: fullWidth || isFullWidth,
      isLoading: isLoading,
      disabled: disabled,
    );
  }

  /// زر Ghost
  factory AppButton.ghost({
    required String label,
    VoidCallback? onPressed,
    IconData? icon,
    ButtonSize size = ButtonSize.medium,
    bool fullWidth = false,
    bool isFullWidth = false, // alias for fullWidth
    bool disabled = false,
  }) {
    return AppButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      size: size,
      variant: AppButtonVariant.ghost,
      fullWidth: fullWidth || isFullWidth,
      disabled: disabled,
    );
  }

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.primary;
    final isDisabled = widget.disabled || widget.isLoading;

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.label,
      hint: widget.shortcutHint,
      child: MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        constraints: BoxConstraints(
          minHeight: _getHeight(),
          minWidth: widget.fullWidth ? double.infinity : ButtonSize.medium == widget.size ? 100 : 80,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Ink(
              decoration: _getDecoration(effectiveColor, isDisabled),
              child: Container(
                height: _getHeight(),
                padding: EdgeInsets.symmetric(
                  horizontal: _getPadding(),
                ),
                child: Row(
                  mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Loading or Icon
                    if (widget.isLoading) ...[
                      widget.loadingWidget ??
                          SizedBox(
                            width: _getIconSize(),
                            height: _getIconSize(),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(
                                _getContentColor(effectiveColor, isDisabled),
                              ),
                            ),
                          ),
                      const SizedBox(width: AppSpacing.sm),
                    ] else if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: _getIconSize(),
                        color: _getContentColor(effectiveColor, isDisabled),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],

                    // Label
                    Flexible(
                      child: Text(
                        widget.label,
                        style: _getTextStyle().copyWith(
                          color: _getContentColor(effectiveColor, isDisabled),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Suffix Icon
                    if (widget.suffixIcon != null && !widget.isLoading) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        widget.suffixIcon,
                        size: _getIconSize(),
                        color: _getContentColor(effectiveColor, isDisabled),
                      ),
                    ],

                    // Shortcut Hint
                    if (widget.shortcutHint != null && !widget.isLoading) ...[
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xxs,
                        ),
                        decoration: BoxDecoration(
                          color: _getContentColor(effectiveColor, isDisabled)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          widget.shortcutHint!,
                          style: AppTypography.labelSmall.copyWith(
                            color: _getContentColor(effectiveColor, isDisabled),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  BoxDecoration _getDecoration(Color color, bool isDisabled) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.variant) {
      case AppButtonVariant.filled:
        return BoxDecoration(
          color: isDisabled
              ? colorScheme.surfaceContainerHigh
              : _isHovered
                  ? color.withValues(alpha: 0.9)
                  : color,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: isDisabled || !_isHovered ? null : AppShadows.primarySm,
        );

      case AppButtonVariant.outlined:
        return BoxDecoration(
          color: _isHovered ? color.withValues(alpha: 0.05) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isDisabled ? colorScheme.outlineVariant : color,
            width: 1.5,
          ),
        );

      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: _isHovered ? colorScheme.surfaceContainerLow : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        );

      case AppButtonVariant.soft:
        return BoxDecoration(
          color: isDisabled
              ? colorScheme.surfaceContainerLow
              : _isHovered
                  ? color.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
        );
    }
  }

  Color _getContentColor(Color color, bool isDisabled) {
    if (isDisabled) return Theme.of(context).colorScheme.onSurfaceVariant;

    switch (widget.variant) {
      case AppButtonVariant.filled:
        return AppColors.white;
      case AppButtonVariant.outlined:
      case AppButtonVariant.ghost:
      case AppButtonVariant.soft:
        return color;
    }
  }

  double _getHeight() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppButtonSize.heightSm;
      case ButtonSize.medium:
        return AppButtonSize.heightMd;
      case ButtonSize.large:
        return AppButtonSize.heightLg;
    }
  }

  double _getPadding() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppSpacing.md;
      case ButtonSize.medium:
        return AppButtonSize.paddingHorizontal;
      case ButtonSize.large:
        return AppButtonSize.paddingHorizontalLg;
    }
  }

  double _getIconSize() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppIconSize.sm;
      case ButtonSize.medium:
        return AppIconSize.md;
      case ButtonSize.large:
        return AppIconSize.md;
    }
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case ButtonSize.small:
        return AppTypography.buttonSmall;
      case ButtonSize.medium:
        return AppTypography.buttonMedium;
      case ButtonSize.large:
        return AppTypography.buttonLarge;
    }
  }
}

/// زر أيقونة
class AppIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;
  final String? tooltip;
  final bool isLoading;
  final bool disabled;
  final AppButtonVariant variant;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 40,
    this.tooltip,
    this.isLoading = false,
    this.disabled = false,
    this.variant = AppButtonVariant.ghost,
  });

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.disabled || widget.isLoading;
    final color = widget.color ?? AppColors.textSecondary;

    Widget button = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: AppDurations.fast,
        width: widget.size,
        height: widget.size,
        decoration: _getDecoration(color, isDisabled),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : widget.onPressed,
            borderRadius: BorderRadius.circular(widget.size / 2),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: widget.size * 0.5,
                      height: widget.size * 0.5,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(color),
                      ),
                    )
                  : Icon(
                      widget.icon,
                      size: widget.size * 0.5,
                      color: isDisabled
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : color,
                    ),
            ),
          ),
        ),
      ),
    );

    if (widget.tooltip != null) {
      button = Tooltip(
        message: widget.tooltip!,
        child: button,
      );
    }

    return Semantics(
      button: true,
      enabled: !isDisabled,
      label: widget.tooltip,
      child: button,
    );
  }

  BoxDecoration _getDecoration(Color color, bool isDisabled) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (widget.variant) {
      case AppButtonVariant.filled:
        return BoxDecoration(
          color: isDisabled
              ? colorScheme.surfaceContainerLow
              : widget.backgroundColor ?? color,
          shape: BoxShape.circle,
        );

      case AppButtonVariant.outlined:
        return BoxDecoration(
          color: _isHovered ? color.withValues(alpha: 0.05) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isDisabled ? colorScheme.outlineVariant : color,
            width: 1.5,
          ),
        );

      case AppButtonVariant.ghost:
        return BoxDecoration(
          color: _isHovered ? colorScheme.surfaceContainerLow : Colors.transparent,
          shape: BoxShape.circle,
        );

      case AppButtonVariant.soft:
        return BoxDecoration(
          color: isDisabled
              ? colorScheme.surfaceContainerLow
              : _isHovered
                  ? color.withValues(alpha: 0.15)
                  : color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        );
    }
  }
}
