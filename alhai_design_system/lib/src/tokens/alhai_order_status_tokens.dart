import 'package:flutter/material.dart';

/// Order status color tokens
/// 
/// Provides status-specific colors derived from ColorScheme
/// but abstracted for design system consistency
abstract final class AlhaiOrderStatusTokens {
  /// Get status colors from ThemeData
  static AlhaiOrderStatusColors of(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlhaiOrderStatusColors.fromColorScheme(colorScheme);
  }
}

/// Status-specific color set
class AlhaiOrderStatusColors {
  final Color newBackground;
  final Color newForeground;
  final Color acceptedBackground;
  final Color acceptedForeground;
  final Color preparingBackground;
  final Color preparingForeground;
  final Color deliveringBackground;
  final Color deliveringForeground;
  final Color deliveredBackground;
  final Color deliveredForeground;
  final Color cancelledBackground;
  final Color cancelledForeground;
  final Color activeIndicator;
  final Color inactiveIndicator;
  final Color activeOnIndicator;
  final Color textActive;
  final Color textInactive;
  final Color textMeta;

  const AlhaiOrderStatusColors({
    required this.newBackground,
    required this.newForeground,
    required this.acceptedBackground,
    required this.acceptedForeground,
    required this.preparingBackground,
    required this.preparingForeground,
    required this.deliveringBackground,
    required this.deliveringForeground,
    required this.deliveredBackground,
    required this.deliveredForeground,
    required this.cancelledBackground,
    required this.cancelledForeground,
    required this.activeIndicator,
    required this.inactiveIndicator,
    required this.activeOnIndicator,
    required this.textActive,
    required this.textInactive,
    required this.textMeta,
  });

  /// Create from ColorScheme
  factory AlhaiOrderStatusColors.fromColorScheme(ColorScheme colorScheme) {
    return AlhaiOrderStatusColors(
      newBackground: colorScheme.primaryContainer,
      newForeground: colorScheme.onPrimaryContainer,
      acceptedBackground: colorScheme.secondaryContainer,
      acceptedForeground: colorScheme.onSecondaryContainer,
      preparingBackground: colorScheme.tertiaryContainer,
      preparingForeground: colorScheme.onTertiaryContainer,
      deliveringBackground: colorScheme.primaryContainer,
      deliveringForeground: colorScheme.onPrimaryContainer,
      deliveredBackground: colorScheme.primaryContainer,
      deliveredForeground: colorScheme.primary,
      cancelledBackground: colorScheme.errorContainer,
      cancelledForeground: colorScheme.onErrorContainer,
      activeIndicator: colorScheme.primary,
      inactiveIndicator: colorScheme.outlineVariant,
      activeOnIndicator: colorScheme.onPrimary,
      textActive: colorScheme.onSurface,
      textInactive: colorScheme.onSurfaceVariant,
      textMeta: colorScheme.onSurfaceVariant,
    );
  }

  /// Get background color for status
  Color backgroundFor(AlhaiOrderStatus status) {
    switch (status) {
      case AlhaiOrderStatus.new_:
        return newBackground;
      case AlhaiOrderStatus.accepted:
        return acceptedBackground;
      case AlhaiOrderStatus.preparing:
        return preparingBackground;
      case AlhaiOrderStatus.delivering:
        return deliveringBackground;
      case AlhaiOrderStatus.delivered:
        return deliveredBackground;
      case AlhaiOrderStatus.cancelled:
        return cancelledBackground;
    }
  }

  /// Get foreground color for status
  Color foregroundFor(AlhaiOrderStatus status) {
    switch (status) {
      case AlhaiOrderStatus.new_:
        return newForeground;
      case AlhaiOrderStatus.accepted:
        return acceptedForeground;
      case AlhaiOrderStatus.preparing:
        return preparingForeground;
      case AlhaiOrderStatus.delivering:
        return deliveringForeground;
      case AlhaiOrderStatus.delivered:
        return deliveredForeground;
      case AlhaiOrderStatus.cancelled:
        return cancelledForeground;
    }
  }
}

/// Order status states
enum AlhaiOrderStatus {
  /// New order, not yet processed
  new_,

  /// Order accepted by merchant
  accepted,

  /// Order being prepared
  preparing,

  /// Order out for delivery
  delivering,

  /// Order delivered successfully
  delivered,

  /// Order cancelled
  cancelled,
}

/// Extension to get status properties
extension AlhaiOrderStatusExtension on AlhaiOrderStatus {
  /// Get the status index for progression (cancelled is special)
  int get progressIndex {
    switch (this) {
      case AlhaiOrderStatus.new_:
        return 0;
      case AlhaiOrderStatus.accepted:
        return 1;
      case AlhaiOrderStatus.preparing:
        return 2;
      case AlhaiOrderStatus.delivering:
        return 3;
      case AlhaiOrderStatus.delivered:
        return 4;
      case AlhaiOrderStatus.cancelled:
        return -1; // Special case
    }
  }

  /// Default icon for status
  IconData get defaultIcon {
    switch (this) {
      case AlhaiOrderStatus.new_:
        return Icons.receipt_outlined;
      case AlhaiOrderStatus.accepted:
        return Icons.check_circle_outline;
      case AlhaiOrderStatus.preparing:
        return Icons.restaurant_outlined;
      case AlhaiOrderStatus.delivering:
        return Icons.delivery_dining_outlined;
      case AlhaiOrderStatus.delivered:
        return Icons.done_all_rounded;
      case AlhaiOrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
