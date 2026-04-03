import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
                ref.read(cartProvider.notifier).clear();
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text(
                    'السلة فارغة',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    'أضف منتجات من المتجر',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),
                  FilledButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('تصفح المتاجر'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AlhaiSpacing.md),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: AlhaiSpacing.xs),
                        child: Padding(
                          padding: const EdgeInsets.all(AlhaiSpacing.sm),
                          child: Row(
                            children: [
                              // Image
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: item.imageUrl != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
                                        child: Image.network(
                                          item.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              const Icon(
                                                  Icons.image_outlined),
                                        ),
                                      )
                                    : const Icon(
                                        Icons.inventory_2_outlined),
                              ),
                              const SizedBox(width: AlhaiSpacing.sm),
                              // Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: AlhaiSpacing.xxs),
                                    Text(
                                      '${item.unitPrice.toStringAsFixed(2)} ر.س',
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.outline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity controls
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${item.lineTotal.toStringAsFixed(2)} ر.س',
                                    style:
                                        theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: AlhaiSpacing.xs),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: IconButton(
                                          onPressed: () {
                                            if (item.qty > 1) {
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .updateQty(
                                                    item.productId,
                                                    item.qty - 1,
                                                  );
                                            } else {
                                              ref
                                                  .read(cartProvider.notifier)
                                                  .removeItem(
                                                      item.productId);
                                            }
                                          },
                                          icon: Icon(
                                            item.qty == 1
                                                ? Icons.delete_outline
                                                : Icons.remove,
                                            size: 16,
                                          ),
                                          padding: EdgeInsets.zero,
                                          style: IconButton.styleFrom(
                                            side: BorderSide(
                                              color:
                                                  theme.colorScheme.outline,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 36,
                                        child: Text(
                                          '${item.qty}',
                                          textAlign: TextAlign.center,
                                          style: theme
                                              .textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 32,
                                        height: 32,
                                        child: IconButton.filled(
                                          onPressed: () {
                                            ref
                                                .read(cartProvider.notifier)
                                                .updateQty(
                                                  item.productId,
                                                  item.qty + 1,
                                                );
                                          },
                                          icon: const Icon(Icons.add,
                                              size: 16),
                                          padding: EdgeInsets.zero,
                                          style: IconButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Checkout bar
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'المجموع',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            Text(
                              '${cart.total.toStringAsFixed(2)} ر.س',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: AlhaiSpacing.md),
                        Expanded(
                          child: FilledButton(
                            onPressed: () => context.push('/checkout'),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'إتمام الطلب (${cart.itemCount})',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
