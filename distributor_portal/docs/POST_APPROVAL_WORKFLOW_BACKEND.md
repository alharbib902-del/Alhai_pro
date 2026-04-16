# Post-Approval Order Workflow - Backend SQL

## Overview

Extends the `orders.status` column to support post-approval workflow stages:
`approved → preparing → packed → shipped → delivered`

## Migration

```sql
-- Step 1: Check current constraint on orders.status
-- If using CHECK constraint, alter it to include new values:
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE orders ADD CONSTRAINT orders_status_check
  CHECK (status IN (
    'draft', 'sent', 'pending',
    'approved', 'rejected', 'received',
    'preparing', 'packed', 'shipped', 'delivered'
  ));

-- Step 2: Add timestamp tracking for workflow transitions
ALTER TABLE orders
  ADD COLUMN IF NOT EXISTS preparing_at timestamptz,
  ADD COLUMN IF NOT EXISTS packed_at timestamptz,
  ADD COLUMN IF NOT EXISTS shipped_at timestamptz,
  ADD COLUMN IF NOT EXISTS delivered_at timestamptz;

-- Step 3: Index for filtering by post-approval statuses
CREATE INDEX IF NOT EXISTS idx_orders_post_approval_status
  ON orders (org_id, status)
  WHERE status IN ('preparing', 'packed', 'shipped', 'delivered');
```

## RLS Policy

No new RLS rules needed — existing org_id-scoped policies already cover
status updates. The `update_order_with_items` RPC should accept the new
status values without changes (it validates on the client side).

## Backward Compatibility

- Old statuses (`draft`, `sent`, `approved`, `received`, `rejected`) remain valid.
- Existing orders with `approved` status can transition to either `received`
  (legacy) or `preparing` (new workflow).
- The frontend handles unknown statuses gracefully by displaying the raw string.

## Rollback

```sql
-- Remove new columns
ALTER TABLE orders
  DROP COLUMN IF EXISTS preparing_at,
  DROP COLUMN IF EXISTS packed_at,
  DROP COLUMN IF EXISTS shipped_at,
  DROP COLUMN IF EXISTS delivered_at;

-- Revert constraint
ALTER TABLE orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE orders ADD CONSTRAINT orders_status_check
  CHECK (status IN ('draft', 'sent', 'pending', 'approved', 'rejected', 'received'));
```
