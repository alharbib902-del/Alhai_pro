import 'dart:async';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../catalog/providers/catalog_providers.dart';
import '../../cart/providers/cart_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = ref.watch(selectedStoreProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'رجوع',
          onPressed: () => context.pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'ابحث عن منتج...',
            border: InputBorder.none,
          ),
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              tooltip: 'مسح البحث',
              onPressed: () {
                _searchController.clear();
                setState(() => _query = '');
              },
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: _query.isEmpty || store == null
            ? Center(
                child: AlhaiEmptyState.noResults(
                  title: 'ابحث باسم المنتج أو الباركود',
                ),
              )
            : Consumer(
                builder: (context, ref, _) {
                  final resultsAsync = ref.watch(
                    productsProvider((
                      storeId: store.id,
                      page: 1,
                      categoryId: null,
                      search: _query,
                    )),
                  );

                  return resultsAsync.when(
                    loading: () => AlhaiShimmer(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AlhaiSpacing.sm),
                        itemCount: 6,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AlhaiSpacing.sm,
                          ),
                          child: AlhaiSkeleton.listTile(),
                        ),
                      ),
                    ),
                    error: (_, __) => Center(
                      child: AlhaiEmptyState.error(
                        title: 'فشل البحث',
                        description: 'تحقق من اتصالك بالإنترنت',
                      ),
                    ),
                    data: (paginated) {
                      if (paginated.items.isEmpty) {
                        return Center(
                          child: AlhaiEmptyState.noResults(
                            title: 'لا توجد نتائج',
                            description: 'جرب كلمات بحث مختلفة',
                          ),
                        );
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(
                            productsProvider((
                              storeId: store.id,
                              page: 1,
                              categoryId: null,
                              search: _query,
                            )),
                          );
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AlhaiSpacing.sm),
                          itemCount: paginated.items.length,
                          itemBuilder: (context, index) {
                            final product = paginated.items[index];
                            return ListTile(
                              leading: SizedBox(
                                width: 48,
                                height: 48,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: ProductImage(
                                    thumbnail: product.imageThumbnail,
                                    medium: product.imageMedium,
                                    large: product.imageLarge,
                                    size: ImageSize.thumbnail,
                                    width: 48,
                                    height: 48,
                                  ),
                                ),
                              ),
                              title: Text(product.name),
                              subtitle: Text(
                                '${(product.price / 100.0).toStringAsFixed(2)} ر.س',
                                style: TextStyle(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: IconButton.filled(
                                onPressed: product.isOutOfStock
                                    ? null
                                    : () {
                                        final added = ref
                                            .read(cartProvider.notifier)
                                            .addItem(product, store.id);
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
                                                          store.id,
                                                        );
                                                    ref
                                                        .read(
                                                          cartProvider.notifier,
                                                        )
                                                        .addItem(
                                                          product,
                                                          store.id,
                                                        );
                                                    Navigator.pop(ctx);
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          'تمت إضافة ${product.name}',
                                                        ),
                                                        duration:
                                                            const Duration(
                                                              seconds: 1,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text(
                                                    'مسح وإضافة',
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }
                                      },
                                icon: const Icon(Icons.add, size: 18),
                              ),
                              onTap: () =>
                                  context.push('/products/${product.id}'),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
