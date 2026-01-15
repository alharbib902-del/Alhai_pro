import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_durations.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// Navigation item for AlhaiBottomNavBar
class AlhaiBottomNavItem {
  /// Icon when item is not selected
  final IconData icon;

  /// Icon when item is selected (defaults to icon)
  final IconData? activeIcon;

  /// Label text
  final String label;

  /// Badge content (string or number)
  final String? badge;

  /// Show badge dot only (ignores badge content)
  final bool showBadgeDot;

  const AlhaiBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
    this.showBadgeDot = false,
  });
}

/// AlhaiBottomNavBar - Bottom navigation bar for main navigation
/// 
/// Features:
/// - 2-5 navigation items
/// - Icons with labels
/// - Badge support (text/number/dot)
/// - Active indicator
/// - RTL-safe order
/// - Material ripple
/// - Dark mode support
class AlhaiBottomNavBar extends StatelessWidget {
  /// Navigation items (2-5 items)
  final List<AlhaiBottomNavItem> items;

  /// Currently selected index
  final int currentIndex;

  /// Callback when item is tapped
  final ValueChanged<int>? onTap;

  /// Whether navigation is enabled
  final bool enabled;

  /// Background color override
  final Color? backgroundColor;

  const AlhaiBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onTap,
    this.enabled = true,
    this.backgroundColor,
  }) : assert(items.length >= 2 && items.length <= 5,
           'AlhaiBottomNavBar requires 2-5 items');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: AlhaiSpacing.strokeXs,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: AlhaiSpacing.bottomNavHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: _NavItem(
                    item: items[i],
                    isSelected: i == currentIndex,
                    onTap: enabled && onTap != null ? () => onTap!(i) : null,
                    theme: theme,
                    colorScheme: colorScheme,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Internal nav item widget
class _NavItem extends StatelessWidget {
  final AlhaiBottomNavItem item;
  final bool isSelected;
  final VoidCallback? onTap;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _NavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIcon = isSelected ? (item.activeIcon ?? item.icon) : item.icon;
    final iconColor = isSelected 
        ? colorScheme.primary 
        : colorScheme.onSurfaceVariant;
    final labelColor = isSelected 
        ? colorScheme.primary 
        : colorScheme.onSurfaceVariant;

    return Semantics(
      label: item.label,
      button: true,
      enabled: onTap != null,
      selected: isSelected,
      child: Material(
        color: AlhaiColors.transparent,
        child: InkWell(
          onTap: onTap,
          splashColor: colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: colorScheme.primary.withValues(alpha: 0.08),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AlhaiSpacing.xs,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon with indicator and badge
                _buildIconWithBadge(effectiveIcon, iconColor),

                const SizedBox(height: AlhaiSpacing.xxs),

                // Label
                AnimatedDefaultTextStyle(
                  duration: AlhaiDurations.fast,
                  style: theme.textTheme.labelSmall!.copyWith(
                    color: labelColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithBadge(IconData icon, Color iconColor) {
    // Icon with active indicator
    Widget iconWidget = AnimatedContainer(
      duration: AlhaiDurations.fast,
      padding: EdgeInsets.symmetric(
        horizontal: isSelected ? AlhaiSpacing.md : AlhaiSpacing.sm,
        vertical: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isSelected ? colorScheme.primaryContainer : AlhaiColors.transparent,
        borderRadius: BorderRadius.circular(AlhaiRadius.full),
      ),
      child: Icon(
        icon,
        size: AlhaiSpacing.lg,
        color: isSelected ? colorScheme.onPrimaryContainer : iconColor,
      ),
    );

    // Add badge if needed
    if (item.showBadgeDot || (item.badge != null && item.badge!.isNotEmpty)) {
      return Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          PositionedDirectional(
            top: 0,
            end: isSelected ? AlhaiSpacing.xs : 0,
            child: _Badge(
              content: item.showBadgeDot ? null : item.badge,
              colorScheme: colorScheme,
            ),
          ),
        ],
      );
    }

    return iconWidget;
  }
}

/// Internal badge widget
class _Badge extends StatelessWidget {
  final String? content;
  final ColorScheme colorScheme;

  const _Badge({
    required this.content,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    // Dot badge
    if (content == null) {
      return Container(
        width: AlhaiSpacing.xs,
        height: AlhaiSpacing.xs,
        decoration: BoxDecoration(
          color: colorScheme.error,
          shape: BoxShape.circle,
        ),
      );
    }

    // Content badge
    return Container(
      constraints: const BoxConstraints(
        minWidth: AlhaiSpacing.md,
        minHeight: AlhaiSpacing.md,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(AlhaiRadius.full),
      ),
      child: Center(
        child: Text(
          content!.length > 2 ? '99+' : content!,
          style: TextStyle(
            color: colorScheme.onError,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            height: 1,
          ),
        ),
      ),
    );
  }
}
