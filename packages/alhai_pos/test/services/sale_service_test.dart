import 'package:drift/drift.dart' hide isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_pos/src/services/sale_service.dart';
import 'package:alhai_pos/src/core/errors/app_exceptions.dart';

import '../helpers/pos_test_helpers.dart';

// Override MockAppDatabase to handle the generic transaction method
class TestMockAppDatabase extends MockAppDatabase {
  @override
  Future<T> transaction<T>(Future<T> Function() action,
      {bool requireNew = false}) async {
    return await action();
  }
}

void main() {
  late SaleService saleService;
  late TestMockAppDatabase mockDb;
  late MockSyncService mockSyncService;
  late MockSalesDao mockSalesDao;
  late MockSaleItemsDao mockSaleItemsDao;
  late MockProductsDao mockProductsDao;
  late MockInventoryDao mockInventoryDao;

  setUpAll(() {
    registerPosFallbackValues();
    registerFallbackValue(FakeSalesTableCompanion());
    registerFallbackValue(FakeSaleItemsTableCompanion());
  });

  setUp(() {
    mockSalesDao = MockSalesDao();
    mockSaleItemsDao = MockSaleItemsDao();
    mockProductsDao = MockProductsDao();
    mockInventoryDao = MockInventoryDao();
    mockSyncService = MockSyncService();

    mockDb = TestMockAppDatabase();

    // Wire up DAO mocks
    when(() => mockDb.salesDao).thenReturn(mockSalesDao);
    when(() => mockDb.saleItemsDao).thenReturn(mockSaleItemsDao);
    when(() => mockDb.productsDao).thenReturn(mockProductsDao);
    when(() => mockDb.inventoryDao).thenReturn(mockInventoryDao);

    saleService = SaleService(
      db: mockDb,
      syncService: mockSyncService,
    );
  });

  // Helper to set up common mocks for createSale
  void setupCreateSaleMocks({
    required ProductsTableData product,
    int todayStoreCount = 0,
  }) {
    when(() => mockSalesDao.getTodayStoreCount(any()))
        .thenAnswer((_) async => todayStoreCount);
    when(() => mockSalesDao.insertSale(any()))
        .thenAnswer((_) async => 1);
    when(() => mockProductsDao.getProductById(product.id))
        .thenAnswer((_) async => product);
    when(() => mockSaleItemsDao.insertItem(any()))
        .thenAnswer((_) async => 1);
    when(() => mockInventoryDao.recordSaleMovement(
          id: any(named: 'id'),
          productId: any(named: 'productId'),
          storeId: any(named: 'storeId'),
          qty: any(named: 'qty'),
          previousQty: any(named: 'previousQty'),
          saleId: any(named: 'saleId'),
        )).thenAnswer((_) async => 1);
    when(() => mockProductsDao.updateStock(any(), any()))
        .thenAnswer((_) async => 1);
    when(() => mockSyncService.enqueueCreate(
          tableName: any(named: 'tableName'),
          recordId: any(named: 'recordId'),
          data: any(named: 'data'),
          priority: any(named: 'priority'),
        )).thenAnswer((_) async => 'sync-1');
  }

  group('SaleService', () {
    group('createSale', () {
      test('should create sale and return sale ID', () async {
        // Arrange
        final product = createTestProductsTableData(
          id: 'prod-1',
          name: 'Test Product',
          price: 10.0,
          stockQty: 100,
          trackInventory: true,
        );

        final cartItem = createTestCartItem(
          productId: 'prod-1',
          productName: 'Test Product',
          price: 10.0,
          quantity: 2,
        );

        setupCreateSaleMocks(product: product);

        // Act
        final saleId = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [cartItem],
          subtotal: 20.0,
          discount: 0.0,
          tax: 3.0,
          total: 23.0,
          paymentMethod: 'cash',
        );

        // Assert
        expect(saleId, isNotEmpty);
        verify(() => mockSalesDao.insertSale(any())).called(1);
        verify(() => mockSaleItemsDao.insertItem(any())).called(1);
        verify(() => mockProductsDao.updateStock('prod-1', 98)).called(1);
      });

      test('should throw SaleException when product not found', () async {
        // Arrange
        final cartItem = createTestCartItem(
          productId: 'missing-prod',
          productName: 'Missing Product',
          price: 10.0,
          quantity: 1,
        );

        when(() => mockSalesDao.getTodayStoreCount(any()))
            .thenAnswer((_) async => 0);
        when(() => mockSalesDao.insertSale(any()))
            .thenAnswer((_) async => 1);
        when(() => mockProductsDao.getProductById('missing-prod'))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => saleService.createSale(
            storeId: 'store-1',
            cashierId: 'cashier-1',
            items: [cartItem],
            subtotal: 10.0,
            discount: 0.0,
            tax: 1.5,
            total: 11.5,
            paymentMethod: 'cash',
          ),
          throwsA(isA<SaleException>()),
        );
      });

      test('should throw SaleException on insufficient stock', () async {
        // Arrange
        final product = createTestProductsTableData(
          id: 'prod-1',
          stockQty: 2,
          trackInventory: true,
        );

        final cartItem = createTestCartItem(
          productId: 'prod-1',
          price: 10.0,
          quantity: 5, // requesting more than available
        );

        when(() => mockSalesDao.getTodayStoreCount(any()))
            .thenAnswer((_) async => 0);
        when(() => mockSalesDao.insertSale(any()))
            .thenAnswer((_) async => 1);
        when(() => mockProductsDao.getProductById('prod-1'))
            .thenAnswer((_) async => product);

        // Act & Assert
        expect(
          () => saleService.createSale(
            storeId: 'store-1',
            cashierId: 'cashier-1',
            items: [cartItem],
            subtotal: 50.0,
            discount: 0.0,
            tax: 7.5,
            total: 57.5,
            paymentMethod: 'cash',
          ),
          throwsA(isA<SaleException>()),
        );
      });

      test('should skip inventory check for non-tracked products', () async {
        // Arrange
        final product = createTestProductsTableData(
          id: 'prod-1',
          name: 'Service',
          stockQty: 0,
          trackInventory: false, // not tracked
        );

        final cartItem = createTestCartItem(
          productId: 'prod-1',
          productName: 'Service',
          price: 50.0,
          quantity: 1,
        );

        setupCreateSaleMocks(product: product);

        // Act - should not throw despite stockQty = 0
        final saleId = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [cartItem],
          subtotal: 50.0,
          discount: 0.0,
          tax: 7.5,
          total: 57.5,
          paymentMethod: 'cash',
        );

        // Assert
        expect(saleId, isNotEmpty);
      });

      test('should enqueue sync operation after creating sale', () async {
        // Arrange
        final product = createTestProductsTableData(
          id: 'prod-1',
          stockQty: 50,
          trackInventory: true,
        );

        final cartItem = createTestCartItem(
          productId: 'prod-1',
          price: 10.0,
          quantity: 1,
        );

        setupCreateSaleMocks(product: product);

        // Act
        await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [cartItem],
          subtotal: 10.0,
          discount: 0.0,
          tax: 1.5,
          total: 11.5,
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
    });

    group('voidSale', () {
      test('should void a completed sale and restore stock', () async {
        // Arrange
        final sale = createTestSalesTableData(
          id: 'sale-1',
          storeId: 'store-1',
          status: 'completed',
        );

        final saleItem = createTestSaleItemsTableData(
          saleId: 'sale-1',
          productId: 'prod-1',
          qty: 2,
        );

        final product = createTestProductsTableData(
          id: 'prod-1',
          stockQty: 98, // after the sale
        );

        when(() => mockSalesDao.getSaleById('sale-1'))
            .thenAnswer((_) async => sale);
        when(() => mockSaleItemsDao.getItemsBySaleId('sale-1'))
            .thenAnswer((_) async => [saleItem]);
        when(() => mockSalesDao.voidSale('sale-1'))
            .thenAnswer((_) async => 1);
        when(() => mockProductsDao.getProductById('prod-1'))
            .thenAnswer((_) async => product);
        when(() => mockInventoryDao.recordAdjustment(
              id: any(named: 'id'),
              productId: any(named: 'productId'),
              storeId: any(named: 'storeId'),
              previousQty: any(named: 'previousQty'),
              newQty: any(named: 'newQty'),
              reason: any(named: 'reason'),
            )).thenAnswer((_) async => 1);
        when(() => mockSyncService.enqueueUpdate(
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              changes: any(named: 'changes'),
              priority: any(named: 'priority'),
            )).thenAnswer((_) async => 'sync-1');

        // Act
        await saleService.voidSale('sale-1', reason: 'Customer request');

        // Assert - voidSale restores stock internally, no separate updateStock
        verify(() => mockSalesDao.voidSale('sale-1')).called(1);
        verify(() => mockInventoryDao.recordAdjustment(
              id: any(named: 'id'),
              productId: 'prod-1',
              storeId: any(named: 'storeId'),
              previousQty: 98.0,
              newQty: 100.0,
              reason: 'Customer request',
            )).called(1);
        verifyNever(() => mockProductsDao.updateStock(any(), any()));
      });

      test('should throw SaleException when sale not found', () async {
        // Arrange
        when(() => mockSalesDao.getSaleById('non-existent'))
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => saleService.voidSale('non-existent'),
          throwsA(isA<SaleException>()),
        );
      });

      test('should throw SaleException when sale already voided', () async {
        // Arrange
        final voidedSale = createTestSalesTableData(
          id: 'sale-1',
          status: 'voided',
        );

        when(() => mockSalesDao.getSaleById('sale-1'))
            .thenAnswer((_) async => voidedSale);

        // Act & Assert
        expect(
          () => saleService.voidSale('sale-1'),
          throwsA(isA<SaleException>()),
        );
      });
    });

    group('getTodaySales', () {
      test('should return list of today sales', () async {
        // Arrange
        final sales = [
          createTestSalesTableData(id: 'sale-1'),
          createTestSalesTableData(id: 'sale-2'),
        ];

        when(() => mockSalesDao.getSalesByDate(any(), any()))
            .thenAnswer((_) async => sales);

        // Act
        final result = await saleService.getTodaySales('store-1');

        // Assert
        expect(result.length, equals(2));
      });
    });

    group('getTodayTotal', () {
      test('should return total for today', () async {
        // Arrange
        when(() => mockSalesDao.getTodayTotal(any(), any()))
            .thenAnswer((_) async => 1500.0);

        // Act
        final result =
            await saleService.getTodayTotal('store-1', 'cashier-1');

        // Assert
        expect(result, equals(1500.0));
      });
    });

    group('getTodayCount', () {
      test('should return count for today', () async {
        // Arrange
        when(() => mockSalesDao.getTodayCount(any(), any()))
            .thenAnswer((_) async => 25);

        // Act
        final result =
            await saleService.getTodayCount('store-1', 'cashier-1');

        // Assert
        expect(result, equals(25));
      });
    });

    group('receipt number generation', () {
      test('should generate receipt number with correct format', () async {
        // Arrange
        final product = createTestProductsTableData(
          id: 'prod-1',
          stockQty: 100,
          trackInventory: true,
        );

        final cartItem = createTestCartItem(
          productId: 'prod-1',
          price: 10.0,
          quantity: 1,
        );

        when(() => mockSalesDao.getTodayStoreCount(any()))
            .thenAnswer((_) async => 5); // 5 previous sales today
        when(() => mockProductsDao.getProductById('prod-1'))
            .thenAnswer((_) async => product);
        when(() => mockSaleItemsDao.insertItem(any()))
            .thenAnswer((_) async => 1);
        when(() => mockInventoryDao.recordSaleMovement(
              id: any(named: 'id'),
              productId: any(named: 'productId'),
              storeId: any(named: 'storeId'),
              qty: any(named: 'qty'),
              previousQty: any(named: 'previousQty'),
              saleId: any(named: 'saleId'),
            )).thenAnswer((_) async => 1);
        when(() => mockProductsDao.updateStock(any(), any()))
            .thenAnswer((_) async => 1);
        when(() => mockSyncService.enqueueCreate(
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              data: any(named: 'data'),
              priority: any(named: 'priority'),
            )).thenAnswer((_) async => 'sync-1');

        // Capture the SalesTableCompanion passed to insertSale
        SalesTableCompanion? capturedCompanion;
        when(() => mockSalesDao.insertSale(any())).thenAnswer((invocation) {
          capturedCompanion = invocation.positionalArguments[0]
              as SalesTableCompanion;
          return Future.value(1);
        });

        // Act
        await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [cartItem],
          subtotal: 10.0,
          discount: 0.0,
          tax: 1.5,
          total: 11.5,
          paymentMethod: 'cash',
        );

        // Assert - receipt number should be POS-YYYYMMDD-0006
        expect(capturedCompanion, isNotNull);
        final receiptNo = capturedCompanion!.receiptNo.value;
        expect(receiptNo, startsWith('POS-'));
        expect(receiptNo, endsWith('-0006')); // 5 + 1 = 6
      });
    });
  });
}
