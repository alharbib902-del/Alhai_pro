import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import '../../providers/held_invoices_providers.dart';

// =============================================================================
// PRODUCT CARD - Rich Design
// =============================================================================

class PosProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback? onAddWithQuantity;

  const PosProductCard({
    super.key,
    required this.product,
    required this.onAddToCart,
    this.onAddWithQuantity,
  });

  @override
  State<PosProductCard> createState() => _PosProductCardState();
}

class _PosProductCardState extends State<PosProductCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final isOutOfStock = product.isOutOfStock;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final imageHeight = getResponsiveValue<double>(
      context,
      mobile: 56,
      desktop: 56,
    );

    return Semantics(
      label: isOutOfStock
          ? '${product.name}, ${l10n.quantitySoldOut}'
          : '${product.name}, ${product.price.toStringAsFixed(2)} ${l10n.sar}',
      button: !isOutOfStock,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: isOutOfStock ? null : widget.onAddToCart,
          child: AnimatedScale(
            scale: _isHovered && !isOutOfStock ? 1.02 : 1.0,
            duration: AlhaiDurations.standard,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(
                  color: colorScheme.outlineVariant,
                  width: 0.5,
                ),
                boxShadow: _isHovered ? AppShadows.md : AppShadows.sm,
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image area with overlays
                  _buildImageArea(
                    product,
                    imageHeight,
                    isOutOfStock,
                    isDark,
                    l10n,
                  ),

                  // Info area - Row with consistent + button position
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        AlhaiSpacing.xs,
                        AlhaiSpacing.xxs,
                        AlhaiSpacing.xxs,
                        AlhaiSpacing.xxs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Product name
                          Expanded(
                            child: Text(
                              product.name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Add to cart button (+)
                          if (!isOutOfStock)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(
                                start: AlhaiSpacing.xxs,
                              ),
                              child: Tooltip(
                                message: l10n.addToCart,
                                child: Material(
                                  color: AppColors.primary,
                                  shape: const CircleBorder(),
                                  elevation: 2,
                                  child: InkWell(
                                    onTap:
                                        widget.onAddWithQuantity ??
                                        widget.onAddToCart,
                                    customBorder: const CircleBorder(),
                                    child: SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: Icon(
                                        Icons.add_rounded,
                                        color: colorScheme.onPrimary,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
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

  Widget _buildImageArea(
    Product product,
    double height,
    bool isOutOfStock,
    bool isDark,
    AppLocalizations l10n,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget imageWidget = Semantics(
      label: product.name,
      image: true,
      child: Container(
        height: height,
        width: double.infinity,
        color: colorScheme.surfaceContainerLow,
        child: product.imageThumbnail != null
            ? CachedNetworkImage(
                imageUrl: product.imageThumbnail!,
                fit: BoxFit.cover,
                memCacheWidth: 200,
                memCacheHeight: 200,
                placeholder: (_, __) => Center(
                  child: Icon(
                    Icons.image_rounded,
                    color: colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    color: colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                ),
              )
            : Center(
                child: Icon(
                  Icons.image_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 40,
                ),
              ),
      ),
    );

    // Grayscale for out of stock
    if (isOutOfStock) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: imageWidget,
      );
    }

    return Stack(
      children: [
        imageWidget,

        // Price badge (top-right) - بدون BackdropFilter للأداء
        if (!isOutOfStock)
          PositionedDirectional(
            top: 6,
            end: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${product.price.toStringAsFixed(0)} ${l10n.sar}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ),
          ),

        // Discount overlay (bottom of image)
        // Note: discount field to be added to Product model in future
        // When available, show: l10n.discountPercent(discount.toStringAsFixed(0))

        // Out of stock badge
        if (isOutOfStock)
          Positioned.fill(
            child: Center(
              child: Transform.rotate(
                angle: -0.3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: AlhaiSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.quantitySoldOut,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Low stock indicator
        if (product.isLowStock && !isOutOfStock)
          PositionedDirectional(
            top: 6,
            start: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: colorScheme.onPrimary,
                    size: 12,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    l10n.lowStock,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// SHORTCUTS BAR (Desktop Only)
// =============================================================================

class PosShortcutsBar extends ConsumerWidget {
  final VoidCallback? onHoldInvoice;
  final VoidCallback? onShowHeldInvoices;

  const PosShortcutsBar({
    super.key,
    this.onHoldInvoice,
    this.onShowHeldInvoices,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final heldCount = ref.watch(dbHeldInvoicesCountProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AlhaiSpacing.lg,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.full),
        boxShadow: AppShadows.lg,
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          PosShortcutButton(
            icon: Icons.point_of_sale_rounded,
            label: l10n.openDrawer,
            color: AppColors.info,
            onTap: () {
              context.push(AppRoutes.cashDrawer);
            },
          ),
          const SizedBox(width: AlhaiSpacing.mdl),
          PosShortcutButton(
            icon: Icons.replay_rounded,
            label: l10n.refund,
            color: AppColors.purple,
            onTap: () {
              context.push(AppRoutes.refundRequest);
            },
          ),
          const SizedBox(width: AlhaiSpacing.mdl),
          // زر تعليق: tap = تعليق، long press = عرض المعلقات
          GestureDetector(
            onLongPress: onShowHeldInvoices,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                PosShortcutButton(
                  icon: Icons.pause_rounded,
                  label: l10n.suspend,
                  color: AppColors.warning,
                  onTap: onHoldInvoice ?? () {},
                ),
                if (heldCount > 0)
                  PositionedDirectional(
                    top: -4,
                    end: -4,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.warning,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$heldCount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SHORTCUT BUTTON
// =============================================================================

class PosShortcutButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const PosShortcutButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.xxs,
            vertical: 2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: AlhaiSpacing.xxs),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MOBILE FAB
// =============================================================================

class PosFab extends StatelessWidget {
  final int itemCount;
  final VoidCallback onTap;

  const PosFab({super.key, required this.itemCount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    return Semantics(
      label: '${l10n.cart}, ${l10n.nItems(itemCount)}',
      button: true,
      child: FloatingActionButton(
      onPressed: onTap,
      backgroundColor: AppColors.primary,
      elevation: 6,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.shopping_cart_rounded,
              color: colorScheme.onPrimary,
              size: 26,
            ),
            if (itemCount > 0)
              PositionedDirectional(
                top: 6,
                end: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$itemCount',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      ),
    );
  }
}
