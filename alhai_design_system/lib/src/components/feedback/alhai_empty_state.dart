import 'package:flutter/material.dart';

import '../../tokens/alhai_spacing.dart';

/// Alhai Empty State - Placeholder for empty content
class AlhaiEmptyState extends StatelessWidget {
  /// Icon to display
  final IconData icon;

  /// Title text
  final String title;

  /// Description text (optional)
  final String? description;

  /// Action button text (optional)
  final String? actionText;

  /// Action callback (optional)
  final VoidCallback? onAction;

  /// Icon size
  final double iconSize;

  /// Icon color (null = theme default)
  final Color? iconColor;

  /// Compact mode (smaller spacing)
  final bool compact;

  const AlhaiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionText,
    this.onAction,
    this.iconSize = 64,
    this.iconColor,
    this.compact = false,
  });

  /// Common empty states
  factory AlhaiEmptyState.noData({
    Key? key,
    required String title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return AlhaiEmptyState(
      key: key,
      icon: Icons.inbox_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
    );
  }

  factory AlhaiEmptyState.noResults({
    Key? key,
    required String title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
    bool compact = false,
  }) {
    return AlhaiEmptyState(
      key: key,
      icon: Icons.search_off_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
      compact: compact,
    );
  }

  factory AlhaiEmptyState.noOrders({
    Key? key,
    required String title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
    bool compact = false,
  }) {
    return AlhaiEmptyState(
      key: key,
      icon: Icons.receipt_long_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
      compact: compact,
    );
  }

  factory AlhaiEmptyState.noProducts({
    Key? key,
    required String title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return AlhaiEmptyState(
      key: key,
      icon: Icons.inventory_2_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
    );
  }

  factory AlhaiEmptyState.error({
    Key? key,
    required String title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return AlhaiEmptyState(
      key: key,
      icon: Icons.error_outline,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
    );
  }

  factory AlhaiEmptyState.noConnection({
    Key? key,
    required String title,
    String? description,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return AlhaiEmptyState(
      key: key,
      icon: Icons.wifi_off_outlined,
      title: title,
      description: description,
      actionText: actionText,
      onAction: onAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final spacing = compact ? AlhaiSpacing.sm : AlhaiSpacing.md;

    return Padding(
      padding: EdgeInsets.all(compact ? AlhaiSpacing.md : AlhaiSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            icon,
            size: iconSize,
            color: iconColor ?? colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),

          SizedBox(height: spacing),

          // Title
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),

          // Description
          if (description != null) ...[
            SizedBox(height: compact ? AlhaiSpacing.xxs : AlhaiSpacing.xs),
            Text(
              description!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          // Action button
          if (actionText != null && onAction != null) ...[
            SizedBox(height: spacing * 1.5),
            FilledButton.tonal(
              onPressed: onAction,
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}
