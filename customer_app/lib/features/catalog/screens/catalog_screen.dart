import 'dart:async';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/services/sentry_service.dart';
import '../../../core/utils/responsive_helper.dart';
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

  // Pagination state
  int _currentPage = 1;
  bool _hasMore = true;
  List<Product> _allProducts = [];
  bool _initialLoading = true;

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
        !_loadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore) return;
    if (mounted) setState(() => _loadingMore = true);

    final store = ref.read(selectedStoreProvider);
    final selectedCategory = ref.read(selectedCategoryProvider);
    if (store == null) {
      if (mounted) setState(() => _loadingMore = false);
      return;
    }

    final nextPage = _currentPage + 1;
    try {
      final paginated = await ref.read(
        productsProvider((
          storeId: store.id,
          page: nextPage,
          categoryId: selectedCategory,
          search: null,
        )).future,
      );

      if (mounted) {
        setState(() {
          _currentPage = nextPage;
          _allProducts = [..._allProducts, ...paginated.items];
          _hasMore = paginated.hasMore;
          _loadingMore = false;
        });
      }
    } catch (e, stack) {
      reportError(e, stackTrace: stack, hint: 'CatalogScreen._loadMore');
      if (mounted) {
        setState(() => _loadingMore = false);
      }
    }
  }

  void _resetPagination() {
    _currentPage = 1;
    _hasMore = true;
    _allProducts = [];
    _initialLoading = true;
  }

  Future<void> _onRefresh() async {
    _resetPagination();
    final store = ref.read(selectedStoreProvider);
    final selectedCategory = ref.read(selectedCategoryProvider);
    if (store == null) return;

    ref.invalidate(
      productsProvider((
        storeId: store.id,
        page: 1,
        categoryId: selectedCategory,
        search: null,
      )),
    );
    ref.invalidate(categoriesProvider(store.id));
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(selectedStoreProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    if (store == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('المنتجات')),
        body: const Center(child: Text('اختر متجر أولاً')),
      );
    }

    // FIX 4: Use select() to only rebuild when the actual data changes
    final categories = ref.watch(
      categoriesProvider(store.id).select((v) => v.valueOrNull ?? <Category>[]),
    );
    final categoriesLoading = ref.watch(
      categoriesProvider(store.id).select((v) => v.isLoading),
    );

    final productsAsync = ref.watch(
      productsProvider((
        storeId: store.id,
        page: 1,
        categoryId: selectedCategory,
        search: null,
      )),
    );

    // When page 1 loads, seed _allProducts
    if (_initialLoading) {
      productsAsync.whenData((paginated) {
        if (_initialLoading) {
          _allProducts = paginated.items;
          _hasMore = paginated.hasMore;
          _currentPage = 1;
          _initialLoading = false;
        }
      });
    }

    // Reset pagination when category changes
    ref.listen(selectedCategoryProvider, (prev, next) {
      if (prev != next) {
        _resetPagination();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(store.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'رجوع',
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'البحث عن منتج',
            onPressed: () => context.push('/search'),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Categories
            categoriesLoading
                ? SizedBox(
                    height: 50,
                    child: AlhaiShimmer(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AlhaiSpacing.md,
                        ),
                        child: Row(
                          children: List.generate(
                            4,
                            (_) => Padding(
                              padding: const EdgeInsetsDirectional.only(
                                end: AlhaiSpacing.xs,
                              ),
                              child: AlhaiSkeleton.rectangle(
                                width: 70,
                                height: 32,
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : CategoryChips(
                    categories: categories,
                    selectedId: selectedCategory,
                    onSelected: (id) {
                      _categoryDebounce?.cancel();
                      _categoryDebounce = Timer(
                        const Duration(milliseconds: 500),
                        () {
                          ref.read(selectedCategoryProvider.notifier).state =
                              id;
                        },
                      );
                    },
                  ),
            // Products grid
            Expanded(
              child: productsAsync.when(
                loading: () => AlhaiShimmer(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(AlhaiSpacing.sm),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: 6,
                    itemBuilder: (context, index) =>
                        AlhaiSkeleton.productCard(),
                  ),
                ),
                error: (error, _) => Center(
                  child: AlhaiEmptyState.error(
                    title: 'فشل تحميل المنتجات',
                    description: 'تحقق من اتصالك بالإنترنت',
                    actionText: 'إعادة المحاولة',
                    onAction: _onRefresh,
                  ),
                ),
                data: (paginated) {
                  final products = _allProducts.isNotEmpty
                      ? _allProducts
                      : paginated.items;
                  if (products.isEmpty) {
                    return Center(
                      child: AlhaiEmptyState.noProducts(
                        title: 'لا توجد منتجات',
                        description: 'جرب تصنيف آخر',
                      ),
                    );
                  }

                  final isTablet = ResponsiveHelper.isTablet(context);
                  final isLandscape = ResponsiveHelper.isLandscape(context);
                  final columns = ResponsiveHelper.getGridColumns(context);
                  final gridPadding = isTablet
                      ? const EdgeInsets.all(AlhaiSpacing.md)
                      : const EdgeInsets.all(AlhaiSpacing.sm);
                  final aspectRatio = isLandscape ? 0.80 : 0.72;

                  // FIX 3: Wrap GridView with RefreshIndicator
                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: gridPadding,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: isTablet ? 14 : 10,
                        mainAxisSpacing: isTablet ? 14 : 10,
                      ),
                      // +1 for loading indicator when loading more
                      itemCount: products.length + (_loadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Loading indicator at the bottom
                        if (index >= products.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(AlhaiSpacing.md),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final product = products[index];
                        return _ProductCard(
                          key: ValueKey(product.id),
                          product: product,
                          onTap: () => context.push('/products/${product.id}'),
                          onAdd: () {
                            HapticFeedback.lightImpact();
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
                        );
                      },
                    ),
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
            Hero(
              tag: 'product_${product.id}',
              child: AspectRatio(
                aspectRatio: 1,
                child: ProductImage(
                  thumbnail: product.imageThumbnail,
                  medium: product.imageMedium,
                  large: product.imageLarge,
                  size: ImageSize.thumbnail,
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AlhaiSpacing.xs,
                vertical: AlhaiSpacing.xs,
              ),
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
                      Semantics(
                        label: 'إضافة ${product.name} للسلة',
                        button: true,
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: IconButton.filled(
                            onPressed: product.isOutOfStock ? null : onAdd,
                            icon: const Icon(Icons.add, size: 16),
                            tooltip: 'إضافة للسلة',
                            padding: EdgeInsets.zero,
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: AlhaiRadius.borderSm,
                              ),
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
