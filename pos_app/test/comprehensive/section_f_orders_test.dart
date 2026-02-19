/// اختبارات قسم F: الطلبات (Orders)
///
/// 5 اختبارات تغطي:
/// - F01: إنشاء طلب بدون عميل
/// - F02: إنشاء طلب مع عميل
/// - F03: تعليق سلة (فاتورة معلقة) واستعادتها
/// - F04: إلغاء طلب مسودة قبل الدفع
/// - F05: منع التعديل بعد الدفع (إلغاء بيع مكتمل يغير الحالة إلى voided)
library;

import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/core/errors/app_exceptions.dart';
import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/services/sync/sync_service.dart' show SyncPriority;
import 'fixtures/test_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Section F: الطلبات (Orders)', () {
    // ==================================================================
    // F01: إنشاء طلب بدون عميل
    // ==================================================================

    test('F01 إنشاء طلب بدون عميل - customerId يكون null', () async {
      final db = createTestDb();
      addTearDown(() => db.close());

      final now = DateTime.now();

      await db.ordersDao.createOrder(OrdersTableCompanion.insert(
        id: 'order-f01',
        storeId: 'store-1',
        orderNumber: 'ORD-20250601-001',
        status: const Value('draft'),
        total: const Value(50.0),
        subtotal: const Value(50.0),
        orderDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      final order = await db.ordersDao.getOrderById('order-f01');

      expect(order, isNotNull);
      expect(order!.id, 'order-f01');
      expect(order.storeId, 'store-1');
      expect(order.customerId, isNull);
      expect(order.status, 'draft');
      expect(order.total, 50.0);
      expect(order.orderNumber, 'ORD-20250601-001');
    });

    // ==================================================================
    // F02: إنشاء طلب مع عميل
    // ==================================================================

    test('F02 إنشاء طلب مع عميل - customerId مرتبط بـ C1', () async {
      final db = createTestDb();
      addTearDown(() => db.close());

      final now = DateTime.now();

      await db.ordersDao.createOrder(OrdersTableCompanion.insert(
        id: 'order-f02',
        storeId: 'store-1',
        orderNumber: 'ORD-20250601-002',
        customerId: const Value(c1Id),
        status: const Value('pending'),
        total: const Value(120.75),
        subtotal: const Value(105.0),
        taxAmount: const Value(15.75),
        orderDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      final order = await db.ordersDao.getOrderById('order-f02');

      expect(order, isNotNull);
      expect(order!.id, 'order-f02');
      expect(order.customerId, c1Id);
      expect(order.status, 'pending');
      expect(order.total, 120.75);
      expect(order.subtotal, 105.0);
      expect(order.taxAmount, 15.75);
    });

    // ==================================================================
    // F03: تعليق سلة (فاتورة معلقة) واستعادتها
    // ==================================================================

    test('F03 تعليق سلة واستعادتها عبر HeldInvoicesTable', () async {
      final db = createTestDb();
      addTearDown(() => db.close());

      final p1 = createP1();
      final cartState = CartState(
        items: [PosCartItem(product: p1, quantity: 3)],
        discount: 2.0,
        customerId: c1Id,
        customerName: c1Name,
      );

      final cartJson = jsonEncode(cartState.toJson());
      final now = DateTime.now();

      // حفظ الفاتورة المعلقة في قاعدة البيانات
      await db.into(db.heldInvoicesTable).insert(
        HeldInvoicesTableCompanion.insert(
          id: 'held-f03',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          customerName: const Value(c1Name),
          items: cartJson,
          subtotal: const Value(21.0),
          discount: const Value(2.0),
          total: const Value(19.0),
          notes: const Value('فاتورة معلقة للاختبار'),
          createdAt: now,
        ),
      );

      // استرجاع الفاتورة المعلقة
      final rows = await db.select(db.heldInvoicesTable).get();
      expect(rows.length, 1);

      final held = rows.first;
      expect(held.id, 'held-f03');
      expect(held.storeId, 'store-1');
      expect(held.customerName, c1Name);
      expect(held.subtotal, 21.0);
      expect(held.discount, 2.0);
      expect(held.total, 19.0);
      expect(held.notes, 'فاتورة معلقة للاختبار');

      // استعادة CartState من JSON المحفوظ
      final restoredCart = CartState.fromJson(
        jsonDecode(held.items) as Map<String, dynamic>,
      );
      expect(restoredCart.items.length, 1);
      expect(restoredCart.items.first.product.id, 'p1-pepsi');
      expect(restoredCart.items.first.quantity, 3);
      expect(restoredCart.discount, 2.0);
      expect(restoredCart.customerId, c1Id);
      expect(restoredCart.customerName, c1Name);

      // حذف الفاتورة المعلقة بعد الاستعادة
      await (db.delete(db.heldInvoicesTable)
            ..where((t) => t.id.equals('held-f03')))
          .go();

      final afterDelete = await db.select(db.heldInvoicesTable).get();
      expect(afterDelete, isEmpty);
    });

    // ==================================================================
    // F04: إلغاء طلب مسودة قبل الدفع
    // ==================================================================

    test('F04 إلغاء طلب مسودة قبل الدفع - الطلب يختفي', () async {
      final db = createTestDb();
      addTearDown(() => db.close());

      final now = DateTime.now();

      // إنشاء طلب مسودة
      await db.ordersDao.createOrder(OrdersTableCompanion.insert(
        id: 'order-f04-draft',
        storeId: 'store-1',
        orderNumber: 'ORD-20250601-004',
        status: const Value('draft'),
        total: const Value(35.0),
        orderDate: now,
        createdAt: now,
        updatedAt: now,
      ));

      // التحقق من وجوده
      final before = await db.ordersDao.getOrderById('order-f04-draft');
      expect(before, isNotNull);
      expect(before!.status, 'draft');

      // إلغاء الطلب عبر cancelOrder
      await db.ordersDao.cancelOrder('order-f04-draft', 'العميل غير موجود');

      // التحقق من تغيير الحالة إلى cancelled
      final after = await db.ordersDao.getOrderById('order-f04-draft');
      expect(after, isNotNull);
      expect(after!.status, 'cancelled');
      expect(after.cancelReason, 'العميل غير موجود');
      expect(after.cancelledAt, isNotNull);
    });

    // ==================================================================
    // F05: منع التعديل بعد الدفع (voidSale يغير الحالة إلى voided)
    // ==================================================================

    test('F05 بيع مكتمل - voidSale يغير الحالة إلى voided ويرجع المخزون', () async {
      final setup = createSaleServiceSetup();
      addTearDown(() => setup.dispose());

      await seedAllProducts(setup.db);

      final p1 = createP1();
      final items = [PosCartItem(product: p1, quantity: 2)];

      // إنشاء بيع مكتمل
      final saleId = await createCompletedSale(
        saleService: setup.saleService,
        items: items,
        subtotal: 14.0,
        discount: 0,
        tax: 2.10,
        total: 16.10,
      );

      // التحقق من أن البيع مكتمل
      final saleBefore = await setup.db.salesDao.getSaleById(saleId);
      expect(saleBefore, isNotNull);
      expect(saleBefore!.status, 'completed');

      // التحقق من خصم المخزون (50 - 2 = 48)
      final productBefore = await setup.db.productsDao.getProductById('p1-pepsi');
      expect(productBefore!.stockQty, 48);

      // إلغاء البيع
      await setup.saleService.voidSale(saleId, reason: 'خطأ في البيع');

      // التحقق من تغيير حالة البيع إلى voided
      final saleAfter = await setup.db.salesDao.getSaleById(saleId);
      expect(saleAfter, isNotNull);
      expect(saleAfter!.status, 'voided');

      // التحقق من إرجاع المخزون (48 + 2 = 50)
      final productAfter = await setup.db.productsDao.getProductById('p1-pepsi');
      expect(productAfter!.stockQty, 50);

      // محاولة إلغاء البيع مرة أخرى يجب أن يرمي استثناء
      // drift transaction قد يغلف الاستثناء
      Object? caughtError;
      try {
        await setup.saleService.voidSale(saleId);
      } catch (e) {
        caughtError = e;
      }
      expect(caughtError, isNotNull, reason: 'إلغاء بيع ملغي مسبقاً يجب أن يرمي استثناء');
      final isSaleException = caughtError is SaleException ||
          (caughtError.toString().contains('SALE_ALREADY_VOIDED'));
      expect(isSaleException, isTrue,
          reason: 'الاستثناء يجب أن يكون SaleException.alreadyVoided: $caughtError');
    });
  });
}
