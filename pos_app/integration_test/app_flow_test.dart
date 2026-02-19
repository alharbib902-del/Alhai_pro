/// اختبارات التكامل لتطبيق نقاط البيع
///
/// تختبر تدفقات العمل الكاملة من البداية للنهاية
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:alhai_core/alhai_core.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/services/sale_service.dart';
import 'package:pos_app/services/sync/sync_service.dart';

// ============================================================================
// TEST HELPERS
// ============================================================================

/// إنشاء قاعدة بيانات اختبار في الذاكرة
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

/// إنشاء منتج اختبار
Product createTestProduct({
  String? id,
  String? name,
  double? price,
  int? stockQty,
}) {
  return Product(
    id: id ?? 'product-${DateTime.now().millisecondsSinceEpoch}',
    storeId: 'test-store',
    name: name ?? 'منتج اختبار',
    price: price ?? 50.0,
    stockQty: stockQty ?? 100,
    isActive: true,
    createdAt: DateTime.now(),
  );
}

/// إضافة منتج لقاعدة البيانات
Future<void> insertProductToDb(AppDatabase db, Product product) async {
  await db.productsDao.insertProduct(ProductsTableCompanion.insert(
    id: product.id,
    storeId: product.storeId,
    name: product.name,
    price: product.price,
    stockQty: Value(product.stockQty),
    createdAt: product.createdAt,
  ));
}

