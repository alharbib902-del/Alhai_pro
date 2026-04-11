import 'package:flutter/material.dart';

import '../../tokens/alhai_spacing.dart';

/// Alhai Section - Section container with title and optional actions
class AlhaiSection extends StatelessWidget {
  /// Section title
  final String? title;

  /// Section subtitle
  final String? subtitle;

  /// Section content
  final Widget child;

  /// Trailing widget (e.g., "View all" button)
  final Widget? trailing;

  /// Padding around the section
  final EdgeInsetsGeometry padding;

  /// Spacing between title and content
  final double titleContentSpacing;

  /// Show divider below section
  final bool showDivider;

  /// Title style
  final TextStyle? titleStyle;

  /// Background color
  final Color? backgroundColor;

  const AlhaiSection({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AlhaiSpacing.pagePaddingHorizontal,
      vertical: AlhaiSpacing.md,
    ),
    this.titleContentSpacing = AlhaiSpacing.md,
    this.showDivider = false,
    this.titleStyle,
    this.backgroundColor,
  });

  /// Section with list items
  factory AlhaiSection.list({
    Key? key,
    String? title,
    String? subtitle,
    required List<Widget> children,
    Widget? trailing,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(
      horizontal: AlhaiSpacing.pagePaddingHorizontal,
      vertical: AlhaiSpacing.md,
    ),
    double itemSpacing = AlhaiSpacing.sm,
    bool showDivider = false,
    Color? backgroundColor,
  }) {
    return AlhaiSection(
      key: key,
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      padding: padding,
      showDivider: showDivider,
      backgroundColor: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _addSpacing(children, itemSpacing),
      ),
    );
  }

  static List<Widget> _addSpacing(List<Widget> children, double spacing) {
    if (children.isEmpty) return children;
    final result = <Widget>[];
    for (int i = 0; i < children.length; i++) {
      result.add(children[i]);
      if (i < children.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final direction = Directionality.of(context);

    // حل آمن: resolve padding ثم copyWith
    final resolvedPadding = padding.resolve(direction);
    final headerPadding = resolvedPadding.copyWith(bottom: 0);
    final contentPadding = resolvedPadding.copyWith(top: 0);

    final hasHeader = title != null || trailing != null;

    return Container(
      color: backgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (hasHeader)
            Padding(
              padding: headerPadding,
              child: Row(
                children: [
                  // Title and subtitle
                  if (title != null)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title!,
                            style:
                                titleStyle ??
                                theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: AlhaiSpacing.xxs),
                            Text(
                              subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  else
                    const Spacer(),

                  // Trailing
                  if (trailing != null) trailing!,
                ],
              ),
            ),

          // Spacing between header and content
          if (hasHeader) SizedBox(height: titleContentSpacing),

          // Content
          Padding(padding: contentPadding, child: child),

          // Divider
          if (showDivider)
            Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),
        ],
      ),
    );
  }
}
