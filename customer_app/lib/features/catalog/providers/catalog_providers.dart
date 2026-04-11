import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';

import '../../../di/injection.dart';
import '../data/products_datasource.dart';
import '../data/categories_datasource.dart';

/// Products for a store with optional filters.
final productsProvider =
    FutureProvider.family<
      Paginated<Product>,
      ({String storeId, int page, String? categoryId, String? search})
    >((ref, params) async {
      final datasource = locator<ProductsDatasource>();
      return datasource.getProducts(
        params.storeId,
        page: params.page,
        categoryId: params.categoryId,
        searchQuery: params.search,
      );
    });

/// Categories for a store.
final categoriesProvider = FutureProvider.family<List<Category>, String>((
  ref,
  storeId,
) async {
  final datasource = locator<CategoriesDatasource>();
  return datasource.getRootCategories(storeId);
});

/// Single product detail.
final productDetailProvider = FutureProvider.family<Product, String>((
  ref,
  productId,
) async {
  final datasource = locator<ProductsDatasource>();
  return datasource.getProduct(productId);
});

/// Selected category filter.
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Search query.
final searchQueryProvider = StateProvider<String>((ref) => '');
