-- Migration v44: Document manually-applied schema changes from 2026-04-18
-- These DDL statements were applied to live Supabase on 2026-04-18 via SQL Editor
-- to unblock P0-5 (_localOnlyColumns staleness fix).
-- Safe idempotent DDL — all use IF NOT EXISTS, can be re-run safely.

ALTER TABLE public.sales
  ADD COLUMN IF NOT EXISTS shift_id TEXT REFERENCES public.shifts(id) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS idx_sales_shift_id ON public.sales (shift_id);

ALTER TABLE public.sales
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
CREATE INDEX IF NOT EXISTS idx_sales_deleted_at
  ON public.sales (deleted_at)
  WHERE deleted_at IS NOT NULL;

ALTER TABLE public.returns
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ;
CREATE INDEX IF NOT EXISTS idx_returns_deleted_at
  ON public.returns (deleted_at)
  WHERE deleted_at IS NOT NULL;
