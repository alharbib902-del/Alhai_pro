-- ═══════════════════════════════════════════════════════════════
-- Migration v15: Invoices Table (ZATCA-compliant)
-- ═══════════════════════════════════════════════════════════════
-- Supports: simplified_tax (B2C), standard_tax (B2B),
--           credit_note, debit_note

-- ─── جدول الفواتير ───────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.invoices (
  id TEXT PRIMARY KEY,
  org_id TEXT,
  store_id TEXT NOT NULL REFERENCES public.stores(id) ON DELETE RESTRICT,

  -- بيانات الفاتورة
  invoice_number TEXT NOT NULL,
  invoice_type TEXT NOT NULL DEFAULT 'simplified_tax',
    -- simplified_tax | standard_tax | credit_note | debit_note
  status TEXT NOT NULL DEFAULT 'issued',
    -- draft | issued | sent | paid | partially_paid | overdue | cancelled | archived

  -- الربط
  sale_id TEXT,
  ref_invoice_id TEXT,       -- لإشعارات الدائن/المدين
  ref_reason TEXT,            -- سبب الإشعار

  -- العميل
  customer_id TEXT,
  customer_name TEXT,
  customer_phone TEXT,
  customer_email TEXT,
  customer_vat_number TEXT,   -- للفاتورة الضريبية B2B
  customer_address TEXT,

  -- المبالغ
  subtotal DOUBLE PRECISION DEFAULT 0,
  discount DOUBLE PRECISION DEFAULT 0,
  tax_rate DOUBLE PRECISION DEFAULT 15,  -- 15% VAT
  tax_amount DOUBLE PRECISION DEFAULT 0,
  total DOUBLE PRECISION DEFAULT 0,

  -- الدفع
  payment_method TEXT,        -- cash, card, mixed, credit, transfer
  amount_paid DOUBLE PRECISION DEFAULT 0,
  amount_due DOUBLE PRECISION DEFAULT 0,
  currency TEXT DEFAULT 'SAR',

  -- ZATCA
  zatca_hash TEXT,
  zatca_qr TEXT,
  zatca_uuid TEXT,

  -- الأرشفة
  pdf_url TEXT,               -- رابط PDF في Supabase Storage
  notes TEXT,

  -- الموظف
  created_by TEXT,
  cashier_name TEXT,

  -- التواريخ
  issued_at TIMESTAMPTZ,
  due_at TIMESTAMPTZ,
  paid_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  synced_at TIMESTAMPTZ
);

-- ─── الفهارس ───────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_invoices_store_id ON public.invoices(store_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_invoices_number ON public.invoices(store_id, invoice_number);
CREATE INDEX IF NOT EXISTS idx_invoices_type ON public.invoices(store_id, invoice_type);
CREATE INDEX IF NOT EXISTS idx_invoices_status ON public.invoices(status);
CREATE INDEX IF NOT EXISTS idx_invoices_created_at ON public.invoices(created_at);
CREATE INDEX IF NOT EXISTS idx_invoices_customer ON public.invoices(customer_id);
CREATE INDEX IF NOT EXISTS idx_invoices_sale ON public.invoices(sale_id);

-- ─── RLS ────────────────────────────────────────────────────────

ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

-- القراءة: أعضاء المنظمة فقط
CREATE POLICY "invoices_select_policy" ON public.invoices
  FOR SELECT USING (
    org_id IN (
      SELECT om.org_id FROM public.org_members om
      WHERE om.user_id = auth.uid()::TEXT
        AND om.is_active = true
    )
  );

-- الإنشاء: أعضاء المنظمة
CREATE POLICY "invoices_insert_policy" ON public.invoices
  FOR INSERT WITH CHECK (
    org_id IN (
      SELECT om.org_id FROM public.org_members om
      WHERE om.user_id = auth.uid()::TEXT
        AND om.is_active = true
    )
  );

-- التحديث: أعضاء المنظمة
CREATE POLICY "invoices_update_policy" ON public.invoices
  FOR UPDATE USING (
    org_id IN (
      SELECT om.org_id FROM public.org_members om
      WHERE om.user_id = auth.uid()::TEXT
        AND om.is_active = true
    )
  );

-- ─── Realtime ───────────────────────────────────────────────────

ALTER PUBLICATION supabase_realtime ADD TABLE public.invoices;

-- ═══════════════════════════════════════════════════════════════
-- Done: v15 invoices table
-- ═══════════════════════════════════════════════════════════════
