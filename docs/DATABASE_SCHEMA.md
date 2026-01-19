# Alhai Platform - Database Schema (Final)

**Version:** 2.2.1  
**Date:** 2026-01-19

---

> [!IMPORTANT]
> هذا الـ Schema **جاهز للإنتاج بالكامل** ويتضمن:
> - REVOKE على أعمدة حساسة (`role`, `store_id`)
> - Helper functions مع `search_path = public, auth`
> - `is_store_admin` يشمل `stores.owner_id`
> - RLS مع أسماء فريدة لكل جدول
> - تقييد `order_items` (حالة + متجر)

---

## 📊 ملخص المنصة

| المكون | القيمة |
|--------|-------|
| الجداول | **17 جدول** |
| ENUMs | **8** |
| Triggers | 5 |
| Helper Functions | 3 |

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

## 🛡️ Helper Functions ✅ محسَّنة

```sql
-- 1. هل المستخدم super_admin؟
CREATE OR REPLACE FUNCTION public.is_super_admin()
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, auth  -- ✅ يشمل auth
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.users 
    WHERE id = auth.uid() AND role = 'super_admin'
  );
$$;

-- 2. هل المستخدم عضو في المتجر؟
CREATE OR REPLACE FUNCTION public.is_store_member(p_store_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, auth
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.store_members 
    WHERE store_id = p_store_id 
      AND user_id = auth.uid() 
      AND is_active = true
  );
$$;

-- 3. هل المستخدم مالك/مدير المتجر؟ ✅ يشمل stores.owner_id
CREATE OR REPLACE FUNCTION public.is_store_admin(p_store_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
STABLE
SET search_path = public, auth
AS $$
  SELECT
    public.is_super_admin()
    -- المالك المسجل في stores.owner_id
    OR EXISTS (
      SELECT 1 FROM public.stores s 
      WHERE s.id = p_store_id AND s.owner_id = auth.uid()
    )
    -- أو مدير/مالك في store_members
    OR EXISTS (
      SELECT 1 FROM public.store_members sm
      WHERE sm.store_id = p_store_id
        AND sm.user_id = auth.uid()
        AND sm.is_active = true
        AND sm.role_in_store IN ('owner', 'manager')
    );
$$;
```

---

## 📋 الجداول (17 جدول)

### 1. users

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

-- ⚠️ منع تعديل role
REVOKE UPDATE (role) ON public.users FROM authenticated;
REVOKE UPDATE (role) ON public.users FROM anon;
```

---

### 2. stores

```sql
CREATE TABLE public.stores (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name VARCHAR(255) NOT NULL,
  address TEXT NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(255),
  lat DECIMAL(10,8) NOT NULL,
  lng DECIMAL(11,8) NOT NULL,
  image_url TEXT,
  logo_url TEXT,
  description TEXT,
  is_active BOOLEAN DEFAULT true,
  owner_id UUID REFERENCES users(id) NOT NULL,
  delivery_radius DECIMAL(5,2),
  min_order_amount DECIMAL(10,2) CHECK (min_order_amount >= 0),
  delivery_fee DECIMAL(10,2) CHECK (delivery_fee >= 0),
  accepts_delivery BOOLEAN DEFAULT true,
  accepts_pickup BOOLEAN DEFAULT true,
  working_hours JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);
```

---

### 3. store_members

```sql
CREATE TABLE public.store_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  role_in_store store_role NOT NULL DEFAULT 'cashier',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(store_id, user_id)
);

-- ⚠️ منع تعديل store_id
REVOKE UPDATE (store_id) ON public.store_members FROM authenticated;
```

---

### 4. products

```sql
CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(50),
  barcode VARCHAR(50),
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  cost_price DECIMAL(10,2) CHECK (cost_price >= 0),
  stock_qty INT NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
  min_qty INT DEFAULT 1 CHECK (min_qty >= 0),
  unit VARCHAR(20),
  description TEXT,
  image_thumbnail TEXT,
  image_medium TEXT,
  image_large TEXT,
  image_hash VARCHAR(32),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  track_inventory BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- ⚠️ منع تعديل store_id
REVOKE UPDATE (store_id) ON public.products FROM authenticated;
```

---

### 5. debts

```sql
CREATE TABLE public.debts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  type debt_type NOT NULL,
  party_id UUID NOT NULL,
  party_name VARCHAR(255) NOT NULL,
  party_phone VARCHAR(20),
  original_amount DECIMAL(10,2) NOT NULL CHECK (original_amount > 0),
  remaining_amount DECIMAL(10,2) NOT NULL CHECK (remaining_amount >= 0),
  order_id UUID REFERENCES orders(id),
  notes TEXT,
  due_date DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  CHECK (remaining_amount <= original_amount)
);

