-- ============================================================================
-- Migration v28: Create missing RPC functions + delivery webhook trigger
-- Date: 2026-04-04
-- RPCs: check_cashier_by_phone, get_my_stores, get_store_categories,
--       get_store_products
-- Trigger: delivery webhook via pg_net (or dashboard config)
-- ============================================================================

-- ############################################################
-- 1. check_cashier_by_phone(p_phone TEXT)
-- ############################################################
-- Called from auth_providers.dart during phone login flow.
-- Expects return: { exists: bool, email, password, name, store_name }

CREATE OR REPLACE FUNCTION public.check_cashier_by_phone(p_phone TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
DECLARE
  v_user RECORD;
  v_store_name TEXT;
BEGIN
  -- Input validation
  IF p_phone IS NULL OR TRIM(p_phone) = '' THEN
    RETURN jsonb_build_object('exists', false, 'error', 'Phone number is required');
  END IF;

  -- Look up the user by phone (strip leading + if present, caller also strips it)
  SELECT u.id, u.phone, u.email, u.name, u.role, u.is_active
  INTO v_user
  FROM public.users u
  WHERE u.phone = p_phone
     OR u.phone = '+' || p_phone
  LIMIT 1;

  IF NOT FOUND THEN
    RETURN jsonb_build_object('exists', false);
  END IF;

  IF NOT v_user.is_active THEN
    RETURN jsonb_build_object('exists', false, 'error', 'Account is deactivated');
  END IF;

  -- Get the first store name for display during login
  SELECT s.name INTO v_store_name
  FROM public.store_members sm
  JOIN public.stores s ON s.id = sm.store_id
  WHERE sm.user_id = v_user.id
    AND sm.is_active = true
    AND s.is_active = true
  LIMIT 1;

  RETURN jsonb_build_object(
    'exists', true,
    'id', v_user.id,
    'email', v_user.email,
    'name', v_user.name,
    'phone', v_user.phone,
    'role', v_user.role,
    'store_name', COALESCE(v_store_name, '')
  );
END;
$$;

-- Note: check_cashier_by_phone is called BEFORE the user is authenticated
-- (it is the first step in the phone login flow), so we grant to anon as well.
GRANT EXECUTE ON FUNCTION public.check_cashier_by_phone(TEXT) TO anon;
GRANT EXECUTE ON FUNCTION public.check_cashier_by_phone(TEXT) TO authenticated;


-- ############################################################
-- 2. get_my_stores()
-- ############################################################
-- Called from store_select_screen.dart.
-- Returns list of stores the current user is a member of.
-- Expected fields: id, name, address, is_active (and extras).
--
-- NOTE: This function may already exist from get_my_stores.sql.
-- Using CREATE OR REPLACE to ensure the latest version is applied.

CREATE OR REPLACE FUNCTION public.get_my_stores()
RETURNS TABLE (
  id TEXT,
  name TEXT,
  name_en TEXT,
  address TEXT,
  phone TEXT,
  email TEXT,
  city TEXT,
  currency TEXT,
  timezone TEXT,
  is_active BOOLEAN,
  created_at TIMESTAMPTZ,
  role_in_store TEXT
)
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, auth
AS $$
  SELECT
    s.id,
    s.name,
    s.name_en,
    s.address,
    s.phone,
    s.email,
    s.city,
    s.currency,
    s.timezone,
    s.is_active,
    s.created_at,
    sm.role_in_store::text
  FROM public.stores s
  JOIN public.store_members sm ON s.id = sm.store_id
  WHERE sm.user_id = auth.uid()
    AND sm.is_active = true
    AND s.is_active = true
  ORDER BY s.name;
$$;

GRANT EXECUTE ON FUNCTION public.get_my_stores() TO authenticated;


-- ############################################################
-- 3. get_store_categories(p_store_id TEXT)
-- ############################################################
-- Already defined in sync_rpc_functions.sql. Re-creating here
-- via CREATE OR REPLACE to ensure it exists in the migration chain.

CREATE OR REPLACE FUNCTION public.get_store_categories(p_store_id TEXT)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- Input validation
  IF p_store_id IS NULL OR TRIM(p_store_id) = '' THEN
    RAISE EXCEPTION 'store_id is required and cannot be empty';
  END IF;

  -- Authorization: verify caller is an active member of the store
  IF NOT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id
      AND user_id = auth.uid()
      AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Access denied: not a member of this store';
  END IF;

  RETURN COALESCE(
    (SELECT jsonb_agg(
      jsonb_build_object(
        'id', c.id,
        'org_id', c.org_id,
        'store_id', c.store_id,
        'name', c.name,
        'name_en', c.name_en,
        'parent_id', c.parent_id,
        'image_url', c.image_url,
        'color', c.color,
        'icon', c.icon,
        'sort_order', c.sort_order,
        'is_active', c.is_active,
        'created_at', c.created_at,
        'updated_at', c.updated_at
      )
    )
    FROM public.categories c
    WHERE c.store_id = p_store_id
      AND c.is_active = true
    ),
    '[]'::jsonb
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_store_categories(TEXT) TO authenticated;


-- ############################################################
-- 4. get_store_products(p_store_id TEXT, p_limit INT, p_offset INT)
-- ############################################################
-- Already defined in sync_rpc_functions.sql. Re-creating here
-- via CREATE OR REPLACE to ensure it exists in the migration chain.

CREATE OR REPLACE FUNCTION public.get_store_products(
  p_store_id TEXT,
  p_limit INT DEFAULT 500,
  p_offset INT DEFAULT 0
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  -- Input validation
  IF p_store_id IS NULL OR TRIM(p_store_id) = '' THEN
    RAISE EXCEPTION 'store_id is required and cannot be empty';
  END IF;

  -- Authorization: verify caller is an active member of the store
  IF NOT EXISTS (
    SELECT 1 FROM public.store_members
    WHERE store_id = p_store_id
      AND user_id = auth.uid()
      AND is_active = true
  ) THEN
    RAISE EXCEPTION 'Access denied: not a member of this store';
  END IF;

  -- Clamp limit to prevent abuse
  IF p_limit > 1000 THEN
    p_limit := 1000;
  END IF;

  RETURN COALESCE(
    (SELECT jsonb_agg(row_data) FROM (
      SELECT jsonb_build_object(
        'id', p.id,
        'org_id', p.org_id,
        'store_id', p.store_id,
        'category_id', p.category_id,
        'sku', p.sku,
        'barcode', p.barcode,
        'name', p.name,
        'description', p.description,
        'image_thumbnail', p.image_thumbnail,
        'image_medium', p.image_medium,
        'image_large', p.image_large,
        'image_hash', p.image_hash,
        'price', p.price,
        'cost_price', p.cost_price,
        'stock_qty', p.stock_qty,
        'min_qty', p.min_qty,
        'unit', p.unit,
        'track_inventory', p.track_inventory,
        'is_active', p.is_active,
        'created_at', p.created_at,
        'updated_at', p.updated_at
      ) AS row_data
      FROM public.products p
      WHERE p.store_id = p_store_id
        AND p.is_active = true
      ORDER BY p.name
      LIMIT p_limit
      OFFSET p_offset
    ) sub),
    '[]'::jsonb
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_store_products(TEXT, INT, INT) TO authenticated;


-- ############################################################
-- 5. Delivery webhook trigger
-- ############################################################
-- Uses pg_net extension to POST to a Supabase Edge Function whenever
-- a delivery row is inserted or updated.
--
-- IMPORTANT: pg_net must be enabled in your Supabase project.
-- If pg_net is NOT available, configure this webhook via:
--   Supabase Dashboard -> Database -> Webhooks -> Create Webhook
--   Table: deliveries | Events: INSERT, UPDATE
--   URL: <your-project-url>/functions/v1/delivery-webhook

-- Safely enable pg_net if available (will no-op if already enabled)
CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;

CREATE OR REPLACE FUNCTION public.trigger_delivery_webhook()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- POST to the delivery-webhook edge function
  -- Uses pg_net for async HTTP from within a trigger
  PERFORM net.http_post(
    url := current_setting('app.settings.supabase_url', true)
           || '/functions/v1/delivery-webhook',
    body := jsonb_build_object(
      'type',       TG_OP,
      'record',     row_to_json(NEW),
      'old_record', CASE WHEN TG_OP = 'UPDATE' THEN row_to_json(OLD) ELSE NULL END
    ),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key', true)
    )
  );
  RETURN NEW;
EXCEPTION
  -- If pg_net is not available or the call fails, log a warning
  -- but do NOT block the INSERT/UPDATE
  WHEN OTHERS THEN
    RAISE WARNING 'delivery webhook failed: %', SQLERRM;
    RETURN NEW;
END;
$$;

-- Only create the trigger if the deliveries table exists
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public' AND table_name = 'deliveries'
  ) THEN
    DROP TRIGGER IF EXISTS on_delivery_change ON public.deliveries;
    CREATE TRIGGER on_delivery_change
      AFTER INSERT OR UPDATE ON public.deliveries
      FOR EACH ROW
      EXECUTE FUNCTION public.trigger_delivery_webhook();
  END IF;
END;
$$;
