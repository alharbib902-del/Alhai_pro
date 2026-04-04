import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/products_table.dart';
import '../fts/products_fts.dart';

part 'products_dao.g.dart';

/// Escape special LIKE characters (%, _, \) in user input
String _escapeLikePattern(String input) {
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('%', '\\%')
      .replaceAll('_', '\\_');
}

/// DAO للمنتجات
@DriftAccessor(tables: [ProductsTable])
class ProductsDao extends DatabaseAccessor<AppDatabase> with _$ProductsDaoMixin {
  ProductsDao(super.db);

  /// خدمة البحث السريع FTS
  late final ProductsFtsService _ftsService = ProductsFtsService(db);

  /// الحصول على خدمة FTS
  ProductsFtsService get ftsService => _ftsService;
  
  /// الحصول على جميع المنتجات للمتجر (باستثناء المحذوفة)
  Future<List<ProductsTableData>> getAllProducts(String storeId, {int limit = 5000}) {
    return (select(productsTable)
      ..where((p) => p.storeId.equals(storeId) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
      ..limit(limit))
      .get();
  }

  /// فحص سريع: هل يوجد منتجات للمتجر؟ (بدون تحميل كل البيانات)
  Future<bool> hasProducts(String storeId) async {
    final result = await (select(productsTable)
      ..where((p) => p.storeId.equals(storeId) & p.deletedAt.isNull())
      ..limit(1))
      .get();
    return result.isNotEmpty;
  }

  /// الحصول على منتج بالمعرف
  Future<ProductsTableData?> getProductById(String id) {
    return (select(productsTable)..where((p) => p.id.equals(id)))
      .getSingleOrNull();
  }
  
  /// الحصول على منتج بالباركود
  Future<ProductsTableData?> getProductByBarcode(String barcode, String storeId) {
    return (select(productsTable)
      ..where((p) => p.barcode.equals(barcode) & p.storeId.equals(storeId)))
      .getSingleOrNull();
  }
  
  /// البحث في المنتجات (يستخدم FTS إذا متاح)
  Future<List<ProductsTableData>> searchProducts(String query, String storeId) async {
    // محاولة البحث بـ FTS أولاً للأداء الأفضل
    try {
      if (await _ftsService.isFtsTableExists()) {
        final ftsResults = await _ftsService.search(query, storeId);
        if (ftsResults.isNotEmpty) {
          // تحويل نتائج FTS إلى ProductsTableData
          final ids = ftsResults.map((r) => r.id).toList();
          return (select(productsTable)
            ..where((p) => p.id.isIn(ids) & p.storeId.equals(storeId)))
            .get();
        }
      }
    } catch (_) {
      // إذا فشل FTS، نستخدم البحث العادي
    }

    // البحث التقليدي كـ fallback
    final escaped = _escapeLikePattern(query);
    return (select(productsTable)
      ..where((p) =>
        p.storeId.equals(storeId) &
        (p.name.like('%$escaped%') | p.barcode.like('%$escaped%') | p.sku.like('%$escaped%'))
      )
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
      ..limit(200))
      .get();
  }

  /// البحث السريع باستخدام FTS مباشرة
  /// يعيد النتائج مرتبة حسب الصلة
  Future<List<FtsSearchResult>> searchWithFts(
    String query,
    String storeId, {
    int limit = 20,
    int offset = 0,
  }) {
    return _ftsService.search(query, storeId, limit: limit, offset: offset);
  }

  /// اقتراحات البحث (autocomplete)
  Future<List<String>> getSearchSuggestions(
    String query,
    String storeId, {
    int limit = 5,
  }) {
    return _ftsService.getSuggestions(query, storeId, limit: limit);
  }

  /// تهيئة FTS (يجب استدعاؤها عند بدء التطبيق)
  Future<void> initializeFts() async {
    await _ftsService.createFtsTable();
  }

  /// إعادة بناء فهرس FTS
  Future<void> rebuildFtsIndex() async {
    await _ftsService.rebuildFtsIndex();
  }
  
  /// الحصول على منتجات التصنيف
  Future<List<ProductsTableData>> getProductsByCategory(String categoryId, String storeId) {
    return (select(productsTable)
      ..where((p) => p.categoryId.equals(categoryId) & p.storeId.equals(storeId))
      ..orderBy([(p) => OrderingTerm.asc(p.name)]))
      .get();
  }
  
  /// الحصول على المنتجات منخفضة المخزون
  Future<List<ProductsTableData>> getLowStockProducts(String storeId) {
    return customSelect(
      '''SELECT p.* FROM products p
         WHERE p.store_id = ? AND p.stock_qty <= p.min_qty AND p.is_active = 1
               AND p.deleted_at IS NULL
         LIMIT 500''',
      variables: [Variable.withString(storeId)],
      readsFrom: {productsTable},
    ).map((row) => productsTable.map(row.data)).get();
  }
  
  /// إدراج منتج
  Future<int> insertProduct(ProductsTableCompanion product) {
    return into(productsTable).insert(product);
  }
  
  /// إدراج أو تحديث منتج
  Future<int> upsertProduct(ProductsTableCompanion product) {
    return into(productsTable).insertOnConflictUpdate(product);
  }
  
  /// تحديث منتج
  Future<bool> updateProduct(ProductsTableData product) {
    return update(productsTable).replace(product);
  }
  
  /// تحديث المخزون
  Future<int> updateStock(String productId, double newQty) {
    return (update(productsTable)..where((p) => p.id.equals(productId)))
      .write(ProductsTableCompanion(
        stockQty: Value(newQty),
        updatedAt: Value(DateTime.now()),
      ));
  }
  
  /// حذف منتج
  Future<int> deleteProduct(String id) {
    return (delete(productsTable)..where((p) => p.id.equals(id))).go();
  }
  
  /// تعيين تاريخ المزامنة
  Future<int> markAsSynced(String id) {
    return (update(productsTable)..where((p) => p.id.equals(id)))
      .write(ProductsTableCompanion(syncedAt: Value(DateTime.now())));
  }
  
  /// الحصول على المنتجات غير المزامنة
  Future<List<ProductsTableData>> getUnsyncedProducts({String? storeId}) {
    final q = select(productsTable)..where((p) => p.syncedAt.isNull());
    if (storeId != null) {
      q.where((p) => p.storeId.equals(storeId));
    }
    return (q..limit(500)).get();
  }

  /// مراقبة المنتجات (Stream) - باستثناء المحذوفة
  /// [limit] - الحد الأقصى للنتائج (افتراضي 500)
  Stream<List<ProductsTableData>> watchProducts(String storeId, {int limit = 500}) {
    return (select(productsTable)
      ..where((p) => p.storeId.equals(storeId) & p.isActive.equals(true) & p.deletedAt.isNull())
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
      ..limit(limit))
      .watch();
  }

  // ============================================================================
  // Pagination Methods - تحسينات الأداء للقوائم الطويلة
  // ============================================================================

  /// الحصول على منتجات مع Pagination
  /// [offset] - عدد العناصر للتخطي
  /// [limit] - الحد الأقصى للنتائج (افتراضي 20)
  Future<List<ProductsTableData>> getProductsPaginated(
    String storeId, {
    int offset = 0,
    int limit = 20,
    String? categoryId,
    bool activeOnly = true,
  }) {
    var query = select(productsTable)
      ..where((p) {
        var condition = p.storeId.equals(storeId) & p.deletedAt.isNull();
        if (activeOnly) {
          condition = condition & p.isActive.equals(true);
        }
        if (categoryId != null) {
          condition = condition & p.categoryId.equals(categoryId);
        }
        return condition;
      })
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
      ..limit(limit, offset: offset);

    return query.get();
  }

  /// عدد المنتجات الكلي (للـ pagination)
  Future<int> getProductsCount(
    String storeId, {
    String? categoryId,
    bool activeOnly = true,
  }) async {
    final countExpression = productsTable.id.count();

    var query = selectOnly(productsTable)
      ..addColumns([countExpression])
      ..where(productsTable.storeId.equals(storeId));

    if (activeOnly) {
      query.where(productsTable.isActive.equals(true));
    }
    if (categoryId != null) {
      query.where(productsTable.categoryId.equals(categoryId));
    }

    final result = await query.getSingle();
    return result.read(countExpression) ?? 0;
  }

  /// البحث في المنتجات مع Pagination (باستثناء المحذوفة)
  Future<List<ProductsTableData>> searchProductsPaginated(
    String query,
    String storeId, {
    int offset = 0,
    int limit = 20,
  }) {
    final searchPattern = '%${_escapeLikePattern(query)}%';

    return (select(productsTable)
      ..where((p) =>
        p.storeId.equals(storeId) &
        p.isActive.equals(true) &
        p.deletedAt.isNull() &
        (p.name.like(searchPattern) | p.barcode.like(searchPattern) | p.sku.like(searchPattern))
      )
      ..orderBy([(p) => OrderingTerm.asc(p.name)])
      ..limit(limit, offset: offset))
      .get();
  }

  /// البحث السريع بالباركود مع cache
  /// يستخدم index على barcode للأداء الأمثل
  Future<ProductsTableData?> quickFindByBarcode(String barcode, String storeId) {
    // الباركود يجب أن يكون دقيقاً
    return (select(productsTable)
      ..where((p) => p.barcode.equals(barcode) & p.storeId.equals(storeId) & p.isActive.equals(true))
      ..limit(1))
      .getSingleOrNull();
  }

  /// L60: Batch-load multiple products by their IDs in a single query.
  /// Eliminates N+1 query overhead when loading products for orders/carts.
  ///
  /// Uses `WHERE id IN (...)` for efficient bulk fetching.
  /// [ids] - list of product IDs to fetch
  Future<List<ProductsTableData>> getProductsByIds(List<String> ids) {
    if (ids.isEmpty) return Future.value([]);

    return (select(productsTable)
      ..where((p) => p.id.isIn(ids)))
      .get();
  }

  /// L60: Batch-load multiple products by their barcodes in a single query.
  /// Useful for scanning multiple items quickly.
  Future<List<ProductsTableData>> getProductsByBarcodes(
    List<String> barcodes,
    String storeId,
  ) {
    if (barcodes.isEmpty) return Future.value([]);

    return (select(productsTable)
      ..where((p) =>
        p.barcode.isIn(barcodes) &
        p.storeId.equals(storeId) &
        p.isActive.equals(true)))
      .get();
  }

  /// الحصول على المنتجات الأكثر مبيعاً (للعرض السريع)
  /// يتطلب join مع جدول sale_items
  /// [since] - فلتر التاريخ لتحديد فترة التقرير (مثلاً آخر 30 يوم)
  Future<List<ProductsTableData>> getTopSellingProducts(
    String storeId, {
    int limit = 10,
    DateTime? since,
  }) {
    // استخدام raw query للأداء
    // Always JOIN sales to scope by store and exclude voided/deleted sales
    final sinceClause = since != null ? ' AND s.created_at > ?' : '';
    final variables = <Variable>[Variable.withString(storeId)];
    if (since != null) {
      variables.add(Variable.withDateTime(since));
    }
    variables.addAll([Variable.withInt(limit), Variable.withString(storeId)]);

    return customSelect(
      '''SELECT p.* FROM products p
         INNER JOIN (
           SELECT si.product_id, COUNT(*) as sale_count
           FROM sale_items si
           INNER JOIN sales s ON si.sale_id = s.id
           WHERE s.store_id = ? AND s.status != 'voided' AND s.deleted_at IS NULL$sinceClause
           GROUP BY si.product_id
           ORDER BY sale_count DESC
           LIMIT ?
         ) top ON p.id = top.product_id
         WHERE p.store_id = ? AND p.is_active = 1 AND p.deleted_at IS NULL
         ORDER BY top.sale_count DESC''',
      variables: variables,
      readsFrom: {productsTable},
    ).map((row) => productsTable.map(row.data)).get();
  }

  // ============================================================================
  // H03: JOIN queries - استعلامات مع ربط الجداول
  // ============================================================================

  /// منتج مع اسم التصنيف
  Future<ProductWithCategory?> getProductWithCategory(String id) async {
    final result = await customSelect(
      '''SELECT p.*, c.name as category_name
         FROM products p
         LEFT JOIN categories c ON p.category_id = c.id
         WHERE p.id = ?''',
      variables: [Variable.withString(id)],
      readsFrom: {productsTable},
    ).get();

    if (result.isEmpty) return null;
    final row = result.first;
    return ProductWithCategory(
      product: productsTable.map(row.data),
      categoryName: row.data['category_name'] as String?,
    );
  }

  /// منتجات منخفضة المخزون مع التصنيف
  Future<List<ProductWithCategory>> getLowStockWithCategory(String storeId) async {
    final result = await customSelect(
      '''SELECT p.*, c.name as category_name
         FROM products p
         LEFT JOIN categories c ON p.category_id = c.id
         WHERE p.store_id = ? AND p.stock_qty <= p.min_qty AND p.is_active = 1
         ORDER BY p.stock_qty ASC''',
      variables: [Variable.withString(storeId)],
      readsFrom: {productsTable},
    ).get();

    return result.map((row) => ProductWithCategory(
      product: productsTable.map(row.data),
      categoryName: row.data['category_name'] as String?,
    )).toList();
  }

  /// تحديث صور المنتج (بعد رفعها إلى Supabase Storage)
  Future<int> updateProductImages(
    String productId, {
    String? imageThumbnail,
    String? imageMedium,
    String? imageLarge,
    String? imageHash,
  }) {
    return (update(productsTable)..where((p) => p.id.equals(productId)))
        .write(ProductsTableCompanion(
      imageThumbnail: imageThumbnail != null ? Value(imageThumbnail) : const Value.absent(),
      imageMedium: imageMedium != null ? Value(imageMedium) : const Value.absent(),
      imageLarge: imageLarge != null ? Value(imageLarge) : const Value.absent(),
      imageHash: imageHash != null ? Value(imageHash) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    ));
  }

  /// تحديث batch للمنتجات (لتحسين الأداء)
  Future<void> batchUpdateStock(Map<String, double> stockUpdates) async {
    await batch((b) {
      for (final entry in stockUpdates.entries) {
        b.update(
          productsTable,
          ProductsTableCompanion(
            stockQty: Value(entry.value),
            updatedAt: Value(DateTime.now()),
          ),
          where: (p) => p.id.equals(entry.key),
        );
      }
    });
  }
}

/// منتج مع اسم التصنيف
class ProductWithCategory {
  final ProductsTableData product;
  final String? categoryName;

  const ProductWithCategory({required this.product, this.categoryName});
}
