/// Product-related providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models.dart';
import 'distributor_datasource_provider.dart';

// ─── Products ───────────────────────────────────────────────────

final productsProvider = FutureProvider<List<DistributorProduct>>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getProducts();
});

final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getCategories();
});

/// Categories with IDs for product creation forms.
final categoriesWithIdsProvider =
    FutureProvider<List<({String id, String name})>>((ref) async {
  final ds = ref.watch(distributorDatasourceProvider);
  return ds.getCategoriesWithIds();
});
