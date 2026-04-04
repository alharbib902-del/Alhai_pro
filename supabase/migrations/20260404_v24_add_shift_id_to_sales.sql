-- ============================================================================
-- Migration v24: Add shift_id to sales table
-- Date: 2026-04-04
-- Purpose: The local Drift schema already has shift_id on sales for tracking
--          which cashier shift a sale belongs to. This migration adds the
--          column to Supabase so sync payloads can include it.
-- ============================================================================

ALTER TABLE public.sales
  ADD COLUMN IF NOT EXISTS shift_id TEXT REFERENCES public.shifts(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_sales_shift_id ON public.sales (shift_id);
