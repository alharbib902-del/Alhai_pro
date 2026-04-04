import 'dart:async';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: AlhaiSpacing.md),
                  Text(
                    'ابحث باسم المنتج أو الباركود',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            )
          : Consumer(
              builder: (context, ref, _) {
                final resultsAsync = ref.watch(productsProvider((
                  storeId: store.id,
                  page: 1,
                  categoryId: null,
                  search: _query,
                )));

                return resultsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(
                    child: Text('فشل البحث'),
                  ),
                  data: (paginated) {
                    if (paginated.items.isEmpty) {
                      return Center(
                        child: Text(
                          'لا توجد نتائج',
                          style: theme.textTheme.bodyLarge,
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(AlhaiSpacing.sm),
                      itemCount: paginated.items.length,
                      itemBuilder: (context, index) {
                        final product = paginated.items[index];
                        return ListTile(
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color:
                                  theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: product.imageThumbnail != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: product.imageThumbnail!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.image_outlined),
                                      placeholder: (_, __) => Icon(
                                          Icons.image_outlined,
                                          color: theme.colorScheme.outline),
                                    ),
                                  )
                                : const Icon(Icons.inventory_2_outlined),
                          ),
                          title: Text(product.name),
                          subtitle: Text(
                            '${product.price.toStringAsFixed(2)} ر.س',
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'تمت إضافة ${product.name}'),
                                          duration:
                                              const Duration(seconds: 1),
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
                                                    .read(cartProvider
                                                        .notifier)
                                                    .clearAndSwitchStore(
                                                        store.id);
                                                ref
                                                    .read(cartProvider
                                                        .notifier)
                                                    .addItem(
                                                        product, store.id);
                                                Navigator.pop(ctx);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'تمت إضافة ${product.name}'),
                                                    duration: const Duration(
                                                        seconds: 1),
                                                  ),
                                                );
                                              },
                                              child:
                                                  const Text('مسح وإضافة'),
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
                    );
                  },
                );
              },
            ),
      ),
    );
  }
}
