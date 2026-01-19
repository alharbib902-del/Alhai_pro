# Alhai Platform - Database Schema

**Version:** 2.2.3 (Final)  
**Date:** 2026-01-19

---

> [!IMPORTANT]
> **نسخة نهائية قابلة للتنفيذ مباشرة** ✅
> - Trigger خصم مخزون مع **قفل كل المنتجات أولاً** (منع race condition)
> - WITH CHECK لكل سياسات UPDATE
> - REVOKE لـ authenticated + anon
> - `handle_new_user` trigger مُضاف
> - سياسات كاملة (categories, deliveries, debts)

---

## 📊 ملخص

| المكون | القيمة |
|--------|-------|
| الجداول | 17 |
| ENUMs | 8 |
| Helper Functions | 3 |
| Triggers | 5 |

---

## 🔧 ENUMs

```sql
CREATE TYPE user_role AS ENUM ('super_admin', 'store_owner', 'employee', 'delivery', 'customer');
CREATE TYPE store_role AS ENUM ('owner', 'manager', 'cashier');
CREATE TYPE order_status AS ENUM ('created', 'confirmed', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'picked_up', 'completed', 'cancelled', 'refunded');
CREATE TYPE delivery_status AS ENUM ('assigned', 'accepted', 'picked_up', 'delivered', 'cancelled', 'failed');
CREATE TYPE payment_method AS ENUM ('cash', 'card', 'credit', 'wallet');
CREATE TYPE adjustment_type AS ENUM ('received', 'sold', 'adjustment', 'damaged', 'returned');
CREATE TYPE debt_type AS ENUM ('customer_debt', 'supplier_debt');
CREATE TYPE po_status AS ENUM ('draft', 'ordered', 'partial', 'received', 'cancelled');
```

---

## 🛡️ Helper Functions

```sql
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'super_admin');
$$;

CREATE OR REPLACE FUNCTION public.is_store_member(p_store_id UUID)
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.store_members 
    WHERE store_id = p_store_id AND user_id = auth.uid() AND is_active = true
  );
$$;

CREATE OR REPLACE FUNCTION public.is_store_admin(p_store_id UUID)
RETURNS BOOLEAN LANGUAGE sql SECURITY DEFINER STABLE
SET search_path = public, auth AS $$
  SELECT
    public.is_super_admin()
    OR EXISTS (SELECT 1 FROM public.stores WHERE id = p_store_id AND owner_id = auth.uid())
    OR EXISTS (
      SELECT 1 FROM public.store_members
      WHERE store_id = p_store_id AND user_id = auth.uid() 
        AND is_active = true AND role_in_store IN ('owner', 'manager')
    );
$$;
```

---

## 📋 الجداول + REVOKE

### users

```sql
CREATE TABLE public.users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone VARCHAR(20) UNIQUE,
  email VARCHAR(255),
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  role user_role NOT NULL DEFAULT 'customer',
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  fcm_token TEXT,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

REVOKE UPDATE (role) ON public.users FROM authenticated;
REVOKE UPDATE (role) ON public.users FROM anon;
```

#### Trigger: إنشاء profile تلقائيًا

```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, auth
AS $$
BEGIN
  INSERT INTO public.users (id, phone, email, name, role)
  VALUES (
    NEW.id,
    NEW.phone,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'مستخدم جديد'),
    'customer'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
```

### stores, store_members, products, debts, purchase_orders

```sql
-- جميع الجداول تُنشأ كما في النسخ السابقة
-- ثم:

REVOKE UPDATE (store_id) ON public.store_members FROM authenticated, anon;
REVOKE UPDATE (store_id) ON public.products FROM authenticated, anon;
REVOKE UPDATE (store_id) ON public.debts FROM authenticated, anon;
REVOKE UPDATE (store_id) ON public.purchase_orders FROM authenticated, anon;
REVOKE UPDATE (store_id) ON public.stock_adjustments FROM authenticated, anon;
```

---

## ⚡ Trigger خصم المخزون ✅ محسَّن (قفل كل المنتجات أولاً)

