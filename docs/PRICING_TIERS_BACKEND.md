# Pricing Tiers Backend Schema

**Feature:** Per-store pricing tiers for distributor portal
**Status:** Schema design — requires Supabase migration to deploy
**Date:** 2026-04-16

---

## Overview

Each distributor creates their own pricing tiers (e.g., Gold/Silver/Regular).
Each tier has a `discount_percent`. Each store is assigned to one tier.
Final price = `product.price × (1 - discount_percent/100)`.

The distributor can override the calculated price per order line.

---

## Tables

### pricing_tiers

```sql
CREATE TABLE pricing_tiers (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  org_id uuid NOT NULL REFERENCES organizations(id),
  name text NOT NULL,
  name_ar text,
  discount_percent numeric(5,2) NOT NULL DEFAULT 0
    CHECK (discount_percent >= 0 AND discount_percent <= 100),
  is_default boolean DEFAULT false,
  sort_order int DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz,

  UNIQUE (org_id, name)
);

-- Ensure only one default tier per org
CREATE UNIQUE INDEX pricing_tiers_one_default
  ON pricing_tiers (org_id) WHERE is_default = true;
```

### distributor_store_tiers

```sql
CREATE TABLE distributor_store_tiers (
  org_id uuid NOT NULL REFERENCES organizations(id),
  store_id uuid NOT NULL REFERENCES stores(id),
  tier_id uuid NOT NULL REFERENCES pricing_tiers(id),
  assigned_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (org_id, store_id)
);
```

---

## RLS Policies

```sql
ALTER TABLE pricing_tiers ENABLE ROW LEVEL SECURITY;
ALTER TABLE distributor_store_tiers ENABLE ROW LEVEL SECURITY;

-- pricing_tiers: org members can manage their own tiers
CREATE POLICY pricing_tiers_org_all ON pricing_tiers
  FOR ALL TO authenticated
  USING (
    org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid())
  )
  WITH CHECK (
    org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid())
  );

-- distributor_store_tiers: org members can manage assignments
CREATE POLICY distributor_store_tiers_org_all ON distributor_store_tiers
  FOR ALL TO authenticated
  USING (
    org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid())
  )
  WITH CHECK (
    org_id IN (SELECT org_id FROM profiles WHERE id = auth.uid())
  );
```

---

## RPC: Get or assign default tier

```sql
CREATE OR REPLACE FUNCTION get_or_assign_default_tier(
  p_org_id uuid,
  p_store_id uuid
) RETURNS uuid AS $$
DECLARE
  v_tier_id uuid;
BEGIN
  -- Check existing assignment
  SELECT tier_id INTO v_tier_id
  FROM distributor_store_tiers
  WHERE org_id = p_org_id AND store_id = p_store_id;

  IF v_tier_id IS NOT NULL THEN
    RETURN v_tier_id;
  END IF;

  -- Get default tier for org
  SELECT id INTO v_tier_id
  FROM pricing_tiers
  WHERE org_id = p_org_id AND is_default = true
  LIMIT 1;

  -- If no default, return NULL (no discount applied)
  IF v_tier_id IS NULL THEN
    RETURN NULL;
  END IF;

  -- Auto-assign
  INSERT INTO distributor_store_tiers (org_id, store_id, tier_id)
  VALUES (p_org_id, p_store_id, v_tier_id);

  RETURN v_tier_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

---

## Notes

- Uses `org_id` (not `distributor_id`) to match the existing distributor_portal pattern
- The partial unique index on `is_default` ensures only one default tier per org
- Client-side handles `42P01` (table not found) gracefully — shows "feature not enabled" message
- The frontend works offline-ready: if tables don't exist, tier features are hidden/disabled
