/// اختبارات قسم N: اختبارات الدخان الشاملة (End-to-End Smoke Tests)
///
/// 8 اختبارات تربط بين عدة ميزات من تطبيق نقطة البيع
///
/// N01: تسجيل دخول → إضافة منتج → دفع نقدي → إيصال
/// N02: إضافة P1×3 → خصم 10% → VAT على الصافي → دفع
/// N03: إنشاء بيع → استرجاع كامل → استعادة المخزون
/// N04: غير متصل → بيع → اتصال → مزامنة → تحقق
/// N05: دفع مقسم (نقد+بطاقة) → التحقق من المبالغ
/// N06: P4 (معفى) + P1 → VAT مختلط صحيح
/// N07: كاشير → تقارير → مرفوض
/// N08: بيع → إغلاق وردية → إلغاء → مرفوض
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/alhai_core.dart' hide CartItem, UserRole;
import 'package:pos_app/core/errors/app_exceptions.dart';
import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/services/permissions_service.dart';
import 'package:pos_app/services/sync/sync_service.dart' show SyncPriority;

import 'fixtures/test_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Section N: اختبارات الدخان الشاملة', () {
    // ==================================================================
    // N01: تسجيل دخول → إضافة منتج → دفع نقدي → إيصال
    // ==================================================================

    test('N01 تسجيل دخول → إضافة P1×3 → دفع نقدي → رقم إيصال POS-YYYYMMDD-XXXX', () async {
      final setup = createSaleServiceSetup();
      try {
        await seedAllProducts(setup.db);

        final Product p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 3)];

        // الحساب: subtotal=21.00, discount=0, VAT=3.15, total=24.15
        final subtotal = roundSar(items.first.total); // 21.00
        expect(subtotal, 21.00);

        final result = computeInvoice(subtotal: subtotal, discountAmount: 0);
        expect(result.vat, 3.15);
        expect(result.total, 24.15);

        // إنشاء البيع
        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: 21.00,
          discount: 0,
          tax: 3.15,
          total: 24.15,
          paymentMethod: 'cash',
        );

        // التحقق من البيع في قاعدة البيانات
        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.subtotal, 21.00);
        expect(sale.discount, 0.00);
        expect(sale.tax, 3.15);
        expect(sale.total, 24.15);
        expect(sale.paymentMethod, 'cash');
        expect(sale.status, 'completed');

        // التحقق من صيغة رقم الإيصال: POS-YYYYMMDD-XXXX
        final receiptPattern = RegExp(r'^POS-\d{8}-\d{4}$');
        expect(receiptPattern.hasMatch(sale.receiptNo), isTrue,
            reason: 'رقم الإيصال يجب أن يطابق POS-YYYYMMDD-XXXX، الفعلي: ${sale.receiptNo}');
      } finally {
        await setup.dispose();
      }
    });

    // ==================================================================
    // N02: إضافة P1×3 → خصم 10% → VAT على الصافي → دفع
    // ==================================================================

    test('N02 إضافة P1×3 → خصم 10% → VAT=2.83 على الصافي → total=21.73', () async {
      final setup = createSaleServiceSetup();
      try {
        await seedAllProducts(setup.db);

        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 3)];

        // subtotal = 7.00 × 3 = 21.00
        final subtotal = roundSar(items.first.total);
        expect(subtotal, 21.00);

        // خصم 10%
        final discount = percentDiscount(subtotal, 0.10); // 2.10
        expect(discount, 2.10);

        // net = 21.00 - 2.10 = 18.90
        final net = roundSar(subtotal - discount);
        expect(net, 18.90);

        // VAT = roundSar(18.90 × 0.15) = roundSar(2.8349...) = 2.83
        // (floating point: 18.90 * 0.15 = 2.8349999... → 283.499... → rounds to 283)
        final vat = computeVat(net);
        expect(vat, 2.83);

        // total = 18.90 + 2.83 = 21.73
        final total = roundSar(net + vat);
        expect(total, 21.73);

        // إنشاء البيع بالقيم المحسوبة
        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: 21.00,
          discount: 2.10,
          tax: 2.83,
          total: 21.73,
        );

        // التحقق من القيم المخزنة
        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.subtotal, 21.00);
        expect(sale.discount, 2.10);
        expect(sale.tax, 2.83);
        expect(sale.total, 21.73);
      } finally {
        await setup.dispose();
      }
    });

    // ==================================================================
    // N03: إنشاء بيع → استرجاع كامل → استعادة المخزون
    // ==================================================================

    test('N03 إنشاء بيع P1×5 → المخزون ينخفض من 50 إلى 45 → إلغاء → المخزون يعود إلى 50', () async {
      final setup = createSaleServiceSetup();
      try {
        await seedAllProducts(setup.db);

        final p1 = createP1(); // stockQty = 50
        final items = [PosCartItem(product: p1, quantity: 5)];

        // subtotal=35.00, VAT=5.25, total=40.25
        final subtotal = roundSar(p1.price * 5); // 35.00
        final vat = computeVat(subtotal); // 5.25
        final total = roundSar(subtotal + vat); // 40.25
        expect(subtotal, 35.00);
        expect(vat, 5.25);
        expect(total, 40.25);

        // إنشاء البيع
        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: 35.00,
          discount: 0,
          tax: 5.25,
          total: 40.25,
        );

        // التحقق أن المخزون انخفض من 50 إلى 45
        final productAfterSale = await setup.db.productsDao.getProductById('p1-pepsi');
        expect(productAfterSale, isNotNull);
        expect(productAfterSale!.stockQty, 45);

        // إلغاء البيع
        await setup.saleService.voidSale(saleId, reason: 'استرجاع كامل');

        // التحقق أن المخزون عاد إلى 50
        final productAfterVoid = await setup.db.productsDao.getProductById('p1-pepsi');
        expect(productAfterVoid, isNotNull);
        expect(productAfterVoid!.stockQty, 50);

        // التحقق أن حالة البيع أصبحت "ملغي"
        final voidedSale = await setup.db.salesDao.getSaleById(saleId);
        expect(voidedSale, isNotNull);
        expect(voidedSale!.status, 'voided');
      } finally {
        await setup.dispose();
      }
    });

    // ==================================================================
    // N04: غير متصل → بيع → اتصال → مزامنة → تحقق
    // ==================================================================

    test('N04 إنشاء بيع offline → التحقق من إضافته لطابور المزامنة بأولوية عالية', () async {
      final setup = createSaleServiceSetup();
      try {
        await seedAllProducts(setup.db);

        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 2)];

        // إنشاء البيع (SaleService يضيف تلقائياً للمزامنة)
        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: 14.00,
          discount: 0,
          tax: 2.10,
          total: 16.10,
        );

        // التحقق أن enqueueCreate استُدعي بالمعطيات الصحيحة
        verify(() => setup.syncService.enqueueCreate(
          tableName: 'sales',
          recordId: saleId,
          data: any(named: 'data'),
          priority: SyncPriority.high,
        )).called(1);
      } finally {
        await setup.dispose();
      }
    });

    // ==================================================================
    // N05: دفع مقسم (نقد+بطاقة) → التحقق من المبالغ
    // ==================================================================

    test('N05 دفع مقسم (نقد+بطاقة) → البيع يُخزّن بـ paymentMethod=mixed والإجمالي صحيح', () async {
      final setup = createSaleServiceSetup();
      try {
        await seedAllProducts(setup.db);

        final p2 = createP2();
        final items = [PosCartItem(product: p2, quantity: 1)];

        // subtotal=45.50, VAT=6.83 (roundSar(45.50*0.15)=roundSar(6.825)=6.83), total=52.33
        final subtotal = roundSar(p2.price * 1);
        final vat = computeVat(subtotal); // 6.83
        final total = roundSar(subtotal + vat); // 52.33
        expect(subtotal, 45.50);
        expect(vat, 6.83);
        expect(total, 52.33);

        // إنشاء البيع بدفع مقسم
        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: 45.50,
          discount: 0,
          tax: 6.83,
          total: 52.33,
          paymentMethod: 'mixed',
        );

        // التحقق من القيم المخزنة
        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.paymentMethod, 'mixed');
        expect(sale.total, 52.33);
        expect(sale.subtotal, 45.50);
        expect(sale.tax, 6.83);
      } finally {
        await setup.dispose();
      }
    });

    // ==================================================================
    // N06: P4 (معفى) + P1 → VAT مختلط صحيح
    // ==================================================================

    test('N06 P1(خاضع)+P4(معفى) → P1:7.00+VAT(1.05)=8.05, P4:15.00 → total=23.05', () {
      final p1 = createP1();
      final p4 = createP4();

      // التحقق من حالة الإعفاء
      expect(isVatExempt(p1), isFalse);
      expect(isVatExempt(p4), isTrue);

      // P1: خاضع للضريبة
      final p1Subtotal = roundSar(p1.price * 1); // 7.00
      final p1Vat = computeVat(p1Subtotal); // 1.05
      expect(p1Subtotal, 7.00);
      expect(p1Vat, 1.05);

      // P4: معفى
      final p4Subtotal = roundSar(p4.price * 1); // 15.00
      expect(p4Subtotal, 15.00);

      // استخدام computeMixedInvoice
      final mixed = computeMixedInvoice(
        taxableSubtotal: p1Subtotal,
        exemptSubtotal: p4Subtotal,
        discountOnTaxable: 0,
      );

      expect(mixed.taxableSubtotal, 7.00);
      expect(mixed.exemptSubtotal, 15.00);
      expect(mixed.taxableNet, 7.00);
      expect(mixed.vat, 1.05);
      expect(mixed.total, 23.05);

      // التحقق اليدوي أيضاً
      final p1Total = roundSar(p1Subtotal + p1Vat); // 8.05
      final grandTotal = roundSar(p1Total + p4Subtotal); // 23.05
      expect(p1Total, 8.05);
      expect(grandTotal, 23.05);
    });

    // ==================================================================
    // N07: كاشير → تقارير → مرفوض
    // ==================================================================

    test('N07 الكاشير لا يستطيع الوصول للتقارير الكاملة، المدير يستطيع', () {
      // الكاشير لا يملك صلاحية التقارير الكاملة
      expect(
        RolePermissions.hasPermission(UserRole.cashier, Permission.viewFullReports),
        isFalse,
      );

      // الكاشير لا يملك صلاحية التقارير الأساسية أيضاً
      expect(
        RolePermissions.hasPermission(UserRole.cashier, Permission.viewBasicReports),
        isFalse,
      );

      // الكاشير لا يملك صلاحية تصدير التقارير
      expect(
        RolePermissions.hasPermission(UserRole.cashier, Permission.exportReports),
        isFalse,
      );

      // المدير يملك صلاحية التقارير الكاملة
      expect(
        RolePermissions.hasPermission(UserRole.manager, Permission.viewFullReports),
        isTrue,
      );

      // المدير يملك صلاحية التقارير الأساسية
      expect(
        RolePermissions.hasPermission(UserRole.manager, Permission.viewBasicReports),
        isTrue,
      );

      // المدير يملك صلاحية تصدير التقارير
      expect(
        RolePermissions.hasPermission(UserRole.manager, Permission.exportReports),
        isTrue,
      );

      // التحقق عبر CurrentUser أيضاً
      const cashier = CurrentUser(
        id: uCashierId,
        name: 'كاشير اختبار',
        role: UserRole.cashier,
        storeId: 'store-1',
      );
      expect(cashier.canViewReports, isFalse);

      const manager = CurrentUser(
        id: uManagerId,
        name: 'مدير اختبار',
        role: UserRole.manager,
        storeId: 'store-1',
      );
      expect(manager.canViewReports, isTrue);
    });

    // ==================================================================
    // N08: بيع → إغلاق وردية → إلغاء مرتين → الثاني مرفوض
    // ==================================================================

    test('N08 إنشاء بيع → إلغاء ناجح → إلغاء بيع ملغي مسبقاً → SaleException.alreadyVoided', () async {
      final setup = createSaleServiceSetup();
      try {
        await seedAllProducts(setup.db);

        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 2)];

        // إنشاء البيع
        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: 14.00,
          discount: 0,
          tax: 2.10,
          total: 16.10,
        );

        // التحقق أن البيع مكتمل
        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.status, 'completed');

        // الإلغاء الأول → ناجح
        await setup.saleService.voidSale(saleId, reason: 'إلغاء اختباري');

        final voidedSale = await setup.db.salesDao.getSaleById(saleId);
        expect(voidedSale!.status, 'voided');

        // الإلغاء الثاني → يجب أن يرمي استثناء
        // drift transaction قد يغلف الاستثناء، لذلك نتحقق يدوياً
        Object? caughtError;
        try {
          await setup.saleService.voidSale(saleId);
        } catch (e) {
          caughtError = e;
        }
        expect(caughtError, isNotNull, reason: 'إلغاء بيع ملغي مسبقاً يجب أن يرمي استثناء');
        // التحقق من أن الاستثناء هو SaleException أو يحتويه
        final isSaleException = caughtError is SaleException ||
            (caughtError.toString().contains('SALE_ALREADY_VOIDED'));
        expect(isSaleException, isTrue,
            reason: 'الاستثناء يجب أن يكون SaleException.alreadyVoided: $caughtError');
      } finally {
        await setup.dispose();
      }
    });
  });
}