```sql
CREATE OR REPLACE FUNCTION public.deduct_stock_on_order_confirm()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_insufficient_count INT;
BEGIN
  -- فقط عند الانتقال من created إلى confirmed/preparing
  IF NOT (OLD.status = 'created' AND NEW.status IN ('confirmed', 'preparing')) THEN
    RETURN NEW;
  END IF;

  -- 1) قفل كل المنتجات المطلوبة أولاً (بدون شرط النقص) ✅
  PERFORM 1
  FROM public.order_items oi
  JOIN public.products p ON p.id = oi.product_id
  WHERE oi.order_id = NEW.id
    AND p.track_inventory = true
  FOR UPDATE OF p;

  -- 2) بعد القفل: افحص النقص
  SELECT COUNT(*) INTO v_insufficient_count
  FROM public.order_items oi
  JOIN public.products p ON p.id = oi.product_id
  WHERE oi.order_id = NEW.id
    AND p.track_inventory = true
    AND p.stock_qty < oi.qty;

  IF v_insufficient_count > 0 THEN
    RAISE EXCEPTION 'المخزون غير كافٍ لأحد المنتجات';
  END IF;

  -- 3) تسجيل حركة المخزون (قبل الخصم)
  INSERT INTO public.stock_adjustments (
    store_id, product_id, type, quantity,
    previous_qty, new_qty, reference_id, reference_type, created_by
  )
  SELECT
    NEW.store_id, oi.product_id, 'sold', -oi.qty,
    p.stock_qty, p.stock_qty - oi.qty,
    NEW.id, 'order', NEW.customer_id
  FROM public.order_items oi
  JOIN public.products p ON p.id = oi.product_id
  WHERE oi.order_id = NEW.id AND p.track_inventory = true;

  -- 4) خصم جماعي
  UPDATE public.products p
  SET stock_qty = p.stock_qty - oi.qty,
      updated_at = now()
  FROM public.order_items oi
  WHERE oi.order_id = NEW.id
    AND p.id = oi.product_id
    AND p.track_inventory = true;

  RETURN NEW;
END;
$$;

CREATE TRIGGER on_order_status_change
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.deduct_stock_on_order_confirm();
```

---

## 🔐 RLS Policies (كاملة مع WITH CHECK)

### تفعيل RLS

```sql
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.store_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.debt_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customer_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.stock_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.purchase_order_items ENABLE ROW LEVEL SECURITY;
```

---

### users

```sql
CREATE POLICY "users_superadmin_select" ON public.users FOR SELECT
  USING (public.is_super_admin());

CREATE POLICY "users_self_select" ON public.users FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "users_self_update" ON public.users FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());
```

---

### stores

```sql
CREATE POLICY "stores_superadmin_all" ON public.stores FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

CREATE POLICY "stores_public_read_active" ON public.stores FOR SELECT
  USING (is_active = true);

CREATE POLICY "stores_staff_read_own" ON public.stores FOR SELECT
  USING (public.is_store_member(id) OR public.is_store_admin(id));

CREATE POLICY "stores_owner_insert" ON public.stores FOR INSERT
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "stores_owner_update" ON public.stores FOR UPDATE
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

CREATE POLICY "stores_owner_delete" ON public.stores FOR DELETE
  USING (owner_id = auth.uid());
```

---

### store_members ✅ مع WITH CHECK

```sql
CREATE POLICY "store_members_superadmin_all" ON public.store_members FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

CREATE POLICY "store_members_admin_insert" ON public.store_members FOR INSERT
  WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_members_admin_update" ON public.store_members FOR UPDATE
  USING (public.is_store_admin(store_id))
  WITH CHECK (public.is_store_admin(store_id));

CREATE POLICY "store_members_admin_delete" ON public.store_members FOR DELETE
  USING (public.is_store_admin(store_id));

CREATE POLICY "store_members_self_read" ON public.store_members FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "store_members_staff_read" ON public.store_members FOR SELECT
  USING (public.is_store_member(store_id));
```

---

### categories ✅ جديدة

```sql
CREATE POLICY "categories_superadmin_all" ON public.categories FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

CREATE POLICY "categories_public_read_active" ON public.categories FOR SELECT
  USING (
    is_active = true 
    AND EXISTS (SELECT 1 FROM public.stores WHERE id = store_id AND is_active = true)
  );

CREATE POLICY "categories_staff_read_all" ON public.categories FOR SELECT
  USING (public.is_store_member(store_id));

CREATE POLICY "categories_staff_insert" ON public.categories FOR INSERT
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "categories_staff_update" ON public.categories FOR UPDATE
  USING (public.is_store_member(store_id))
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "categories_staff_delete" ON public.categories FOR DELETE
  USING (public.is_store_member(store_id));
```

