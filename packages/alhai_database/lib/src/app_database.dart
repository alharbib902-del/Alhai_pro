import 'package:drift/drift.dart';

import 'tables/tables.dart';
import 'connection.dart';
import 'daos/daos.dart';
import 'fts/products_fts.dart';

part 'app_database.g.dart';

/// قاعدة بيانات التطبيق المحلية
/// تستخدم Drift (SQLite) للتخزين المحلي والعمل بدون إنترنت
@DriftDatabase(
  tables: [
    // الجداول الأساسية
    ProductsTable,
    SalesTable,
    SaleItemsTable,
    InventoryMovementsTable,
    AccountsTable,
    SyncQueueTable,
    TransactionsTable,
    OrdersTable,
    OrderItemsTable,
    AuditLogTable,
    CategoriesTable,
    LoyaltyPointsTable,
    LoyaltyTransactionsTable,
    LoyaltyRewardsTable,
    // جداول الأولوية العالية
    StoresTable,
    UsersTable,
    RolesTable,
    CustomersTable,
    CustomerAddressesTable,
    SuppliersTable,
    ShiftsTable,
    CashMovementsTable,
    ReturnsTable,
    ReturnItemsTable,
    ExpensesTable,
    ExpenseCategoriesTable,
    // جداول الأولوية المتوسطة
    PurchasesTable,
    PurchaseItemsTable,
    DiscountsTable,
    CouponsTable,
    PromotionsTable,
    HeldInvoicesTable,
    NotificationsTable,
    StockTransfersTable,
    SettingsTable,
    // جداول الأولوية المنخفضة
    StockTakesTable,
    ProductExpiryTable,
    DriversTable,
    DailySummariesTable,
    OrderStatusHistoryTable,
    FavoritesTable,
    // جداول واتساب
    WhatsAppMessagesTable,
    WhatsAppTemplatesTable,
    // جداول متعددة المستأجرين
    OrganizationsTable,
    SubscriptionsTable,
    OrgMembersTable,
    UserStoresTable,
    PosTerminalsTable,
    // جداول المزامنة
    SyncMetadataTable,
    StockDeltasTable,
  ],
  daos: [
    // DAOs الأساسية
    ProductsDao,
    SalesDao,
    SaleItemsDao,
    InventoryDao,
    AccountsDao,
    SyncQueueDao,
    TransactionsDao,
    OrdersDao,
    AuditLogDao,
    CategoriesDao,
    LoyaltyDao,
    // DAOs الجديدة
    StoresDao,
    UsersDao,
    CustomersDao,
    SuppliersDao,
    ShiftsDao,
    ReturnsDao,
    ExpensesDao,
    PurchasesDao,
    DiscountsDao,
    NotificationsDao,
    // DAOs واتساب
    WhatsAppMessagesDao,
    WhatsAppTemplatesDao,
    // DAOs متعددة المستأجرين
    OrganizationsDao,
    OrgMembersDao,
    PosTerminalsDao,
    // DAOs المزامنة
    SyncMetadataDao,
    StockDeltasDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// إنشاء قاعدة البيانات مع الاتصال الافتراضي
  AppDatabase() : super(openConnection());

  /// إنشاء قاعدة البيانات مع اتصال مخصص (للاختبارات)
  AppDatabase.forTesting(super.e);

  /// خدمة البحث السريع FTS
  late final ProductsFtsService ftsService = ProductsFtsService(this);

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // إنشاء جدول FTS للبحث السريع
      await ftsService.createFtsTable();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Migration v1 -> v2: إضافة جدول transactions
      if (from < 2) {
        await m.createTable(transactionsTable);
      }
      // Migration v2 -> v3: إضافة جداول orders و order_items
      if (from < 3) {
        await m.createTable(ordersTable);
        await m.createTable(orderItemsTable);
      }
      // Migration v3 -> v4: إضافة جدول audit_log
      if (from < 4) {
        await m.createTable(auditLogTable);
      }
      // Migration v4 -> v5: إضافة جدول categories
      if (from < 5) {
        await m.createTable(categoriesTable);
      }
      // Migration v5 -> v6: إضافة جداول نظام الولاء
      if (from < 6) {
        await m.createTable(loyaltyPointsTable);
        await m.createTable(loyaltyTransactionsTable);
        await m.createTable(loyaltyRewardsTable);
      }
      // Migration v6 -> v7: إضافة FTS5 للبحث السريع
      if (from < 7) {
        await ftsService.createFtsTable();
        await ftsService.rebuildFtsIndex();
      }
      // Migration v7 -> v8: إضافة جميع الجداول الجديدة (المتاجر، المستخدمين، العملاء، الموردين، إلخ)
      if (from < 8) {
        // جداول الأولوية العالية
        await m.createTable(storesTable);
        await m.createTable(usersTable);
        await m.createTable(rolesTable);
        await m.createTable(customersTable);
        await m.createTable(customerAddressesTable);
        await m.createTable(suppliersTable);
        await m.createTable(shiftsTable);
        await m.createTable(cashMovementsTable);
        await m.createTable(returnsTable);
        await m.createTable(returnItemsTable);
        await m.createTable(expensesTable);
        await m.createTable(expenseCategoriesTable);
        // جداول الأولوية المتوسطة
        await m.createTable(purchasesTable);
        await m.createTable(purchaseItemsTable);
        await m.createTable(discountsTable);
        await m.createTable(couponsTable);
        await m.createTable(promotionsTable);
        await m.createTable(heldInvoicesTable);
        await m.createTable(notificationsTable);
        await m.createTable(stockTransfersTable);
        await m.createTable(settingsTable);
        // جداول الأولوية المنخفضة
        await m.createTable(stockTakesTable);
        await m.createTable(productExpiryTable);
        await m.createTable(driversTable);
        await m.createTable(dailySummariesTable);
        await m.createTable(orderStatusHistoryTable);
        await m.createTable(favoritesTable);
      }
      // Migration v8 -> v9: إضافة جداول واتساب
      if (from < 9) {
        await m.createTable(whatsAppMessagesTable);
        await m.createTable(whatsAppTemplatesTable);
      }
      // Migration v9 → v10: إضافة جداول متعددة المستأجرين + أعمدة org_id
      if (from < 10) {
        // إنشاء الجداول الجديدة
        await m.createTable(organizationsTable);
        await m.createTable(subscriptionsTable);
        await m.createTable(orgMembersTable);
        await m.createTable(userStoresTable);
        await m.createTable(posTerminalsTable);
        // إضافة org_id للجداول الحالية
        final tablesForOrgId = [
          'products', 'categories', 'customers', 'customer_addresses',
          'sales', 'orders', 'order_items', 'inventory_movements',
          'accounts', 'suppliers', 'stores', 'users', 'shifts',
          'cash_movements', 'audit_log', 'loyalty_points',
          'loyalty_transactions', 'loyalty_rewards', 'expenses',
          'expense_categories', 'returns', 'return_items',
          'purchases', 'purchase_items', 'discounts', 'coupons',
          'promotions', 'notifications', 'daily_summaries',
        ];
        for (final table in tablesForOrgId) {
          await customStatement(
            'ALTER TABLE $table ADD COLUMN org_id TEXT',
          );
        }
        // إضافة أعمدة إضافية
        await customStatement(
          'ALTER TABLE users ADD COLUMN auth_uid TEXT',
        );
        await customStatement(
          'ALTER TABLE users ADD COLUMN role_id TEXT',
        );
        await customStatement(
          'ALTER TABLE sales ADD COLUMN terminal_id TEXT',
        );
        await customStatement(
          'ALTER TABLE shifts ADD COLUMN terminal_id TEXT',
        );
      }
      // Migration v10 → v11: إضافة جداول المزامنة المتقدمة
      if (from < 11) {
        await m.createTable(syncMetadataTable);
        await m.createTable(stockDeltasTable);
      }
      // Migration v11 → v12: إضافة عمود deleted_at للحذف الناعم (soft delete)
      if (from < 12) {
        final tablesForDeletedAt = [
          'products', 'customers', 'categories', 'suppliers',
          'sales', 'orders', 'purchases', 'returns',
          'expenses', 'accounts', 'discounts', 'coupons',
          'promotions', 'users', 'stores',
        ];
        for (final table in tablesForDeletedAt) {
          await customStatement(
            'ALTER TABLE $table ADD COLUMN deleted_at INTEGER',
          );
        }
      }
      // Migration v12 → v13: H32 - توحيد أنواع أعمدة الكميات إلى REAL
      // لدعم الكميات الكسرية (مثل 0.5 كجم، 1.5 لتر)
      // ملاحظة: SQLite يخزن الأرقام كـ REAL داخلياً، لذا هذه الهجرة تعيد
      // إنشاء الجداول لتحديث تعريف نوع العمود في Drift
      if (from < 13) {
        // sale_items: تغيير qty من INTEGER إلى REAL
        await customStatement('''
          CREATE TABLE sale_items_tmp AS SELECT * FROM sale_items
        ''');
        await customStatement('DROP TABLE sale_items');
        await customStatement('''
          CREATE TABLE sale_items (
            id TEXT NOT NULL PRIMARY KEY,
            sale_id TEXT NOT NULL REFERENCES sales(id) ON DELETE CASCADE,
            product_id TEXT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
            product_name TEXT NOT NULL,
            product_sku TEXT,
            product_barcode TEXT,
            qty REAL NOT NULL,
            unit_price REAL NOT NULL,
            cost_price REAL,
            subtotal REAL NOT NULL,
            discount REAL NOT NULL DEFAULT 0,
            total REAL NOT NULL,
            notes TEXT
          )
        ''');
        await customStatement('''
          INSERT INTO sale_items SELECT * FROM sale_items_tmp
        ''');
        await customStatement('DROP TABLE sale_items_tmp');
        await customStatement('CREATE INDEX idx_sale_items_sale_id ON sale_items (sale_id)');
        await customStatement('CREATE INDEX idx_sale_items_product_id ON sale_items (product_id)');

        // inventory_movements: تغيير qty, previous_qty, new_qty من INTEGER إلى REAL
        await customStatement('''
          CREATE TABLE inventory_movements_tmp AS SELECT * FROM inventory_movements
        ''');
        await customStatement('DROP TABLE inventory_movements');
        await customStatement('''
          CREATE TABLE inventory_movements (
            id TEXT NOT NULL PRIMARY KEY,
            org_id TEXT,
            product_id TEXT NOT NULL REFERENCES products(id),
            store_id TEXT NOT NULL REFERENCES stores(id),
            type TEXT NOT NULL,
            qty REAL NOT NULL,
            previous_qty REAL NOT NULL,
            new_qty REAL NOT NULL,
            reference_type TEXT,
            reference_id TEXT,
            reason TEXT,
            notes TEXT,
            user_id TEXT,
            created_at INTEGER NOT NULL,
            synced_at INTEGER
          )
        ''');
        await customStatement('''
          INSERT INTO inventory_movements SELECT * FROM inventory_movements_tmp
        ''');
        await customStatement('DROP TABLE inventory_movements_tmp');
        await customStatement('CREATE INDEX idx_inventory_product_id ON inventory_movements (product_id)');
        await customStatement('CREATE INDEX idx_inventory_store_id ON inventory_movements (store_id)');
        await customStatement('CREATE INDEX idx_inventory_created_at ON inventory_movements (created_at)');
        await customStatement('CREATE INDEX idx_inventory_type ON inventory_movements (type)');
        await customStatement('CREATE INDEX idx_inventory_reference ON inventory_movements (reference_type, reference_id)');
        await customStatement('CREATE INDEX idx_inventory_synced_at ON inventory_movements (synced_at)');

        // purchase_items: تغيير qty, received_qty من INTEGER إلى REAL
        await customStatement('''
          CREATE TABLE purchase_items_tmp AS SELECT * FROM purchase_items
        ''');
        await customStatement('DROP TABLE purchase_items');
        await customStatement('''
          CREATE TABLE purchase_items (
            id TEXT NOT NULL PRIMARY KEY,
            org_id TEXT,
            purchase_id TEXT NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
            product_id TEXT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
            product_name TEXT NOT NULL,
            product_barcode TEXT,
            qty REAL NOT NULL,
            received_qty REAL NOT NULL DEFAULT 0,
            unit_cost REAL NOT NULL,
            total REAL NOT NULL
          )
        ''');
        await customStatement('''
          INSERT INTO purchase_items SELECT * FROM purchase_items_tmp
        ''');
        await customStatement('DROP TABLE purchase_items_tmp');
        await customStatement('CREATE INDEX idx_purchase_items_purchase_id ON purchase_items (purchase_id)');
        await customStatement('CREATE INDEX idx_purchase_items_product_id ON purchase_items (product_id)');

        // return_items: تغيير qty من INTEGER إلى REAL
        await customStatement('''
          CREATE TABLE return_items_tmp AS SELECT * FROM return_items
        ''');
        await customStatement('DROP TABLE return_items');
        await customStatement('''
          CREATE TABLE return_items (
            id TEXT NOT NULL PRIMARY KEY,
            org_id TEXT,
            return_id TEXT NOT NULL REFERENCES returns(id) ON DELETE CASCADE,
            sale_item_id TEXT,
            product_id TEXT NOT NULL REFERENCES products(id) ON DELETE RESTRICT,
            product_name TEXT NOT NULL,
            qty REAL NOT NULL,
            unit_price REAL NOT NULL,
            refund_amount REAL NOT NULL
          )
        ''');
        await customStatement('''
          INSERT INTO return_items SELECT * FROM return_items_tmp
        ''');
        await customStatement('DROP TABLE return_items_tmp');
        await customStatement('CREATE INDEX idx_return_items_return_id ON return_items (return_id)');
        await customStatement('CREATE INDEX idx_return_items_product_id ON return_items (product_id)');

        // stock_deltas: تغيير quantity_change من INTEGER إلى REAL
        await customStatement('''
          CREATE TABLE stock_deltas_tmp AS SELECT * FROM stock_deltas
        ''');
        await customStatement('DROP TABLE stock_deltas');
        await customStatement('''
          CREATE TABLE stock_deltas (
            id TEXT NOT NULL PRIMARY KEY,
            product_id TEXT NOT NULL,
            store_id TEXT NOT NULL,
            org_id TEXT,
            quantity_change REAL NOT NULL,
            device_id TEXT NOT NULL,
            operation_type TEXT NOT NULL,
            reference_id TEXT,
            sync_status TEXT NOT NULL DEFAULT 'pending',
            created_at INTEGER NOT NULL,
            synced_at INTEGER
          )
        ''');
        await customStatement('''
          INSERT INTO stock_deltas SELECT * FROM stock_deltas_tmp
        ''');
        await customStatement('DROP TABLE stock_deltas_tmp');
        await customStatement('CREATE INDEX idx_stock_deltas_product ON stock_deltas (product_id)');
        await customStatement('CREATE INDEX idx_stock_deltas_sync_status ON stock_deltas (sync_status)');
        await customStatement('CREATE INDEX idx_stock_deltas_device ON stock_deltas (device_id)');
        await customStatement('CREATE INDEX idx_stock_deltas_product_sync ON stock_deltas (product_id, sync_status)');
      }
    },
    beforeOpen: (details) async {
      // تفعيل المفاتيح الأجنبية (M31 fix)
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// تهيئة FTS (للاستدعاء بعد إنشاء قاعدة البيانات)
  Future<void> initializeFts() async {
    await ftsService.createFtsTable();
  }

  /// إعادة بناء فهرس FTS
  Future<void> rebuildFtsIndex() async {
    await ftsService.rebuildFtsIndex();
  }

  // ==========================================================================
  // Transactional compound operations (C09 fix)
  // ==========================================================================

  /// إنشاء عملية بيع كاملة في معاملة واحدة (sale + items + stock update)
  Future<void> createSaleTransaction({
    required SalesTableCompanion sale,
    required List<SaleItemsTableCompanion> items,
    required List<MapEntry<String, double>> stockDeductions,
    String? accountId,
    double? creditAmount,
  }) {
    return transaction(() async {
      await salesDao.insertSale(sale);
      await saleItemsDao.insertItems(items);

      // خصم المخزون
      for (final entry in stockDeductions) {
        await customStatement(
          'UPDATE products SET stock_qty = stock_qty - ? WHERE id = ?',
          [Variable.withReal(entry.value), Variable.withString(entry.key)],
        );
      }

      // تحديث حساب العميل (إذا كان بيع آجل)
      if (accountId != null && creditAmount != null) {
        await accountsDao.addToBalance(accountId, creditAmount);
      }
    });
  }

  /// إنشاء عملية إرجاع كاملة في معاملة واحدة
  Future<void> createReturnTransaction({
    required ReturnsTableCompanion returnData,
    required List<ReturnItemsTableCompanion> items,
    required List<MapEntry<String, double>> stockAdditions,
    String? accountId,
    double? refundAmount,
  }) {
    return transaction(() async {
      await returnsDao.insertReturn(returnData);
      await returnsDao.insertReturnItems(items);

      // إعادة المخزون
      for (final entry in stockAdditions) {
        await customStatement(
          'UPDATE products SET stock_qty = stock_qty + ? WHERE id = ?',
          [Variable.withReal(entry.value), Variable.withString(entry.key)],
        );
      }

      // تحديث حساب العميل (إرجاع مبلغ)
      if (accountId != null && refundAmount != null) {
        await accountsDao.subtractFromBalance(accountId, refundAmount);
      }
    });
  }

  /// إلغاء عملية بيع في معاملة واحدة (void sale + restore stock + refund)
  /// ملاحظة: salesDao.voidSale() يستعيد المخزون تلقائياً
  Future<void> voidSaleTransaction({
    required String saleId,
    required List<MapEntry<String, double>> stockRestorations,
    String? accountId,
    double? creditAmount,
  }) {
    return transaction(() async {
      // voidSale يستعيد المخزون تلقائياً من sale_items
      await salesDao.voidSale(saleId);

      // إعادة المبلغ لحساب العميل
      if (accountId != null && creditAmount != null) {
        await accountsDao.subtractFromBalance(accountId, creditAmount);
      }
    });
  }
}
