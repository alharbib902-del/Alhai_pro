import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/inventory_movements_table.dart';

part 'inventory_dao.g.dart';

/// Wave 7 (P0-19): canonical movement types — every insert into
/// `inventory_movements` MUST use one of these strings. Validation lives
/// here (vs. a SQLite CHECK constraint) because adding a CHECK on an
/// existing table requires the table-copy migration pattern, which is
/// heavier than the safety we'd buy given every write goes through this
/// DAO. Reports / analytics can rely on these values being stable.
const Set<String> kInventoryMovementTypes = {
  /// Stock added (receive from supplier, manual addition, returns to
  /// supplier reversal, etc). Carries optional `unitCostCents` for WAVG.
  'receive',

  /// Manual adjustment up or down with a reason — counts variance,
  /// damage write-off without a wastage flow, etc.
  'adjust',

  /// Transfer leg: stock leaving the source store.
  'transfer_out',

  /// Transfer leg: stock arriving at the destination store. May carry
  /// `unitCostCents` if the destination tracks WAVG.
  'transfer_in',

  /// Wastage / spoilage / damaged. Negative qty.
  'wastage',

  /// Periodic stock-take adjustment (counted - on-hand).
  'stock_take',

  /// Customer return — restock at original sale's cost basis.
  'return',

  /// Sale fulfilment. Negative qty.
  'sale',

  /// Void of a completed sale — restocks at original cost basis.
  'void',
};

