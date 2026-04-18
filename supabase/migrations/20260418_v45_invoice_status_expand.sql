-- Migration v45: Expand invoices.status CHECK to include statuses used by Drift/InvoicesDao
-- Context: v41 attempted CHECK with 6 statuses (draft/pending/issued/paid/void/cancelled)
--   but Drift code writes additional statuses: sent, partially_paid, overdue, archived.
-- Verified 2026-04-18: no prior constraint existed on production; invoices table empty.
-- Applied manually via SQL Editor on 2026-04-18.
-- NOT VALID is preserved to match v41 intent (existing rows not validated).
-- Safe idempotent DDL — DROP IF EXISTS then ADD CONSTRAINT.

ALTER TABLE public.invoices
  DROP CONSTRAINT IF EXISTS invoices_status_valid;

ALTER TABLE public.invoices
  ADD CONSTRAINT invoices_status_valid
  CHECK (status IS NULL OR status IN (
    'draft',
    'pending',
    'issued',
    'paid',
    'partially_paid',
    'sent',
    'overdue',
    'void',
    'cancelled',
    'archived'
  )) NOT VALID;
