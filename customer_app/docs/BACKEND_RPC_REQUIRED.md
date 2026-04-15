# Backend RPC Required: cancel_order_by_customer

## Problem

The RLS policy `orders_customer_update_created` only allows customers to UPDATE
orders where `status = 'created'`. The app's `cancelOrder` method previously
attempted a direct UPDATE for any cancellable status, which was silently blocked
by RLS for non-`created` orders. Worse, `release_reserved_stock` RPC executed
*before* the UPDATE, so stock was released without the order being cancelled.

**Verifier finding:** C3-2 (HIGH) — data inconsistency between stock and order status.

## Current Workaround

`OrdersDatasource.cancelOrder()` now routes by status:

- **`created`** — direct UPDATE (RLS-allowed path). Stock release + status update.
- **Other statuses** — calls `cancel_order_by_customer` RPC. If RPC is not
  deployed, shows a user-facing error asking them to contact the store.

## Required RPC

```sql
CREATE OR REPLACE FUNCTION cancel_order_by_customer(
  p_order_id UUID,
  p_reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_status TEXT;
  v_customer_id UUID;
BEGIN
  -- 1. Fetch order with row lock
  SELECT status, customer_id
    INTO v_status, v_customer_id
    FROM orders
   WHERE id = p_order_id
   FOR UPDATE;

  -- 2. Verify ownership
  IF v_customer_id IS NULL OR v_customer_id != auth.uid() THEN
    RAISE EXCEPTION 'Order not found or access denied';
  END IF;

  -- 3. Check cancellable status
  IF v_status NOT IN ('created', 'confirmed', 'preparing') THEN
    RETURN FALSE;
  END IF;

  -- 4. Release reserved stock (atomic, same transaction)
  PERFORM release_reserved_stock(p_order_id);

  -- 5. Cancel the order
  UPDATE orders
     SET status = 'cancelled',
         cancelled_at = NOW(),
         cancellation_reason = p_reason
   WHERE id = p_order_id;

  RETURN TRUE;
END;
$$;

-- Grant execute to authenticated users
GRANT EXECUTE ON FUNCTION cancel_order_by_customer(UUID, TEXT) TO authenticated;
```

## Impact Until Deployed

Customers can only cancel orders in `status = 'created'`. For confirmed/preparing
orders, the app shows: "لا يمكن إلغاء الطلب في حالته الحالية. يرجى التواصل مع المتجر."

## Testing

After deploying the RPC, verify:
1. Customer can cancel `confirmed` order — stock released + status = `cancelled`
2. Customer cannot cancel `delivered` order — returns false
3. Customer cannot cancel another user's order — raises exception
4. Stock release and status update are atomic (no partial state)