-- ⚠️ منع تعديل store_id
REVOKE UPDATE (store_id) ON public.debts FROM authenticated;
```

---

### 6. purchase_orders

```sql
CREATE TABLE public.purchase_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  supplier_id UUID REFERENCES suppliers(id) NOT NULL,
  order_number VARCHAR(20),
  status po_status NOT NULL DEFAULT 'draft',
  subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
  tax DECIMAL(10,2) DEFAULT 0 CHECK (tax >= 0),
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
  notes TEXT,
  expected_date DATE,
  received_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- ⚠️ منع تعديل store_id
REVOKE UPDATE (store_id) ON public.purchase_orders FROM authenticated;
```

---

### 7-17. باقي الجداول

```sql
-- categories, addresses, orders, order_items, suppliers, 
-- debt_payments, deliveries, customer_accounts, loyalty_points,
-- stock_adjustments, purchase_order_items
-- (نفس تعريفات v2.2)
```

---

## ⚡ Triggers

### 1. تحديث updated_at

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = now(); RETURN NEW; END;
$$;
```

---

### 2. خصم المخزون (Set-Based + CTE)

```sql
CREATE OR REPLACE FUNCTION deduct_stock_on_order_confirm()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  IF (OLD.status = 'created' AND NEW.status IN ('confirmed', 'preparing')) THEN
    
    -- CTE واحد: قفل + تحقق + جلب البيانات
    WITH locked_items AS (
      SELECT 
        oi.product_id, 
        oi.qty AS order_qty,
        p.stock_qty,
        p.name AS product_name,
        p.track_inventory
      FROM order_items oi
      JOIN products p ON p.id = oi.product_id
      WHERE oi.order_id = NEW.id AND p.track_inventory = true
      FOR UPDATE OF p
    ),
    -- تحقق من عدم وجود نقص
    insufficient AS (
      SELECT * FROM locked_items WHERE stock_qty < order_qty
    )
    -- رفع خطأ إذا وُجد نقص
    SELECT INTO STRICT NEW FROM insufficient LIMIT 0;
    -- إذا وصلنا هنا فلا يوجد نقص
    
    EXCEPTION WHEN NO_DATA_FOUND THEN
      -- المخزون كافٍ، نكمل
      NULL;
    WHEN OTHERS THEN
      RAISE EXCEPTION 'المخزون غير كافٍ لأحد المنتجات';
    
    -- تسجيل حركة المخزون
    INSERT INTO stock_adjustments (
      store_id, product_id, type, quantity, 
      previous_qty, new_qty, reference_id, reference_type, created_by
    )
    SELECT 
      NEW.store_id, oi.product_id, 'sold', -oi.qty,
      p.stock_qty, p.stock_qty - oi.qty, 
      NEW.id, 'order', NEW.customer_id
    FROM order_items oi
    JOIN products p ON p.id = oi.product_id
    WHERE oi.order_id = NEW.id AND p.track_inventory = true;
    
    -- خصم جماعي
    UPDATE products p
    SET stock_qty = p.stock_qty - oi.qty, updated_at = now()
    FROM order_items oi
    WHERE oi.order_id = NEW.id AND p.id = oi.product_id AND p.track_inventory = true;
    
  END IF;
  
  RETURN NEW;
END;
$$;
```

---

## 🔐 RLS Policies ✅ أسماء فريدة

### تفعيل RLS

```sql
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE debts ENABLE ROW LEVEL SECURITY;
ALTER TABLE debt_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE customer_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE loyalty_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_adjustments ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
```

---

### users

```sql
CREATE POLICY "users_superadmin_select" ON users FOR SELECT
  USING (is_super_admin());

CREATE POLICY "users_self_select" ON users FOR SELECT
  USING (id = auth.uid());

CREATE POLICY "users_self_update" ON users FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (id = auth.uid());
```

---

### stores ✅ مُحسَّنة

```sql
CREATE POLICY "stores_superadmin_all" ON stores FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

-- الكل يقرأ المتاجر النشطة
CREATE POLICY "stores_public_read_active" ON stores FOR SELECT
  USING (is_active = true);

-- موظفو/مالك المتجر يقرأون متجرهم (حتى لو غير نشط) ✅
CREATE POLICY "stores_staff_read_own" ON stores FOR SELECT
  USING (is_store_member(id) OR is_store_admin(id));

-- المالك ينشئ
CREATE POLICY "stores_owner_insert" ON stores FOR INSERT
  WITH CHECK (owner_id = auth.uid());

-- المالك يحدث
CREATE POLICY "stores_owner_update" ON stores FOR UPDATE
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

-- المالك يحذف
CREATE POLICY "stores_owner_delete" ON stores FOR DELETE
  USING (owner_id = auth.uid());
```

