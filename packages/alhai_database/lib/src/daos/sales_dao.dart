import 'package:alhai_core/alhai_core.dart' show AppendOnlyViolationException;
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';
import '../tables/sales_table.dart';

part 'sales_dao.g.dart';

/// DAO للمبيعات
@DriftAccessor(tables: [SalesTable])
class SalesDao extends DatabaseAccessor<AppDatabase> with _$SalesDaoMixin {
  SalesDao(super.db);

  // Simple time-based cache for getTodayTotal (30-second TTL)
  DateTime? _todayTotalCacheTime;
  double? _todayTotalCacheValue;
  String? _todayTotalCacheKey;

  /// الحصول على جميع المبيعات للمتجر (باستثناء المحذوفة)
  Future<List<SalesTableData>> getAllSales(String storeId, {int limit = 1000}) {
    return (select(salesTable)
          ..where((s) => s.storeId.equals(storeId) & s.deletedAt.isNull())
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
          ..limit(limit))
        .get();
  }

  /// الحصول على مبيعات بتاريخ (باستثناء المحذوفة)
  Future<List<SalesTableData>> getSalesByDate(
    String storeId,
    DateTime date, {
    int limit = 1000,
  }) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(salesTable)
          ..where(
            (s) =>
                s.storeId.equals(storeId) &
                s.deletedAt.isNull() &
                s.createdAt.isBiggerOrEqualValue(startOfDay) &
                s.createdAt.isSmallerThanValue(endOfDay),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
          ..limit(limit))
        .get();
  }

  /// الحصول على مبيعات مع عناصرها لنطاق تاريخ معين (بدون N+1)
  ///
  /// Fetches sales in a single query, then batch-loads every matching
  /// sale_items row in a second query using `WHERE sale_id IN (...)`.
  /// Callers get `(sale, items)` tuples without looping and issuing
  /// one item query per sale.
  ///
  /// Sales without items return an empty list for `items` (never null).
  /// Results are ordered by sale.createdAt DESC (same as [getSalesByDate]).
  ///
  /// [to] is exclusive so callers can pass next-day midnight and not
  /// worry about double-counting rows on the boundary.
  Future<List<({SalesTableData sale, List<SaleItemsTableData> items})>>
  getSalesWithItemsByDate(
    String storeId,
    DateTime from,
    DateTime to, {
    int limit = 1000,
  }) async {
    // 1. Fetch sales in range (non-deleted) ordered newest first.
    final sales = await (select(salesTable)
          ..where(
            (s) =>
                s.storeId.equals(storeId) &
                s.deletedAt.isNull() &
                s.createdAt.isBiggerOrEqualValue(from) &
                s.createdAt.isSmallerThanValue(to),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
          ..limit(limit))
        .get();

    if (sales.isEmpty) return const [];

    // 2. Batch-load items for all these sales in chunked IN() queries so
    //    we never exceed SQLite's variable limit (~999 per statement).
    final saleIds = sales.map((s) => s.id).toList(growable: false);
    final itemsBySaleId = <String, List<SaleItemsTableData>>{};
    const chunkSize = 500;

    for (var i = 0; i < saleIds.length; i += chunkSize) {
      final end = (i + chunkSize > saleIds.length)
          ? saleIds.length
          : i + chunkSize;
      final chunk = saleIds.sublist(i, end);
      final rows = await (select(attachedDatabase.saleItemsTable)
            ..where((si) => si.saleId.isIn(chunk)))
          .get();
      for (final item in rows) {
        (itemsBySaleId[item.saleId] ??= <SaleItemsTableData>[]).add(item);
      }
    }

    // 3. Stitch sales + items together preserving sales order.
    return sales
        .map(
          (s) => (
            sale: s,
            items:
                itemsBySaleId[s.id] ?? const <SaleItemsTableData>[],
          ),
        )
        .toList(growable: false);
  }

  /// الحصول على مبيعات الفترة (باستثناء المحذوفة)
  Future<List<SalesTableData>> getSalesByDateRange(
    String storeId,
    DateTime startDate,
    DateTime endDate, {
    int limit = 5000,
  }) {
    return (select(salesTable)
          ..where(
            (s) =>
                s.storeId.equals(storeId) &
                s.deletedAt.isNull() &
                s.createdAt.isBiggerOrEqualValue(startDate) &
                s.createdAt.isSmallerOrEqualValue(endDate),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
          ..limit(limit))
        .get();
  }

  /// الحصول على بيع بالمعرف
  Future<SalesTableData?> getSaleById(String id) {
    return (select(
      salesTable,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// الحصول على بيع برقم الإيصال
  Future<SalesTableData?> getSaleByReceiptNo(String receiptNo, String storeId) {
    return (select(salesTable)..where(
          (s) => s.receiptNo.equals(receiptNo) & s.storeId.equals(storeId),
        ))
        .getSingleOrNull();
  }

  /// إدراج بيع
  Future<int> insertSale(SalesTableCompanion sale) {
    return into(salesTable).insert(sale);
  }

  /// إدراج بيع مع عناصره في معاملة واحدة (atomic)
  ///
  /// Creates a new sale plus all its items in a single Drift transaction so
  /// partial writes can never leave the database in an inconsistent state
  /// (e.g. a sale row without its items if the app crashes mid-insert).
  ///
  /// Returns the sale id (which is always the UUID already set on the
  /// [sale] companion — sale ids are client-generated strings).
  ///
  /// This method is additive: existing callers of [insertSale] continue
  /// to work and can migrate to this at their own pace.
  Future<String> createSaleWithItems({
    required SalesTableCompanion sale,
    required List<SaleItemsTableCompanion> items,
  }) async {
    // Sale id is required on the companion (TextColumn primary key, no default).
    final saleId = sale.id.value;
    return attachedDatabase.transaction(() async {
      await into(salesTable).insert(sale);
      if (items.isNotEmpty) {
        await attachedDatabase.saleItemsDao.insertItems(items);
      }
      return saleId;
    });
  }

  /// Immutable statuses (ZATCA compliance: completed invoices cannot be
  /// modified — corrections go through Credit/Debit Notes).
  static const _immutableStatuses = ['completed', 'paid', 'refunded'];

  /// تحديث بيع
  ///
  /// Throws [AppendOnlyViolationException] if the sale is in an immutable
  /// status and the update touches financial or identity fields.
  Future<bool> updateSale(SalesTableData sale) async {
    final current = await getSaleById(sale.id);
    if (current != null &&
        _immutableStatuses.contains(current.status) &&
        _hasFinancialChanges(current, sale)) {
      throw AppendOnlyViolationException(
        'Cannot modify completed sale ${sale.id}. '
        'Use Credit/Debit Note instead.',
        code: 'APPEND_ONLY_VIOLATION',
      );
    }
    return update(salesTable).replace(sale);
  }

  /// Returns true when any financial or identity field differs between
  /// [old] and [updated].
  bool _hasFinancialChanges(SalesTableData old, SalesTableData updated) {
    return old.subtotal != updated.subtotal ||
        old.discount != updated.discount ||
        old.tax != updated.tax ||
        old.total != updated.total ||
        old.paymentMethod != updated.paymentMethod ||
        old.isPaid != updated.isPaid ||
        old.amountReceived != updated.amountReceived ||
        old.changeAmount != updated.changeAmount ||
        old.cashAmount != updated.cashAmount ||
        old.cardAmount != updated.cardAmount ||
        old.creditAmount != updated.creditAmount ||
        old.customerId != updated.customerId ||
        old.receiptNo != updated.receiptNo ||
        old.status != updated.status ||
        old.notes != updated.notes;
  }

  static const _uuid = Uuid();

  /// إلغاء بيع مع استعادة المخزون وتسجيل حركات المخزون ودلتا المزامنة
  Future<int> voidSale(String id) {
    return transaction(() async {
      try {
        // 0. جلب store_id و cashier_id من البيع
        final saleRow = await customSelect(
          'SELECT store_id, cashier_id FROM sales WHERE id = ?',
          variables: [Variable.withString(id)],
        ).getSingleOrNull();
        final storeId = saleRow?.data['store_id'] as String?;
        final cashierId = saleRow?.data['cashier_id'] as String?;

        // جلب org_id من المتجر (لدلتا المخزون)
        String? orgId;
        if (storeId != null) {
          try {
            final storeRow = await customSelect(
              'SELECT org_id FROM stores WHERE id = ?',
              variables: [Variable.withString(storeId)],
            ).getSingleOrNull();
            orgId = storeRow?.data['org_id'] as String?;
          } catch (e) {
            // org_id is only needed for stock-delta logging; leaving it null
            // falls back to store-scoped delta tracking.
            debugPrint(
              '[DB] voidSale: org_id lookup failed for store $storeId: $e',
            );
          }
        }

        // 1. جلب عناصر البيع لاستعادة الكميات
        final items = await customSelect(
          'SELECT product_id, qty FROM sale_items WHERE sale_id = ?',
          variables: [Variable.withString(id)],
        ).get();

        // 2. استعادة المخزون لكل منتج مع تسجيل الحركات والدلتا
        final now = DateTime.now();
        for (final item in items) {
          try {
            final productId = item.data['product_id'] as String;
            final qty = item.data['qty'];
            final qtyDouble = (qty is int) ? qty.toDouble() : qty as double;

            // قراءة الكمية الحالية قبل الاستعادة (للسجل)
            final productRow = await customSelect(
              'SELECT stock_qty FROM products WHERE id = ?',
              variables: [Variable.withString(productId)],
            ).getSingleOrNull();
            final previousQty = productRow != null
                ? ((productRow.data['stock_qty'] is int)
                      ? (productRow.data['stock_qty'] as int).toDouble()
                      : productRow.data['stock_qty'] as double? ?? 0.0)
                : 0.0;

            // استعادة المخزون
            await customStatement(
              'UPDATE products SET stock_qty = stock_qty + ?, updated_at = ? WHERE id = ?'
              '${storeId != null ? ' AND store_id = ?' : ''}',
              [
                qtyDouble,
                now.millisecondsSinceEpoch,
                productId,
                if (storeId != null) storeId,
              ],
            );

            // تسجيل حركة المخزون (void movement)
            if (storeId != null) {
              await attachedDatabase.inventoryDao.recordVoidMovement(
                id: _uuid.v4(),
                productId: productId,
                storeId: storeId,
                qty: qtyDouble,
                previousQty: previousQty,
                saleId: id,
                userId: cashierId,
              );

              // تسجيل دلتا المخزون (موجب لاستعادة المخزون)
              await attachedDatabase.stockDeltasDao.addDelta(
                id: _uuid.v4(),
                productId: productId,
                storeId: storeId,
                orgId: orgId,
                quantityChange: qtyDouble,
                deviceId: cashierId ?? 'system',
                operationType: 'void',
                referenceId: id,
              );
            }
          } catch (e) {
            debugPrint(
              '[DB] voidSale: failed to restore stock for '
              'product ${item.data['product_id']} in sale $id: $e',
            );
            rethrow;
          }
        }

        // 3. تحديث حالة البيع إلى ملغي
        return (update(salesTable)..where((s) => s.id.equals(id))).write(
          SalesTableCompanion(
            status: const Value('voided'),
            updatedAt: Value(now),
          ),
        );
      } catch (e) {
        debugPrint('[DB] voidSale transaction failed for $id: $e');
        rethrow;
      }
    });
  }

  /// إجمالي مبيعات اليوم (cached for 30 seconds)
  Future<double> getTodayTotal(String storeId, String cashierId) async {
    final cacheKey = '${storeId}_$cashierId';
    final now = DateTime.now();

    // Return cached value if still valid (within 30 seconds)
    if (_todayTotalCacheTime != null &&
        _todayTotalCacheKey == cacheKey &&
        _todayTotalCacheValue != null &&
        now.difference(_todayTotalCacheTime!).inSeconds < 30) {
      return _todayTotalCacheValue!;
    }

    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await customSelect(
      '''SELECT COALESCE(SUM(total), 0) as total
         FROM sales
         WHERE store_id = ?
         AND cashier_id = ?
         AND created_at >= ?
         AND created_at < ?
         AND status = 'completed' ''',
      variables: [
        Variable.withString(storeId),
        Variable.withString(cashierId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).getSingle();

    final total = result.data['total'];
    double value;
    if (total == null) {
      value = 0.0;
    } else if (total is int) {
      value = total.toDouble();
    } else {
      value = total as double;
    }

    // Update cache
    _todayTotalCacheTime = now;
    _todayTotalCacheKey = cacheKey;
    _todayTotalCacheValue = value;

    return value;
  }

  /// عدد مبيعات اليوم للكاشير
  Future<int> getTodayCount(String storeId, String cashierId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await customSelect(
      '''SELECT COUNT(*) as count
         FROM sales
         WHERE store_id = ?
         AND cashier_id = ?
         AND created_at >= ?
         AND created_at < ?
         AND status = 'completed' ''',
      variables: [
        Variable.withString(storeId),
        Variable.withString(cashierId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).getSingle();

    return result.data['count'] as int? ?? 0;
  }

  /// عدد جميع مبيعات اليوم للمتجر (لتوليد رقم الإيصال)
  Future<int> getTodayStoreCount(String storeId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await customSelect(
      '''SELECT COUNT(*) as count
         FROM sales
         WHERE store_id = ?
         AND created_at >= ?
         AND created_at < ? ''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).getSingle();

    return result.data['count'] as int? ?? 0;
  }

  /// تعيين تاريخ المزامنة
  Future<int> markAsSynced(String id) {
    return (update(salesTable)..where((s) => s.id.equals(id))).write(
      SalesTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  /// الحصول على المبيعات غير المزامنة
  Future<List<SalesTableData>> getUnsyncedSales({String? storeId}) {
    final q = select(salesTable)..where((s) => s.syncedAt.isNull());
    if (storeId != null) {
      q.where((s) => s.storeId.equals(storeId));
    }
    return (q..limit(500)).get();
  }

  /// مراقبة المبيعات (Stream)
  /// [limit] - الحد الأقصى للنتائج (افتراضي 200)
  Stream<List<SalesTableData>> watchTodaySales(
    String storeId, {
    int limit = 200,
  }) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(salesTable)
          ..where(
            (s) =>
                s.storeId.equals(storeId) &
                s.deletedAt.isNull() &
                s.status.equals('voided').not() &
                s.createdAt.isBiggerOrEqualValue(startOfDay) &
                s.createdAt.isSmallerThanValue(endOfDay),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
          ..limit(limit))
        .watch();
  }

  // ============================================================================
  // Pagination & Performance Methods - تحسينات الأداء
  // ============================================================================

  /// الحصول على مبيعات مع Pagination
  Future<List<SalesTableData>> getSalesPaginated(
    String storeId, {
    int offset = 0,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? cashierId,
  }) {
    var query = select(salesTable)
      ..where((s) {
        var condition = s.storeId.equals(storeId) & s.deletedAt.isNull();

        if (startDate != null) {
          condition = condition & s.createdAt.isBiggerOrEqualValue(startDate);
        }
        if (endDate != null) {
          condition = condition & s.createdAt.isSmallerOrEqualValue(endDate);
        }
        if (status != null) {
          condition = condition & s.status.equals(status);
        }
        if (cashierId != null) {
          condition = condition & s.cashierId.equals(cashierId);
        }

        return condition;
      })
      ..orderBy([(s) => OrderingTerm.desc(s.createdAt)])
      ..limit(limit, offset: offset);

    return query.get();
  }

  /// عدد المبيعات الكلي (للـ pagination)
  Future<int> getSalesCount(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? cashierId,
  }) async {
    final countExpression = salesTable.id.count();

    var query = selectOnly(salesTable)
      ..addColumns([countExpression])
      ..where(salesTable.storeId.equals(storeId))
      ..where(salesTable.deletedAt.isNull());

    if (startDate != null) {
      query.where(salesTable.createdAt.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(salesTable.createdAt.isSmallerOrEqualValue(endDate));
    }
    if (status != null) {
      query.where(salesTable.status.equals(status));
    }
    if (cashierId != null) {
      query.where(salesTable.cashierId.equals(cashierId));
    }

    final result = await query.getSingle();
    return result.read(countExpression) ?? 0;
  }

  /// إحصائيات سريعة للمبيعات
  /// يجمع المجموع، العدد، المتوسط في استعلام واحد
  Future<SalesStats> getSalesStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
    String? cashierId,
  }) async {
    var whereClause = 'store_id = ? AND status = \'completed\'';
    final variables = <Variable>[Variable.withString(storeId)];

    if (startDate != null) {
      whereClause += ' AND created_at >= ?';
      variables.add(Variable.withDateTime(startDate));
    }
    if (endDate != null) {
      whereClause += ' AND created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }
    if (cashierId != null) {
      whereClause += ' AND cashier_id = ?';
      variables.add(Variable.withString(cashierId));
    }

    final result = await customSelect('''SELECT
           COUNT(*) as count,
           COALESCE(SUM(total), 0) as total,
           COALESCE(AVG(total), 0) as average,
           COALESCE(MAX(total), 0) as max_sale,
           COALESCE(MIN(total), 0) as min_sale
         FROM sales
         WHERE $whereClause''', variables: variables).getSingle();

    return SalesStats(
      count: result.data['count'] as int? ?? 0,
      total: (result.data['total'] is int)
          ? (result.data['total'] as int).toDouble()
          : result.data['total'] as double? ?? 0.0,
      average: (result.data['average'] is int)
          ? (result.data['average'] as int).toDouble()
          : result.data['average'] as double? ?? 0.0,
      maxSale: (result.data['max_sale'] is int)
          ? (result.data['max_sale'] as int).toDouble()
          : result.data['max_sale'] as double? ?? 0.0,
      minSale: (result.data['min_sale'] is int)
          ? (result.data['min_sale'] as int).toDouble()
          : result.data['min_sale'] as double? ?? 0.0,
    );
  }

  /// المبيعات بالساعة (للتقارير)
  Future<List<HourlySales>> getHourlySales(
    String storeId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final result = await customSelect(
      '''SELECT
           strftime('%H', created_at) as hour,
           COUNT(*) as count,
           COALESCE(SUM(total), 0) as total
         FROM sales
         WHERE store_id = ?
         AND created_at >= ?
         AND created_at < ?
         AND status = 'completed'
         GROUP BY strftime('%H', created_at)
         ORDER BY hour''',
      variables: [
        Variable.withString(storeId),
        Variable.withDateTime(startOfDay),
        Variable.withDateTime(endOfDay),
      ],
    ).get();

    return result
        .map(
          (row) => HourlySales(
            hour: int.tryParse(row.data['hour']?.toString() ?? '') ?? 0,
            count: row.data['count'] as int,
            total: (row.data['total'] is int)
                ? (row.data['total'] as int).toDouble()
                : row.data['total'] as double,
          ),
        )
        .toList();
  }

  /// أفضل طرق الدفع
  Future<List<PaymentMethodStats>> getPaymentMethodStats(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var whereClause = 'store_id = ? AND status = \'completed\'';
    final variables = <Variable>[Variable.withString(storeId)];

    if (startDate != null) {
      whereClause += ' AND created_at >= ?';
      variables.add(Variable.withDateTime(startDate));
    }
    if (endDate != null) {
      whereClause += ' AND created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }

    final result = await customSelect('''SELECT
           payment_method,
           COUNT(*) as count,
           COALESCE(SUM(total), 0) as total
         FROM sales
         WHERE $whereClause
         GROUP BY payment_method
         ORDER BY total DESC''', variables: variables).get();

    return result
        .map(
          (row) => PaymentMethodStats(
            method: row.data['payment_method'] as String,
            count: row.data['count'] as int,
            total: (row.data['total'] is int)
                ? (row.data['total'] as int).toDouble()
                : row.data['total'] as double,
          ),
        )
        .toList();
  }

  // ============================================================================
  // H03: JOIN queries - استعلامات مع ربط الجداول
  // ============================================================================

  /// مبيعات مع اسم العميل والكاشير
  Future<List<SaleWithDetails>> getSalesWithDetails(
    String storeId, {
    int offset = 0,
    int limit = 20,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var whereClause =
        "s.store_id = ? AND s.deleted_at IS NULL AND s.status = 'completed'";
    final variables = <Variable>[Variable.withString(storeId)];

    if (startDate != null) {
      whereClause += ' AND s.created_at >= ?';
      variables.add(Variable.withDateTime(startDate));
    }
    if (endDate != null) {
      whereClause += ' AND s.created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }

    final result = await customSelect(
      '''SELECT s.id, s.receipt_no, s.total, s.payment_method, s.status,
              s.created_at, s.customer_id, s.cashier_id,
              c.name as customer_name, c.phone as customer_phone
         FROM sales s
         LEFT JOIN customers c ON s.customer_id = c.id
         WHERE $whereClause
         ORDER BY s.created_at DESC
         LIMIT ? OFFSET ?''',
      variables: [
        ...variables,
        Variable.withInt(limit),
        Variable.withInt(offset),
      ],
    ).get();

    return result
        .map(
          (row) => SaleWithDetails(
            id: row.data['id'] as String,
            receiptNo: row.data['receipt_no'] as String,
            total: _toDouble(row.data['total']),
            paymentMethod: row.data['payment_method'] as String? ?? 'cash',
            status: row.data['status'] as String,
            createdAt:
                DateTime.tryParse(row.data['created_at'].toString()) ??
                DateTime.now(),
            customerName: row.data['customer_name'] as String?,
            customerPhone: row.data['customer_phone'] as String?,
          ),
        )
        .toList();
  }

  /// بيع واحد مع التفاصيل
  Future<SaleWithDetails?> getSaleWithDetails(String saleId) async {
    final result = await customSelect(
      '''SELECT s.id, s.receipt_no, s.total, s.payment_method, s.status,
              s.created_at, s.customer_id, s.cashier_id,
              c.name as customer_name, c.phone as customer_phone
         FROM sales s
         LEFT JOIN customers c ON s.customer_id = c.id
         WHERE s.id = ?''',
      variables: [Variable.withString(saleId)],
    ).get();

    if (result.isEmpty) return null;
    final row = result.first;
    return SaleWithDetails(
      id: row.data['id'] as String,
      receiptNo: row.data['receipt_no'] as String,
      total: _toDouble(row.data['total']),
      paymentMethod: row.data['payment_method'] as String? ?? 'cash',
      status: row.data['status'] as String,
      createdAt:
          DateTime.tryParse(row.data['created_at'].toString()) ??
          DateTime.now(),
      customerName: row.data['customer_name'] as String?,
      customerPhone: row.data['customer_phone'] as String?,
    );
  }

  /// مجموع المبيعات النقدية فقط خلال فترة الوردية
  /// يُستخدم لحساب النقد المتوقع في الدرج (بدون بطاقة/آجل)
  Future<double> getCashSalesTotalForPeriod(
    String storeId, {
    required DateTime startDate,
    DateTime? endDate,
    String? cashierId,
  }) async {
    var whereClause =
        "store_id = ? AND status = 'completed' AND payment_method = 'cash' AND created_at >= ?";
    final variables = <Variable>[
      Variable.withString(storeId),
      Variable.withDateTime(startDate),
    ];

    if (endDate != null) {
      whereClause += ' AND created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }
    if (cashierId != null) {
      whereClause += ' AND cashier_id = ?';
      variables.add(Variable.withString(cashierId));
    }

    final result = await customSelect(
      'SELECT COALESCE(SUM(total), 0) as total FROM sales WHERE $whereClause',
      variables: variables,
    ).getSingle();

    final total = result.data['total'];
    if (total == null) return 0.0;
    if (total is int) return total.toDouble();
    return total as double;
  }

  /// مجموع الجزء النقدي من المبيعات المختلطة خلال فترة الوردية
  Future<double> getMixedCashAmountForPeriod(
    String storeId, {
    required DateTime startDate,
    DateTime? endDate,
    String? cashierId,
  }) async {
    var whereClause =
        "store_id = ? AND status = 'completed' AND payment_method = 'mixed' AND cash_amount IS NOT NULL AND created_at >= ?";
    final variables = <Variable>[
      Variable.withString(storeId),
      Variable.withDateTime(startDate),
    ];

    if (endDate != null) {
      whereClause += ' AND created_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }
    if (cashierId != null) {
      whereClause += ' AND cashier_id = ?';
      variables.add(Variable.withString(cashierId));
    }

    final result = await customSelect(
      'SELECT COALESCE(SUM(cash_amount), 0) as total FROM sales WHERE $whereClause',
      variables: variables,
    ).getSingle();

    final total = result.data['total'];
    if (total == null) return 0.0;
    if (total is int) return total.toDouble();
    return total as double;
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// نموذج بيع مع تفاصيل العميل
class SaleWithDetails {
  final String id;
  final String receiptNo;
  final double total;
  final String paymentMethod;
  final String status;
  final DateTime createdAt;
  final String? customerName;
  final String? customerPhone;

  const SaleWithDetails({
    required this.id,
    required this.receiptNo,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.customerName,
    this.customerPhone,
  });
}

/// نموذج إحصائيات المبيعات
class SalesStats {
  final int count;
  final double total;
  final double average;
  final double maxSale;
  final double minSale;

  const SalesStats({
    required this.count,
    required this.total,
    required this.average,
    required this.maxSale,
    required this.minSale,
  });
}

/// نموذج المبيعات بالساعة
class HourlySales {
  final int hour;
  final int count;
  final double total;

  const HourlySales({
    required this.hour,
    required this.count,
    required this.total,
  });
}

/// نموذج إحصائيات طرق الدفع
class PaymentMethodStats {
  final String method;
  final int count;
  final double total;

  const PaymentMethodStats({
    required this.method,
    required this.count,
    required this.total,
  });
}
