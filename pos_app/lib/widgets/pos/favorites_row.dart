import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';
import '../../providers/products_providers.dart';
import '../../providers/cart_providers.dart';

/// صف المنتجات السريعة (الأكثر مبيعاً)
/// 
/// يعرض أعلى 9 منتجات مبيعاً مع اختصارات أرقام 1-9
class FavoritesRow extends ConsumerWidget {
  final VoidCallback? onProductAdded;

  const FavoritesRow({super.key, this.onProductAdded});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsStateProvider);
    final theme = Theme.of(context);

    // الحصول على أعلى 9 منتجات (TODO: استخدام بيانات المبيعات الفعلية)
    final products = productsState.products.take(9).toList();

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Icon(
                  Icons.star,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'الأكثر مبيعاً (اضغط 1-9)',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          
          // المنتجات
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _FavoriteProductCard(
                  product: product,
                  shortcutNumber: index + 1,
                  onTap: () {
                    ref.read(cartStateProvider.notifier).addProduct(product);
                    onProductAdded?.call();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة منتج سريع
class _FavoriteProductCard extends StatelessWidget {
  final Product product;
  final int shortcutNumber;
  final VoidCallback onTap;

  const _FavoriteProductCard({
    required this.product,
    required this.shortcutNumber,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 80,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // رقم الاختصار
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '[$shortcutNumber]',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // اسم المنتج
                Text(
                  product.name,
                  style: theme.textTheme.labelSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                // السعر
                Text(
                  'ر.س ${product.price.toStringAsFixed(0)}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