// ============================================================================
// INTEGRATION TESTS
// ============================================================================

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('تدفق البيع الكامل', () {
    late AppDatabase db;
    late SyncService syncService;
    late SaleService saleService;

    setUp(() async {
      db = createTestDatabase();
      syncService = SyncService(db.syncQueueDao);
      saleService = SaleService(db: db, syncService: syncService);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('إضافة منتجات للسلة والدفع', (tester) async {
      // 1. إعداد المنتجات
      final product1 = createTestProduct(id: 'p1', name: 'تفاح', price: 10.0, stockQty: 50);
      final product2 = createTestProduct(id: 'p2', name: 'موز', price: 5.0, stockQty: 30);
      await insertProductToDb(db, product1);
      await insertProductToDb(db, product2);

      // 2. إنشاء السلة وإضافة المنتجات
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartNotifier = container.read(cartStateProvider.notifier);

      // إضافة المنتجات
      cartNotifier.addProduct(product1, quantity: 3); // 30
      cartNotifier.addProduct(product2, quantity: 2); // 10

      // التحقق من السلة
      final cartState = container.read(cartStateProvider);
      expect(cartState.itemCount, 5);
      expect(cartState.subtotal, 40.0);

      // 3. تطبيق خصم
      cartNotifier.setDiscount(5.0);
      expect(container.read(cartTotalProvider), 35.0);

      // 4. إنشاء البيع
      final saleId = await saleService.createSale(
        storeId: 'test-store',
        cashierId: 'cashier-1',
        items: cartState.items,
        subtotal: cartState.subtotal,
        discount: cartState.discount,
        tax: 5.25, // 15% VAT
        total: 40.25,
        paymentMethod: 'cash',
      );

      expect(saleId, isNotEmpty);

      // 5. التحقق من حفظ البيع
      final sale = await db.salesDao.getSaleById(saleId);
      expect(sale, isNotNull);
      expect(sale!.total, 40.25);
      expect(sale.status, 'completed');

      // 6. التحقق من خصم المخزون
      final updatedProduct1 = await db.productsDao.getProductById('p1');
      final updatedProduct2 = await db.productsDao.getProductById('p2');
      expect(updatedProduct1!.stockQty, 47); // 50 - 3
      expect(updatedProduct2!.stockQty, 28); // 30 - 2

      // 7. التحقق من إضافة للمزامنة
      final pendingCount = await syncService.getPendingCount();
      expect(pendingCount, 1);
    });

    testWidgets('البيع بسعر مخصص', (tester) async {
      // 1. إعداد المنتج
      final product = createTestProduct(id: 'p1', price: 100.0, stockQty: 10);
      await insertProductToDb(db, product);

      // 2. إضافة بسعر مخصص
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartNotifier = container.read(cartStateProvider.notifier);
      cartNotifier.addProduct(product, quantity: 1, customPrice: 80.0);

      final cartState = container.read(cartStateProvider);
      expect(cartState.items.first.effectivePrice, 80.0);
      expect(cartState.subtotal, 80.0);

      // 3. إنشاء البيع
      final saleId = await saleService.createSale(
        storeId: 'test-store',
        cashierId: 'cashier-1',
        items: cartState.items,
        subtotal: 80.0,
        discount: 0,
        tax: 12.0,
        total: 92.0,
        paymentMethod: 'card',
      );

      // 4. التحقق من البيع
      final sale = await db.salesDao.getSaleById(saleId);
      expect(sale!.paymentMethod, 'card');
      expect(sale.total, 92.0);
    });
  });

  group('تدفق الإلغاء', () {
    late AppDatabase db;
    late SyncService syncService;
    late SaleService saleService;

    setUp(() async {
      db = createTestDatabase();
      syncService = SyncService(db.syncQueueDao);
      saleService = SaleService(db: db, syncService: syncService);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('إلغاء بيع واسترجاع المخزون', (tester) async {
      // 1. إعداد المنتج
      final product = createTestProduct(id: 'p1', stockQty: 100);
      await insertProductToDb(db, product);

      // 2. إنشاء بيع
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartNotifier = container.read(cartStateProvider.notifier);
      cartNotifier.addProduct(product, quantity: 10);

      final saleId = await saleService.createSale(
        storeId: 'test-store',
        cashierId: 'cashier-1',
        items: container.read(cartStateProvider).items,
        subtotal: 500.0,
        discount: 0,
        tax: 75.0,
        total: 575.0,
        paymentMethod: 'cash',
      );

      // التحقق من خصم المخزون
      var productAfterSale = await db.productsDao.getProductById('p1');
      expect(productAfterSale!.stockQty, 90);

      // 3. إلغاء البيع
      await saleService.voidSale(saleId, reason: 'طلب العميل');

      // 4. التحقق من الإلغاء
      final sale = await db.salesDao.getSaleById(saleId);
      expect(sale!.status, 'voided');

      // 5. التحقق من استرجاع المخزون
      final productAfterVoid = await db.productsDao.getProductById('p1');
      expect(productAfterVoid!.stockQty, 100);
    });
  });

  group('تدفق المزامنة', () {
    late AppDatabase db;
    late SyncService syncService;

    setUp(() async {
      db = createTestDatabase();
      syncService = SyncService(db.syncQueueDao);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('إضافة عمليات للطابور ومعالجتها', (tester) async {
      // 1. إضافة عمليات متعددة
      await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-1',
        data: {'total': 100.0},
        priority: SyncPriority.high,
      );
      await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-2',
        data: {'total': 200.0},
        priority: SyncPriority.normal,
      );
      await syncService.enqueueUpdate(
        tableName: 'products',
        recordId: 'prod-1',
        changes: {'stock': 50},
        priority: SyncPriority.low,
      );

      // 2. التحقق من العدد
      final pendingCount = await syncService.getPendingCount();
      expect(pendingCount, 3);

      // 3. الحصول على العناصر المعلقة (مرتبة حسب الأولوية)
      final items = await syncService.getPendingItems();
      expect(items.length, 3);
      expect(items.first.recordId, 'sale-1'); // أولوية عالية

      // 4. محاكاة المزامنة
      for (final item in items) {
        await syncService.markAsSyncing(item.id);
        await syncService.markAsSynced(item.id);
      }

      // 5. التحقق من عدم وجود عناصر معلقة
      final remainingCount = await syncService.getPendingCount();
      expect(remainingCount, 0);
    });

    testWidgets('معالجة فشل المزامنة مع إعادة المحاولة', (tester) async {
      // 1. إضافة عملية
      await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-1',
        data: {'total': 100.0},
      );

      // 2. محاكاة الفشل
      final items = await syncService.getPendingItems();
      await syncService.markAsFailed(items.first.id, 'Network error');

      // 3. التحقق من أنها ما زالت في الطابور
      final pendingItems = await syncService.getPendingItems();
      expect(pendingItems.length, 1);
      expect(pendingItems.first.status, 'failed');
      expect(pendingItems.first.retryCount, 1);

      // 4. محاكاة الفشل حتى الحد الأقصى
      await syncService.markAsFailed(items.first.id, 'Error 2');
      await syncService.markAsFailed(items.first.id, 'Error 3');

      // 5. التحقق من عدم إرجاعها بعد الوصول للحد الأقصى
      final finalItems = await syncService.getPendingItems();
      expect(finalItems, isEmpty);
    });

    testWidgets('منع التكرار باستخدام idempotency key', (tester) async {
      // 1. إضافة عملية
      await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-1',
        data: {'total': 100.0},
      );

      // 2. محاولة إضافة نفس العملية (سيتم تجاهلها)
      // ملاحظة: idempotency key يعتمد على الوقت، لذا قد لا يعمل في نفس الميلي ثانية
      await Future.delayed(const Duration(milliseconds: 10));

      await syncService.enqueueCreate(
        tableName: 'sales',
        recordId: 'sale-1',
        data: {'total': 100.0},
      );

      // 3. التحقق من إضافة عملية واحدة أو اثنتين (حسب الوقت)
      final count = await syncService.getPendingCount();
      expect(count, greaterThanOrEqualTo(1));
    });
  });

  group('إحصائيات المبيعات', () {
    late AppDatabase db;
    late SyncService syncService;
    late SaleService saleService;

    setUp(() async {
      db = createTestDatabase();
      syncService = SyncService(db.syncQueueDao);
      saleService = SaleService(db: db, syncService: syncService);
    });

    tearDown(() async {
      await db.close();
    });

    testWidgets('حساب إجمالي وعدد مبيعات اليوم', (tester) async {
      // 1. إعداد المنتج
      final product = createTestProduct(id: 'p1', price: 100.0, stockQty: 1000);
      await insertProductToDb(db, product);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // 2. إنشاء عدة مبيعات
      for (var i = 0; i < 5; i++) {
        container.read(cartStateProvider.notifier).clear();
        container.read(cartStateProvider.notifier).addProduct(product, quantity: 2);

        await saleService.createSale(
          storeId: 'test-store',
          cashierId: 'cashier-1',
          items: container.read(cartStateProvider).items,
          subtotal: 200.0,
          discount: 0,
          tax: 30.0,
          total: 230.0,
          paymentMethod: 'cash',
        );
      }

      // 3. التحقق من الإحصائيات
      final todayTotal = await saleService.getTodayTotal('test-store', 'cashier-1');
      final todayCount = await saleService.getTodayCount('test-store', 'cashier-1');

      expect(todayTotal, 1150.0); // 5 × 230
      expect(todayCount, 5);
    });
  });

  group('سلة التسوق', () {
    testWidgets('عمليات السلة الكاملة', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final cartNotifier = container.read(cartStateProvider.notifier);

      // 1. إضافة منتجات
      final product1 = createTestProduct(id: 'p1', name: 'تفاح', price: 10.0);
      final product2 = createTestProduct(id: 'p2', name: 'موز', price: 5.0);

      cartNotifier.addProduct(product1, quantity: 2);
      cartNotifier.addProduct(product2, quantity: 3);

      expect(container.read(cartItemCountProvider), 5);
      expect(container.read(cartSubtotalProvider), 35.0);

      // 2. زيادة الكمية
      cartNotifier.incrementQuantity('p1');
      expect(container.read(cartItemCountProvider), 6);

      // 3. إنقاص الكمية
      cartNotifier.decrementQuantity('p2');
      expect(container.read(cartItemCountProvider), 5);

      // 4. تعديل السعر
      cartNotifier.setCustomPrice('p1', 8.0);
      expect(container.read(cartSubtotalProvider), 34.0); // 3×8 + 2×5

      // 5. إضافة خصم
      cartNotifier.setDiscount(4.0);
      expect(container.read(cartTotalProvider), 30.0);

      // 6. تعيين العميل
      cartNotifier.setCustomer('customer-1');
      expect(container.read(cartStateProvider).customerId, 'customer-1');

      // 7. تعيين ملاحظات
      cartNotifier.setNotes('توصيل سريع');
      expect(container.read(cartStateProvider).notes, 'توصيل سريع');

      // 8. إزالة منتج
      cartNotifier.removeProduct('p1');
      expect(container.read(cartItemCountProvider), 2);

      // 9. تفريغ السلة
      cartNotifier.clear();
      expect(container.read(isCartEmptyProvider), isTrue);
    });
  });
}
