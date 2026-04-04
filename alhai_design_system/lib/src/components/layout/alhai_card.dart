import 'package:flutter/material.dart';

import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// Alhai Card - Styled card component with variants
class AlhaiCard extends StatelessWidget {
  /// Card content
  final Widget child;

  /// Padding inside card
  final EdgeInsetsGeometry? padding;

  /// Card margin
  final EdgeInsetsGeometry? margin;

  /// Card width
  final double? width;

  /// Card height
  final double? height;

  /// Background color (null = theme default)
  final Color? backgroundColor;

  /// Border color (null = theme default)
  final Color? borderColor;

  /// Show border
  final bool showBorder;

  /// Elevation
  final double elevation;

  /// Border radius
  final double borderRadius;

  /// On tap callback
  final VoidCallback? onTap;

  /// On long press callback
  final VoidCallback? onLongPress;

  /// Clip behavior
  final Clip clipBehavior;

  const AlhaiCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderColor,
    this.showBorder = true,
    this.elevation = 0,
    this.borderRadius = AlhaiRadius.card,
    this.onTap,
    this.onLongPress,
    this.clipBehavior = Clip.antiAlias,
  });

  /// Elevated card factory
  factory AlhaiCard.elevated({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? backgroundColor,
    double elevation = 2,
    double borderRadius = AlhaiRadius.card,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return AlhaiCard(
      key: key,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      showBorder: false,
      elevation: elevation,
      borderRadius: borderRadius,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  /// Filled card factory
  factory AlhaiCard.filled({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? backgroundColor,
    double borderRadius = AlhaiRadius.card,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return AlhaiCard(
      key: key,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
      backgroundColor: backgroundColor,
      showBorder: false,
      elevation: 0,
      borderRadius: borderRadius,
      onTap: onTap,
      onLongPress: onLongPress,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = backgroundColor ?? colorScheme.surface;
    final border = showBorder
        ? Border.all(color: borderColor ?? colorScheme.outlineVariant)
        : null;
    final radiusBorder = BorderRadius.circular(borderRadius);

    // Wrap with margin if provided
    Widget wrapWithMargin(Widget content) {
      if (margin != null) {
        return Container(margin: margin, child: content);
      }
      return content;
    }

    // Tappable card - use Material for proper ripple
    if (onTap != null || onLongPress != null) {
      return wrapWithMargin(
        Material(
          color: bgColor,
          clipBehavior: clipBehavior,
          shape: RoundedRectangleBorder(
            borderRadius: radiusBorder,
            side: showBorder
                ? BorderSide(color: borderColor ?? colorScheme.outlineVariant)
                : BorderSide.none,
          ),
          elevation: elevation,
          shadowColor: elevation > 0 ? colorScheme.shadow : null,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: radiusBorder,
            child: Container(
              width: width,
              height: height,
              padding:
                  padding ?? const EdgeInsets.all(AlhaiSpacing.cardPadding),
              child: child,
            ),
          ),
        ),
      );
    }

    // Non-tappable card
    return wrapWithMargin(
      Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(AlhaiSpacing.cardPadding),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: radiusBorder,
          border: border,
          boxShadow: elevation > 0
              ? [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    blurRadius: elevation * 2,
                    offset: Offset(0, elevation),
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    );
  }
}
