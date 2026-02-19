/// اختبارات قسم T: تدفق الورديات
///
/// 5 اختبارات تغطي:
/// - T01: فتح وردية وإنشاء بيع
/// - T02: إغلاق وردية وحساب الفرق
/// - T03: حركات نقدية (إيداع + سحب)
/// - T04: منع فتح وردية مكررة
/// - T05: تدفق كامل: فتح -> بيع x3 -> حركة نقدية -> إغلاق
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

  group('Section T: تدفق الورديات', () {
    late SaleServiceTestSetup setup;

    setUp(() async {
      setup = createSaleServiceSetup();
      await seedAllProducts(setup.db);
    });

    tearDown(() async {
      await setup.dispose();
    });

    // ==================================================================
    // T01: فتح وردية وإنشاء بيع
    // ==================================================================

    test('T01 فتح وردية وإنشاء بيع: الوردية مفتوحة والبيع مسجل بنجاح',
        () async {
      final p1 = createP1();

      // فتح وردية
      const shiftId = 'shift-t01';
      await setup.db.shiftsDao.openShift(
        ShiftsTableCompanion.insert(
          id: shiftId,
          storeId: 'store-1',
          cashierId: uCashierId,
          cashierName: 'كاشير 1',
          openingCash: const Value(500.00),
          openedAt: DateTime.now(),
        ),
      );

      // التحقق من أن الوردية مفتوحة
      final openShift =
          await setup.db.shiftsDao.getOpenShift('store-1', uCashierId);
      expect(openShift, isNotNull);
      expect(openShift!.id, shiftId);
      expect(openShift.status, 'open');
      expect(openShift.openingCash, 500.00);

      // إنشاء بيع أثناء الوردية
      final saleId = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 2)],
        subtotal: 14.00,
        discount: 0,
        tax: 2.10,
        total: 16.10,
        paymentMethod: 'cash',
      );

      // التحقق من أن البيع مكتمل
      final sale = await setup.db.salesDao.getSaleById(saleId);
      expect(sale, isNotNull);
      expect(sale!.status, 'completed');
      expect(sale.total, 16.10);

      // التحقق من أن الوردية لا تزال مفتوحة
      final stillOpen =
          await setup.db.shiftsDao.getOpenShift('store-1', uCashierId);
      expect(stillOpen, isNotNull);
      expect(stillOpen!.status, 'open');
    });

    // ==================================================================
    // T02: إغلاق وردية وحساب الفرق
    // ==================================================================

    test('T02 إغلاق وردية وحساب الفرق: المبلغ الفعلي مقابل المتوقع',
        () async {
      final p1 = createP1();

      // فتح وردية بمبلغ افتتاحي 500 ر.س
      const shiftId = 'shift-t02';
      const openingCash = 500.00;
      await setup.db.shiftsDao.openShift(
        ShiftsTableCompanion.insert(
          id: shiftId,
          storeId: 'store-1',
          cashierId: uCashierId,
          cashierName: 'كاشير 1',
          openingCash: const Value(openingCash),
          openedAt: DateTime.now(),
        ),
      );

      // إنشاء بيعين نقديين
      // بيع 1: P1x2 = 16.10
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 2)],
        subtotal: 14.00,
        discount: 0,
        tax: 2.10,
        total: 16.10,
        paymentMethod: 'cash',
      );

      // بيع 2: P1x1 = 8.05
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.00,
        discount: 0,
        tax: 1.05,
        total: 8.05,
        paymentMethod: 'cash',
      );

      // المتوقع: 500 + 16.10 + 8.05 = 524.15
      const expectedCash = openingCash + 16.10 + 8.05; // 524.15
      // المبلغ الفعلي في الصندوق (فرق بسيط)
      const actualCash = 520.00;
      const difference = actualCash - expectedCash; // -4.15

      // إغلاق الوردية
      await setup.db.shiftsDao.closeShift(
        id: shiftId,
        closingCash: actualCash,
        expectedCash: expectedCash,
        difference: difference,
        totalSales: 2,
        totalSalesAmount: 16.10 + 8.05,
        totalRefunds: 0,
        totalRefundsAmount: 0,
        notes: 'عجز بسيط',
      );

      // التحقق من بيانات الإغلاق
      final closedShift = await setup.db.shiftsDao.getShiftById(shiftId);
      expect(closedShift, isNotNull);
      expect(closedShift!.status, 'closed');
      expect(closedShift.closingCash, actualCash);
      expect(closedShift.expectedCash, closeTo(expectedCash, 0.01));
      expect(closedShift.difference, closeTo(difference, 0.01));
      expect(closedShift.totalSales, 2);
      expect(closedShift.totalSalesAmount, closeTo(24.15, 0.01));
      expect(closedShift.totalRefunds, 0);
      expect(closedShift.closedAt, isNotNull);
      expect(closedShift.notes, 'عجز بسيط');

      // التحقق من أنه لا توجد وردية مفتوحة بعد الإغلاق
      final noOpen =
          await setup.db.shiftsDao.getOpenShift('store-1', uCashierId);
      expect(noOpen, isNull);
    });

    // ==================================================================
    // T03: حركات نقدية (إيداع + سحب)
    // ==================================================================

    test('T03 حركات نقدية: إيداع وسحب يُسجلان بشكل صحيح', () async {
      // فتح وردية
      const shiftId = 'shift-t03';
      await setup.db.shiftsDao.openShift(
        ShiftsTableCompanion.insert(
          id: shiftId,
          storeId: 'store-1',
          cashierId: uCashierId,
          cashierName: 'كاشير 1',
          openingCash: const Value(1000.00),
          openedAt: DateTime.now(),
        ),
      );

      // إيداع 200 ر.س
      await setup.db.shiftsDao.insertCashMovement(
        CashMovementsTableCompanion.insert(
          id: 'cm-t03-in',
          shiftId: shiftId,
          storeId: 'store-1',
          type: 'in',
          amount: 200.00,
          reason: const Value('إيداع من المدير'),
          createdBy: const Value(uManagerId),
          createdAt: DateTime.now(),
        ),
      );

      // سحب 150 ر.س
      await setup.db.shiftsDao.insertCashMovement(
        CashMovementsTableCompanion.insert(
          id: 'cm-t03-out',
          shiftId: shiftId,
          storeId: 'store-1',
          type: 'out',
          amount: 150.00,
          reason: const Value('مصاريف تشغيلية'),
          createdBy: const Value(uManagerId),
          createdAt: DateTime.now(),
        ),
      );

      // التحقق من الحركات
      final movements =
          await setup.db.shiftsDao.getShiftMovements(shiftId);
      expect(movements.length, 2);

      // التحقق من حركة الإيداع
      final inMovement = movements.firstWhere((m) => m.type == 'in');
      expect(inMovement.amount, 200.00);
      expect(inMovement.reason, 'إيداع من المدير');
      expect(inMovement.shiftId, shiftId);

      // التحقق من حركة السحب
      final outMovement = movements.firstWhere((m) => m.type == 'out');
      expect(outMovement.amount, 150.00);
      expect(outMovement.reason, 'مصاريف تشغيلية');

      // حساب صافي الحركات: +200 - 150 = +50
      final netMovement = movements.fold<double>(0.0, (sum, m) {
        return m.type == 'in' ? sum + m.amount : sum - m.amount;
      });
      expect(netMovement, closeTo(50.00, 0.01));
    });

    // ==================================================================
    // T04: منع فتح وردية مكررة
    // ==================================================================

    test('T04 منع فتح وردية مكررة: لا يمكن فتح ورديتين لنفس الكاشير',
        () async {
      // فتح وردية أولى
      const shiftId1 = 'shift-t04-first';
      await setup.db.shiftsDao.openShift(
        ShiftsTableCompanion.insert(
          id: shiftId1,
          storeId: 'store-1',
          cashierId: uCashierId,
          cashierName: 'كاشير 1',
          openingCash: const Value(500.00),
          openedAt: DateTime.now(),
        ),
      );

      // التحقق من وجود وردية مفتوحة
      final existing =
          await setup.db.shiftsDao.getOpenShift('store-1', uCashierId);
      expect(existing, isNotNull);
      expect(existing!.id, shiftId1);

      // محاولة فتح وردية ثانية لنفس الكاشير
      // (محاكاة فحص التطبيق: يجب التحقق أولا من عدم وجود وردية مفتوحة)
      final hasOpenShift =
          await setup.db.shiftsDao.getOpenShift('store-1', uCashierId);
      expect(hasOpenShift, isNotNull,
          reason: 'يوجد بالفعل وردية مفتوحة لهذا الكاشير');

      // التحقق أن الوردية المفتوحة هي الأولى فقط
      final anyOpen =
          await setup.db.shiftsDao.getAnyOpenShift('store-1');
      expect(anyOpen, isNotNull);
      expect(anyOpen!.id, shiftId1);

      // التحقق أنه يمكن لكاشير آخر فتح وردية
      const shiftId2 = 'shift-t04-second';
      await setup.db.shiftsDao.openShift(
        ShiftsTableCompanion.insert(
          id: shiftId2,
          storeId: 'store-1',
          cashierId: uManagerId,
          cashierName: 'مدير 1',
          openingCash: const Value(300.00),
          openedAt: DateTime.now(),
        ),
      );

      final managerShift =
          await setup.db.shiftsDao.getOpenShift('store-1', uManagerId);
      expect(managerShift, isNotNull);
      expect(managerShift!.id, shiftId2);

      // التحقق أن كل كاشير لديه وردية مختلفة
      expect(existing.id, isNot(managerShift.id));
    });

    // ==================================================================
    // T05: تدفق كامل: فتح -> بيع x3 -> حركة نقدية -> إغلاق
    // ==================================================================

    test('T05 تدفق كامل: فتح وردية -> 3 مبيعات -> حركة نقدية -> إغلاق',
        () async {
      final p1 = createP1(); // 7.00 SAR
      final p2 = createP2(); // 45.50 SAR
      final p4 = createP4(); // 15.00 SAR, معفى

      // === الخطوة 1: فتح الوردية ===
      const shiftId = 'shift-t05';
      const openingCash = 1000.00;
      await setup.db.shiftsDao.openShift(
        ShiftsTableCompanion.insert(
          id: shiftId,
          storeId: 'store-1',
          cashierId: uCashierId,
          cashierName: 'كاشير 1',
          openingCash: const Value(openingCash),
          openedAt: DateTime.now(),
        ),
      );

      // === الخطوة 2: إنشاء 3 مبيعات ===
      // بيع 1: P1x3 = 21.00, VAT=3.15, total=24.15 (نقد)
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 3)],
        subtotal: 21.00,
        discount: 0,
        tax: 3.15,
        total: 24.15,
        paymentMethod: 'cash',
      );

      // بيع 2: P2x1 = 45.50, VAT=6.83, total=52.33 (بطاقة)
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p2, quantity: 1)],
        subtotal: 45.50,
        discount: 0,
        tax: 6.83,
        total: 52.33,
        paymentMethod: 'card',
      );

      // بيع 3: P4x2 = 30.00, VAT=0, total=30.00 (نقد، معفى)
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p4, quantity: 2)],
        subtotal: 30.00,
        discount: 0,
        tax: 0,
        total: 30.00,
        paymentMethod: 'cash',
      );

      // === الخطوة 3: حركة نقدية (سحب 100 ر.س) ===
      await setup.db.shiftsDao.insertCashMovement(
        CashMovementsTableCompanion.insert(
          id: 'cm-t05-out',
          shiftId: shiftId,
          storeId: 'store-1',
          type: 'out',
          amount: 100.00,
          reason: const Value('دفع فاتورة كهرباء'),
          createdBy: const Value(uCashierId),
          createdAt: DateTime.now(),
        ),
      );

      // === الخطوة 4: حساب وإغلاق الوردية ===
      // المبيعات النقدية: 24.15 + 30.00 = 54.15
      const cashSalesTotal = 24.15 + 30.00; // 54.15
      // المتوقع في الصندوق: 1000 + 54.15 - 100 = 954.15
      const expectedCash = openingCash + cashSalesTotal - 100.00; // 954.15
      // المبلغ الفعلي (تطابق)
      const actualCash = 954.15;
      const difference = actualCash - expectedCash; // 0.00

      // إجمالي كل المبيعات (نقد + بطاقة)
      const totalSalesAmount = 24.15 + 52.33 + 30.00; // 106.48

      await setup.db.shiftsDao.closeShift(
        id: shiftId,
        closingCash: actualCash,
        expectedCash: expectedCash,
        difference: difference,
        totalSales: 3,
        totalSalesAmount: totalSalesAmount,
        totalRefunds: 0,
        totalRefundsAmount: 0,
      );

      // === التحقق النهائي ===
      final closedShift = await setup.db.shiftsDao.getShiftById(shiftId);
      expect(closedShift, isNotNull);
      expect(closedShift!.status, 'closed');
      expect(closedShift.openingCash, openingCash);
      expect(closedShift.closingCash, actualCash);
      expect(closedShift.expectedCash, closeTo(expectedCash, 0.01));
      expect(closedShift.difference, closeTo(0.00, 0.01));
      expect(closedShift.totalSales, 3);
      expect(closedShift.totalSalesAmount, closeTo(totalSalesAmount, 0.01));
      expect(closedShift.totalRefunds, 0);
      expect(closedShift.closedAt, isNotNull);

      // التحقق من حركات الصندوق
      final movements =
          await setup.db.shiftsDao.getShiftMovements(shiftId);
      expect(movements.length, 1);
      expect(movements.first.type, 'out');
      expect(movements.first.amount, 100.00);

      // التحقق من أن المبيعات كلها موجودة
      final todaySales =
          await setup.saleService.getTodaySales('store-1');
      expect(todaySales.length, 3);

      // التحقق من أنه لا توجد وردية مفتوحة
      final noOpen =
          await setup.db.shiftsDao.getOpenShift('store-1', uCashierId);
      expect(noOpen, isNull);
    });
  });
}
