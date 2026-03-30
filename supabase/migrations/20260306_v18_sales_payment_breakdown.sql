-- ============================================================================
-- Alhai Platform - Migration v18: تفصيل مبالغ الدفع في المبيعات
-- Version: 18
-- Date: 2026-03-06
-- Description: إضافة أعمدة cash_amount, card_amount, credit_amount
--              لتخزين تفاصيل كل طريقة دفع في الفواتير المختلطة
-- ============================================================================

-- إضافة أعمدة تفصيل مبالغ الدفع
ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS cash_amount DOUBLE PRECISION;
ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS card_amount DOUBLE PRECISION;
ALTER TABLE public.sales ADD COLUMN IF NOT EXISTS credit_amount DOUBLE PRECISION;

-- تعليق توضيحي
COMMENT ON COLUMN public.sales.cash_amount IS 'المبلغ المدفوع نقداً';
COMMENT ON COLUMN public.sales.card_amount IS 'المبلغ المدفوع بالبطاقة';
COMMENT ON COLUMN public.sales.credit_amount IS 'المبلغ الآجل (الدين)';