/// DAO لحركات المخزون
@DriftAccessor(tables: [InventoryMovementsTable])
class InventoryDao extends DatabaseAccessor<AppDatabase>
    with _$InventoryDaoMixin {
  InventoryDao(super.db);

  /// الحصول على حركات منتج (مع فلتر المتجر)
  Future<List<InventoryMovementsTableData>> getMovementsByProduct(
    String productId, {
    String? storeId,
  }) {
    return (select(inventoryMovementsTable)
          ..where((m) {
            var condition = m.productId.equals(productId);
            if (storeId != null) {
              condition = condition & m.storeId.equals(storeId);
            }
            return condition;
          })
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(200))
        .get();
  }

  /// الحصول على حركات اليوم
  Future<List<InventoryMovementsTableData>> getTodayMovements(String storeId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (select(inventoryMovementsTable)
          ..where(
            (m) =>
                m.storeId.equals(storeId) &
                m.createdAt.isBiggerOrEqualValue(startOfDay) &
                m.createdAt.isSmallerThanValue(endOfDay),
          )
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .get();
  }

  /// إدراج حركة. The companion's `type` MUST be one of
  /// [kInventoryMovementTypes]; throws [ArgumentError] otherwise so a
  /// stray string bug shows up at the call site instead of polluting
  /// reports months later.
  Future<int> insertMovement(InventoryMovementsTableCompanion movement) {
    final type = movement.type.value;
    if (!kInventoryMovementTypes.contains(type)) {
      throw ArgumentError.value(
        type,
        'movement.type',
        'Must be one of $kInventoryMovementTypes',
      );
    }
    return into(inventoryMovementsTable).insert(movement);
  }

  /// إدراج حركة بيع (خصم من المخزون)
  Future<int> recordSaleMovement({
    required String id,
    required String productId,
    required String storeId,
    required double qty,
    required double previousQty,
    required String saleId,
    String? userId,
  }) {
    return insertMovement(
      InventoryMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        type: 'sale',
        qty: -qty, // سالب للبيع
        previousQty: previousQty,
        newQty: previousQty - qty,
        referenceType: const Value('sale'),
        referenceId: Value(saleId),
        userId: Value(userId),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// إدراج حركة استلام (إضافة للمخزون). Wave 7 (P0-19, P0-21):
  /// renamed from `recordPurchaseMovement` and now carries the per-unit
  /// cost so receive flows can drive WAVG. Pass `unitCostCents` when
  /// available; the legacy `purchase`-without-cost path is preserved by
  /// leaving it null.
  Future<int> recordReceiveMovement({
    required String id,
    required String productId,
    required String storeId,
    required double qty,
    required double previousQty,
    String? referenceType,
    String? referenceId,
    int? unitCostCents,
    String? userId,
    String? notes,
  }) {
    return insertMovement(
      InventoryMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        type: 'receive',
        qty: qty,
        previousQty: previousQty,
        newQty: previousQty + qty,
        referenceType: Value(referenceType),
        referenceId: Value(referenceId),
        unitCostCents: Value(unitCostCents),
        userId: Value(userId),
        notes: Value(notes),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// إدراج حركة إلغاء بيع (استعادة المخزون)
  Future<int> recordVoidMovement({
    required String id,
    required String productId,
    required String storeId,
    required double qty,
    required double previousQty,
    required String saleId,
    String? userId,
  }) {
    return insertMovement(
      InventoryMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        type: 'void',
        qty: qty, // موجب لاستعادة المخزون
        previousQty: previousQty,
        newQty: previousQty + qty,
        referenceType: const Value('sale'),
        referenceId: Value(saleId),
        userId: Value(userId),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// إدراج حركة إرجاع جزئي (استعادة المخزون)
  Future<int> recordReturnMovement({
    required String id,
    required String productId,
    required String storeId,
    required double qty,
    required double previousQty,
    required String returnId,
    String? userId,
  }) {
    return insertMovement(
      InventoryMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        type: 'return',
        qty: qty, // positive = restock
        previousQty: previousQty,
        newQty: previousQty + qty,
        referenceType: const Value('return'),
        referenceId: Value(returnId),
        userId: Value(userId),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// إدراج حركة تعديل manual. Wave 7: type renamed from
  /// 'adjustment' → 'adjust' to match the canonical enum.
  Future<int> recordAdjustment({
    required String id,
    required String productId,
    required String storeId,
    required double newQty,
    required double previousQty,
    String? reason,
    String? userId,
  }) {
    return insertMovement(
      InventoryMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        type: 'adjust',
        qty: newQty - previousQty,
        previousQty: previousQty,
        newQty: newQty,
        reason: Value(reason),
        userId: Value(userId),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Wave 7: wastage / spoilage / damage write-off. qty is the
  /// (positive) amount removed; the row stores `qty: -qty` so the
  /// running balance is correct.
  Future<int> recordWastageMovement({
    required String id,
    required String productId,
    required String storeId,
    required double qty,
    required double previousQty,
    String? reason,
    String? userId,
    String? notes,
  }) {
    return insertMovement(
      InventoryMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        type: 'wastage',
        qty: -qty,
        previousQty: previousQty,
        newQty: previousQty - qty,
        reason: Value(reason),
        notes: Value(notes),
        userId: Value(userId),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Wave 7: stock-take adjustment. `delta` is `counted - on-hand` and
  /// can be negative (overcount → write-down) or positive
  /// (undercount → write-up).
  ///
  /// P0-22: [referenceType] / [referenceId] let the caller pin the
  /// movement to a `stock_takes` session row, so audit reports can
  /// reconstruct which physical-count operation produced each delta.
  /// Both nullable to keep legacy call sites compiling unchanged.
  Future<int> recordStockTakeMovement({
    required String id,
    required String productId,
    required String storeId,
    required double delta,
    required double previousQty,
    String? reason,
    String? userId,
    String? referenceType,
    String? referenceId,
  }) {
    return insertMovement(
      InventoryMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        type: 'stock_take',
        qty: delta,
        previousQty: previousQty,
        newQty: previousQty + delta,
        reason: Value(reason),
        userId: Value(userId),
        referenceType: Value(referenceType),
        referenceId: Value(referenceId),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Wave 7: source leg of a transfer between stores.
  Future<int> recordTransferOutMovement({
    required String id,
    required String productId,
    required String storeId,
    required double qty,
    required double previousQty,
    required String transferId,
    String? userId,
    String? notes,
  }) {
    return insertMovement(
      InventoryMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        type: 'transfer_out',
        qty: -qty,
        previousQty: previousQty,
        newQty: previousQty - qty,
        referenceType: const Value('transfer'),
        referenceId: Value(transferId),
        userId: Value(userId),
        notes: Value(notes),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Wave 7: destination leg of a transfer. Carries `unitCostCents` so
  /// the destination store's WAVG cost is recomputed correctly.
  Future<int> recordTransferInMovement({
    required String id,
    required String productId,
    required String storeId,
    required double qty,
    required double previousQty,
    required String transferId,
    int? unitCostCents,
    String? userId,
    String? notes,
  }) {
    return insertMovement(
      InventoryMovementsTableCompanion.insert(
        id: id,
        productId: productId,
        storeId: storeId,
        type: 'transfer_in',
        qty: qty,
        previousQty: previousQty,
        newQty: previousQty + qty,
        referenceType: const Value('transfer'),
        referenceId: Value(transferId),
        unitCostCents: Value(unitCostCents),
        userId: Value(userId),
        notes: Value(notes),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// تعيين تاريخ المزامنة
  Future<int> markAsSynced(String id) {
    return (update(
      inventoryMovementsTable,
    )..where((m) => m.id.equals(id))).write(
      InventoryMovementsTableCompanion(syncedAt: Value(DateTime.now())),
    );
  }

  /// الحصول على الحركات غير المزامنة
  Future<List<InventoryMovementsTableData>> getUnsyncedMovements({
    String? storeId,
  }) {
    final q = select(inventoryMovementsTable)
      ..where((m) => m.syncedAt.isNull());
    if (storeId != null) {
      q.where((m) => m.storeId.equals(storeId));
    }
    return (q..limit(500)).get();
  }

  // ============================================================================
  // H03: JOIN queries - استعلامات مع ربط الجداول
  // ============================================================================

  /// حركات المخزون مع اسم المنتج
  Future<List<MovementWithProduct>> getMovementsWithProductName(
    String storeId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await customSelect(
      '''SELECT m.*, p.name as product_name, p.barcode as product_barcode
         FROM inventory_movements m
         LEFT JOIN products p ON m.product_id = p.id
         WHERE m.store_id = ?
         ORDER BY m.created_at DESC
         LIMIT ? OFFSET ?''',
      variables: [
        Variable.withString(storeId),
        Variable.withInt(limit),
        Variable.withInt(offset),
      ],
      readsFrom: {inventoryMovementsTable},
    ).get();

    return result
        .map(
          (row) => MovementWithProduct(
            movement: inventoryMovementsTable.map(row.data),
            productName: row.data['product_name'] as String? ?? '',
            productBarcode: row.data['product_barcode'] as String?,
          ),
        )
        .toList();
  }
}

/// حركة مخزون مع اسم المنتج
class MovementWithProduct {
  final InventoryMovementsTableData movement;
  final String productName;
  final String? productBarcode;

  const MovementWithProduct({
    required this.movement,
    required this.productName,
    this.productBarcode,
  });
}
