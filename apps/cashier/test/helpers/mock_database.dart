/// Mock database classes for Cashier tests
///
/// Provides mock implementations of AppDatabase and all 28 DAOs,
/// plus Fake companion classes for mocktail registerFallbackValue,
/// and a helper to wire all DAOs into a MockAppDatabase.
library;

import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_sync/alhai_sync.dart' show SyncPriority;

// ============================================================================
// MOCK DATABASE
// ============================================================================

class MockAppDatabase extends Mock implements AppDatabase {}

// ============================================================================
// MOCK DAOs - Core
// ============================================================================

class MockProductsDao extends Mock implements ProductsDao {}

class MockSalesDao extends Mock implements SalesDao {}

class MockSaleItemsDao extends Mock implements SaleItemsDao {}

class MockInventoryDao extends Mock implements InventoryDao {}

class MockAccountsDao extends Mock implements AccountsDao {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class MockTransactionsDao extends Mock implements TransactionsDao {}

class MockOrdersDao extends Mock implements OrdersDao {}

class MockAuditLogDao extends Mock implements AuditLogDao {}

class MockCategoriesDao extends Mock implements CategoriesDao {}

class MockLoyaltyDao extends Mock implements LoyaltyDao {}

// ============================================================================
// MOCK DAOs - Business
// ============================================================================

class MockStoresDao extends Mock implements StoresDao {}

class MockUsersDao extends Mock implements UsersDao {}

class MockCustomersDao extends Mock implements CustomersDao {}

class MockSuppliersDao extends Mock implements SuppliersDao {}

class MockShiftsDao extends Mock implements ShiftsDao {}

class MockReturnsDao extends Mock implements ReturnsDao {}

class MockExpensesDao extends Mock implements ExpensesDao {}

class MockPurchasesDao extends Mock implements PurchasesDao {}

class MockDiscountsDao extends Mock implements DiscountsDao {}

class MockNotificationsDao extends Mock implements NotificationsDao {}

// ============================================================================
// MOCK DAOs - WhatsApp
// ============================================================================

class MockWhatsAppMessagesDao extends Mock implements WhatsAppMessagesDao {}

class MockWhatsAppTemplatesDao extends Mock implements WhatsAppTemplatesDao {}

// ============================================================================
// MOCK DAOs - Multi-tenant
// ============================================================================

class MockOrganizationsDao extends Mock implements OrganizationsDao {}

class MockOrgMembersDao extends Mock implements OrgMembersDao {}

class MockPosTerminalsDao extends Mock implements PosTerminalsDao {}

// ============================================================================
// MOCK DAOs - Sync
// ============================================================================

class MockSyncMetadataDao extends Mock implements SyncMetadataDao {}

class MockStockDeltasDao extends Mock implements StockDeltasDao {}

// ============================================================================
// FAKE CLASSES (for mocktail registerFallbackValue)
// ============================================================================

class FakeProductsTableCompanion extends Fake
    implements ProductsTableCompanion {}

class FakeSalesTableCompanion extends Fake implements SalesTableCompanion {}

class FakeSaleItemsTableCompanion extends Fake
    implements SaleItemsTableCompanion {}

class FakeOrdersTableCompanion extends Fake implements OrdersTableCompanion {}

class FakeCategoriesTableCompanion extends Fake
    implements CategoriesTableCompanion {}

class FakeCustomersTableCompanion extends Fake
    implements CustomersTableCompanion {}

class FakeInventoryMovementsTableCompanion extends Fake
    implements InventoryMovementsTableCompanion {}

class FakeShiftsTableCompanion extends Fake implements ShiftsTableCompanion {}

class FakeReturnsTableCompanion extends Fake implements ReturnsTableCompanion {}

class FakeExpensesTableCompanion extends Fake
    implements ExpensesTableCompanion {}

class FakePurchasesTableCompanion extends Fake
    implements PurchasesTableCompanion {}

class FakeDiscountsTableCompanion extends Fake
    implements DiscountsTableCompanion {}

class FakeAccountsTableCompanion extends Fake
    implements AccountsTableCompanion {}

class FakeSyncQueueTableCompanion extends Fake
    implements SyncQueueTableCompanion {}

class FakeSuppliersTableCompanion extends Fake
    implements SuppliersTableCompanion {}

class FakeStoresTableCompanion extends Fake implements StoresTableCompanion {}

class FakeUsersTableCompanion extends Fake implements UsersTableCompanion {}

class FakeStockDeltasTableCompanion extends Fake
    implements StockDeltasTableCompanion {}

// ============================================================================
// REGISTRATION HELPER
// ============================================================================

/// Register all fallback values for mocktail.
///
/// Call once in setUpAll() before any when() stubs that use `any()` matchers
/// on Drift companion objects.
void registerCashierFallbackValues() {
  registerFallbackValue(FakeProductsTableCompanion());
  registerFallbackValue(FakeSalesTableCompanion());
  registerFallbackValue(FakeSaleItemsTableCompanion());
  registerFallbackValue(FakeOrdersTableCompanion());
  registerFallbackValue(FakeCategoriesTableCompanion());
  registerFallbackValue(FakeCustomersTableCompanion());
  registerFallbackValue(FakeInventoryMovementsTableCompanion());
  registerFallbackValue(FakeShiftsTableCompanion());
  registerFallbackValue(FakeReturnsTableCompanion());
  registerFallbackValue(FakeExpensesTableCompanion());
  registerFallbackValue(FakePurchasesTableCompanion());
  registerFallbackValue(FakeDiscountsTableCompanion());
  registerFallbackValue(FakeAccountsTableCompanion());
  registerFallbackValue(FakeSyncQueueTableCompanion());
  registerFallbackValue(FakeSuppliersTableCompanion());
  registerFallbackValue(FakeStoresTableCompanion());
  registerFallbackValue(FakeUsersTableCompanion());
  registerFallbackValue(FakeStockDeltasTableCompanion());
  // SyncPriority is needed by defaultProviderOverrides() for any(named: 'priority')
  registerFallbackValue(SyncPriority.normal);
}

// ============================================================================
// DATABASE SETUP HELPER
// ============================================================================

/// Setup a [MockAppDatabase] with all 28 DAOs wired.
///
/// Pass specific mock DAOs to override defaults. Any DAO not provided
/// will be created as a fresh [Mock] instance.
///
/// Example:
/// ```dart
/// final salesDao = MockSalesDao();
/// when(() => salesDao.watchAllByStore('test-store-1'))
///     .thenAnswer((_) => Stream.value([]));
///
/// final db = setupMockDatabase(salesDao: salesDao);
/// setupTestGetIt(mockDb: db);
/// ```
MockAppDatabase setupMockDatabase({
  // Core DAOs
  MockProductsDao? productsDao,
  MockSalesDao? salesDao,
  MockSaleItemsDao? saleItemsDao,
  MockInventoryDao? inventoryDao,
  MockAccountsDao? accountsDao,
  MockSyncQueueDao? syncQueueDao,
  MockTransactionsDao? transactionsDao,
  MockOrdersDao? ordersDao,
  MockAuditLogDao? auditLogDao,
  MockCategoriesDao? categoriesDao,
  MockLoyaltyDao? loyaltyDao,
  // Business DAOs
  MockStoresDao? storesDao,
  MockUsersDao? usersDao,
  MockCustomersDao? customersDao,
  MockSuppliersDao? suppliersDao,
  MockShiftsDao? shiftsDao,
  MockReturnsDao? returnsDao,
  MockExpensesDao? expensesDao,
  MockPurchasesDao? purchasesDao,
  MockDiscountsDao? discountsDao,
  MockNotificationsDao? notificationsDao,
  // WhatsApp DAOs
  MockWhatsAppMessagesDao? whatsAppMessagesDao,
  MockWhatsAppTemplatesDao? whatsAppTemplatesDao,
  // Multi-tenant DAOs
  MockOrganizationsDao? organizationsDao,
  MockOrgMembersDao? orgMembersDao,
  MockPosTerminalsDao? posTerminalsDao,
  // Sync DAOs
  MockSyncMetadataDao? syncMetadataDao,
  MockStockDeltasDao? stockDeltasDao,
}) {
  final db = MockAppDatabase();

  // Core DAOs
  when(() => db.productsDao).thenReturn(productsDao ?? MockProductsDao());
  when(() => db.salesDao).thenReturn(salesDao ?? MockSalesDao());
  when(() => db.saleItemsDao).thenReturn(saleItemsDao ?? MockSaleItemsDao());
  when(() => db.inventoryDao).thenReturn(inventoryDao ?? MockInventoryDao());
  when(() => db.accountsDao).thenReturn(accountsDao ?? MockAccountsDao());
  when(() => db.syncQueueDao).thenReturn(syncQueueDao ?? MockSyncQueueDao());
  when(() => db.transactionsDao)
      .thenReturn(transactionsDao ?? MockTransactionsDao());
  when(() => db.ordersDao).thenReturn(ordersDao ?? MockOrdersDao());
  when(() => db.auditLogDao).thenReturn(auditLogDao ?? MockAuditLogDao());
  when(() => db.categoriesDao)
      .thenReturn(categoriesDao ?? MockCategoriesDao());
  when(() => db.loyaltyDao).thenReturn(loyaltyDao ?? MockLoyaltyDao());

  // Business DAOs
  when(() => db.storesDao).thenReturn(storesDao ?? MockStoresDao());
  when(() => db.usersDao).thenReturn(usersDao ?? MockUsersDao());
  when(() => db.customersDao).thenReturn(customersDao ?? MockCustomersDao());
  when(() => db.suppliersDao).thenReturn(suppliersDao ?? MockSuppliersDao());
  when(() => db.shiftsDao).thenReturn(shiftsDao ?? MockShiftsDao());
  when(() => db.returnsDao).thenReturn(returnsDao ?? MockReturnsDao());
  when(() => db.expensesDao).thenReturn(expensesDao ?? MockExpensesDao());
  when(() => db.purchasesDao).thenReturn(purchasesDao ?? MockPurchasesDao());
  when(() => db.discountsDao).thenReturn(discountsDao ?? MockDiscountsDao());
  when(() => db.notificationsDao)
      .thenReturn(notificationsDao ?? MockNotificationsDao());

  // WhatsApp DAOs
  when(() => db.whatsAppMessagesDao)
      .thenReturn(whatsAppMessagesDao ?? MockWhatsAppMessagesDao());
  when(() => db.whatsAppTemplatesDao)
      .thenReturn(whatsAppTemplatesDao ?? MockWhatsAppTemplatesDao());

  // Multi-tenant DAOs
  when(() => db.organizationsDao)
      .thenReturn(organizationsDao ?? MockOrganizationsDao());
  when(() => db.orgMembersDao)
      .thenReturn(orgMembersDao ?? MockOrgMembersDao());
  when(() => db.posTerminalsDao)
      .thenReturn(posTerminalsDao ?? MockPosTerminalsDao());

  // Sync DAOs
  when(() => db.syncMetadataDao)
      .thenReturn(syncMetadataDao ?? MockSyncMetadataDao());
  when(() => db.stockDeltasDao)
      .thenReturn(stockDeltasDao ?? MockStockDeltasDao());

  return db;
}
