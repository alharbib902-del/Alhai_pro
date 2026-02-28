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
  final Color createdBackground;
  final Color createdForeground;
  final Color confirmedBackground;
  final Color confirmedForeground;
  final Color preparingBackground;
  final Color preparingForeground;
  final Color readyBackground;
  final Color readyForeground;
  final Color outForDeliveryBackground;
  final Color outForDeliveryForeground;
  final Color deliveredBackground;
  final Color deliveredForeground;
  final Color pickedUpBackground;
  final Color pickedUpForeground;
  final Color completedBackground;
  final Color completedForeground;
  final Color cancelledBackground;
  final Color cancelledForeground;
  final Color refundedBackground;
  final Color refundedForeground;
  final Color activeIndicator;
  final Color inactiveIndicator;
  final Color activeOnIndicator;
  final Color textActive;
  final Color textInactive;
  final Color textMeta;

  const AlhaiOrderStatusColors({
    required this.createdBackground,
    required this.createdForeground,
    required this.confirmedBackground,
    required this.confirmedForeground,
    required this.preparingBackground,
    required this.preparingForeground,
    required this.readyBackground,
    required this.readyForeground,
    required this.outForDeliveryBackground,
    required this.outForDeliveryForeground,
    required this.deliveredBackground,
    required this.deliveredForeground,
    required this.pickedUpBackground,
    required this.pickedUpForeground,
    required this.completedBackground,
    required this.completedForeground,
    required this.cancelledBackground,
    required this.cancelledForeground,
    required this.refundedBackground,
    required this.refundedForeground,
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
      createdBackground: colorScheme.primaryContainer,
      createdForeground: colorScheme.onPrimaryContainer,
      confirmedBackground: colorScheme.secondaryContainer,
      confirmedForeground: colorScheme.onSecondaryContainer,
      preparingBackground: colorScheme.tertiaryContainer,
      preparingForeground: colorScheme.onTertiaryContainer,
      readyBackground: colorScheme.secondaryContainer,
      readyForeground: colorScheme.onSecondaryContainer,
      outForDeliveryBackground: colorScheme.primaryContainer,
      outForDeliveryForeground: colorScheme.onPrimaryContainer,
      deliveredBackground: colorScheme.primaryContainer,
      deliveredForeground: colorScheme.primary,
      pickedUpBackground: colorScheme.primaryContainer,
      pickedUpForeground: colorScheme.primary,
      completedBackground: colorScheme.primaryContainer,
      completedForeground: colorScheme.primary,
      cancelledBackground: colorScheme.errorContainer,
      cancelledForeground: colorScheme.onErrorContainer,
      refundedBackground: colorScheme.errorContainer,
      refundedForeground: colorScheme.onErrorContainer,
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
      case AlhaiOrderStatus.created:
        return createdBackground;
      case AlhaiOrderStatus.confirmed:
        return confirmedBackground;
      case AlhaiOrderStatus.preparing:
        return preparingBackground;
      case AlhaiOrderStatus.ready:
        return readyBackground;
      case AlhaiOrderStatus.outForDelivery:
        return outForDeliveryBackground;
      case AlhaiOrderStatus.delivered:
        return deliveredBackground;
      case AlhaiOrderStatus.pickedUp:
        return pickedUpBackground;
      case AlhaiOrderStatus.completed:
        return completedBackground;
      case AlhaiOrderStatus.cancelled:
        return cancelledBackground;
      case AlhaiOrderStatus.refunded:
        return refundedBackground;
    }
  }

  /// Get foreground color for status
  Color foregroundFor(AlhaiOrderStatus status) {
    switch (status) {
      case AlhaiOrderStatus.created:
        return createdForeground;
      case AlhaiOrderStatus.confirmed:
        return confirmedForeground;
      case AlhaiOrderStatus.preparing:
        return preparingForeground;
      case AlhaiOrderStatus.ready:
        return readyForeground;
      case AlhaiOrderStatus.outForDelivery:
        return outForDeliveryForeground;
      case AlhaiOrderStatus.delivered:
        return deliveredForeground;
      case AlhaiOrderStatus.pickedUp:
        return pickedUpForeground;
      case AlhaiOrderStatus.completed:
        return completedForeground;
      case AlhaiOrderStatus.cancelled:
        return cancelledForeground;
      case AlhaiOrderStatus.refunded:
        return refundedForeground;
    }
  }
}

/// Order status states matching Supabase enum
enum AlhaiOrderStatus {
  /// New order, just created
  created,

  /// Order confirmed by merchant
  confirmed,

  /// Order being prepared
  preparing,

  /// Order ready for pickup or delivery
  ready,

  /// Order out for delivery
  outForDelivery,

  /// Order delivered to customer
  delivered,

  /// Order picked up by customer
  pickedUp,

  /// Order fully completed
  completed,

  /// Order cancelled
  cancelled,

  /// Order refunded
  refunded,
}

/// Extension to get status properties
extension AlhaiOrderStatusExtension on AlhaiOrderStatus {
  /// Get the status index for progression (cancelled/refunded are special)
  int get progressIndex {
    switch (this) {
      case AlhaiOrderStatus.created:
        return 0;
      case AlhaiOrderStatus.confirmed:
        return 1;
      case AlhaiOrderStatus.preparing:
        return 2;
      case AlhaiOrderStatus.ready:
        return 3;
      case AlhaiOrderStatus.outForDelivery:
        return 4;
      case AlhaiOrderStatus.delivered:
        return 5;
      case AlhaiOrderStatus.pickedUp:
        return 5;
      case AlhaiOrderStatus.completed:
        return 6;
      case AlhaiOrderStatus.cancelled:
        return -1; // Special case
      case AlhaiOrderStatus.refunded:
        return -2; // Special case
    }
  }

  /// Default icon for status
  IconData get defaultIcon {
    switch (this) {
      case AlhaiOrderStatus.created:
        return Icons.receipt_outlined;
      case AlhaiOrderStatus.confirmed:
        return Icons.check_circle_outline;
      case AlhaiOrderStatus.preparing:
        return Icons.restaurant_outlined;
      case AlhaiOrderStatus.ready:
        return Icons.inventory_2_outlined;
      case AlhaiOrderStatus.outForDelivery:
        return Icons.delivery_dining_outlined;
      case AlhaiOrderStatus.delivered:
        return Icons.done_all_rounded;
      case AlhaiOrderStatus.pickedUp:
        return Icons.shopping_bag_outlined;
      case AlhaiOrderStatus.completed:
        return Icons.check_circle_rounded;
      case AlhaiOrderStatus.cancelled:
        return Icons.cancel_outlined;
      case AlhaiOrderStatus.refunded:
        return Icons.undo_rounded;
    }
  }
}
