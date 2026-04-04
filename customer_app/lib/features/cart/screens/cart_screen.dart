import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/responsive_helper.dart';
import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('السلة'),
        actions: [
          if (cart.isNotEmpty)
            TextButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('مسح السلة'),
                    content: const Text(
                        'هل تريد حذف جميع المنتجات من السلة؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء'),
                      ),
                      FilledButton(
                        onPressed: () {
                          HapticFeedback.heavyImpact();
                          ref.read(cartProvider.notifier).clear();
                          Navigator.pop(ctx);
                        },
                        child: const Text('مسح'),
                      ),
                    ],
                  ),
                );
              },
              child: Text(
                'مسح',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: AlhaiEmptyState(
                icon: Icons.shopping_cart_outlined,
                title: 'السلة فارغة',
                description: 'أضف منتجات من المتجر',
                actionText: 'تصفح المتاجر',
                onAction: () => context.go('/home'),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = ResponsiveHelper.isTablet(context);

                Widget cartItemsList() => RefreshIndicator(
                  onRefresh: () async {
                    // Refresh cart prices by re-reading cart state
                    ref.invalidate(cartProvider);
                  },
                  child: ListView.builder(
                      padding: EdgeInsets.all(
                          isTablet ? AlhaiSpacing.lg : AlhaiSpacing.md),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                          child: Dismissible(
                            key: ValueKey(item.productId),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              padding:
                                  const EdgeInsetsDirectional.only(end: 16),
                              color: theme.colorScheme.error,
                              child: Icon(Icons.delete_outline,
                                  color: theme.colorScheme.onError),
                            ),
                            confirmDismiss: (_) async => true,
                            onDismissed: (_) {
                              HapticFeedback.mediumImpact();
                              ref
                                  .read(cartProvider.notifier)
                                  .removeItem(item.productId);
                            },
                            child: AlhaiCartItem(
                              title: item.name,
                              priceAmount: item.unitPrice,
                              currency: 'ر.س',
                              quantity: item.qty,
                              leading: ProductImage(
                                thumbnail: item.imageUrl,
                                size: ImageSize.thumbnail,
                                width: 60,
                                height: 60,
                              ),
                              onQuantityChanged: (newQty) {
                                HapticFeedback.lightImpact();
                                ref
                                    .read(cartProvider.notifier)
                                    .updateQty(item.productId, newQty);
                              },
                              quantityMin: 0,
                              onRemove: () {
                                HapticFeedback.mediumImpact();
                                ref
                                    .read(cartProvider.notifier)
                                    .removeItem(item.productId);
                              },
                              removeSemanticLabel: 'حذف ${item.name}',
                            ),
                          ),
                        );
                      },
                    ),
                    );

                Widget checkoutSummary({bool isColumn = false}) => Container(
                      padding: const EdgeInsets.all(AlhaiSpacing.md),
                      decoration: isColumn
                          ? BoxDecoration(
                              color: theme.colorScheme.surface,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, -2),
                                ),
                              ],
                            )
                          : null,
                      child: SafeArea(
                        child: isColumn
                            ? Row(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'المجموع',
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                          color: theme.colorScheme.outline,
                                        ),
                                      ),
                                      Text(
                                        '${cart.total.toStringAsFixed(2)} ر.س',
                                        style: theme.textTheme.titleLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: AlhaiSpacing.md),
                                  Expanded(
                                    child: FilledButton(
                                      onPressed: () =>
                                          context.push('/checkout'),
                                      style: FilledButton.styleFrom(
                                        minimumSize:
                                            const Size.fromHeight(52),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              AlhaiRadius.borderMd,
                                        ),
                                      ),
                                      child: Text(
                                        'إتمام الطلب (${cart.itemCount})',
                                        style:
                                            const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                children: [
                                  Card(
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                          AlhaiSpacing.md),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ملخص الطلب',
                                            style: theme
                                                .textTheme.titleMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(
                                              height: AlhaiSpacing.sm),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text('عدد المنتجات',
                                                  style: theme.textTheme
                                                      .bodyMedium),
                                              Text('${cart.itemCount}',
                                                  style: theme.textTheme
                                                      .bodyMedium),
                                            ],
                                          ),
                                          const Divider(
                                              height: AlhaiSpacing.lg),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                'المجموع',
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${cart.total.toStringAsFixed(2)} ر.س',
                                                style: theme
                                                    .textTheme.titleMedium
                                                    ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.bold,
                                                  color: theme.colorScheme
                                                      .primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AlhaiSpacing.md),
                                  FilledButton(
                                    onPressed: () =>
                                        context.push('/checkout'),
                                    style: FilledButton.styleFrom(
                                      minimumSize:
                                          const Size.fromHeight(52),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            AlhaiRadius.borderMd,
                                      ),
                                    ),
                                    child: Text(
                                      'إتمام الطلب (${cart.itemCount})',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );

                if (isTablet) {
                  // Tablet: items on left, summary on right
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 3,
                        child: cartItemsList(),
                      ),
                      Expanded(
                        flex: 2,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(AlhaiSpacing.md),
                          child: checkoutSummary(isColumn: false),
                        ),
                      ),
                    ],
                  );
                }

                // Phone: list on top, checkout bar at bottom
                return Column(
                  children: [
                    Expanded(child: cartItemsList()),
                    checkoutSummary(isColumn: true),
                  ],
                );
              },
            ),
    );
  }
}
