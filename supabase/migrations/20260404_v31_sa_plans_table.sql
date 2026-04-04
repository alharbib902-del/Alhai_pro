-- ============================================================================
-- Super Admin: Plans management table
-- ============================================================================
-- The subscriptions table stores plan as a TEXT slug. This table provides
-- metadata (pricing, limits, features) for each plan slug, enabling the
-- super admin panel to manage plans without altering the core schema.
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.sa_plans (
  id TEXT PRIMARY KEY DEFAULT gen_random_uuid()::TEXT,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  monthly_price DOUBLE PRECISION NOT NULL DEFAULT 0,
  yearly_price DOUBLE PRECISION NOT NULL DEFAULT 0,
  max_branches INT DEFAULT 1,
  max_products INT DEFAULT 100,
  max_users INT DEFAULT 5,
  features JSONB DEFAULT '[]'::JSONB,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- Seed default plans matching common subscription.plan slugs
INSERT INTO public.sa_plans (id, name, slug, monthly_price, yearly_price, max_branches, max_products, max_users, features)
VALUES
  ('plan_trial', 'Trial', 'trial', 0, 0, 1, 50, 2, '["basic_pos", "basic_reports"]'::JSONB),
  ('plan_basic', 'Basic', 'basic', 99, 990, 1, 200, 5, '["basic_pos", "reports", "inventory"]'::JSONB),
  ('plan_pro', 'Professional', 'pro', 199, 1990, 3, 1000, 15, '["full_pos", "advanced_reports", "inventory", "multi_branch", "api_access"]'::JSONB),
  ('plan_enterprise', 'Enterprise', 'enterprise', 499, 4990, 10, 10000, 50, '["full_pos", "advanced_reports", "inventory", "multi_branch", "api_access", "custom_branding", "priority_support"]'::JSONB)
ON CONFLICT (slug) DO NOTHING;

-- Enable RLS
ALTER TABLE public.sa_plans ENABLE ROW LEVEL SECURITY;

-- Super admin can manage plans (read/write)
CREATE POLICY "sa_plans_superadmin_all" ON public.sa_plans
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid()::TEXT
      AND role = 'super_admin'
    )
  );

-- All authenticated users can read plans (for pricing pages etc.)
CREATE POLICY "sa_plans_read_all" ON public.sa_plans
  FOR SELECT
  USING (true);

-- ============================================================================
-- Super Admin RPCs for analytics
-- ============================================================================

-- Monthly revenue RPC (used by dashboard)
CREATE OR REPLACE FUNCTION public.sa_monthly_revenue()
RETURNS TABLE(month TEXT, revenue DOUBLE PRECISION)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    to_char(s.created_at, 'YYYY-MM') AS month,
    COALESCE(SUM(
      CASE
        WHEN s.billing_cycle = 'yearly' THEN s.amount / 12
        ELSE s.amount
      END
    ), 0)::DOUBLE PRECISION AS revenue
  FROM public.subscriptions s
  WHERE s.status = 'active'
    AND s.created_at >= (now() - interval '12 months')
  GROUP BY to_char(s.created_at, 'YYYY-MM')
  ORDER BY month;
END;
$$;

-- Top stores by revenue RPC
CREATE OR REPLACE FUNCTION public.sa_top_stores_by_revenue(p_limit INT DEFAULT 5)
RETURNS TABLE(store_id TEXT, store_name TEXT, revenue DOUBLE PRECISION)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    st.id AS store_id,
    st.name AS store_name,
    COALESCE(SUM(sa.total), 0)::DOUBLE PRECISION AS revenue
  FROM public.stores st
  LEFT JOIN public.sales sa ON sa.store_id = st.id
  WHERE st.is_active = true
  GROUP BY st.id, st.name
  ORDER BY revenue DESC
  LIMIT p_limit;
END;
$$;

-- Top stores by transactions RPC
CREATE OR REPLACE FUNCTION public.sa_top_stores_by_transactions(p_limit INT DEFAULT 5)
RETURNS TABLE(store_id TEXT, store_name TEXT, transactions BIGINT, avg_per_day INT, products BIGINT)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    st.id AS store_id,
    st.name AS store_name,
    COUNT(sa.id) AS transactions,
    (COUNT(sa.id) / GREATEST(1, EXTRACT(day FROM now() - MIN(sa.created_at))::INT))::INT AS avg_per_day,
    (SELECT COUNT(*) FROM public.products p WHERE p.store_id = st.id) AS products
  FROM public.stores st
  LEFT JOIN public.sales sa ON sa.store_id = st.id
  WHERE st.is_active = true
  GROUP BY st.id, st.name
  ORDER BY transactions DESC
  LIMIT p_limit;
END;
$$;
