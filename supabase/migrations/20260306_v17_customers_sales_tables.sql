-- ============================================================================
-- Alhai Platform - Migration v17: إنشاء جداول customers, sales, sale_items
-- Version: 17
-- Date: 2026-03-06
-- Description: هذه الجداول كانت موجودة في Drift المحلي لكن لم تُنشأ في Supabase
--              مما يسبب فشل مزامنة المبيعات (خصوصاً الآجل مع customer_id)
-- ============================================================================

-- ############################################################
-- 1. جدول العملاء (customers)
-- ############################################################

CREATE TABLE IF NOT EXISTS public.customers (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  store_id TEXT NOT NULL,
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  tax_number TEXT,
  type TEXT DEFAULT 'individual',
  notes TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

-- فهارس العملاء
CREATE INDEX IF NOT EXISTS idx_customers_store_id ON public.customers (store_id);
CREATE INDEX IF NOT EXISTS idx_customers_phone ON public.customers (phone);
CREATE INDEX IF NOT EXISTS idx_customers_name ON public.customers (name);
CREATE INDEX IF NOT EXISTS idx_customers_is_active ON public.customers (store_id, is_active);
CREATE INDEX IF NOT EXISTS idx_customers_org_id ON public.customers (org_id);

-- ############################################################
-- 2. جدول المبيعات (sales)
-- ############################################################

CREATE TABLE IF NOT EXISTS public.sales (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  receipt_no TEXT NOT NULL,
  store_id TEXT NOT NULL,
  cashier_id TEXT NOT NULL,
  terminal_id TEXT,

  -- العميل (اختياري - مرتبط بجدول customers)
  customer_id TEXT REFERENCES public.customers(id) ON DELETE SET NULL,
  customer_name TEXT,
  customer_phone TEXT,

  -- المبالغ
  subtotal DOUBLE PRECISION NOT NULL,
  discount DOUBLE PRECISION DEFAULT 0,
  tax DOUBLE PRECISION DEFAULT 0,
  total DOUBLE PRECISION NOT NULL,

  -- الدفع
  payment_method TEXT NOT NULL,  -- cash, card, mixed, credit
  is_paid BOOLEAN DEFAULT true,
  amount_received DOUBLE PRECISION,
  change_amount DOUBLE PRECISION,

  -- معلومات إضافية
  notes TEXT,
  channel TEXT DEFAULT 'POS',  -- POS, ONLINE

  -- الحالة
  status TEXT DEFAULT 'completed',  -- completed, voided, refunded

  -- التواريخ
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ
);

-- فهارس المبيعات
CREATE INDEX IF NOT EXISTS idx_sales_store_id ON public.sales (store_id);
CREATE INDEX IF NOT EXISTS idx_sales_cashier_id ON public.sales (cashier_id);
CREATE INDEX IF NOT EXISTS idx_sales_created_at ON public.sales (created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sales_status ON public.sales (status);
CREATE INDEX IF NOT EXISTS idx_sales_synced_at ON public.sales (synced_at);
CREATE INDEX IF NOT EXISTS idx_sales_store_created ON public.sales (store_id, created_at DESC);
CREATE UNIQUE INDEX IF NOT EXISTS idx_sales_store_receipt_unique ON public.sales (store_id, receipt_no);
CREATE INDEX IF NOT EXISTS idx_sales_customer_id ON public.sales (customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_payment_method ON public.sales (payment_method);

-- ############################################################
-- 3. جدول عناصر البيع (sale_items)
-- ############################################################

CREATE TABLE IF NOT EXISTS public.sale_items (
  id TEXT PRIMARY KEY,
  sale_id TEXT NOT NULL REFERENCES public.sales(id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  product_name TEXT NOT NULL,
  product_sku TEXT,
  product_barcode TEXT,

  -- الكميات والأسعار
  qty DOUBLE PRECISION NOT NULL,
  unit_price DOUBLE PRECISION NOT NULL,
  cost_price DOUBLE PRECISION,
  subtotal DOUBLE PRECISION NOT NULL,
  discount DOUBLE PRECISION DEFAULT 0,
  total DOUBLE PRECISION NOT NULL,

  -- ملاحظات
  notes TEXT
);

-- فهارس عناصر البيع
CREATE INDEX IF NOT EXISTS idx_sale_items_sale_id ON public.sale_items (sale_id);
CREATE INDEX IF NOT EXISTS idx_sale_items_product_id ON public.sale_items (product_id);

-- ############################################################
-- 4. تفعيل RLS وإنشاء السياسات
-- ############################################################

-- customers
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow authenticated full access" ON public.customers;
CREATE POLICY "Allow authenticated full access" ON public.customers
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- sales
ALTER TABLE public.sales ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow authenticated full access" ON public.sales;
CREATE POLICY "Allow authenticated full access" ON public.sales
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- sale_items
ALTER TABLE public.sale_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Allow authenticated full access" ON public.sale_items;
CREATE POLICY "Allow authenticated full access" ON public.sale_items
  FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ############################################################
-- 5. تحديث customer_addresses لإضافة FK إلى customers (إن لم يكن موجوداً)
-- ############################################################

-- لا نضيف FK لـ customer_addresses.customer_id لأنها TEXT
-- والعلاقة منطقية وليست فيزيائية (لتجنب مشاكل المزامنة)

-- ############################################################
-- تم بنجاح!
-- ############################################################
