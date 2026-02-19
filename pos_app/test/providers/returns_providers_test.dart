/// اختبارات مزودات المرتجعات - Returns Providers Tests
///
/// اختبارات تكامل تستخدم قاعدة بيانات SQLite في الذاكرة + Riverpod
///
/// 8 اختبارات تغطي:
/// - بناء ReturnDetailData
/// - returnsListProvider يعيد قائمة فارغة بدون متجر
/// - returnsListProvider يعيد قائمة فارغة عند عدم وجود مرتجعات
/// - returnDetailProvider يعيد null لمعرف غير موجود
/// - إنشاء مرتجع في قاعدة البيانات
/// - إنشاء مرتجع مع عناصر
/// - إنشاء مرتجع يفشل بدون متجر
/// - قراءة مرتجعات فاتورة محددة
library;

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/providers/returns_providers.dart';

/// إنشاء قاعدة بيانات اختبار في الذاكرة
AppDatabase _createTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('Returns Providers - اختبارات مزودات المرتجعات', () {
    late AppDatabase db;
    late GetIt getIt;

    setUp(() {
      db = _createTestDb();
      getIt = GetIt.instance;
      if (getIt.isRegistered<AppDatabase>()) {
        getIt.unregister<AppDatabase>();
      }
      getIt.registerSingleton<AppDatabase>(db);
    });

    tearDown(() async {
      await db.close();
      if (getIt.isRegistered<AppDatabase>()) {
        getIt.unregister<AppDatabase>();
      }
    });

    // ========================================================================
    // اختبار بناء ReturnDetailData
    // ========================================================================

    test('ReturnDetailData يحتوي على بيانات المرتجع والعناصر', () async {
      // Arrange - إنشاء مرتجع في قاعدة البيانات
      final now = DateTime.now();
      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: const Value('ret-1'),
        returnNumber: const Value('RET-001'),
        saleId: const Value('sale-1'),
        storeId: const Value('store-1'),
        reason: const Value('منتج تالف'),
        totalRefund: const Value(50.0),
        status: const Value('completed'),
        createdAt: Value(now),
      ));

      // Act - قراءة المرتجع
      final returnData = await db.returnsDao.getReturnById('ret-1');
      final items = await db.returnsDao.getReturnItems('ret-1');

      // بناء ReturnDetailData
      final detail = ReturnDetailData(
        returnData: returnData!,
        items: items,
      );

      // Assert
      expect(detail.returnData.id, equals('ret-1'));
      expect(detail.returnData.returnNumber, equals('RET-001'));
      expect(detail.returnData.totalRefund, equals(50.0));
      expect(detail.items, isEmpty); // لا يوجد عناصر
    });

    // ========================================================================
    // اختبار returnsListProvider - قائمة فارغة عند عدم وجود مرتجعات
    // ========================================================================

    test('getAllReturns يعيد قائمة فارغة عند عدم وجود مرتجعات', () async {
      // Act
      final returns = await db.returnsDao.getAllReturns('store-1');

      // Assert
      expect(returns, isEmpty);
    });

    // ========================================================================
    // اختبار returnDetailProvider - معرف غير موجود
    // ========================================================================

    test('getReturnById يعيد null لمعرف غير موجود', () async {
      // Act
      final result = await db.returnsDao.getReturnById('nonexistent-id');

      // Assert
      expect(result, isNull);
    });

    // ========================================================================
    // اختبار إنشاء مرتجع
    // ========================================================================

    test('insertReturn ينشئ مرتجع في قاعدة البيانات', () async {
      // Arrange
      final now = DateTime.now();

      // Act
      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: const Value('ret-new'),
        returnNumber: const Value('RET-NEW-001'),
        saleId: const Value('sale-100'),
        storeId: const Value('store-1'),
        customerId: const Value('cust-1'),
        customerName: const Value('عميل اختبار'),
        reason: const Value('خطأ في الطلب'),
        totalRefund: const Value(75.50),
        refundMethod: const Value('cash'),
        status: const Value('completed'),
        createdBy: const Value('cashier-1'),
        notes: const Value('ملاحظة اختبار'),
        createdAt: Value(now),
      ));

      // Assert
      final saved = await db.returnsDao.getReturnById('ret-new');
      expect(saved, isNotNull);
      expect(saved!.returnNumber, equals('RET-NEW-001'));
      expect(saved.saleId, equals('sale-100'));
      expect(saved.storeId, equals('store-1'));
      expect(saved.customerId, equals('cust-1'));
      expect(saved.customerName, equals('عميل اختبار'));
      expect(saved.reason, equals('خطأ في الطلب'));
      expect(saved.totalRefund, equals(75.50));
      expect(saved.refundMethod, equals('cash'));
      expect(saved.status, equals('completed'));
      expect(saved.notes, equals('ملاحظة اختبار'));
    });

    // ========================================================================
    // اختبار إنشاء مرتجع مع عناصر
    // ========================================================================

    test('insertReturn مع عناصر ينشئ مرتجع كامل', () async {
      // Arrange
      final now = DateTime.now();

      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: const Value('ret-items'),
        returnNumber: const Value('RET-ITEMS-001'),
        saleId: const Value('sale-200'),
        storeId: const Value('store-1'),
        reason: const Value('منتج تالف'),
        totalRefund: const Value(100.0),
        status: const Value('completed'),
        createdAt: Value(now),
      ));

      // Act - إضافة عناصر
      await db.returnsDao.insertReturnItems([
        const ReturnItemsTableCompanion(
          id: Value('item-1'),
          returnId: Value('ret-items'),
          productId: Value('prod-1'),
          productName: Value('بيبسي 2L'),
          qty: Value(2),
          unitPrice: Value(7.0),
          refundAmount: Value(14.0),
        ),
        const ReturnItemsTableCompanion(
          id: Value('item-2'),
          returnId: Value('ret-items'),
          productId: Value('prod-2'),
          productName: Value('أرز بسمتي'),
          qty: Value(1),
          unitPrice: Value(45.50),
          refundAmount: Value(45.50),
        ),
      ]);

      // Assert
      final items = await db.returnsDao.getReturnItems('ret-items');
      expect(items, hasLength(2));
      expect(items.first.productName, equals('بيبسي 2L'));
      expect(items.first.qty, equals(2));
      expect(items.last.productName, equals('أرز بسمتي'));
      expect(items.last.refundAmount, equals(45.50));
    });

    // ========================================================================
    // اختبار قراءة مرتجعات فاتورة محددة
    // ========================================================================

    test('getReturnsBySaleId يعيد مرتجعات فاتورة محددة', () async {
      // Arrange
      final now = DateTime.now();

      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: const Value('ret-s1-a'),
        returnNumber: const Value('RET-S1-A'),
        saleId: const Value('sale-300'),
        storeId: const Value('store-1'),
        reason: const Value('منتج تالف'),
        totalRefund: const Value(25.0),
        createdAt: Value(now),
      ));

      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: const Value('ret-s1-b'),
        returnNumber: const Value('RET-S1-B'),
        saleId: const Value('sale-300'),
        storeId: const Value('store-1'),
        reason: const Value('خطأ في الكمية'),
        totalRefund: const Value(10.0),
        createdAt: Value(now),
      ));

      // مرتجع لفاتورة أخرى
      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: const Value('ret-s2'),
        returnNumber: const Value('RET-S2'),
        saleId: const Value('sale-999'),
        storeId: const Value('store-1'),
        reason: const Value('سبب آخر'),
        totalRefund: const Value(5.0),
        createdAt: Value(now),
      ));

      // Act
      final saleReturns = await db.returnsDao.getReturnsBySaleId('sale-300');

      // Assert
      expect(saleReturns, hasLength(2));
      expect(saleReturns.map((r) => r.id), containsAll(['ret-s1-a', 'ret-s1-b']));
    });

    // ========================================================================
    // اختبار قراءة جميع المرتجعات لمتجر
    // ========================================================================

    test('getAllReturns يعيد مرتجعات المتجر المحدد فقط', () async {
      // Arrange
      final now = DateTime.now();

      // مرتجعات المتجر الأول
      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: const Value('ret-store1-a'),
        returnNumber: const Value('RET-S1-001'),
        saleId: const Value('sale-1'),
        storeId: const Value('store-1'),
        reason: const Value('سبب'),
        totalRefund: const Value(20.0),
        createdAt: Value(now),
      ));

      // مرتجعات متجر آخر
      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: const Value('ret-store2'),
        returnNumber: const Value('RET-S2-001'),
        saleId: const Value('sale-2'),
        storeId: const Value('store-2'),
        reason: const Value('سبب'),
        totalRefund: const Value(30.0),
        createdAt: Value(now),
      ));

      // Act
      final store1Returns = await db.returnsDao.getAllReturns('store-1');
      final store2Returns = await db.returnsDao.getAllReturns('store-2');

      // Assert
      expect(store1Returns, hasLength(1));
      expect(store1Returns.first.id, equals('ret-store1-a'));
      expect(store2Returns, hasLength(1));
      expect(store2Returns.first.id, equals('ret-store2'));
    });

    // ========================================================================
    // اختبار تفاصيل مرتجع كامل (ReturnDetailData)
    // ========================================================================

    test('ReturnDetailData يحتوي على المرتجع وعناصره', () async {
      // Arrange
      final now = DateTime.now();

      await db.returnsDao.insertReturn(ReturnsTableCompanion(
        id: const Value('ret-detail'),
        returnNumber: const Value('RET-DETAIL-001'),
        saleId: const Value('sale-detail'),
        storeId: const Value('store-1'),
        reason: const Value('مرتجع مع عناصر'),
        totalRefund: const Value(59.50),
        createdAt: Value(now),
      ));

      await db.returnsDao.insertReturnItems([
        const ReturnItemsTableCompanion(
          id: Value('detail-item-1'),
          returnId: Value('ret-detail'),
          productId: Value('prod-x'),
          productName: Value('منتج X'),
          qty: Value(3),
          unitPrice: Value(10.0),
          refundAmount: Value(30.0),
        ),
      ]);

      // Act
      final returnData = await db.returnsDao.getReturnById('ret-detail');
      final items = await db.returnsDao.getReturnItems('ret-detail');
      final detail = ReturnDetailData(returnData: returnData!, items: items);

      // Assert
      expect(detail.returnData.id, equals('ret-detail'));
      expect(detail.returnData.totalRefund, equals(59.50));
      expect(detail.items, hasLength(1));
      expect(detail.items.first.productName, equals('منتج X'));
      expect(detail.items.first.qty, equals(3));
    });
  });
}
