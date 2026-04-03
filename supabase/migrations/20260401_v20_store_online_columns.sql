-- ============================================================================
-- v20: إضافة أعمدة التوصيل للمتاجر + ربط العميل بنظام الكاشير
-- ============================================================================
-- هذا الملف يضيف الأعمدة اللازمة لتطبيق العميل:
-- 1. أعمدة التوصيل في جدول المتاجر (stores)
-- 2. إحداثيات المتجر (lat/lng) للبحث بالقرب
-- 3. ربط طلبات العميل بنظام المبيعات POS
-- ============================================================================

-- 1. أعمدة التوصيل والموقع في المتاجر
ALTER TABLE public.stores
  ADD COLUMN IF NOT EXISTS lat DECIMAL(10,8),
  ADD COLUMN IF NOT EXISTS lng DECIMAL(11,8),
  ADD COLUMN IF NOT EXISTS description TEXT,
  ADD COLUMN IF NOT EXISTS image_url TEXT,
  ADD COLUMN IF NOT EXISTS delivery_radius DECIMAL(6,2) DEFAULT 10.0,
  ADD COLUMN IF NOT EXISTS min_order_amount DECIMAL(10,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS delivery_fee DECIMAL(10,2) DEFAULT 0,
  ADD COLUMN IF NOT EXISTS accepts_delivery BOOLEAN DEFAULT true,
  ADD COLUMN IF NOT EXISTS accepts_pickup BOOLEAN DEFAULT true;

COMMENT ON COLUMN public.stores.lat IS 'خط العرض - لإظهار المتجر على الخريطة وحساب المسافة';
COMMENT ON COLUMN public.stores.lng IS 'خط الطول';
COMMENT ON COLUMN public.stores.delivery_radius IS 'نطاق التوصيل بالكيلومتر';
COMMENT ON COLUMN public.stores.min_order_amount IS 'الحد الأدنى للطلب بالريال';
COMMENT ON COLUMN public.stores.delivery_fee IS 'رسوم التوصيل الافتراضية';
COMMENT ON COLUMN public.stores.accepts_delivery IS 'هل المتجر يقبل طلبات توصيل';
COMMENT ON COLUMN public.stores.accepts_pickup IS 'هل المتجر يقبل استلام من المتجر';

-- 2. إنشاء جدول customer_addresses (نسخة مبسطة من addresses)
-- الجدول addresses الحالي يستخدم user_id → نعيد استخدامه مباشرة
-- لكن نضيف أعمدة مفقودة
ALTER TABLE public.addresses
  ADD COLUMN IF NOT EXISTS landmark TEXT;

-- 3. فهرس للبحث عن المتاجر القريبة
CREATE INDEX IF NOT EXISTS idx_stores_location
  ON public.stores (lat, lng)
  WHERE is_active = true AND lat IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_stores_delivery
  ON public.stores (is_active, accepts_delivery)
  WHERE is_active = true;

-- 4. فهرس طلبات العميل
CREATE INDEX IF NOT EXISTS idx_orders_customer_status
  ON public.orders (customer_id, status, created_at DESC);

-- 5. سياسة RLS: العميل يقدر يضيف ويقرأ عناوينه
-- (السياسة الحالية تسمح بالقراءة فقط - نضيف الإضافة والحذف)
DO $$
BEGIN
  -- Allow customers to insert their own addresses
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'addresses' AND policyname = 'addresses_customer_insert'
  ) THEN
    CREATE POLICY "addresses_customer_insert" ON public.addresses
      FOR INSERT TO authenticated
      WITH CHECK (user_id = auth.uid());
  END IF;

  -- Allow customers to delete their own addresses
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'addresses' AND policyname = 'addresses_customer_delete'
  ) THEN
    CREATE POLICY "addresses_customer_delete" ON public.addresses
      FOR DELETE TO authenticated
      USING (user_id = auth.uid());
  END IF;

  -- Allow customers to update their own addresses
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'addresses' AND policyname = 'addresses_customer_update'
  ) THEN
    CREATE POLICY "addresses_customer_update" ON public.addresses
      FOR UPDATE TO authenticated
      USING (user_id = auth.uid())
      WITH CHECK (user_id = auth.uid());
  END IF;
END $$;

-- 6. سياسة RLS: العميل يقدر ينشئ طلبات
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'orders' AND policyname = 'orders_customer_create'
  ) THEN
    CREATE POLICY "orders_customer_create" ON public.orders
      FOR INSERT TO authenticated
      WITH CHECK (customer_id = auth.uid());
  END IF;

  -- العميل يقدر يقرأ طلباته فقط
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'orders' AND policyname = 'orders_customer_read_own'
  ) THEN
    CREATE POLICY "orders_customer_read_own" ON public.orders
      FOR SELECT TO authenticated
      USING (customer_id = auth.uid());
  END IF;
END $$;

-- 7. سياسة RLS: العميل يقدر يضيف عناصر لطلبه
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'order_items' AND policyname = 'order_items_customer_insert'
  ) THEN
    CREATE POLICY "order_items_customer_insert" ON public.order_items
      FOR INSERT TO authenticated
      WITH CHECK (
        EXISTS (
          SELECT 1 FROM public.orders
          WHERE id = order_id AND customer_id = auth.uid()
        )
      );
  END IF;
END $$;

-- 8. سياسة RLS: العميل يقدر يقرأ بيانات مستخدمه
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'users' AND policyname = 'users_customer_upsert_own'
  ) THEN
    CREATE POLICY "users_customer_upsert_own" ON public.users
      FOR INSERT TO authenticated
      WITH CHECK (id = auth.uid());
  END IF;
END $$;

-- 9. تفعيل Realtime على جدول الطلبات (إذا لم يكن مفعل)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime' AND tablename = 'orders'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
  END IF;
END $$;
