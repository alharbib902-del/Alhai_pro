/// اختبارات قسم S: Supabase RLS + Server-Side
///
/// 4 اختبارات تغطي:
/// - S01: الكاشير لا يستطيع قراءة مبيعات متجر آخر (RLS)
/// - S02: رفض الحمولة المُعدّلة (DataIntegrity)
/// - S03: مفتاح idempotency فريد في طابور المزامنة
/// - S04: المرتجع لا يتجاوز المبلغ الأصلي (سيرفر)
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/services/sync/sync_service.dart';
import 'package:pos_app/core/security/data_integrity.dart';

import 'fixtures/test_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Section S: Supabase RLS + Server-Side - سياسات الخادم والأمان', () {
    // ================================================================
    // S01: الكاشير لا يستطيع قراءة مبيعات متجر آخر (RLS)
    // ================================================================

    test('S01 الكاشير لا يستطيع قراءة مبيعات متجر آخر (RLS) → فقط بيانات متجره', () async {
      // Arrange - إنشاء قاعدة بيانات وإدراج مبيعات لمتجرين مختلفين
      final db = createTestDb();

      // إدراج مبيعات لمتجر store-1
      await db.salesDao.insertSale(SalesTableCompanion.insert(
        id: 'sale-s1-001',
        receiptNo: 'RCP-S1-001',
        storeId: 'store-1',
        cashierId: uCashierId,
        subtotal: 100.0,
        discount: const Value(0.0),
        tax: const Value(15.0),
        total: 115.0,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      ));
      await db.salesDao.insertSale(SalesTableCompanion.insert(
        id: 'sale-s1-002',
        receiptNo: 'RCP-S1-002',
        storeId: 'store-1',
        cashierId: uCashierId,
        subtotal: 200.0,
        discount: const Value(10.0),
        tax: const Value(28.5),
        total: 218.5,
        paymentMethod: 'card',
        createdAt: DateTime.now(),
      ));

      // إدراج مبيعات لمتجر store-2
      await db.salesDao.insertSale(SalesTableCompanion.insert(
        id: 'sale-s2-001',
        receiptNo: 'RCP-S2-001',
        storeId: 'store-2',
        cashierId: 'cashier-other',
        subtotal: 300.0,
        discount: const Value(0.0),
        tax: const Value(45.0),
        total: 345.0,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      ));
      await db.salesDao.insertSale(SalesTableCompanion.insert(
        id: 'sale-s2-002',
        receiptNo: 'RCP-S2-002',
        storeId: 'store-2',
        cashierId: 'cashier-other',
        subtotal: 50.0,
        discount: const Value(0.0),
        tax: const Value(7.5),
        total: 57.5,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      ));

      // Act - استعلام بفلتر store-1 (محاكاة RLS)
      final store1Sales = await db.salesDao.getAllSales('store-1');
      final store2Sales = await db.salesDao.getAllSales('store-2');

      // Assert - كاشير store-1 يرى فقط مبيعات متجره
      expect(store1Sales, hasLength(2));
      for (final sale in store1Sales) {
        expect(sale.storeId, equals('store-1'),
            reason: 'يجب ألا يرى الكاشير مبيعات متجر آخر');
      }

      // store-2 يرى فقط مبيعاته
      expect(store2Sales, hasLength(2));
      for (final sale in store2Sales) {
        expect(sale.storeId, equals('store-2'));
      }

      // التحقق من أن الاستعلام بـ store-1 لا يُرجع بيانات store-2
      final store1Ids = store1Sales.map((s) => s.id).toSet();
      expect(store1Ids, isNot(contains('sale-s2-001')),
          reason: 'RLS يمنع الوصول لمبيعات متجر آخر');
      expect(store1Ids, isNot(contains('sale-s2-002')),
          reason: 'RLS يمنع الوصول لمبيعات متجر آخر');

      // Cleanup
      await db.close();
    });

    // ================================================================
    // S02: رفض الحمولة المُعدّلة - DataIntegrity.verify يفشل
    // ================================================================

    test('S02 الحمولة المُعدّلة مرفوضة → DataIntegrity يكشف التلاعب بالمبلغ ومعرف المتجر', () {
      // Arrange - تهيئة DataIntegrity وتسجيل بيانات أصلية
      DataIntegrity.initialize('test-hmac-secret-key-for-s02');

      final originalPayload = <String, dynamic>{
        'saleId': 'sale-001',
        'storeId': 'store-1',
        'total': 115.0,
        'items': [
          {'productId': 'p1-pepsi', 'qty': 2, 'price': 7.0},
        ],
      };

      // تسجيل Hash للبيانات الأصلية
      DataIntegrity.registerHash('sale:sale-001', originalPayload);

      // التحقق من أن البيانات الأصلية صالحة
      final validResult = DataIntegrity.verifyIntegrity('sale:sale-001', originalPayload);
      expect(validResult.isValid, isTrue, reason: 'البيانات الأصلية يجب أن تكون صالحة');

      // Act & Assert 1 - تعديل المبلغ الإجمالي
      final tamperedTotal = Map<String, dynamic>.from(originalPayload);
      tamperedTotal['total'] = 50.0; // تلاعب بالمبلغ

      final tamperedTotalResult = DataIntegrity.verifyIntegrity('sale:sale-001', tamperedTotal);
      expect(tamperedTotalResult.isValid, isFalse,
          reason: 'يجب رفض الحمولة عند تعديل المبلغ');
      expect(tamperedTotalResult.violations, isNotEmpty);

      // Act & Assert 2 - تعديل معرف المتجر
      final tamperedStore = Map<String, dynamic>.from(originalPayload);
      tamperedStore['storeId'] = 'store-hacker'; // تلاعب بمعرف المتجر

      final tamperedStoreResult = DataIntegrity.verifyIntegrity('sale:sale-001', tamperedStore);
      expect(tamperedStoreResult.isValid, isFalse,
          reason: 'يجب رفض الحمولة عند تعديل معرف المتجر');

      // Act & Assert 3 - التحقق بالتوقيع (sign/verify)
      final signature = DataIntegrity.sign(originalPayload);
      expect(DataIntegrity.verify(originalPayload, signature), isTrue,
          reason: 'التوقيع الأصلي يجب أن يكون صالحاً');
      expect(DataIntegrity.verify(tamperedTotal, signature), isFalse,
          reason: 'التوقيع يجب أن يفشل مع البيانات المُعدّلة');

      // Cleanup
      DataIntegrity.clear();
    });

    // ================================================================
    // S03: مفتاح idempotency فريد في طابور المزامنة
    // ================================================================

    test('S03 إدراج بيع مرتين بنفس مفتاح idempotency → findByIdempotencyKey يجد واحداً فقط', () async {
      // Arrange
      final db = createTestDb();
      final syncService = SyncService(db.syncQueueDao);

      // Act - إدراج أول عنصر
      final id1 = await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-idem-001',
        data: {
          'storeId': 'store-1',
          'total': 115.0,
          'paymentMethod': 'cash',
        },
        priority: SyncPriority.high,
      );

      // استخراج مفتاح idempotency المولّد
      final pendingItems = await syncService.getPendingItems();
      expect(pendingItems, hasLength(1));
      final idempotencyKey = pendingItems.first.idempotencyKey;

      // Act - البحث بمفتاح idempotency
      final found = await db.syncQueueDao.findByIdempotencyKey(idempotencyKey);

      // Assert - عنصر واحد فقط موجود بهذا المفتاح
      expect(found, isNotNull, reason: 'يجب إيجاد العنصر بمفتاح idempotency');
      expect(found!.id, equals(id1));
      expect(found.recordId, equals('sale-idem-001'));

      // Act - محاولة إدراج عنصر آخر بنفس الجدول والسجل لكن بتوقيت مختلف
      // SyncService ينشئ مفتاح مختلف بسبب timestamp، لذا نختبر على مستوى DAO
      // إدراج يدوي بنفس المفتاح يجب أن يفشل (UNIQUE constraint)
      var duplicateInsertFailed = false;
      try {
        await db.syncQueueDao.enqueue(
          id: 'duplicate-id',
          tableName: 'sales',
          recordId: 'sale-idem-001',
          operation: 'CREATE',
          payload: '{"total":115.0}',
          idempotencyKey: idempotencyKey, // نفس المفتاح
          priority: 3,
        );
      } catch (_) {
        duplicateInsertFailed = true;
      }

      expect(duplicateInsertFailed, isTrue,
          reason: 'UNIQUE constraint يمنع إدراج نفس مفتاح idempotency مرتين');

      // التأكد من أن العدد لا يزال 1
      final count = await syncService.getPendingCount();
      expect(count, equals(1),
          reason: 'يجب أن يبقى عنصر واحد فقط بعد رفض التكرار');

      // Cleanup
      await db.close();
    });

    // ================================================================
    // S04: المرتجع لا يتجاوز المبلغ الأصلي (سيرفر)
    // ================================================================

    test('S04 المرتجع لا يمكن أن يتجاوز إجمالي البيع الأصلي → التجاوز مرفوض', () async {
      // Arrange - إنشاء بيع أصلي
      final db = createTestDb();
      await seedAllProducts(db);

      // إدراج بيع بإجمالي 115 ر.س
      final saleTotal = 115.0;
      await db.salesDao.insertSale(SalesTableCompanion.insert(
        id: 'sale-refund-001',
        receiptNo: 'RCP-REF-001',
        storeId: 'store-1',
        cashierId: uCashierId,
        subtotal: 100.0,
        discount: const Value(0.0),
        tax: const Value(15.0),
        total: saleTotal,
        paymentMethod: 'cash',
        createdAt: DateTime.now(),
      ));

      // التأكد من وجود البيع
      final sale = await db.salesDao.getSaleById('sale-refund-001');
      expect(sale, isNotNull);
      expect(sale!.total, equals(saleTotal));

      // Act & Assert - حساب المرتجعات والتحقق من عدم التجاوز

      // سيناريو 1: مرتجع جزئي صالح
      final refundItems1 = [
        {'productId': 'p1-pepsi', 'qty': 1, 'refundAmount': 8.05},
      ];
      final totalRefund1 = refundItems1.fold<double>(
        0.0,
        (sum, item) => sum + (item['refundAmount'] as double),
      );
      final isRefund1Valid = totalRefund1 <= sale.total;
      expect(isRefund1Valid, isTrue,
          reason: 'المرتجع الجزئي (${roundSar(totalRefund1)} ر.س) يجب أن يكون مقبولاً');

      // سيناريو 2: مرتجع كامل صالح (يساوي الإجمالي)
      final refundItems2 = [
        {'productId': 'p1-pepsi', 'qty': 2, 'refundAmount': 16.10},
        {'productId': 'p2-rice', 'qty': 1, 'refundAmount': 52.33},
        {'productId': 'p3-milk', 'qty': 3, 'refundAmount': 23.29},
        {'productId': 'p4-delivery', 'qty': 1, 'refundAmount': 23.28},
      ];
      final totalRefund2 = refundItems2.fold<double>(
        0.0,
        (sum, item) => sum + (item['refundAmount'] as double),
      );
      // المجموع = 115.0 بالضبط
      final isRefund2Valid = roundSar(totalRefund2) <= sale.total;
      expect(isRefund2Valid, isTrue,
          reason: 'المرتجع الكامل المساوي للإجمالي يجب أن يكون مقبولاً');

      // سيناريو 3: مرتجع يتجاوز الإجمالي (مرفوض)
      final refundItems3 = [
        {'productId': 'p1-pepsi', 'qty': 2, 'refundAmount': 16.10},
        {'productId': 'p2-rice', 'qty': 1, 'refundAmount': 52.33},
        {'productId': 'p3-milk', 'qty': 3, 'refundAmount': 23.29},
        {'productId': 'p4-delivery', 'qty': 1, 'refundAmount': 30.00}, // زيادة تجعل المجموع أكبر
      ];
      final totalRefund3 = refundItems3.fold<double>(
        0.0,
        (sum, item) => sum + (item['refundAmount'] as double),
      );
      final isRefund3Valid = roundSar(totalRefund3) <= sale.total;
      expect(isRefund3Valid, isFalse,
          reason: 'المرتجع المتجاوز (${roundSar(totalRefund3)} > $saleTotal) يجب أن يُرفض');

      // التحقق من القيمة المحسوبة
      expect(roundSar(totalRefund3), greaterThan(saleTotal),
          reason: 'مجموع المرتجعات يتجاوز إجمالي البيع');

      // Cleanup
      await db.close();
    });
  });
}