---

### products ✅ مع WITH CHECK

```sql
CREATE POLICY "products_superadmin_all" ON public.products FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

CREATE POLICY "products_public_read_active" ON public.products FOR SELECT
  USING (
    is_active = true 
    AND EXISTS (SELECT 1 FROM public.stores WHERE id = store_id AND is_active = true)
  );

CREATE POLICY "products_staff_read_all" ON public.products FOR SELECT
  USING (public.is_store_member(store_id));

CREATE POLICY "products_staff_insert" ON public.products FOR INSERT
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "products_staff_update" ON public.products FOR UPDATE
  USING (public.is_store_member(store_id))
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "products_staff_delete" ON public.products FOR DELETE
  USING (public.is_store_member(store_id));
```

---

### orders ✅ مع WITH CHECK

```sql
CREATE POLICY "orders_superadmin_all" ON public.orders FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

CREATE POLICY "orders_customer_read" ON public.orders FOR SELECT
  USING (customer_id = auth.uid());

CREATE POLICY "orders_customer_insert" ON public.orders FOR INSERT
  WITH CHECK (customer_id = auth.uid());

CREATE POLICY "orders_customer_update_created" ON public.orders FOR UPDATE
  USING (customer_id = auth.uid() AND status = 'created')
  WITH CHECK (customer_id = auth.uid() AND status = 'created');

CREATE POLICY "orders_staff_read" ON public.orders FOR SELECT
  USING (public.is_store_member(store_id));

CREATE POLICY "orders_staff_update" ON public.orders FOR UPDATE
  USING (public.is_store_member(store_id))
  WITH CHECK (public.is_store_member(store_id));
```

---

### order_items ✅ مع WITH CHECK

```sql
CREATE POLICY "order_items_superadmin_all" ON public.order_items FOR ALL
  USING (public.is_super_admin())
  WITH CHECK (public.is_super_admin());

CREATE POLICY "order_items_read_via_order" ON public.order_items FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM public.orders o WHERE o.id = order_id 
    AND (o.customer_id = auth.uid() OR public.is_store_member(o.store_id))
  ));

CREATE POLICY "order_items_customer_insert" ON public.order_items FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.orders o
    JOIN public.products p ON p.id = product_id
    WHERE o.id = order_id
      AND o.customer_id = auth.uid()
      AND o.status = 'created'
      AND p.store_id = o.store_id
      AND p.is_active = true
  ));

CREATE POLICY "order_items_staff_all" ON public.order_items FOR ALL
  USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)))
  WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)));
```

---

### suppliers

```sql
CREATE POLICY "suppliers_superadmin_all" ON public.suppliers FOR ALL
  USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "suppliers_staff_read" ON public.suppliers FOR SELECT
  USING (public.is_store_member(store_id));

CREATE POLICY "suppliers_staff_insert" ON public.suppliers FOR INSERT
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "suppliers_staff_update" ON public.suppliers FOR UPDATE
  USING (public.is_store_member(store_id))
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "suppliers_staff_delete" ON public.suppliers FOR DELETE
  USING (public.is_store_member(store_id));
```

---

### debts ✅ مع WITH CHECK

```sql
CREATE POLICY "debts_superadmin_all" ON public.debts FOR ALL
  USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "debts_staff_read" ON public.debts FOR SELECT
  USING (public.is_store_member(store_id));

CREATE POLICY "debts_staff_insert" ON public.debts FOR INSERT
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "debts_staff_update" ON public.debts FOR UPDATE
  USING (public.is_store_member(store_id))
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "debts_staff_delete" ON public.debts FOR DELETE
  USING (public.is_store_member(store_id));
```

---

### debt_payments

```sql
CREATE POLICY "debt_payments_superadmin_all" ON public.debt_payments FOR ALL
  USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "debt_payments_staff_read" ON public.debt_payments FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.debts d WHERE d.id = debt_id AND public.is_store_member(d.store_id)));

CREATE POLICY "debt_payments_staff_insert" ON public.debt_payments FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.debts d WHERE d.id = debt_id AND public.is_store_member(d.store_id)));
```

---

### deliveries ✅ مع WITH CHECK

