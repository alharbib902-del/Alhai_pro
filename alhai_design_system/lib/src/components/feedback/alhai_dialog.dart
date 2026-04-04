import 'package:flutter/material.dart';

import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';
import '../../theme/theme_extensions.dart';
import '../buttons/alhai_button.dart';

/// Dialog icon type for styling
enum AlhaiDialogIconType {
  /// No icon
  none,

  /// Info icon (primary color)
  info,

  /// Warning/destructive icon (error color)
  warning,

  /// Success icon (success color)
  success,
}

/// AlhaiDialog - Unified dialog system with consistent layout and actions
class AlhaiDialog extends StatelessWidget {
  /// Dialog title
  final String title;

  /// Optional message text
  final String? message;

  /// Optional body widget (takes precedence over message)
  final Widget? body;

  /// Icon type (built in build() with correct context)
  final AlhaiDialogIconType iconType;

  /// Custom icon data (overrides iconType)
  final IconData? customIcon;

  /// Primary action text
  final String primaryText;

  /// Primary action callback
  final VoidCallback? onPrimary;

  /// Secondary action text
  final String? secondaryText;

  /// Secondary action callback
  final VoidCallback? onSecondary;

  /// Show loading state on primary action
  final bool primaryLoading;

  /// Is primary action destructive (red color)
  final bool isDestructive;

  /// Padding override
  final EdgeInsetsGeometry? paddingOverride;

  /// Dialog min width override
  final double? minWidth;

  /// Dialog max width override
  final double? maxWidth;

  const AlhaiDialog({
    super.key,
    required this.title,
    this.message,
    this.body,
    this.iconType = AlhaiDialogIconType.none,
    this.customIcon,
    required this.primaryText,
    this.onPrimary,
    this.secondaryText,
    this.onSecondary,
    this.primaryLoading = false,
    this.isDestructive = false,
    this.paddingOverride,
    this.minWidth,
    this.maxWidth,
  });

