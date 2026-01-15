import 'package:flutter/material.dart';

import '../../tokens/alhai_spacing.dart';
import '../buttons/alhai_button.dart';

/// View state types
enum AlhaiViewState {
  /// Loading state with spinner
  loading,

  /// Empty state (no data)
  empty,

  /// Error state
  error,

  /// Offline/no connection state
  offline,
}

/// AlhaiStateView - Single widget to render page states consistently
class AlhaiStateView extends StatelessWidget {
  /// Current view state
  final AlhaiViewState state;

  /// Optional title
  final String? title;

  /// Optional message/description
  final String? message;

  /// Optional custom icon (overrides default)
  final Widget? icon;

  /// Optional action button text
  final String? actionText;

  /// Optional action callback
  final VoidCallback? onAction;

  /// Custom content (overrides default layout)
  final Widget? customContent;

  /// Content alignment (RTL-safe)
  final AlignmentGeometry alignment;

  /// Padding override
  final EdgeInsetsGeometry? padding;

  const AlhaiStateView({
    super.key,
    required this.state,
    this.title,
    this.message,
    this.icon,
    this.actionText,
    this.onAction,
    this.customContent,
    this.alignment = AlignmentDirectional.center,
    this.padding,
  });

  /// Loading state factory
  factory AlhaiStateView.loading({
    Key? key,
    String? title,
    String? message,
    EdgeInsetsGeometry? padding,
  }) {
    return AlhaiStateView(
      key: key,
      state: AlhaiViewState.loading,
      title: title,
      message: message,
      padding: padding,
    );
  }

  /// Empty state factory
  factory AlhaiStateView.empty({
    Key? key,
    String? title,
    String? message,
    Widget? icon,
    String? actionText,
    VoidCallback? onAction,
    EdgeInsetsGeometry? padding,
  }) {
    return AlhaiStateView(
      key: key,
      state: AlhaiViewState.empty,
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      padding: padding,
    );
  }

  /// Error state factory
  factory AlhaiStateView.error({
    Key? key,
    String? title,
    String? message,
    Widget? icon,
    String? actionText,
    VoidCallback? onAction,
    EdgeInsetsGeometry? padding,
  }) {
    return AlhaiStateView(
      key: key,
      state: AlhaiViewState.error,
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      padding: padding,
    );
  }

  /// Offline state factory
  factory AlhaiStateView.offline({
    Key? key,
    String? title,
    String? message,
    Widget? icon,
    String? actionText,
    VoidCallback? onAction,
    EdgeInsetsGeometry? padding,
  }) {
    return AlhaiStateView(
      key: key,
      state: AlhaiViewState.offline,
      title: title,
      message: message,
      icon: icon,
      actionText: actionText,
      onAction: onAction,
      padding: padding,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final effectivePadding = padding ??
        const EdgeInsetsDirectional.all(AlhaiSpacing.lg);

    // If custom content provided, use it
    if (customContent != null) {
      return Padding(
        padding: effectivePadding,
        child: Align(
          alignment: alignment,
          child: customContent,
        ),
      );
    }

    // Build default layout based on state
    Widget content;
    if (state == AlhaiViewState.loading) {
      content = _buildLoadingContent(theme, colorScheme);
    } else {
      content = _buildStateContent(theme, colorScheme);
    }

    return Padding(
      padding: effectivePadding,
      child: Align(
        alignment: alignment,
        child: content,
      ),
    );
  }

  Widget _buildLoadingContent(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: AlhaiSpacing.iconLg,
          height: AlhaiSpacing.iconLg,
          child: CircularProgressIndicator(
            strokeWidth: AlhaiSpacing.strokeSm,
            color: colorScheme.primary,
          ),
        ),
        if (title != null || message != null) ...[
          const SizedBox(height: AlhaiSpacing.lg),
          if (title != null)
            Text(
              title!,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          if (message != null) ...[
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildStateContent(ThemeData theme, ColorScheme colorScheme) {
    final defaultIcon = _getDefaultIcon(colorScheme);
    final effectiveIcon = icon ?? defaultIcon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Icon
        effectiveIcon,

        // Title
        if (title != null) ...[
          const SizedBox(height: AlhaiSpacing.md),
          Text(
            title!,
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ],

        // Message
        if (message != null) ...[
          const SizedBox(height: AlhaiSpacing.xs),
          Text(
            message!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],

        // Action button
        if (actionText != null && onAction != null) ...[
          const SizedBox(height: AlhaiSpacing.lg),
          AlhaiButton.filled(
            label: actionText!,
            onPressed: onAction,
          ),
        ],
      ],
    );
  }

  Widget _getDefaultIcon(ColorScheme colorScheme) {
    switch (state) {
      case AlhaiViewState.loading:
        // لن يُستخدم هنا (loading له layout خاص)
        return const SizedBox.shrink();

      case AlhaiViewState.empty:
        return Icon(
          Icons.inbox_outlined,
          size: AlhaiSpacing.massive,
          color: colorScheme.onSurfaceVariant,
        );

      case AlhaiViewState.error:
        return Icon(
          Icons.error_outline_rounded,
          size: AlhaiSpacing.massive,
          color: colorScheme.error,
        );

      case AlhaiViewState.offline:
        return Icon(
          Icons.wifi_off_rounded,
          size: AlhaiSpacing.massive,
          color: colorScheme.onSurfaceVariant,
        );
    }
  }
}
