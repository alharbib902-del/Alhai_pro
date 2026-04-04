/// Mock database classes for Admin tests
library;

import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// MOCK DATABASE
// ============================================================================

class MockAppDatabase extends Mock implements AppDatabase {}

// ============================================================================
// MOCK DAOs
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

class MockWhatsAppMessagesDao extends Mock implements WhatsAppMessagesDao {}

class MockWhatsAppTemplatesDao extends Mock implements WhatsAppTemplatesDao {}

class MockOrganizationsDao extends Mock implements OrganizationsDao {}

class MockOrgMembersDao extends Mock implements OrgMembersDao {}

class MockPosTerminalsDao extends Mock implements PosTerminalsDao {}

class MockSyncMetadataDao extends Mock implements SyncMetadataDao {}

class MockStockDeltasDao extends Mock implements StockDeltasDao {}

// ============================================================================
// FAKE COMPANION CLASSES (for mocktail registerFallbackValue)
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

class FakeCouponsTableCompanion extends Fake implements CouponsTableCompanion {}

class FakePromotionsTableCompanion extends Fake
    implements PromotionsTableCompanion {}

class FakeSuppliersTableCompanion extends Fake
    implements SuppliersTableCompanion {}

// ============================================================================
// FALLBACK VALUE REGISTRATION
// ============================================================================

/// Register all Fake companion classes as fallback values for mocktail.
/// Call this in setUpAll() before any test that uses verify() with matchers.
void registerAdminFallbackValues() {
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
  registerFallbackValue(FakeCouponsTableCompanion());
  registerFallbackValue(FakePromotionsTableCompanion());
  registerFallbackValue(FakeSuppliersTableCompanion());
}

// ============================================================================
// DATABASE SETUP HELPER
// ============================================================================

/// Creates a MockAppDatabase with all DAO getters stubbed.
/// Pass specific mock DAOs to control their behavior in tests.
MockAppDatabase setupMockDatabase({
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
  MockWhatsAppMessagesDao? whatsAppMessagesDao,
  MockWhatsAppTemplatesDao? whatsAppTemplatesDao,
  MockOrganizationsDao? organizationsDao,
  MockOrgMembersDao? orgMembersDao,
  MockPosTerminalsDao? posTerminalsDao,
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
  when(() => db.categoriesDao).thenReturn(categoriesDao ?? MockCategoriesDao());
  when(() => db.loyaltyDao).thenReturn(loyaltyDao ?? MockLoyaltyDao());

  // High-priority DAOs
  when(() => db.storesDao).thenReturn(storesDao ?? MockStoresDao());
  when(() => db.usersDao).thenReturn(usersDao ?? MockUsersDao());
  when(() => db.customersDao).thenReturn(customersDao ?? MockCustomersDao());
  when(() => db.suppliersDao).thenReturn(suppliersDao ?? MockSuppliersDao());
  when(() => db.shiftsDao).thenReturn(shiftsDao ?? MockShiftsDao());
  when(() => db.returnsDao).thenReturn(returnsDao ?? MockReturnsDao());
  when(() => db.expensesDao).thenReturn(expensesDao ?? MockExpensesDao());

  // Medium-priority DAOs
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
  when(() => db.orgMembersDao).thenReturn(orgMembersDao ?? MockOrgMembersDao());
  when(() => db.posTerminalsDao)
      .thenReturn(posTerminalsDao ?? MockPosTerminalsDao());

  // Sync DAOs
  when(() => db.syncMetadataDao)
      .thenReturn(syncMetadataDao ?? MockSyncMetadataDao());
  when(() => db.stockDeltasDao)
      .thenReturn(stockDeltasDao ?? MockStockDeltasDao());

  return db;
}
