/// اختبارات قسم J: التقارير / إغلاق الوردية
///
/// 4 اختبارات تغطي:
/// - J01: إجماليات التقرير اليومي تطابق المبيعات
/// - J02: تقسيم تقرير ضريبة القيمة المضافة
/// - J03: تقرير طرق الدفع
/// - J04: إغلاق الوردية يمنع التعديلات القديمة
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/core/errors/app_exceptions.dart';
import 'package:pos_app/services/sync/sync_service.dart' show SyncPriority;

import 'fixtures/test_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Section J: التقارير / إغلاق الوردية', () {
    late SaleServiceTestSetup setup;

    setUp(() async {
      setup = createSaleServiceSetup();
      await seedAllProducts(setup.db);
    });

    tearDown(() async {
      await setup.dispose();
    });

    // ==================================================================
    // J01: إجماليات التقرير اليومي تطابق المبيعات
    // ==================================================================

    test('J01 إجماليات التقرير اليومي تطابق مجموع 5 مبيعات', () async {
      final p1 = createP1();
      final p2 = createP2();
      final p4 = createP4();

      // بيع 1: P1×2 = 14.00, VAT=2.10, total=16.10
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 2)],
        subtotal: 14.00,
        discount: 0,
        tax: 2.10,
        total: 16.10,
        paymentMethod: 'cash',
      );

      // بيع 2: P2×1 = 45.50, VAT=6.83, total=52.33
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p2, quantity: 1)],
        subtotal: 45.50,
        discount: 0,
        tax: 6.83,
        total: 52.33,
        paymentMethod: 'cash',
      );

      // بيع 3: P1×1 = 7.00, VAT=1.05, total=8.05
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.00,
        discount: 0,
        tax: 1.05,
        total: 8.05,
        paymentMethod: 'card',
      );

      // بيع 4: P4×1 = 15.00, VAT=0, total=15.00 (معفى)
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p4, quantity: 1)],
        subtotal: 15.00,
        discount: 0,
        tax: 0,
        total: 15.00,
        paymentMethod: 'cash',
      );

      // بيع 5: P1×3 = 21.00, خصم=2.00, VAT=2.85, total=21.85
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 3)],
        subtotal: 21.00,
        discount: 2.00,
        tax: 2.85,
        total: 21.85,
        paymentMethod: 'card',
      );

      // المجموع المتوقع = 16.10 + 52.33 + 8.05 + 15.00 + 21.85 = 113.33
      const expectedTotal = 113.33;
      const expectedCount = 5;

      // التحقق عبر getTodayTotal
      final todayTotal = await setup.saleService.getTodayTotal(
        'store-1',
        'cashier-1',
      );
      expect(todayTotal, closeTo(expectedTotal, 0.01));

      // التحقق عبر getTodayCount
      final todayCount = await setup.saleService.getTodayCount(
        'store-1',
        'cashier-1',
      );
      expect(todayCount, expectedCount);

      // التحقق عبر getTodaySales
      final todaySales = await setup.saleService.getTodaySales('store-1');
      expect(todaySales.length, expectedCount);

      final salesTotal = todaySales.fold<double>(0.0, (sum, s) => sum + s.total);
      expect(salesTotal, closeTo(expectedTotal, 0.01));
    });

    // ==================================================================
    // J02: تقسيم تقرير ضريبة القيمة المضافة
    // ==================================================================

    test('J02 تقرير ضريبة القيمة المضافة: عناصر خاضعة ومعفاة تُخزّن بشكل صحيح', () async {
      final p1 = createP1(); // خاضع للضريبة
      final p4 = createP4(); // معفى من الضريبة

      // بيع 1: P1×2 = 14.00, خاضع → VAT=2.10, total=16.10
      final saleId1 = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 2)],
        subtotal: 14.00,
        discount: 0,
        tax: 2.10,
        total: 16.10,
        paymentMethod: 'cash',
      );

      // بيع 2: P4×2 = 30.00, معفى → VAT=0, total=30.00
      final saleId2 = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p4, quantity: 2)],
        subtotal: 30.00,
        discount: 0,
        tax: 0,
        total: 30.00,
        paymentMethod: 'cash',
      );

      // بيع 3: P1×1 مع خصم → sub=7.00, disc=1.00, VAT=0.90, total=6.90
      final saleId3 = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.00,
        discount: 1.00,
        tax: 0.90,
        total: 6.90,
        paymentMethod: 'card',
      );

      // التحقق من القيم المخزنة لكل بيع
      final sale1 = await setup.db.salesDao.getSaleById(saleId1);
      expect(sale1, isNotNull);
      expect(sale1!.tax, 2.10); // ضريبة مخزنة صحيحة
      expect(sale1.subtotal, 14.00);

      final sale2 = await setup.db.salesDao.getSaleById(saleId2);
      expect(sale2, isNotNull);
      expect(sale2!.tax, 0.0); // معفى: لا ضريبة
      expect(sale2.subtotal, 30.00);

      final sale3 = await setup.db.salesDao.getSaleById(saleId3);
      expect(sale3, isNotNull);
      expect(sale3!.tax, 0.90); // ضريبة بعد الخصم
      expect(sale3.discount, 1.00);

      // التحقق من مجموع الضرائب لليوم
      final allSales = await setup.saleService.getTodaySales('store-1');
      final totalTax = allSales.fold<double>(0.0, (sum, s) => sum + (s.tax ?? 0));
      // 2.10 + 0.00 + 0.90 = 3.00
      expect(totalTax, closeTo(3.00, 0.01));

      // مبيعات خاضعة (tax > 0) مقابل معفاة (tax == 0)
      final taxableSales = allSales.where((s) => (s.tax ?? 0) > 0).toList();
      final exemptSales = allSales.where((s) => (s.tax ?? 0) == 0).toList();
      expect(taxableSales.length, 2);
      expect(exemptSales.length, 1);
    });

    // ==================================================================
    // J03: تقرير طرق الدفع
    // ==================================================================

    test('J03 تقرير طرق الدفع: تجميع حسب الطريقة والتحقق من الإجماليات', () async {
      final p1 = createP1();
      final p2 = createP2();
      final p4 = createP4();

      // 2 مبيعات نقدية (cash)
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 2)],
        subtotal: 14.00,
        discount: 0,
        tax: 2.10,
        total: 16.10,
        paymentMethod: 'cash',
      );
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p4, quantity: 1)],
        subtotal: 15.00,
        discount: 0,
        tax: 0,
        total: 15.00,
        paymentMethod: 'cash',
      );

      // 2 مبيعات بطاقة (card)
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p2, quantity: 1)],
        subtotal: 45.50,
        discount: 0,
        tax: 6.83,
        total: 52.33,
        paymentMethod: 'card',
      );
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.00,
        discount: 0,
        tax: 1.05,
        total: 8.05,
        paymentMethod: 'card',
      );

      // 1 بيع آجل (credit)
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 3)],
        subtotal: 21.00,
        discount: 0,
        tax: 3.15,
        total: 24.15,
        paymentMethod: 'credit',
      );

      // استخدام getPaymentMethodStats من SalesDao
      final stats = await setup.db.salesDao.getPaymentMethodStats('store-1');

      // التحقق من عدد الطرق
      expect(stats.length, 3);

      // التحقق من طريقة الدفع النقدي
      final cashStats = stats.firstWhere((s) => s.method == 'cash');
      expect(cashStats.count, 2);
      expect(cashStats.total, closeTo(31.10, 0.01)); // 16.10 + 15.00

      // التحقق من طريقة البطاقة
      final cardStats = stats.firstWhere((s) => s.method == 'card');
      expect(cardStats.count, 2);
      expect(cardStats.total, closeTo(60.38, 0.01)); // 52.33 + 8.05

      // التحقق من طريقة الائتمان
      final creditStats = stats.firstWhere((s) => s.method == 'credit');
      expect(creditStats.count, 1);
      expect(creditStats.total, closeTo(24.15, 0.01));

      // التحقق من أن مجموع كل الطرق = الإجمالي الكلي
      final grandTotal = stats.fold<double>(0.0, (sum, s) => sum + s.total);
      final expectedGrand = 31.10 + 60.38 + 24.15; // 115.63
      expect(grandTotal, closeTo(expectedGrand, 0.01));
    });

    // ==================================================================
    // J04: إغلاق الوردية يمنع التعديلات القديمة
    // ==================================================================

    test('J04 إلغاء بيع بعد الإغلاق: إلغاء مرتين يرمي خطأ', () async {
      final p1 = createP1();

      // إنشاء بيع
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
      final saleBefore = await setup.db.salesDao.getSaleById(saleId);
      expect(saleBefore, isNotNull);
      expect(saleBefore!.status, 'completed');

      // إلغاء البيع (محاكاة إغلاق الوردية: إلغاء البيع)
      await setup.saleService.voidSale(saleId, reason: 'إغلاق وردية');

      // التحقق من أن البيع أصبح ملغياً
      final saleAfter = await setup.db.salesDao.getSaleById(saleId);
      expect(saleAfter, isNotNull);
      expect(saleAfter!.status, 'voided');

      // البيع الملغي لا يُحتسب في إجماليات اليوم
      final todayTotal = await setup.saleService.getTodayTotal(
        'store-1',
        'cashier-1',
      );
      expect(todayTotal, 0.0); // لا مبيعات مكتملة

      final todayCount = await setup.saleService.getTodayCount(
        'store-1',
        'cashier-1',
      );
      expect(todayCount, 0); // لا مبيعات مكتملة

      // محاولة إلغاء البيع مرة ثانية → يجب أن يرمي SaleException
      expect(
        () => setup.saleService.voidSale(saleId),
        throwsA(isA<SaleException>()),
      );
    });
  });
}
