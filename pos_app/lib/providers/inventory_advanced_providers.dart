/// مزودات المخزون المتقدمة - Advanced Inventory Providers
///
/// تحويلات المخزون، الجرد، تتبع الصلاحية
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import '../di/injection.dart';
import 'products_providers.dart';
import 'sync_providers.dart';

const _uuid = Uuid();

// ============================================================================
// تحويلات المخزون - STOCK TRANSFERS
// ============================================================================

/// مزود قائمة التحويلات - يجلب تحويلات الفرع الحالي
final stockTransfersListProvider =
    FutureProvider.autoDispose<List<StockTransfersTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = getIt<AppDatabase>();
  return (db.select(db.stockTransfersTable)
        ..where((t) =>
            t.fromStoreId.equals(storeId) | t.toStoreId.equals(storeId))
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
});

/// إنشاء تحويل مخزون جديد
Future<String?> createStockTransfer(
  WidgetRef ref, {
  required String fromStoreId,
  required String toStoreId,
  required List<Map<String, dynamic>> items,
  String? notes,
}) async {
  try {
    final db = getIt<AppDatabase>();
    final id = _uuid.v4();
    final now = DateTime.now();
    // رقم التحويل: TR-YYYYMMDD-XXXX
    final transferNumber =
        'TR-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(8)}';
    final itemsJson = jsonEncode(items);

    await db.into(db.stockTransfersTable).insert(
          StockTransfersTableCompanion.insert(
            id: id,
            transferNumber: transferNumber,
            fromStoreId: fromStoreId,
            toStoreId: toStoreId,
            items: itemsJson,
            notes: Value(notes),
            createdAt: now,
          ),
        );

    // إضافة للمزامنة
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.enqueueCreate(
        tableName: 'stock_transfers',
        recordId: id,
        data: {
          'id': id,
          'transfer_number': transferNumber,
          'from_store_id': fromStoreId,
          'to_store_id': toStoreId,
          'status': 'pending',
          'items': itemsJson,
          'notes': notes,
          'created_at': now.toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SyncQueue error: $e');
    }

    // تحديث قائمة التحويلات
    ref.invalidate(stockTransfersListProvider);
    return id;
  } catch (e) {
    if (kDebugMode) debugPrint('createStockTransfer error: $e');
    return null;
  }
}

/// تحديث حالة التحويل
Future<bool> updateTransferStatus(
  WidgetRef ref,
  String id,
  String newStatus,
) async {
  try {
    final db = getIt<AppDatabase>();
    final now = DateTime.now();

    final companion = StockTransfersTableCompanion(
      status: Value(newStatus),
      approvedAt:
          newStatus == 'approved' ? Value(now) : const Value.absent(),
      completedAt:
          newStatus == 'completed' ? Value(now) : const Value.absent(),
    );

    await (db.update(db.stockTransfersTable)
          ..where((t) => t.id.equals(id)))
        .write(companion);

    // إضافة للمزامنة
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.enqueueUpdate(
        tableName: 'stock_transfers',
        recordId: id,
        changes: {
          'status': newStatus,
          if (newStatus == 'approved')
            'approved_at': now.toIso8601String(),
          if (newStatus == 'completed')
            'completed_at': now.toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SyncQueue error: $e');
    }

    ref.invalidate(stockTransfersListProvider);
    return true;
  } catch (e) {
    if (kDebugMode) debugPrint('updateTransferStatus error: $e');
    return false;
  }
}

/// إكمال التحويل - يخصم من الفرع المصدر ويضيف للفرع الهدف
Future<bool> completeTransfer(WidgetRef ref, String id) async {
  try {
    final db = getIt<AppDatabase>();
    final now = DateTime.now();

    // جلب بيانات التحويل
    final transfer = await (db.select(db.stockTransfersTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (transfer == null) return false;

    final items = jsonDecode(transfer.items) as List<dynamic>;

    // تحديث مخزون المنتجات: خصم من المصدر وإضافة للهدف
    for (final item in items) {
      final productId = item['productId'] as String?;
      final sku = item['sku'] as String?;
      final qty = item['quantity'] as int? ?? 0;
      if (qty <= 0) continue;

      // البحث عن المنتج في الفرع المصدر بالـ SKU أو ID
      if (productId != null) {
        final sourceProduct = await (db.select(db.productsTable)
              ..where((p) =>
                  p.id.equals(productId) &
                  p.storeId.equals(transfer.fromStoreId)))
            .getSingleOrNull();
        if (sourceProduct != null) {
          final newQty =
              (sourceProduct.stockQty - qty).clamp(0, double.infinity).toInt();
          await db.productsDao.updateStock(sourceProduct.id, newQty);
        }
      }

      // البحث عن المنتج في الفرع الهدف بالـ SKU
      if (sku != null && sku.isNotEmpty) {
        final destProduct = await (db.select(db.productsTable)
              ..where((p) =>
                  p.sku.equals(sku) &
                  p.storeId.equals(transfer.toStoreId)))
            .getSingleOrNull();
        if (destProduct != null) {
          final newQty = destProduct.stockQty + qty;
          await db.productsDao.updateStock(destProduct.id, newQty);
        }
      }
    }

    // تحديث حالة التحويل إلى مكتمل
    await (db.update(db.stockTransfersTable)
          ..where((t) => t.id.equals(id)))
        .write(StockTransfersTableCompanion(
      status: const Value('completed'),
      completedAt: Value(now),
    ));

    // إضافة للمزامنة
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.enqueueUpdate(
        tableName: 'stock_transfers',
        recordId: id,
        changes: {
          'status': 'completed',
          'completed_at': now.toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SyncQueue error: $e');
    }

    ref.invalidate(stockTransfersListProvider);
    return true;
  } catch (e) {
    if (kDebugMode) debugPrint('completeTransfer error: $e');
    return false;
  }
}

// ============================================================================
// الجرد - STOCK TAKES
// ============================================================================

/// مزود قائمة عمليات الجرد
final stockTakesListProvider =
    FutureProvider.autoDispose<List<StockTakesTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = getIt<AppDatabase>();
  return (db.select(db.stockTakesTable)
        ..where((t) => t.storeId.equals(storeId))
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
      .get();
});

/// إنشاء عملية جرد جديدة - تحميل جميع المنتجات كعناصر
Future<String?> createStockTake(
  WidgetRef ref,
  String name,
) async {
  try {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return null;

    final db = getIt<AppDatabase>();
    final id = _uuid.v4();
    final now = DateTime.now();

    // تحميل جميع المنتجات لتضمينها في الجرد
    final products = await db.productsDao.getAllProducts(storeId);
    final itemsList = products
        .map((p) => {
              'productId': p.id,
              'name': p.name,
              'sku': p.sku ?? '',
              'expectedQty': p.stockQty,
              'countedQty': null,
            })
        .toList();
    final itemsJson = jsonEncode(itemsList);

    await db.into(db.stockTakesTable).insert(
          StockTakesTableCompanion.insert(
            id: id,
            storeId: storeId,
            name: name,
            items: Value(itemsJson),
            totalItems: Value(products.length),
            startedAt: now,
          ),
        );

    // إضافة للمزامنة
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.enqueueCreate(
        tableName: 'stock_takes',
        recordId: id,
        data: {
          'id': id,
          'store_id': storeId,
          'name': name,
          'status': 'in_progress',
          'items': itemsJson,
          'total_items': products.length,
          'counted_items': 0,
          'variance_items': 0,
          'started_at': now.toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SyncQueue error: $e');
    }

    ref.invalidate(stockTakesListProvider);
    return id;
  } catch (e) {
    if (kDebugMode) debugPrint('createStockTake error: $e');
    return null;
  }
}

/// تحديث عناصر الجرد (أثناء العد)
Future<bool> updateStockTakeItems(
  WidgetRef ref,
  String id, {
  required String itemsJson,
  required int countedItems,
}) async {
  try {
    final db = getIt<AppDatabase>();

    await (db.update(db.stockTakesTable)..where((t) => t.id.equals(id)))
        .write(StockTakesTableCompanion(
      items: Value(itemsJson),
      countedItems: Value(countedItems),
    ));

    // إضافة للمزامنة
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.enqueueUpdate(
        tableName: 'stock_takes',
        recordId: id,
        changes: {
          'items': itemsJson,
          'counted_items': countedItems,
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SyncQueue error: $e');
    }

    ref.invalidate(stockTakesListProvider);
    return true;
  } catch (e) {
    if (kDebugMode) debugPrint('updateStockTakeItems error: $e');
    return false;
  }
}

/// إكمال الجرد - مقارنة المتوقع بالفعلي وتحديث المخزون
Future<bool> completeStockTake(WidgetRef ref, String id) async {
  try {
    final db = getIt<AppDatabase>();
    final now = DateTime.now();

    // جلب بيانات الجرد
    final stockTake = await (db.select(db.stockTakesTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (stockTake == null) return false;

    final items = jsonDecode(stockTake.items) as List<dynamic>;
    int varianceCount = 0;
    final stockUpdates = <String, int>{};

    // حساب الفروقات وتحديث المخزون
    for (final item in items) {
      final productId = item['productId'] as String?;
      final countedQty = item['countedQty'] as int?;
      final expectedQty = item['expectedQty'] as int? ?? 0;

      if (productId != null && countedQty != null) {
        if (countedQty != expectedQty) {
          varianceCount++;
        }
        // تحديث المخزون بالكمية الفعلية المعدودة
        stockUpdates[productId] = countedQty;
      }
    }

    // تحديث المخزون بالدفعات
    if (stockUpdates.isNotEmpty) {
      await db.productsDao.batchUpdateStock(stockUpdates);
    }

    // تحديث حالة الجرد إلى مكتمل
    await (db.update(db.stockTakesTable)..where((t) => t.id.equals(id)))
        .write(StockTakesTableCompanion(
      status: const Value('completed'),
      varianceItems: Value(varianceCount),
      completedAt: Value(now),
    ));

    // إضافة للمزامنة
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.enqueueUpdate(
        tableName: 'stock_takes',
        recordId: id,
        changes: {
          'status': 'completed',
          'variance_items': varianceCount,
          'completed_at': now.toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SyncQueue error: $e');
    }

    ref.invalidate(stockTakesListProvider);
    return true;
  } catch (e) {
    if (kDebugMode) debugPrint('completeStockTake error: $e');
    return false;
  }
}

// ============================================================================
// تتبع الصلاحية - PRODUCT EXPIRY
// ============================================================================

/// بيانات عنصر الصلاحية مع اسم المنتج
class ExpiryItemData {
  final ProductExpiryTableData expiry;
  final String productName;

  const ExpiryItemData({
    required this.expiry,
    required this.productName,
  });
}

/// مزود تتبع الصلاحية - جميع المنتجات خلال 90 يوم
final expiryTrackingProvider =
    FutureProvider.autoDispose<List<ExpiryItemData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];

  final db = getIt<AppDatabase>();
  final cutoff = DateTime.now().add(const Duration(days: 90));

  final records = await (db.select(db.productExpiryTable)
        ..where(
            (e) => e.storeId.equals(storeId) & e.expiryDate.isSmallerOrEqualValue(cutoff))
        ..orderBy([(e) => OrderingTerm.asc(e.expiryDate)]))
      .get();

  // جلب أسماء المنتجات
  final productIds = records.map((e) => e.productId).toSet().toList();
  final Map<String, String> productNames = {};
  for (final pid in productIds) {
    try {
      final product = await (db.select(db.productsTable)
            ..where((p) => p.id.equals(pid)))
          .getSingleOrNull();
      if (product != null) {
        productNames[pid] = product.name;
      }
    } catch (_) {}
  }

  return records
      .map((e) => ExpiryItemData(
            expiry: e,
            productName: productNames[e.productId] ?? 'منتج غير معروف',
          ))
      .toList();
});

/// مزود المنتجات التي تنتهي خلال عدد أيام محدد
final expiringSoonProvider =
    FutureProvider.autoDispose.family<List<ExpiryItemData>, int>((ref, days) async {
  final allItems = await ref.watch(expiryTrackingProvider.future);
  final now = DateTime.now();
  final cutoff = now.add(Duration(days: days));

  return allItems
      .where((item) =>
          item.expiry.expiryDate.isBefore(cutoff) &&
          item.expiry.expiryDate.isAfter(now))
      .toList();
});

/// إضافة سجل صلاحية جديد
Future<String?> addExpiryRecord(
  WidgetRef ref, {
  required String productId,
  required DateTime expiryDate,
  required int quantity,
  String? batchNumber,
  String? notes,
}) async {
  try {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) return null;

    final db = getIt<AppDatabase>();
    final id = _uuid.v4();
    final now = DateTime.now();

    await db.into(db.productExpiryTable).insert(
          ProductExpiryTableCompanion.insert(
            id: id,
            productId: productId,
            storeId: storeId,
            batchNumber: Value(batchNumber),
            expiryDate: expiryDate,
            quantity: quantity,
            notes: Value(notes),
            createdAt: now,
          ),
        );

    // إضافة للمزامنة
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.enqueueCreate(
        tableName: 'product_expiry',
        recordId: id,
        data: {
          'id': id,
          'product_id': productId,
          'store_id': storeId,
          'batch_number': batchNumber,
          'expiry_date': expiryDate.toIso8601String(),
          'quantity': quantity,
          'notes': notes,
          'created_at': now.toIso8601String(),
        },
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SyncQueue error: $e');
    }

    ref.invalidate(expiryTrackingProvider);
    return id;
  } catch (e) {
    if (kDebugMode) debugPrint('addExpiryRecord error: $e');
    return null;
  }
}

/// حذف سجل صلاحية
Future<bool> deleteExpiryRecord(WidgetRef ref, String id) async {
  try {
    final db = getIt<AppDatabase>();

    await (db.delete(db.productExpiryTable)
          ..where((e) => e.id.equals(id)))
        .go();

    // إضافة للمزامنة
    try {
      final syncService = ref.read(syncServiceProvider);
      await syncService.enqueueDelete(
        tableName: 'product_expiry',
        recordId: id,
      );
    } catch (e) {
      if (kDebugMode) debugPrint('SyncQueue error: $e');
    }

    ref.invalidate(expiryTrackingProvider);
    return true;
  } catch (e) {
    if (kDebugMode) debugPrint('deleteExpiryRecord error: $e');
    return false;
  }
}
