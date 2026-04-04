-- Migration v29: Align Supabase columns with Drift table definitions
-- Adds ALL missing columns from Drift schemas to Supabase tables (batch 1)
-- Uses ADD COLUMN IF NOT EXISTS for idempotency
--
-- Source of truth: packages/alhai_database/lib/src/tables/*.dart
-- Drift column naming convention: camelCase -> snake_case

BEGIN;

-- ============================================================
-- 1. shifts table (from shifts_table.dart)
--    Missing: org_id, terminal_id, cashier_name, total_sales,
--             total_sales_amount, total_refunds, total_refunds_amount,
--             difference, synced_at
-- ============================================================

ALTER TABLE shifts ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS terminal_id TEXT;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS cashier_name TEXT;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS total_sales INTEGER DEFAULT 0;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS total_sales_amount DOUBLE PRECISION DEFAULT 0;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS total_refunds INTEGER DEFAULT 0;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS total_refunds_amount DOUBLE PRECISION DEFAULT 0;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS difference DOUBLE PRECISION;
ALTER TABLE shifts ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;


-- ============================================================
-- 2. returns table (from returns_table.dart)
--    Missing: org_id, return_number, customer_name, total_refund
-- ============================================================

ALTER TABLE returns ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE returns ADD COLUMN IF NOT EXISTS return_number TEXT;
ALTER TABLE returns ADD COLUMN IF NOT EXISTS customer_name TEXT;
ALTER TABLE returns ADD COLUMN IF NOT EXISTS total_refund DOUBLE PRECISION DEFAULT 0;


-- ============================================================
-- 3. return_items table (from returns_table.dart - ReturnItemsTable)
--    Missing: org_id, product_name, refund_amount
-- ============================================================

ALTER TABLE return_items ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE return_items ADD COLUMN IF NOT EXISTS product_name TEXT;
ALTER TABLE return_items ADD COLUMN IF NOT EXISTS refund_amount DOUBLE PRECISION DEFAULT 0;


-- ============================================================
-- 4. audit_log table (from audit_log_table.dart)
--    Missing: org_id, user_name, old_value, new_value, description,
--             device_info
-- ============================================================

ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS user_name TEXT;
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS old_value TEXT;
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS new_value TEXT;
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE audit_log ADD COLUMN IF NOT EXISTS device_info TEXT;


-- ============================================================
-- 5. daily_summaries table (from daily_summaries_table.dart)
--    Missing: org_id, total_orders_amount, total_sales_count (mapped
--    from Drift totalSales INTEGER), total_refunds_amount
--
--    Note: Drift has totalSales (integer = count) and
--    totalSalesAmount (real = money). Supabase may already have
--    total_sales as amount. We add the missing semantic columns.
-- ============================================================

ALTER TABLE daily_summaries ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE daily_summaries ADD COLUMN IF NOT EXISTS total_orders_amount DOUBLE PRECISION DEFAULT 0;
ALTER TABLE daily_summaries ADD COLUMN IF NOT EXISTS total_sales_count INTEGER DEFAULT 0;
ALTER TABLE daily_summaries ADD COLUMN IF NOT EXISTS total_refunds_amount DOUBLE PRECISION DEFAULT 0;


-- ============================================================
-- 6. cash_movements table (from shifts_table.dart - CashMovementsTable)
--    Missing: org_id, reference
-- ============================================================

ALTER TABLE cash_movements ADD COLUMN IF NOT EXISTS org_id TEXT;
ALTER TABLE cash_movements ADD COLUMN IF NOT EXISTS reference TEXT;


-- ============================================================
-- 7. organizations table (from organizations_table.dart)
--    Missing: status, company_type
-- ============================================================

ALTER TABLE organizations ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'trial';
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS company_type TEXT DEFAULT 'agency';


-- ============================================================
-- 8. org_products table (from org_products_table.dart)
--    Missing: synced_at
-- ============================================================

ALTER TABLE org_products ADD COLUMN IF NOT EXISTS synced_at TIMESTAMPTZ;


COMMIT;
