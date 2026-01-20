-- ============================================================================
-- Alhai Platform - Supabase Owner Only SQL
-- Version: 2.4.0
-- Generated: 2026-01-20
-- Target: Supabase Postgres
-- ============================================================================
-- ⚠️ WARNING: Run this file ONLY from SQL Editor with Project Owner / postgres privileges
-- DO NOT include in normal migrations
-- ============================================================================

-- ============================================================================
-- A1. ALTER FUNCTION OWNER TO postgres
-- ============================================================================

ALTER FUNCTION public.update_user_role(UUID, user_role, TEXT) OWNER TO postgres;
ALTER FUNCTION public.prevent_direct_role_update() OWNER TO postgres;

-- ============================================================================
-- A2. handle_new_user FUNCTION + TRIGGER ON auth.users
-- ============================================================================
-- This trigger requires auth schema privileges (Project Owner only)

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
INSERT INTO public.users (id, phone, email, name, role)
VALUES (
    NEW.id,
    COALESCE(NEW.phone, NEW.raw_user_meta_data->>'phone'),
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'مستخدم جديد'),
    'customer'
)
ON CONFLICT (id) DO NOTHING;
RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ============================================================================
-- A3. BOOTSTRAP FIRST super_admin
-- ============================================================================
-- ⚠️ Replace 'YOUR-USER-UUID-HERE' with actual user ID before running
-- NOTE: Run this only once after creating the first user record in public.users (profile created).

-- SELECT set_config('app.role_update','1',true);
-- UPDATE public.users SET role='super_admin' WHERE id='YOUR-USER-UUID-HERE';
-- SELECT set_config('app.role_update','0',true);

-- ============================================================================
-- END OF FILE
-- ============================================================================
