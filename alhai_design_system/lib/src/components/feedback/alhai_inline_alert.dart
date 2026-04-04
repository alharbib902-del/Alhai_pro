import 'package:flutter/material.dart';

import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';
import '../../theme/theme_extensions.dart';

/// Inline alert types
enum AlhaiInlineAlertType {
  /// Success alert (green)
  success,

  /// Info alert (blue/primary)
  info,

  /// Warning alert (amber/orange)
  warning,

  /// Error alert (red)
  error,
}

/// AlhaiInlineAlert - Inline banner alert component for pages
class AlhaiInlineAlert extends StatelessWidget {
  /// Alert type
  final AlhaiInlineAlertType type;

  /// Alert message (required)
  final String message;

  /// Optional title
  final String? title;

  /// Optional action text
  final String? actionText;

  /// Optional action callback
  final VoidCallback? onAction;

  /// Optional close callback (if provided, shows close button)
  final VoidCallback? onClose;

  /// Filled vs outlined style
  final bool filled;

  /// Custom leading icon (overrides default)
  final Widget? leadingIcon;

  /// Padding override
  final EdgeInsetsGeometry? paddingOverride;

  const AlhaiInlineAlert({
    super.key,
    required this.type,
    required this.message,
    this.title,
    this.actionText,
    this.onAction,
    this.onClose,
    this.filled = true,
    this.leadingIcon,
    this.paddingOverride,
  });

  /// Success alert factory
  factory AlhaiInlineAlert.success({
    Key? key,
    required String message,
    String? title,
    String? actionText,
    VoidCallback? onAction,
    VoidCallback? onClose,
    bool filled = true,
    Widget? leadingIcon,
    EdgeInsetsGeometry? paddingOverride,
  }) {
    return AlhaiInlineAlert(
      key: key,
      type: AlhaiInlineAlertType.success,
      message: message,
      title: title,
      actionText: actionText,
      onAction: onAction,
      onClose: onClose,
      filled: filled,
      leadingIcon: leadingIcon,
      paddingOverride: paddingOverride,
    );
  }

  /// Info alert factory
  factory AlhaiInlineAlert.info({
    Key? key,
    required String message,
    String? title,
    String? actionText,
    VoidCallback? onAction,
    VoidCallback? onClose,
    bool filled = true,
    Widget? leadingIcon,
    EdgeInsetsGeometry? paddingOverride,
  }) {
    return AlhaiInlineAlert(
      key: key,
      type: AlhaiInlineAlertType.info,
      message: message,
      title: title,
      actionText: actionText,
      onAction: onAction,
      onClose: onClose,
      filled: filled,
      leadingIcon: leadingIcon,
      paddingOverride: paddingOverride,
    );
  }

  /// Warning alert factory
  factory AlhaiInlineAlert.warning({
    Key? key,
    required String message,
    String? title,
    String? actionText,
    VoidCallback? onAction,
    VoidCallback? onClose,
    bool filled = true,
    Widget? leadingIcon,
    EdgeInsetsGeometry? paddingOverride,
  }) {
    return AlhaiInlineAlert(
      key: key,
      type: AlhaiInlineAlertType.warning,
      message: message,
      title: title,
      actionText: actionText,
      onAction: onAction,
      onClose: onClose,
      filled: filled,
      leadingIcon: leadingIcon,
      paddingOverride: paddingOverride,
    );
  }

