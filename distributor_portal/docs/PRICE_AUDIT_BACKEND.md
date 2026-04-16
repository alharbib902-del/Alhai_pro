# Price Audit Log - Backend SQL

## Overview

Creates a `price_audit_log` table to track all price changes with full audit trail.

## Migration

```sql
CREATE TABLE IF NOT EXISTS price_audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id text NOT NULL REFERENCES organizations(id),
  product_id text NOT NULL,
  product_name text NOT NULL,
  old_price numeric(10,2),
  new_price numeric(10,2) NOT NULL,
  changed_by uuid NOT NULL,
  changed_at timestamptz NOT NULL DEFAULT now(),
  reason text
);

-- Performance index for org+product queries sorted by date
CREATE INDEX idx_price_audit_org_product
  ON price_audit_log (org_id, product_id, changed_at DESC);

-- Index for date-range queries
CREATE INDEX idx_price_audit_org_date
  ON price_audit_log (org_id, changed_at DESC);
```

## RLS Policy

```sql
-- Enable RLS
ALTER TABLE price_audit_log ENABLE ROW LEVEL SECURITY;

-- Distributors can read their own org's audit log
CREATE POLICY price_audit_read ON price_audit_log
  FOR SELECT
  USING (org_id = (SELECT org_id FROM users WHERE id = auth.uid()));

-- Distributors can insert audit entries for their own org
CREATE POLICY price_audit_insert ON price_audit_log
  FOR INSERT
  WITH CHECK (org_id = (SELECT org_id FROM users WHERE id = auth.uid()));
```

## Integration

The frontend calls `_logPriceChange()` after each `updateProductPrice` or
`updateProductPrices` call. If the table doesn't exist (error code `42P01`),
the log call fails silently — the price update still succeeds.

## Rollback

```sql
DROP TABLE IF EXISTS price_audit_log;
```
