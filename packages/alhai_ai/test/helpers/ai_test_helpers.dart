/// Mock classes and helpers for alhai_ai tests
library;

import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// MOCK CLASSES
// ============================================================================

class MockAppDatabase extends Mock implements AppDatabase {}

class MockSalesDao extends Mock implements SalesDao {}

class MockProductsDao extends Mock implements ProductsDao {}

class MockAccountsDao extends Mock implements AccountsDao {}

class MockSaleItemsDao extends Mock implements SaleItemsDao {}

class MockInventoryDao extends Mock implements InventoryDao {}

// ============================================================================
// FAKE DATA FACTORIES
// ============================================================================

/// Create a fake ProductsTableData for testing
ProductsTableData createFakeProduct({
  String id = 'test-product-1',
  String storeId = 'store-1',
  String name = 'Test Product',
  double price = 25.0,
  double? costPrice = 15.0,
  int stockQty = 100,
  int minQty = 10,
  String? categoryId,
  bool isActive = true,
}) {
  return ProductsTableData(
    id: id,
    storeId: storeId,
    name: name,
    price: price,
    costPrice: costPrice,
    stockQty: stockQty,
    minQty: minQty,
    categoryId: categoryId,
    isActive: isActive,
    trackInventory: true,
    createdAt: DateTime.now(),
  );
}

/// Create a fake SalesTableData for testing
SalesTableData createFakeSale({
  String id = 'sale-1',
  String storeId = 'store-1',
  String cashierId = 'cashier-1',
  double total = 100.0,
  DateTime? createdAt,
}) {
  return SalesTableData(
    id: id,
    receiptNo: 'REC-001',
    storeId: storeId,
    cashierId: cashierId,
    subtotal: total,
    discount: 0,
    tax: total * 0.15,
    total: total,
    paymentMethod: 'cash',
    isPaid: true,
    channel: 'pos',
    status: 'completed',
    createdAt: createdAt ?? DateTime.now(),
  );
}

/// Create a fake AccountsTableData for testing
AccountsTableData createFakeAccount({
  String id = 'account-1',
  String storeId = 'store-1',
  String name = 'Test Customer',
  double balance = 500.0,
  String type = 'receivable',
}) {
  return AccountsTableData(
    id: id,
    storeId: storeId,
    type: type,
    name: name,
    balance: balance,
    creditLimit: 1000.0,
    isActive: true,
    createdAt: DateTime.now(),
  );
}

// ============================================================================
// SETUP HELPERS
// ============================================================================

/// Setup a MockAppDatabase with mock DAOs
MockAppDatabase createMockDatabase({
  MockSalesDao? salesDao,
  MockProductsDao? productsDao,
  MockAccountsDao? accountsDao,
  MockSaleItemsDao? saleItemsDao,
  MockInventoryDao? inventoryDao,
}) {
  final db = MockAppDatabase();
  final mockSalesDao = salesDao ?? MockSalesDao();
  final mockProductsDao = productsDao ?? MockProductsDao();
  final mockAccountsDao = accountsDao ?? MockAccountsDao();
  final mockSaleItemsDao = saleItemsDao ?? MockSaleItemsDao();
  final mockInventoryDao = inventoryDao ?? MockInventoryDao();

  when(() => db.salesDao).thenReturn(mockSalesDao);
  when(() => db.productsDao).thenReturn(mockProductsDao);
  when(() => db.accountsDao).thenReturn(mockAccountsDao);
  when(() => db.saleItemsDao).thenReturn(mockSaleItemsDao);
  when(() => db.inventoryDao).thenReturn(mockInventoryDao);

  return db;
}
