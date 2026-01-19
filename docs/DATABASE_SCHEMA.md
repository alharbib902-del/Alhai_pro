# Alhai Platform - Database Schema (Production Ready)

**Version:** 2.1.0  
**Date:** 2026-01-19

---

> [!IMPORTANT]
> هذا الـ Schema **جاهز للإنتاج** ويتضمن:
> - ربط مع `auth.users` مع trigger آمن
> - `store_members` بدلاً من circular dependency
> - **8 ENUMs** للحالات
> - Triggers مع **قفل FOR UPDATE** ومنع السلبيات
> - RLS شامل لـ **17 جدول**
> - حماية `users.role` من التعديل

---

## 📊 ملخص المنصة

| المكون | القيمة |
|--------|-------|
| الجداول | **17 جدول** |
| ENUMs | **8** |
| Triggers | 5 |
| Functions | 4 |

---

## 🔧 ENUMs (تُنشأ أولاً)

```sql
-- 1. User roles
CREATE TYPE user_role AS ENUM (
  'super_admin',
  'store_owner', 
  'employee',
  'delivery',
  'customer'
);

-- 2. Store member role
CREATE TYPE store_role AS ENUM (
  'owner',
  'manager',
  'cashier'
);

-- 3. Order status
CREATE TYPE order_status AS ENUM (
  'created',
  'confirmed',
  'preparing',
  'ready',
  'out_for_delivery',
  'delivered',
  'picked_up',
  'completed',
  'cancelled',
  'refunded'
);

-- 4. Delivery status
CREATE TYPE delivery_status AS ENUM (
  'assigned',
  'accepted',
  'picked_up',
  'delivered',
  'cancelled',
  'failed'
);

-- 5. Payment method
CREATE TYPE payment_method AS ENUM (
  'cash',
  'card',
  'credit',
  'wallet'
);

-- 6. Stock adjustment type
CREATE TYPE adjustment_type AS ENUM (
  'received',
  'sold',
  'adjustment',
  'damaged',
  'returned'
);

-- 7. Debt type
CREATE TYPE debt_type AS ENUM (
  'customer_debt',
  'supplier_debt'
);

-- 8. Purchase order status
CREATE TYPE po_status AS ENUM (
  'draft',
  'ordered',
  'partial',
  'received',
  'cancelled'
);
```

---

## 📋 الجداول (17 جدول)

### 1. users (مرتبط بـ auth.users)

```sql
CREATE TABLE users (
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

-- ⚠️ منع تعديل role من العميل
REVOKE UPDATE (role) ON users FROM authenticated;
```

#### Trigger: إنشاء profile آمن ✅ محسَّن

```sql
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (id, phone, email, name, role)
  VALUES (
    NEW.id,
    NEW.phone,  -- قد يكون NULL
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'مستخدم جديد'),
    'customer'
  )
  ON CONFLICT (id) DO NOTHING;  -- منع التكرار
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();
```

---

### 2. stores (المتاجر)

```sql
CREATE TABLE stores (
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
  working_hours JSONB,  -- Schema موحد أدناه
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- فهرس للبحث
CREATE INDEX idx_stores_active ON stores(is_active);
CREATE INDEX idx_stores_owner ON stores(owner_id);
```

#### Working Hours JSONB Schema

```json
{
  "saturday":  {"open": "08:00", "close": "22:00", "closed": false},
  "sunday":    {"open": "08:00", "close": "22:00", "closed": false},
  "monday":    {"open": "08:00", "close": "22:00", "closed": false},
  "tuesday":   {"open": "08:00", "close": "22:00", "closed": false},
  "wednesday": {"open": "08:00", "close": "22:00", "closed": false},
  "thursday":  {"open": "08:00", "close": "22:00", "closed": false},
  "friday":    {"open": "14:00", "close": "22:00", "closed": false}
}
```

---

### 3. store_members (عضويات المتجر)

