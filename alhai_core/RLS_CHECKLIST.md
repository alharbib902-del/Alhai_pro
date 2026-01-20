# RLS (Row Level Security) Policy Checklist

## Overview

Supabase RLS policies must be configured to ensure:
1. Users can only access data they're authorized to see
2. Multi-tenant isolation (stores can't see each other's data)
3. Role-based access control

> ⚠️ **CRITICAL**: Always use separate policies for SELECT/INSERT/UPDATE/DELETE with appropriate USING and WITH CHECK clauses.

---

## Policy Structure Best Practice

```sql
-- SELECT/UPDATE/DELETE use USING
CREATE POLICY "policy_select" ON table_name
  FOR SELECT USING (condition);

-- INSERT uses WITH CHECK (no existing rows to check)
CREATE POLICY "policy_insert" ON table_name
  FOR INSERT WITH CHECK (condition);

-- UPDATE uses both USING (which rows) and WITH CHECK (new values valid)
CREATE POLICY "policy_update" ON table_name
  FOR UPDATE USING (can_access_row) WITH CHECK (new_values_valid);
```

---

## Core Policies

### 1. Users Table
```sql
-- Users can read their own profile
CREATE POLICY "users_select_own" ON users
  FOR SELECT USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "users_update_own" ON users
  FOR UPDATE USING (auth.uid() = id) 
  WITH CHECK (auth.uid() = id);
```

### 2. Stores Table
```sql
-- Store owners have full access
CREATE POLICY "stores_owner_select" ON stores
  FOR SELECT USING (owner_id = auth.uid());

CREATE POLICY "stores_owner_insert" ON stores
  FOR INSERT WITH CHECK (owner_id = auth.uid());

CREATE POLICY "stores_owner_update" ON stores
  FOR UPDATE USING (owner_id = auth.uid()) 
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "stores_owner_delete" ON stores
  FOR DELETE USING (owner_id = auth.uid());

-- Store staff can read their store
CREATE POLICY "stores_staff_select" ON stores
  FOR SELECT USING (
    id IN (SELECT store_id FROM store_staff WHERE user_id = auth.uid())
  );
```

### 3. Store Staff Table (جديد - مهم)
```sql
-- Only owner/admin can manage staff
CREATE POLICY "store_staff_owner_select" ON store_staff
  FOR SELECT USING (
    store_id IN (SELECT id FROM stores WHERE owner_id = auth.uid())
    OR user_id = auth.uid()
  );

CREATE POLICY "store_staff_owner_insert" ON store_staff
  FOR INSERT WITH CHECK (
    store_id IN (SELECT id FROM stores WHERE owner_id = auth.uid())
  );

CREATE POLICY "store_staff_owner_delete" ON store_staff
  FOR DELETE USING (
    store_id IN (SELECT id FROM stores WHERE owner_id = auth.uid())
  );
```

### 4. Products Table
```sql
-- Helper function for store membership check (SECURED with search_path)
CREATE OR REPLACE FUNCTION is_store_member(store_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.stores WHERE id = store_uuid AND owner_id = auth.uid()
    UNION
    SELECT 1 FROM public.store_staff WHERE store_id = store_uuid AND user_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
SET search_path = public;

-- Store members can manage products
CREATE POLICY "products_member_select" ON products
  FOR SELECT USING (is_store_member(store_id));

CREATE POLICY "products_member_insert" ON products
  FOR INSERT WITH CHECK (is_store_member(store_id));

CREATE POLICY "products_member_update" ON products
  FOR UPDATE USING (is_store_member(store_id)) 
  WITH CHECK (is_store_member(store_id));

CREATE POLICY "products_member_delete" ON products
  FOR DELETE USING (is_store_member(store_id));

-- ⚠️ NO products_public_select policy!
-- Public read access is handled via Edge Function (public-products)
-- which ENFORCES store_id at the database level with rate limiting.
-- See: supabase/functions/public-products/index.ts
```

