/// اختبارات DAO المبيعات
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

Future<void> _insertTestSale(
  AppDatabase db, {
  required String id,
  required String storeId,
  String cashierId = 'cashier-1',
  String status = 'completed',
  DateTime? createdAt,
  double total = 100.0,
}) async {
  await db.salesDao.insertSale(SalesTableCompanion.insert(
    id: id,
    storeId: storeId,
    receiptNo: 'REC-$id',
    cashierId: cashierId,
    subtotal: total,
    total: total,
    paymentMethod: 'cash',
    status: Value(status),
    createdAt: createdAt ?? DateTime.now(),
  ));
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

  group('SalesDao', () {
    group('insertSale', () {
      test('يُضيف بيع جديد', () async {
        // Act
        final result = await db.salesDao.insertSale(SalesTableCompanion.insert(
          id: 'sale-1',
          storeId: 'store-1',
          receiptNo: 'REC-001',
          cashierId: 'cashier-1',
          subtotal: 100.0,
          total: 115.0,
          paymentMethod: 'cash',
          createdAt: DateTime.now(),
        ));

        // Assert
        expect(result, 1);
      });
    });

    group('getSaleById', () {
      test('يجد البيع بالمعرف', () async {
        // Arrange
        await _insertTestSale(db, id: 'sale-1', storeId: 'store-1');

        // Act
        final sale = await db.salesDao.getSaleById('sale-1');

        // Assert
        expect(sale, isNotNull);
        expect(sale!.id, 'sale-1');
        expect(sale.storeId, 'store-1');
      });

      test('يُرجع null إذا لم يُوجد البيع', () async {
        // Act
        final sale = await db.salesDao.getSaleById('non-existent');

        // Assert
        expect(sale, isNull);
      });
    });

    group('getSaleByReceiptNo', () {
      test('يجد البيع برقم الإيصال', () async {
        // Arrange
        await _insertTestSale(db, id: 'sale-1', storeId: 'store-1');

        // Act
        final sale = await db.salesDao.getSaleByReceiptNo('REC-sale-1', 'store-1');

        // Assert
        expect(sale, isNotNull);
        expect(sale!.receiptNo, 'REC-sale-1');
      });
    });

    group('getAllSales', () {
      test('يُرجع جميع مبيعات المتجر', () async {
        // Arrange
        await _insertTestSale(db, id: 'sale-1', storeId: 'store-1');
        await _insertTestSale(db, id: 'sale-2', storeId: 'store-1');
        await _insertTestSale(db, id: 'sale-3', storeId: 'store-2'); // متجر آخر

        // Act
        final sales = await db.salesDao.getAllSales('store-1');

        // Assert
        expect(sales.length, 2);
      });

      test('يُرتب المبيعات حسب التاريخ تنازلياً', () async {
        // Arrange
        final now = DateTime.now();
        await _insertTestSale(
          db,
          id: 'sale-old',
          storeId: 'store-1',
          createdAt: now.subtract(const Duration(hours: 2)),
        );
        await _insertTestSale(
          db,
          id: 'sale-new',
          storeId: 'store-1',
          createdAt: now,
        );

        // Act
        final sales = await db.salesDao.getAllSales('store-1');

        // Assert
        expect(sales.first.id, 'sale-new');
        expect(sales.last.id, 'sale-old');
      });
    });

    group('getSalesByDate', () {
      test('يُرجع مبيعات يوم محدد', () async {
        // Arrange - استخدام منتصف النهار لتجنب مشاكل منتصف الليل
        final today = DateTime.now();
        final todayNoon = DateTime(today.year, today.month, today.day, 12, 0, 0);
        final todayMorning = DateTime(today.year, today.month, today.day, 10, 0, 0);
        final yesterday = todayNoon.subtract(const Duration(days: 1));

        await _insertTestSale(
          db,
          id: 'sale-today-1',
          storeId: 'store-1',
          createdAt: todayNoon,
        );
        await _insertTestSale(
          db,
          id: 'sale-today-2',
          storeId: 'store-1',
          createdAt: todayMorning,
        );
        await _insertTestSale(
          db,
          id: 'sale-yesterday',
          storeId: 'store-1',
          createdAt: yesterday,
        );

        // Act
        final sales = await db.salesDao.getSalesByDate('store-1', todayNoon);

        // Assert
        expect(sales.length, 2);
      });
    });

    group('getSalesByDateRange', () {
      test('يُرجع مبيعات فترة محددة', () async {
        // Arrange
        final now = DateTime.now();
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        final sevenDaysAgo = now.subtract(const Duration(days: 7));

        await _insertTestSale(
          db,
          id: 'sale-recent',
          storeId: 'store-1',
          createdAt: now,
        );
        await _insertTestSale(
          db,
          id: 'sale-week',
          storeId: 'store-1',
          createdAt: threeDaysAgo,
        );
        await _insertTestSale(
          db,
          id: 'sale-old',
          storeId: 'store-1',
          createdAt: sevenDaysAgo.subtract(const Duration(days: 1)),
        );

        // Act
        final sales = await db.salesDao.getSalesByDateRange(
          'store-1',
          sevenDaysAgo,
          now,
        );

        // Assert
        expect(sales.length, 2);
      });
    });

    group('voidSale', () {
      test('يُلغي البيع', () async {
        // Arrange
        await _insertTestSale(db, id: 'sale-1', storeId: 'store-1');

        // Act
        await db.salesDao.voidSale('sale-1');
        final sale = await db.salesDao.getSaleById('sale-1');

        // Assert
        expect(sale!.status, 'voided');
      });
    });

    group('getTodayTotal', () {
      test('يحسب إجمالي مبيعات اليوم', () async {
        // Arrange
        final today = DateTime.now();
        await _insertTestSale(
          db,
          id: 'sale-1',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          total: 100.0,
          createdAt: today,
        );
        await _insertTestSale(
          db,
          id: 'sale-2',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          total: 150.0,
          createdAt: today.subtract(const Duration(hours: 1)),
        );

        // Act
        final total = await db.salesDao.getTodayTotal('store-1', 'cashier-1');

        // Assert
        expect(total, 250.0);
      });

      test('يستثني المبيعات الملغاة', () async {
        // Arrange
        final today = DateTime.now();
        await _insertTestSale(
          db,
          id: 'sale-1',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          total: 100.0,
          createdAt: today,
        );
        await _insertTestSale(
          db,
          id: 'sale-2',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          total: 150.0,
          status: 'voided',
          createdAt: today,
        );

        // Act
        final total = await db.salesDao.getTodayTotal('store-1', 'cashier-1');

        // Assert
        expect(total, 100.0);
      });

      test('يُرجع صفر إذا لم تكن هناك مبيعات', () async {
        // Act
        final total = await db.salesDao.getTodayTotal('store-1', 'cashier-1');

        // Assert
        expect(total, 0.0);
      });
    });

    group('getTodayCount', () {
      test('يحسب عدد مبيعات اليوم', () async {
        // Arrange
        final today = DateTime.now();
        await _insertTestSale(
          db,
          id: 'sale-1',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          createdAt: today,
        );
        await _insertTestSale(
          db,
          id: 'sale-2',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          createdAt: today,
        );
        await _insertTestSale(
          db,
          id: 'sale-3',
          storeId: 'store-1',
          cashierId: 'cashier-2', // كاشير آخر
          createdAt: today,
        );

        // Act
        final count = await db.salesDao.getTodayCount('store-1', 'cashier-1');

        // Assert
        expect(count, 2);
      });
    });

    group('markAsSynced', () {
      test('يُعيّن تاريخ المزامنة', () async {
        // Arrange
        await _insertTestSale(db, id: 'sale-1', storeId: 'store-1');

        // Act
        await db.salesDao.markAsSynced('sale-1');
        final sale = await db.salesDao.getSaleById('sale-1');

        // Assert
        expect(sale!.syncedAt, isNotNull);
      });
    });

    group('getUnsyncedSales', () {
      test('يُرجع المبيعات غير المزامنة', () async {
        // Arrange
        await _insertTestSale(db, id: 'sale-1', storeId: 'store-1');
        await _insertTestSale(db, id: 'sale-2', storeId: 'store-1');
        await db.salesDao.markAsSynced('sale-1');

        // Act
        final unsynced = await db.salesDao.getUnsyncedSales();

        // Assert
        expect(unsynced.length, 1);
        expect(unsynced.first.id, 'sale-2');
      });
    });

    group('watchTodaySales', () {
      test('يُراقب مبيعات اليوم', () async {
        // Arrange
        final today = DateTime.now();
        final emissions = <List<SalesTableData>>[];
        final subscription = db.salesDao.watchTodaySales('store-1').listen(emissions.add);

        await Future.delayed(const Duration(milliseconds: 50));

        // Act
        await _insertTestSale(
          db,
          id: 'sale-1',
          storeId: 'store-1',
          createdAt: today,
        );
        await Future.delayed(const Duration(milliseconds: 50));

        await _insertTestSale(
          db,
          id: 'sale-2',
          storeId: 'store-1',
          createdAt: today,
        );
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        await subscription.cancel();
        expect(emissions.length, greaterThanOrEqualTo(2));
      });
    });
  });
}
