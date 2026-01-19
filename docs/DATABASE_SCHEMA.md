# Alhai Platform - Database Schema (Final)

**Version:** 2.0.0  
**Date:** 2026-01-19

---

> [!IMPORTANT]
> هذا الـ Schema مُحسَّن ويتضمن:
> - ربط مع `auth.users` (Supabase Auth)
> - `store_members` بدلاً من circular dependency
> - ENUMs للحالات
> - Triggers للمخزون والتواريخ
> - `purchase_order_items` منفصل
> - RLS مبني على `auth.uid()`

---

## 📊 ملخص المنصة

| المكون | القيمة |
|--------|-------|
| الجداول الأساسية | **17 جدول** |
| ENUMs | 4 |
| Triggers | 4 |
| Functions | 2 |

---

## 🔧 ENUMs (أولاً)

```sql
-- User roles
CREATE TYPE user_role AS ENUM (
  'super_admin',
  'store_owner', 
  'employee',
  'delivery',
  'customer'
);

-- Order status
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

-- Delivery status
CREATE TYPE delivery_status AS ENUM (
  'assigned',
  'accepted',
  'picked_up',
  'delivered',
  'cancelled',
  'failed'
);

-- Payment method
CREATE TYPE payment_method AS ENUM (
  'cash',
  'card',
  'credit',
  'wallet'
);

-- Stock adjustment type
CREATE TYPE adjustment_type AS ENUM (
  'received',
  'sold',
  'adjustment',
  'damaged',
  'returned'
);

-- Debt type
CREATE TYPE debt_type AS ENUM (
  'customer_debt',
  'supplier_debt'
);
```

---

## 📋 الجداول (17 جدول)

### 1. users (مرتبط بـ auth.users)

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone VARCHAR(20) UNIQUE NOT NULL,
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

-- Trigger: إنشاء profile تلقائيًا عند التسجيل
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, phone, name, role)
  VALUES (
    NEW.id,
    NEW.phone,
    COALESCE(NEW.raw_user_meta_data->>'name', 'مستخدم جديد'),
    'customer'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

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
  working_hours JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);
```

---

### 3. store_members (عضويات المتجر) ✨ جديد

```sql
-- بدلاً من users.store_id (circular dependency)
CREATE TABLE store_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  role_in_store VARCHAR(20) DEFAULT 'cashier', -- owner, manager, cashier
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
  -- Snapshot fields (لقطة وقت الطلب)
  customer_name VARCHAR(255),
  customer_phone VARCHAR(20),
  store_id UUID REFERENCES stores(id) NOT NULL,
  store_name VARCHAR(255),
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
  -- Unique order number per store
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
  name VARCHAR(255) NOT NULL, -- Snapshot
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
  balance DECIMAL(10,2) DEFAULT 0, -- Derived via trigger
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

-- Trigger: تحديث remaining_amount
CREATE OR REPLACE FUNCTION update_debt_on_payment()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE debts 
  SET remaining_amount = remaining_amount - NEW.amount,
      updated_at = now()
  WHERE id = NEW.debt_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_debt_payment
  AFTER INSERT ON debt_payments
  FOR EACH ROW EXECUTE FUNCTION update_debt_on_payment();
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
  balance DECIMAL(10,2) DEFAULT 0, -- Derived via trigger (negative = debt)
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
  quantity INT NOT NULL, -- positive or negative
  previous_qty INT NOT NULL,
  new_qty INT NOT NULL,
  reason TEXT,
  reference_id UUID, -- order_id or purchase_order_id
  reference_type VARCHAR(20), -- 'order' or 'purchase_order'
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
  status VARCHAR(20) DEFAULT 'draft', -- draft, ordered, received, cancelled
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

### 17. purchase_order_items (عناصر أمر الشراء) ✨ جديد

```sql
-- بدلاً من JSONB items
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

## ⚡ Triggers المهمة

### 1. تحديث updated_at تلقائيًا

```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- تطبيق على كل الجداول
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

### 2. خصم المخزون عند تأكيد الطلب

