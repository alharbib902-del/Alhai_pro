/// اختبارات قسم L: الأداء (Performance Benchmarks)
///
/// 4 اختبارات أداء تغطي:
/// - L01: بداية باردة < 3 ثوانٍ
/// - L02: بحث 10 آلاف منتج < 500 مللي ثانية
/// - L03: استعلام 50 ألف فاتورة < 2 ثانية
/// - L04: 500 عنصر طابور مزامنة < 10 ثوانٍ
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/services/sync/sync_service.dart';

import 'fixtures/test_fixtures.dart';

void main() {
  group('Section L: Performance - الأداء', () {
    // ================================================================
    // L01: بداية باردة < 3 ثوانٍ
    // ================================================================
    test('L01: بداية باردة - تهيئة قاعدة البيانات وإعداد البيانات < 3 ثوانٍ',
        () async {
      final stopwatch = Stopwatch()..start();

      // تهيئة قاعدة البيانات من الصفر
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      // إعداد جميع المنتجات الاختبارية
      await seedAllProducts(db);

      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;

      // التأكد من أن الوقت أقل من 3000 مللي ثانية
      expect(
        elapsedMs,
        lessThan(3000),
        reason:
            'بداية باردة (تهيئة DB + seed) استغرقت $elapsedMs مللي ثانية، '
            'المتوقع أقل من 3000 مللي ثانية',
      );

      await db.close();
    });

    // ================================================================
    // L02: بحث 10 آلاف منتج < 500 مللي ثانية
    // ================================================================
    test('L02: بحث في 10,000 منتج - استعلام البحث < 500 مللي ثانية', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      // إدراج 10,000 منتج باستخدام batch
      await db.batch((batch) {
        for (var i = 0; i < 10000; i++) {
          batch.insert(
            db.productsTable,
            ProductsTableCompanion.insert(
              id: 'prod-$i',
              storeId: 'store-1',
              name: 'منتج اختبار $i ${i.isEven ? "بيبسي" : "حليب"}',
              price: 10.0 + (i % 100),
              createdAt: DateTime(2025, 1, 1),
              stockQty: Value(i % 200),
              isActive: const Value(true),
              trackInventory: const Value(true),
            ),
          );
        }
      });

      // التحقق من عدد المنتجات
      final count = await db.productsDao.getProductsCount('store-1');
      expect(count, equals(10000));

      // قياس زمن البحث
      final stopwatch = Stopwatch()..start();
      final results =
          await db.productsDao.searchProducts('بيبسي', 'store-1');
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;

      // التأكد من وجود نتائج
      expect(results, isNotEmpty, reason: 'يجب أن يعيد البحث نتائج');

      // التأكد من أن الوقت أقل من 500 مللي ثانية
      expect(
        elapsedMs,
        lessThan(500),
        reason: 'بحث في 10,000 منتج استغرق $elapsedMs مللي ثانية، '
            'المتوقع أقل من 500 مللي ثانية',
      );

      await db.close();
    });

    // ================================================================
    // L03: استعلام 50 ألف فاتورة < 2 ثانية
    // ================================================================
    test('L03: استعلام 50,000 فاتورة - استعلام بالتاريخ < 2 ثانية', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      final targetDate = DateTime(2025, 6, 15);

      // إدراج 50,000 فاتورة باستخدام batch
      await db.batch((batch) {
        for (var i = 0; i < 50000; i++) {
          // توزيع الفواتير على أيام مختلفة: ~1000 فاتورة لكل يوم من 50 يوم
          final dayOffset = i % 50;
          final saleDate = DateTime(2025, 6, 1).add(Duration(
            days: dayOffset,
            hours: i % 24,
            minutes: i % 60,
          ));

          batch.insert(
            db.salesTable,
            SalesTableCompanion.insert(
              id: 'sale-$i',
              storeId: 'store-1',
              receiptNo: 'RCP-${i.toString().padLeft(6, '0')}',
              cashierId: 'cashier-${i % 5}',
              subtotal: 100.0 + (i % 500),
              total: 115.0 + (i % 500),
              paymentMethod: i.isEven ? 'cash' : 'card',
              createdAt: saleDate,
            ),
          );
        }
      });

      // قياس زمن الاستعلام بالتاريخ
      final stopwatch = Stopwatch()..start();
      final results =
          await db.salesDao.getSalesByDate('store-1', targetDate);
      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;

      // التأكد من وجود نتائج
      expect(results, isNotEmpty,
          reason: 'يجب أن يعيد الاستعلام فواتير لتاريخ 2025-06-15');

      // التأكد من أن الوقت أقل من 2000 مللي ثانية
      expect(
        elapsedMs,
        lessThan(2000),
        reason:
            'استعلام 50,000 فاتورة بالتاريخ استغرق $elapsedMs مللي ثانية، '
            'المتوقع أقل من 2000 مللي ثانية',
      );

      await db.close();
    });

    // ================================================================
    // L04: 500 عنصر طابور مزامنة < 10 ثوانٍ
    // ================================================================
    test('L04: معالجة 500 عنصر طابور مزامنة < 10 ثوانٍ', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());

      // إدراج 500 عنصر في طابور المزامنة
      await db.batch((batch) {
        for (var i = 0; i < 500; i++) {
          batch.insert(
            db.syncQueueTable,
            SyncQueueTableCompanion.insert(
              id: 'sync-$i',
              tableName_: i % 3 == 0
                  ? 'sales'
                  : (i % 3 == 1 ? 'products' : 'inventory_movements'),
              recordId: 'record-$i',
              operation: i % 3 == 0
                  ? 'CREATE'
                  : (i % 3 == 1 ? 'UPDATE' : 'DELETE'),
              payload: '{"id": "record-$i", "data": "test-payload-$i"}',
              idempotencyKey: 'idem-key-$i',
              priority: Value(i % 3 == 0 ? 3 : (i % 3 == 1 ? 2 : 1)),
              createdAt: DateTime(2025, 1, 1).add(Duration(minutes: i)),
            ),
          );
        }
      });

      // التحقق من عدد العناصر المعلقة
      final pendingCount = await db.syncQueueDao.getPendingCount();
      expect(pendingCount, equals(500));

      // قياس زمن معالجة الطابور (قراءة + تحديث الحالة)
      final stopwatch = Stopwatch()..start();

      // الخطوة 1: استرجاع العناصر المعلقة مرتبة بالأولوية
      final pendingItems = await db.syncQueueDao.getPendingItems();

      // الخطوة 2: محاكاة المعالجة - تحديث كل عنصر إلى "synced"
      for (final item in pendingItems) {
        await db.syncQueueDao.markAsSynced(item.id);
      }

      stopwatch.stop();

      final elapsedMs = stopwatch.elapsedMilliseconds;

      // التأكد من معالجة جميع العناصر
      expect(pendingItems.length, equals(500));

      // التأكد من عدم وجود عناصر معلقة بعد المعالجة
      final remainingCount = await db.syncQueueDao.getPendingCount();
      expect(remainingCount, equals(0));

      // التأكد من أن الوقت أقل من 10000 مللي ثانية
      expect(
        elapsedMs,
        lessThan(10000),
        reason:
            'معالجة 500 عنصر طابور مزامنة استغرقت $elapsedMs مللي ثانية، '
            'المتوقع أقل من 10000 مللي ثانية',
      );

      await db.close();
    });
  });
}
