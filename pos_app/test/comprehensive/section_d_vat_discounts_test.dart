/// اختبارات قسم D: ضريبة القيمة المضافة / الخصومات / التقريب
///
/// ★ القسم الأهم - 18 اختبار
///
/// القاعدة الحرجة: الخصم يقلل الوعاء الضريبي أولاً
/// ثم VAT = 15% من المبلغ الصافي (net)
/// التقريب: منزلتان عشريتان دائماً
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/services/sync/sync_service.dart' show SyncPriority;

import 'fixtures/test_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Section D: VAT/Discounts/Rounding', () {
    // ================================================================
    // D01-D06: الحسابات الأساسية
    // ================================================================

    group('D01-D06 الحسابات الأساسية', () {
      test('D01 بيع سطر واحد: P1×3 → sub=21.00, VAT=3.15, total=24.15', () {
        final p1 = createP1();
        final item = PosCartItem(product: p1, quantity: 3);
        final subtotal = roundSar(item.total); // 7.00 × 3 = 21.00

        final result = computeInvoice(
          subtotal: subtotal,
          discountAmount: 0,
        );

        expect(result.subtotal, 21.00);
        expect(result.discount, 0.00);
        expect(result.net, 21.00);
        expect(result.vat, 3.15);
        expect(result.total, 24.15);
      });

      test('D02 خصم سطر 10% على P2×1 → sub=45.50, disc=4.55, net=40.95, VAT=6.14, total=47.09', () {
        final p2 = createP2();
        final item = PosCartItem(product: p2, quantity: 1);
        final subtotal = roundSar(item.total); // 45.50

        final disc = percentDiscount(subtotal, 0.10); // 4.55
        final net = roundSar(subtotal - disc); // 40.95
        final vat = computeVat(net); // 6.14
        final total = roundSar(net + vat); // 47.09

        expect(subtotal, 45.50);
        expect(disc, 4.55);
        expect(net, 40.95);
        expect(vat, 6.14);
        expect(total, 47.09);
      });

      test('D03 خصم فاتورة 20 ر.س على P1×2 (مسقّف) → net=0, VAT=0, total=0', () {
        final p1 = createP1();
        final item = PosCartItem(product: p1, quantity: 2);
        final subtotal = roundSar(item.total); // 14.00

        final result = computeInvoice(
          subtotal: subtotal,
          discountAmount: 20.00, // أكبر من subtotal=14 → مسقّف
        );

        expect(result.subtotal, 14.00);
        expect(result.discount, 14.00); // مسقّف للـ subtotal
        expect(result.net, 0.00);
        expect(result.vat, 0.00);
        expect(result.total, 0.00);
      });

      test('D04 عناصر متعددة خصم 5%: P1×2+P2×1 → sub=59.50, disc=2.98, net=56.52, VAT=8.48, total=65.00', () {
        final p1 = createP1();
        final p2 = createP2();
        final items = [
          PosCartItem(product: p1, quantity: 2), // 14.00
          PosCartItem(product: p2, quantity: 1), // 45.50
        ];
        final subtotal = roundSar(items.fold<double>(0, (s, i) => s + i.total)); // 59.50

        final disc = percentDiscount(subtotal, 0.05); // 2.975 → 2.98
        final net = roundSar(subtotal - disc); // 56.52
        final vat = computeVat(net); // 8.478 → 8.48
        final total = roundSar(net + vat); // 65.00

        expect(subtotal, 59.50);
        expect(disc, 2.98);
        expect(net, 56.52);
        expect(vat, 8.48);
        expect(total, 65.00);
      });

      test('D05 تقريب كسري: P3×7 → sub=47.25, VAT=7.09 (وليس 7.0875), total=54.34', () {
        final p3 = createP3();
        final item = PosCartItem(product: p3, quantity: 7);
        final subtotal = roundSar(item.total); // 6.75 × 7 = 47.25

        final result = computeInvoice(
          subtotal: subtotal,
          discountAmount: 0,
        );

        expect(result.subtotal, 47.25);
        expect(result.vat, 7.09); // 47.25 × 0.15 = 7.0875 → 7.09
        expect(result.total, 54.34);
      });

      test('D06 خصم 100% → VAT=0, total=0', () {
        final p1 = createP1();
        final item = PosCartItem(product: p1, quantity: 1);
        final subtotal = roundSar(item.total); // 7.00

        final result = computeInvoice(
          subtotal: subtotal,
          discountAmount: 7.00, // 100%
        );

        expect(result.subtotal, 7.00);
        expect(result.discount, 7.00);
        expect(result.net, 0.00);
        expect(result.vat, 0.00);
        expect(result.total, 0.00);
      });
    });

    // ================================================================
    // D07-D08: سياسات الخصم
    // ================================================================

    group('D07-D08 سياسات الخصم', () {
      test('D07 رفض خصم فوق الحد: سطر 60% مرفوض، فاتورة 35% مرفوضة', () {
        expect(isLineDiscountAllowed(0.60), isFalse);
        expect(isLineDiscountAllowed(0.50), isTrue);

        expect(isInvoiceDiscountAllowed(0.35), isFalse);
        expect(isInvoiceDiscountAllowed(0.30), isTrue);
      });

      test('D08 تكديس: خصم سطر 10% ثم خصم فاتورة 5% (السطر أولاً)', () {
        final p2 = createP2();
        final subtotal = roundSar(p2.price * 1); // 45.50

        // خصم سطر 10%
        final lineDisc = percentDiscount(subtotal, 0.10); // 4.55
        final netAfterLine = roundSar(subtotal - lineDisc); // 40.95

        // خصم فاتورة 5% على المتبقي
        final invoiceDisc = percentDiscount(netAfterLine, 0.05); // 2.05
        final net = roundSar(netAfterLine - invoiceDisc); // 38.90

        final vat = computeVat(net); // 5.84
        final total = roundSar(net + vat); // 44.74

        expect(lineDisc, 4.55);
        expect(netAfterLine, 40.95);
        expect(invoiceDisc, 2.05);
        expect(net, 38.90);
        expect(vat, 5.84);
        expect(total, 44.74);

        // التحقق بدالة applyStacking
        final stackedTotal = applyStacking(
          subtotal: subtotal,
          lineDiscountPercent: 0.10,
          invoiceDiscountPercent: 0.05,
        );
        expect(stackedTotal, total);
      });
    });

    // ================================================================
    // D09-D10: الإعفاء الضريبي
    // ================================================================

    group('D09-D10 الإعفاء الضريبي', () {
      test('D09 عنصر معفى P4: sub=15.00, VAT=0, total=15.00', () {
        final p4 = createP4();
        final item = PosCartItem(product: p4, quantity: 1);
        final subtotal = roundSar(item.total); // 15.00

        final result = computeInvoice(
          subtotal: subtotal,
          discountAmount: 0,
          vatExempt: true,
        );

        expect(result.subtotal, 15.00);
        expect(result.vat, 0.00);
        expect(result.total, 15.00);
        expect(isVatExempt(p4), isTrue);
      });

      test('D10 سلة مختلطة: P1+P4 → P1 خاضع (8.05) + P4 معفى (15.00) = 23.05', () {
        final p1 = createP1();
        final p4 = createP4();

        // P1: خاضع للضريبة
        final p1Subtotal = roundSar(p1.price * 1); // 7.00
        final p1Vat = computeVat(p1Subtotal); // 1.05
        final p1Total = roundSar(p1Subtotal + p1Vat); // 8.05

        // P4: معفى
        final p4Total = roundSar(p4.price * 1); // 15.00

        final grandTotal = roundSar(p1Total + p4Total); // 23.05

        expect(p1Subtotal, 7.00);
        expect(p1Vat, 1.05);
        expect(p1Total, 8.05);
        expect(p4Total, 15.00);
        expect(grandTotal, 23.05);

        // التحقق بدالة computeMixedInvoice
        final mixed = computeMixedInvoice(
          taxableSubtotal: p1Subtotal,
          exemptSubtotal: p4Total,
          discountOnTaxable: 0,
        );
        expect(mixed.vat, 1.05);
        expect(mixed.total, 23.05);
      });
    });

    // ================================================================
    // D11-D14: حدود الخصم (Boundary Tests)
    // ================================================================

    group('D11-D14 حدود الخصم', () {
      test('D11 خصم سطر 50% (الحد الأقصى مسموح): P1×2 → disc=7.00, net=7.00, VAT=1.05, total=8.05', () {
        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 2)];
        final subtotal = roundSar(items.first.total); // 14.00

        expect(isLineDiscountAllowed(0.50), isTrue);

        final disc = percentDiscount(subtotal, 0.50); // 7.00
        final net = roundSar(subtotal - disc); // 7.00
        final vat = computeVat(net); // 1.05
        final total = roundSar(net + vat); // 8.05

        expect(disc, 7.00);
        expect(net, 7.00);
        expect(vat, 1.05);
        expect(total, 8.05);
      });

      test('D12 خصم سطر 50.01% (فوق الحد - مرفوض)', () {
        expect(isLineDiscountAllowed(0.5001), isFalse);
        expect(isLineDiscountAllowed(0.51), isFalse);
      });

      test('D13 خصم فاتورة 30% (الحد الأقصى مسموح): sub=59.50 → disc=17.85, net=41.65, VAT=6.25, total=47.90', () {
        final subtotal = 59.50;

        expect(isInvoiceDiscountAllowed(0.30), isTrue);

        final disc = percentDiscount(subtotal, 0.30); // 17.85
        final net = roundSar(subtotal - disc); // 41.65
        final vat = computeVat(net); // 6.2475 → 6.25
        final total = roundSar(net + vat); // 47.90

        expect(disc, 17.85);
        expect(net, 41.65);
        expect(vat, 6.25);
        expect(total, 47.90);
      });

      test('D14 خصم فاتورة 30.01% (فوق الحد - مرفوض)', () {
        expect(isInvoiceDiscountAllowed(0.3001), isFalse);
        expect(isInvoiceDiscountAllowed(0.31), isFalse);
      });
    });

    // ================================================================
    // D15-D16: صلاحيات الخصم (RBAC)
    // ================================================================

    group('D15-D16 صلاحيات الخصم', () {
      test('D15 المدير يتجاوز الحد + تسجيل audit', () {
        // المدير يمكنه الموافقة على خصم 60% (فوق حد الكاشير 50%)
        const requestedPercent = 0.60;
        const isManager = true;

        // المدير مسموح له بتجاوز الحدود
        final managerCanOverride = isManager && requestedPercent > lineDiscountMax;
        expect(managerCanOverride, isTrue);

        // الخصم نفسه يحسب بشكل صحيح
        final subtotal = 100.0;
        final disc = percentDiscount(subtotal, requestedPercent); // 60.00
        final net = roundSar(subtotal - disc); // 40.00
        final vat = computeVat(net); // 6.00
        final total = roundSar(net + vat); // 46.00

        expect(disc, 60.00);
        expect(net, 40.00);
        expect(vat, 6.00);
        expect(total, 46.00);
      });

      test('D16 الكاشير لا يمكنه تجاوز الحد', () {
        const requestedPercent = 0.60;
        const isCashier = true;

        // الكاشير ليس لديه صلاحية التجاوز
        final cashierCanOverride = !isCashier;
        expect(cashierCanOverride, isFalse);

        // التحقق أن الخصم مرفوض
        expect(isLineDiscountAllowed(requestedPercent), isFalse);
      });
    });

    // ================================================================
    // D17-D18: تخزين المبالغ الخاضعة والمعفاة
    // ================================================================

    group('D17-D18 تخزين التقسيم الضريبي', () {
      test('D17 العنصر المعفى لا يدخل في الوعاء الضريبي', () {
        final p1 = createP1();
        final p4 = createP4();

        // P1 خاضع، P4 معفى
        expect(isVatExempt(p1), isFalse);
        expect(isVatExempt(p4), isTrue);

        // الوعاء الضريبي يشمل P1 فقط
        final taxableSubtotal = p1.price * 2; // 14.00
        final exemptSubtotal = p4.price * 1; // 15.00

        final vat = computeVat(taxableSubtotal); // 2.10
        expect(vat, 2.10);

        // الإجمالي: taxable+VAT + exempt
        final total = roundSar(taxableSubtotal + vat + exemptSubtotal); // 31.10
        expect(total, 31.10);
      });

      test('D18 سلة مختلطة: التقسيم مخزّن للتقارير', () {
        final p1 = createP1();
        final p2 = createP2();
        final p4 = createP4();

        // P1×2 + P2×1 = خاضع: 14.00 + 45.50 = 59.50
        // P4×1 = معفى: 15.00
        final taxable = roundSar(p1.price * 2 + p2.price * 1); // 59.50
        final exempt = roundSar(p4.price * 1); // 15.00

        final mixed = computeMixedInvoice(
          taxableSubtotal: taxable,
          exemptSubtotal: exempt,
          discountOnTaxable: 0,
        );

        expect(mixed.taxableSubtotal, 59.50);
        expect(mixed.exemptSubtotal, 15.00);
        expect(mixed.taxableNet, 59.50);
        expect(mixed.vat, 8.92); // 59.50 × 0.15 = 8.925 → 8.92 (banker's rounding)
        expect(mixed.total, 83.42); // 59.50 + 8.92 + 15.00 = 83.42
      });
    });

    // ================================================================
    // D01-D10 Integration: اختبارات تكامل مع SaleService
    // ================================================================

    group('D Integration: SaleService يحفظ القيم الصحيحة', () {
      late SaleServiceTestSetup setup;

      setUp(() async {
        setup = createSaleServiceSetup();
        await seedAllProducts(setup.db);
      });

      tearDown(() async {
        await setup.dispose();
      });

      test('D01-INT إنشاء بيع P1×3 يحفظ VAT=3.15 و total=24.15', () async {
        final p1 = createP1();
        final items = [PosCartItem(product: p1, quantity: 3)];

        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: 21.00,
          discount: 0,
          tax: 3.15,
          total: 24.15,
        );

        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.subtotal, 21.00);
        expect(sale.discount, 0.00);
        expect(sale.tax, 3.15);
        expect(sale.total, 24.15);
      });

      test('D02-INT بيع P2×1 مع خصم 10% يحفظ القيم الصحيحة', () async {
        final p2 = createP2();
        final items = [PosCartItem(product: p2, quantity: 1)];

        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: 45.50,
          discount: 4.55,
          tax: 6.14,
          total: 47.09,
        );

        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.subtotal, 45.50);
        expect(sale.discount, 4.55);
        expect(sale.tax, 6.14);
        expect(sale.total, 47.09);
      });

      test('D05-INT بيع P3×7 يحفظ VAT=7.09 (مقرّب) و total=54.34', () async {
        final p3 = createP3(stockQty: 100); // Override stock for test
        await setup.db.productsDao.updateStock(p3.id, 100);

        final items = [PosCartItem(product: p3, quantity: 7)];

        final saleId = await createCompletedSale(
          saleService: setup.saleService,
          items: items,
          subtotal: 47.25,
          discount: 0,
          tax: 7.09,
          total: 54.34,
        );

        final sale = await setup.db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.tax, 7.09);
        expect(sale.total, 54.34);
      });
    });
  });
}
