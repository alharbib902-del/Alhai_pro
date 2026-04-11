/// مساعدات الاختبار لحزمة POS - POS Test Helpers
///
/// توفر محاكيات (Mocks) وبيانات وهمية لجميع اختبارات POS
library;

import 'package:mocktail/mocktail.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart';
import 'package:alhai_core/alhai_core.dart' hide CartItem;
import 'package:alhai_pos/src/providers/cart_providers.dart';
import 'package:alhai_pos/src/services/whatsapp/phone_validation_service.dart';
import 'package:alhai_pos/src/services/whatsapp/wasender_api_client.dart';

// ============================================================================
// MOCK CLASSES
// ============================================================================

/// Mock for AppDatabase
class MockAppDatabase extends Mock implements AppDatabase {}

/// Mock for SyncService
class MockSyncService extends Mock implements SyncService {}

/// Mock for SalesDao
class MockSalesDao extends Mock implements SalesDao {}

/// Mock for SaleItemsDao
class MockSaleItemsDao extends Mock implements SaleItemsDao {}

/// Mock for ProductsDao
class MockProductsDao extends Mock implements ProductsDao {}

/// Mock for InventoryDao
class MockInventoryDao extends Mock implements InventoryDao {}

/// Mock for WhatsAppMessagesDao
class MockWhatsAppMessagesDao extends Mock implements WhatsAppMessagesDao {}

/// Mock for WaSenderApiClient
class MockWaSenderApiClient extends Mock implements WaSenderApiClient {}

/// Mock for PhoneValidationService
class MockPhoneValidationService extends Mock
    implements PhoneValidationService {}

/// Mock for CartPersistenceService
class MockCartPersistenceService extends Mock
    implements CartPersistenceService {}

/// Mock for SyncQueueDao
class MockSyncQueueDao extends Mock implements SyncQueueDao {}

/// Mock for ReturnsDao
class MockReturnsDao extends Mock implements ReturnsDao {}

/// Mock for AccountsDao
class MockAccountsDao extends Mock implements AccountsDao {}

/// Mock for TransactionsDao
class MockTransactionsDao extends Mock implements TransactionsDao {}

/// Mock for StockDeltasDao
class MockStockDeltasDao extends Mock implements StockDeltasDao {}

/// Mock for UsersDao
class MockUsersDao extends Mock implements UsersDao {}

/// Mock for CustomersDao
class MockCustomersDao extends Mock implements CustomersDao {}

/// Mock for StoresDao
class MockStoresDao extends Mock implements StoresDao {}

// ============================================================================
// FAKE CLASSES (for mocktail fallbackValue)
// ============================================================================

class FakeSalesTableCompanion extends Fake implements SalesTableCompanion {}

class FakeSaleItemsTableCompanion extends Fake
    implements SaleItemsTableCompanion {}

class FakeInventoryMovementsTableCompanion extends Fake
    implements InventoryMovementsTableCompanion {}

class FakeWhatsAppMessagesTableCompanion extends Fake
    implements WhatsAppMessagesTableCompanion {}

class FakeAccountsTableCompanion extends Fake
    implements AccountsTableCompanion {}

class FakeTransactionsTableCompanion extends Fake
    implements TransactionsTableCompanion {}

class FakeUsersTableCompanion extends Fake implements UsersTableCompanion {}

class FakeStockDeltasTableCompanion extends Fake
    implements StockDeltasTableCompanion {}

// ============================================================================
// REGISTRATION HELPER
// ============================================================================

/// Register all fallback values for mocktail
void registerPosFallbackValues() {
  registerFallbackValue(FakeSalesTableCompanion());
  registerFallbackValue(FakeSaleItemsTableCompanion());
  registerFallbackValue(FakeInventoryMovementsTableCompanion());
  registerFallbackValue(FakeWhatsAppMessagesTableCompanion());
  registerFallbackValue(FakeAccountsTableCompanion());
  registerFallbackValue(FakeTransactionsTableCompanion());
  registerFallbackValue(FakeUsersTableCompanion());
  registerFallbackValue(FakeStockDeltasTableCompanion());
  registerFallbackValue(SyncPriority.normal);
  registerFallbackValue(const CartState());
  registerFallbackValue(
    HeldInvoice(
      id: 'fake',
      cart: const CartState(),
      createdAt: DateTime(2026, 1, 1),
    ),
  );
}

// ============================================================================
// TEST DATA FACTORIES
// ============================================================================

/// Create a test Product
Product createTestProduct({
  String id = 'prod-1',
  String storeId = 'store-1',
  String name = 'Test Product',
  double price = 10.0,
  double? costPrice = 5.0,
  double stockQty = 100,
  bool isActive = true,
  bool trackInventory = true,
  String? barcode,
}) {
  return Product(
    id: id,
    storeId: storeId,
    name: name,
    price: price,
    costPrice: costPrice,
    stockQty: stockQty,
    isActive: isActive,
    trackInventory: trackInventory,
    barcode: barcode,
    createdAt: DateTime(2026, 1, 1),
  );
}

/// Create a test PosCartItem
PosCartItem createTestCartItem({
  String productId = 'prod-1',
  String productName = 'Test Product',
  double price = 10.0,
  int quantity = 1,
  double? customPrice,
}) {
  return PosCartItem(
    product: createTestProduct(id: productId, name: productName, price: price),
    quantity: quantity,
    customPrice: customPrice,
  );
}