  /// Error alert factory
  factory AlhaiInlineAlert.error({
    Key? key,
    required String message,
    String? title,
    String? actionText,
    VoidCallback? onAction,
    VoidCallback? onClose,
    bool filled = true,
    Widget? leadingIcon,
    EdgeInsetsGeometry? paddingOverride,
  }) {
    return AlhaiInlineAlert(
      key: key,
      type: AlhaiInlineAlertType.error,
      message: message,
      title: title,
      actionText: actionText,
      onAction: onAction,
      onClose: onClose,
      filled: filled,
      leadingIcon: leadingIcon,
      paddingOverride: paddingOverride,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statusColors = theme.extension<AlhaiStatusColors>();
    final textDirection = Directionality.of(context);

    final colors = _getColors(colorScheme, statusColors);
    final effectivePadding =
        paddingOverride ?? const EdgeInsetsDirectional.all(AlhaiSpacing.md);

    final effectiveIcon = leadingIcon ?? _buildDefaultIcon(colors);

    return Material(
      color: filled ? colors.background : colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AlhaiRadius.md),
        side: filled
            ? BorderSide.none
            : BorderSide(color: colors.border, width: 1),
      ),
      child: Padding(
        padding: effectivePadding,
        child: Row(
          textDirection: textDirection,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Leading icon
            effectiveIcon,
            const SizedBox(width: AlhaiSpacing.sm),

            // Content
            Expanded(
              child: Column(
                textDirection: textDirection,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  if (title != null) ...[
                    Text(
                      title!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.foreground,
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.xxs),
                  ],

                  // Message
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: filled
                          ? colors.foreground
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),

                  // Action button
                  if (actionText != null && onAction != null) ...[
                    const SizedBox(height: AlhaiSpacing.sm),
                    TextButton(
                      onPressed: onAction,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        actionText!,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.foreground,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Close button
            if (onClose != null) ...[
              const SizedBox(width: AlhaiSpacing.xs),
              IconButton(
                onPressed: onClose,
                icon: Icon(
                  Icons.close,
                  size: AlhaiSpacing.mdl,
                  color: colors.foreground,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
              ),
            ],
          ],
        ),
      ),
    );
  }

  _AlertColors _getColors(
    ColorScheme colorScheme,
    AlhaiStatusColors? statusColors,
  ) {
    switch (type) {
      case AlhaiInlineAlertType.success:
        final successColor = statusColors?.success ?? colorScheme.primary;
        final successLight =
            statusColors?.successLight ?? successColor.withValues(alpha: 0.1);
        return _AlertColors(
          background: successLight,
          foreground: statusColors?.onSuccess ?? successColor,
          border: successColor,
          icon: successColor,
        );

      case AlhaiInlineAlertType.info:
        return _AlertColors(
          background: colorScheme.primaryContainer,
          foreground: colorScheme.onPrimaryContainer,
          border: colorScheme.primary,
          icon: colorScheme.primary,
        );

      case AlhaiInlineAlertType.warning:
        final warningColor = statusColors?.warning ?? colorScheme.tertiary;
        final warningLight =
            statusColors?.warningLight ?? warningColor.withValues(alpha: 0.1);
        return _AlertColors(
          background: warningLight,
          foreground: statusColors?.onWarning ?? warningColor,
          border: warningColor,
          icon: warningColor,
        );

      case AlhaiInlineAlertType.error:
        return _AlertColors(
          background: colorScheme.errorContainer,
          foreground: colorScheme.onErrorContainer,
          border: colorScheme.error,
          icon: colorScheme.error,
        );
    }
  }

  Widget _buildDefaultIcon(_AlertColors colors) {
    IconData iconData;
    switch (type) {
      case AlhaiInlineAlertType.success:
        iconData = Icons.check_circle_outline_rounded;
        break;
      case AlhaiInlineAlertType.info:
        iconData = Icons.info_outline_rounded;
        break;
      case AlhaiInlineAlertType.warning:
        iconData = Icons.warning_amber_rounded;
        break;
      case AlhaiInlineAlertType.error:
        iconData = Icons.error_outline_rounded;
        break;
    }

    return Icon(
      iconData,
      size: AlhaiSpacing.lg,
      color: colors.icon,
    );
  }
}

/// Internal color helper
class _AlertColors {
  final Color background;
  final Color foreground;
  final Color border;
  final Color icon;

  const _AlertColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.icon,
  });
}