  /// Show a dialog
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? body,
    AlhaiDialogIconType iconType = AlhaiDialogIconType.none,
    IconData? customIcon,
    required String primaryText,
    VoidCallback? onPrimary,
    String? secondaryText,
    VoidCallback? onSecondary,
    bool barrierDismissible = true,
    bool primaryLoading = false,
    bool isDestructive = false,
    bool isDismissibleWhileLoading = false,
    EdgeInsetsGeometry? paddingOverride,
    double? minWidth,
    double? maxWidth,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: primaryLoading && !isDismissibleWhileLoading
          ? false
          : barrierDismissible,
      builder: (dialogContext) => AlhaiDialog(
        title: title,
        message: message,
        body: body,
        iconType: iconType,
        customIcon: customIcon,
        primaryText: primaryText,
        onPrimary: onPrimary,
        secondaryText: secondaryText,
        onSecondary: onSecondary,
        primaryLoading: primaryLoading,
        isDestructive: isDestructive,
        paddingOverride: paddingOverride,
        minWidth: minWidth,
        maxWidth: maxWidth,
      ),
    );
  }

  /// Confirmation dialog
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    String? message,
    Widget? body,
    required String confirmText,
    required String cancelText,
    bool barrierDismissible = true,
    bool primaryLoading = false,
  }) {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      body: body,
      primaryText: confirmText,
      onPrimary: () => Navigator.pop(context, true),
      secondaryText: cancelText,
      onSecondary: () => Navigator.pop(context, false),
      barrierDismissible: barrierDismissible,
      primaryLoading: primaryLoading,
    );
  }

  /// Destructive action dialog (delete, remove, etc.)
  static Future<bool?> destructive({
    required BuildContext context,
    required String title,
    String? message,
    Widget? body,
    required String destructText,
    required String cancelText,
    IconData? icon,
    bool barrierDismissible = true,
    bool primaryLoading = false,
  }) {
    return show<bool>(
      context: context,
      title: title,
      message: message,
      body: body,
      iconType: AlhaiDialogIconType.warning,
      customIcon: icon,
      primaryText: destructText,
      onPrimary: () => Navigator.pop(context, true),
      secondaryText: cancelText,
      onSecondary: () => Navigator.pop(context, false),
      barrierDismissible: barrierDismissible,
      primaryLoading: primaryLoading,
      isDestructive: true,
    );
  }

  /// Info/alert dialog
  static Future<void> info({
    required BuildContext context,
    required String title,
    String? message,
    Widget? body,
    required String okText,
    IconData? icon,
    bool barrierDismissible = true,
  }) {
    return show<void>(
      context: context,
      title: title,
      message: message,
      body: body,
      iconType: AlhaiDialogIconType.info,
      customIcon: icon,
      primaryText: okText,
      onPrimary: () => Navigator.pop(context),
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final padding =
        paddingOverride ?? const EdgeInsetsDirectional.all(AlhaiSpacing.lg);

    final effectiveMinWidth = minWidth ?? AlhaiSpacing.dialogMinWidth;
    final effectiveMaxWidth = maxWidth ?? AlhaiSpacing.dialogMaxWidth;

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      child: Material(
        color: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AlhaiRadius.dialog),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: effectiveMinWidth,
            maxWidth: effectiveMaxWidth,
          ),
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon (built here with correct context)
                if (_hasIcon) ...[
                  Center(child: _buildIcon(theme, colorScheme)),
                  const SizedBox(height: AlhaiSpacing.md),
                ],

                // Title
                Text(
                  title,
                  style: theme.textTheme.titleLarge,
                  textAlign: _hasIcon ? TextAlign.center : TextAlign.start,
                ),

                // Message/Body
                if (message != null || body != null) ...[
                  const SizedBox(height: AlhaiSpacing.sm),
                  if (body != null)
                    body!
                  else
                    Text(
                      message!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: _hasIcon ? TextAlign.center : TextAlign.start,
                    ),
                ],

                // Actions
                const SizedBox(height: AlhaiSpacing.lg),
                _buildActions(colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _hasIcon =>
      iconType != AlhaiDialogIconType.none || customIcon != null;

  Widget _buildIcon(ThemeData theme, ColorScheme colorScheme) {
    final iconData = customIcon ?? _getDefaultIcon();
    final iconColor = _getIconColor(theme, colorScheme);

    return Icon(
      iconData,
      size: AlhaiSpacing.iconLg,
      color: iconColor,
    );
  }

  IconData _getDefaultIcon() {
    switch (iconType) {
      case AlhaiDialogIconType.info:
        return Icons.info_outline_rounded;
      case AlhaiDialogIconType.warning:
        return Icons.warning_amber_rounded;
      case AlhaiDialogIconType.success:
        return Icons.check_circle_outline_rounded;
      case AlhaiDialogIconType.none:
        // لن يصل هنا لأن _hasIcon يمنعها
        return Icons.info_outline_rounded;
    }
  }

  Color _getIconColor(ThemeData theme, ColorScheme colorScheme) {
    final statusColors = theme.extension<AlhaiStatusColors>();

    switch (iconType) {
      case AlhaiDialogIconType.info:
        return colorScheme.primary;
      case AlhaiDialogIconType.warning:
        return colorScheme.error;
      case AlhaiDialogIconType.success:
        return statusColors?.success ?? colorScheme.primary;
      case AlhaiDialogIconType.none:
        return colorScheme.onSurfaceVariant;
    }
  }

  Widget _buildActions(ColorScheme colorScheme) {
    // Determine if actions should be disabled during loading
    final actionsDisabled = primaryLoading;

    return Row(
      children: [
        // Secondary action
        if (secondaryText != null) ...[
          Expanded(
            child: AlhaiButton.outlined(
              label: secondaryText!,
              onPressed: actionsDisabled ? null : onSecondary,
              fullWidth: true,
            ),
          ),
          const SizedBox(width: AlhaiSpacing.sm),
        ],

        // Primary action
        Expanded(
          child: AlhaiButton.filled(
            label: primaryText,
            onPressed: actionsDisabled ? null : onPrimary,
            isLoading: primaryLoading,
            fullWidth: true,
            backgroundColor: isDestructive ? colorScheme.error : null,
            foregroundColor: isDestructive ? colorScheme.onError : null,
          ),
        ),
      ],
    );
  }
}
