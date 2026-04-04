-- Batch update order with items in a single transaction
CREATE OR REPLACE FUNCTION update_order_with_items(
  p_order_id UUID,
  p_status TEXT,
  p_notes TEXT DEFAULT NULL,
  p_item_prices JSONB DEFAULT NULL
) RETURNS BOOLEAN AS $$
BEGIN
  UPDATE orders SET status = p_status, notes = COALESCE(p_notes, notes), updated_at = NOW() WHERE id = p_order_id;

  IF p_item_prices IS NOT NULL THEN
    -- Update each item price from the JSONB
    UPDATE order_items oi SET
      unit_price = (p_item_prices->>oi.id::text)::numeric,
      total = quantity * (p_item_prices->>oi.id::text)::numeric
    WHERE oi.order_id = p_order_id AND p_item_prices ? oi.id::text;

    -- Recalculate order total
    UPDATE orders SET total = (SELECT COALESCE(SUM(total), 0) FROM order_items WHERE order_id = p_order_id) WHERE id = p_order_id;
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Batch update product prices in a single transaction
CREATE OR REPLACE FUNCTION batch_update_product_prices(
  p_org_id UUID,
  p_prices JSONB
) RETURNS BOOLEAN AS $$
BEGIN
  UPDATE products p SET
    price = (p_prices->>p.id::text)::numeric,
    updated_at = NOW()
  WHERE p.org_id = p_org_id AND p_prices ? p.id::text;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
