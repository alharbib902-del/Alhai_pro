import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// Tab item data model
class AlhaiTabItem {
  /// Tab label text
  final String label;

  /// Optional icon
  final Widget? icon;

  /// Optional badge (e.g., notification count)
  final Widget? badge;

  const AlhaiTabItem({
    required this.label,
    this.icon,
    this.badge,
  });
}

/// AlhaiTabs - Standardized Tabs component (TabBar + TabBarView)
class AlhaiTabs extends StatelessWidget {
  /// Tab items
  final List<AlhaiTabItem> tabs;

  /// Tab views (must have same length as tabs)
  final List<Widget> views;

  /// Optional controller (for controlled mode)
  final TabController? controller;

  /// Scrollable tabs
  final bool scrollable;

  /// Filled style (segmented) vs underline
  final bool filled;

  /// Show divider below TabBar
  final bool showDivider;

  /// Tab change callback
  final ValueChanged<int>? onTap;

  /// TabBar padding override
  final EdgeInsetsGeometry? paddingOverride;

  /// Fixed height for TabBarView (use when placed inside ScrollView/unbounded).
  /// When null, Expanded is used (requires bounded parent height).
  final double? viewHeight;

  const AlhaiTabs({
    super.key,
    required this.tabs,
    required this.views,
    this.controller,
    this.scrollable = false,
    this.filled = false,
    this.showDivider = true,
    this.onTap,
    this.paddingOverride,
    this.viewHeight,
  })  : assert(tabs.length == views.length,
            'tabs and views must have same length'),
        assert(tabs.length > 0, 'tabs must not be empty'),
        assert(views.length > 0, 'views must not be empty'),
        assert(controller == null || controller.length == tabs.length,
            'controller.length must match tabs length');

  @override
  Widget build(BuildContext context) {
    // If controller provided, use it directly
    if (controller != null) {
      return _buildContent(context);
    }

    // Otherwise, wrap with DefaultTabController
    return DefaultTabController(
      length: tabs.length,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final tabBarView = TabBarView(
      controller: controller,
      children: views,
    );

    return Column(
      mainAxisSize: viewHeight != null ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // TabBar
        _buildTabBar(context, theme, colorScheme),

        // Divider
        if (showDivider)
          Divider(
            height: AlhaiSpacing.strokeSm,
            thickness: AlhaiSpacing.strokeSm,
            color: colorScheme.outlineVariant,
          ),

        // TabBarView — SizedBox when viewHeight set (for unbounded parents),
        // Expanded otherwise (for bounded parents)
        if (viewHeight != null)
          SizedBox(height: viewHeight, child: tabBarView)
        else
          Expanded(child: tabBarView),
      ],
    );
  }

  Widget _buildTabBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final textDirection = Directionality.of(context);
    final effectivePadding = paddingOverride ??
        const EdgeInsetsDirectional.symmetric(horizontal: AlhaiSpacing.md);

    // Build tabs
    final tabWidgets = tabs.map((item) => _buildTab(item, theme)).toList();

    Widget tabBar;

    if (filled) {
      // Segmented/Filled style
      tabBar = Container(
        padding: effectivePadding,
        child: Material(
          color: colorScheme.surfaceContainerHighest,
          surfaceTintColor: AlhaiColors.transparent,
          borderRadius: BorderRadius.circular(AlhaiRadius.md),
          clipBehavior: Clip.antiAlias,
          child: TabBar(
            controller: controller,
            tabs: tabWidgets,
            onTap: onTap,
            isScrollable: scrollable,
            labelPadding: const EdgeInsetsDirectional.symmetric(
              horizontal: AlhaiSpacing.md,
            ),
            indicator: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AlhaiRadius.sm),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: colorScheme.onSecondaryContainer,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.labelLarge,
            unselectedLabelStyle: theme.textTheme.labelLarge,
            dividerHeight: 0,
            splashBorderRadius: BorderRadius.circular(AlhaiRadius.sm),
          ),
        ),
      );
    } else {
      // Underline style (default Material)
      tabBar = Padding(
        padding: effectivePadding,
        child: TabBar(
          controller: controller,
          tabs: tabWidgets,
          onTap: onTap,
          isScrollable: scrollable,
          labelPadding: const EdgeInsetsDirectional.symmetric(
            horizontal: AlhaiSpacing.md,
          ),
          indicatorColor: colorScheme.primary,
          indicatorWeight: AlhaiSpacing.strokeSm,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          labelStyle: theme.textTheme.labelLarge,
          unselectedLabelStyle: theme.textTheme.labelLarge,
          dividerHeight: 0,
        ),
      );
    }

    return Directionality(
      textDirection: textDirection,
      child: tabBar,
    );
  }

  Widget _buildTab(AlhaiTabItem item, ThemeData theme) {
    // Build tab content
    Widget content;

    if (item.icon != null) {
      // Icon + label
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          item.icon!,
          const SizedBox(width: AlhaiSpacing.xs),
          Text(item.label),
          if (item.badge != null) ...[
            const SizedBox(width: AlhaiSpacing.xs),
            item.badge!,
          ],
        ],
      );
    } else if (item.badge != null) {
      // Label + badge
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(item.label),
          const SizedBox(width: AlhaiSpacing.xs),
          item.badge!,
        ],
      );
    } else {
      // Label only
      content = Text(item.label);
    }

    return Tab(
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          vertical: AlhaiSpacing.sm,
        ),
        child: content,
      ),
    );
  }
}
