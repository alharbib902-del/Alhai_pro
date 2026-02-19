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