```sql
CREATE OR REPLACE FUNCTION deduct_stock_on_order_confirm()
RETURNS TRIGGER AS $$
BEGIN
  -- فقط عند الانتقال إلى confirmed أو preparing
  IF (OLD.status = 'created' AND NEW.status IN ('confirmed', 'preparing')) THEN
    -- خصم المخزون لكل عنصر
    UPDATE products p
    SET stock_qty = stock_qty - oi.qty,
        updated_at = now()
    FROM order_items oi
    WHERE oi.order_id = NEW.id 
      AND p.id = oi.product_id
      AND p.track_inventory = true;
    
    -- تسجيل حركة المخزون
    INSERT INTO stock_adjustments (store_id, product_id, type, quantity, previous_qty, new_qty, reference_id, reference_type, created_by)
    SELECT 
      NEW.store_id,
      oi.product_id,
      'sold',
      -oi.qty,
      p.stock_qty + oi.qty,
      p.stock_qty,
      NEW.id,
      'order',
      NEW.customer_id
    FROM order_items oi
    JOIN products p ON p.id = oi.product_id
    WHERE oi.order_id = NEW.id AND p.track_inventory = true;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_order_status_change
  AFTER UPDATE OF status ON orders
  FOR EACH ROW EXECUTE FUNCTION deduct_stock_on_order_confirm();
```

---

## 🔐 RLS Policies (مبني على auth.uid)

### قواعد عامة

```sql
-- تفعيل RLS على كل الجداول
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE addresses ENABLE ROW LEVEL SECURITY;
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;
-- ... etc
```

### users

```sql
-- قراءة الملف الشخصي
CREATE POLICY "Users can read own profile"
  ON users FOR SELECT
  USING (id = auth.uid());

-- تحديث الملف الشخصي (بدون تغيير role)
CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (id = auth.uid())
  WITH CHECK (role = (SELECT role FROM users WHERE id = auth.uid()));
```

### stores

```sql
-- الكل يقرأ المتاجر النشطة
CREATE POLICY "Anyone can read active stores"
  ON stores FOR SELECT
  USING (is_active = true);

-- المالك فقط يعدل
CREATE POLICY "Owner can manage store"
  ON stores FOR ALL
  USING (owner_id = auth.uid());
```

### products

```sql
-- العملاء يقرأون المنتجات النشطة
CREATE POLICY "Customers can read active products"
  ON products FOR SELECT
  USING (is_active = true);

-- موظفو المتجر يديرون المنتجات
CREATE POLICY "Staff can manage products"
  ON products FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM store_members sm
      WHERE sm.store_id = products.store_id
        AND sm.user_id = auth.uid()
        AND sm.is_active = true
    )
  );
```

### orders

```sql
-- العميل يرى طلباته
CREATE POLICY "Customer can view own orders"
  ON orders FOR SELECT
  USING (customer_id = auth.uid());

-- العميل ينشئ طلب
CREATE POLICY "Customer can create orders"
  ON orders FOR INSERT
  WITH CHECK (customer_id = auth.uid());

-- موظفو المتجر يرون طلبات المتجر
CREATE POLICY "Staff can view store orders"
  ON orders FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM store_members sm
      WHERE sm.store_id = orders.store_id
        AND sm.user_id = auth.uid()
        AND sm.is_active = true
    )
  );
```

### deliveries

```sql
-- السائق يرى توصيلاته المخصصة
CREATE POLICY "Driver can view assigned deliveries"
  ON deliveries FOR SELECT
  USING (driver_id = auth.uid());

-- السائق يحدث حالة التوصيل
CREATE POLICY "Driver can update delivery status"
  ON deliveries FOR UPDATE
  USING (driver_id = auth.uid());
```

---

## 📱 ملخص: ماذا يستخدم كل تطبيق؟

| التطبيق | الجداول | العمليات |
|---------|---------|---------|
| **POS App** | users, stores, store_members, products, orders, order_items, debts, debt_payments, stock_adjustments | CRUD |
| **Customer App** | users, stores, products, orders, addresses, customer_accounts, loyalty_points | CR + R |
| **Driver App** | users, deliveries, orders | R + Update status |
| **Admin Portal** | All | Full CRUD |

---

## ✅ Checklist قبل التنفيذ

- [ ] إنشاء مشروع Supabase
- [ ] تشغيل ENUMs أولاً
- [ ] إنشاء الجداول بالترتيب (users → stores → ... )
- [ ] تفعيل Triggers
- [ ] تفعيل RLS
- [ ] اختبار OTP login

---

*Ready for Supabase Implementation*
