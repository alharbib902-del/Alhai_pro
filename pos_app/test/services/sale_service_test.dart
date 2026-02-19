/// اختبارات خدمة المبيعات
///
/// اختبارات تكامل تستخدم قاعدة بيانات SQLite في الذاكرة
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/alhai_core.dart';
import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/providers/cart_providers.dart';
import 'package:pos_app/services/sale_service.dart';
import 'package:pos_app/services/sync/sync_service.dart';

// ============================================================================
// MOCKS
// ============================================================================

class MockSyncService extends Mock implements SyncService {}

// ============================================================================
// TEST DATA
// ============================================================================

Product _createTestProduct({
  String? id,
  String? name,
  double? price,
  int? stockQty,
}) {
  return Product(
    id: id ?? 'product-1',
    storeId: 'store-1',
    name: name ?? 'منتج اختبار',
    price: price ?? 25.0,
    stockQty: stockQty ?? 100,
    isActive: true,
    createdAt: DateTime.now(),
  );
}

Future<void> _insertProductToDb(AppDatabase db, Product product) async {
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
// TESTS
// ============================================================================

void main() {
  late AppDatabase db;
  late MockSyncService mockSyncService;
  late SaleService saleService;

  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockSyncService = MockSyncService();
    saleService = SaleService(db: db, syncService: mockSyncService);

    // Setup sync service defaults
    when(() => mockSyncService.enqueueCreate(
          tableName: any(named: 'tableName'),
          recordId: any(named: 'recordId'),
          data: any(named: 'data'),
          priority: any(named: 'priority'),
        )).thenAnswer((_) async => 'sync-id');

    when(() => mockSyncService.enqueueUpdate(
          tableName: any(named: 'tableName'),
          recordId: any(named: 'recordId'),
          changes: any(named: 'changes'),
          priority: any(named: 'priority'),
        )).thenAnswer((_) async => 'sync-id');
  });

  tearDown(() async {
    await db.close();
  });

  group('SaleService', () {
    group('createSale', () {
      test('ينشئ بيع جديد بنجاح', () async {
        // Arrange
        final product = _createTestProduct();
        await _insertProductToDb(db, product);
        final cartItems = [PosCartItem(product: product, quantity: 2)];

        // Act
        final saleId = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 50.0,
          discount: 0,
          tax: 7.5,
          total: 57.5,
          paymentMethod: 'cash',
        );

        // Assert
        expect(saleId, isNotEmpty);
        final sale = await db.salesDao.getSaleById(saleId);
        expect(sale, isNotNull);
        expect(sale!.total, 57.5);
        expect(sale.status, 'completed');
      });

      test('يخصم المخزون بشكل صحيح', () async {
        // Arrange
        final product = _createTestProduct(stockQty: 50);
        await _insertProductToDb(db, product);
        final cartItems = [PosCartItem(product: product, quantity: 5)];

        // Act
        await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 125.0,
          discount: 0,
          tax: 18.75,
          total: 143.75,
          paymentMethod: 'cash',
        );

        // Assert
        final updatedProduct = await db.productsDao.getProductById('product-1');
        expect(updatedProduct!.stockQty, 45); // 50 - 5
      });

      test('يخصم المخزون بشكل صحيح لعناصر متعددة', () async {
        // Arrange
        final product1 = _createTestProduct(id: 'p1', stockQty: 50);
        final product2 = _createTestProduct(id: 'p2', stockQty: 30);
        await _insertProductToDb(db, product1);
        await _insertProductToDb(db, product2);

        final cartItems = [
          PosCartItem(product: product1, quantity: 5),
          PosCartItem(product: product2, quantity: 3),
        ];

        // Act
        await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 200.0,
          discount: 0,
          tax: 30.0,
          total: 230.0,
          paymentMethod: 'cash',
        );

        // Assert
        final updatedProduct1 = await db.productsDao.getProductById('p1');
        final updatedProduct2 = await db.productsDao.getProductById('p2');
        expect(updatedProduct1!.stockQty, 45); // 50 - 5
        expect(updatedProduct2!.stockQty, 27); // 30 - 3
      });

      test('يحفظ عناصر البيع', () async {
        // Arrange
        final product = _createTestProduct();
        await _insertProductToDb(db, product);
        final cartItems = [PosCartItem(product: product, quantity: 3)];

        // Act
        final saleId = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 75.0,
          discount: 0,
          tax: 11.25,
          total: 86.25,
          paymentMethod: 'cash',
        );

        // Assert
        final items = await db.saleItemsDao.getItemsBySaleId(saleId);
        expect(items.length, 1);
        expect(items.first.qty, 3);
        expect(items.first.productId, 'product-1');
      });

      test('يستخدم السعر المخصص إذا تم تحديده', () async {
        // Arrange
        final product = _createTestProduct(price: 50.0);
        await _insertProductToDb(db, product);
        final cartItems = [
          PosCartItem(product: product, quantity: 2, customPrice: 40.0)
        ];

        // Act
        final saleId = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 80.0,
          discount: 0,
          tax: 12.0,
          total: 92.0,
          paymentMethod: 'cash',
        );

        // Assert
        final items = await db.saleItemsDao.getItemsBySaleId(saleId);
        expect(items.first.unitPrice, 40.0);
      });

      test('يُضيف البيع لطابور المزامنة', () async {
        // Arrange
        final product = _createTestProduct();
        await _insertProductToDb(db, product);
        final cartItems = [PosCartItem(product: product, quantity: 1)];

        // Act
        await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 25.0,
          discount: 0,
          tax: 3.75,
          total: 28.75,
          paymentMethod: 'cash',
        );

        // Assert
        verify(() => mockSyncService.enqueueCreate(
              tableName: 'sales',
              recordId: any(named: 'recordId'),
              data: any(named: 'data'),
              priority: SyncPriority.high,
            )).called(1);
      });

      test('يتضمن بيانات العميل إذا تم تحديدها', () async {
        // Arrange
        final product = _createTestProduct();
        await _insertProductToDb(db, product);
        final cartItems = [PosCartItem(product: product, quantity: 1)];

        // Act
        final saleId = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 25.0,
          discount: 0,
          tax: 3.75,
          total: 28.75,
          paymentMethod: 'cash',
          customerId: 'customer-1',
          customerName: 'أحمد محمد',
        );

        // Assert
        final sale = await db.salesDao.getSaleById(saleId);
        expect(sale!.customerId, 'customer-1');
        expect(sale.customerName, 'أحمد محمد');
      });

      test('يُنشئ رقم إيصال صحيح', () async {
        // Arrange
        final product = _createTestProduct();
        await _insertProductToDb(db, product);
        final cartItems = [PosCartItem(product: product, quantity: 1)];

        // Act
        final saleId = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 25.0,
          discount: 0,
          tax: 3.75,
          total: 28.75,
          paymentMethod: 'cash',
        );

        // Assert
        final sale = await db.salesDao.getSaleById(saleId);
        expect(sale!.receiptNo, startsWith('POS-'));
      });
    });

    group('voidSale', () {
      test('يُلغي البيع ويُرجع المخزون', () async {
        // Arrange
        final product = _createTestProduct(stockQty: 100);
        await _insertProductToDb(db, product);
        final cartItems = [PosCartItem(product: product, quantity: 10)];

        final saleId = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 250.0,
          discount: 0,
          tax: 37.5,
          total: 287.5,
          paymentMethod: 'cash',
        );

        // Verify stock was reduced
        var updatedProduct = await db.productsDao.getProductById('product-1');
        expect(updatedProduct!.stockQty, 90);

        // Act
        await saleService.voidSale(saleId, reason: 'خطأ في الطلب');

        // Assert
        final sale = await db.salesDao.getSaleById(saleId);
        expect(sale!.status, 'voided');

        updatedProduct = await db.productsDao.getProductById('product-1');
        expect(updatedProduct!.stockQty, 100); // Restored
      });

      test('يرمي خطأ إذا لم يُوجد البيع', () async {
        // Act & Assert
        expect(
          () => saleService.voidSale('non-existent'),
          throwsA(isA<Exception>()),
        );
      });

      test('يُضيف الإلغاء لطابور المزامنة', () async {
        // Arrange
        final product = _createTestProduct();
        await _insertProductToDb(db, product);
        final cartItems = [PosCartItem(product: product, quantity: 1)];

        final saleId = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: cartItems,
          subtotal: 25.0,
          discount: 0,
          tax: 3.75,
          total: 28.75,
          paymentMethod: 'cash',
        );

        reset(mockSyncService);
        when(() => mockSyncService.enqueueUpdate(
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              changes: any(named: 'changes'),
              priority: any(named: 'priority'),
            )).thenAnswer((_) async => 'sync-id');

        // Act
        await saleService.voidSale(saleId);

        // Assert
        verify(() => mockSyncService.enqueueUpdate(
              tableName: 'sales',
              recordId: saleId,
              changes: any(named: 'changes'),
              priority: SyncPriority.high,
            )).called(1);
      });
    });

    group('getTodaySales', () {
      test('يُرجع مبيعات اليوم للمتجر', () async {
        // Arrange
        final product = _createTestProduct();
        await _insertProductToDb(db, product);

        // Create 3 sales
        for (var i = 0; i < 3; i++) {
          await saleService.createSale(
            storeId: 'store-1',
            cashierId: 'cashier-1',
            items: [PosCartItem(product: product, quantity: 1)],
            subtotal: 25.0,
            discount: 0,
            tax: 3.75,
            total: 28.75,
            paymentMethod: 'cash',
          );
        }

        // Act
        final result = await saleService.getTodaySales('store-1');

        // Assert
        expect(result.length, 3);
      });
    });

    group('getTodayTotal', () {
      test('يُرجع إجمالي مبيعات اليوم', () async {
        // Arrange
        final product = _createTestProduct(stockQty: 1000);
        await _insertProductToDb(db, product);

        // Create sales with different totals
        await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [PosCartItem(product: product, quantity: 4)], // 100
          subtotal: 100.0,
          discount: 0,
          tax: 15.0,
          total: 115.0,
          paymentMethod: 'cash',
        );
        await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [PosCartItem(product: product, quantity: 2)], // 50
          subtotal: 50.0,
          discount: 0,
          tax: 7.5,
          total: 57.5,
          paymentMethod: 'cash',
        );

        // Act
        final result = await saleService.getTodayTotal('store-1', 'cashier-1');

        // Assert
        expect(result, 172.5); // 115 + 57.5
      });

      test('يستثني المبيعات الملغاة من الإجمالي', () async {
        // Arrange
        final product = _createTestProduct(stockQty: 1000);
        await _insertProductToDb(db, product);

        final saleId1 = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [PosCartItem(product: product, quantity: 4)],
          subtotal: 100.0,
          discount: 0,
          tax: 15.0,
          total: 115.0,
          paymentMethod: 'cash',
        );
        await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [PosCartItem(product: product, quantity: 2)],
          subtotal: 50.0,
          discount: 0,
          tax: 7.5,
          total: 57.5,
          paymentMethod: 'cash',
        );

        // Void first sale
        await saleService.voidSale(saleId1);

        // Act
        final result = await saleService.getTodayTotal('store-1', 'cashier-1');

        // Assert
        expect(result, 57.5); // Only second sale
      });
    });

    group('getTodayCount', () {
      test('يُرجع عدد مبيعات اليوم', () async {
        // Arrange
        final product = _createTestProduct(stockQty: 1000);
        await _insertProductToDb(db, product);

        // Create 5 sales
        for (var i = 0; i < 5; i++) {
          await saleService.createSale(
            storeId: 'store-1',
            cashierId: 'cashier-1',
            items: [PosCartItem(product: product, quantity: 1)],
            subtotal: 25.0,
            discount: 0,
            tax: 3.75,
            total: 28.75,
            paymentMethod: 'cash',
          );
        }

        // Act
        final result = await saleService.getTodayCount('store-1', 'cashier-1');

        // Assert
        expect(result, 5);
      });
    });
  });
}
