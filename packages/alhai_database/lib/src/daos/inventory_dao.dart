import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/inventory_movements_table.dart';

part 'inventory_dao.g.dart';

/// DAO لحركات المخزون
@DriftAccessor(tables: [InventoryMovementsTable])
class InventoryDao extends DatabaseAccessor<AppDatabase> with _$InventoryDaoMixin {
  InventoryDao(super.db);
  
  /// الحصول على حركات منتج (مع فلتر المتجر)
  Future<List<InventoryMovementsTableData>> getMovementsByProduct(String productId, {String? storeId}) {
    return (select(inventoryMovementsTable)
      ..where((m) {
        var condition = m.productId.equals(productId);
        if (storeId != null) condition = condition & m.storeId.equals(storeId);
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
      ..where((m) => 
        m.storeId.equals(storeId) &
        m.createdAt.isBiggerOrEqualValue(startOfDay) &
        m.createdAt.isSmallerThanValue(endOfDay)
      )
      ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
      .get();
  }
  
  /// إدراج حركة
  Future<int> insertMovement(InventoryMovementsTableCompanion movement) {
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
    return insertMovement(InventoryMovementsTableCompanion.insert(
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
    ));
  }
  
  /// إدراج حركة شراء (إضافة للمخزون)
  Future<int> recordPurchaseMovement({
    required String id,
    required String productId,
    required String storeId,
    required double qty,
    required double previousQty,
    required String purchaseId,
    String? userId,
  }) {
    return insertMovement(InventoryMovementsTableCompanion.insert(
      id: id,
      productId: productId,
      storeId: storeId,
      type: 'purchase',
      qty: qty, // موجب للشراء
      previousQty: previousQty,
      newQty: previousQty + qty,
      referenceType: const Value('purchase_order'),
      referenceId: Value(purchaseId),
      userId: Value(userId),
      createdAt: DateTime.now(),
    ));
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
    return insertMovement(InventoryMovementsTableCompanion.insert(
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
    ));
  }

  /// إدراج حركة تعديل
  Future<int> recordAdjustment({
    required String id,
    required String productId,
    required String storeId,
    required double newQty,
    required double previousQty,
    String? reason,
    String? userId,
  }) {
    return insertMovement(InventoryMovementsTableCompanion.insert(
      id: id,
      productId: productId,
      storeId: storeId,
      type: 'adjustment',
      qty: newQty - previousQty,
      previousQty: previousQty,
      newQty: newQty,
      reason: Value(reason),
      userId: Value(userId),
      createdAt: DateTime.now(),
    ));
  }
  
  /// تعيين تاريخ المزامنة
  Future<int> markAsSynced(String id) {
    return (update(inventoryMovementsTable)..where((m) => m.id.equals(id)))
      .write(InventoryMovementsTableCompanion(syncedAt: Value(DateTime.now())));
  }
  
  /// الحصول على الحركات غير المزامنة
  Future<List<InventoryMovementsTableData>> getUnsyncedMovements({String? storeId}) {
    final q = select(inventoryMovementsTable)..where((m) => m.syncedAt.isNull());
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

    return result.map((row) => MovementWithProduct(
      movement: inventoryMovementsTable.map(row.data),
      productName: row.data['product_name'] as String? ?? '',
      productBarcode: row.data['product_barcode'] as String?,
    )).toList();
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
