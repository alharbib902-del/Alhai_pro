import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';
import '../data_display/alhai_price_text.dart';
import '../inputs/alhai_quantity_control.dart';

/// AlhaiCartItem - Compact cart item row for cart & checkout screens
///
/// Features:
/// - Title + Price display
/// - Quantity control (AlhaiQuantityControl)
/// - Remove action
/// - Optional leading widget (image/icon)
/// - Tappable row
/// - RTL-safe layout
/// - Dark mode support
class AlhaiCartItem extends StatelessWidget {
  /// Product title
  final String title;

  /// Price amount
  final double priceAmount;

  /// Currency symbol or code
  final String currency;

  /// Leading widget (e.g., product image or icon)
  final Widget? leading;

  /// Current quantity
  final int quantity;

  /// Quantity change callback
  final ValueChanged<int>? onQuantityChanged;

  /// Quantity min value
  final int quantityMin;

  /// Quantity max value
  final int? quantityMax;

  /// Remove item callback
  final VoidCallback? onRemove;

  /// Row tap callback
  final VoidCallback? onTap;

  /// Whether the item is enabled
  final bool enabled;

  /// Semantic label for accessibility
  final String? semanticsLabel;

  /// Semantic label for remove button
  final String? removeSemanticLabel;

  const AlhaiCartItem({
    super.key,
    required this.title,
    required this.priceAmount,
    required this.currency,
    this.leading,
    required this.quantity,
    this.onQuantityChanged,
    this.quantityMin = 1,
    this.quantityMax,
    this.onRemove,
    this.onTap,
    this.enabled = true,
    this.semanticsLabel,
    this.removeSemanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);

    final isTappable = enabled && onTap != null;

    return Semantics(
      label: semanticsLabel ?? title,
      button: isTappable,
      enabled: enabled,
      container: true,
      child: Opacity(
        opacity: enabled ? 1.0 : AlhaiColors.disabledOpacity,
        child: Material(
          color: AlhaiColors.transparent,
          borderRadius: BorderRadius.circular(AlhaiRadius.sm),
          clipBehavior: Clip.antiAlias,
          child: isTappable
              ? InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(AlhaiRadius.sm),
                  child: _buildContent(theme, colorScheme, textDirection),
                )
              : _buildContent(theme, colorScheme, textDirection),
        ),
      ),
    );
  }

  Widget _buildContent(
    ThemeData theme,
    ColorScheme colorScheme,
    TextDirection textDirection,
  ) {
    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        vertical: AlhaiSpacing.sm,
        horizontal: AlhaiSpacing.md,
      ),
      child: Row(
        textDirection: textDirection,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Leading widget (image/icon)
          if (leading != null) ...[
            _buildLeading(),
            const SizedBox(width: AlhaiSpacing.md),
          ],

          // Content (title, price, quantity)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: textDirection,
                ),

                const SizedBox(height: AlhaiSpacing.xxs),

                // Price
                AlhaiPriceText.compact(amount: priceAmount, currency: currency),

                const SizedBox(height: AlhaiSpacing.sm),

                // Quantity control + remove
                Row(
                  textDirection: textDirection,
                  children: [
                    AlhaiQuantityControl(
                      quantity: quantity,
                      onChanged: enabled ? onQuantityChanged : null,
                      min: quantityMin,
                      max: quantityMax,
                      size: AlhaiQuantityControlSize.compact,
                      enabled: enabled,
                    ),

                    const Spacer(),

                    // Remove button
                    if (onRemove != null)
                      _RemoveButton(
                        onRemove: enabled ? onRemove : null,
                        semanticLabel: removeSemanticLabel,
                        colorScheme: colorScheme,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeading() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AlhaiRadius.sm),
      child: SizedBox(
        width: AlhaiSpacing.huge,
        height: AlhaiSpacing.huge,
        child: FittedBox(
          fit: BoxFit.cover,
          clipBehavior: Clip.antiAlias,
          child: leading,
        ),
      ),
    );
  }
}

/// Internal remove button widget
class _RemoveButton extends StatelessWidget {
  final VoidCallback? onRemove;
  final String? semanticLabel;
  final ColorScheme colorScheme;

  const _RemoveButton({
    required this.onRemove,
    required this.semanticLabel,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final Widget button = Material(
      color: AlhaiColors.transparent,
      borderRadius: BorderRadius.circular(AlhaiRadius.full),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onRemove,
        borderRadius: BorderRadius.circular(AlhaiRadius.full),
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.xs),
          child: Icon(
            Icons.delete_outline_rounded,
            size: AlhaiSpacing.lg,
            color: onRemove != null
                ? colorScheme.error
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );

    // Use provided label or fallback
    return Semantics(
      label: semanticLabel ?? 'Remove',
      button: true,
      enabled: onRemove != null,
      child: button,
    );
  }
}
