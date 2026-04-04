import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../tokens/alhai_spacing.dart';

/// AlhaiPriceText - Formatted price display with optional original price
///
/// Supports:
/// - Currency + amount formatting
/// - Original price (strikethrough) for discounts
/// - RTL-safe layout
class AlhaiPriceText extends StatelessWidget {
  /// Current price amount
  final double amount;

  /// Currency symbol or code
  final String currency;

  /// Original price (shown with strikethrough if provided)
  final double? originalAmount;

  /// Text style override for current price
  final TextStyle? priceStyle;

  /// Text style override for original price
  final TextStyle? originalPriceStyle;

  /// Size variant
  final AlhaiPriceTextSize size;

  const AlhaiPriceText({
    super.key,
    required this.amount,
    required this.currency,
    this.originalAmount,
    this.priceStyle,
    this.originalPriceStyle,
    this.size = AlhaiPriceTextSize.regular,
  });

  /// Compact variant
  const AlhaiPriceText.compact({
    super.key,
    required this.amount,
    required this.currency,
    this.originalAmount,
    this.priceStyle,
    this.originalPriceStyle,
  }) : size = AlhaiPriceTextSize.compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textDirection = Directionality.of(context);

    final hasDiscount = originalAmount != null && originalAmount! > amount;

    // Text styles based on size
    final TextStyle effectivePriceStyle;
    final TextStyle effectiveOriginalStyle;

    switch (size) {
      case AlhaiPriceTextSize.compact:
        effectivePriceStyle = priceStyle ??
            theme.textTheme.labelLarge!.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
        effectiveOriginalStyle = originalPriceStyle ??
            theme.textTheme.labelSmall!.copyWith(
              color: colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            );
        break;
      case AlhaiPriceTextSize.regular:
        effectivePriceStyle = priceStyle ??
            theme.textTheme.titleMedium!.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
        effectiveOriginalStyle = originalPriceStyle ??
            theme.textTheme.bodySmall!.copyWith(
              color: colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            );
        break;
      case AlhaiPriceTextSize.large:
        effectivePriceStyle = priceStyle ??
            theme.textTheme.headlineSmall!.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            );
        effectiveOriginalStyle = originalPriceStyle ??
            theme.textTheme.bodyMedium!.copyWith(
              color: colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            );
        break;
    }

    final priceText = _formatPrice(context, amount, currency);
    final originalText =
        hasDiscount ? _formatPrice(context, originalAmount!, currency) : null;

    if (!hasDiscount) {
      return Text(
        priceText,
        style: effectivePriceStyle,
        textDirection: textDirection,
      );
    }

    // With discount: show original (strikethrough) + current
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: textDirection,
      children: [
        Text(
          priceText,
          style: effectivePriceStyle,
        ),
        const SizedBox(width: AlhaiSpacing.xs),
        Text(
          originalText!,
          style: effectiveOriginalStyle,
        ),
      ],
    );
  }

  String _formatPrice(
      BuildContext context, double value, String currencyLabel) {
    // M160: Locale-aware formatting with thousands separators
    final locale = Localizations.localeOf(context).toString();
    final decimals = value.truncateToDouble() == value ? 0 : 2;
    final format = NumberFormat.currency(
      locale: locale,
      symbol: '',
      decimalDigits: decimals,
    );
    final formatted = format.format(value).trim();
    return '$formatted $currencyLabel';
  }
}

/// Size variants for price text
enum AlhaiPriceTextSize {
  /// Compact size for cards
  compact,

  /// Regular size
  regular,

  /// Large size for details
  large,
}
