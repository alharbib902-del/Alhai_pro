# Report 5: Migration SQL + Drift Migration

## File 1: `supabase/migrations/004_schema_alignment.sql`

```sql
-- ============================================================================
-- Migration 004: Schema Alignment
-- Aligns Supabase schema with Drift local models
-- ============================================================================

-- 1. MISSING INDEXES (exist in Drift but not Supabase)
CREATE INDEX IF NOT EXISTS idx_products_org_store ON products(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_categories_org_store ON categories(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_customers_org_store ON customers(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_sales_org_store ON sales(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_orders_org_store ON orders(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_inventory_org_store ON inventory_movements(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_shifts_org_store ON shifts(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_returns_org_store ON returns(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_purchases_org_store ON purchases(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_expenses_org_store ON expenses(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_accounts_org_store ON accounts(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_daily_summaries_org_store ON daily_summaries(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_notifications_org_store ON notifications(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_loyalty_org_store ON loyalty_points(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_discounts_org_store ON discounts(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_audit_org_store ON audit_log(org_id, store_id);
CREATE INDEX IF NOT EXISTS idx_pos_terminals_is_active ON pos_terminals(is_active);
CREATE INDEX IF NOT EXISTS idx_org_members_is_active ON org_members(is_active);
CREATE INDEX IF NOT EXISTS idx_subscriptions_plan ON subscriptions(plan);
CREATE INDEX IF NOT EXISTS idx_user_stores_is_active ON user_stores(is_active);

-- 2. BACKFILL ORG_ID FOR EXISTING ROWS
DO $$
DECLARE
    tbl TEXT;
    tbls TEXT[] := ARRAY[
        'categories', 'products', 'customers', 'suppliers', 'sales',
        'orders', 'inventory_movements', 'accounts', 'expenses',
        'purchases', 'returns', 'shifts', 'loyalty_points',
        'discounts', 'notifications', 'daily_summaries', 'audit_log'
    ];
BEGIN
    FOREACH tbl IN ARRAY tbls LOOP
        BEGIN
            EXECUTE format(
                'UPDATE %I t SET org_id = s.org_id
                 FROM stores s
                 WHERE t.store_id = s.id
                 AND t.org_id IS NULL
                 AND s.org_id IS NOT NULL', tbl
            );
        EXCEPTION WHEN undefined_column THEN NULL;
        END;
    END LOOP;
END;
$$;

-- 3. GRANTS
GRANT SELECT, INSERT, UPDATE, DELETE ON organizations TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON subscriptions TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON org_members TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON user_stores TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON pos_terminals TO authenticated;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO authenticated;

-- 4. VALIDATION FUNCTION
CREATE OR REPLACE FUNCTION validate_schema_alignment()
RETURNS TABLE (check_name TEXT, status TEXT, details TEXT)
LANGUAGE plpgsql STABLE AS $$
DECLARE v_count INTEGER;
BEGIN
    check_name := 'org_id_columns';
    SELECT COUNT(*) INTO v_count
    FROM information_schema.columns
    WHERE table_schema = 'public' AND column_name = 'org_id';
    status := CASE WHEN v_count >= 19 THEN 'PASS' ELSE 'FAIL' END;
    details := format('%s tables have org_id', v_count);
    RETURN NEXT;

    check_name := 'multi_tenant_tables';
    SELECT COUNT(*) INTO v_count
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name IN ('organizations', 'subscriptions', 'org_members',
                       'user_stores', 'pos_terminals');
    status := CASE WHEN v_count = 5 THEN 'PASS' ELSE 'FAIL' END;
    details := format('%s/5 multi-tenant tables exist', v_count);
    RETURN NEXT;
END;
$$;
```

## File 2: Drift Migration (`lib/data/local/migrations/migration_v2.dart`)

