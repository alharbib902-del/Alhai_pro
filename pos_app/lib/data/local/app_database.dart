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
  int get schemaVersion => 10;

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
      // Migration v9 -> v10: إضافة جداول متعددة المستأجرين + أعمدة org_id
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
}
