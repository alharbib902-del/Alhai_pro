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
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(super.db);

  /// خدمة البحث السريع FTS
  late final ProductsFtsService _ftsService = ProductsFtsService(db);

  /// الحصول على خدمة FTS
  ProductsFtsService get ftsService => _ftsService;

  /// الحصول على جميع المنتجات للمتجر (باستثناء المحذوفة)
  Future<List<ProductsTableData>> getAllProducts(
    String storeId, {
    int limit = 5000,
  }) {
    return (select(productsTable)
          ..where((p) => p.storeId.equals(storeId) & p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.name)])
          ..limit(limit))
        .get();
  }

  /// فحص سريع: هل يوجد منتجات للمتجر؟ (بدون تحميل كل البيانات)
  Future<bool> hasProducts(String storeId) async {
    final result =
        await (select(productsTable)
              ..where((p) => p.storeId.equals(storeId) & p.deletedAt.isNull())
              ..limit(1))
            .get();
    return result.isNotEmpty;
  }

  /// الحصول على منتج بالمعرف
  Future<ProductsTableData?> getProductById(String id) {
    return (select(
      productsTable,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Wave 10 (P0-29): tenant-isolated single-product fetch.
  ///
  /// `getProductById` doesn't filter by store, which means a store_owner
  /// who knows (or guesses) a product id from a different store can
  /// load + edit that row by deep-linking. This method enforces that
  /// the product belongs to the active store before returning it. Use
  /// it from screens that mutate the product (price edit, stock edit,
  /// etc); the un-scoped version stays for cross-store admin tooling.
  Future<ProductsTableData?> getByIdForStore(String id, String storeId) {
    return (select(productsTable)
          ..where(
            (p) =>
                p.id.equals(id) &
                p.storeId.equals(storeId) &
                p.deletedAt.isNull(),
          ))
        .getSingleOrNull();
  }

  /// Wave 10 (P0-30): targeted price + cost write that touches ONLY the
  /// columns the caller passed.
  ///
  /// The legacy edit_price flow used `currentProduct.copyWith(price: …)`
  /// + `update(productsTable).replace(row)` which writes EVERY column.
  /// If `cost_price` was null on disk and the user touched only the
  /// price, copyWith carried the null through and the replace wiped a
  /// cost that may have been set by another flow (e.g. a receive WAVG
  /// recompute) since the row was loaded. This method uses a Drift
  /// companion update so absent fields stay untouched at the SQL level.
  ///
  /// `costPriceCents` is wrapped in [Value]: pass `Value.absent()` to
  /// leave the cost untouched (the common case where the user only
  /// edits sell price), `Value(null)` to explicitly clear it, or
  /// `Value(n)` to set it.
  Future<int> updatePriceAndCost({
    required String productId,
    required int priceCents,
    Value<int?> costPriceCents = const Value.absent(),
  }) {
    return (update(
      productsTable,
    )..where((p) => p.id.equals(productId))).write(
      ProductsTableCompanion(
        price: Value(priceCents),
        costPrice: costPriceCents,
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// الحصول على منتج بالباركود
  ///
  /// Wave 10 (P0-25): excludes soft-deleted rows. POS scanning and
  /// transfer-destination lookups rely on this method for "find an
  /// active product"; without the `deletedAt IS NULL` clause a
  /// soft-deleted product would still resolve and (a) sales would
  /// silently transact against a deleted SKU, (b) inventory transfers
  /// would land stock on rows the cashier had already removed.
  Future<ProductsTableData?> getProductByBarcode(
    String barcode,
    String storeId,
  ) {
    return (select(productsTable)
          ..where(
            (p) =>
                p.barcode.equals(barcode) &
                p.storeId.equals(storeId) &
                p.deletedAt.isNull(),
          ))
        .getSingleOrNull();
  }

  /// الحصول على منتج بـ SKU داخل متجر محدد.
  ///
  /// Wave 10 (P0-25): excludes soft-deleted rows for the same reason
  /// as [getProductByBarcode] — every caller that uses SKU lookup is
  /// looking for a live, sellable product.
  Future<ProductsTableData?> getProductBySku(String sku, String storeId) {
    return (select(productsTable)
          ..where(
            (p) =>
                p.sku.equals(sku) &
                p.storeId.equals(storeId) &
                p.deletedAt.isNull(),
          ))
        .getSingleOrNull();
  }

  /// مطابقة منتج في متجر آخر (للنقل بين الفروع).
  ///
  /// يبحث بـ SKU أولاً ثم Barcode. إن لم يوجد أيهما يعيد null —
  /// المتصل مسؤول عن التعامل مع غياب المنتج في الفرع المستقبِل.
  Future<ProductsTableData?> findInStoreBySkuOrBarcode({
    required String storeId,
    String? sku,
    String? barcode,
  }) async {
    if (sku != null && sku.isNotEmpty) {
      final bySku = await getProductBySku(sku, storeId);
      if (bySku != null) return bySku;
    }
    if (barcode != null && barcode.isNotEmpty) {
      return getProductByBarcode(barcode, storeId);
    }
    return null;
  }

  /// البحث في المنتجات (يستخدم FTS إذا متاح)
  Future<List<ProductsTableData>> searchProducts(
    String query,
    String storeId,
  ) async {
    // محاولة البحث بـ FTS أولاً للأداء الأفضل
    try {
      if (await _ftsService.isFtsTableExists()) {
        final ftsResults = await _ftsService.search(query, storeId);
        if (ftsResults.isNotEmpty) {
          // تحويل نتائج FTS إلى ProductsTableData
          final ids = ftsResults.map((r) => r.id).toList();
          return (select(
            productsTable,
          )..where((p) => p.id.isIn(ids) & p.storeId.equals(storeId))).get();
        }
      }
    } catch (_) {
      // إذا فشل FTS، نستخدم البحث العادي
    }

    // البحث التقليدي كـ fallback
    final escaped = _escapeLikePattern(query);
    return (select(productsTable)
          ..where(
            (p) =>
                p.storeId.equals(storeId) &
                (p.name.like('%$escaped%') |
                    p.barcode.like('%$escaped%') |
                    p.sku.like('%$escaped%')),
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
  Future<List<ProductsTableData>> getProductsByCategory(
    String categoryId,
    String storeId,
  ) {
    return (select(productsTable)
          ..where(
            (p) => p.categoryId.equals(categoryId) & p.storeId.equals(storeId),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.name)]))
        .get();
  }

  /// Returns a map of `category_id -> product count` for a store in a single
  /// grouped query. Replaces the N+1 pattern of calling
  /// [getProductsByCategory] once per category (P1 #19 2026-04-24).
  ///
  /// Products with `category_id = NULL` are aggregated under the
  /// sentinel key `'uncategorized'` so callers can surface them without
  /// losing the count.
  Future<Map<String, int>> countByCategory(String storeId) async {
    final result = await customSelect(
      '''SELECT COALESCE(category_id, 'uncategorized') AS category_id,
                COUNT(*) AS cnt
         FROM products
         WHERE store_id = ? AND deleted_at IS NULL
         GROUP BY COALESCE(category_id, 'uncategorized')''',
      variables: [Variable.withString(storeId)],
      readsFrom: {productsTable},
    ).get();
    return {
      for (final row in result)
        (row.data['category_id'] as String? ?? 'uncategorized'):
            (row.data['cnt'] as int? ?? 0),
    };
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

  /// M2: live count of low-stock products for a store.
  ///
  /// Mirrors [getLowStockProducts]'s WHERE clause but returns a `Stream<int>`
  /// so AppHeader's notification badge updates in real time as stock moves
  /// across the min-qty threshold (purchase receipt, sale, manual edit).
  Stream<int> watchLowStockCount(String storeId) {
    return customSelect(
      '''SELECT COUNT(*) AS c FROM products
         WHERE store_id = ? AND stock_qty <= min_qty AND is_active = 1
               AND deleted_at IS NULL''',
      variables: [Variable.withString(storeId)],
      readsFrom: {productsTable},
    ).map((row) => row.data['c'] as int? ?? 0).watchSingle();
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
    return (update(productsTable)..where((p) => p.id.equals(productId))).write(
      ProductsTableCompanion(
        stockQty: Value(newQty),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Apply a `receive` movement and recompute the product's
  /// weighted-average cost in one atomic step.
  ///
  /// Wave 7 (P0-21): the legacy receive flow overwrote `cost_price`
  /// with the latest receipt's unit cost — so a single batch at a
  /// promotional price wiped the basis the rest of the inventory was
  /// valued against. The new flow accumulates a true WAVG:
  ///
  ///   newCost = (oldCost × oldStock + unitCost × qty) / (oldStock + qty)
  ///
  /// All arithmetic happens in int cents to avoid floating-point drift.
  /// Caller still records the InventoryMovement separately (this method
  /// only touches the products row) so the same call site can stitch
  /// both writes into its own transaction with the FK update.
  ///
  /// Returns the new cost in cents (matches what was written). When
  /// [unitCostCents] is null the method just bumps `stock_qty` and
  /// leaves `cost_price` alone — same semantics the receive_purchase
  /// flow had before unit cost capture existed, used as a fallback.
  Future<int?> applyReceiveAndRecomputeCost({
    required String productId,
    required double qty,
    int? unitCostCents,
  }) async {
    return attachedDatabase.transaction(() async {
      // Re-read inside the tx — `applyReceive...` will frequently be
      // called from a UI screen that captured the product on screen
      // open, and we need TOCTOU-correct stock+cost for the WAVG.
      final fresh = await getProductById(productId);
      if (fresh == null) {
        throw StateError('Product $productId disappeared before receive');
      }
      final newStock = fresh.stockQty + qty;

      // No unit cost → bump stock only (preserve old behaviour for
      // legacy receive paths that don't yet capture cost).
      if (unitCostCents == null) {
        await updateStock(productId, newStock);
        return fresh.costPrice;
      }

      // Fresh stock with no prior cost basis → cost is exactly the
      // receipt unit cost.
      final oldCost = fresh.costPrice;
      final oldStock = fresh.stockQty;
      late final int newCostCents;
      if (oldCost == null || oldCost <= 0 || oldStock <= 0) {
        newCostCents = unitCostCents;
      } else {
        // WAVG in pure integer arithmetic. oldStock and qty are doubles
        // (the products schema stores stock as REAL — fractional packs).
        // Convert to a fixed-precision representation by scaling by 1000
        // before the divide so 0.75 kg + 0.5 kg behaves correctly.
        const precision = 1000;
        final oldStockScaled = (oldStock * precision).round();
        final addStockScaled = (qty * precision).round();
        final totalScaled = oldStockScaled + addStockScaled;
        if (totalScaled <= 0) {
          newCostCents = unitCostCents;
        } else {
          final numerator =
              (oldCost * oldStockScaled) + (unitCostCents * addStockScaled);
          newCostCents = (numerator / totalScaled).round();
        }
      }

      await (update(
        productsTable,
      )..where((p) => p.id.equals(productId))).write(
        ProductsTableCompanion(
          stockQty: Value(newStock),
          costPrice: Value(newCostCents),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return newCostCents;
    });
  }

  /// حذف منتج
  Future<int> deleteProduct(String id) {
    return (delete(productsTable)..where((p) => p.id.equals(id))).go();
  }

  /// Soft-delete a product: set `deleted_at = now()` without removing the row.
  /// Admin Tier A Q1 — preferred over [deleteProduct] for audit-preserving
  /// removal. Active-row queries (which filter `deletedAt.isNull()`) will
  /// hide the row, while reports and history remain intact.
  ///
  /// Returns the number of rows affected (0 if product doesn't exist or
  /// already soft-deleted, 1 on success).
  Future<int> softDeleteProduct(String id) {
    return (update(
      productsTable,
    )..where((p) => p.id.equals(id) & p.deletedAt.isNull())).write(
      ProductsTableCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  /// تعيين تاريخ المزامنة
  Future<int> markAsSynced(String id) {
    return (update(productsTable)..where((p) => p.id.equals(id))).write(
      ProductsTableCompanion(syncedAt: Value(DateTime.now())),
    );
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
  Stream<List<ProductsTableData>> watchProducts(
    String storeId, {
    int limit = 500,
  }) {
    return (select(productsTable)
          ..where(
            (p) =>
                p.storeId.equals(storeId) &
                p.isActive.equals(true) &
                p.deletedAt.isNull(),
          )
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

  /// P1-5: SQL aggregate for inventory valuation grouped by category.
  ///
  /// Replaces the pre-fix pattern in `report_data_provider._inventory`
  /// which loaded every product row into Dart memory just to sum
  /// `costPrice * stockQty` per category — for a 5000-SKU store that
  /// materialized 5000 rows over the FFI bridge for a single number
  /// per group. SQL aggregation does the same work in O(rows) with
  /// no row materialization, matching the Wave 8 pattern from sales
  /// (`aggregatePaymentBreakdownRaw`).
  ///
  /// Returns one entry per category (or 'uncategorized' bucket):
  ///   - `categoryKey`: categoryId (or 'uncategorized' when null)
  ///   - `totalValueCents`: SUM(cost_price * stock_qty), int cents
  ///   - `totalQty`: SUM(stock_qty), double (fractional packs preserved)
  ///   - `productCount`: COUNT(*) of products contributing
  ///
  /// Excludes soft-deleted rows. `cost_price` NULL contributes 0
  /// (legacy entries before cost tracking) — matches the existing
  /// Dart-side semantics so the report number stays the same.
  Future<List<InventoryValuationGroup>> getInventoryValuationByCategory(
    String storeId,
  ) async {
    final result = await customSelect(
      '''SELECT
           COALESCE(category_id, 'uncategorized') AS category_key,
           COALESCE(SUM(COALESCE(cost_price, 0) * stock_qty), 0) AS total_value_cents,
           COALESCE(SUM(stock_qty), 0) AS total_qty,
           COUNT(*) AS product_count
         FROM products
         WHERE store_id = ?
           AND deleted_at IS NULL
         GROUP BY COALESCE(category_id, 'uncategorized')''',
      variables: [Variable.withString(storeId)],
      readsFrom: {productsTable},
    ).get();

    return result.map((row) {
      final rawValue = row.data['total_value_cents'];
      final rawQty = row.data['total_qty'];
      return InventoryValuationGroup(
        categoryKey: row.data['category_key'] as String,
        totalValueCents: (rawValue is int)
            ? rawValue
            : (rawValue as num?)?.toInt() ?? 0,
        totalQty: (rawQty as num?)?.toDouble() ?? 0.0,
        productCount: row.data['product_count'] as int? ?? 0,
      );
    }).toList();
  }

  /// البحث في المنتجات مع Pagination (باستثناء المحذوفة).
  ///
  /// Phase 3 §3.8 — يُجرَّب FTS5 أولاً للأداء الأفضل (خصوصاً على 10k+ منتج)،
  /// ثم LIKE كـ fallback إذا كان FTS غير متوفر أو فشل أو أعطى لا نتائج.
  /// هذا نفس النمط الذي يستخدمه [searchProducts] لكن مع دعم offset+limit
  /// الذي يحتاجه الـ POS للـ infinite scroll.
  Future<List<ProductsTableData>> searchProductsPaginated(
    String query,
    String storeId, {
    int offset = 0,
    int limit = 20,
  }) async {
    // محاولة FTS أولاً (BM25 ranking، يدعم عربي عبر unicode61 tokenizer)
    try {
      if (await _ftsService.isFtsTableExists()) {
        final ftsResults = await _ftsService.search(
          query,
          storeId,
          limit: limit,
          offset: offset,
        );
        if (ftsResults.isNotEmpty) {
          final ids = ftsResults.map((r) => r.id).toList();
          final rows = await (select(productsTable)
                ..where(
                  (p) =>
                      p.id.isIn(ids) &
                      p.storeId.equals(storeId) &
                      p.isActive.equals(true) &
                      p.deletedAt.isNull(),
                ))
              .get();
          // الحفاظ على ترتيب BM25 من FTS (ids.indexOf = أعلى صلة أولاً).
          rows.sort(
            (a, b) => ids.indexOf(a.id).compareTo(ids.indexOf(b.id)),
          );
          return rows;
        }
      }
    } catch (_) {
      // FTS غير متاح / فشل — نسقط على LIKE.
    }

    // Fallback: LIKE التقليدي (بطيء على مجموعات كبيرة لكن مضمون).
    final searchPattern = '%${_escapeLikePattern(query)}%';
    return (select(productsTable)
          ..where(
            (p) =>
                p.storeId.equals(storeId) &
                p.isActive.equals(true) &
                p.deletedAt.isNull() &
                (p.name.like(searchPattern) |
                    p.barcode.like(searchPattern) |
                    p.sku.like(searchPattern)),
          )
          ..orderBy([(p) => OrderingTerm.asc(p.name)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// البحث السريع بالباركود مع cache
  /// يستخدم index على barcode للأداء الأمثل
  Future<ProductsTableData?> quickFindByBarcode(
    String barcode,
    String storeId,
  ) {
    // الباركود يجب أن يكون دقيقاً
    return (select(productsTable)
          ..where(
            (p) =>
                p.barcode.equals(barcode) &
                p.storeId.equals(storeId) &
                p.isActive.equals(true),
          )
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

    return (select(productsTable)..where((p) => p.id.isIn(ids))).get();
  }

  /// L60: Batch-load multiple products by their barcodes in a single query.
  /// Useful for scanning multiple items quickly.
  Future<List<ProductsTableData>> getProductsByBarcodes(
    List<String> barcodes,
    String storeId,
  ) {
    if (barcodes.isEmpty) return Future.value([]);

    return (select(productsTable)..where(
          (p) =>
              p.barcode.isIn(barcodes) &
              p.storeId.equals(storeId) &
              p.isActive.equals(true),
        ))
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
  Future<List<ProductWithCategory>> getLowStockWithCategory(
    String storeId,
  ) async {
    final result = await customSelect(
      '''SELECT p.*, c.name as category_name
         FROM products p
         LEFT JOIN categories c ON p.category_id = c.id
         WHERE p.store_id = ? AND p.stock_qty <= p.min_qty AND p.is_active = 1
         ORDER BY p.stock_qty ASC''',
      variables: [Variable.withString(storeId)],
      readsFrom: {productsTable},
    ).get();

    return result
        .map(
          (row) => ProductWithCategory(
            product: productsTable.map(row.data),
            categoryName: row.data['category_name'] as String?,
          ),
        )
        .toList();
  }

  /// تحديث صور المنتج (بعد رفعها إلى Supabase Storage)
  Future<int> updateProductImages(
    String productId, {
    String? imageThumbnail,
    String? imageMedium,
    String? imageLarge,
    String? imageHash,
  }) {
    return (update(productsTable)..where((p) => p.id.equals(productId))).write(
      ProductsTableCompanion(
        imageThumbnail: imageThumbnail != null
            ? Value(imageThumbnail)
            : const Value.absent(),
        imageMedium: imageMedium != null
            ? Value(imageMedium)
            : const Value.absent(),
        imageLarge: imageLarge != null
            ? Value(imageLarge)
            : const Value.absent(),
        imageHash: imageHash != null ? Value(imageHash) : const Value.absent(),
        updatedAt: Value(DateTime.now()),
      ),
    );
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

/// P1-5: one bucket from the inventory-valuation aggregate query.
/// Mirrors the per-category row shape the report screen expects but
/// stays Drift-free so the data class can travel into alhai_reports
/// without dragging the DAO with it.
class InventoryValuationGroup {
  final String categoryKey;
  final int totalValueCents;
  final double totalQty;
  final int productCount;

  const InventoryValuationGroup({
    required this.categoryKey,
    required this.totalValueCents,
    required this.totalQty,
    required this.productCount,
  });
}
