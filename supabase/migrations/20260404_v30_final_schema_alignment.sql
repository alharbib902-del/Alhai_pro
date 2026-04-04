-- v30: Final schema alignment — fix remaining gaps between Drift and Supabase
-- Adds missing updated_at, org_id columns and triggers for bidirectional sync

BEGIN;

-- ============================================================
-- 1. customer_addresses: missing updated_at (needed for bidirectional sync ordering)
-- ============================================================
ALTER TABLE customer_addresses ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;

CREATE OR REPLACE FUNCTION trg_customer_addresses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_customer_addresses_updated_at ON customer_addresses;
CREATE TRIGGER set_customer_addresses_updated_at
  BEFORE UPDATE ON customer_addresses
  FOR EACH ROW EXECUTE FUNCTION trg_customer_addresses_updated_at();

-- ============================================================
-- 2. product_expiry: missing updated_at and org_id
-- ============================================================
ALTER TABLE product_expiry ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;
ALTER TABLE product_expiry ADD COLUMN IF NOT EXISTS org_id TEXT;

CREATE OR REPLACE FUNCTION trg_product_expiry_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_product_expiry_updated_at ON product_expiry;
CREATE TRIGGER set_product_expiry_updated_at
  BEFORE UPDATE ON product_expiry
  FOR EACH ROW EXECUTE FUNCTION trg_product_expiry_updated_at();

-- ============================================================
-- 3. stock_takes: missing updated_at and org_id
-- ============================================================
ALTER TABLE stock_takes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;
ALTER TABLE stock_takes ADD COLUMN IF NOT EXISTS org_id TEXT;

CREATE OR REPLACE FUNCTION trg_stock_takes_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_stock_takes_updated_at ON stock_takes;
CREATE TRIGGER set_stock_takes_updated_at
  BEFORE UPDATE ON stock_takes
  FOR EACH ROW EXECUTE FUNCTION trg_stock_takes_updated_at();

-- ============================================================
-- 4. stock_transfers: missing updated_at and org_id
-- ============================================================
ALTER TABLE stock_transfers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ;
ALTER TABLE stock_transfers ADD COLUMN IF NOT EXISTS org_id TEXT;

CREATE OR REPLACE FUNCTION trg_stock_transfers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_stock_transfers_updated_at ON stock_transfers;
CREATE TRIGGER set_stock_transfers_updated_at
  BEFORE UPDATE ON stock_transfers
  FOR EACH ROW EXECUTE FUNCTION trg_stock_transfers_updated_at();

-- ============================================================
-- 5. Add updated_at triggers for bidirectional tables that lack them
-- ============================================================

-- customers
CREATE OR REPLACE FUNCTION trg_customers_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS set_customers_updated_at ON customers;
CREATE TRIGGER set_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION trg_customers_updated_at();

-- expenses
CREATE OR REPLACE FUNCTION trg_expenses_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS set_expenses_updated_at ON expenses;
CREATE TRIGGER set_expenses_updated_at BEFORE UPDATE ON expenses FOR EACH ROW EXECUTE FUNCTION trg_expenses_updated_at();

-- purchases
CREATE OR REPLACE FUNCTION trg_purchases_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS set_purchases_updated_at ON purchases;
CREATE TRIGGER set_purchases_updated_at BEFORE UPDATE ON purchases FOR EACH ROW EXECUTE FUNCTION trg_purchases_updated_at();

-- shifts
CREATE OR REPLACE FUNCTION trg_shifts_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS set_shifts_updated_at ON shifts;
CREATE TRIGGER set_shifts_updated_at BEFORE UPDATE ON shifts FOR EACH ROW EXECUTE FUNCTION trg_shifts_updated_at();

-- suppliers
CREATE OR REPLACE FUNCTION trg_suppliers_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS set_suppliers_updated_at ON suppliers;
CREATE TRIGGER set_suppliers_updated_at BEFORE UPDATE ON suppliers FOR EACH ROW EXECUTE FUNCTION trg_suppliers_updated_at();

-- notifications
CREATE OR REPLACE FUNCTION trg_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS set_notifications_updated_at ON notifications;
CREATE TRIGGER set_notifications_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION trg_notifications_updated_at();

-- loyalty_points
CREATE OR REPLACE FUNCTION trg_loyalty_points_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS set_loyalty_points_updated_at ON loyalty_points;
CREATE TRIGGER set_loyalty_points_updated_at BEFORE UPDATE ON loyalty_points FOR EACH ROW EXECUTE FUNCTION trg_loyalty_points_updated_at();

-- whatsapp_templates
CREATE OR REPLACE FUNCTION trg_whatsapp_templates_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;
DROP TRIGGER IF EXISTS set_whatsapp_templates_updated_at ON whatsapp_templates;
CREATE TRIGGER set_whatsapp_templates_updated_at BEFORE UPDATE ON whatsapp_templates FOR EACH ROW EXECUTE FUNCTION trg_whatsapp_templates_updated_at();

COMMIT;
