-- ============================================================================
-- Migration v32: Replace remaining blanket USING(true) RLS policies with
--                proper store/org/user-scoped policies.
-- Date: 2026-04-10
-- Purpose: v26 (20260404) fixed 7 tables (sales, sale_items, customers,
--          stock_deltas, expenses, purchases, inventory_movements). A follow-up
--          security audit identified 23+ additional tables that still rely on
--          the blanket "Allow authenticated full access" policy created in
--          supabase/fix_compatibility.sql. Any authenticated user can currently
--          read/write every row in these tables across every store and every
--          organization.
--
--          This migration applies the exact same pattern used in v26 to the
--          remaining tables, scoping access via membership in org_members:
--
--              store_id IN (
--                SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT
--              )
--
--          Tables that have no direct store_id column are scoped by joining
--          through their parent table (orders, purchases, customers). Tables
--          that are organisation-wide are scoped by org_id. The notifications
--          table is scoped by the per-user user_id column because each row is
--          personal.
--
-- Pattern: identical to v26 — idempotent via DROP POLICY IF EXISTS, single
--          "store_member_access" policy per table, FOR ALL TO authenticated.
--
-- References:
--   - supabase/migrations/20260404_v26_fix_rls_policies.sql (original pattern)
--   - supabase/fix_compatibility.sql (source of the blanket policy)
--   - packages/alhai_database/lib/src/tables/*.dart (Drift schema)
-- ============================================================================

-- ############################################################
-- 1. orders - store-scoped (has store_id column)
-- ############################################################

ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.orders;
DROP POLICY IF EXISTS "store_member_access" ON public.orders;

CREATE POLICY "store_member_access" ON public.orders
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 2. order_items - scoped via orders JOIN (no direct store_id)
-- ############################################################

ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.order_items;
DROP POLICY IF EXISTS "store_member_access" ON public.order_items;

CREATE POLICY "store_member_access" ON public.order_items
  FOR ALL TO authenticated
  USING (order_id IN (
    SELECT id FROM public.orders
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ))
  WITH CHECK (order_id IN (
    SELECT id FROM public.orders
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ));


-- ############################################################
-- 3. shifts - store-scoped
-- ############################################################

ALTER TABLE public.shifts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.shifts;
DROP POLICY IF EXISTS "store_member_access" ON public.shifts;

CREATE POLICY "store_member_access" ON public.shifts
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 4. loyalty_points - store-scoped
-- ############################################################

ALTER TABLE public.loyalty_points ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.loyalty_points;
DROP POLICY IF EXISTS "store_member_access" ON public.loyalty_points;

CREATE POLICY "store_member_access" ON public.loyalty_points
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 5. notifications - user-scoped (personal per recipient)
--    Each notification targets a specific user. Users must only see
--    their own notifications regardless of store context.
-- ############################################################

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.notifications;
DROP POLICY IF EXISTS "store_member_access" ON public.notifications;
DROP POLICY IF EXISTS "user_personal_access" ON public.notifications;

CREATE POLICY "user_personal_access" ON public.notifications
  FOR ALL TO authenticated
  USING (user_id = auth.uid()::TEXT)
  WITH CHECK (user_id = auth.uid()::TEXT);


-- ############################################################
-- 6. suppliers - store-scoped
-- ############################################################

ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.suppliers;
DROP POLICY IF EXISTS "store_member_access" ON public.suppliers;

CREATE POLICY "store_member_access" ON public.suppliers
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 7. promotions - store-scoped
-- ############################################################

ALTER TABLE public.promotions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.promotions;
DROP POLICY IF EXISTS "store_member_access" ON public.promotions;

CREATE POLICY "store_member_access" ON public.promotions
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 8. organizations - self-scoped via org_members
--    An org row is only visible to members of that organisation.
-- ############################################################

ALTER TABLE public.organizations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.organizations;
DROP POLICY IF EXISTS "store_member_access" ON public.organizations;
DROP POLICY IF EXISTS "org_member_access" ON public.organizations;

CREATE POLICY "org_member_access" ON public.organizations
  FOR ALL TO authenticated
  USING (id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 9. subscriptions - org-scoped
-- ############################################################

ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.subscriptions;
DROP POLICY IF EXISTS "store_member_access" ON public.subscriptions;
DROP POLICY IF EXISTS "org_member_access" ON public.subscriptions;

CREATE POLICY "org_member_access" ON public.subscriptions
  FOR ALL TO authenticated
  USING (org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 10. org_members - org-scoped (a member can see all members of their org)
-- ############################################################

ALTER TABLE public.org_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.org_members;
DROP POLICY IF EXISTS "store_member_access" ON public.org_members;
DROP POLICY IF EXISTS "org_member_access" ON public.org_members;

CREATE POLICY "org_member_access" ON public.org_members
  FOR ALL TO authenticated
  USING (org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (org_id IN (SELECT org_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 11. user_stores - user-scoped (a user can only see their own store assignments)
-- ############################################################

ALTER TABLE public.user_stores ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.user_stores;
DROP POLICY IF EXISTS "store_member_access" ON public.user_stores;
DROP POLICY IF EXISTS "user_personal_access" ON public.user_stores;

CREATE POLICY "user_personal_access" ON public.user_stores
  FOR ALL TO authenticated
  USING (user_id = auth.uid()::TEXT)
  WITH CHECK (user_id = auth.uid()::TEXT);


-- ############################################################
-- 12. roles - store-scoped
--     fix_compatibility.sql creates roles with store_id NOT NULL.
-- ############################################################

ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.roles;
DROP POLICY IF EXISTS "store_member_access" ON public.roles;

CREATE POLICY "store_member_access" ON public.roles
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 13. discounts - store-scoped
-- ############################################################

ALTER TABLE public.discounts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.discounts;
DROP POLICY IF EXISTS "store_member_access" ON public.discounts;

CREATE POLICY "store_member_access" ON public.discounts
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 14. coupons - store-scoped
-- ############################################################

ALTER TABLE public.coupons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.coupons;
DROP POLICY IF EXISTS "store_member_access" ON public.coupons;

CREATE POLICY "store_member_access" ON public.coupons
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 15. expense_categories - store-scoped
--     (expenses itself was already fixed in v26)
-- ############################################################

ALTER TABLE public.expense_categories ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.expense_categories;
DROP POLICY IF EXISTS "store_member_access" ON public.expense_categories;

CREATE POLICY "store_member_access" ON public.expense_categories
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 16. purchase_items - scoped via purchases JOIN (no direct store_id)
--     (purchases itself was already fixed in v26)
-- ############################################################

ALTER TABLE public.purchase_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.purchase_items;
DROP POLICY IF EXISTS "store_member_access" ON public.purchase_items;

CREATE POLICY "store_member_access" ON public.purchase_items
  FOR ALL TO authenticated
  USING (purchase_id IN (
    SELECT id FROM public.purchases
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ))
  WITH CHECK (purchase_id IN (
    SELECT id FROM public.purchases
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ));


-- ############################################################
-- 17. drivers - store-scoped
-- ############################################################

ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.drivers;
DROP POLICY IF EXISTS "store_member_access" ON public.drivers;

CREATE POLICY "store_member_access" ON public.drivers
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 18. loyalty_transactions - store-scoped
-- ############################################################

ALTER TABLE public.loyalty_transactions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.loyalty_transactions;
DROP POLICY IF EXISTS "store_member_access" ON public.loyalty_transactions;

CREATE POLICY "store_member_access" ON public.loyalty_transactions
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 19. loyalty_rewards - store-scoped
-- ############################################################

ALTER TABLE public.loyalty_rewards ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.loyalty_rewards;
DROP POLICY IF EXISTS "store_member_access" ON public.loyalty_rewards;

CREATE POLICY "store_member_access" ON public.loyalty_rewards
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 20. customer_addresses - scoped via customers JOIN
--     customer_addresses has no store_id column, so we scope through
--     the parent customers table whose store_id must belong to a store
--     the caller is a member of. This aligns with the way v26 scoped
--     sale_items via sales.
-- ############################################################

ALTER TABLE public.customer_addresses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.customer_addresses;
DROP POLICY IF EXISTS "store_member_access" ON public.customer_addresses;

CREATE POLICY "store_member_access" ON public.customer_addresses
  FOR ALL TO authenticated
  USING (customer_id IN (
    SELECT id FROM public.customers
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ))
  WITH CHECK (customer_id IN (
    SELECT id FROM public.customers
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ));


-- ############################################################
-- 21. order_status_history - scoped via orders JOIN (no direct store_id)
-- ############################################################

ALTER TABLE public.order_status_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.order_status_history;
DROP POLICY IF EXISTS "store_member_access" ON public.order_status_history;

CREATE POLICY "store_member_access" ON public.order_status_history
  FOR ALL TO authenticated
  USING (order_id IN (
    SELECT id FROM public.orders
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ))
  WITH CHECK (order_id IN (
    SELECT id FROM public.orders
    WHERE store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT)
  ));


-- ############################################################
-- 22. pos_terminals - store-scoped
-- ############################################################

ALTER TABLE public.pos_terminals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.pos_terminals;
DROP POLICY IF EXISTS "store_member_access" ON public.pos_terminals;

CREATE POLICY "store_member_access" ON public.pos_terminals
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ############################################################
-- 23. settings - store-scoped
--     This is the key/value settings table (not store_settings).
--     Schema: id TEXT PK, store_id TEXT NOT NULL, key TEXT, value TEXT.
-- ############################################################

ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow authenticated full access" ON public.settings;
DROP POLICY IF EXISTS "store_member_access" ON public.settings;

CREATE POLICY "store_member_access" ON public.settings
  FOR ALL TO authenticated
  USING (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT))
  WITH CHECK (store_id IN (SELECT store_id FROM org_members WHERE user_id = auth.uid()::TEXT));


-- ============================================================================
-- SUMMARY
-- ============================================================================
-- Fixed 23 tables in this migration:
--
-- store-scoped (direct store_id column):
--   1.  orders
--   3.  shifts
--   4.  loyalty_points
--   6.  suppliers
--   7.  promotions
--   12. roles
--   13. discounts
--   14. coupons
--   15. expense_categories
--   17. drivers
--   18. loyalty_transactions
--   19. loyalty_rewards
--   22. pos_terminals
--   23. settings
--
-- parent-table JOIN scoped:
--   2.  order_items          (via orders.id -> orders.store_id)
--   16. purchase_items       (via purchases.id -> purchases.store_id)
--   20. customer_addresses   (via customers.id -> customers.store_id)
--   21. order_status_history (via orders.id -> orders.store_id)
--
-- org-scoped (direct or self-referencing org_id):
--   8.  organizations        (organizations.id IN org_members.org_id)
--   9.  subscriptions        (subscriptions.org_id IN org_members.org_id)
--   10. org_members          (self-scoped through membership)
--
-- user-scoped (personal data, auth.uid() match):
--   5.  notifications        (user_id = auth.uid())
--   11. user_stores          (user_id = auth.uid())
--
-- Combined with v26 (sales, sale_items, customers, stock_deltas, expenses,
-- purchases, inventory_movements) this closes the audit gap for 30 tables.
--
-- Not included in this migration:
--   - Tables already fixed in v26 (listed above).
--   - Additional auxiliary tables (cash_movements, returns, return_items,
--     audit_log, daily_summaries, held_invoices, favorites, transactions,
--     accounts, whatsapp_messages, stock_takes, stock_transfers, product_expiry,
--     org_products, chat_messages, driver_locations, driver_shifts,
--     delivery_proofs, invoices, etc.) — these should be reviewed in a
--     follow-up audit pass. They were NOT in the 25-table scope of this
--     migration.
-- ============================================================================