```dart
import 'package:drift/drift.dart';

/// Migration from schema v1 to v2 (multi-tenant support)
class MigrationV2 {
  static Future<void> migrate(Migrator m, int from, int to) async {
    if (from < 2) {
      // 1. Create new multi-tenant tables
      await _createOrganizationsTable(m);
      await _createSubscriptionsTable(m);
      await _createOrgMembersTable(m);
      await _createUserStoresTable(m);
      await _createPosTerminalsTable(m);

      // 2. Add org_id to existing tables
      await _addOrgIdColumns(m);

      // 3. Add missing columns to users, sales, shifts
      await _addMissingColumns(m);

      // 4. Create indexes
      await _createIndexes(m);
    }
  }

  static Future<void> _createOrganizationsTable(Migrator m) async {
    await m.createTable('''
      CREATE TABLE IF NOT EXISTS organizations (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        name_en TEXT,
        slug TEXT,
        logo TEXT,
        owner_id TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        city TEXT,
        country TEXT NOT NULL DEFAULT 'SA',
        tax_number TEXT,
        commercial_reg TEXT,
        currency TEXT NOT NULL DEFAULT 'SAR',
        timezone TEXT NOT NULL DEFAULT 'Asia/Riyadh',
        locale TEXT NOT NULL DEFAULT 'ar',
        plan TEXT NOT NULL DEFAULT 'free',
        max_stores INTEGER NOT NULL DEFAULT 1,
        max_users INTEGER NOT NULL DEFAULT 3,
        max_products INTEGER NOT NULL DEFAULT 100,
        is_active INTEGER NOT NULL DEFAULT 1,
        trial_ends_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        synced_at INTEGER
      )
    ''');
  }

  static Future<void> _createSubscriptionsTable(Migrator m) async {
    await m.createTable('''
      CREATE TABLE IF NOT EXISTS subscriptions (
        id TEXT NOT NULL PRIMARY KEY,
        org_id TEXT NOT NULL,
        plan TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'active',
        amount REAL NOT NULL DEFAULT 0,
        currency TEXT NOT NULL DEFAULT 'SAR',
        billing_cycle TEXT NOT NULL DEFAULT 'monthly',
        current_period_start INTEGER NOT NULL,
        current_period_end INTEGER NOT NULL,
        cancel_at_period_end INTEGER NOT NULL DEFAULT 0,
        payment_method TEXT,
        external_subscription_id TEXT,
        features TEXT NOT NULL DEFAULT '{}',
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        synced_at INTEGER
      )
    ''');
  }

  static Future<void> _createOrgMembersTable(Migrator m) async {
    await m.createTable('''
      CREATE TABLE IF NOT EXISTS org_members (
        id TEXT NOT NULL PRIMARY KEY,
        org_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'staff',
        is_active INTEGER NOT NULL DEFAULT 1,
        invited_by TEXT,
        invited_at INTEGER,
        joined_at INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');
  }

  static Future<void> _createUserStoresTable(Migrator m) async {
    await m.createTable('''
      CREATE TABLE IF NOT EXISTS user_stores (
        id TEXT NOT NULL PRIMARY KEY,
        user_id TEXT NOT NULL,
        store_id TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'cashier',
        is_primary INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');
  }

  static Future<void> _createPosTerminalsTable(Migrator m) async {
    await m.createTable('''
      CREATE TABLE IF NOT EXISTS pos_terminals (
        id TEXT NOT NULL PRIMARY KEY,
        store_id TEXT NOT NULL,
        org_id TEXT NOT NULL,
        name TEXT NOT NULL,
        terminal_number INTEGER NOT NULL DEFAULT 1,
        device_id TEXT,
        device_name TEXT,
        device_model TEXT,
        os_version TEXT,
        app_version TEXT,
        status TEXT NOT NULL DEFAULT 'active',
        current_shift_id TEXT,
        current_user_id TEXT,
        last_heartbeat_at INTEGER,
        last_sync_at INTEGER,
        settings TEXT NOT NULL DEFAULT '{}',
        receipt_header TEXT,
        receipt_footer TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        synced_at INTEGER
      )
    ''');
  }

  static Future<void> _addOrgIdColumns(Migrator m) async {
    final tables = [
      'products', 'categories', 'customers', 'sales', 'orders',
      'inventory_movements', 'accounts', 'suppliers', 'stores',
      'users', 'shifts', 'audit_log', 'loyalty_points', 'expenses',
      'returns', 'purchases', 'discounts', 'notifications',
      'daily_summaries',
    ];
    for (final table in tables) {
      await m.addColumn(table, 'org_id TEXT');
    }
  }

  static Future<void> _addMissingColumns(Migrator m) async {
    await m.addColumn('users', 'auth_uid TEXT');
    await m.addColumn('users', 'role_id TEXT');
    await m.addColumn('sales', 'terminal_id TEXT');
    await m.addColumn('shifts', 'terminal_id TEXT');
  }

  static Future<void> _createIndexes(Migrator m) async {
    await m.createIndex('idx_org_members_org_id', 'org_members', ['org_id']);
    await m.createIndex('idx_org_members_user_id', 'org_members', ['user_id']);
    await m.createIndex('idx_user_stores_user_id', 'user_stores', ['user_id']);
    await m.createIndex('idx_user_stores_store_id', 'user_stores', ['store_id']);
    await m.createIndex('idx_pos_terminals_store_id', 'pos_terminals', ['store_id']);
    await m.createIndex('idx_pos_terminals_org_id', 'pos_terminals', ['org_id']);
    await m.createIndex('idx_subscriptions_org_id', 'subscriptions', ['org_id']);
  }
}
```

