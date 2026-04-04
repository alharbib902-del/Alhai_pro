import 'dart:async';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/providers/app_providers.dart';
import '../providers/catalog_providers.dart';
import '../../cart/providers/cart_provider.dart';
import '../widgets/category_chips.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final _scrollController = ScrollController();
  bool _loadingMore = false;
  Timer? _categoryDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _categoryDebounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_loadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    setState(() => _loadingMore = true);
    // TODO: Implement pagination with page tracking
    setState(() => _loadingMore = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = ref.watch(selectedStoreProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    if (store == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('المنتجات')),
        body: const Center(child: Text('اختر متجر أولاً')),
      );
    }

    final categoriesAsync = ref.watch(categoriesProvider(store.id));
    final productsAsync = ref.watch(productsProvider((
      storeId: store.id,
      page: 1,
      categoryId: selectedCategory,
      search: null,
    )));

    return Scaffold(
      appBar: AppBar(
        title: Text(store.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
        children: [
          // Categories
          categoriesAsync.when(
            loading: () => const SizedBox(
              height: 50,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const SizedBox.shrink(),
            data: (categories) => CategoryChips(
              categories: categories,
              selectedId: selectedCategory,
              onSelected: (id) {
                _categoryDebounce?.cancel();
                _categoryDebounce = Timer(
                  const Duration(milliseconds: 500),
                  () {
                    ref.read(selectedCategoryProvider.notifier).state = id;
                  },
                );
              },
            ),
          ),
          // Products grid
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48),
                    const SizedBox(height: AlhaiSpacing.md),
                    Text('فشل تحميل المنتجات',
                        style: theme.textTheme.bodyLarge),
                  ],
                ),
              ),
              data: (paginated) {
                final products = paginated.items;
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: theme.colorScheme.outline),
                        const SizedBox(height: AlhaiSpacing.md),
                        Text('لا توجد منتجات',
                            style: theme.textTheme.titleMedium),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(AlhaiSpacing.sm),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _ProductCard(
                      key: ValueKey(product.id),
                      product: product,
                      onTap: () =>
                          context.push('/products/${product.id}'),
                      onAdd: () {
                        final added = ref
                            .read(cartProvider.notifier)
                            .addItem(product, store.id);
                        if (added) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت إضافة ${product.name}'),
                              duration: const Duration(seconds: 1),
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
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('إلغاء'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    ref
                                        .read(cartProvider.notifier)
                                        .clearAndSwitchStore(store.id);
                                    ref
                                        .read(cartProvider.notifier)
                                        .addItem(product, store.id);
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'تمت إضافة ${product.name}'),
                                        duration:
                                            const Duration(seconds: 1),
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
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onAdd;

  const _ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            AspectRatio(
              aspectRatio: 1,
              child: product.imageThumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageThumbnail!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_outlined, size: 40),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_outlined, size: 40),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Center(
                        child: Icon(
                          Icons.inventory_2_outlined,
                          size: 40,
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs, vertical: AlhaiSpacing.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xxs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(2)} ر.س',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        width: 30,
                        child: IconButton.filled(
                          onPressed: product.isOutOfStock ? null : onAdd,
                          icon: const Icon(Icons.add, size: 16),
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: AlhaiRadius.borderSm,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
