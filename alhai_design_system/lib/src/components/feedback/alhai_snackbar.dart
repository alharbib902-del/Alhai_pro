import 'package:flutter/material.dart';

import '../../tokens/alhai_durations.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';
import '../../theme/theme_extensions.dart';

/// Snackbar variant types
enum AlhaiSnackbarVariant {
  /// Default/neutral
  neutral,

  /// Success message
  success,

  /// Warning message
  warning,

  /// Error message
  error,

  /// Info message
  info,
}

/// Alhai Snackbar - Toast/Snackbar component
class AlhaiSnackbar extends StatelessWidget {
  /// Message text
  final String message;

  /// Snackbar variant
  final AlhaiSnackbarVariant variant;

  /// Leading icon (optional, uses variant default if null)
  final IconData? icon;

  /// Action text (optional)
  final String? actionText;

  /// Action callback
  final VoidCallback? onAction;

  /// Close callback
  final VoidCallback? onClose;

  /// Show close button
  final bool showCloseButton;

  const AlhaiSnackbar({
    super.key,
    required this.message,
    this.variant = AlhaiSnackbarVariant.neutral,
    this.icon,
    this.actionText,
    this.onAction,
    this.onClose,
    this.showCloseButton = true,
  });

  /// Show snackbar using ScaffoldMessenger
  static void show(
    BuildContext context, {
    required String message,
    AlhaiSnackbarVariant variant = AlhaiSnackbarVariant.neutral,
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
    Duration? duration,
    bool showCloseButton = true,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: AlhaiSnackbar(
          message: message,
          variant: variant,
          icon: icon,
          actionText: actionText,
          onAction: onAction != null
              ? () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                }
              : null,
          showCloseButton: showCloseButton,
          onClose: messenger.hideCurrentSnackBar,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        duration: duration ?? AlhaiDurations.snackbarVisible,
        padding: EdgeInsets.zero,
      ),
    );
  }

  /// Show success snackbar
  static void success(BuildContext context, String message) {
    show(context, message: message, variant: AlhaiSnackbarVariant.success);
  }

  /// Show error snackbar
  static void error(BuildContext context, String message) {
    show(context, message: message, variant: AlhaiSnackbarVariant.error);
  }

  /// Show warning snackbar
  static void warning(BuildContext context, String message) {
    show(context, message: message, variant: AlhaiSnackbarVariant.warning);
  }

  /// Show info snackbar
  static void info(BuildContext context, String message) {
    show(context, message: message, variant: AlhaiSnackbarVariant.info);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColors = context.statusColors;

    final colors = _getColors(theme.colorScheme, statusColors);
    final effectiveIcon = icon ?? _getDefaultIcon();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AlhaiRadius.sm),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Icon(
            effectiveIcon,
            color: colors.foreground,
            size: 20,
          ),
          const SizedBox(width: AlhaiSpacing.sm),

          // Message
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.foreground,
              ),
            ),
          ),

          // Action
          if (actionText != null && onAction != null) ...[
            const SizedBox(width: AlhaiSpacing.xs),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: colors.foreground,
                padding:
                    const EdgeInsets.symmetric(horizontal: AlhaiSpacing.sm),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(actionText!),
            ),
          ],

          // Close button
          if (showCloseButton && onClose != null) ...[
            const SizedBox(width: AlhaiSpacing.xs),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              color: colors.foreground.withValues(alpha: 0.7),
              onPressed: onClose,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }

  _SnackbarColors _getColors(
      ColorScheme colorScheme, AlhaiStatusColors statusColors) {
    switch (variant) {
      case AlhaiSnackbarVariant.neutral:
        return _SnackbarColors(
          background: colorScheme.inverseSurface,
          foreground: colorScheme.onInverseSurface,
        );
      case AlhaiSnackbarVariant.success:
        return _SnackbarColors(
          background: statusColors.success,
          foreground: statusColors.onSuccess,
        );
      case AlhaiSnackbarVariant.warning:
        return _SnackbarColors(
          background: statusColors.warning,
          foreground: statusColors.onWarning,
        );
      case AlhaiSnackbarVariant.error:
        return _SnackbarColors(
          background: colorScheme.error,
          foreground: colorScheme.onError,
        );
      case AlhaiSnackbarVariant.info:
        return _SnackbarColors(
          background: statusColors.info,
          foreground: statusColors.onInfo,
        );
    }
  }

  IconData _getDefaultIcon() {
    switch (variant) {
      case AlhaiSnackbarVariant.neutral:
        return Icons.info_outline;
      case AlhaiSnackbarVariant.success:
        return Icons.check_circle_outline;
      case AlhaiSnackbarVariant.warning:
        return Icons.warning_amber_outlined;
      case AlhaiSnackbarVariant.error:
        return Icons.error_outline;
      case AlhaiSnackbarVariant.info:
        return Icons.info_outline;
    }
  }
}

class _SnackbarColors {
  final Color background;
  final Color foreground;

  const _SnackbarColors({
    required this.background,
    required this.foreground,
  });
}
