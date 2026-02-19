/// اختبارات DAO المشتريات
///
/// اختبارات تكامل تستخدم قاعدة بيانات SQLite في الذاكرة
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/data/local/app_database.dart';

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

Future<int> _insertTestPurchase(
  AppDatabase db, {
  required String id,
  required String storeId,
  String purchaseNumber = 'PO-001',
  String? supplierId,
  String? supplierName,
  double total = 500.0,
  String status = 'draft',
  DateTime? createdAt,
}) async {
  return db.purchasesDao.insertPurchase(PurchasesTableCompanion.insert(
    id: id,
    storeId: storeId,
    purchaseNumber: purchaseNumber,
    supplierId: Value(supplierId),
    supplierName: Value(supplierName),
    total: Value(total),
    status: Value(status),
    createdAt: createdAt ?? DateTime.now(),
  ));
}

Future<void> _insertTestPurchaseItems(
  AppDatabase db, {
  required String purchaseId,
  required List<Map<String, dynamic>> items,
}) async {
  final companions = items.map((item) => PurchaseItemsTableCompanion.insert(
    id: item['id'] as String,
    purchaseId: purchaseId,
    productId: item['productId'] as String,
    productName: item['productName'] as String? ?? 'منتج اختبار',
    qty: item['qty'] as int? ?? 10,
    unitCost: item['unitCost'] as double? ?? 20.0,
    total: item['total'] as double? ?? 200.0,
  )).toList();
  await db.purchasesDao.insertPurchaseItems(companions);
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('PurchasesDao', () {
    group('insertPurchase', () {
      test('يُضيف أمر شراء جديد', () async {
        // Act
        final result = await db.purchasesDao.insertPurchase(
          PurchasesTableCompanion.insert(
            id: 'pur-1',
            storeId: 'store-1',
            purchaseNumber: 'PO-001',
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });

      test('يُضيف أمر شراء مع مورّد', () async {
        // Act
        final result = await db.purchasesDao.insertPurchase(
          PurchasesTableCompanion.insert(
            id: 'pur-2',
            storeId: 'store-1',
            purchaseNumber: 'PO-002',
            supplierId: const Value('sup-1'),
            supplierName: const Value('مورّد الفواكه'),
            total: const Value(1500.0),
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getPurchaseById', () {
      test('يجد أمر الشراء بالمعرف', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', total: 750.0);

        // Act
        final purchase = await db.purchasesDao.getPurchaseById('pur-1');

        // Assert
        expect(purchase, isNotNull);
        expect(purchase!.total, 750.0);
        expect(purchase.storeId, 'store-1');
      });

      test('يُرجع null إذا لم يُوجد أمر الشراء', () async {
        // Act
        final purchase = await db.purchasesDao.getPurchaseById('non-existent');

        // Assert
        expect(purchase, isNull);
      });
    });

    group('getAllPurchases', () {
      test('يُرجع جميع مشتريات المتجر', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', purchaseNumber: 'PO-001');
        await _insertTestPurchase(db, id: 'pur-2', storeId: 'store-1', purchaseNumber: 'PO-002');
        await _insertTestPurchase(db, id: 'pur-3', storeId: 'store-2', purchaseNumber: 'PO-003');

        // Act
        final purchases = await db.purchasesDao.getAllPurchases('store-1');

        // Assert
        expect(purchases.length, 2);
      });

      test('يُرتب المشتريات حسب تاريخ الإنشاء تنازلياً', () async {
        // Arrange
        final older = DateTime(2025, 1, 1);
        final newer = DateTime(2025, 6, 1);
        await _insertTestPurchase(db, id: 'pur-old', storeId: 'store-1', purchaseNumber: 'PO-OLD', createdAt: older);
        await _insertTestPurchase(db, id: 'pur-new', storeId: 'store-1', purchaseNumber: 'PO-NEW', createdAt: newer);

        // Act
        final purchases = await db.purchasesDao.getAllPurchases('store-1');

        // Assert
        expect(purchases.first.id, 'pur-new');
        expect(purchases.last.id, 'pur-old');
      });
    });

    group('getPurchasesByStatus', () {
      test('يُرجع المشتريات حسب الحالة', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', purchaseNumber: 'PO-001', status: 'draft');
        await _insertTestPurchase(db, id: 'pur-2', storeId: 'store-1', purchaseNumber: 'PO-002', status: 'received');
        await _insertTestPurchase(db, id: 'pur-3', storeId: 'store-1', purchaseNumber: 'PO-003', status: 'draft');

        // Act
        final drafts = await db.purchasesDao.getPurchasesByStatus('store-1', 'draft');
        final received = await db.purchasesDao.getPurchasesByStatus('store-1', 'received');

        // Assert
        expect(drafts.length, 2);
        expect(received.length, 1);
      });

      test('يُرجع قائمة فارغة للحالة غير الموجودة', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', purchaseNumber: 'PO-001', status: 'draft');

        // Act
        final cancelled = await db.purchasesDao.getPurchasesByStatus('store-1', 'cancelled');

        // Assert
        expect(cancelled, isEmpty);
      });
    });

    group('updateStatus', () {
      test('يُحدّث حالة أمر الشراء', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', purchaseNumber: 'PO-001', status: 'draft');

        // Act
        final result = await db.purchasesDao.updateStatus('pur-1', 'approved');
        final purchase = await db.purchasesDao.getPurchaseById('pur-1');

        // Assert
        expect(result, 1);
        expect(purchase!.status, 'approved');
        expect(purchase.updatedAt, isNotNull);
      });
    });

    group('receivePurchase', () {
      test('يُعيّن الحالة كمُستلم ويُسجل تاريخ الاستلام', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', purchaseNumber: 'PO-001', status: 'approved');

        // Act
        final result = await db.purchasesDao.receivePurchase('pur-1');
        final purchase = await db.purchasesDao.getPurchaseById('pur-1');

        // Assert
        expect(result, 1);
        expect(purchase!.status, 'received');
        expect(purchase.receivedAt, isNotNull);
        expect(purchase.updatedAt, isNotNull);
      });
    });

    group('deletePurchase', () {
      test('يحذف أمر الشراء', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', purchaseNumber: 'PO-001');

        // Act
        final deleted = await db.purchasesDao.deletePurchase('pur-1');
        final purchase = await db.purchasesDao.getPurchaseById('pur-1');

        // Assert
        expect(deleted, 1);
        expect(purchase, isNull);
      });
    });

    group('insertPurchaseItems', () {
      test('يُضيف عناصر أمر الشراء', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', purchaseNumber: 'PO-001');

        // Act
        await _insertTestPurchaseItems(db, purchaseId: 'pur-1', items: [
          {'id': 'pi-1', 'productId': 'prod-1', 'productName': 'تفاح', 'qty': 50, 'unitCost': 3.0, 'total': 150.0},
          {'id': 'pi-2', 'productId': 'prod-2', 'productName': 'موز', 'qty': 30, 'unitCost': 2.0, 'total': 60.0},
        ]);

        // Assert
        final items = await db.purchasesDao.getPurchaseItems('pur-1');
        expect(items.length, 2);
      });
    });

    group('getPurchaseItems', () {
      test('يُرجع عناصر أمر شراء محدد', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', purchaseNumber: 'PO-001');
        await _insertTestPurchase(db, id: 'pur-2', storeId: 'store-1', purchaseNumber: 'PO-002');

        await _insertTestPurchaseItems(db, purchaseId: 'pur-1', items: [
          {'id': 'pi-1', 'productId': 'prod-1', 'productName': 'تفاح', 'qty': 20, 'unitCost': 5.0, 'total': 100.0},
        ]);
        await _insertTestPurchaseItems(db, purchaseId: 'pur-2', items: [
          {'id': 'pi-2', 'productId': 'prod-2', 'productName': 'موز', 'qty': 10, 'unitCost': 3.0, 'total': 30.0},
          {'id': 'pi-3', 'productId': 'prod-3', 'productName': 'برتقال', 'qty': 15, 'unitCost': 4.0, 'total': 60.0},
        ]);

        // Act
        final itemsForPur1 = await db.purchasesDao.getPurchaseItems('pur-1');
        final itemsForPur2 = await db.purchasesDao.getPurchaseItems('pur-2');

        // Assert
        expect(itemsForPur1.length, 1);
        expect(itemsForPur1.first.productId, 'prod-1');
        expect(itemsForPur2.length, 2);
      });

      test('يُرجع قائمة فارغة إذا لم توجد عناصر', () async {
        // Act
        final items = await db.purchasesDao.getPurchaseItems('pur-nonexistent');

        // Assert
        expect(items, isEmpty);
      });
    });

    group('deletePurchaseItems', () {
      test('يحذف جميع عناصر أمر الشراء', () async {
        // Arrange
        await _insertTestPurchase(db, id: 'pur-1', storeId: 'store-1', purchaseNumber: 'PO-001');
        await _insertTestPurchaseItems(db, purchaseId: 'pur-1', items: [
          {'id': 'pi-1', 'productId': 'prod-1', 'productName': 'تفاح', 'qty': 20, 'unitCost': 5.0, 'total': 100.0},
          {'id': 'pi-2', 'productId': 'prod-2', 'productName': 'موز', 'qty': 10, 'unitCost': 3.0, 'total': 30.0},
        ]);

        // Act
        final deleted = await db.purchasesDao.deletePurchaseItems('pur-1');

        // Assert
        expect(deleted, 2);
        final items = await db.purchasesDao.getPurchaseItems('pur-1');
        expect(items, isEmpty);
      });

      test('يُرجع 0 إذا لم توجد عناصر للحذف', () async {
        // Act
        final deleted = await db.purchasesDao.deletePurchaseItems('pur-nonexistent');

        // Assert
        expect(deleted, 0);
      });
    });
  });
}
