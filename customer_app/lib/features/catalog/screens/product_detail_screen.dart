import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/responsive_helper.dart';
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
          tooltip: 'رجوع',
          onPressed: () => context.pop(),
        ),
      ),
      body: productAsync.when(
        loading: () => AlhaiShimmer(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: AlhaiSkeleton.rectangle(
                  width: double.infinity,
                  height: double.infinity,
                  borderRadius: BorderRadius.zero,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AlhaiSkeleton.text(width: 200, lineHeight: 24),
                    const SizedBox(height: AlhaiSpacing.sm),
                    AlhaiSkeleton.text(width: 120, lineHeight: 20),
                    const SizedBox(height: AlhaiSpacing.md),
                    AlhaiSkeleton.text(lines: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: AlhaiEmptyState.error(
            title: 'فشل تحميل المنتج',
            description: 'تحقق من اتصالك بالإنترنت',
            actionText: 'رجوع',
            onAction: () => context.pop(),
          ),
        ),
        data: (product) {
          final cartItem = ref
              .watch(cartProvider)
              .items
              .where((item) => item.productId == product.id)
              .firstOrNull;
          final qtyInCart = cartItem?.qty ?? 0;

          // Shared widgets
          Widget imageSection({double? aspectRatio}) => Hero(
            tag: 'product_${product.id}',
            child: AspectRatio(
              aspectRatio: aspectRatio ?? 1,
              child: ProductImage(
                thumbnail: product.imageThumbnail,
                medium: product.imageMedium,
                large: product.imageLarge,
                size: ImageSize.large,
              ),
            ),
          );

          Widget detailsSection() => Padding(
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
                  '${product.price.toStringAsFixed(2)} ر.س (شامل الضريبة)',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Builder(
                  builder: (context) {
                    final statusColors = theme.extension<AlhaiStatusColors>()!;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: AlhaiSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: product.isOutOfStock
                            ? statusColors.error.withValues(alpha: 0.1)
                            : statusColors.success.withValues(alpha: 0.1),
                        borderRadius: AlhaiRadius.borderSm,
                      ),
                      child: Text(
                        product.isOutOfStock ? 'غير متوفر' : 'متوفر',
                        style: TextStyle(
                          color: product.isOutOfStock
                              ? statusColors.error
                              : statusColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
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
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final useSideBySide =
                  ResponsiveHelper.isTablet(context) ||
                  ResponsiveHelper.isLandscape(context);

              return Column(
                children: [
                  Expanded(
                    child: useSideBySide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: SingleChildScrollView(
                                  child: imageSection(aspectRatio: 0.85),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: SingleChildScrollView(
                                  child: detailsSection(),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [imageSection(), detailsSection()],
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
                          color: theme.colorScheme.shadow,
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: SafeArea(
                      child: qtyInCart > 0
                          ? Row(
                              children: [
                                AlhaiQuantityControl(
                                  quantity: qtyInCart,
                                  min: 0,
                                  onChanged: (newQty) {
                                    if (newQty <= 0) {
                                      ref
                                          .read(cartProvider.notifier)
                                          .removeItem(product.id);
                                    } else {
                                      ref
                                          .read(cartProvider.notifier)
                                          .updateQty(product.id, newQty);
                                    }
                                  },
                                  decrementSemanticLabel: 'تقليل الكمية',
                                  incrementSemanticLabel: 'زيادة الكمية',
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
                                      HapticFeedback.mediumImpact();
                                      final storeId = store?.id ?? '';
                                      final added = ref
                                          .read(cartProvider.notifier)
                                          .addItem(product, storeId);
                                      if (added) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'تمت إضافة ${product.name}',
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                          ),
                                        );
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('تغيير المتجر'),
                                            content: const Text(
                                              'السلة تحتوي على منتجات من متجر آخر. '
                                              'هل تريد مسح السلة والإضافة من هذا المتجر؟',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx),
                                                child: const Text('إلغاء'),
                                              ),
                                              FilledButton(
                                                onPressed: () {
                                                  ref
                                                      .read(
                                                        cartProvider.notifier,
                                                      )
                                                      .clearAndSwitchStore(
                                                        storeId,
                                                      );
                                                  ref
                                                      .read(
                                                        cartProvider.notifier,
                                                      )
                                                      .addItem(
                                                        product,
                                                        storeId,
                                                      );
                                                  Navigator.pop(ctx);
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        'تمت إضافة ${product.name}',
                                                      ),
                                                      duration: const Duration(
                                                        seconds: 1,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Text('مسح وإضافة'),
                                              ),
                                            ],
                                          ),
                                        );
                                      }
                                    },
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                shape: RoundedRectangleBorder(
                                  borderRadius: AlhaiRadius.borderMd,
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
          );
        },
      ),
    );
  }
}
