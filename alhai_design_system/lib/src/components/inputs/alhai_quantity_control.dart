import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// Size variants for quantity control
enum AlhaiQuantityControlSize {
  /// Compact size (32dp height)
  compact,

  /// Default size (40dp height)
  regular,
}

/// AlhaiQuantityControl - Compact quantity stepper for commerce UI
///
/// Features:
/// - Plus/minus buttons with quantity display
/// - Min/max value support with clamping
/// - Disabled states (whole control or individual buttons)
/// - RTL-safe layout
/// - Dark mode support
class AlhaiQuantityControl extends StatelessWidget {
  /// Current quantity value
  final int quantity;

  /// Called when quantity changes
  final ValueChanged<int>? onChanged;

  /// Minimum allowed value
  final int min;

  /// Maximum allowed value (null = no limit)
  final int? max;

  /// Step increment/decrement value
  final int step;

  /// Whether the control is enabled
  final bool enabled;

  /// Size variant
  final AlhaiQuantityControlSize size;

  /// Custom decrement icon
  final IconData? decrementIcon;

  /// Custom increment icon
  final IconData? incrementIcon;

  /// Semantic label for decrement button
  final String? decrementSemanticLabel;

  /// Semantic label for increment button
  final String? incrementSemanticLabel;

  /// Enable haptic feedback on tap
  final bool hapticsEnabled;

  const AlhaiQuantityControl({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    this.max,
    this.step = 1,
    this.enabled = true,
    this.size = AlhaiQuantityControlSize.regular,
    this.decrementIcon,
    this.incrementIcon,
    this.decrementSemanticLabel,
    this.incrementSemanticLabel,
    this.hapticsEnabled = true,
  })  : assert(min >= 0, 'min must be >= 0'),
        assert(step > 0, 'step must be > 0'),
        assert(max == null || max >= min, 'max must be >= min');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);

    // Clamp quantity to valid range
    final clampedQuantity = _clampQuantity(quantity);

    // Button states - based on actual value change
    final isDisabled = !enabled || onChanged == null;

    final nextDecrementValue = math.max(min, clampedQuantity - step);
    final canDecrement = !isDisabled && nextDecrementValue != clampedQuantity;

    final nextIncrementValue = max == null
        ? clampedQuantity + step
        : math.min(max!, clampedQuantity + step);
    final canIncrement = !isDisabled && nextIncrementValue != clampedQuantity;

    // Sizes - visual size may be smaller but tap target respects accessibility
    final visualSize = size == AlhaiQuantityControlSize.compact
        ? AlhaiSpacing.avatarSm
        : AlhaiSpacing.avatarMd;
    final iconSize = size == AlhaiQuantityControlSize.compact
        ? AlhaiSpacing.avatarIconSm
        : AlhaiSpacing.avatarIconMd;
    // Ensure minimum tap target for accessibility
    final tapTargetSize = math.max(visualSize, AlhaiSpacing.minTouchTarget);

    // Use only Opacity for disabled state (no double dimming)
    return Opacity(
      opacity: isDisabled ? AlhaiColors.disabledOpacity : 1.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: textDirection,
        children: [
          // Decrement button
          _QuantityButton(
            icon: decrementIcon ?? Icons.remove,
            iconSize: iconSize,
            visualSize: visualSize,
            tapTargetSize: tapTargetSize,
            enabled: canDecrement,
            onTap: canDecrement ? () => _decrement(clampedQuantity) : null,
            semanticLabel: decrementSemanticLabel,
            colorScheme: colorScheme,
          ),

          // Quantity display
          Container(
            constraints: BoxConstraints(
              minWidth: visualSize,
            ),
            padding: const EdgeInsetsDirectional.symmetric(
              horizontal: AlhaiSpacing.sm,
            ),
            child: Text(
              '$clampedQuantity',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Increment button
          _QuantityButton(
            icon: incrementIcon ?? Icons.add,
            iconSize: iconSize,
            visualSize: visualSize,
            tapTargetSize: tapTargetSize,
            enabled: canIncrement,
            onTap: canIncrement ? () => _increment(clampedQuantity) : null,
            semanticLabel: incrementSemanticLabel,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  int _clampQuantity(int value) {
    if (value < min) return min;
    if (max != null && value > max!) return max!;
    return value;
  }

  void _decrement(int current) {
    final newValue = math.max(min, current - step);
    if (newValue != current) {
      if (hapticsEnabled) {
        HapticFeedback.lightImpact();
      }
      onChanged?.call(newValue);
    }
  }

  void _increment(int current) {
    final newValue =
        max == null ? current + step : math.min(max!, current + step);
    if (newValue != current) {
      if (hapticsEnabled) {
        HapticFeedback.lightImpact();
      }
      onChanged?.call(newValue);
    }
  }
}

/// Internal quantity button widget
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final double visualSize;
  final double tapTargetSize;
  final bool enabled;
  final VoidCallback? onTap;
  final String? semanticLabel;
  final ColorScheme colorScheme;

  const _QuantityButton({
    required this.icon,
    required this.iconSize,
    required this.visualSize,
    required this.tapTargetSize,
    required this.enabled,
    required this.onTap,
    required this.semanticLabel,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    // Single Material with correct ripple
    final Widget button = SizedBox(
      width: tapTargetSize,
      height: tapTargetSize,
      child: Center(
        child: Material(
          color: enabled
              ? colorScheme.secondaryContainer
              : colorScheme.surfaceContainerHighest,
          surfaceTintColor: AlhaiColors.transparent,
          borderRadius: BorderRadius.circular(AlhaiRadius.sm),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AlhaiRadius.sm),
            child: SizedBox(
              width: visualSize,
              height: visualSize,
              child: Center(
                child: Icon(
                  icon,
                  size: iconSize,
                  color: enabled
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Wrap with Semantics for accessibility
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: enabled,
      excludeSemantics: semanticLabel == null,
      child: button,
    );
  }
}
