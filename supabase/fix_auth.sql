-- ============================================================================
-- FIX AUTH: Delete broken manually-created records, restore proper trigger
-- Run this in Supabase SQL Editor as Project Owner
-- ============================================================================
-- HOTFIX: Already executed. UUIDs are specific to production environment.
-- NOTE: handle_new_user() is also defined in supabase_owner_only.sql (section A2).
-- ============================================================================

-- 1. Delete test user created during debugging
DELETE FROM auth.identities WHERE user_id = '5e399530-3b30-434a-bd2c-b9940b90d40d';
DELETE FROM auth.users WHERE id = '5e399530-3b30-434a-bd2c-b9940b90d40d';

-- 2. Clean up any public.users records for our broken users
DELETE FROM public.users WHERE id IN (
  'c4ddb40f-da7c-4573-a5a2-f4eb402c7581',
  '66b93e45-f649-497f-a190-18973ae544ba'
);

-- 3. Delete broken auth identities + users
DELETE FROM auth.identities WHERE user_id IN (
  'c4ddb40f-da7c-4573-a5a2-f4eb402c7581',
  '66b93e45-f649-497f-a190-18973ae544ba'
);
DELETE FROM auth.users WHERE id IN (
  'c4ddb40f-da7c-4573-a5a2-f4eb402c7581',
  '66b93e45-f649-497f-a190-18973ae544ba'
);

-- 4. Also delete any duplicate users from previous debugging
DELETE FROM auth.identities WHERE user_id NOT IN (SELECT id FROM auth.users);

-- 5. Ensure user_role enum exists
DO $$ BEGIN
  CREATE TYPE user_role AS ENUM ('super_admin', 'store_owner', 'employee', 'delivery', 'customer');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- 6. Restore proper handle_new_user trigger (creates public.users record)
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

-- 7. Recreate trigger on auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 8. Verify: should show 0 broken users
SELECT id, phone, email FROM auth.users
WHERE phone IN ('966500000001', '966500000002', '+966500000001', '+966500000002');
