/// Mock database classes for Admin Lite tests
library;

import 'package:mocktail/mocktail.dart';
import 'package:alhai_database/alhai_database.dart';

// ============================================================================
// MOCK CLASSES
// ============================================================================

class MockAppDatabase extends Mock implements AppDatabase {}

// DAOs used by Admin Lite
class MockSalesDao extends Mock implements SalesDao {}
class MockProductsDao extends Mock implements ProductsDao {}
class MockAuditLogDao extends Mock implements AuditLogDao {}
class MockReturnsDao extends Mock implements ReturnsDao {}
class MockShiftsDao extends Mock implements ShiftsDao {}
class MockOrdersDao extends Mock implements OrdersDao {}
class MockCustomersDao extends Mock implements CustomersDao {}
class MockCategoriesDao extends Mock implements CategoriesDao {}
class MockInventoryDao extends Mock implements InventoryDao {}
class MockNotificationsDao extends Mock implements NotificationsDao {}
class MockStoresDao extends Mock implements StoresDao {}
class MockSyncQueueDao extends Mock implements SyncQueueDao {}

// ============================================================================
// FAKE CLASSES
// ============================================================================

class FakeReturnsTableCompanion extends Fake implements ReturnsTableCompanion {}

// ============================================================================
// REGISTRATION HELPER
// ============================================================================

void registerLiteFallbackValues() {
  registerFallbackValue(FakeReturnsTableCompanion());
}

// ============================================================================
// DATABASE SETUP HELPER
// ============================================================================

MockAppDatabase setupMockDatabase({
  MockSalesDao? salesDao,
  MockProductsDao? productsDao,
  MockAuditLogDao? auditLogDao,
  MockReturnsDao? returnsDao,
  MockShiftsDao? shiftsDao,
  MockOrdersDao? ordersDao,
  MockCustomersDao? customersDao,
  MockCategoriesDao? categoriesDao,
  MockInventoryDao? inventoryDao,
  MockNotificationsDao? notificationsDao,
  MockStoresDao? storesDao,
  MockSyncQueueDao? syncQueueDao,
}) {
  final db = MockAppDatabase();

  when(() => db.salesDao).thenReturn(salesDao ?? MockSalesDao());
  when(() => db.productsDao).thenReturn(productsDao ?? MockProductsDao());
  when(() => db.auditLogDao).thenReturn(auditLogDao ?? MockAuditLogDao());
  when(() => db.returnsDao).thenReturn(returnsDao ?? MockReturnsDao());
  when(() => db.shiftsDao).thenReturn(shiftsDao ?? MockShiftsDao());
  when(() => db.ordersDao).thenReturn(ordersDao ?? MockOrdersDao());
  when(() => db.customersDao).thenReturn(customersDao ?? MockCustomersDao());
  when(() => db.categoriesDao).thenReturn(categoriesDao ?? MockCategoriesDao());
  when(() => db.inventoryDao).thenReturn(inventoryDao ?? MockInventoryDao());
  when(() => db.notificationsDao).thenReturn(notificationsDao ?? MockNotificationsDao());
  when(() => db.storesDao).thenReturn(storesDao ?? MockStoresDao());
  when(() => db.syncQueueDao).thenReturn(syncQueueDao ?? MockSyncQueueDao());

  return db;
}
