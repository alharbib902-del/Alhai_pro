import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_durations.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// Tab bar variant
enum AlhaiTabBarVariant {
  /// Fixed width tabs (distributed equally)
  fixed,

  /// Scrollable tabs (natural width)
  scrollable,
}

/// Tab item data model
class AlhaiTabBarItem {
  /// Tab label text
  final String label;

  /// Optional subtitle (secondary line)
  final String? subtitle;

  /// Optional icon
  final IconData? icon;

  /// Badge text (e.g., "3", "99+")
  final String? badge;

  /// Show badge dot only
  final bool showBadgeDot;

  /// Whether tab is enabled
  final bool enabled;

  const AlhaiTabBarItem({
    required this.label,
    this.subtitle,
    this.icon,
    this.badge,
    this.showBadgeDot = false,
    this.enabled = true,
  });
}

/// AlhaiTabBar - Enhanced TabBar with badges, subtitles, leading/trailing
/// 
/// Features:
/// - Fixed and scrollable modes
/// - Optional leading/trailing widgets
/// - Badge support (dot or text)
/// - Optional subtitle per tab
/// - Animated indicator (token-based)
/// - RTL-safe layout
/// - Dark mode support
class AlhaiTabBar extends StatelessWidget {
  /// Tab items
  final List<AlhaiTabBarItem> tabs;

  /// Currently selected index
  final int currentIndex;

  /// Index change callback
  final ValueChanged<int>? onChanged;

  /// Tab bar variant
  final AlhaiTabBarVariant variant;

  /// Leading widget (e.g., filter icon)
  final Widget? leading;

  /// Trailing widget (e.g., actions)
  final Widget? trailing;

  /// Show divider below tab bar
  final bool showDivider;

  /// Use filled/segmented style
  final bool filled;

  const AlhaiTabBar({
    super.key,
    required this.tabs,
    required this.currentIndex,
    this.onChanged,
    this.variant = AlhaiTabBarVariant.fixed,
    this.leading,
    this.trailing,
    this.showDivider = true,
    this.filled = false,
  }) : assert(tabs.length > 0, 'AlhaiTabBar requires at least one tab'),
       assert(currentIndex >= 0 && currentIndex < tabs.length,
           'currentIndex must be within tabs range');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tab bar row
        Container(
          color: colorScheme.surface,
          child: Row(
            textDirection: textDirection,
            children: [
              // Leading
              if (leading != null) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: AlhaiSpacing.md,
                  ),
                  child: leading,
                ),
              ],

              // Tabs
              Expanded(
                child: _buildTabsRow(theme, colorScheme, textDirection),
              ),

              // Trailing
              if (trailing != null) ...[
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: AlhaiSpacing.md,
                  ),
                  child: trailing,
                ),
              ],
            ],
          ),
        ),

        // Divider
        if (showDivider)
          Container(
            height: AlhaiSpacing.strokeXs,
            color: colorScheme.outlineVariant,
          ),
      ],
    );
  }

  Widget _buildTabsRow(
    ThemeData theme,
    ColorScheme colorScheme,
    TextDirection textDirection,
  ) {
    if (filled) {
      return _buildFilledTabs(theme, colorScheme, textDirection);
    }
    return _buildUnderlineTabs(theme, colorScheme, textDirection);
  }

  Widget _buildUnderlineTabs(
    ThemeData theme,
    ColorScheme colorScheme,
    TextDirection textDirection,
  ) {
    final isScrollable = variant == AlhaiTabBarVariant.scrollable;

    if (isScrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AlhaiSpacing.md,
        ),
        child: Row(
          textDirection: textDirection,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < tabs.length; i++)
              _TabItem(
                item: tabs[i],
                isSelected: i == currentIndex,
                onTap: tabs[i].enabled && onChanged != null
                    ? () => onChanged!(i)
                    : null,
                theme: theme,
                colorScheme: colorScheme,
                textDirection: textDirection,
                filled: false,
              ),
          ],
        ),
      );
    }

    // Fixed tabs
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AlhaiSpacing.md,
      ),
      child: Row(
        textDirection: textDirection,
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: _TabItem(
                item: tabs[i],
                isSelected: i == currentIndex,
                onTap: tabs[i].enabled && onChanged != null
                    ? () => onChanged!(i)
                    : null,
                theme: theme,
                colorScheme: colorScheme,
                textDirection: textDirection,
                filled: false,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilledTabs(
    ThemeData theme,
    ColorScheme colorScheme,
    TextDirection textDirection,
  ) {
    final isScrollable = variant == AlhaiTabBarVariant.scrollable;

    Widget tabsContent;

    if (isScrollable) {
      tabsContent = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          textDirection: textDirection,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < tabs.length; i++)
              _TabItem(
                item: tabs[i],
                isSelected: i == currentIndex,
                onTap: tabs[i].enabled && onChanged != null
                    ? () => onChanged!(i)
                    : null,
                theme: theme,
                colorScheme: colorScheme,
                textDirection: textDirection,
                filled: true,
              ),
          ],
        ),
      );
    } else {
      tabsContent = Row(
        textDirection: textDirection,
        children: [
          for (int i = 0; i < tabs.length; i++)
            Expanded(
              child: _TabItem(
                item: tabs[i],
                isSelected: i == currentIndex,
                onTap: tabs[i].enabled && onChanged != null
                    ? () => onChanged!(i)
                    : null,
                theme: theme,
                colorScheme: colorScheme,
                textDirection: textDirection,
                filled: true,
              ),
            ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AlhaiSpacing.xxs),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AlhaiRadius.md),
        ),
        child: tabsContent,
      ),
    );
  }
}