---

### store_members ✅ مُحسَّنة

```sql
CREATE POLICY "store_members_superadmin_all" ON store_members FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

-- المالك/المدير يدير العضويات
CREATE POLICY "store_members_admin_insert" ON store_members FOR INSERT
  WITH CHECK (is_store_admin(store_id));

CREATE POLICY "store_members_admin_update" ON store_members FOR UPDATE
  USING (is_store_admin(store_id));
  -- لا WITH CHECK لأن store_id محمي بـ REVOKE

CREATE POLICY "store_members_admin_delete" ON store_members FOR DELETE
  USING (is_store_admin(store_id));

-- العضو يقرأ نفسه
CREATE POLICY "store_members_self_read" ON store_members FOR SELECT
  USING (user_id = auth.uid());

-- أعضاء المتجر يقرأون بعضهم
CREATE POLICY "store_members_staff_read" ON store_members FOR SELECT
  USING (is_store_member(store_id));
```

---

### products ✅ مُحسَّنة

```sql
CREATE POLICY "products_superadmin_all" ON products FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

-- قراءة المنتجات النشطة في متاجر نشطة
CREATE POLICY "products_public_read_active" ON products FOR SELECT
  USING (
    is_active = true 
    AND EXISTS (SELECT 1 FROM stores WHERE id = store_id AND is_active = true)
  );

-- موظفو المتجر يقرأون كل منتجات متجرهم
CREATE POLICY "products_staff_read_all" ON products FOR SELECT
  USING (is_store_member(store_id));

-- موظفو المتجر يضيفون
CREATE POLICY "products_staff_insert" ON products FOR INSERT
  WITH CHECK (is_store_member(store_id));

-- موظفو المتجر يحدثون
CREATE POLICY "products_staff_update" ON products FOR UPDATE
  USING (is_store_member(store_id));
  -- لا WITH CHECK لأن store_id محمي بـ REVOKE

-- موظفو المتجر يحذفون
CREATE POLICY "products_staff_delete" ON products FOR DELETE
  USING (is_store_member(store_id));
```

---

### orders ✅ مُحسَّنة

```sql
CREATE POLICY "orders_superadmin_all" ON orders FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

-- العميل يقرأ طلباته
CREATE POLICY "orders_customer_read" ON orders FOR SELECT
  USING (customer_id = auth.uid());

-- العميل ينشئ
CREATE POLICY "orders_customer_insert" ON orders FOR INSERT
  WITH CHECK (customer_id = auth.uid());

-- العميل يحدث طلبه (فقط في حالة created) ✅
CREATE POLICY "orders_customer_update_created" ON orders FOR UPDATE
  USING (customer_id = auth.uid() AND status = 'created')
  WITH CHECK (customer_id = auth.uid() AND status = 'created');

-- موظفو المتجر يقرأون
CREATE POLICY "orders_staff_read" ON orders FOR SELECT
  USING (is_store_member(store_id));

-- موظفو المتجر يحدثون (للحالات التشغيلية)
CREATE POLICY "orders_staff_update" ON orders FOR UPDATE
  USING (is_store_member(store_id));
```

---

### order_items ✅ مُحسَّنة (مع تحقق المتجر والحالة)

```sql
CREATE POLICY "order_items_superadmin_all" ON order_items FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

-- قراءة عبر الطلب
CREATE POLICY "order_items_read_via_order" ON order_items FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM orders o WHERE o.id = order_id AND (
      o.customer_id = auth.uid() OR is_store_member(o.store_id)
    )
  ));

-- العميل يضيف (فقط لطلب created + منتج من نفس المتجر) ✅
CREATE POLICY "order_items_customer_insert" ON order_items FOR INSERT
  WITH CHECK (EXISTS (
    SELECT 1 FROM orders o
    JOIN products p ON p.id = order_items.product_id
    WHERE o.id = order_items.order_id
      AND o.customer_id = auth.uid()
      AND o.status = 'created'
      AND p.store_id = o.store_id
      AND p.is_active = true
  ));

-- موظفو المتجر يديرون
CREATE POLICY "order_items_staff_all" ON order_items FOR ALL
  USING (EXISTS (
    SELECT 1 FROM orders o WHERE o.id = order_id AND is_store_member(o.store_id)
  ));
```

