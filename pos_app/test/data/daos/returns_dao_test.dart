/// اختبارات DAO المرتجعات
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

Future<int> _insertTestReturn(
  AppDatabase db, {
  required String id,
  required String storeId,
  String returnNumber = 'RET-001',
  String saleId = 'sale-1',
  double totalRefund = 50.0,
  String? reason,
  String? customerId,
  String? customerName,
  DateTime? createdAt,
}) async {
  return db.returnsDao.insertReturn(ReturnsTableCompanion.insert(
    id: id,
    storeId: storeId,
    returnNumber: returnNumber,
    saleId: saleId,
    totalRefund: totalRefund,
    reason: Value(reason),
    customerId: Value(customerId),
    customerName: Value(customerName),
    createdAt: createdAt ?? DateTime.now(),
  ));
}

Future<void> _insertTestReturnItems(
  AppDatabase db, {
  required String returnId,
  required List<Map<String, dynamic>> items,
}) async {
  final companions = items.map((item) => ReturnItemsTableCompanion.insert(
    id: item['id'] as String,
    returnId: returnId,
    productId: item['productId'] as String,
    productName: item['productName'] as String? ?? 'منتج اختبار',
    qty: item['qty'] as int? ?? 1,
    unitPrice: item['unitPrice'] as double? ?? 10.0,
    refundAmount: item['refundAmount'] as double? ?? 10.0,
  )).toList();
  await db.returnsDao.insertReturnItems(companions);
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

  group('ReturnsDao', () {
    group('insertReturn', () {
      test('يُضيف مرتجع جديد', () async {
        // Act
        final result = await db.returnsDao.insertReturn(
          ReturnsTableCompanion.insert(
            id: 'ret-1',
            storeId: 'store-1',
            returnNumber: 'RET-001',
            saleId: 'sale-1',
            totalRefund: 100.0,
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });

      test('يُضيف مرتجع مع سبب وعميل', () async {
        // Act
        final result = await db.returnsDao.insertReturn(
          ReturnsTableCompanion.insert(
            id: 'ret-2',
            storeId: 'store-1',
            returnNumber: 'RET-002',
            saleId: 'sale-2',
            totalRefund: 75.0,
            reason: const Value('منتج تالف'),
            customerId: const Value('cust-1'),
            customerName: const Value('أحمد'),
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getReturnById', () {
      test('يجد المرتجع بالمعرف', () async {
        // Arrange
        await _insertTestReturn(db, id: 'ret-1', storeId: 'store-1', totalRefund: 120.0);

        // Act
        final returnData = await db.returnsDao.getReturnById('ret-1');

        // Assert
        expect(returnData, isNotNull);
        expect(returnData!.totalRefund, 120.0);
        expect(returnData.storeId, 'store-1');
      });

      test('يُرجع null إذا لم يُوجد المرتجع', () async {
        // Act
        final returnData = await db.returnsDao.getReturnById('non-existent');

        // Assert
        expect(returnData, isNull);
      });
    });

    group('getAllReturns', () {
      test('يُرجع جميع مرتجعات المتجر', () async {
        // Arrange
        await _insertTestReturn(db, id: 'ret-1', storeId: 'store-1', returnNumber: 'RET-001');
        await _insertTestReturn(db, id: 'ret-2', storeId: 'store-1', returnNumber: 'RET-002');
        await _insertTestReturn(db, id: 'ret-3', storeId: 'store-2', returnNumber: 'RET-003');

        // Act
        final returns = await db.returnsDao.getAllReturns('store-1');

        // Assert
        expect(returns.length, 2);
      });

      test('يُرتب المرتجعات حسب تاريخ الإنشاء تنازلياً', () async {
        // Arrange
        final older = DateTime(2025, 1, 1);
        final newer = DateTime(2025, 6, 1);
        await _insertTestReturn(db, id: 'ret-old', storeId: 'store-1', returnNumber: 'RET-OLD', createdAt: older);
        await _insertTestReturn(db, id: 'ret-new', storeId: 'store-1', returnNumber: 'RET-NEW', createdAt: newer);

        // Act
        final returns = await db.returnsDao.getAllReturns('store-1');

        // Assert
        expect(returns.first.id, 'ret-new');
        expect(returns.last.id, 'ret-old');
      });
    });

    group('getReturnsByDateRange', () {
      test('يُرجع المرتجعات ضمن نطاق التاريخ', () async {
        // Arrange
        await _insertTestReturn(db, id: 'ret-1', storeId: 'store-1', returnNumber: 'RET-001', createdAt: DateTime(2025, 3, 15));
        await _insertTestReturn(db, id: 'ret-2', storeId: 'store-1', returnNumber: 'RET-002', createdAt: DateTime(2025, 5, 20));
        await _insertTestReturn(db, id: 'ret-3', storeId: 'store-1', returnNumber: 'RET-003', createdAt: DateTime(2025, 7, 10));

        // Act
        final returns = await db.returnsDao.getReturnsByDateRange(
          'store-1',
          DateTime(2025, 3, 1),
          DateTime(2025, 6, 1),
        );

        // Assert
        expect(returns.length, 2);
      });

      test('يستبعد المرتجعات خارج النطاق', () async {
        // Arrange
        await _insertTestReturn(db, id: 'ret-1', storeId: 'store-1', returnNumber: 'RET-001', createdAt: DateTime(2025, 1, 1));

        // Act
        final returns = await db.returnsDao.getReturnsByDateRange(
          'store-1',
          DateTime(2025, 6, 1),
          DateTime(2025, 12, 31),
        );

        // Assert
        expect(returns.length, 0);
      });
    });

    group('getReturnsBySaleId', () {
      test('يُرجع المرتجعات المرتبطة بعملية بيع', () async {
        // Arrange
        await _insertTestReturn(db, id: 'ret-1', storeId: 'store-1', returnNumber: 'RET-001', saleId: 'sale-100');
        await _insertTestReturn(db, id: 'ret-2', storeId: 'store-1', returnNumber: 'RET-002', saleId: 'sale-100');
        await _insertTestReturn(db, id: 'ret-3', storeId: 'store-1', returnNumber: 'RET-003', saleId: 'sale-200');

        // Act
        final returns = await db.returnsDao.getReturnsBySaleId('sale-100');

        // Assert
        expect(returns.length, 2);
      });

      test('يُرجع قائمة فارغة إذا لم توجد مرتجعات للبيع', () async {
        // Act
        final returns = await db.returnsDao.getReturnsBySaleId('sale-nonexistent');

        // Assert
        expect(returns, isEmpty);
      });
    });

    group('insertReturnItems', () {
      test('يُضيف عناصر المرتجع', () async {
        // Arrange
        await _insertTestReturn(db, id: 'ret-1', storeId: 'store-1');

        // Act
        await _insertTestReturnItems(db, returnId: 'ret-1', items: [
          {'id': 'ri-1', 'productId': 'prod-1', 'productName': 'تفاح', 'qty': 3, 'unitPrice': 5.0, 'refundAmount': 15.0},
          {'id': 'ri-2', 'productId': 'prod-2', 'productName': 'موز', 'qty': 2, 'unitPrice': 3.0, 'refundAmount': 6.0},
        ]);

        // Assert
        final items = await db.returnsDao.getReturnItems('ret-1');
        expect(items.length, 2);
      });
    });

    group('getReturnItems', () {
      test('يُرجع عناصر مرتجع محدد', () async {
        // Arrange
        await _insertTestReturn(db, id: 'ret-1', storeId: 'store-1', returnNumber: 'RET-001');
        await _insertTestReturn(db, id: 'ret-2', storeId: 'store-1', returnNumber: 'RET-002');

        await _insertTestReturnItems(db, returnId: 'ret-1', items: [
          {'id': 'ri-1', 'productId': 'prod-1', 'productName': 'تفاح', 'qty': 2, 'unitPrice': 10.0, 'refundAmount': 20.0},
        ]);
        await _insertTestReturnItems(db, returnId: 'ret-2', items: [
          {'id': 'ri-2', 'productId': 'prod-2', 'productName': 'موز', 'qty': 5, 'unitPrice': 4.0, 'refundAmount': 20.0},
          {'id': 'ri-3', 'productId': 'prod-3', 'productName': 'برتقال', 'qty': 1, 'unitPrice': 8.0, 'refundAmount': 8.0},
        ]);

        // Act
        final itemsForRet1 = await db.returnsDao.getReturnItems('ret-1');
        final itemsForRet2 = await db.returnsDao.getReturnItems('ret-2');

        // Assert
        expect(itemsForRet1.length, 1);
        expect(itemsForRet1.first.productId, 'prod-1');
        expect(itemsForRet2.length, 2);
      });

      test('يُرجع قائمة فارغة إذا لم توجد عناصر', () async {
        // Act
        final items = await db.returnsDao.getReturnItems('ret-nonexistent');

        // Assert
        expect(items, isEmpty);
      });
    });
  });
}
