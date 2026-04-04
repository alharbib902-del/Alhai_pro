/// مزودات المنتجات - Products Providers
///
/// توفر حالة المنتجات والتصنيفات للتطبيق
///
/// ## Riverpod v2 Code Generation Migration Path
///
/// This file currently uses manual provider declarations (Riverpod v1 style).
/// When the team decides to migrate to Riverpod v2 code generation, follow
/// these steps:
///
/// ### Prerequisites
/// 1. Add `riverpod_annotation` and `riverpod_generator` to pubspec.yaml
/// 2. Add `build_runner` to dev_dependencies
/// 3. Run `dart run build_runner build` after migration
///
/// ### Migration Examples
///
/// **Before (current):**
/// ```dart
/// final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
///   return GetIt.I<ProductsRepository>();
/// });
/// ```
///
/// **After (v2 code generation):**
/// ```dart
/// @riverpod
/// ProductsRepository productsRepository(Ref ref) {
///   return GetIt.I<ProductsRepository>();
/// }
/// ```
///
/// **StateNotifier → AsyncNotifier:**
/// ```dart
/// @riverpod
/// class ProductsNotifier extends _$ProductsNotifier {
///   @override
///   ProductsState build() => const ProductsState();
///   // ... methods remain the same
/// }
/// ```
///
/// ### Migration Order (recommended)
/// 1. Simple Provider → @riverpod function
/// 2. FutureProvider → @riverpod async function
/// 3. StateNotifierProvider → @riverpod class extending _$ClassName
/// 4. Provider.family → @riverpod function with parameters
///
/// ### Risk Notes
/// - Do NOT migrate all at once; do one provider file at a time
/// - Run full test suite after each file migration
/// - Generated files (.g.dart) must be committed to version control
/// - Family providers change their API (no more `.family<T, Arg>`)
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:get_it/get_it.dart';
import 'package:alhai_auth/alhai_auth.dart';

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// مزود مستودع المنتجات
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return GetIt.I<ProductsRepository>();
});

/// مزود مستودع التصنيفات
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return GetIt.I<CategoriesRepository>();
});

// ============================================================================
// PRODUCTS STATE
// ============================================================================

