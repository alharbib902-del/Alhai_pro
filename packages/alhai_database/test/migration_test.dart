import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

import 'package:alhai_database/alhai_database.dart';

void main() {
  // ─── Schema version ───────────────────────────────────────────────

  group('Schema version', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('schema version is 41', () {
      expect(db.schemaVersion, 41);
    });

    test('schema version is positive', () {
      expect(db.schemaVersion, greaterThan(0));
    });
  });

  // ─── Tables registration ──────────────────────────────────────────

  group('Tables registration', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('allTables is non-empty', () {
      expect(db.allTables, isNotEmpty);
    });

    test('allTables contains core tables', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();

      // Core business tables
      expect(tableNames, contains('products'));
      expect(tableNames, contains('sales'));
      expect(tableNames, contains('sale_items'));
      expect(tableNames, contains('inventory_movements'));
      expect(tableNames, contains('accounts'));
      expect(tableNames, contains('orders'));
      expect(tableNames, contains('order_items'));
      expect(tableNames, contains('categories'));
    });

    test('allTables contains sync tables', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();

      expect(tableNames, contains('sync_queue'));
      expect(tableNames, contains('sync_metadata'));
      expect(tableNames, contains('stock_deltas'));
    });

    test('allTables contains multi-tenant tables', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();

      expect(tableNames, contains('organizations'));
      expect(tableNames, contains('org_members'));
      expect(tableNames, contains('pos_terminals'));
    });

    test('allTables contains secondary tables', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();

      expect(tableNames, contains('stores'));
      expect(tableNames, contains('customers'));
      expect(tableNames, contains('suppliers'));
      expect(tableNames, contains('shifts'));
      expect(tableNames, contains('expenses'));
      expect(tableNames, contains('returns'));
      expect(tableNames, contains('discounts'));
      expect(tableNames, contains('notifications'));
    });

    test('allTables contains whatsapp tables', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();

      expect(tableNames, contains('whatsapp_messages'));
      expect(tableNames, contains('whatsapp_templates'));
    });

    test('allTables contains invoices table', () {
      final tableNames = db.allTables.map((t) => t.actualTableName).toSet();

      expect(tableNames, contains('invoices'));
    });
  });

  // ─── DAOs registration ────────────────────────────────────────────

  group('DAOs registration', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('core DAOs are accessible', () {
      expect(db.productsDao, isA<ProductsDao>());
      expect(db.salesDao, isA<SalesDao>());
      expect(db.saleItemsDao, isA<SaleItemsDao>());
      expect(db.inventoryDao, isA<InventoryDao>());
      expect(db.accountsDao, isA<AccountsDao>());
      expect(db.syncQueueDao, isA<SyncQueueDao>());
      expect(db.transactionsDao, isA<TransactionsDao>());
      expect(db.ordersDao, isA<OrdersDao>());
      expect(db.auditLogDao, isA<AuditLogDao>());
      expect(db.categoriesDao, isA<CategoriesDao>());
      expect(db.loyaltyDao, isA<LoyaltyDao>());
    });

    test('secondary DAOs are accessible', () {
      expect(db.storesDao, isA<StoresDao>());
      expect(db.usersDao, isA<UsersDao>());
      expect(db.customersDao, isA<CustomersDao>());
      expect(db.suppliersDao, isA<SuppliersDao>());
      expect(db.shiftsDao, isA<ShiftsDao>());
      expect(db.expensesDao, isA<ExpensesDao>());
      expect(db.purchasesDao, isA<PurchasesDao>());
      expect(db.discountsDao, isA<DiscountsDao>());
      expect(db.notificationsDao, isA<NotificationsDao>());
    });

    test('multi-tenant DAOs are accessible', () {
      expect(db.orgMembersDao, isA<OrgMembersDao>());
      expect(db.posTerminalsDao, isA<PosTerminalsDao>());
    });

    test('sync DAOs are accessible', () {
      expect(db.syncMetadataDao, isA<SyncMetadataDao>());
      expect(db.stockDeltasDao, isA<StockDeltasDao>());
    });

    test('whatsapp DAOs are accessible', () {
      expect(db.whatsAppMessagesDao, isA<WhatsAppMessagesDao>());
      expect(db.whatsAppTemplatesDao, isA<WhatsAppTemplatesDao>());
    });

    test('invoices DAO is accessible', () {
      expect(db.invoicesDao, isA<InvoicesDao>());
    });

    test('org products DAO is accessible', () {
      expect(db.orgProductsDao, isA<OrgProductsDao>());
    });

    test('stock transfers DAO is accessible', () {
      expect(db.stockTransfersDao, isA<StockTransfersDao>());
    });
  });

  // ─── In-memory database creation ──────────────────────────────────

  group('Database creation', () {
    test('can create in-memory database without errors', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      // If this completes without throwing, the schema is valid
      expect(db, isA<AppDatabase>());
      await db.close();
    });

    test('FTS service is available', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      expect(db.ftsService, isNotNull);
      await db.close();
    });

    test('backup service is available', () async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      expect(db.backupService, isNotNull);
      await db.close();
    });
  });

  // ─── SyncQueueHealth model ────────────────────────────────────────

  group('SyncQueueHealth', () {
    test('activeCount sums pending, syncing, failed, and conflict', () {
      final health = SyncQueueHealth(
        totalItems: 100,
        pendingCount: 40,
        syncingCount: 10,
        failedCount: 5,
        conflictCount: 3,
        syncedCount: 42,
        oldestPendingAt: null,
        avgRetryCount: 0.0,
        itemsPerTable: {},
      );
      expect(health.activeCount, 58); // 40+10+5+3
    });

    test('isOverloaded is true when activeCount > 10000', () {
      final health = SyncQueueHealth(
        totalItems: 15000,
        pendingCount: 10001,
        syncingCount: 0,
        failedCount: 0,
        conflictCount: 0,
        syncedCount: 4999,
        oldestPendingAt: null,
        avgRetryCount: 0.0,
        itemsPerTable: {},
      );
      expect(health.isOverloaded, isTrue);
    });

    test('isOverloaded is false when activeCount <= 10000', () {
      final health = SyncQueueHealth(
        totalItems: 12000,
        pendingCount: 9000,
        syncingCount: 500,
        failedCount: 400,
        conflictCount: 100,
        syncedCount: 2000,
        oldestPendingAt: null,
        avgRetryCount: 0.0,
        itemsPerTable: {},
      );
      expect(health.isOverloaded, isFalse);
    });

    test('isWarning is true when activeCount > 5000', () {
      final health = SyncQueueHealth(
        totalItems: 8000,
        pendingCount: 5001,
        syncingCount: 0,
        failedCount: 0,
        conflictCount: 0,
        syncedCount: 2999,
        oldestPendingAt: null,
        avgRetryCount: 0.0,
        itemsPerTable: {},
      );
      expect(health.isWarning, isTrue);
    });
  });
}