```sql
CREATE TABLE store_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  role_in_store store_role NOT NULL DEFAULT 'cashier',
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(store_id, user_id)
);

CREATE INDEX idx_store_members_user ON store_members(user_id);
CREATE INDEX idx_store_members_store ON store_members(store_id, is_active);
```

---

### 4. categories (التصنيفات)

```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  sort_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_categories_store ON categories(store_id, is_active);
```

---

### 5. products (المنتجات)

```sql
CREATE TABLE products (
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

CREATE INDEX idx_products_barcode ON products(barcode, store_id) WHERE barcode IS NOT NULL;
CREATE INDEX idx_products_store ON products(store_id, is_active);
CREATE INDEX idx_products_category ON products(store_id, category_id, is_active);
```

---

### 6. addresses (العناوين)

```sql
CREATE TABLE addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  label VARCHAR(50),
  address_line TEXT NOT NULL,
  lat DECIMAL(10,8) NOT NULL,
  lng DECIMAL(11,8) NOT NULL,
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- عنوان افتراضي واحد فقط لكل مستخدم
CREATE UNIQUE INDEX idx_addresses_default 
  ON addresses(user_id) WHERE is_default = true;
```

---

### 7. orders (الطلبات)

```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number VARCHAR(20),
  customer_id UUID REFERENCES users(id) NOT NULL,
  customer_name VARCHAR(255),  -- Snapshot
  customer_phone VARCHAR(20),   -- Snapshot
  store_id UUID REFERENCES stores(id) NOT NULL,
  store_name VARCHAR(255),      -- Snapshot
  status order_status NOT NULL DEFAULT 'created',
  subtotal DECIMAL(10,2) NOT NULL CHECK (subtotal >= 0),
  discount DECIMAL(10,2) DEFAULT 0 CHECK (discount >= 0),
  delivery_fee DECIMAL(10,2) DEFAULT 0 CHECK (delivery_fee >= 0),
  tax DECIMAL(10,2) DEFAULT 0 CHECK (tax >= 0),
  total DECIMAL(10,2) NOT NULL CHECK (total >= 0),
  payment_method payment_method NOT NULL,
  is_paid BOOLEAN DEFAULT false,
  address_id UUID REFERENCES addresses(id),
  notes TEXT,
  cancellation_reason TEXT,
  confirmed_at TIMESTAMPTZ,
  preparing_at TIMESTAMPTZ,
  ready_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  UNIQUE(store_id, order_number)
);

CREATE INDEX idx_orders_store_status ON orders(store_id, status);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_orders_store_date ON orders(store_id, created_at DESC);
```

---

### 8. order_items (عناصر الطلب)

```sql
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
  qty INT NOT NULL CHECK (qty > 0),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_order_items_order ON order_items(order_id);
```

---

### 9. suppliers (الموردون)

```sql
CREATE TABLE suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  email VARCHAR(255),
  address TEXT,
  notes TEXT,
  balance DECIMAL(10,2) DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX idx_suppliers_store ON suppliers(store_id, is_active);
```

---

### 10. debts (الديون)

```sql
CREATE TABLE debts (
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

CREATE INDEX idx_debts_store ON debts(store_id, type);
CREATE INDEX idx_debts_party ON debts(party_id);
```

---

### 11. debt_payments (سداد الديون)

```sql
CREATE TABLE debt_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  debt_id UUID REFERENCES debts(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10,2) NOT NULL CHECK (amount > 0),
  notes TEXT,
  payment_method payment_method,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 12. deliveries (التوصيلات)

```sql
CREATE TABLE deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) NOT NULL,
  driver_id UUID REFERENCES users(id) NOT NULL,
  status delivery_status NOT NULL DEFAULT 'assigned',
  driver_name VARCHAR(255),
  driver_phone VARCHAR(20),
  driver_lat DECIMAL(10,8),
  driver_lng DECIMAL(11,8),
  estimated_arrival TIMESTAMPTZ,
  picked_up_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX idx_deliveries_driver ON deliveries(driver_id, status);
