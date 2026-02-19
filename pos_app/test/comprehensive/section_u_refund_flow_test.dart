/// اختبارات قسم U: تدفق الإرجاع الكامل
///
/// 5 اختبارات تغطي:
/// - U01: إرجاع كامل يعيد جميع المنتجات
/// - U02: إرجاع جزئي (بعض المنتجات فقط)
/// - U03: إرجاع ينشئ سجل في جدول المرتجعات
/// - U04: إرجاع ينشئ حركة مخزون من نوع return
/// - U05: إرجاع يحفظ السبب والملاحظات
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/services/sync/sync_service.dart';

import 'fixtures/test_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Section U: تدفق الإرجاع الكامل', () {
    late SaleServiceTestSetup setup;

    setUp(() async {
      setup = createSaleServiceSetup();
      await seedAllProducts(setup.db);
    });

    tearDown(() async {
      await setup.dispose();
    });

    // ==================================================================
    // U01: إرجاع كامل يعيد جميع المنتجات
    // ==================================================================

    test('U01 إرجاع كامل: إنشاء مرتجع كامل ببيانات صحيحة ومبلغ مطابق',
        () async {
      final p1 = createP1(); // 7.00 SAR
      final p2 = createP2(); // 45.50 SAR

      // إنشاء بيع: P1x2 + P2x1
      final p1Subtotal = roundSar(p1.price * 2); // 14.00
      final p2Subtotal = roundSar(p2.price * 1); // 45.50
      final subtotal = roundSar(p1Subtotal + p2Subtotal); // 59.50
      final vat = computeVat(subtotal); // 8.93
      final total = roundSar(subtotal + vat); // 68.43

      final saleId = await createCompletedSale(
        saleService: setup.saleService,
        items: [
          PosCartItem(product: p1, quantity: 2),
          PosCartItem(product: p2, quantity: 1),
        ],
        subtotal: subtotal,
        discount: 0,
        tax: vat,
        total: total,
        paymentMethod: 'cash',
      );

      // إنشاء مرتجع كامل
      const returnId = 'return-u01';
      await setup.db.returnsDao.insertReturn(
        ReturnsTableCompanion.insert(
          id: returnId,
          returnNumber: 'RET-U01-001',
          saleId: saleId,
          storeId: 'store-1',
          type: const Value('full'),
          refundMethod: const Value('cash'),
          totalRefund: total,
          createdAt: DateTime.now(),
        ),
      );

      // إدراج عناصر المرتجع (كل المنتجات)
      await setup.db.returnsDao.insertReturnItems([
        ReturnItemsTableCompanion.insert(
          id: 'ret-item-u01-1',
          returnId: returnId,
          productId: p1.id,
          productName: p1.name,
          qty: 2,
          unitPrice: p1.price,
          refundAmount: roundSar(p1.price * 2 * (1 + vatRate)),
        ),
        ReturnItemsTableCompanion.insert(
          id: 'ret-item-u01-2',
          returnId: returnId,
          productId: p2.id,
          productName: p2.name,
          qty: 1,
          unitPrice: p2.price,
          refundAmount: roundSar(p2.price * 1 * (1 + vatRate)),
        ),
      ]);

      // التحقق من المرتجع
      final returnRecord = await setup.db.returnsDao.getReturnById(returnId);
      expect(returnRecord, isNotNull);
      expect(returnRecord!.type, 'full');
      expect(returnRecord.totalRefund, total);
      expect(returnRecord.saleId, saleId);
      expect(returnRecord.refundMethod, 'cash');
      expect(returnRecord.status, 'completed');

      // التحقق من عناصر المرتجع
      final returnItems = await setup.db.returnsDao.getReturnItems(returnId);
      expect(returnItems.length, 2);

      // التحقق من أن كلا المنتجين مسجلان
      final returnedProductIds =
          returnItems.map((i) => i.productId).toSet();
      expect(returnedProductIds, contains(p1.id));
      expect(returnedProductIds, contains(p2.id));

      // التحقق من الكميات
      final p1Return = returnItems.firstWhere((i) => i.productId == p1.id);
      expect(p1Return.qty, 2);
      expect(p1Return.unitPrice, p1.price);

      final p2Return = returnItems.firstWhere((i) => i.productId == p2.id);
      expect(p2Return.qty, 1);
      expect(p2Return.unitPrice, p2.price);
    });

    // ==================================================================
    // U02: إرجاع جزئي (بعض المنتجات فقط)
    // ==================================================================

    test('U02 إرجاع جزئي: إرجاع منتج واحد من بيع متعدد المنتجات', () async {
      final p1 = createP1(); // 7.00 SAR
      final p2 = createP2(); // 45.50 SAR

      // إنشاء بيع: P1x3 + P2x2
      final p1Sub = roundSar(p1.price * 3); // 21.00
      final p2Sub = roundSar(p2.price * 2); // 91.00
      final subtotal = roundSar(p1Sub + p2Sub); // 112.00
      final vat = computeVat(subtotal); // 16.80
      final total = roundSar(subtotal + vat); // 128.80

      final saleId = await createCompletedSale(
        saleService: setup.saleService,
        items: [
          PosCartItem(product: p1, quantity: 3),
          PosCartItem(product: p2, quantity: 2),
        ],
        subtotal: subtotal,
        discount: 0,
        tax: vat,
        total: total,
        paymentMethod: 'cash',
      );

      // إرجاع جزئي: P1x1 فقط
      const returnId = 'return-u02';
      final refundPerItem = roundSar(p1.price * (1 + vatRate)); // 8.05
      final refundAmount = roundSar(refundPerItem * 1); // 8.05

      await setup.db.returnsDao.insertReturn(
        ReturnsTableCompanion.insert(
          id: returnId,
          returnNumber: 'RET-U02-001',
          saleId: saleId,
          storeId: 'store-1',
          type: const Value('partial'),
          refundMethod: const Value('cash'),
          totalRefund: refundAmount,
          createdAt: DateTime.now(),
        ),
      );

      await setup.db.returnsDao.insertReturnItems([
        ReturnItemsTableCompanion.insert(
          id: 'ret-item-u02-1',
          returnId: returnId,
          productId: p1.id,
          productName: p1.name,
          qty: 1,
          unitPrice: p1.price,
          refundAmount: refundAmount,
        ),
      ]);

      // التحقق من أن المرتجع جزئي
      final returnRecord = await setup.db.returnsDao.getReturnById(returnId);
      expect(returnRecord, isNotNull);
      expect(returnRecord!.type, 'partial');
      expect(returnRecord.totalRefund, refundAmount);
      expect(returnRecord.totalRefund, lessThan(total));

      // التحقق من أن عنصر واحد فقط مُرجع
      final returnItems = await setup.db.returnsDao.getReturnItems(returnId);
      expect(returnItems.length, 1);
      expect(returnItems.first.productId, p1.id);
      expect(returnItems.first.qty, 1);

      // التحقق من أن P2 لم يُرجع
      final p2Items =
          returnItems.where((i) => i.productId == p2.id).toList();
      expect(p2Items, isEmpty);
    });

    // ==================================================================
    // U03: إرجاع ينشئ سجل في جدول المرتجعات مع ربط بالبيع الأصلي
    // ==================================================================

    test('U03 سجل المرتجعات: المرتجع مرتبط بالبيع الأصلي ويُسترجع بالبحث',
        () async {
      final p1 = createP1();

      // إنشاء بيعين مختلفين
      final saleId1 = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 2)],
        subtotal: 14.00,
        discount: 0,
        tax: 2.10,
        total: 16.10,
        paymentMethod: 'cash',
      );

      final saleId2 = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.00,
        discount: 0,
        tax: 1.05,
        total: 8.05,
        paymentMethod: 'cash',
      );

      // إنشاء مرتجعين: واحد لكل بيع
      await setup.db.returnsDao.insertReturn(
        ReturnsTableCompanion.insert(
          id: 'return-u03-a',
          returnNumber: 'RET-U03-001',
          saleId: saleId1,
          storeId: 'store-1',
          type: const Value('full'),
          refundMethod: const Value('cash'),
          totalRefund: 16.10,
          createdAt: DateTime.now(),
        ),
      );

      await setup.db.returnsDao.insertReturn(
        ReturnsTableCompanion.insert(
          id: 'return-u03-b',
          returnNumber: 'RET-U03-002',
          saleId: saleId2,
          storeId: 'store-1',
          type: const Value('full'),
          refundMethod: const Value('cash'),
          totalRefund: 8.05,
          createdAt: DateTime.now(),
        ),
      );

      // التحقق من استرجاع المرتجعات حسب البيع
      final returnsBySale1 =
          await setup.db.returnsDao.getReturnsBySaleId(saleId1);
      expect(returnsBySale1.length, 1);
      expect(returnsBySale1.first.id, 'return-u03-a');
      expect(returnsBySale1.first.totalRefund, 16.10);

      final returnsBySale2 =
          await setup.db.returnsDao.getReturnsBySaleId(saleId2);
      expect(returnsBySale2.length, 1);
      expect(returnsBySale2.first.id, 'return-u03-b');
      expect(returnsBySale2.first.totalRefund, 8.05);

      // التحقق من استرجاع كل المرتجعات حسب المتجر
      final allReturns =
          await setup.db.returnsDao.getAllReturns('store-1');
      expect(allReturns.length, 2);

      // التحقق من أن المبلغ الإجمالي صحيح
      final totalRefunded =
          allReturns.fold<double>(0.0, (sum, r) => sum + r.totalRefund);
      expect(totalRefunded, closeTo(24.15, 0.01));
    });

    // ==================================================================
    // U04: إرجاع ينشئ حركة مخزون من نوع return
    // ==================================================================

    test('U04 حركة مخزون إرجاع: تسجيل حركة return مع الكميات الصحيحة',
        () async {
      final p1 = createP1(); // stockQty=50

      // إنشاء بيع: P1x5
      final subtotal = roundSar(p1.price * 5); // 35.00
      final vat = computeVat(subtotal); // 5.25
      final total = roundSar(subtotal + vat); // 40.25

      final saleId = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 5)],
        subtotal: subtotal,
        discount: 0,
        tax: vat,
        total: total,
        paymentMethod: 'cash',
      );

      // التحقق من المخزون بعد البيع: 50 - 5 = 45
      final productAfterSale =
          await setup.db.productsDao.getProductById(p1.id);
      expect(productAfterSale!.stockQty, 45);

      // إنشاء مرتجع: P1x3
      const returnId = 'return-u04';
      await setup.db.returnsDao.insertReturn(
        ReturnsTableCompanion.insert(
          id: returnId,
          returnNumber: 'RET-U04-001',
          saleId: saleId,
          storeId: 'store-1',
          type: const Value('partial'),
          refundMethod: const Value('cash'),
          totalRefund: roundSar(p1.price * 3 * (1 + vatRate)),
          createdAt: DateTime.now(),
        ),
      );

      await setup.db.returnsDao.insertReturnItems([
        ReturnItemsTableCompanion.insert(
          id: 'ret-item-u04-1',
          returnId: returnId,
          productId: p1.id,
          productName: p1.name,
          qty: 3,
          unitPrice: p1.price,
          refundAmount: roundSar(p1.price * 3 * (1 + vatRate)),
        ),
      ]);

      // تسجيل حركة مخزون من نوع return
      await setup.db.inventoryDao.insertMovement(
        InventoryMovementsTableCompanion.insert(
          id: 'inv-u04-return',
          productId: p1.id,
          storeId: 'store-1',
          type: 'return',
          qty: 3, // موجب (إرجاع للمخزون)
          previousQty: 45,
          newQty: 48,
          referenceType: const Value('return'),
          referenceId: const Value(returnId),
          createdAt: DateTime.now(),
        ),
      );

      // تحديث المخزون
      await setup.db.productsDao.updateStock(p1.id, 48);

      // التحقق من حركة المخزون
      final movements =
          await setup.db.inventoryDao.getMovementsByProduct(p1.id);
      // حركة البيع (sale) + حركة الإرجاع (return)
      final returnMovement =
          movements.firstWhere((m) => m.type == 'return');
      expect(returnMovement.qty, 3); // موجب (إرجاع)
      expect(returnMovement.previousQty, 45);
      expect(returnMovement.newQty, 48);
      expect(returnMovement.referenceType, 'return');
      expect(returnMovement.referenceId, returnId);

      // التحقق من المخزون النهائي: 45 + 3 = 48
      final productFinal =
          await setup.db.productsDao.getProductById(p1.id);
      expect(productFinal!.stockQty, 48);
    });

    // ==================================================================
    // U05: إرجاع يحفظ السبب والملاحظات
    // ==================================================================

    test('U05 السبب والملاحظات: تخزين واسترجاع بيانات المرتجع التفصيلية',
        () async {
      final p1 = createP1();

      // إنشاء بيع
      final saleId = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.00,
        discount: 0,
        tax: 1.05,
        total: 8.05,
        paymentMethod: 'cash',
      );

      // إنشاء مرتجع مع سبب وملاحظات وبيانات العميل
      const returnId = 'return-u05';
      const reason = 'منتج تالف';
      const notes = 'العميل لاحظ تلف في العبوة عند الفتح - تم الاستبدال';
      const customerId = 'cust-u05';
      const customerName = 'أحمد محمد';

      await setup.db.returnsDao.insertReturn(
        ReturnsTableCompanion.insert(
          id: returnId,
          returnNumber: 'RET-U05-001',
          saleId: saleId,
          storeId: 'store-1',
          type: const Value('full'),
          refundMethod: const Value('cash'),
          totalRefund: 8.05,
          reason: const Value(reason),
          notes: const Value(notes),
          customerId: const Value(customerId),
          customerName: const Value(customerName),
          createdBy: const Value(uCashierId),
          createdAt: DateTime.now(),
        ),
      );

      // التحقق من جميع البيانات التفصيلية
      final returnRecord = await setup.db.returnsDao.getReturnById(returnId);
      expect(returnRecord, isNotNull);
      expect(returnRecord!.reason, reason);
      expect(returnRecord.notes, notes);
      expect(returnRecord.customerId, customerId);
      expect(returnRecord.customerName, customerName);
      expect(returnRecord.createdBy, uCashierId);
      expect(returnRecord.returnNumber, startsWith('RET-'));
      expect(returnRecord.status, 'completed');

      // التحقق من أن المرتجع غير مزامن بعد
      expect(returnRecord.syncedAt, isNull);

      // محاكاة المزامنة
      await setup.db.returnsDao.markAsSynced(returnId);
      final synced = await setup.db.returnsDao.getReturnById(returnId);
      expect(synced!.syncedAt, isNotNull);
    });
  });
}