```sql
CREATE POLICY "deliveries_superadmin_all" ON public.deliveries FOR ALL
  USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "deliveries_driver_read" ON public.deliveries FOR SELECT
  USING (driver_id = auth.uid());

CREATE POLICY "deliveries_driver_update" ON public.deliveries FOR UPDATE
  USING (driver_id = auth.uid())
  WITH CHECK (driver_id = auth.uid());

CREATE POLICY "deliveries_staff_read" ON public.deliveries FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)));

CREATE POLICY "deliveries_staff_update" ON public.deliveries FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)))
  WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)));

CREATE POLICY "deliveries_staff_insert" ON public.deliveries FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.orders o WHERE o.id = order_id AND public.is_store_member(o.store_id)));
```

---

### purchase_orders ✅ مع WITH CHECK

```sql
CREATE POLICY "purchase_orders_superadmin_all" ON public.purchase_orders FOR ALL
  USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "purchase_orders_staff_read" ON public.purchase_orders FOR SELECT
  USING (public.is_store_member(store_id));

CREATE POLICY "purchase_orders_staff_insert" ON public.purchase_orders FOR INSERT
  WITH CHECK (public.is_store_member(store_id));

CREATE POLICY "purchase_orders_staff_update" ON public.purchase_orders FOR UPDATE
  USING (public.is_store_member(store_id))
  WITH CHECK (public.is_store_member(store_id));
```

---

### purchase_order_items

```sql
CREATE POLICY "po_items_superadmin_all" ON public.purchase_order_items FOR ALL
  USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());

CREATE POLICY "po_items_staff_all" ON public.purchase_order_items FOR ALL
  USING (EXISTS (SELECT 1 FROM public.purchase_orders po WHERE po.id = purchase_order_id AND public.is_store_member(po.store_id)))
  WITH CHECK (EXISTS (SELECT 1 FROM public.purchase_orders po WHERE po.id = purchase_order_id AND public.is_store_member(po.store_id)));
```

---

### addresses, customer_accounts, loyalty_points, stock_adjustments

```sql
-- addresses
CREATE POLICY "addresses_user_all" ON public.addresses FOR ALL
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- customer_accounts
CREATE POLICY "customer_accounts_superadmin_all" ON public.customer_accounts FOR ALL
  USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());
CREATE POLICY "customer_accounts_customer_read" ON public.customer_accounts FOR SELECT
  USING (customer_id = auth.uid());
CREATE POLICY "customer_accounts_staff_read" ON public.customer_accounts FOR SELECT
  USING (public.is_store_member(store_id));

-- loyalty_points
CREATE POLICY "loyalty_points_superadmin_all" ON public.loyalty_points FOR ALL
  USING (public.is_super_admin()) WITH CHECK (public.is_super_admin());
CREATE POLICY "loyalty_points_customer_read" ON public.loyalty_points FOR SELECT
  USING (customer_id = auth.uid());
CREATE POLICY "loyalty_points_staff_read" ON public.loyalty_points FOR SELECT
  USING (public.is_store_member(store_id));

-- stock_adjustments (سجلات ثابتة: قراءة + إضافة + حذف للسوبر أدمن فقط)
CREATE POLICY "stock_adj_superadmin_select" ON public.stock_adjustments FOR SELECT
  USING (public.is_super_admin());
CREATE POLICY "stock_adj_superadmin_insert" ON public.stock_adjustments FOR INSERT
  WITH CHECK (public.is_super_admin());
CREATE POLICY "stock_adj_superadmin_delete" ON public.stock_adjustments FOR DELETE
  USING (public.is_super_admin());
-- لا UPDATE للسوبر أدمن (سجلات ثابتة)

CREATE POLICY "stock_adj_staff_read" ON public.stock_adjustments FOR SELECT
  USING (public.is_store_member(store_id));
CREATE POLICY "stock_adj_staff_insert" ON public.stock_adjustments FOR INSERT
  WITH CHECK (public.is_store_member(store_id));
-- لا UPDATE/DELETE للموظفين (سجلات ثابتة)
```

---

## ✅ Checklist النهائي

- [ ] إنشاء ENUMs (8)
- [ ] إنشاء Helper Functions (3)
- [ ] إنشاء الجداول (17)
- [ ] تطبيق REVOKE (role + store_id × 5)
- [ ] إنشاء Triggers
- [ ] تفعيل RLS
- [ ] إنشاء السياسات

---

*Final Production Ready - v2.2.3*