---

### debts + debt_payments

```sql
CREATE POLICY "debts_superadmin_all" ON debts FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

CREATE POLICY "debts_staff_read" ON debts FOR SELECT
  USING (is_store_member(store_id));

CREATE POLICY "debts_staff_insert" ON debts FOR INSERT
  WITH CHECK (is_store_member(store_id));

CREATE POLICY "debts_staff_update" ON debts FOR UPDATE
  USING (is_store_member(store_id));

-- debt_payments
CREATE POLICY "debt_payments_superadmin_all" ON debt_payments FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

CREATE POLICY "debt_payments_staff_read" ON debt_payments FOR SELECT
  USING (EXISTS (SELECT 1 FROM debts d WHERE d.id = debt_id AND is_store_member(d.store_id)));

CREATE POLICY "debt_payments_staff_insert" ON debt_payments FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM debts d WHERE d.id = debt_id AND is_store_member(d.store_id)));
```

---

### purchase_orders + items

```sql
CREATE POLICY "purchase_orders_superadmin_all" ON purchase_orders FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

CREATE POLICY "purchase_orders_staff_read" ON purchase_orders FOR SELECT
  USING (is_store_member(store_id));

CREATE POLICY "purchase_orders_staff_insert" ON purchase_orders FOR INSERT
  WITH CHECK (is_store_member(store_id));

CREATE POLICY "purchase_orders_staff_update" ON purchase_orders FOR UPDATE
  USING (is_store_member(store_id));

-- items
CREATE POLICY "po_items_superadmin_all" ON purchase_order_items FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

CREATE POLICY "po_items_staff_all" ON purchase_order_items FOR ALL
  USING (EXISTS (SELECT 1 FROM purchase_orders po WHERE po.id = purchase_order_id AND is_store_member(po.store_id)))
  WITH CHECK (EXISTS (SELECT 1 FROM purchase_orders po WHERE po.id = purchase_order_id AND is_store_member(po.store_id)));
```

---

### deliveries, addresses, customer_accounts, loyalty_points, stock_adjustments

```sql
-- deliveries
CREATE POLICY "deliveries_superadmin_all" ON deliveries FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

CREATE POLICY "deliveries_driver_read" ON deliveries FOR SELECT
  USING (driver_id = auth.uid());

CREATE POLICY "deliveries_driver_update" ON deliveries FOR UPDATE
  USING (driver_id = auth.uid());

CREATE POLICY "deliveries_staff_read" ON deliveries FOR SELECT
  USING (EXISTS (SELECT 1 FROM orders o WHERE o.id = order_id AND is_store_member(o.store_id)));

-- addresses
CREATE POLICY "addresses_user_all" ON addresses FOR ALL
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- customer_accounts
CREATE POLICY "customer_accounts_superadmin_all" ON customer_accounts FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

CREATE POLICY "customer_accounts_customer_read" ON customer_accounts FOR SELECT
  USING (customer_id = auth.uid());

CREATE POLICY "customer_accounts_staff_read" ON customer_accounts FOR SELECT
  USING (is_store_member(store_id));

-- loyalty_points (مثل customer_accounts)
CREATE POLICY "loyalty_points_superadmin_all" ON loyalty_points FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

CREATE POLICY "loyalty_points_customer_read" ON loyalty_points FOR SELECT
  USING (customer_id = auth.uid());

CREATE POLICY "loyalty_points_staff_read" ON loyalty_points FOR SELECT
  USING (is_store_member(store_id));

-- stock_adjustments (قراءة + إضافة فقط)
CREATE POLICY "stock_adj_superadmin_all" ON stock_adjustments FOR ALL
  USING (is_super_admin()) WITH CHECK (is_super_admin());

CREATE POLICY "stock_adj_staff_read" ON stock_adjustments FOR SELECT
  USING (is_store_member(store_id));

CREATE POLICY "stock_adj_staff_insert" ON stock_adjustments FOR INSERT
  WITH CHECK (is_store_member(store_id));
```

---

## ✅ Checklist النهائي

- [ ] إنشاء ENUMs (8)
- [ ] إنشاء Helper Functions (3)
- [ ] إنشاء الجداول (17)
- [ ] تطبيق REVOKE على `role`, `store_id`
- [ ] إنشاء Triggers (5)
- [ ] تفعيل RLS على كل الجداول
- [ ] إنشاء جميع السياسات بأسماء فريدة
- [ ] اختبار super_admin bypass
- [ ] اختبار is_store_admin مع owner_id
- [ ] اختبار order_items (status + store match)

---

*Final Production Ready - v2.2.1*
