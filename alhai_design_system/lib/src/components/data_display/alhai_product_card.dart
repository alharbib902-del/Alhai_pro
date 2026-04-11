import 'package:flutter/material.dart';

import '../../responsive/context_ext.dart';
import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_durations.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';
import '../buttons/alhai_button.dart';
import '../data_display/alhai_price_text.dart';
import '../inputs/alhai_quantity_control.dart';

/// CTA mode for product card
enum AlhaiProductCardCtaMode {
  /// Show add button
  add,

  /// Show quantity control
  quantity,

  /// No CTA
  none,
}

/// AlhaiProductCard - Reusable product card for e-commerce
///
/// Features:
/// - Product image with placeholder/error handling
/// - Title with ellipsis
/// - Price display using AlhaiPriceText
/// - Discount badge support
/// - Add button or QuantityControl CTA modes
/// - Tappable card
/// - RTL-safe layout
class AlhaiProductCard extends StatelessWidget {
  /// Product title
  final String title;

  /// Product image provider
  final ImageProvider? image;

  /// Custom image widget builder (overrides image)
  final Widget Function(BuildContext context)? imageBuilder;

  /// Price amount
  final double priceAmount;

  /// Currency symbol or code
  final String currency;

  /// Original price (for discount display)
  final double? originalPriceAmount;

  /// Discount badge label (e.g., "-20%")
  final String? discountLabel;

  /// Card tap callback
  final VoidCallback? onTap;

  /// CTA mode
  final AlhaiProductCardCtaMode ctaMode;

  /// Add button callback (when ctaMode == add)
  final VoidCallback? onAdd;

  /// Add button label (required when ctaMode == add)
  final String? addButtonLabel;

  /// Current quantity (when ctaMode == quantity)
  final int quantity;

  /// Quantity change callback (when ctaMode == quantity)
  final ValueChanged<int>? onQuantityChanged;

  /// Quantity min value
  final int quantityMin;

  /// Quantity max value
  final int? quantityMax;

  /// Whether the product is available
  final bool enabled;

  /// Unavailable label (shown when enabled = false)
  final String? unavailableLabel;

  /// Semantic label for accessibility
  final String? semanticsLabel;

  /// Image semantic label for accessibility
  final String? imageSemanticLabel;

  const AlhaiProductCard({
    super.key,
    required this.title,
    required this.priceAmount,
    required this.currency,
    this.image,
    this.imageBuilder,
    this.originalPriceAmount,
    this.discountLabel,
    this.onTap,
    this.ctaMode = AlhaiProductCardCtaMode.add,
    this.onAdd,
    this.addButtonLabel,
    this.quantity = 0,
    this.onQuantityChanged,
    this.quantityMin = 1,
    this.quantityMax,
    this.enabled = true,
    this.unavailableLabel,
    this.semanticsLabel,
    this.imageSemanticLabel,
  }) : assert(
         ctaMode != AlhaiProductCardCtaMode.add || addButtonLabel != null,
         'addButtonLabel is required when ctaMode is add',
       );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);

    // Separate discount logic
    final hasPriceDiscount =
        originalPriceAmount != null && originalPriceAmount! > priceAmount;
    final showDiscountBadge = hasPriceDiscount && discountLabel != null;

    return Semantics(
      label: semanticsLabel ?? title,
      button: enabled && onTap != null,
      enabled: enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : AlhaiColors.disabledOpacity,
        child: Material(
          color: colorScheme.surface,
          surfaceTintColor: AlhaiColors.transparent,
          borderRadius: BorderRadius.circular(AlhaiRadius.card),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(AlhaiRadius.card),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AlhaiRadius.card),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: AlhaiSpacing.strokeXs,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image section
                  _buildImageSection(
                    context,
                    theme,
                    colorScheme,
                    showDiscountBadge,
                  ),

                  // Content section
                  Padding(
                    padding: const EdgeInsets.all(AlhaiSpacing.sm),
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

                        const SizedBox(height: AlhaiSpacing.xs),

                        // Price (uses hasPriceDiscount, not showDiscountBadge)
                        AlhaiPriceText.compact(
                          amount: priceAmount,
                          currency: currency,
                          originalAmount: hasPriceDiscount
                              ? originalPriceAmount
                              : null,
                        ),

                        // CTA
                        if (ctaMode != AlhaiProductCardCtaMode.none) ...[
                          const SizedBox(height: AlhaiSpacing.sm),
                          _buildCta(context, colorScheme),
                        ],

                        // Unavailable label
                        if (!enabled && unavailableLabel != null) ...[
                          const SizedBox(height: AlhaiSpacing.xs),
                          Text(
                            unavailableLabel!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool showDiscountBadge,
  ) {
    Widget imageWidget;

    if (imageBuilder != null) {
      imageWidget = imageBuilder!(context);
    } else if (image != null) {
      imageWidget = Image(
        image: image!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(colorScheme),
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedSwitcher(
            duration: context.prefersReducedMotion
                ? Duration.zero
                : AlhaiDurations.standard,
            child: frame != null ? child : _buildPlaceholder(colorScheme),
          );
        },
      );
    } else {
      imageWidget = _buildPlaceholder(colorScheme);
    }

    return AspectRatio(
      aspectRatio: 1.0,
      child: Semantics(
        image: true,
        label: imageSemanticLabel ?? title,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image (no extra ClipRRect - Material already clips)
            imageWidget,

            // Discount badge
            if (showDiscountBadge)
              PositionedDirectional(
                top: AlhaiSpacing.xs,
                start: AlhaiSpacing.xs,
                child: _DiscountBadge(
                  label: discountLabel!,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: AlhaiSpacing.xxl,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildCta(BuildContext context, ColorScheme colorScheme) {
    if (!enabled) {
      return const SizedBox.shrink();
    }

    switch (ctaMode) {
      case AlhaiProductCardCtaMode.add:
        return AlhaiButton(
          onPressed: onAdd,
          label: addButtonLabel!,
          variant: AlhaiButtonVariant.tonal,
          size: AlhaiButtonSize.small,
          fullWidth: true,
        );

      case AlhaiProductCardCtaMode.quantity:
        return Center(
          child: AlhaiQuantityControl(
            quantity: quantity,
            onChanged: onQuantityChanged,
            min: quantityMin,
            max: quantityMax,
            size: AlhaiQuantityControlSize.compact,
          ),
        );

      case AlhaiProductCardCtaMode.none:
        return const SizedBox.shrink();
    }
  }
}

/// Internal discount badge widget
class _DiscountBadge extends StatelessWidget {
  final String label;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _DiscountBadge({
    required this.label,
    required this.theme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.xs,
        vertical: AlhaiSpacing.xxxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.error,
        borderRadius: BorderRadius.circular(AlhaiRadius.xs),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onError),
      ),
    );
  }
}
