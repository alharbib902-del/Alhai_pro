/// مزودات المنتجات - Products Providers
///
/// توفر حالة المنتجات والتصنيفات للتطبيق
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// مزود مستودع المنتجات
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return getIt<ProductsRepository>();
});

/// مزود مستودع التصنيفات
final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return getIt<CategoriesRepository>();
});

/// معرّف المتجر الافتراضي للتطوير (يتوافق مع DatabaseSeeder)
const String kDemoStoreId = 'store_demo_001';

/// مزود معرّف المتجر الحالي (يجب تعيينه عند تسجيل الدخول)
/// يستخدم المعرّف الافتراضي في وضع التطوير
final currentStoreIdProvider = StateProvider<String?>((ref) => kDemoStoreId);

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
  Future<void> loadProducts({
    required String storeId,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

    if (refresh) {
      state = state.copyWith(
        currentPage: 1,
        hasMore: true,
        products: [],
      );
    }

    state = state.copyWith(isLoading: true);

    try {
      // تم نقل الفلترة والبحث إلى Repository/DAO (SQL level)
      // بدلاً من تحميل جميع البيانات وفلترتها في Dart
      final result = await _productsRepository.getProducts(
        storeId,
        page: state.currentPage,
        limit: 20,
        categoryId: state.categoryId,  // تمرير للـ SQL
        searchQuery: state.searchQuery,  // تمرير للـ SQL
      );

      // الآن النتائج مفلترة مسبقاً من قاعدة البيانات
      final newProducts = refresh ? result.items : [...state.products, ...result.items];

      state = state.copyWith(
        products: newProducts,
        isLoading: false,
        currentPage: state.currentPage + 1,
        hasMore: result.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// البحث في المنتجات
  Future<void> search(String query, {String? storeId}) async {
    state = state.copyWith(
      searchQuery: query.isEmpty ? null : query,
      currentPage: 1,
      hasMore: true,
      products: [],
    );
    if (storeId != null) {
      await loadProducts(storeId: storeId, refresh: true);
    }
  }

  /// تصفية حسب التصنيف
  Future<void> filterByCategory(String? categoryId, {String? storeId}) async {
    state = state.copyWith(
      categoryId: categoryId,
      currentPage: 1,
      hasMore: true,
      products: [],
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
final productsListProvider = Provider<List<Product>>((ref) {
  return ref.watch(productsStateProvider).products;
});

/// مزود منتج واحد بالـ ID - محسّن باستخدام Map للبحث السريع
final productByIdProvider = Provider.family<Product?, String>((ref, id) {
  final productsMap = ref.watch(productsMapProvider);
  return productsMap[id];
});

/// مزود خريطة المنتجات (للبحث السريع O(1) بدلاً من O(n))
final productsMapProvider = Provider<Map<String, Product>>((ref) {
  final products = ref.watch(productsListProvider);
  return {for (final p in products) p.id: p};
});

/// مزود المنتجات منخفضة المخزون
final lowStockProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsListProvider);
  return products.where((p) => p.isLowStock).toList();
});

/// مزود المنتجات النفذة
final outOfStockProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsListProvider);
  return products.where((p) => p.isOutOfStock).toList();
});

// ============================================================================
// CATEGORIES PROVIDERS
// ============================================================================

/// مزود التصنيفات - مع Cache (keepAlive) لتجنب إعادة الجلب
final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  // الإبقاء على البيانات في الذاكرة لمدة 5 دقائق
  final link = ref.keepAlive();

  // إلغاء الحفظ بعد 5 دقائق من عدم الاستخدام
  // ignore: unused_local_variable - used for side effect only
  final _ = Future.delayed(const Duration(minutes: 5), () {
    link.close();
  });

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
final categoryByIdProvider = Provider.family<Category?, String>((ref, id) {
  final categoriesMap = ref.watch(categoriesMapProvider);
  return categoriesMap[id];
});

// ============================================================================
// FTS SEARCH PROVIDERS - البحث السريع باستخدام Full-Text Search
// ============================================================================

/// مزود البحث بالباركود - يستخدم من BarcodeListener
final barcodeProductProvider =
    FutureProvider.family<Product?, String>((ref, barcode) async {
  if (barcode.isEmpty) return null;
  final repository = ref.watch(productsRepositoryProvider);
  return repository.getByBarcode(barcode);
});

/// مزود اقتراحات البحث (autocomplete)
/// يعطي اقتراحات أثناء الكتابة
final searchSuggestionsProvider =
    FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.length < 2) return [];

  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  // FTS سيكون متاحاً في المستقبل من خلال ProductsRepository
  // حالياً نعيد قائمة فارغة
  return [];
});
