import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// List tile variant
enum AlhaiListTileVariant {
  /// Standard height (56dp min)
  standard,

  /// Compact height (44dp min)
  compact,
}

/// AlhaiListTile - Standardized list row component
class AlhaiListTile extends StatelessWidget {
  /// Title widget (required)
  final Widget title;

  /// Optional subtitle
  final Widget? subtitle;

  /// Optional leading widget
  final Widget? leading;

  /// Optional trailing widget
  final Widget? trailing;

  /// Tap callback
  final VoidCallback? onTap;

  /// Long press callback
  final VoidCallback? onLongPress;

  /// Tile variant
  final AlhaiListTileVariant variant;

  /// Is selected state
  final bool selected;

  /// Is disabled state
  final bool disabled;

  /// Padding override
  final EdgeInsetsGeometry? paddingOverride;

  /// Background color override
  final Color? backgroundColorOverride;

  /// Border radius override
  final BorderRadius? borderRadiusOverride;

  const AlhaiListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.variant = AlhaiListTileVariant.standard,
    this.selected = false,
    this.disabled = false,
    this.paddingOverride,
    this.backgroundColorOverride,
    this.borderRadiusOverride,
  });

  /// Standard list tile factory
  factory AlhaiListTile.standard({
    Key? key,
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool selected = false,
    bool disabled = false,
    EdgeInsetsGeometry? paddingOverride,
    Color? backgroundColorOverride,
    BorderRadius? borderRadiusOverride,
  }) {
    return AlhaiListTile(
      key: key,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      variant: AlhaiListTileVariant.standard,
      selected: selected,
      disabled: disabled,
      paddingOverride: paddingOverride,
      backgroundColorOverride: backgroundColorOverride,
      borderRadiusOverride: borderRadiusOverride,
    );
  }

  /// Compact list tile factory
  factory AlhaiListTile.compact({
    Key? key,
    required Widget title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
    bool selected = false,
    bool disabled = false,
    EdgeInsetsGeometry? paddingOverride,
    Color? backgroundColorOverride,
    BorderRadius? borderRadiusOverride,
  }) {
    return AlhaiListTile(
      key: key,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      onTap: onTap,
      onLongPress: onLongPress,
      variant: AlhaiListTileVariant.compact,
      selected: selected,
      disabled: disabled,
      paddingOverride: paddingOverride,
      backgroundColorOverride: backgroundColorOverride,
      borderRadiusOverride: borderRadiusOverride,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);

    // Calculate dimensions based on variant
    final minHeight = variant == AlhaiListTileVariant.compact
        ? AlhaiSpacing.listTileCompactMinHeight
        : AlhaiSpacing.listTileMinHeight;

    final verticalPadding = variant == AlhaiListTileVariant.compact
        ? AlhaiSpacing.xs
        : AlhaiSpacing.sm;

    // Padding
    final effectivePadding =
        paddingOverride ??
        EdgeInsetsDirectional.symmetric(
          horizontal: AlhaiSpacing.md,
          vertical: verticalPadding,
        );

    // Border radius
    final effectiveRadius =
        borderRadiusOverride ?? BorderRadius.circular(AlhaiRadius.sm);

    // Background color
    Color backgroundColor;
    if (backgroundColorOverride != null) {
      backgroundColor = backgroundColorOverride!;
    } else if (selected) {
      backgroundColor = colorScheme.secondaryContainer;
    } else {
      backgroundColor = colorScheme.surface;
    }

    // Opacity for disabled state
    final opacity = disabled ? AlhaiColors.disabledOpacity : 1.0;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: backgroundColor,
        surfaceTintColor: AlhaiColors.transparent,
        borderRadius: effectiveRadius,
        child: InkWell(
          onTap: disabled ? null : onTap,
          onLongPress: disabled ? null : onLongPress,
          borderRadius: effectiveRadius,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: effectivePadding,
              child: Row(
                textDirection: textDirection,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Leading
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: AlhaiSpacing.md),
                  ],

                  // Content (title + subtitle)
                  Expanded(
                    child: Column(
                      textDirection: textDirection,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        DefaultTextStyle.merge(
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: selected
                                ? colorScheme.onSecondaryContainer
                                : colorScheme.onSurface,
                          ),
                          child: title,
                        ),

                        // Subtitle
                        if (subtitle != null) ...[
                          const SizedBox(height: AlhaiSpacing.xxs),
                          DefaultTextStyle.merge(
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: selected
                                  ? colorScheme.onSecondaryContainer
                                  : colorScheme.onSurfaceVariant,
                            ),
                            child: subtitle!,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing
                  if (trailing != null) ...[
                    const SizedBox(width: AlhaiSpacing.sm),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
