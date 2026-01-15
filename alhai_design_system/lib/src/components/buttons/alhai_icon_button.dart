import 'package:flutter/material.dart';

import '../../tokens/alhai_durations.dart';
import '../../tokens/alhai_motion.dart';
import '../../tokens/alhai_spacing.dart';

/// Alhai Icon Button - Accessible icon button with states
class AlhaiIconButton extends StatefulWidget {
  /// The icon to display
  final IconData icon;

  /// Callback when pressed (null = disabled)
  final VoidCallback? onPressed;

  /// Size of the icon
  final double iconSize;

  /// Size of the touch target (min 48dp for accessibility)
  final double size;

  /// Icon color (null = theme default)
  final Color? color;

  /// Background color (null = transparent)
  final Color? backgroundColor;

  /// Tooltip text for accessibility
  final String? tooltip;

  /// Is loading state
  final bool isLoading;

  /// Badge count (null = no badge)
  final int? badgeCount;

  /// Show badge dot without count
  final bool showBadge;

  const AlhaiIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconSize = 24,
    this.size = AlhaiSpacing.minTouchTarget,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.isLoading = false,
    this.badgeCount,
    this.showBadge = false,
  }) : assert(size >= AlhaiSpacing.minTouchTarget,
            'Icon button size must be at least 48dp for accessibility');

  @override
  State<AlhaiIconButton> createState() => _AlhaiIconButtonState();
}

class _AlhaiIconButtonState extends State<AlhaiIconButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: AlhaiMotion.buttonPress),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;
  bool get _hasBadge =>
      widget.showBadge || (widget.badgeCount != null && widget.badgeCount! > 0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconColor = widget.color ?? colorScheme.onSurface;
    final disabledColor = colorScheme.onSurface.withValues(alpha: 0.38);

    Widget iconButton = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Material(
        color: widget.backgroundColor ?? Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: _isEnabled ? _handlePress : null,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: widget.iconSize,
                      height: widget.iconSize,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: iconColor,
                      ),
                    )
                  : Icon(
                      widget.icon,
                      size: widget.iconSize,
                      color: _isEnabled ? iconColor : disabledColor,
                    ),
            ),
          ),
        ),
      ),
    );

    // Add badge if needed
    if (_hasBadge) {
      iconButton = Stack(
        clipBehavior: Clip.none,
        children: [
          iconButton,
          PositionedDirectional(
            top: 4,
            end: 4,
            child: _buildBadge(colorScheme),
          ),
        ],
      );
    }

    // Wrap with tooltip if provided
    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip!,
        child: iconButton,
      );
    }

    return iconButton;
  }

  Widget _buildBadge(ColorScheme colorScheme) {
    if (widget.badgeCount != null && widget.badgeCount! > 0) {
      final displayCount =
          widget.badgeCount! > 99 ? '99+' : widget.badgeCount.toString();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            displayCount,
            style: TextStyle(
              color: colorScheme.onError,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // Simple dot badge
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: colorScheme.error,
        shape: BoxShape.circle,
      ),
    );
  }

  void _handlePress() {
    _controller.forward().then((_) {
      _controller.reverse();
    });
    widget.onPressed?.call();
  }
}
