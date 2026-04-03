import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/providers/app_providers.dart';
import '../providers/catalog_providers.dart';
import '../../cart/providers/cart_provider.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final productAsync = ref.watch(productDetailProvider(productId));
    final store = ref.watch(selectedStoreProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('فشل تحميل المنتج', style: theme.textTheme.bodyLarge),
        ),
        data: (product) {
          final cartItem = ref.watch(cartProvider).items
              .where((item) => item.productId == product.id)
              .firstOrNull;
          final qtyInCart = cartItem?.qty ?? 0;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Product image
                      AspectRatio(
                        aspectRatio: 1,
                        child: product.imageLarge != null
                            ? CachedNetworkImage(
                                imageUrl: product.imageLarge!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) => Container(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: theme.colorScheme.surfaceContainerHighest,
                                  child: const Icon(Icons.image_outlined,
                                      size: 64),
                                ),
                              )
                            : Container(
                                color: theme.colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  size: 80,
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AlhaiSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.xs),
                            Text(
                              '${product.price.toStringAsFixed(2)} ر.س',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AlhaiSpacing.xs),
                            // Stock status
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: AlhaiSpacing.xxs),
                              decoration: BoxDecoration(
                                color: product.isOutOfStock
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                product.isOutOfStock
                                    ? 'غير متوفر'
                                    : 'متوفر',
                                style: TextStyle(
                                  color: product.isOutOfStock
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (product.description != null &&
                                product.description!.isNotEmpty) ...[
                              const SizedBox(height: AlhaiSpacing.md),
                              Text(
                                'الوصف',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: AlhaiSpacing.xs),
                              Text(
                                product.description!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                            if (product.unit != null) ...[
                              const SizedBox(height: AlhaiSpacing.sm),
                              Text(
                                'الوحدة: ${product.unit}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom action bar
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
                  child: qtyInCart > 0
                      ? Row(
                          children: [
                            IconButton.outlined(
                              onPressed: () {
                                if (qtyInCart > 1) {
                                  ref.read(cartProvider.notifier)
                                      .updateQty(product.id, qtyInCart - 1);
                                } else {
                                  ref.read(cartProvider.notifier)
                                      .removeItem(product.id);
                                }
                              },
                              icon: Icon(
                                  qtyInCart == 1 ? Icons.delete : Icons.remove),
                            ),
                            const SizedBox(width: AlhaiSpacing.md),
                            Text(
                              '$qtyInCart',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: AlhaiSpacing.md),
                            IconButton.filled(
                              onPressed: () {
                                ref.read(cartProvider.notifier)
                                    .updateQty(product.id, qtyInCart + 1);
                              },
                              icon: const Icon(Icons.add),
                            ),
                            const Spacer(),
                            FilledButton(
                              onPressed: () => context.push('/cart'),
                              child: const Text('عرض السلة'),
                            ),
                          ],
                        )
                      : FilledButton(
                          onPressed: product.isOutOfStock
                              ? null
                              : () {
                                  ref.read(cartProvider.notifier)
                                      .addItem(product, store?.id ?? '');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('تمت إضافة ${product.name}'),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            product.isOutOfStock
                                ? 'غير متوفر'
                                : 'أضف للسلة',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
