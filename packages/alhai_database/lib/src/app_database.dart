import 'package:alhai_core/alhai_core.dart' show MigrationFailedException;
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'tables/tables.dart';
import 'connection.dart';
import 'daos/daos.dart';
import 'fts/products_fts.dart';
import 'services/database_backup_service.dart';

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
    // كتالوج المنظمة المركزي
    OrgProductsTable,
    // الفواتير الرسمية
    InvoicesTable,
    // طابور ZATCA offline + dead-letter
    ZatcaOfflineQueueTable,
    ZatcaDeadLetterTable,
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
    // DAO كتالوج المنظمة
    OrgProductsDao,
    // DAO نقل المخزون
    StockTransfersDao,
    // DAO الفواتير
    InvoicesDao,
    // DAO طابور ZATCA offline
    ZatcaOfflineQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// إنشاء قاعدة البيانات مع الاتصال الافتراضي
  AppDatabase() : super(openConnection());

  /// إنشاء قاعدة البيانات مع اتصال مخصص (للاختبارات)
  AppDatabase.forTesting(super.e);

  /// خدمة البحث السريع FTS
  late final ProductsFtsService ftsService = ProductsFtsService(this);

  /// خدمة النسخ الاحتياطي التلقائي
  late final DatabaseBackupService backupService = DatabaseBackupService(this);

  @override
  int get schemaVersion => 44;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      // إنشاء جدول FTS للبحث السريع
      await ftsService.createFtsTable();
      // إنشاء جدول سجل الهجرات
      await _createMigrationHistoryTable();
      // ZATCA append-only triggers (v23) — createAll() only creates tables,
      // custom triggers must be applied explicitly.
      await _createAppendOnlyTriggers();
      // تسجيل الإنشاء الأولي
      await _recordMigrationHistory(
        version: schemaVersion,
        durationMs: 0,
        success: true,
      );
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Downgrade guard: reject going backwards
      if (from > to) {
        debugPrint(
          '[Migration] CRITICAL: downgrade attempt v$from -> v$to blocked',
        );
        throw UnsupportedError(
          'Database downgrade from v$from to v$to is not supported. '
          'This indicates an app rollback on a newer database schema.',
        );
      }

      final migrationStartTime = DateTime.now();

      // نسخ احتياطي تلقائي قبل أي ترحيل للـ schema
      String? backupId;
      try {
        final info = await backupService.createPreMigrationBackup(from);
        backupId = info.id;
      } catch (e) {
        // لا نمنع الترحيل إذا فشل النسخ الاحتياطي
        debugPrint('[Backup] Pre-migration backup failed: $e');
      }

      // إنشاء جدول سجل الهجرات (إن لم يكن موجوداً)
      await _createMigrationHistoryTable();

      // فحص سلامة قاعدة البيانات قبل الهجرة
      final preIntegrityOk = await _checkDatabaseIntegrity();
      if (!preIntegrityOk) {
        const errorMsg =
            'Database integrity check failed BEFORE migration. '
            'Aborting migration to prevent further corruption.';
        debugPrint('[Migration] $errorMsg');
        await _recordMigrationHistory(
          version: from,
          durationMs: 0,
          success: false,
          errorMessage: errorMsg,
        );
        return;
      }

      debugPrint(
        '[Migration] Pre-migration integrity check passed. '
        'Upgrading v$from -> v$to...',
      );

      // تنفيذ كل هجرة على حدة مع تسجيل النتيجة
      for (var version = from + 1; version <= to; version++) {
        final stepStart = DateTime.now();
        try {
          debugPrint('[Migration] Migrating v${version - 1} -> v$version...');
          await _runMigrationStep(m, version);
          final stepDuration = DateTime.now()
              .difference(stepStart)
              .inMilliseconds;
          debugPrint('[Migration] v$version complete (${stepDuration}ms)');
          await _recordMigrationHistory(
            version: version,
            durationMs: stepDuration,
            success: true,
          );
        } catch (e, stackTrace) {
          final stepDuration = DateTime.now()
              .difference(stepStart)
              .inMilliseconds;
          debugPrint('[Migration] v$version FAILED (${stepDuration}ms): $e');
          debugPrint('[Migration] Stack trace: $stackTrace');
          debugPrint('[Migration] Pre-migration backup available: $backupId');
          await _recordMigrationHistory(
            version: version,
            durationMs: stepDuration,
            success: false,
            errorMessage: e.toString(),
          );
          // Wrap with MigrationFailedException so callers know about
          // the backup they can use for recovery.
          throw MigrationFailedException(
            fromVersion: from,
            toVersion: to,
            backupPath: backupId,
            originalError: e,
          );
        }
      }

      // فحص سلامة قاعدة البيانات بعد الهجرة
      final postIntegrityOk = await _checkDatabaseIntegrity();
      if (!postIntegrityOk) {
        debugPrint(
          '[Migration] WARNING: Post-migration integrity check failed!',
        );
      } else {
        debugPrint('[Migration] Post-migration integrity check passed.');
      }

      // التحقق من وجود الجداول المتوقعة
      final schemaValid = await verifySchema();
      if (!schemaValid) {
        debugPrint(
          '[Migration] WARNING: Schema verification found missing tables!',
        );
      } else {
        debugPrint(
          '[Migration] Schema verification passed '
          '- all expected tables present.',
        );
      }

      // نسخ احتياطي بعد نجاح الترحيل
      try {
        await backupService.createPostMigrationBackup(to);
      } catch (e) {
        debugPrint('[Backup] Post-migration backup failed: $e');
      }

      final totalDuration = DateTime.now()
          .difference(migrationStartTime)
          .inMilliseconds;
      debugPrint(
        '[Migration] Full migration v$from -> v$to '
        'completed in ${totalDuration}ms',
      );
    },
    beforeOpen: (details) async {
      // تفعيل المفاتيح الأجنبية (M31 fix)
      await customStatement('PRAGMA foreign_keys = ON');
      // تحسينات الأداء
      await customStatement('PRAGMA cache_size = -8000'); // 8MB cache
      // Wait 5s instead of failing immediately on database lock (C09)
      await customStatement('PRAGMA busy_timeout = 5000');

      // تنظيف تلقائي للبيانات القديمة (عند فتح القاعدة)
      await _autoCleanup();

      // استعادة عناصر المزامنة المعلقة (من تعطل سابق)
      final resetCount = await syncQueueDao.resetStuckItems();
      if (resetCount > 0) {
        debugPrint('[DB] Reset $resetCount stuck sync items back to pending');
      }

      // بدء النسخ الاحتياطي الدوري التلقائي (كل ساعتين)
      backupService.startPeriodicBackup();
    },
  );

  // ==========================================================================
  // Migration steps - كل خطوة هجرة منفصلة
  // ==========================================================================

  /// تنفيذ خطوة هجرة واحدة حسب رقم الإصدار المستهدف
  Future<void> _runMigrationStep(Migrator m, int targetVersion) async {
    switch (targetVersion) {
      case 2:
        // Migration v1 -> v2: إضافة جدول transactions
        await m.createTable(transactionsTable);
      case 3:
        // Migration v2 -> v3: إضافة جداول orders و order_items
        await m.createTable(ordersTable);
        await m.createTable(orderItemsTable);
      case 4:
        // Migration v3 -> v4: إضافة جدول audit_log
        await m.createTable(auditLogTable);
      case 5:
        // Migration v4 -> v5: إضافة جدول categories
        await m.createTable(categoriesTable);
      case 6:
        // Migration v5 -> v6: إضافة جداول نظام الولاء
        await m.createTable(loyaltyPointsTable);
        await m.createTable(loyaltyTransactionsTable);
        await m.createTable(loyaltyRewardsTable);
      case 7:
        // Migration v6 -> v7: إضافة FTS5 للبحث السريع
        await ftsService.createFtsTable();
        await ftsService.rebuildFtsIndex();
      case 8:
        // Migration v7 -> v8: إضافة جميع الجداول الجديدة
        // (المتاجر، المستخدمين، العملاء، الموردين، إلخ)
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
      case 9:
        // Migration v8 -> v9: إضافة جداول واتساب
        await m.createTable(whatsAppMessagesTable);
        await m.createTable(whatsAppTemplatesTable);
      case 10:
        // Migration v9 -> v10: إضافة جداول متعددة المستأجرين + أعمدة org_id
        await _migrateToV10(m);
      case 11:
        // Migration v10 -> v11: إضافة جداول المزامنة المتقدمة
        await m.createTable(syncMetadataTable);
        await m.createTable(stockDeltasTable);
      case 12:
        // Migration v11 -> v12: إضافة عمود deleted_at للحذف الناعم (soft delete)
        await _migrateToV12();
      case 13:
        // Migration v12 -> v13: H32 - توحيد أنواع أعمدة الكميات إلى REAL
        // لدعم الكميات الكسرية (مثل 0.5 كجم، 1.5 لتر)
        // ملاحظة: SQLite يخزن الأرقام كـ REAL داخلياً، لذا هذه الهجرة تعيد
        // إنشاء الجداول لتحديث تعريف نوع العمود في Drift
        await _migrateToV13();
      case 14:
        // Migration v13 -> v14: كتالوج مركزي + طلبات أونلاين + صور هجينة
        await _migrateToV14(m);
      case 15:
        // Migration v14 -> v15: نظام الفواتير الرسمية + أرشفة PDF
        await m.createTable(invoicesTable);
      case 16:
        // Migration v15 -> v16: تفصيل مبالغ الدفع (نقد/بطاقة/آجل)
        await customStatement('ALTER TABLE sales ADD COLUMN cash_amount REAL');
        await customStatement('ALTER TABLE sales ADD COLUMN card_amount REAL');
        await customStatement(
          'ALTER TABLE sales ADD COLUMN credit_amount REAL',
        );
      case 17:
        // Migration v16 -> v17: إضافة أعمدة status و company_type للمؤسسات
        await customStatement(
          "ALTER TABLE organizations ADD COLUMN status TEXT NOT NULL DEFAULT 'trial'",
        );
        await customStatement(
          "ALTER TABLE organizations ADD COLUMN company_type TEXT NOT NULL DEFAULT 'agency'",
        );
      case 18:
        // Migration v17 -> v18: جعل عمود store_id في جدول users قابل لـ null
        // المستخدمون على مستوى المؤسسة (org-level admins) قد لا ينتمون لمتجر محدد
        // SQLite لا يدعم ALTER COLUMN، لذا نعيد إنشاء الجدول
        await customStatement('''
          CREATE TABLE users_new (
            id TEXT NOT NULL PRIMARY KEY,
            org_id TEXT,
            store_id TEXT,
            name TEXT NOT NULL,
            phone TEXT,
            email TEXT,
            pin TEXT,
            auth_uid TEXT,
            role TEXT NOT NULL DEFAULT 'cashier',
            role_id TEXT,
            avatar TEXT,
            is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
            last_login_at INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER,
            synced_at INTEGER,
            deleted_at INTEGER
          )
        ''');
        await customStatement('''
          INSERT INTO users_new SELECT * FROM users
        ''');
        await customStatement('DROP TABLE users');
        await customStatement('ALTER TABLE users_new RENAME TO users');
        // إعادة إنشاء الفهارس
        await customStatement(
          'CREATE INDEX idx_users_store_id ON users (store_id)',
        );
        await customStatement('CREATE INDEX idx_users_phone ON users (phone)');
        await customStatement(
          'CREATE INDEX idx_users_is_active ON users (is_active)',
        );
      case 19:
        // Migration v18 -> v19: تحويل stock_qty و min_qty من INTEGER إلى REAL
        // لدعم الكميات الكسرية (مثل 2.5 كجم أرز)
        // SQLite لا يدعم ALTER COLUMN TYPE لذا نعيد إنشاء الجدول
        await _migrateToV19();
      case 20:
        // Migration v19 -> v20: Add trigger-based FK validation
        // SQLite doesn't support ALTER TABLE ADD CONSTRAINT for FK,
        // so we use triggers to validate referential integrity.
        await _migrateToV20();
      case 21:
        // Migration v20 -> v21: Enhance sync metadata + composite index
        // 1. Add conflict tracking columns to sync_metadata
        await customStatement(
          'ALTER TABLE sync_metadata ADD COLUMN conflict_count INTEGER NOT NULL DEFAULT 0',
        );
        await customStatement(
          'ALTER TABLE sync_metadata ADD COLUMN last_conflict_at INTEGER',
        );
        await customStatement(
          'ALTER TABLE sync_metadata ADD COLUMN requires_manual_review INTEGER NOT NULL DEFAULT 0',
        );
        // 2. Add composite index for orders (customer + createdAt)
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_orders_customer_created ON orders (customer_id, created_at)',
        );
      case 22:
        // Migration v21 -> v22: Add shift_id column to sales for shift-sale linkage
        await customStatement(
          'ALTER TABLE sales ADD COLUMN shift_id TEXT REFERENCES shifts(id) ON DELETE SET NULL',
        );

        // Add FK validation triggers for stock_deltas table
        // SQLite cannot ALTER TABLE to add FKs, so we use triggers (same pattern as v20).
        //
        // productId -> products.id (SET NULL behavior: nullify on product delete)
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS fk_stock_deltas_product_id
          BEFORE INSERT ON stock_deltas
          BEGIN
            SELECT RAISE(ABORT, 'FK violation: product_id not found in products')
            WHERE NEW.product_id IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM products WHERE id = NEW.product_id);
          END
        ''');
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS fk_stock_deltas_product_id_update
          BEFORE UPDATE OF product_id ON stock_deltas
          BEGIN
            SELECT RAISE(ABORT, 'FK violation: product_id not found in products')
            WHERE NEW.product_id IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM products WHERE id = NEW.product_id);
          END
        ''');
        // SET NULL on product delete: nullify product_id in stock_deltas
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS fk_stock_deltas_product_id_cascade
          AFTER DELETE ON products
          BEGIN
            UPDATE stock_deltas SET product_id = NULL WHERE product_id = OLD.id;
          END
        ''');

        // storeId -> stores.id (RESTRICT behavior: block store delete if deltas exist)
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS fk_stock_deltas_store_id
          BEFORE INSERT ON stock_deltas
          BEGIN
            SELECT RAISE(ABORT, 'FK violation: store_id not found in stores')
            WHERE NEW.store_id IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM stores WHERE id = NEW.store_id);
          END
        ''');
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS fk_stock_deltas_store_id_update
          BEFORE UPDATE OF store_id ON stock_deltas
          BEGIN
            SELECT RAISE(ABORT, 'FK violation: store_id not found in stores')
            WHERE NEW.store_id IS NOT NULL
              AND NOT EXISTS (SELECT 1 FROM stores WHERE id = NEW.store_id);
          END
        ''');
        // RESTRICT on store delete: block if stock_deltas reference this store
        await customStatement('''
          CREATE TRIGGER IF NOT EXISTS fk_stock_deltas_store_id_restrict
          BEFORE DELETE ON stores
          BEGIN
            SELECT RAISE(ABORT, 'FK violation: cannot delete store with existing stock_deltas')
            WHERE EXISTS (SELECT 1 FROM stock_deltas WHERE store_id = OLD.id);
          END
        ''');

        // Make product_id nullable for existing rows (SQLite requires table rebuild)
        // Since ALTER COLUMN is not supported, we add a new nullable column and migrate data.
        // However, this is risky for existing data. The trigger approach above handles
        // referential integrity without changing the column type, so we skip the rebuild.
        // New installs get the correct nullable column from Drift's createAll().
        debugPrint(
          '[Migration v22] sales.shift_id + stock_deltas FK triggers created',
        );
      case 23:
        // Migration v22 -> v23: ZATCA append-only compliance
        // 1. Add reference_invoice_id for Credit/Debit Notes
        await customStatement(
          'ALTER TABLE sales ADD COLUMN reference_invoice_id TEXT',
        );
        // 2. Append-only triggers (shared with onCreate)
        await _createAppendOnlyTriggers();
        debugPrint(
          '[Migration v23] ZATCA append-only triggers + '
          'reference_invoice_id created',
        );

      // ────────────────────────────────────────────────────────────────
      // v24 → v37: version alignment with Supabase.
      //
      // Per `docs/schema_alignment_v23_to_v37_plan.md`, the audit confirmed
      // Drift was the source of truth for the columns Supabase added in
      // v29/v30 (shifts.orgId, returns.orgId, daily_summaries.totalSales,
      // etc. — all already present on the Drift side). The remaining
      // migrations v24..v37 are RLS / RPC / server-only — no client
      // schema change.
      //
      // The no-op cases below exist only so `_runMigrationStep`'s linear
      // loop (`for version in from+1..to`) does not fall into `default`
      // and log "Unknown migration version". The version pointer advances
      // and `_recordMigrationHistory` captures each step for audit.
      //
      // If a future Supabase migration introduces a real client-side
      // column, replace the matching case body with the appropriate
      // `m.addColumn(...)` / `customStatement(...)` call.
      //
      // Known follow-ups (tracked in the plan, not implemented here):
      //  - v35 `audit_log` naming collision with Super Admin audit shape.
      //  - `daily_summaries.total_sales` INT vs DOUBLE semantic drift.
      // ────────────────────────────────────────────────────────────────
      case 24:
      case 25:
      case 26:
      case 27:
      case 28:
      case 29:
      case 30:
      case 31:
      case 32:
      case 33:
      case 34:
      case 35:
      case 36:
      case 37:
        debugPrint(
          '[Migration v$targetVersion] Server-only change — '
          'no Drift schema update required.',
        );

      case 38:
        // v38: طابور ZATCA offline الـ Drift-backed (active queue)
        // يحل محل SharedPreferences JSON-blob.
        await m.createTable(zatcaOfflineQueueTable);
        debugPrint(
          '[Migration v38] Created zatca_offline_queue table',
        );

      case 39:
        // v39: جدول dead-letter منفصل لفواتير ZATCA المستنفدة المحاولات
        // row-move pattern: DAO.moveToDeadLetter() ينقل الصف atomic من
        // zatca_offline_queue → zatca_dead_letter عند exceed maxRetries.
        await m.createTable(zatcaDeadLetterTable);
        debugPrint(
          '[Migration v39] Created zatca_dead_letter table',
        );

      case 40:
        // v40: C-4 Stage A — money columns على discounts + org_products
        // RealColumn → IntColumn (cents) ROUND_HALF_UP
        // الجداول فارغة (server side verified قبل apply) — لا يوجد فقدان بيانات
        await m.alterTable(
          TableMigration(
            discountsTable,
            columnTransformer: {
              discountsTable.value: const CustomExpression<int>(
                'CAST(ROUND(value * 100) AS INTEGER)',
              ),
              discountsTable.minPurchase: const CustomExpression<int>(
                'CAST(ROUND(min_purchase * 100) AS INTEGER)',
              ),
              discountsTable.maxDiscount: const CustomExpression<int>(
                'CAST(ROUND(max_discount * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            orgProductsTable,
            columnTransformer: {
              orgProductsTable.defaultPrice: const CustomExpression<int>(
                'CAST(ROUND(default_price * 100) AS INTEGER)',
              ),
              orgProductsTable.costPrice: const CustomExpression<int>(
                'CAST(ROUND(cost_price * 100) AS INTEGER)',
              ),
            },
          ),
        );
        debugPrint(
          '[Migration v40] Converted discounts + org_products money columns '
          'to INTEGER cents (C-4 Stage A)',
        );

      case 41:
        // v41: C-4 Stage B — products.price + cost_price
        // RealColumn → IntColumn (cents) ROUND_HALF_UP
        // 9742 rows on server, 0 fractional cents verified pre-apply
        await m.alterTable(
          TableMigration(
            productsTable,
            columnTransformer: {
              productsTable.price: const CustomExpression<int>(
                'CAST(ROUND(price * 100) AS INTEGER)',
              ),
              productsTable.costPrice: const CustomExpression<int>(
                'CAST(ROUND(cost_price * 100) AS INTEGER)',
              ),
            },
          ),
        );
        debugPrint(
          '[Migration v41] Converted products money columns '
          'to INTEGER cents (C-4 Stage B)',
        );

      case 42:
        // v42: C-4 Session 2 — invoices (6) + sale_items (5) + held_invoices (3)
        // RealColumn → IntColumn (cents) ROUND_HALF_UP
        // invoices + held_invoices: 0 rows on server (empty).
        // sale_items: 30 rows, 0 real fractional cents (FP artifacts only).
        // Verified via tolerance-based Appendix B audit on 2026-04-22.
        await m.alterTable(
          TableMigration(
            invoicesTable,
            columnTransformer: {
              invoicesTable.subtotal: const CustomExpression<int>(
                'CAST(ROUND(subtotal * 100) AS INTEGER)',
              ),
              invoicesTable.discount: const CustomExpression<int>(
                'CAST(ROUND(discount * 100) AS INTEGER)',
              ),
              invoicesTable.taxAmount: const CustomExpression<int>(
                'CAST(ROUND(tax_amount * 100) AS INTEGER)',
              ),
              invoicesTable.total: const CustomExpression<int>(
                'CAST(ROUND(total * 100) AS INTEGER)',
              ),
              invoicesTable.amountPaid: const CustomExpression<int>(
                'CAST(ROUND(amount_paid * 100) AS INTEGER)',
              ),
              invoicesTable.amountDue: const CustomExpression<int>(
                'CAST(ROUND(amount_due * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            saleItemsTable,
            columnTransformer: {
              saleItemsTable.unitPrice: const CustomExpression<int>(
                'CAST(ROUND(unit_price * 100) AS INTEGER)',
              ),
              saleItemsTable.costPrice: const CustomExpression<int>(
                'CAST(ROUND(cost_price * 100) AS INTEGER)',
              ),
              saleItemsTable.subtotal: const CustomExpression<int>(
                'CAST(ROUND(subtotal * 100) AS INTEGER)',
              ),
              saleItemsTable.discount: const CustomExpression<int>(
                'CAST(ROUND(discount * 100) AS INTEGER)',
              ),
              saleItemsTable.total: const CustomExpression<int>(
                'CAST(ROUND(total * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            heldInvoicesTable,
            columnTransformer: {
              heldInvoicesTable.subtotal: const CustomExpression<int>(
                'CAST(ROUND(subtotal * 100) AS INTEGER)',
              ),
              heldInvoicesTable.discount: const CustomExpression<int>(
                'CAST(ROUND(discount * 100) AS INTEGER)',
              ),
              heldInvoicesTable.total: const CustomExpression<int>(
                'CAST(ROUND(total * 100) AS INTEGER)',
              ),
            },
          ),
        );
        debugPrint(
          '[Migration v42] Converted invoices+sale_items+held_invoices money '
          'columns to INTEGER cents (C-4 Session 2)',
        );

      case 43:
        // v43: C-4 Session 3 — shifts (6) + cash_movements (1) + sales (9)
        // RealColumn → IntColumn (cents) ROUND_HALF_UP
        // shifts + cash_movements: 0 rows on server (empty).
        // sales: 11 rows (5 have amount_received).
        //   - Audit flagged 10 tax + 8 total rows with real fractional-cent
        //     values (e.g. subtotal * 0.15 stored unrounded). Max drift ≤0.005
        //     SAR per row; ROUND_HALF_UP keeps invariant total==subtotal+tax.
        await m.alterTable(
          TableMigration(
            shiftsTable,
            columnTransformer: {
              shiftsTable.openingCash: const CustomExpression<int>(
                'CAST(ROUND(opening_cash * 100) AS INTEGER)',
              ),
              shiftsTable.closingCash: const CustomExpression<int>(
                'CAST(ROUND(closing_cash * 100) AS INTEGER)',
              ),
              shiftsTable.expectedCash: const CustomExpression<int>(
                'CAST(ROUND(expected_cash * 100) AS INTEGER)',
              ),
              shiftsTable.difference: const CustomExpression<int>(
                'CAST(ROUND(difference * 100) AS INTEGER)',
              ),
              shiftsTable.totalSalesAmount: const CustomExpression<int>(
                'CAST(ROUND(total_sales_amount * 100) AS INTEGER)',
              ),
              shiftsTable.totalRefundsAmount: const CustomExpression<int>(
                'CAST(ROUND(total_refunds_amount * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            cashMovementsTable,
            columnTransformer: {
              cashMovementsTable.amount: const CustomExpression<int>(
                'CAST(ROUND(amount * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            salesTable,
            columnTransformer: {
              salesTable.subtotal: const CustomExpression<int>(
                'CAST(ROUND(subtotal * 100) AS INTEGER)',
              ),
              salesTable.discount: const CustomExpression<int>(
                'CAST(ROUND(discount * 100) AS INTEGER)',
              ),
              salesTable.tax: const CustomExpression<int>(
                'CAST(ROUND(tax * 100) AS INTEGER)',
              ),
              salesTable.total: const CustomExpression<int>(
                'CAST(ROUND(total * 100) AS INTEGER)',
              ),
              salesTable.amountReceived: const CustomExpression<int>(
                'CAST(ROUND(amount_received * 100) AS INTEGER)',
              ),
              salesTable.changeAmount: const CustomExpression<int>(
                'CAST(ROUND(change_amount * 100) AS INTEGER)',
              ),
              salesTable.cashAmount: const CustomExpression<int>(
                'CAST(ROUND(cash_amount * 100) AS INTEGER)',
              ),
              salesTable.cardAmount: const CustomExpression<int>(
                'CAST(ROUND(card_amount * 100) AS INTEGER)',
              ),
              salesTable.creditAmount: const CustomExpression<int>(
                'CAST(ROUND(credit_amount * 100) AS INTEGER)',
              ),
            },
          ),
        );
        debugPrint(
          '[Migration v43] Converted shifts+cash_movements+sales money '
          'columns to INTEGER cents (C-4 Session 3)',
        );

      case 44:
        // v44: C-4 Session 4 — analytics tables money columns.
        // 27 money cols across 11 tables (Real → Int cents ROUND_HALF_UP):
        //   accounts (2), coupons (2), daily_summaries (8), expenses (1),
        //   loyalty_rewards (2), purchase_items (2), purchases (4),
        //   return_items (2), returns (1), suppliers (1), transactions (2)
        // Pre-apply audit: ALL 11 tables are empty on server (Stage A-style).
        await m.alterTable(
          TableMigration(
            accountsTable,
            columnTransformer: {
              accountsTable.balance: const CustomExpression<int>(
                'CAST(ROUND(balance * 100) AS INTEGER)',
              ),
              accountsTable.creditLimit: const CustomExpression<int>(
                'CAST(ROUND(credit_limit * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            expensesTable,
            columnTransformer: {
              expensesTable.amount: const CustomExpression<int>(
                'CAST(ROUND(amount * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            purchasesTable,
            columnTransformer: {
              purchasesTable.subtotal: const CustomExpression<int>(
                'CAST(ROUND(subtotal * 100) AS INTEGER)',
              ),
              purchasesTable.tax: const CustomExpression<int>(
                'CAST(ROUND(tax * 100) AS INTEGER)',
              ),
              purchasesTable.discount: const CustomExpression<int>(
                'CAST(ROUND(discount * 100) AS INTEGER)',
              ),
              purchasesTable.total: const CustomExpression<int>(
                'CAST(ROUND(total * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            purchaseItemsTable,
            columnTransformer: {
              purchaseItemsTable.unitCost: const CustomExpression<int>(
                'CAST(ROUND(unit_cost * 100) AS INTEGER)',
              ),
              purchaseItemsTable.total: const CustomExpression<int>(
                'CAST(ROUND(total * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            returnsTable,
            columnTransformer: {
              returnsTable.totalRefund: const CustomExpression<int>(
                'CAST(ROUND(total_refund * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            returnItemsTable,
            columnTransformer: {
              returnItemsTable.unitPrice: const CustomExpression<int>(
                'CAST(ROUND(unit_price * 100) AS INTEGER)',
              ),
              returnItemsTable.refundAmount: const CustomExpression<int>(
                'CAST(ROUND(refund_amount * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            dailySummariesTable,
            columnTransformer: {
              dailySummariesTable.totalSalesAmount: const CustomExpression<int>(
                'CAST(ROUND(total_sales_amount * 100) AS INTEGER)',
              ),
              dailySummariesTable.totalOrdersAmount:
                  const CustomExpression<int>(
                    'CAST(ROUND(total_orders_amount * 100) AS INTEGER)',
                  ),
              dailySummariesTable.totalRefundsAmount:
                  const CustomExpression<int>(
                    'CAST(ROUND(total_refunds_amount * 100) AS INTEGER)',
                  ),
              dailySummariesTable.totalExpenses: const CustomExpression<int>(
                'CAST(ROUND(total_expenses * 100) AS INTEGER)',
              ),
              dailySummariesTable.cashTotal: const CustomExpression<int>(
                'CAST(ROUND(cash_total * 100) AS INTEGER)',
              ),
              dailySummariesTable.cardTotal: const CustomExpression<int>(
                'CAST(ROUND(card_total * 100) AS INTEGER)',
              ),
              dailySummariesTable.creditTotal: const CustomExpression<int>(
                'CAST(ROUND(credit_total * 100) AS INTEGER)',
              ),
              dailySummariesTable.netProfit: const CustomExpression<int>(
                'CAST(ROUND(net_profit * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            transactionsTable,
            columnTransformer: {
              transactionsTable.amount: const CustomExpression<int>(
                'CAST(ROUND(amount * 100) AS INTEGER)',
              ),
              transactionsTable.balanceAfter: const CustomExpression<int>(
                'CAST(ROUND(balance_after * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            suppliersTable,
            columnTransformer: {
              suppliersTable.balance: const CustomExpression<int>(
                'CAST(ROUND(balance * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            loyaltyRewardsTable,
            columnTransformer: {
              loyaltyRewardsTable.rewardValue: const CustomExpression<int>(
                'CAST(ROUND(reward_value * 100) AS INTEGER)',
              ),
              loyaltyRewardsTable.minPurchase: const CustomExpression<int>(
                'CAST(ROUND(min_purchase * 100) AS INTEGER)',
              ),
            },
          ),
        );
        await m.alterTable(
          TableMigration(
            couponsTable,
            columnTransformer: {
              couponsTable.value: const CustomExpression<int>(
                'CAST(ROUND(value * 100) AS INTEGER)',
              ),
              couponsTable.minPurchase: const CustomExpression<int>(
                'CAST(ROUND(min_purchase * 100) AS INTEGER)',
              ),
            },
          ),
        );
        debugPrint(
          '[Migration v44] Converted analytics tables money columns to '
          'INTEGER cents (C-4 Session 4)',
        );

      default:
        debugPrint('[Migration] Unknown migration version: $targetVersion');
    }
  }

  /// ZATCA append-only triggers — created both in onCreate and migration v23.
  Future<void> _createAppendOnlyTriggers() async {
    // Block financial/identity field changes on completed/paid/refunded sales.
    // Exception: status change to 'voided' is allowed (legitimate accounting
    // cancellation — ZATCA permits voiding as a separate transaction type).
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_sales_append_only
      BEFORE UPDATE ON sales
      FOR EACH ROW
      WHEN OLD.status IN ('completed', 'paid', 'refunded')
        AND NOT (NEW.status = 'voided' AND OLD.status IN ('completed', 'paid'))
        AND (
          NEW.subtotal    IS NOT OLD.subtotal    OR
          NEW.discount    IS NOT OLD.discount    OR
          NEW.tax         IS NOT OLD.tax         OR
          NEW.total       IS NOT OLD.total       OR
          NEW.payment_method IS NOT OLD.payment_method OR
          NEW.is_paid     IS NOT OLD.is_paid     OR
          NEW.amount_received IS NOT OLD.amount_received OR
          NEW.change_amount IS NOT OLD.change_amount OR
          NEW.cash_amount IS NOT OLD.cash_amount OR
          NEW.card_amount IS NOT OLD.card_amount OR
          NEW.credit_amount IS NOT OLD.credit_amount OR
          NEW.customer_id IS NOT OLD.customer_id OR
          NEW.customer_name IS NOT OLD.customer_name OR
          NEW.customer_phone IS NOT OLD.customer_phone OR
          NEW.receipt_no  IS NOT OLD.receipt_no  OR
          NEW.status      IS NOT OLD.status      OR
          NEW.notes       IS NOT OLD.notes       OR
          NEW.channel     IS NOT OLD.channel
        )
      BEGIN
        SELECT RAISE(ABORT,
          'Sales with status completed/paid/refunded are immutable. Use Credit/Debit Note.');
      END
    ''');

    // Prevent DELETE on sale_items of a completed sale.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_sale_items_no_delete
      BEFORE DELETE ON sale_items
      FOR EACH ROW
      WHEN EXISTS (
        SELECT 1 FROM sales
        WHERE id = OLD.sale_id
          AND status IN ('completed', 'paid', 'refunded')
      )
      BEGIN
        SELECT RAISE(ABORT,
          'Cannot delete items of a completed/paid/refunded sale.');
      END
    ''');

    // Prevent UPDATE on sale_items of a completed sale.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS trg_sale_items_no_update
      BEFORE UPDATE ON sale_items
      FOR EACH ROW
      WHEN EXISTS (
        SELECT 1 FROM sales
        WHERE id = OLD.sale_id
          AND status IN ('completed', 'paid', 'refunded')
      )
      BEGIN
        SELECT RAISE(ABORT,
          'Cannot modify items of a completed/paid/refunded sale.');
      END
    ''');
  }

  /// Migration v9 -> v10: إضافة جداول متعددة المستأجرين + أعمدة org_id
  Future<void> _migrateToV10(Migrator m) async {
    // إنشاء الجداول الجديدة
    await m.createTable(organizationsTable);
    await m.createTable(subscriptionsTable);
    await m.createTable(orgMembersTable);
    await m.createTable(userStoresTable);
    await m.createTable(posTerminalsTable);
    // إضافة org_id للجداول الحالية
    final tablesForOrgId = [
      'products',
      'categories',
      'customers',
      'customer_addresses',
      'sales',
      'orders',
      'order_items',
      'inventory_movements',
      'accounts',
      'suppliers',
      'stores',
      'users',
      'shifts',
      'cash_movements',
      'audit_log',
      'loyalty_points',
      'loyalty_transactions',
      'loyalty_rewards',
      'expenses',
      'expense_categories',
      'returns',
      'return_items',
      'purchases',
      'purchase_items',
      'discounts',
      'coupons',
      'promotions',
      'notifications',
      'daily_summaries',
    ];
    for (final table in tablesForOrgId) {
      await customStatement('ALTER TABLE $table ADD COLUMN org_id TEXT');
    }
    // إضافة أعمدة إضافية
    await customStatement('ALTER TABLE users ADD COLUMN auth_uid TEXT');
    await customStatement('ALTER TABLE users ADD COLUMN role_id TEXT');
    await customStatement('ALTER TABLE sales ADD COLUMN terminal_id TEXT');
    await customStatement('ALTER TABLE shifts ADD COLUMN terminal_id TEXT');
  }

  /// Migration v11 -> v12: إضافة عمود deleted_at للحذف الناعم (soft delete)
  Future<void> _migrateToV12() async {
    final tablesForDeletedAt = [
      'products',
      'customers',
      'categories',
      'suppliers',
      'sales',
      'orders',
      'purchases',
      'returns',
      'expenses',
      'accounts',
      'discounts',
      'coupons',
      'promotions',
      'users',
      'stores',
    ];
    for (final table in tablesForDeletedAt) {
      await customStatement('ALTER TABLE $table ADD COLUMN deleted_at INTEGER');
    }
  }

  /// Migration v12 -> v13: توحيد أنواع أعمدة الكميات إلى REAL
  Future<void> _migrateToV13() async {
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
    await customStatement(
      'CREATE INDEX idx_sale_items_sale_id ON sale_items (sale_id)',
    );
    await customStatement(
      'CREATE INDEX idx_sale_items_product_id ON sale_items (product_id)',
    );

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
    await customStatement(
      'CREATE INDEX idx_inventory_product_id ON inventory_movements (product_id)',
    );
    await customStatement(
      'CREATE INDEX idx_inventory_store_id ON inventory_movements (store_id)',
    );
    await customStatement(
      'CREATE INDEX idx_inventory_created_at ON inventory_movements (created_at)',
    );
    await customStatement(
      'CREATE INDEX idx_inventory_type ON inventory_movements (type)',
    );
    await customStatement(
      'CREATE INDEX idx_inventory_reference ON inventory_movements (reference_type, reference_id)',
    );
    await customStatement(
      'CREATE INDEX idx_inventory_synced_at ON inventory_movements (synced_at)',
    );

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
    await customStatement(
      'CREATE INDEX idx_purchase_items_purchase_id ON purchase_items (purchase_id)',
    );
    await customStatement(
      'CREATE INDEX idx_purchase_items_product_id ON purchase_items (product_id)',
    );

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
    await customStatement(
      'CREATE INDEX idx_return_items_return_id ON return_items (return_id)',
    );
    await customStatement(
      'CREATE INDEX idx_return_items_product_id ON return_items (product_id)',
    );

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
    await customStatement(
      'CREATE INDEX idx_stock_deltas_product ON stock_deltas (product_id)',
    );
    await customStatement(
      'CREATE INDEX idx_stock_deltas_sync_status ON stock_deltas (sync_status)',
    );
    await customStatement(
      'CREATE INDEX idx_stock_deltas_device ON stock_deltas (device_id)',
    );
    await customStatement(
      'CREATE INDEX idx_stock_deltas_product_sync ON stock_deltas (product_id, sync_status)',
    );
  }

  /// Migration v13 -> v14: كتالوج مركزي + طلبات أونلاين + صور هجينة
  Future<void> _migrateToV14(Migrator m) async {
    // إنشاء جدول كتالوج المنظمة
    await m.createTable(orgProductsTable);

    // إضافة أعمدة صور المنظمة للمنتجات
    await customStatement(
      'ALTER TABLE products ADD COLUMN org_image_thumbnail TEXT',
    );
    await customStatement(
      'ALTER TABLE products ADD COLUMN org_image_medium TEXT',
    );
    await customStatement(
      'ALTER TABLE products ADD COLUMN org_image_large TEXT',
    );
    await customStatement(
      'ALTER TABLE products ADD COLUMN org_image_hash TEXT',
    );
    await customStatement(
      'ALTER TABLE products ADD COLUMN org_product_id TEXT',
    );

    // إضافة أعمدة الطلب الأونلاين للمنتجات
    await customStatement(
      'ALTER TABLE products ADD COLUMN online_available INTEGER NOT NULL DEFAULT 0',
    );
    await customStatement(
      'ALTER TABLE products ADD COLUMN online_max_qty REAL',
    );
    await customStatement(
      'ALTER TABLE products ADD COLUMN online_reserved_qty REAL NOT NULL DEFAULT 0',
    );
    await customStatement('ALTER TABLE products ADD COLUMN min_alert_qty REAL');
    await customStatement(
      'ALTER TABLE products ADD COLUMN auto_reorder INTEGER NOT NULL DEFAULT 0',
    );
    await customStatement('ALTER TABLE products ADD COLUMN reorder_qty REAL');
    await customStatement('ALTER TABLE products ADD COLUMN turnover_rate REAL');

    // إضافة أعمدة تأكيد التسليم للطلبات
    await customStatement(
      'ALTER TABLE orders ADD COLUMN confirmation_code TEXT',
    );
    await customStatement(
      'ALTER TABLE orders ADD COLUMN confirmation_attempts INTEGER NOT NULL DEFAULT 0',
    );
    await customStatement(
      'ALTER TABLE orders ADD COLUMN auto_reorder_triggered INTEGER NOT NULL DEFAULT 0',
    );

    // إضافة أعمدة نقل المخزون
    await customStatement(
      'ALTER TABLE stock_transfers ADD COLUMN received_by TEXT',
    );
    await customStatement(
      "ALTER TABLE stock_transfers ADD COLUMN approval_status TEXT NOT NULL DEFAULT 'pending'",
    );
    await customStatement(
      'ALTER TABLE stock_transfers ADD COLUMN received_at INTEGER',
    );
  }

  /// Migration v18 -> v19: تحويل stock_qty و min_qty في products من INTEGER إلى REAL
  Future<void> _migrateToV19() async {
    // SQLite لا يدعم ALTER COLUMN TYPE لذا نعيد إنشاء الجدول
    await customStatement('''
      CREATE TABLE products_tmp AS SELECT * FROM products
    ''');
    await customStatement('DROP TABLE products');
    await customStatement('''
      CREATE TABLE products (
        id TEXT NOT NULL PRIMARY KEY,
        org_id TEXT,
        store_id TEXT NOT NULL REFERENCES stores(id) ON DELETE RESTRICT,
        name TEXT NOT NULL,
        sku TEXT,
        barcode TEXT,
        price REAL NOT NULL,
        cost_price REAL,
        stock_qty REAL NOT NULL DEFAULT 0,
        min_qty REAL NOT NULL DEFAULT 0,
        unit TEXT,
        description TEXT,
        image_thumbnail TEXT,
        image_medium TEXT,
        image_large TEXT,
        image_hash TEXT,
        category_id TEXT REFERENCES categories(id) ON DELETE SET NULL,
        is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
        track_inventory INTEGER NOT NULL DEFAULT 1 CHECK (track_inventory IN (0, 1)),
        org_image_thumbnail TEXT,
        org_image_medium TEXT,
        org_image_large TEXT,
        org_image_hash TEXT,
        org_product_id TEXT,
        online_available INTEGER NOT NULL DEFAULT 0,
        online_max_qty REAL,
        online_reserved_qty REAL NOT NULL DEFAULT 0,
        min_alert_qty REAL,
        auto_reorder INTEGER NOT NULL DEFAULT 0,
        reorder_qty REAL,
        turnover_rate REAL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        synced_at INTEGER,
        deleted_at INTEGER
      )
    ''');
    await customStatement('''
      INSERT INTO products SELECT * FROM products_tmp
    ''');
    await customStatement('DROP TABLE products_tmp');
    // إعادة إنشاء الفهارس
    await customStatement(
      'CREATE INDEX idx_products_store_id ON products (store_id)',
    );
    await customStatement(
      'CREATE INDEX idx_products_barcode ON products (barcode)',
    );
    await customStatement('CREATE INDEX idx_products_sku ON products (sku)');
    await customStatement(
      'CREATE INDEX idx_products_category_id ON products (category_id)',
    );
    await customStatement('CREATE INDEX idx_products_name ON products (name)');
    await customStatement(
      'CREATE INDEX idx_products_synced_at ON products (synced_at)',
    );
    await customStatement(
      'CREATE INDEX idx_products_is_active ON products (is_active)',
    );
    await customStatement(
      'CREATE INDEX idx_products_store_barcode ON products (store_id, barcode)',
    );
    await customStatement(
      'CREATE INDEX idx_products_store_category_active ON products (store_id, category_id, is_active)',
    );
    // إعادة بناء FTS (يعتمد على جدول products)
    try {
      await ftsService.rebuildFtsIndex();
    } catch (e) {
      debugPrint('[Migration v19] FTS rebuild skipped: $e');
    }
  }

  /// Migration v19 -> v20: Add trigger-based FK validation
  /// SQLite doesn't support ALTER TABLE ADD CONSTRAINT for FK after table
  /// creation, so we add BEFORE INSERT/UPDATE triggers to enforce referential
  /// integrity on columns that lack inline FK definitions.
  Future<void> _migrateToV20() async {
    // --- customers.store_id -> stores.id ---
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fk_customers_store_id
      BEFORE INSERT ON customers
      BEGIN
        SELECT RAISE(ABORT, 'FK violation: store_id not found in stores')
        WHERE NEW.store_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM stores WHERE id = NEW.store_id);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fk_customers_store_id_update
      BEFORE UPDATE OF store_id ON customers
      BEGIN
        SELECT RAISE(ABORT, 'FK violation: store_id not found in stores')
        WHERE NEW.store_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM stores WHERE id = NEW.store_id);
      END
    ''');

    // --- customer_addresses.customer_id -> customers.id ---
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fk_customer_addresses_customer_id
      BEFORE INSERT ON customer_addresses
      BEGIN
        SELECT RAISE(ABORT, 'FK violation: customer_id not found in customers')
        WHERE NEW.customer_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM customers WHERE id = NEW.customer_id);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fk_customer_addresses_customer_id_update
      BEFORE UPDATE OF customer_id ON customer_addresses
      BEGIN
        SELECT RAISE(ABORT, 'FK violation: customer_id not found in customers')
        WHERE NEW.customer_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM customers WHERE id = NEW.customer_id);
      END
    ''');

    // --- sales.customer_id -> customers.id (optional FK) ---
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fk_sales_customer_id
      BEFORE INSERT ON sales
      BEGIN
        SELECT RAISE(ABORT, 'FK violation: customer_id not found in customers')
        WHERE NEW.customer_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM customers WHERE id = NEW.customer_id);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fk_sales_customer_id_update
      BEFORE UPDATE OF customer_id ON sales
      BEGIN
        SELECT RAISE(ABORT, 'FK violation: customer_id not found in customers')
        WHERE NEW.customer_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM customers WHERE id = NEW.customer_id);
      END
    ''');

    // --- expenses.store_id -> stores.id ---
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fk_expenses_store_id
      BEFORE INSERT ON expenses
      BEGIN
        SELECT RAISE(ABORT, 'FK violation: store_id not found in stores')
        WHERE NEW.store_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM stores WHERE id = NEW.store_id);
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fk_expenses_store_id_update
      BEFORE UPDATE OF store_id ON expenses
      BEGIN
        SELECT RAISE(ABORT, 'FK violation: store_id not found in stores')
        WHERE NEW.store_id IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM stores WHERE id = NEW.store_id);
      END
    ''');

    debugPrint('[Migration v20] FK validation triggers created');
  }

  // ==========================================================================
  // Migration safety infrastructure - بنية سلامة الهجرات
  // ==========================================================================

  /// إنشاء جدول سجل الهجرات (يُنشأ بـ SQL مباشر، ليس جدول Drift)
  Future<void> _createMigrationHistoryTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS migration_history (
        version INTEGER PRIMARY KEY,
        migrated_at INTEGER NOT NULL,
        duration_ms INTEGER NOT NULL DEFAULT 0,
        success INTEGER NOT NULL DEFAULT 1,
        error_message TEXT
      )
    ''');
  }

  /// تسجيل نتيجة هجرة في جدول migration_history
  Future<void> _recordMigrationHistory({
    required int version,
    required int durationMs,
    required bool success,
    String? errorMessage,
  }) async {
    try {
      await customStatement(
        '''INSERT OR REPLACE INTO migration_history
           (version, migrated_at, duration_ms, success, error_message)
           VALUES (?, ?, ?, ?, ?)''',
        [
          version,
          DateTime.now().millisecondsSinceEpoch,
          durationMs,
          success ? 1 : 0,
          errorMessage,
        ],
      );
    } catch (e) {
      // لا نريد أن يمنع خطأ التسجيل الهجرة من الاكتمال
      debugPrint('[Migration] Failed to record migration history: $e');
    }
  }

  /// فحص سلامة قاعدة البيانات باستخدام PRAGMA integrity_check
  Future<bool> _checkDatabaseIntegrity() async {
    try {
      final result = await customSelect('PRAGMA integrity_check').get();
      if (result.isEmpty) return false;
      final status = result.first.data.values.first?.toString() ?? '';
      return status == 'ok';
    } catch (e) {
      debugPrint('[Migration] Integrity check error: $e');
      return false;
    }
  }

  /// التحقق من أن جميع الجداول المتوقعة موجودة في قاعدة البيانات
  /// يُستخدم بعد الهجرة وعند بدء التطبيق للكشف المبكر عن مشاكل المخطط
  Future<bool> verifySchema() async {
    // قائمة الجداول الأساسية المتوقعة في الإصدار الحالي
    const expectedTables = [
      // الجداول الأساسية
      'products',
      'sales',
      'sale_items',
      'inventory_movements',
      'accounts',
      'sync_queue',
      'transactions',
      'orders',
      'order_items',
      'audit_log',
      'categories',
      'loyalty_points',
      'loyalty_transactions',
      'loyalty_rewards',
      // جداول الأولوية العالية
      'stores',
      'users',
      'roles',
      'customers',
      'customer_addresses',
      'suppliers',
      'shifts',
      'cash_movements',
      'returns',
      'return_items',
      'expenses',
      'expense_categories',
      // جداول الأولوية المتوسطة
      'purchases',
      'purchase_items',
      'discounts',
      'coupons',
      'promotions',
      'held_invoices',
      'notifications',
      'stock_transfers',
      'settings',
      // جداول الأولوية المنخفضة
      'stock_takes',
      'product_expiry',
      'drivers',
      'daily_summaries',
      'order_status_history',
      'favorites',
      // جداول واتساب
      'whatsapp_messages',
      'whatsapp_templates',
      // جداول متعددة المستأجرين
      'organizations',
      'subscriptions',
      'org_members',
      'user_stores',
      'pos_terminals',
      // جداول المزامنة
      'sync_metadata',
      'stock_deltas',
      // كتالوج المنظمة
      'org_products',
      // الفواتير
      'invoices',
    ];

    try {
      final result = await customSelect(
        "SELECT name FROM sqlite_master "
        "WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      ).get();
      final existingTables = result.map((r) => r.read<String>('name')).toSet();

      final missingTables = <String>[];
      for (final table in expectedTables) {
        if (!existingTables.contains(table)) {
          missingTables.add(table);
        }
      }

      if (missingTables.isNotEmpty) {
        debugPrint('[Migration] Missing tables: ${missingTables.join(', ')}');
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('[Migration] Schema verification error: $e');
      return false;
    }
  }

  /// الحصول على سجل الهجرات (للتشخيص والمراقبة)
  Future<List<Map<String, dynamic>>> getMigrationHistory() async {
    try {
      // التحقق من وجود الجدول أولاً
      final tableExists = await customSelect(
        "SELECT 1 FROM sqlite_master "
        "WHERE type='table' AND name='migration_history'",
      ).getSingleOrNull();
      if (tableExists == null) return [];

      final rows = await customSelect(
        'SELECT * FROM migration_history ORDER BY version ASC',
      ).get();
      return rows.map((r) => r.data).toList();
    } catch (e) {
      debugPrint('[Migration] Failed to read migration history: $e');
      return [];
    }
  }

  /// تنظيف تلقائي للبيانات القديمة
  Future<void> _autoCleanup() async {
    try {
      // حذف sync_queue المكتملة أقدم من 30 يوم
      await syncQueueDao.cleanOldSyncedItems();
      // حذف audit_log المزامنة أقدم من 6 سنوات (Saudi VAT Art. 66)
      await auditLogDao.cleanupOldLogs();
      // حذف stock_deltas المزامنة أقدم من 7 أيام
      await stockDeltasDao.cleanupSynced();
    } catch (_) {
      // تجاهل أخطاء التنظيف - لا تمنع فتح القاعدة
    }
  }

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
          [entry.value, entry.key],
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
          [entry.value, entry.key],
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