### 5. Orders Table
```sql
-- Store members can manage orders
CREATE POLICY "orders_member_select" ON orders
  FOR SELECT USING (is_store_member(store_id));

CREATE POLICY "orders_member_insert" ON orders
  FOR INSERT WITH CHECK (is_store_member(store_id));

CREATE POLICY "orders_member_update" ON orders
  FOR UPDATE USING (is_store_member(store_id));

-- Customers can read their own orders
CREATE POLICY "orders_customer_select" ON orders
  FOR SELECT USING (customer_id = auth.uid());

-- Customers can create orders (for their own account)
CREATE POLICY "orders_customer_insert" ON orders
  FOR INSERT WITH CHECK (customer_id = auth.uid());
```

### 6. Deliveries Table
```sql
-- Drivers can see assigned deliveries
CREATE POLICY "deliveries_driver_select" ON deliveries
  FOR SELECT USING (driver_id = auth.uid());

-- Drivers can update delivery status
CREATE POLICY "deliveries_driver_update" ON deliveries
  FOR UPDATE USING (driver_id = auth.uid())
  WITH CHECK (driver_id = auth.uid());

-- Customers can track their deliveries
CREATE POLICY "deliveries_customer_select" ON deliveries
  FOR SELECT USING (
    order_id IN (SELECT id FROM orders WHERE customer_id = auth.uid())
  );

-- Store members can manage deliveries
CREATE POLICY "deliveries_member_select" ON deliveries
  FOR SELECT USING (
    order_id IN (SELECT id FROM orders WHERE is_store_member(store_id))
  );
```

### 7. Inventory Adjustments
```sql
CREATE POLICY "adjustments_member_select" ON stock_adjustments
  FOR SELECT USING (
    product_id IN (SELECT id FROM products WHERE is_store_member(store_id))
  );

CREATE POLICY "adjustments_member_insert" ON stock_adjustments
  FOR INSERT WITH CHECK (
    product_id IN (SELECT id FROM products WHERE is_store_member(store_id))
  );
```

### 8. Suppliers
```sql
CREATE POLICY "suppliers_member_select" ON suppliers
  FOR SELECT USING (is_store_member(store_id));

CREATE POLICY "suppliers_member_insert" ON suppliers
  FOR INSERT WITH CHECK (is_store_member(store_id));

CREATE POLICY "suppliers_member_update" ON suppliers
  FOR UPDATE USING (is_store_member(store_id)) 
  WITH CHECK (is_store_member(store_id));

CREATE POLICY "suppliers_member_delete" ON suppliers
  FOR DELETE USING (is_store_member(store_id));
```

### 9. Debts
```sql
CREATE POLICY "debts_member_select" ON debts
  FOR SELECT USING (is_store_member(store_id));

CREATE POLICY "debts_member_insert" ON debts
  FOR INSERT WITH CHECK (is_store_member(store_id));

CREATE POLICY "debts_member_update" ON debts
  FOR UPDATE USING (is_store_member(store_id));
```

---

## Verification Checklist

### Before Production
- [ ] All tables have RLS enabled (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`)
- [ ] All tables have at least one policy per operation type
- [ ] No tables use `FOR ALL USING (true)` in production
- [ ] Multi-tenant isolation verified
- [ ] store_staff table has proper RLS
- [ ] Products public read restricted by store_id in app layer

### Test Scenarios (Cross-Tenant Critical)
- [ ] ✅ User A (Store A) creates product
- [ ] ✅ User B (Store B) tries to read it → **403 FORBIDDEN**
- [ ] ✅ User B (Store B) tries to update it → **403 FORBIDDEN**
- [ ] ✅ User B (Store B) tries to delete it → **403 FORBIDDEN**
- [ ] ✅ Customers can only see their own orders
- [ ] ✅ Drivers can only see assigned deliveries
- [ ] ✅ Staff can only see their store's members

### Edge Cases
- [ ] New users have minimal permissions
- [ ] Deleted staff can't access store data
- [ ] Role changes take effect immediately
- [ ] Service role bypasses RLS (for admin functions)

---

## Integration Test Commands

```bash
# Run RLS tests
flutter test test/integration/ --tags=rls

# Run with real Supabase
flutter test test/integration/ --dart-define=USE_REAL_API=true

# Run cross-tenant isolation test specifically
flutter test test/integration/cross_tenant_test.dart
```

---

*Last Updated: 2026-01-19 v1.1.0*