/// حالة قائمة المنتجات
class ProductsState {
  final List<Product> products;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMore;
  final String? searchQuery;
  final String? categoryId;

  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
    this.searchQuery,
    this.categoryId,
  });

  ProductsState copyWith({
    List<Product>? products,
    bool? isLoading,
    String? error,
    int? currentPage,
    bool? hasMore,
    String? searchQuery,
    String? categoryId,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

// ============================================================================
// PRODUCTS NOTIFIER
// ============================================================================

/// مُدير حالة المنتجات
/// تم تحسينه لنقل الفلترة والبحث إلى SQL بدلاً من Dart
class ProductsNotifier extends StateNotifier<ProductsState> {
  final ProductsRepository _productsRepository;

  ProductsNotifier(this._productsRepository) : super(const ProductsState());

  /// تحميل المنتجات - محسّن مع الفلترة على مستوى SQL
  /// عند refresh=true، لا نمسح المنتجات القديمة حتى تصل الجديدة (بدون وميض)
  Future<void> loadProducts({
    required String storeId,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        hasMore: true,
        isLoading: true,
        // لا نمسح products - نبقي القديمة مرئية حتى تصل الجديدة
      );
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final result = await _productsRepository.getProducts(
        storeId,
        page: refresh ? 1 : state.currentPage,
        limit: 20,
        categoryId: state.categoryId,
        searchQuery: state.searchQuery,
      );

      final newProducts =
          refresh ? result.items : [...state.products, ...result.items];

      state = state.copyWith(
        products: newProducts,
        isLoading: false,
        currentPage: (refresh ? 1 : state.currentPage) + 1,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// البحث في المنتجات (لا يمسح القائمة - يستبدلها عند وصول النتائج)
  Future<void> search(String query, {String? storeId}) async {
    state = state.copyWith(
      searchQuery: query.isEmpty ? null : query,
      currentPage: 1,
      hasMore: true,
      // لا نمسح products - نبقي القديمة مرئية
    );
    if (storeId != null) {
      await loadProducts(storeId: storeId, refresh: true);
    }
  }

  /// تصفية حسب التصنيف (انتقال سلس بدون وميض)
  Future<void> filterByCategory(String? categoryId, {String? storeId}) async {
    state = state.copyWith(
      categoryId: categoryId,
      currentPage: 1,
      hasMore: true,
      // لا نمسح products - نبقي القديمة مرئية
    );
    if (storeId != null) {
      await loadProducts(storeId: storeId, refresh: true);
    }
  }

  /// تحميل المزيد
  Future<void> loadMore({required String storeId}) async {
    if (!state.hasMore || state.isLoading) return;
    await loadProducts(storeId: storeId);
  }

  /// مسح الخطأ
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود حالة المنتجات
final productsStateProvider =
    StateNotifierProvider<ProductsNotifier, ProductsState>((ref) {
  final productsRepository = ref.watch(productsRepositoryProvider);
  return ProductsNotifier(productsRepository);
});

/// مزود قائمة المنتجات (اختصار)
/// يستخدم .select() لتجنب إعادة البناء عند تغيير حقول أخرى (isLoading, error, etc.)
final productsListProvider = Provider<List<Product>>((ref) {
  return ref.watch(productsStateProvider.select((state) => state.products));
});

/// مزود منتج واحد بالـ ID - محسّن باستخدام Map للبحث السريع
final productByIdProvider =
    Provider.autoDispose.family<Product?, String>((ref, id) {
  final productsMap = ref.watch(productsMapProvider);
  return productsMap[id];
});

/// مزود خريطة المنتجات (للبحث السريع O(1) بدلاً من O(n))
/// يُعاد بناؤه فقط عند تغيير قائمة المنتجات الفعلية بفضل select()
/// في productsListProvider - لا يتأثر بتغييرات isLoading أو error أو currentPage
final productsMapProvider = Provider<Map<String, Product>>((ref) {
  final products = ref.watch(productsListProvider);
  return Map.unmodifiable({for (final p in products) p.id: p});
});

/// مزود المنتجات منخفضة المخزون
/// Uses .select() to only rebuild when the filtered low-stock list actually changes,
/// rather than on every mutation of the full products list (L58 fix).
final lowStockProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(
    productsStateProvider
        .select((state) => state.products.where((p) => p.isLowStock).toList()),
  );
  return products;
});

/// مزود المنتجات النفذة
/// Uses .select() to only rebuild when the filtered out-of-stock list actually changes (L58 fix).
final outOfStockProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(
    productsStateProvider.select(
        (state) => state.products.where((p) => p.isOutOfStock).toList()),
  );
  return products;
});

// ============================================================================
// CATEGORIES PROVIDERS
// ============================================================================

/// مزود التصنيفات - مع Cache (keepAlive) لتجنب إعادة الجلب
final categoriesProvider =
    FutureProvider.autoDispose<List<Category>>((ref) async {
  // الإبقاء على البيانات في الذاكرة لمدة 5 دقائق
  final link = ref.keepAlive();

  // إلغاء الحفظ بعد 5 دقائق من عدم الاستخدام (Timer قابل للإلغاء)
  final timer = Timer(const Duration(minutes: 5), () {
    link.close();
  });
  ref.onDispose(() => timer.cancel());

  final repository = ref.watch(categoriesRepositoryProvider);
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  return repository.getCategories(storeId);
});

/// مزود خريطة التصنيفات (للبحث السريع)
final categoriesMapProvider = Provider<Map<String, Category>>((ref) {
  final categoriesAsync = ref.watch(categoriesProvider);
  return categoriesAsync.maybeWhen(
    data: (categories) => {for (final c in categories) c.id: c},
    orElse: () => {},
  );
});

/// مزود تصنيف واحد بالـ ID - محسّن
final categoryByIdProvider =
    Provider.autoDispose.family<Category?, String>((ref, id) {
  final categoriesMap = ref.watch(categoriesMapProvider);
  return categoriesMap[id];
});

// ============================================================================
// FTS SEARCH PROVIDERS - البحث السريع باستخدام Full-Text Search
// ============================================================================

/// مزود البحث بالباركود - يستخدم من BarcodeListener
final barcodeProductProvider =
    FutureProvider.autoDispose.family<Product?, String>((ref, barcode) async {
  if (barcode.isEmpty) return null;
  final repository = ref.watch(productsRepositoryProvider);
  return repository.getByBarcode(barcode);
});

/// مزود اقتراحات البحث (autocomplete)
/// يعطي اقتراحات أثناء الكتابة
final searchSuggestionsProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, query) async {
  if (query.length < 2) return [];

  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  // FTS سيكون متاحاً في المستقبل من خلال ProductsRepository
  // حالياً نعيد قائمة فارغة
  return [];
});