/// Internal tab item widget
class _TabItem extends StatelessWidget {
  final AlhaiTabBarItem item;
  final bool isSelected;
  final VoidCallback? onTap;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final TextDirection textDirection;
  final bool filled;

  const _TabItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
    required this.colorScheme,
    required this.textDirection,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = !item.enabled;
    final labelColor = isDisabled
        ? colorScheme.onSurfaceVariant.withValues(alpha: AlhaiColors.disabledOpacity)
        : isSelected
            ? (filled ? colorScheme.onSecondaryContainer : colorScheme.primary)
            : colorScheme.onSurfaceVariant;

    return Semantics(
      label: item.label,
      button: onTap != null,
      enabled: onTap != null,
      selected: isSelected,
      child: AnimatedContainer(
        duration: AlhaiDurations.fast,
        decoration: filled
            ? BoxDecoration(
                color: isSelected ? colorScheme.secondaryContainer : AlhaiColors.transparent,
                borderRadius: BorderRadius.circular(AlhaiRadius.sm),
              )
            : null,
        child: Material(
          color: AlhaiColors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AlhaiRadius.sm),
            child: Container(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: filled ? AlhaiSpacing.sm : AlhaiSpacing.md,
              ),
              decoration: !filled
                  ? BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected ? colorScheme.primary : AlhaiColors.transparent,
                          width: AlhaiSpacing.strokeSm,
                        ),
                      ),
                    )
                  : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Main row (icon + label + badge)
                  _buildMainRow(labelColor),

                  // Subtitle
                  if (item.subtitle != null) ...[
                    const SizedBox(height: AlhaiSpacing.xxxs),
                    Text(
                      item.subtitle!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: textDirection,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainRow(Color labelColor) {
    final List<Widget> children = [];

    // Icon
    if (item.icon != null) {
      children.add(Icon(
        item.icon,
        size: AlhaiSpacing.lg,
        color: labelColor,
      ));
      children.add(const SizedBox(width: AlhaiSpacing.xs));
    }

    // Label
    children.add(
      Flexible(
        child: Text(
          item.label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: labelColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textDirection: textDirection,
        ),
      ),
    );

    // Badge
    if (item.showBadgeDot || (item.badge != null && item.badge!.isNotEmpty)) {
      children.add(const SizedBox(width: AlhaiSpacing.xs));
      children.add(_buildBadge());
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      textDirection: textDirection,
      children: children,
    );
  }

  Widget _buildBadge() {
    // Dot badge
    if (item.showBadgeDot) {
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
    final content = item.badge!;
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
          content.length > 2 ? '99+' : content,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onError,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
