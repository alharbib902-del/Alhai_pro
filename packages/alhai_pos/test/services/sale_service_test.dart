import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_pos/src/services/sale_service.dart';
import 'package:alhai_pos/src/services/terminal_suffix_service.dart';
import 'package:alhai_pos/src/core/errors/app_exceptions.dart';

import '../helpers/pos_test_helpers.dart';

/// Test double for [TerminalSuffixService] that returns a fixed suffix.
/// Used by the cross-device collision regression test (C-1).
class _FixedTerminalSuffix extends TerminalSuffixService {
  final String _fixed;
  _FixedTerminalSuffix(this._fixed);
  @override
  Future<String> getSuffix() async => _fixed;
}

// Override MockAppDatabase to handle the generic transaction method
class TestMockAppDatabase extends MockAppDatabase {
  @override
  Future<T> transaction<T>(
    Future<T> Function() action, {
    bool requireNew = false,
  }) async {
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
  late MockAccountsDao mockAccountsDao;
  late MockTransactionsDao mockTransactionsDao;
  late MockStockDeltasDao mockStockDeltasDao;
  late MockUsersDao mockUsersDao;
  late MockCustomersDao mockCustomersDao;
  late MockStoresDao mockStoresDao;

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
    mockAccountsDao = MockAccountsDao();
    mockTransactionsDao = MockTransactionsDao();
    mockStockDeltasDao = MockStockDeltasDao();
    mockUsersDao = MockUsersDao();
    mockCustomersDao = MockCustomersDao();
    mockStoresDao = MockStoresDao();
    mockSyncService = MockSyncService();

    mockDb = TestMockAppDatabase();

    // Wire up DAO mocks
    when(() => mockDb.salesDao).thenReturn(mockSalesDao);
    when(() => mockDb.saleItemsDao).thenReturn(mockSaleItemsDao);
    when(() => mockDb.productsDao).thenReturn(mockProductsDao);
    when(() => mockDb.inventoryDao).thenReturn(mockInventoryDao);
    when(() => mockDb.accountsDao).thenReturn(mockAccountsDao);
    when(() => mockDb.transactionsDao).thenReturn(mockTransactionsDao);
    when(() => mockDb.stockDeltasDao).thenReturn(mockStockDeltasDao);
    when(() => mockDb.usersDao).thenReturn(mockUsersDao);
    when(() => mockDb.customersDao).thenReturn(mockCustomersDao);
    when(() => mockDb.storesDao).thenReturn(mockStoresDao);

    saleService = SaleService(db: mockDb, syncService: mockSyncService);
  });

  // Helper to set up common mocks for createSale
  void setupCreateSaleMocks({
    required ProductsTableData product,
    int todayStoreCount = 0,
  }) {
    when(
      () => mockSalesDao.getTodayStoreCount(any()),
    ).thenAnswer((_) async => todayStoreCount);
    when(() => mockSalesDao.insertSale(any())).thenAnswer((_) async => 1);
    when(
      () => mockProductsDao.getProductById(product.id),
    ).thenAnswer((_) async => product);
    when(() => mockSaleItemsDao.insertItem(any())).thenAnswer((_) async => 1);
    when(
      () => mockInventoryDao.recordSaleMovement(
        id: any(named: 'id'),
        productId: any(named: 'productId'),
        storeId: any(named: 'storeId'),
        qty: any(named: 'qty'),
        previousQty: any(named: 'previousQty'),
        saleId: any(named: 'saleId'),
      ),
    ).thenAnswer((_) async => 1);
    when(
      () => mockProductsDao.updateStock(any(), any()),
    ).thenAnswer((_) async => 1);
    when(
      () => mockSyncService.enqueueCreate(
        tableName: any(named: 'tableName'),
        recordId: any(named: 'recordId'),
        data: any(named: 'data'),
        priority: any(named: 'priority'),
      ),
    ).thenAnswer((_) async => 'sync-1');
    // Additional DAOs used by createSale
    when(() => mockUsersDao.getUserById(any())).thenAnswer((_) async => null);
    when(() => mockUsersDao.ensureUser(any())).thenAnswer((_) async => 1);
    when(
      () => mockCustomersDao.getCustomerById(any()),
    ).thenAnswer((_) async => null);
    when(() => mockStoresDao.getStoreById(any())).thenAnswer((_) async => null);
    when(
      () => mockStockDeltasDao.addDelta(
        id: any(named: 'id'),
        productId: any(named: 'productId'),
        storeId: any(named: 'storeId'),
        orgId: any(named: 'orgId'),
        quantityChange: any(named: 'quantityChange'),
        deviceId: any(named: 'deviceId'),
        operationType: any(named: 'operationType'),
        referenceId: any(named: 'referenceId'),
      ),
    ).thenAnswer((_) async => 1);
  }

  group('SaleService', () {
    group('createSale', () {
      test('should create sale and return sale ID', () async {
        // Arrange
        final product = createTestProductsTableData(
          id: 'prod-1',
          name: 'Test Product',
          price: 1000,
          stockQty: 100,
          trackInventory: true,
        );

        final cartItem = createTestCartItem(
          productId: 'prod-1',
          productName: 'Test Product',
          price: 1000,
          quantity: 2,
        );

        setupCreateSaleMocks(product: product);

        // Act
        final result = await saleService.createSale(
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
        expect(result.saleId, isNotEmpty);
        verify(() => mockSalesDao.insertSale(any())).called(1);
        verify(() => mockSaleItemsDao.insertItem(any())).called(1);
        verify(() => mockProductsDao.updateStock('prod-1', 98)).called(1);
      });

      test('should throw SaleException when product not found', () async {
        // Arrange
        final cartItem = createTestCartItem(
          productId: 'missing-prod',
          productName: 'Missing Product',
          price: 1000,
          quantity: 1,
        );

        when(
          () => mockSalesDao.getTodayStoreCount(any()),
        ).thenAnswer((_) async => 0);
        when(() => mockSalesDao.insertSale(any())).thenAnswer((_) async => 1);
        when(
          () => mockProductsDao.getProductById('missing-prod'),
        ).thenAnswer((_) async => null);
        when(
          () => mockUsersDao.getUserById(any()),
        ).thenAnswer((_) async => null);
        when(() => mockUsersDao.ensureUser(any())).thenAnswer((_) async => 1);
        when(
          () => mockCustomersDao.getCustomerById(any()),
        ).thenAnswer((_) async => null);

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
          price: 1000,
          quantity: 5, // requesting more than available
        );

        when(
          () => mockSalesDao.getTodayStoreCount(any()),
        ).thenAnswer((_) async => 0);
        when(() => mockSalesDao.insertSale(any())).thenAnswer((_) async => 1);
        when(
          () => mockProductsDao.getProductById('prod-1'),
        ).thenAnswer((_) async => product);
        when(
          () => mockUsersDao.getUserById(any()),
        ).thenAnswer((_) async => null);
        when(() => mockUsersDao.ensureUser(any())).thenAnswer((_) async => 1);
        when(
          () => mockCustomersDao.getCustomerById(any()),
        ).thenAnswer((_) async => null);

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
          price: 5000,
          quantity: 1,
        );

        setupCreateSaleMocks(product: product);

        // Act - should not throw despite stockQty = 0
        final result = await saleService.createSale(
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
        expect(result.saleId, isNotEmpty);
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
          price: 1000,
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
        verify(
          () => mockSyncService.enqueueCreate(
            tableName: 'sales',
            recordId: any(named: 'recordId'),
            data: any(named: 'data'),
            priority: SyncPriority.high,
          ),
        ).called(1);
      });

      // Session 50 sync-enqueue audit — Bug-B-shape regression:
      // inventory_movements is a pushTable and recordSaleMovement writes one
      // row per sale item, but pre-fix the rows never hit sync_queue →
      // server-side inventory reports showed 0 POS activity. Lock the new
      // post-tx enqueue in place.
      test(
        'enqueues inventory_movements once per sale item (2 items)',
        () async {
          // Arrange
          final productA = createTestProductsTableData(
            id: 'prod-A',
            stockQty: 50,
            trackInventory: true,
          );
          final productB = createTestProductsTableData(
            id: 'prod-B',
            stockQty: 30,
            trackInventory: true,
          );

          final itemA = createTestCartItem(
            productId: 'prod-A',
            price: 1000,
            quantity: 1,
          );
          final itemB = createTestCartItem(
            productId: 'prod-B',
            price: 2000,
            quantity: 3,
          );

          setupCreateSaleMocks(product: productA);
          // Override to teach the mock how to return both products individually.
          when(
            () => mockProductsDao.getProductById('prod-A'),
          ).thenAnswer((_) async => productA);
          when(
            () => mockProductsDao.getProductById('prod-B'),
          ).thenAnswer((_) async => productB);

          // Act
          await saleService.createSale(
            storeId: 'store-1',
            cashierId: 'cashier-1',
            items: [itemA, itemB],
            subtotal: 70.0,
            discount: 0.0,
            tax: 10.5,
            total: 80.5,
            paymentMethod: 'cash',
          );

          // Assert — one enqueueCreate('inventory_movements') per sale item.
          verify(
            () => mockSyncService.enqueueCreate(
              tableName: 'inventory_movements',
              recordId: any(named: 'recordId'),
              data: any(named: 'data'),
              priority: SyncPriority.high,
            ),
          ).called(2);
        },
      );

      test(
        'inventory_movements enqueue payload carries type, qty, previousQty, '
        'newQty, and references the sale',
        () async {
          // Arrange
          final product = createTestProductsTableData(
            id: 'prod-X',
            stockQty: 20,
            trackInventory: true,
          );
          final cartItem = createTestCartItem(
            productId: 'prod-X',
            price: 500,
            quantity: 4,
          );

          setupCreateSaleMocks(product: product);

          // Capture every enqueueCreate; filter for the inventory_movements one
          // so other enqueues (sales, sale_items) don't interfere.
          final capturedInventoryPayloads = <Map<String, dynamic>>[];
          when(
            () => mockSyncService.enqueueCreate(
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              data: any(named: 'data'),
              priority: any(named: 'priority'),
            ),
          ).thenAnswer((invocation) async {
            final tableName = invocation.namedArguments[#tableName] as String;
            final data =
                invocation.namedArguments[#data] as Map<String, dynamic>;
            if (tableName == 'inventory_movements') {
              capturedInventoryPayloads.add(data);
            }
            return 'sync-id';
          });

          // Act
          final result = await saleService.createSale(
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
          expect(capturedInventoryPayloads, hasLength(1));
          final payload = capturedInventoryPayloads.single;
          expect(payload['productId'], 'prod-X');
          expect(payload['storeId'], 'store-1');
          expect(payload['type'], 'sale');
          // Quantity is stored as a NEGATIVE double for sale movements.
          expect(payload['qty'], -4.0);
          expect(payload['previousQty'], 20.0);
          expect(payload['newQty'], 16.0);
          expect(payload['referenceType'], 'sale');
          expect(payload['referenceId'], result.saleId);
          expect(payload['userId'], 'cashier-1');
          // id is the Drift movement id; must echo recordId so the server row
          // and the local row share a primary key.
          expect(payload['id'], isA<String>());
          expect((payload['id'] as String).isNotEmpty, isTrue);
        },
      );

      test('should create debt when payment method is credit', () async {
        // Arrange
        final product = createTestProductsTableData(
          id: 'prod-1',
          name: 'Credit Product',
          price: 10000,
          stockQty: 50,
          trackInventory: true,
        );

        final cartItem = createTestCartItem(
          productId: 'prod-1',
          productName: 'Credit Product',
          price: 10000,
          quantity: 1,
        );

        setupCreateSaleMocks(product: product);

        // Mock customer exists in DB (required for debt creation)
        when(() => mockCustomersDao.getCustomerById('cust-1')).thenAnswer(
          (_) async => CustomersTableData(
            id: 'cust-1',
            storeId: 'store-1',
            name: 'Test Customer',
            type: 'individual',
            isActive: true,
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        // No existing account for this customer
        when(
          () => mockAccountsDao.getCustomerAccount('cust-1', 'store-1'),
        ).thenAnswer((_) async => null);
        when(
          () => mockAccountsDao.insertAccount(any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockTransactionsDao.recordInvoice(
            id: any(named: 'id'),
            storeId: any(named: 'storeId'),
            accountId: any(named: 'accountId'),
            amount: any(named: 'amount'),
            balanceAfter: any(named: 'balanceAfter'),
            saleId: any(named: 'saleId'),
            createdBy: any(named: 'createdBy'),
          ),
        ).thenAnswer((_) async => 1);

        // Capture the SalesTableCompanion to verify isPaid
        SalesTableCompanion? capturedSale;
        when(() => mockSalesDao.insertSale(any())).thenAnswer((invocation) {
          capturedSale =
              invocation.positionalArguments[0] as SalesTableCompanion;
          return Future.value(1);
        });

        // Act
        final result = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [cartItem],
          subtotal: 100.0,
          discount: 0.0,
          tax: 15.0,
          total: 115.0,
          paymentMethod: 'credit',
          customerId: 'cust-1',
          customerName: 'Test Customer',
        );

        // Assert
        expect(result.saleId, isNotEmpty);
        expect(capturedSale, isNotNull);
        expect(capturedSale!.isPaid.value, isFalse);

        // Verify accounts DAO was called to create a receivable account
        verify(() => mockAccountsDao.insertAccount(any())).called(1);

        // Verify transactions DAO recorded a debt transaction
        verify(
          () => mockTransactionsDao.recordInvoice(
            id: any(named: 'id'),
            storeId: 'store-1',
            accountId: any(named: 'accountId'),
            amount: 115.0,
            balanceAfter: 115.0,
            saleId: result.saleId,
            createdBy: 'cashier-1',
          ),
        ).called(1);
      });

      test('should create sale with empty cart (no items)', () async {
        // Arrange
        // The service does not validate empty items list -- it proceeds and
        // creates a sale record with zero items. This test documents that
        // behavior (a zero-item sale is valid at the service layer).
        setupCreateSaleMocks(
          product: createTestProductsTableData(id: 'unused'),
        );

        // Act
        final result = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [],
          subtotal: 0.0,
          discount: 0.0,
          tax: 0.0,
          total: 0.0,
          paymentMethod: 'cash',
        );

        // Assert - sale is created but no items are inserted
        expect(result.saleId, isNotEmpty);
        verify(() => mockSalesDao.insertSale(any())).called(1);
        verifyNever(() => mockSaleItemsDao.insertItem(any()));
        verifyNever(() => mockProductsDao.updateStock(any(), any()));
      });

      test('should retry on receipt number collision', () async {
        // Arrange
        final product = createTestProductsTableData(
          id: 'prod-1',
          name: 'Collision Product',
          price: 1000,
          stockQty: 100,
          trackInventory: true,
        );

        final cartItem = createTestCartItem(
          productId: 'prod-1',
          productName: 'Collision Product',
          price: 1000,
          quantity: 1,
        );

        // Set up all common mocks except insertSale (we override it below)
        when(
          () => mockSalesDao.getTodayStoreCount(any()),
        ).thenAnswer((_) async => 5);
        when(
          () => mockProductsDao.getProductById('prod-1'),
        ).thenAnswer((_) async => product);
        when(
          () => mockSaleItemsDao.insertItem(any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockInventoryDao.recordSaleMovement(
            id: any(named: 'id'),
            productId: any(named: 'productId'),
            storeId: any(named: 'storeId'),
            qty: any(named: 'qty'),
            previousQty: any(named: 'previousQty'),
            saleId: any(named: 'saleId'),
          ),
        ).thenAnswer((_) async => 1);
        when(
          () => mockProductsDao.updateStock(any(), any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockSyncService.enqueueCreate(
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            data: any(named: 'data'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((_) async => 'sync-1');
        when(
          () => mockUsersDao.getUserById(any()),
        ).thenAnswer((_) async => null);
        when(() => mockUsersDao.ensureUser(any())).thenAnswer((_) async => 1);
        when(
          () => mockCustomersDao.getCustomerById(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockStoresDao.getStoreById(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockStockDeltasDao.addDelta(
            id: any(named: 'id'),
            productId: any(named: 'productId'),
            storeId: any(named: 'storeId'),
            orgId: any(named: 'orgId'),
            quantityChange: any(named: 'quantityChange'),
            deviceId: any(named: 'deviceId'),
            operationType: any(named: 'operationType'),
            referenceId: any(named: 'referenceId'),
          ),
        ).thenAnswer((_) async => 1);

        // First insertSale throws unique constraint error, second succeeds
        int insertCallCount = 0;
        final capturedReceipts = <String>[];
        when(() => mockSalesDao.insertSale(any())).thenAnswer((invocation) {
          insertCallCount++;
          final companion =
              invocation.positionalArguments[0] as SalesTableCompanion;
          capturedReceipts.add(companion.receiptNo.value);
          if (insertCallCount == 1) {
            throw Exception(
              'UNIQUE constraint failed: idx_sales_store_receipt_unique',
            );
          }
          return Future.value(1);
        });

        // Act
        final result = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [cartItem],
          subtotal: 10.0,
          discount: 0.0,
          tax: 1.5,
          total: 11.5,
          paymentMethod: 'cash',
        );

        // Assert - sale succeeded on retry
        expect(result.saleId, isNotEmpty);
        // insertSale was called twice (first failed, second succeeded)
        expect(insertCallCount, equals(2));
        // Both receipt numbers have the same format since count didn't change,
        // but the retry mechanism was exercised
        expect(capturedReceipts.length, equals(2));
        expect(capturedReceipts[0], startsWith('POS-'));
        expect(capturedReceipts[1], startsWith('POS-'));
      });

      test('should create debt for credit portion of split payment', () async {
        // Arrange
        final product = createTestProductsTableData(
          id: 'prod-1',
          name: 'Split Product',
          price: 10000,
          stockQty: 50,
          trackInventory: true,
        );

        final cartItem = createTestCartItem(
          productId: 'prod-1',
          productName: 'Split Product',
          price: 10000,
          quantity: 1,
        );

        setupCreateSaleMocks(product: product);

        // Mock customer exists in DB
        when(() => mockCustomersDao.getCustomerById('cust-1')).thenAnswer(
          (_) async => CustomersTableData(
            id: 'cust-1',
            storeId: 'store-1',
            name: 'Split Customer',
            type: 'individual',
            isActive: true,
            createdAt: DateTime(2026, 1, 1),
          ),
        );

        // No existing account for this customer
        when(
          () => mockAccountsDao.getCustomerAccount('cust-1', 'store-1'),
        ).thenAnswer((_) async => null);
        when(
          () => mockAccountsDao.insertAccount(any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockTransactionsDao.recordInvoice(
            id: any(named: 'id'),
            storeId: any(named: 'storeId'),
            accountId: any(named: 'accountId'),
            amount: any(named: 'amount'),
            balanceAfter: any(named: 'balanceAfter'),
            saleId: any(named: 'saleId'),
            createdBy: any(named: 'createdBy'),
          ),
        ).thenAnswer((_) async => 1);

        // Capture the SalesTableCompanion to verify isPaid and amounts
        SalesTableCompanion? capturedSale;
        when(() => mockSalesDao.insertSale(any())).thenAnswer((invocation) {
          capturedSale =
              invocation.positionalArguments[0] as SalesTableCompanion;
          return Future.value(1);
        });

        // Act - total = 100.0, amountReceived = 80.0 (cash 50 + card 30)
        // creditAmount = 20, so isPaid should be false
        final result = await saleService.createSale(
          storeId: 'store-1',
          cashierId: 'cashier-1',
          items: [cartItem],
          subtotal: 100.0,
          discount: 0.0,
          tax: 0.0,
          total: 100.0,
          paymentMethod: 'mixed',
          amountReceived: 80.0,
          cashAmount: 50.0,
          cardAmount: 30.0,
          creditAmount: 20.0,
          customerId: 'cust-1',
          customerName: 'Split Customer',
        );

        // Assert
        expect(result.saleId, isNotEmpty);
        expect(capturedSale, isNotNull);
        // isPaid is false because amountReceived (80) < total (100)
        expect(capturedSale!.isPaid.value, isFalse);
        // C-4 Session 3: sales.total is int cents (100 SAR = 10000).
        expect(capturedSale!.total.value, equals(10000));

        // Verify debt created for the unpaid portion (total - amountReceived = 20)
        verify(() => mockAccountsDao.insertAccount(any())).called(1);
        verify(
          () => mockTransactionsDao.recordInvoice(
            id: any(named: 'id'),
            storeId: 'store-1',
            accountId: any(named: 'accountId'),
            amount: 20.0,
            balanceAfter: 20.0,
            saleId: result.saleId,
            createdBy: 'cashier-1',
          ),
        ).called(1);
      });
    });

    group('voidSale', () {
      test('should void a completed sale and enqueue sync', () async {
        // Arrange
        final sale = createTestSalesTableData(
          id: 'sale-1',
          storeId: 'store-1',
          status: 'completed',
        );

        when(
          () => mockSalesDao.getSaleById('sale-1'),
        ).thenAnswer((_) async => sale);
        when(() => mockSalesDao.voidSale('sale-1')).thenAnswer((_) async => 1);
        when(
          () => mockSyncService.enqueueUpdate(
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            changes: any(named: 'changes'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((_) async => 'sync-1');

        // Act
        await saleService.voidSale('sale-1', reason: 'Customer request');

        // Assert - voidSale delegates stock restoration to salesDao.voidSale
        verify(() => mockSalesDao.voidSale('sale-1')).called(1);
        verify(
          () => mockSyncService.enqueueUpdate(
            tableName: 'sales',
            recordId: 'sale-1',
            changes: any(named: 'changes'),
            priority: SyncPriority.high,
          ),
        ).called(1);
      });

      test('should throw SaleException when sale not found', () async {
        // Arrange
        when(
          () => mockSalesDao.getSaleById('non-existent'),
        ).thenAnswer((_) async => null);

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

        when(
          () => mockSalesDao.getSaleById('sale-1'),
        ).thenAnswer((_) async => voidedSale);

        // Act & Assert
        expect(
          () => saleService.voidSale('sale-1'),
          throwsA(isA<SaleException>()),
        );
      });
    });

    group('getTodayTotal', () {
      test('should return total for today', () async {
        // Arrange
        when(
          () => mockSalesDao.getTodayTotal(any(), any()),
        ).thenAnswer((_) async => 1500.0);

        // Act
        final result = await saleService.getTodayTotal('store-1', 'cashier-1');

        // Assert
        expect(result, equals(1500.0));
      });
    });

    group('getTodayCount', () {
      test('should return count for today', () async {
        // Arrange
        when(
          () => mockSalesDao.getTodayCount(any(), any()),
        ).thenAnswer((_) async => 25);

        // Act
        final result = await saleService.getTodayCount('store-1', 'cashier-1');

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
          price: 1000,
          quantity: 1,
        );

        when(
          () => mockSalesDao.getTodayStoreCount(any()),
        ).thenAnswer((_) async => 5); // 5 previous sales today
        when(
          () => mockProductsDao.getProductById('prod-1'),
        ).thenAnswer((_) async => product);
        when(
          () => mockSaleItemsDao.insertItem(any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockInventoryDao.recordSaleMovement(
            id: any(named: 'id'),
            productId: any(named: 'productId'),
            storeId: any(named: 'storeId'),
            qty: any(named: 'qty'),
            previousQty: any(named: 'previousQty'),
            saleId: any(named: 'saleId'),
          ),
        ).thenAnswer((_) async => 1);
        when(
          () => mockProductsDao.updateStock(any(), any()),
        ).thenAnswer((_) async => 1);
        when(
          () => mockSyncService.enqueueCreate(
            tableName: any(named: 'tableName'),
            recordId: any(named: 'recordId'),
            data: any(named: 'data'),
            priority: any(named: 'priority'),
          ),
        ).thenAnswer((_) async => 'sync-1');
        when(
          () => mockUsersDao.getUserById(any()),
        ).thenAnswer((_) async => null);
        when(() => mockUsersDao.ensureUser(any())).thenAnswer((_) async => 1);
        when(
          () => mockCustomersDao.getCustomerById(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockStoresDao.getStoreById(any()),
        ).thenAnswer((_) async => null);
        when(
          () => mockStockDeltasDao.addDelta(
            id: any(named: 'id'),
            productId: any(named: 'productId'),
            storeId: any(named: 'storeId'),
            orgId: any(named: 'orgId'),
            quantityChange: any(named: 'quantityChange'),
            deviceId: any(named: 'deviceId'),
            operationType: any(named: 'operationType'),
            referenceId: any(named: 'referenceId'),
          ),
        ).thenAnswer((_) async => 1);

        // Capture the SalesTableCompanion passed to insertSale
        SalesTableCompanion? capturedCompanion;
        when(() => mockSalesDao.insertSale(any())).thenAnswer((invocation) {
          capturedCompanion =
              invocation.positionalArguments[0] as SalesTableCompanion;
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

        // Assert - receipt number should be POS-YYYYMMDD-<suffix>-0006
        expect(capturedCompanion, isNotNull);
        final receiptNo = capturedCompanion!.receiptNo.value;
        expect(receiptNo, startsWith('POS-'));
        expect(receiptNo, endsWith('-0006')); // 5 + 1 = 6
        // C-1 contract: suffix segment (4 hex chars) sits between the
        // date and the count.
        expect(
          RegExp(r'^POS-\d{8}-[0-9a-f]{4}-\d{4}$').hasMatch(receiptNo),
          isTrue,
          reason: 'Receipt number should match new C-1 format: $receiptNo',
        );
      });

      test(
        'regression — two devices in the same store with the same local '
        'count generate different receipts (C-1, multi-device offline '
        'collision since v17 2026-03-06)',
        () async {
          // Arrange: two SaleService instances, same mock DB (to keep the
          // test simple — in production they'd be separate Drift DBs, but
          // for the receipt-number calculation what matters is each has a
          // distinct TerminalSuffixService value). Both see
          // todayStoreCount=5 so the legacy encoder would hand them
          // BOTH `POS-YYYYMMDD-0006`.
          final deviceA = SaleService(
            db: mockDb,
            syncService: mockSyncService,
            terminalSuffix: _FixedTerminalSuffix('a3f7'),
          );
          final deviceB = SaleService(
            db: mockDb,
            syncService: mockSyncService,
            terminalSuffix: _FixedTerminalSuffix('b2c8'),
          );

          final product = createTestProductsTableData(
            id: 'prod-1',
            name: 'Soda',
            price: 1000, // 10 SAR in cents
            stockQty: 100,
          );
          final cartItem = createTestCartItem(
            productId: 'prod-1',
            productName: 'Soda',
            price: 1000,
            quantity: 1,
          );

          when(
            () => mockSalesDao.getTodayStoreCount(any()),
          ).thenAnswer((_) async => 5);
          when(
            () => mockProductsDao.getProductById('prod-1'),
          ).thenAnswer((_) async => product);
          when(() => mockSaleItemsDao.insertItem(any())).thenAnswer((_) async => 1);
          when(
            () => mockInventoryDao.recordSaleMovement(
              id: any(named: 'id'),
              productId: any(named: 'productId'),
              storeId: any(named: 'storeId'),
              qty: any(named: 'qty'),
              previousQty: any(named: 'previousQty'),
              saleId: any(named: 'saleId'),
            ),
          ).thenAnswer((_) async => 1);
          when(
            () => mockProductsDao.updateStock(any(), any()),
          ).thenAnswer((_) async => 1);
          when(
            () => mockSyncService.enqueueCreate(
              tableName: any(named: 'tableName'),
              recordId: any(named: 'recordId'),
              data: any(named: 'data'),
              priority: any(named: 'priority'),
            ),
          ).thenAnswer((_) async => 'sync-1');
          when(() => mockUsersDao.getUserById(any())).thenAnswer((_) async => null);
          when(() => mockUsersDao.ensureUser(any())).thenAnswer((_) async => 1);
          when(
            () => mockCustomersDao.getCustomerById(any()),
          ).thenAnswer((_) async => null);
          when(() => mockStoresDao.getStoreById(any())).thenAnswer((_) async => null);
          when(
            () => mockStockDeltasDao.addDelta(
              id: any(named: 'id'),
              productId: any(named: 'productId'),
              storeId: any(named: 'storeId'),
              orgId: any(named: 'orgId'),
              quantityChange: any(named: 'quantityChange'),
              deviceId: any(named: 'deviceId'),
              operationType: any(named: 'operationType'),
              referenceId: any(named: 'referenceId'),
            ),
          ).thenAnswer((_) async => 1);

          final captured = <SalesTableCompanion>[];
          when(() => mockSalesDao.insertSale(any())).thenAnswer((inv) {
            captured.add(
              inv.positionalArguments[0] as SalesTableCompanion,
            );
            return Future.value(1);
          });

          // Act — both devices create a sale.
          await deviceA.createSale(
            storeId: 'store-1',
            cashierId: 'cashier-1',
            items: [cartItem],
            subtotal: 10.0,
            discount: 0.0,
            tax: 1.5,
            total: 11.5,
            paymentMethod: 'cash',
          );
          await deviceB.createSale(
            storeId: 'store-1',
            cashierId: 'cashier-2',
            items: [cartItem],
            subtotal: 10.0,
            discount: 0.0,
            tax: 1.5,
            total: 11.5,
            paymentMethod: 'cash',
          );

          // Assert — suffixes land in the receipt numbers and the two
          // are NOT equal (the whole point of the fix).
          expect(captured.length, 2);
          final receiptA = captured[0].receiptNo.value;
          final receiptB = captured[1].receiptNo.value;
          expect(receiptA, contains('-a3f7-'));
          expect(receiptB, contains('-b2c8-'));
          expect(receiptA, isNot(receiptB));
          // Both should end in the same count (pre-fix this was the
          // collision point).
          expect(receiptA, endsWith('-0006'));
          expect(receiptB, endsWith('-0006'));
        },
      );
    });
  });
}
