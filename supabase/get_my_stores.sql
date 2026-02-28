-- ============================================================================
-- get_my_stores() - RPC + store_members table setup
-- ============================================================================
-- Execute this in Supabase Dashboard -> SQL Editor
--
-- مصدر الحقيقة: Live DB schema (information_schema)
-- stores.id = TEXT, store_members.store_id = TEXT
-- ============================================================================

-- 1. إنشاء نوع store_role (إذا غير موجود)
DO $$ BEGIN
  CREATE TYPE store_role AS ENUM ('owner', 'manager', 'cashier');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- 2. إنشاء جدول store_members (يطابق Live DB)
CREATE TABLE IF NOT EXISTS public.store_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id TEXT NOT NULL,
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  role_in_store store_role NOT NULL DEFAULT 'cashier',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  UNIQUE(store_id, user_id)
);

-- 3. الفهارس
CREATE INDEX IF NOT EXISTS idx_store_members_user_active
  ON public.store_members (user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_store_members_store_id
  ON public.store_members (store_id);

-- 4. تفعيل RLS
ALTER TABLE public.store_members ENABLE ROW LEVEL SECURITY;

-- 5. سياسات RLS (مع حماية من التكرار)
DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename = 'store_members' AND policyname = 'store_members_self_read') THEN
    CREATE POLICY "store_members_self_read" ON public.store_members
      FOR SELECT USING (user_id = auth.uid());
  END IF;
END $$;

-- 6. إنشاء دالة get_my_stores
DROP FUNCTION IF EXISTS public.get_my_stores();

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

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.get_my_stores() TO authenticated;
