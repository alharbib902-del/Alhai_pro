import 'package:flutter/material.dart';

import '../../responsive/context_ext.dart';
import '../../tokens/alhai_durations.dart';
import '../../tokens/alhai_motion.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// Alhai Button variants
enum AlhaiButtonVariant {
  /// Filled button (primary action)
  filled,

  /// Outlined button (secondary action)
  outlined,

  /// Text button (tertiary action)
  text,

  /// Tonal button (medium emphasis)
  tonal,
}

/// Alhai Button sizes
enum AlhaiButtonSize {
  /// Small button
  small,

  /// Medium button (default)
  medium,

  /// Large button
  large,
}

/// Alhai Button - Production-grade button with variants and states
class AlhaiButton extends StatefulWidget {
  /// Button label text
  final String label;

  /// Button variant
  final AlhaiButtonVariant variant;

  /// Button size
  final AlhaiButtonSize size;

  /// Callback when pressed (null = disabled)
  final VoidCallback? onPressed;

  /// Leading icon
  final IconData? leadingIcon;

  /// Trailing icon
  final IconData? trailingIcon;

  /// Is loading state
  final bool isLoading;

  /// Expand to full width
  final bool fullWidth;

  /// Custom background color (overrides variant)
  final Color? backgroundColor;

  /// Custom foreground/text color (overrides variant)
  final Color? foregroundColor;

  const AlhaiButton({
    super.key,
    required this.label,
    this.variant = AlhaiButtonVariant.filled,
    this.size = AlhaiButtonSize.medium,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
  });

  /// Filled button factory
  factory AlhaiButton.filled({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool fullWidth = false,
    AlhaiButtonSize size = AlhaiButtonSize.medium,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return AlhaiButton(
      key: key,
      label: label,
      variant: AlhaiButtonVariant.filled,
      size: size,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );
  }

  /// Outlined button factory
  factory AlhaiButton.outlined({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool fullWidth = false,
    AlhaiButtonSize size = AlhaiButtonSize.medium,
    Color? foregroundColor,
  }) {
    return AlhaiButton(
      key: key,
      label: label,
      variant: AlhaiButtonVariant.outlined,
      size: size,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      foregroundColor: foregroundColor,
    );
  }

  /// Text button factory
  factory AlhaiButton.text({
    Key? key,
    required String label,
    VoidCallback? onPressed,
    IconData? leadingIcon,
    IconData? trailingIcon,
    bool isLoading = false,
    bool fullWidth = false,
    AlhaiButtonSize size = AlhaiButtonSize.medium,
    Color? foregroundColor,
  }) {
    return AlhaiButton(
      key: key,
      label: label,
      variant: AlhaiButtonVariant.text,
      size: size,
      onPressed: onPressed,
      leadingIcon: leadingIcon,
      trailingIcon: trailingIcon,
      isLoading: isLoading,
      fullWidth: fullWidth,
      foregroundColor: foregroundColor,
    );
  }

  @override
  State<AlhaiButton> createState() => _AlhaiButtonState();
}

class _AlhaiButtonState extends State<AlhaiButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AlhaiDurations.quick,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: AlhaiMotion.buttonPress),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration =
        context.prefersReducedMotion ? Duration.zero : AlhaiDurations.quick;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  EdgeInsetsGeometry get _padding {
    switch (widget.size) {
      case AlhaiButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: AlhaiSpacing.xs,
        );
      case AlhaiButtonSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.lg,
          vertical: AlhaiSpacing.sm,
        );
      case AlhaiButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: AlhaiSpacing.xl,
          vertical: AlhaiSpacing.md,
        );
    }
  }

  double get _minHeight {
    switch (widget.size) {
      case AlhaiButtonSize.small:
        return 36;
      case AlhaiButtonSize.medium:
        return AlhaiSpacing.minTouchTarget;
      case AlhaiButtonSize.large:
        return 56;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AlhaiButtonSize.small:
        return 16;
      case AlhaiButtonSize.medium:
        return 20;
      case AlhaiButtonSize.large:
        return 24;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: _buildButton(theme, colorScheme),
    );
  }

  Widget _buildButton(ThemeData theme, ColorScheme colorScheme) {
    final child = _buildContent(colorScheme);

    Widget button;
    switch (widget.variant) {
      case AlhaiButtonVariant.filled:
        button = FilledButton(
          onPressed: _isEnabled ? _handlePress : null,
          style: _getButtonStyle(colorScheme),
          child: child,
        );
        break;
      case AlhaiButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: _isEnabled ? _handlePress : null,
          style: _getButtonStyle(colorScheme),
          child: child,
        );
        break;
      case AlhaiButtonVariant.text:
        button = TextButton(
          onPressed: _isEnabled ? _handlePress : null,
          style: _getButtonStyle(colorScheme),
          child: child,
        );
        break;
      case AlhaiButtonVariant.tonal:
        button = FilledButton.tonal(
          onPressed: _isEnabled ? _handlePress : null,
          style: _getButtonStyle(colorScheme),
          child: child,
        );
        break;
    }

    if (widget.fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildContent(ColorScheme colorScheme) {
    final iconColor = widget.foregroundColor ??
        (widget.variant == AlhaiButtonVariant.filled
            ? colorScheme.onPrimary
            : colorScheme.primary);

    if (widget.isLoading) {
      return SizedBox(
        width: _iconSize,
        height: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: iconColor,
        ),
      );
    }

    final children = <Widget>[];

    if (widget.leadingIcon != null) {
      children.add(Icon(widget.leadingIcon, size: _iconSize, color: iconColor));
      children.add(const SizedBox(width: AlhaiSpacing.xs));
    }

    children.add(Text(widget.label));

    if (widget.trailingIcon != null) {
      children.add(const SizedBox(width: AlhaiSpacing.xs));
      children
          .add(Icon(widget.trailingIcon, size: _iconSize, color: iconColor));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  ButtonStyle _getButtonStyle(ColorScheme colorScheme) {
    return ButtonStyle(
      padding: WidgetStateProperty.all(_padding),
      minimumSize: WidgetStateProperty.all(Size(88, _minHeight)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.button),
        ),
      ),
      backgroundColor: widget.backgroundColor != null
          ? WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return widget.backgroundColor!.withValues(alpha: 0.38);
              }
              return widget.backgroundColor;
            })
          : null,
      foregroundColor: widget.foregroundColor != null
          ? WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.disabled)) {
                return widget.foregroundColor!.withValues(alpha: 0.38);
              }
              return widget.foregroundColor;
            })
          : null,
    );
  }

  void _handlePress() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onPressed?.call();
  }
}
