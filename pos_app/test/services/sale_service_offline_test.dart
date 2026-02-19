/// اختبارات خدمة المبيعات - سيناريوهات عدم الاتصال
///
/// اختبارات تكامل لسيناريوهات البيع أثناء عدم الاتصال
/// تستخدم SaleServiceTestSetup من test_fixtures.dart
///
/// 8 اختبارات تغطي:
/// - البيع ينشئ إدخال في طابور المزامنة
/// - البيع يولد UUID محلي
/// - البيع يحفظ في قاعدة البيانات المحلية بنجاح
/// - طابور المزامنة يتلقى بيانات البيع الصحيحة
/// - البيع يخصم المخزون محلياً
/// - عدة مبيعات offline تنشئ عدة إدخالات مزامنة
/// - بيع مع عميل يحفظ بيانات العميل
/// - رقم الإيصال يتولد بشكل صحيح
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/services/sync/sync_service.dart';

import '../comprehensive/fixtures/test_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Sale Service Offline - سيناريوهات عدم الاتصال', () {
    late SaleServiceTestSetup setup;

    setUp(() async {
      setup = createSaleServiceSetup();
      await seedAllProducts(setup.db);
    });

    tearDown(() async {
      await setup.dispose();
    });

    // ========================================================================
    // اختبار: البيع ينشئ إدخال في طابور المزامنة
    // ========================================================================

    test('البيع ينشئ إدخال في طابور المزامنة (enqueueCreate)', () async {
      // Arrange
      final p1 = createP1();

      // Act
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 2)],
        subtotal: 14.0,
        discount: 0,
        tax: 2.10,
        total: 16.10,
      );

      // Assert - التحقق من استدعاء enqueueCreate
      verify(() => setup.syncService.enqueueCreate(
            tableName: 'sales',
            recordId: any(named: 'recordId'),
            data: any(named: 'data'),
            priority: SyncPriority.high,
          )).called(1);
    });

    // ========================================================================
    // اختبار: البيع يولد UUID محلي
    // ========================================================================

    test('البيع يولد UUID محلي كمعرف', () async {
      // Arrange
      final p1 = createP1();

      // Act
      final saleId = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.0,
        discount: 0,
        tax: 1.05,
        total: 8.05,
      );

      // Assert - UUID v4 يكون بطول 36 حرف مع شرطات
      expect(saleId, isNotEmpty);
      expect(saleId.length, equals(36));
      expect(saleId.contains('-'), isTrue);
    });

    // ========================================================================
    // اختبار: البيع يحفظ في قاعدة البيانات المحلية
    // ========================================================================

    test('البيع يحفظ في قاعدة البيانات المحلية بنجاح', () async {
      // Arrange
      final p1 = createP1();

      // Act
      final saleId = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 3)],
        subtotal: 21.0,
        discount: 0,
        tax: 3.15,
        total: 24.15,
        paymentMethod: 'cash',
      );

      // Assert - التحقق من حفظ البيع في DB
      final sale = await setup.db.salesDao.getSaleById(saleId);
      expect(sale, isNotNull);
      expect(sale!.storeId, equals('store-1'));
      expect(sale.total, equals(24.15));
      expect(sale.paymentMethod, equals('cash'));
      expect(sale.status, equals('completed'));
    });

    // ========================================================================
    // اختبار: طابور المزامنة يتلقى بيانات البيع الصحيحة
    // ========================================================================

    test('طابور المزامنة يتلقى tableName=sales و priority=high', () async {
      // Arrange
      final p2 = createP2();

      // Act
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p2, quantity: 1)],
        subtotal: 45.50,
        discount: 0,
        tax: 6.83,
        total: 52.33,
      );

      // Assert
      final captured = verify(() => setup.syncService.enqueueCreate(
            tableName: captureAny(named: 'tableName'),
            recordId: any(named: 'recordId'),
            data: any(named: 'data'),
            priority: captureAny(named: 'priority'),
          )).captured;

      // captured[0] = tableName, captured[1] = priority
      expect(captured[0], equals('sales'));
      expect(captured[1], equals(SyncPriority.high));
    });

    // ========================================================================
    // اختبار: البيع يخصم المخزون محلياً
    // ========================================================================

    test('البيع يخصم المخزون محلياً في قاعدة البيانات', () async {
      // Arrange
      final p1 = createP1(); // مخزون = 50

      // Act
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 5)],
        subtotal: 35.0,
        discount: 0,
        tax: 5.25,
        total: 40.25,
      );

      // Assert - المخزون = 50 - 5 = 45
      final updatedProduct = await setup.db.productsDao.getProductById('p1-pepsi');
      expect(updatedProduct, isNotNull);
      expect(updatedProduct!.stockQty, equals(45));
    });

    // ========================================================================
    // اختبار: عدة مبيعات offline تنشئ عدة إدخالات
    // ========================================================================

    test('عدة مبيعات offline تنشئ عدة إدخالات في طابور المزامنة', () async {
      // Arrange
      final p1 = createP1();
      final p4 = createP4(); // غير متتبع المخزون

      // Act - بيعين
      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.0,
        discount: 0,
        tax: 1.05,
        total: 8.05,
      );

      await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p4, quantity: 1)],
        subtotal: 15.0,
        discount: 0,
        tax: 0,
        total: 15.0,
      );

      // Assert - enqueueCreate يُستدعى مرتين
      verify(() => setup.syncService.enqueueCreate(
            tableName: 'sales',
            recordId: any(named: 'recordId'),
            data: any(named: 'data'),
            priority: SyncPriority.high,
          )).called(2);
    });

    // ========================================================================
    // اختبار: بيع مع عميل
    // ========================================================================

    test('بيع مع عميل يحفظ بيانات العميل في DB', () async {
      // Arrange
      final p1 = createP1();

      // Act
      final saleId = await setup.saleService.createSale(
        storeId: 'store-1',
        cashierId: 'cashier-1',
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.0,
        discount: 0,
        tax: 1.05,
        total: 8.05,
        paymentMethod: 'cash',
        customerId: c1Id,
        customerName: c1Name,
      );

      // Assert
      final sale = await setup.db.salesDao.getSaleById(saleId);
      expect(sale, isNotNull);
      expect(sale!.customerId, equals(c1Id));
      expect(sale.customerName, equals(c1Name));
    });

    // ========================================================================
    // اختبار: رقم الإيصال يتولد بشكل صحيح
    // ========================================================================

    test('رقم الإيصال يبدأ بـ POS- ويحتوي تاريخ اليوم', () async {
      // Arrange
      final p1 = createP1();

      // Act
      final saleId = await createCompletedSale(
        saleService: setup.saleService,
        items: [PosCartItem(product: p1, quantity: 1)],
        subtotal: 7.0,
        discount: 0,
        tax: 1.05,
        total: 8.05,
      );

      // Assert
      final sale = await setup.db.salesDao.getSaleById(saleId);
      expect(sale, isNotNull);
      expect(sale!.receiptNo, startsWith('POS-'));

      // التحقق من أن رقم الإيصال يحتوي تاريخ اليوم
      final today = DateTime.now();
      final expectedDatePart =
          '${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}';
      expect(sale.receiptNo, contains(expectedDatePart));
    });
  });
}