## File 3: `app_database.dart` Migration Update

Add to `onUpgrade` in AppDatabase:

```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (m) => m.createAll(),
  onUpgrade: (m, from, to) async {
    await MigrationV2.migrate(m, from, to);
  },
);
```

## File 4: Rollback Script (`supabase/migrations/004_rollback.sql`)

```sql
-- ROLLBACK for migration 004
-- WARNING: This will remove multi-tenant columns and data

-- Drop new indexes
DROP INDEX IF EXISTS idx_products_org_store;
DROP INDEX IF EXISTS idx_categories_org_store;
-- ... (repeat for all compound indexes)

-- Drop new tables (CASCADE to remove dependent data)
DROP TABLE IF EXISTS pos_terminals CASCADE;
DROP TABLE IF EXISTS user_stores CASCADE;
DROP TABLE IF EXISTS org_members CASCADE;
DROP TABLE IF EXISTS subscriptions CASCADE;
DROP TABLE IF EXISTS organizations CASCADE;

-- Remove org_id from existing tables
-- NOTE: PostgreSQL requires recreating tables to drop columns safely
-- Use ALTER TABLE ... DROP COLUMN IF EXISTS
ALTER TABLE products DROP COLUMN IF EXISTS org_id;
ALTER TABLE categories DROP COLUMN IF EXISTS org_id;
ALTER TABLE customers DROP COLUMN IF EXISTS org_id;
ALTER TABLE sales DROP COLUMN IF EXISTS org_id;
ALTER TABLE orders DROP COLUMN IF EXISTS org_id;
ALTER TABLE inventory_movements DROP COLUMN IF EXISTS org_id;
ALTER TABLE accounts DROP COLUMN IF EXISTS org_id;
ALTER TABLE suppliers DROP COLUMN IF EXISTS org_id;
ALTER TABLE shifts DROP COLUMN IF EXISTS org_id;
ALTER TABLE audit_log DROP COLUMN IF EXISTS org_id;
ALTER TABLE expenses DROP COLUMN IF EXISTS org_id;
ALTER TABLE returns DROP COLUMN IF EXISTS org_id;
ALTER TABLE purchases DROP COLUMN IF EXISTS org_id;
ALTER TABLE discounts DROP COLUMN IF EXISTS org_id;
ALTER TABLE notifications DROP COLUMN IF EXISTS org_id;
ALTER TABLE daily_summaries DROP COLUMN IF EXISTS org_id;

-- Remove auth columns from users
ALTER TABLE users DROP COLUMN IF EXISTS auth_uid;
ALTER TABLE users DROP COLUMN IF EXISTS role_id;

-- Remove terminal_id
ALTER TABLE sales DROP COLUMN IF EXISTS terminal_id;
ALTER TABLE shifts DROP COLUMN IF EXISTS terminal_id;

-- Drop validation function
DROP FUNCTION IF EXISTS validate_schema_alignment();
```