/// Create a test CartState with items
CartState createTestCartState({
  List<PosCartItem>? items,
  double discount = 0,
  String? customerId,
  String? customerName,
}) {
  return CartState(
    items:
        items ??
        [
          createTestCartItem(
            productId: 'prod-1',
            productName: 'Product A',
            price: 10.0,
            quantity: 2,
          ),
          createTestCartItem(
            productId: 'prod-2',
            productName: 'Product B',
            price: 20.0,
            quantity: 1,
          ),
        ],
    discount: discount,
    customerId: customerId,
    customerName: customerName,
  );
}

/// Create a mock ProductsTableData
ProductsTableData createTestProductsTableData({
  String id = 'prod-1',
  String storeId = 'store-1',
  String name = 'Test Product',
  double price = 10.0,
  double costPrice = 5.0,
  double stockQty = 100,
  bool isActive = true,
  bool trackInventory = true,
  String? barcode,
}) {
  return ProductsTableData(
    id: id,
    storeId: storeId,
    name: name,
    price: price,
    costPrice: costPrice,
    stockQty: stockQty,
    isActive: isActive,
    trackInventory: trackInventory,
    barcode: barcode,
    minQty: 1,
    onlineAvailable: false,
    onlineReservedQty: 0,
    autoReorder: false,
    createdAt: DateTime(2026, 1, 1),
  );
}

/// Create a mock SalesTableData
SalesTableData createTestSalesTableData({
  String id = 'sale-1',
  String storeId = 'store-1',
  String receiptNo = 'POS-20260101-0001',
  String cashierId = 'cashier-1',
  String? customerId,
  String? customerName,
  double subtotal = 40.0,
  double discount = 0.0,
  double tax = 6.0,
  double total = 46.0,
  String paymentMethod = 'cash',
  String status = 'completed',
  bool isPaid = true,
  double? amountReceived,
  double? changeAmount,
}) {
  return SalesTableData(
    id: id,
    storeId: storeId,
    receiptNo: receiptNo,
    cashierId: cashierId,
    customerId: customerId,
    customerName: customerName,
    subtotal: subtotal,
    discount: discount,
    tax: tax,
    total: total,
    paymentMethod: paymentMethod,
    channel: 'POS',
    status: status,
    isPaid: isPaid,
    amountReceived: amountReceived,
    changeAmount: changeAmount,
    createdAt: DateTime(2026, 1, 1, 10, 30),
  );
}

/// Create a mock SaleItemsTableData
SaleItemsTableData createTestSaleItemsTableData({
  String id = 'item-1',
  String saleId = 'sale-1',
  String productId = 'prod-1',
  String productName = 'Test Product',
  double unitPrice = 10.0,
  double qty = 2.0,
  double subtotal = 20.0,
  double discount = 0.0,
  double total = 20.0,
}) {
  return SaleItemsTableData(
    id: id,
    saleId: saleId,
    productId: productId,
    productName: productName,
    unitPrice: unitPrice,
    qty: qty,
    subtotal: subtotal,
    discount: discount,
    total: total,
  );
}

// ============================================================================
// SETUP HELPERS
// ============================================================================

/// Setup mock AppDatabase with DAOs
MockAppDatabase setupMockDatabase({
  MockSalesDao? salesDao,
  MockSaleItemsDao? saleItemsDao,
  MockProductsDao? productsDao,
  MockInventoryDao? inventoryDao,
  MockWhatsAppMessagesDao? whatsAppMessagesDao,
  MockReturnsDao? returnsDao,
  MockAccountsDao? accountsDao,
  MockTransactionsDao? transactionsDao,
  MockStockDeltasDao? stockDeltasDao,
  MockUsersDao? usersDao,
  MockCustomersDao? customersDao,
  MockStoresDao? storesDao,
}) {
  final db = MockAppDatabase();

  final mockSalesDao = salesDao ?? MockSalesDao();
  final mockSaleItemsDao = saleItemsDao ?? MockSaleItemsDao();
  final mockProductsDao = productsDao ?? MockProductsDao();
  final mockInventoryDao = inventoryDao ?? MockInventoryDao();
  final mockWhatsAppMessagesDao =
      whatsAppMessagesDao ?? MockWhatsAppMessagesDao();
  final mockReturnsDao = returnsDao ?? MockReturnsDao();
  final mockAccountsDao = accountsDao ?? MockAccountsDao();
  final mockTransactionsDao = transactionsDao ?? MockTransactionsDao();
  final mockStockDeltasDao = stockDeltasDao ?? MockStockDeltasDao();
  final mockUsersDao = usersDao ?? MockUsersDao();
  final mockCustomersDao = customersDao ?? MockCustomersDao();
  final mockStoresDao = storesDao ?? MockStoresDao();

  when(() => db.salesDao).thenReturn(mockSalesDao);
  when(() => db.saleItemsDao).thenReturn(mockSaleItemsDao);
  when(() => db.productsDao).thenReturn(mockProductsDao);
  when(() => db.inventoryDao).thenReturn(mockInventoryDao);
  when(() => db.whatsAppMessagesDao).thenReturn(mockWhatsAppMessagesDao);
  when(() => db.returnsDao).thenReturn(mockReturnsDao);
  when(() => db.accountsDao).thenReturn(mockAccountsDao);
  when(() => db.transactionsDao).thenReturn(mockTransactionsDao);
  when(() => db.stockDeltasDao).thenReturn(mockStockDeltasDao);
  when(() => db.usersDao).thenReturn(mockUsersDao);
  when(() => db.customersDao).thenReturn(mockCustomersDao);
  when(() => db.storesDao).thenReturn(mockStoresDao);

  return db;
}
