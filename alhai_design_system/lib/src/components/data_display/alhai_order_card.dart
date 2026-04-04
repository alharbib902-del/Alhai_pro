import 'package:flutter/material.dart';

import '../../tokens/alhai_colors.dart';
import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';
import 'alhai_order_status.dart';
import 'alhai_price_text.dart';

/// AlhaiOrderRow - Compact order row for lists
///
/// Features:
/// - Order number and status badge
/// - Total amount with currency
/// - Item count and time
/// - Full row tappable
/// - RTL-safe layout
class AlhaiOrderRow extends StatelessWidget {
  /// Order number (e.g., "#1234")
  final String orderNumber;

  /// Order status
  final AlhaiOrderStatus status;

  /// Status label text
  final String statusLabel;

  /// Total order amount
  final double totalAmount;

  /// Currency symbol
  final String currency;

  /// Number of items
  final int? itemCount;

  /// Creation time (formatted string)
  final String? createdAt;

  /// Tap callback
  final VoidCallback? onTap;

  /// Whether row is enabled
  final bool enabled;

  const AlhaiOrderRow({
    super.key,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.totalAmount,
    this.currency = 'ر.س',
    this.itemCount,
    this.createdAt,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final isDisabled = !enabled || onTap == null;

    return Semantics(
      label: '$orderNumber - $statusLabel',
      button: !isDisabled,
      enabled: !isDisabled,
      child: Opacity(
        opacity: isDisabled ? AlhaiColors.disabledOpacity : 1.0,
        child: Material(
          color: AlhaiColors.transparent,
          child: InkWell(
            onTap: isDisabled ? null : onTap,
            borderRadius: BorderRadius.circular(AlhaiRadius.sm),
            child: Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: AlhaiSpacing.md,
                vertical: AlhaiSpacing.sm,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Order info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Order number + status
                        Row(
                          children: [
                            Text(
                              orderNumber,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AlhaiSpacing.sm),
                            AlhaiOrderStatusBadge(
                              status: status,
                              label: statusLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: AlhaiSpacing.xxs),
                        // Meta info
                        Row(
                          children: [
                            if (itemCount != null) ...[
                              Icon(
                                Icons.shopping_bag_outlined,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AlhaiSpacing.xxxs),
                              Text(
                                '$itemCount',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: AlhaiSpacing.sm),
                            ],
                            if (createdAt != null) ...[
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: AlhaiSpacing.xxxs),
                              Text(
                                createdAt!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Price
                  AlhaiPriceText(
                    amount: totalAmount,
                    currency: currency,
                  ),
                  const SizedBox(width: AlhaiSpacing.xs),
                  // Arrow (RTL-aware)
                  Icon(
                    isRtl ? Icons.chevron_left : Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Order item for AlhaiOrderCard
class AlhaiOrderCardItem {
  /// Item name
  final String name;

  /// Quantity
  final int quantity;

  /// Unit price
  final double price;

  const AlhaiOrderCardItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

/// AlhaiOrderCard - Full order card for details
///
/// Features:
/// - Complete order information
/// - Customer details with actions
/// - Items list with prices
/// - RTL-safe layout
class AlhaiOrderCard extends StatelessWidget {
  /// Order number
  final String orderNumber;

  /// Order status
  final AlhaiOrderStatus status;

  /// Status label
  final String statusLabel;

  /// Customer name
  final String? customer;

  /// Customer phone
  final String? phone;

  /// Delivery address
  final String? address;

  /// Order items
  final List<AlhaiOrderCardItem>? items;

  /// Subtotal amount
  final double? subtotal;

  /// Delivery fee
  final double? delivery;

  /// Total amount
  final double total;

  /// Currency symbol
  final String currency;

  /// Card tap callback
  final VoidCallback? onTap;

  /// Call button callback
  final VoidCallback? onCall;

  /// Map button callback
  final VoidCallback? onMap;

  /// Whether card is enabled
  final bool enabled;

  const AlhaiOrderCard({
    super.key,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    this.customer,
    this.phone,
    this.address,
    this.items,
    this.subtotal,
    this.delivery,
    required this.total,
    this.currency = 'ر.س',
    this.onTap,
    this.onCall,
    this.onMap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDisabled = !enabled || onTap == null;

    return Semantics(
      label: '$orderNumber - $statusLabel',
      button: !isDisabled,
      enabled: !isDisabled,
      child: Opacity(
        opacity: isDisabled ? AlhaiColors.disabledOpacity : 1.0,
        child: Material(
          color: colorScheme.surface,
          surfaceTintColor: AlhaiColors.transparent,
          borderRadius: BorderRadius.circular(AlhaiRadius.card),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isDisabled || onTap == null ? null : onTap,
            borderRadius: BorderRadius.circular(AlhaiRadius.card),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: AlhaiSpacing.strokeXs,
                ),
                borderRadius: BorderRadius.circular(AlhaiRadius.card),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  _buildHeader(theme, colorScheme),

                  // Customer info
                  if (customer != null || phone != null || address != null)
                    _buildCustomerSection(theme, colorScheme, isDisabled),

                  // Items
                  if (items != null && items!.isNotEmpty)
                    _buildItemsSection(theme, colorScheme),

                  // Totals
                  _buildTotalsSection(theme, colorScheme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsetsDirectional.all(AlhaiSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  orderNumber,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                AlhaiOrderStatusBadge(
                  status: status,
                  label: statusLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection(
      ThemeData theme, ColorScheme colorScheme, bool isDisabled) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: AlhaiSpacing.strokeXs,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Customer name
          if (customer != null)
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Text(
                    customer!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // Call button
                if (phone != null && onCall != null)
                  IconButton(
                    onPressed: isDisabled ? null : onCall,
                    icon: Icon(
                      Icons.phone_outlined,
                      color: colorScheme.primary,
                    ),
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'اتصال',
                  ),
              ],
            ),

          // Address
          if (address != null) ...[
            const SizedBox(height: AlhaiSpacing.xs),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Text(
                    address!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                // Map button
                if (onMap != null)
                  IconButton(
                    onPressed: isDisabled ? null : onMap,
                    icon: Icon(
                      Icons.map_outlined,
                      color: colorScheme.primary,
                    ),
                    iconSize: 20,
                    visualDensity: VisualDensity.compact,
                    tooltip: 'الخريطة',
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AlhaiSpacing.md,
        vertical: AlhaiSpacing.sm,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: AlhaiSpacing.strokeXs,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < items!.length; i++) ...[
            if (i > 0) const SizedBox(height: AlhaiSpacing.xs),
            Row(
              children: [
                Text(
                  '${items![i].quantity}x',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: AlhaiSpacing.sm),
                Expanded(
                  child: Text(
                    items![i].name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Text(
                  '${items![i].price} $currency',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTotalsSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsetsDirectional.all(AlhaiSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant,
            width: AlhaiSpacing.strokeXs,
          ),
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AlhaiRadius.card),
        ),
      ),
      child: Column(
        children: [
          // Subtotal
          if (subtotal != null)
            _buildTotalRow(
              theme,
              colorScheme,
              'المجموع الفرعي',
              subtotal!,
              isSubtle: true,
            ),

          // Delivery
          if (delivery != null) ...[
            const SizedBox(height: AlhaiSpacing.xs),
            _buildTotalRow(
              theme,
              colorScheme,
              'التوصيل',
              delivery!,
              isSubtle: true,
            ),
          ],

          // Total
          if (subtotal != null || delivery != null)
            const SizedBox(height: AlhaiSpacing.sm),
          _buildTotalRow(
            theme,
            colorScheme,
            'الإجمالي',
            total,
            isSubtle: false,
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    double amount, {
    required bool isSubtle,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: (isSubtle
                  ? theme.textTheme.bodySmall
                  : theme.textTheme.titleMedium)
              ?.copyWith(
            color:
                isSubtle ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
            fontWeight: isSubtle ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        const Spacer(),
        Text(
          '$amount $currency',
          style: (isSubtle
                  ? theme.textTheme.bodySmall
                  : theme.textTheme.titleMedium)
              ?.copyWith(
            color:
                isSubtle ? colorScheme.onSurfaceVariant : colorScheme.primary,
            fontWeight: isSubtle ? FontWeight.normal : FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