CREATE INDEX idx_deliveries_order ON deliveries(order_id);
```

---

### 13. customer_accounts (حسابات العملاء)

```sql
CREATE TABLE customer_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  balance DECIMAL(10,2) DEFAULT 0,
  credit_limit DECIMAL(10,2) DEFAULT 500 CHECK (credit_limit >= 0),
  is_active BOOLEAN DEFAULT true,
  total_orders INT DEFAULT 0,
  completed_orders INT DEFAULT 0,
  cancelled_orders INT DEFAULT 0,
  last_order_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  UNIQUE(customer_id, store_id)
);
```

---

### 14. loyalty_points (نقاط الولاء)

```sql
CREATE TABLE loyalty_points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  points INT DEFAULT 0 CHECK (points >= 0),
  total_earned INT DEFAULT 0,
  total_redeemed INT DEFAULT 0,
  tier VARCHAR(20) DEFAULT 'bronze',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  UNIQUE(customer_id, store_id)
);
```

---

### 15. stock_adjustments (تعديلات المخزون)

```sql
CREATE TABLE stock_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE NOT NULL,
  type adjustment_type NOT NULL,
  quantity INT NOT NULL,
  previous_qty INT NOT NULL,
  new_qty INT NOT NULL,
  reason TEXT,
  reference_id UUID,
  reference_type VARCHAR(20),
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_stock_adj_product ON stock_adjustments(product_id, created_at DESC);
```

---

### 16. purchase_orders (أوامر الشراء)

```sql
CREATE TABLE purchase_orders (
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
```

---

### 17. purchase_order_items

```sql
CREATE TABLE purchase_order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  purchase_order_id UUID REFERENCES purchase_orders(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  qty INT NOT NULL CHECK (qty > 0),
  cost_price DECIMAL(10,2) NOT NULL CHECK (cost_price >= 0),
  line_total DECIMAL(10,2) NOT NULL CHECK (line_total >= 0),
  received_qty INT DEFAULT 0 CHECK (received_qty >= 0),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_po_items_order ON purchase_order_items(purchase_order_id);
```

---

## ⚡ Triggers (مُحسَّنة للأمان)

### 1. تحديث updated_at تلقائيًا

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- تطبيق على الجداول
CREATE TRIGGER set_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON stores FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON debts FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON deliveries FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON suppliers FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON customer_accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON loyalty_points FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER set_updated_at BEFORE UPDATE ON purchase_orders FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

---

### 2. خصم المخزون عند تأكيد الطلب ✅ محسَّن

```sql
CREATE OR REPLACE FUNCTION deduct_stock_on_order_confirm()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_item RECORD;
  v_current_stock INT;
BEGIN
  -- فقط عند الانتقال من created إلى confirmed/preparing
  IF (OLD.status = 'created' AND NEW.status IN ('confirmed', 'preparing')) THEN
    
    -- قفل + تحقق + خصم لكل عنصر
    FOR v_item IN 
      SELECT oi.product_id, oi.qty, p.name, p.stock_qty, p.track_inventory
      FROM order_items oi
      JOIN products p ON p.id = oi.product_id
      WHERE oi.order_id = NEW.id
      FOR UPDATE OF p  -- قفل الصف
    LOOP
      IF v_item.track_inventory THEN
        -- تحقق من توفر الكمية
        IF v_item.stock_qty < v_item.qty THEN
          RAISE EXCEPTION 'المخزون غير كافٍ للمنتج: % (متوفر: %, مطلوب: %)', 
            v_item.name, v_item.stock_qty, v_item.qty;
        END IF;
        
        -- خصم المخزون
        UPDATE products 
        SET stock_qty = stock_qty - v_item.qty,
            updated_at = now()
        WHERE id = v_item.product_id;
        
        -- تسجيل الحركة
        INSERT INTO stock_adjustments (
          store_id, product_id, type, quantity, 
          previous_qty, new_qty, reference_id, reference_type
        ) VALUES (
          NEW.store_id, v_item.product_id, 'sold', -v_item.qty,
          v_item.stock_qty, v_item.stock_qty - v_item.qty, 
          NEW.id, 'order'
        );
      END IF;
    END LOOP;
    
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_order_status_change
  AFTER UPDATE OF status ON orders
  FOR EACH ROW EXECUTE FUNCTION deduct_stock_on_order_confirm();
```

---

### 3. سداد الديون ✅ محسَّن (منع السلبيات)

```sql
CREATE OR REPLACE FUNCTION update_debt_on_payment()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_remaining DECIMAL(10,2);
BEGIN
  -- قفل الصف وجلب القيمة الحالية
  SELECT remaining_amount INTO v_remaining
  FROM debts
  WHERE id = NEW.debt_id
  FOR UPDATE;
  
  -- تحقق من عدم تجاوز المتبقي
  IF NEW.amount > v_remaining THEN
    RAISE EXCEPTION 'مبلغ السداد (%) أكبر من المتبقي (%)', NEW.amount, v_remaining;
  END IF;
  
  -- تحديث المتبقي
  UPDATE debts 
  SET remaining_amount = remaining_amount - NEW.amount,
      updated_at = now()
  WHERE id = NEW.debt_id;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER on_debt_payment
  BEFORE INSERT ON debt_payments
  FOR EACH ROW EXECUTE FUNCTION update_debt_on_payment();
```

---

## 🔐 RLS Policies (شامل لكل الجداول)

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
CREATE POLICY "Users read own" ON users FOR SELECT USING (id = auth.uid());
CREATE POLICY "Users update own" ON users FOR UPDATE USING (id = auth.uid());
-- Note: role محمي بـ REVOKE أعلاه
```

### stores

```sql
CREATE POLICY "Anyone read active stores" ON stores FOR SELECT USING (is_active = true);
CREATE POLICY "Owner manage store" ON stores FOR INSERT WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Owner update store" ON stores FOR UPDATE USING (owner_id = auth.uid()) WITH CHECK (owner_id = auth.uid());
CREATE POLICY "Owner delete store" ON stores FOR DELETE USING (owner_id = auth.uid());
```

### store_members

```sql
CREATE POLICY "Owner manage members" ON store_members FOR ALL
  USING (EXISTS (SELECT 1 FROM stores WHERE id = store_id AND owner_id = auth.uid()));
CREATE POLICY "Member read own" ON store_members FOR SELECT USING (user_id = auth.uid());
```

### addresses

```sql
CREATE POLICY "User manage own addresses" ON addresses FOR ALL USING (user_id = auth.uid());
```

### products

```sql
CREATE POLICY "Anyone read active products" ON products FOR SELECT USING (is_active = true);
CREATE POLICY "Staff manage products" ON products FOR ALL
  USING (EXISTS (
    SELECT 1 FROM store_members sm 
    WHERE sm.store_id = products.store_id AND sm.user_id = auth.uid() AND sm.is_active
  ));
```

### orders

```sql
CREATE POLICY "Customer read own orders" ON orders FOR SELECT USING (customer_id = auth.uid());
CREATE POLICY "Customer create order" ON orders FOR INSERT WITH CHECK (customer_id = auth.uid());
CREATE POLICY "Staff read store orders" ON orders FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM store_members sm 
    WHERE sm.store_id = orders.store_id AND sm.user_id = auth.uid() AND sm.is_active
  ));
CREATE POLICY "Staff update store orders" ON orders FOR UPDATE
  USING (EXISTS (
    SELECT 1 FROM store_members sm 
    WHERE sm.store_id = orders.store_id AND sm.user_id = auth.uid() AND sm.is_active
  ));
```

### order_items

```sql
CREATE POLICY "Read via order" ON order_items FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM orders o WHERE o.id = order_id AND (
      o.customer_id = auth.uid() OR
      EXISTS (SELECT 1 FROM store_members sm WHERE sm.store_id = o.store_id AND sm.user_id = auth.uid())
    )
  ));
CREATE POLICY "Insert via order" ON order_items FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM orders o WHERE o.id = order_id AND o.customer_id = auth.uid()));
```

### deliveries

```sql
CREATE POLICY "Driver read assigned" ON deliveries FOR SELECT USING (driver_id = auth.uid());
CREATE POLICY "Driver update assigned" ON deliveries FOR UPDATE USING (driver_id = auth.uid());
CREATE POLICY "Staff read store deliveries" ON deliveries FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM orders o 
    JOIN store_members sm ON sm.store_id = o.store_id
    WHERE o.id = order_id AND sm.user_id = auth.uid()
  ));
```

### debts + debt_payments

```sql
CREATE POLICY "Staff manage debts" ON debts FOR ALL
  USING (EXISTS (
    SELECT 1 FROM store_members sm 
    WHERE sm.store_id = debts.store_id AND sm.user_id = auth.uid() AND sm.is_active
  ));

CREATE POLICY "Staff manage debt_payments" ON debt_payments FOR ALL
  USING (EXISTS (
    SELECT 1 FROM debts d 
    JOIN store_members sm ON sm.store_id = d.store_id
    WHERE d.id = debt_id AND sm.user_id = auth.uid()
  ));
```

### customer_accounts + loyalty_points

```sql
CREATE POLICY "Customer read own account" ON customer_accounts FOR SELECT USING (customer_id = auth.uid());
CREATE POLICY "Staff read store accounts" ON customer_accounts FOR SELECT
  USING (EXISTS (SELECT 1 FROM store_members sm WHERE sm.store_id = customer_accounts.store_id AND sm.user_id = auth.uid()));

CREATE POLICY "Customer read own points" ON loyalty_points FOR SELECT USING (customer_id = auth.uid());
CREATE POLICY "Staff read store points" ON loyalty_points FOR SELECT
  USING (EXISTS (SELECT 1 FROM store_members sm WHERE sm.store_id = loyalty_points.store_id AND sm.user_id = auth.uid()));
```

### stock_adjustments

```sql
CREATE POLICY "Staff read adjustments" ON stock_adjustments FOR SELECT
  USING (EXISTS (SELECT 1 FROM store_members sm WHERE sm.store_id = stock_adjustments.store_id AND sm.user_id = auth.uid()));
CREATE POLICY "Staff create adjustments" ON stock_adjustments FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM store_members sm WHERE sm.store_id = stock_adjustments.store_id AND sm.user_id = auth.uid()));
-- لا UPDATE/DELETE - سجلات ثابتة
```

### purchase_orders + items

```sql
CREATE POLICY "Staff manage POs" ON purchase_orders FOR ALL
  USING (EXISTS (SELECT 1 FROM store_members sm WHERE sm.store_id = purchase_orders.store_id AND sm.user_id = auth.uid()));

CREATE POLICY "Staff manage PO items" ON purchase_order_items FOR ALL
  USING (EXISTS (
    SELECT 1 FROM purchase_orders po 
    JOIN store_members sm ON sm.store_id = po.store_id
    WHERE po.id = purchase_order_id AND sm.user_id = auth.uid()
  ));
```

---

## ✅ Checklist قبل التنفيذ

- [ ] إنشاء مشروع Supabase
- [ ] تشغيل ENUMs أولاً (8 أنواع)
- [ ] إنشاء الجداول بالترتيب
- [ ] إنشاء Functions و Triggers
- [ ] تفعيل RLS على كل الجداول
- [ ] تطبيق REVOKE على users.role
- [ ] اختبار OTP login
- [ ] اختبار خصم المخزون
- [ ] اختبار سداد الديون

---

*Production Ready - v2.1.0*
