# Alhai Platform - Database Schema Analysis

**Version:** 1.0.0  
**Date:** 2026-01-19

---

## 📊 ملخص المنصة

| المكون | التطبيقات | قاعدة البيانات |
|--------|----------|----------------|
| Apps | 7 تطبيقات | Supabase (واحدة) |
| Models | 20+ نموذج | PostgreSQL |
| Users | 5 أدوار | RLS Policies |

---

## 🏗️ التطبيقات والأدوار

```
┌─────────────────────────────────────────────────────────────┐
│                    Alhai Platform                            │
├─────────────┬─────────────┬─────────────┬──────────────────┤
│  POS App    │ Customer App│ Driver App  │ Admin Portal     │
│  (كاشير)    │   (عملاء)   │  (توصيل)    │   (إدارة)        │
├─────────────┴─────────────┴─────────────┴──────────────────┤
│                      Supabase                                │
│              (PostgreSQL + Auth + Storage)                   │
└─────────────────────────────────────────────────────────────┘
```

### أدوار المستخدمين (5 أدوار)

| Role | الوصف | التطبيقات |
|------|-------|----------|
| `super_admin` | مدير النظام الكامل | super_admin, admin_pos |
| `store_owner` | صاحب المتجر | pos_app, admin_pos |
| `employee` | موظف/كاشير | pos_app |
| `delivery` | سائق توصيل | driver_app |
| `customer` | عميل | customer_app |

---

## 📋 الجداول المطلوبة (15 جدول)

### 1. users (المستخدمون)
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(20) UNIQUE NOT NULL,
  email VARCHAR(255),
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  role VARCHAR(20) NOT NULL DEFAULT 'customer',
  store_id UUID REFERENCES stores(id),
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  fcm_token TEXT,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- RLS: كل مستخدم يرى نفسه فقط، super_admin يرى الكل
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
  min_order_amount DECIMAL(10,2),
  delivery_fee DECIMAL(10,2),
  accepts_delivery BOOLEAN DEFAULT true,
  accepts_pickup BOOLEAN DEFAULT true,
  working_hours JSONB,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- RLS: owner يدير متجره، customers يقرأون المتاجر النشطة
```

---

### 3. categories (التصنيفات)
```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  sort_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS: store_owner يدير، الكل يقرأ
```

---

### 4. products (المنتجات)
```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  sku VARCHAR(50),
  barcode VARCHAR(50),
  price DECIMAL(10,2) NOT NULL,
  cost_price DECIMAL(10,2),
  stock_qty INT NOT NULL DEFAULT 0,
  min_qty INT DEFAULT 1,
  unit VARCHAR(20),
  description TEXT,
  image_thumbnail TEXT,
  image_medium TEXT,
  image_large TEXT,
  image_hash VARCHAR(32),
  category_id UUID REFERENCES categories(id),
  is_active BOOLEAN DEFAULT true,
  track_inventory BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);

-- Index: barcode + store_id for fast lookup
CREATE INDEX idx_products_barcode ON products(barcode, store_id);
CREATE INDEX idx_products_store ON products(store_id, is_active);
```

---

### 5. orders (الطلبات)
```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_number VARCHAR(20) UNIQUE,
  customer_id UUID REFERENCES users(id) NOT NULL,
  customer_name VARCHAR(255),
  customer_phone VARCHAR(20),
  store_id UUID REFERENCES stores(id) NOT NULL,
  store_name VARCHAR(255),
  status VARCHAR(20) NOT NULL DEFAULT 'created',
  subtotal DECIMAL(10,2) NOT NULL,
  discount DECIMAL(10,2) DEFAULT 0,
  delivery_fee DECIMAL(10,2) DEFAULT 0,
  tax DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  payment_method VARCHAR(20) NOT NULL,
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
  updated_at TIMESTAMPTZ
);

-- Index for store + status queries
CREATE INDEX idx_orders_store_status ON orders(store_id, status);
CREATE INDEX idx_orders_customer ON orders(customer_id);
```

---

### 6. order_items (عناصر الطلب)
```sql
CREATE TABLE order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) ON DELETE CASCADE NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10,2) NOT NULL,
  qty INT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 7. addresses (العناوين)
```sql
CREATE TABLE addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) NOT NULL,
  label VARCHAR(50),
  address_line TEXT NOT NULL,
  lat DECIMAL(10,8),
  lng DECIMAL(11,8),
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 8. suppliers (الموردون)
```sql
CREATE TABLE suppliers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
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
```

---

### 9. debts (الديون)
```sql
CREATE TABLE debts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  type VARCHAR(20) NOT NULL, -- 'customer_debt' | 'supplier_debt'
  party_id UUID NOT NULL,
  party_name VARCHAR(255) NOT NULL,
  party_phone VARCHAR(20),
  original_amount DECIMAL(10,2) NOT NULL,
  remaining_amount DECIMAL(10,2) NOT NULL,
  order_id UUID REFERENCES orders(id),
  notes TEXT,
  due_date DATE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);
```

---

### 10. debt_payments (سداد الديون)
```sql
CREATE TABLE debt_payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  debt_id UUID REFERENCES debts(id) ON DELETE CASCADE NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  notes TEXT,
  payment_method VARCHAR(20),
  created_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 11. deliveries (التوصيلات)
```sql
CREATE TABLE deliveries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID REFERENCES orders(id) NOT NULL,
  driver_id UUID REFERENCES users(id) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'assigned',
  driver_name VARCHAR(255),
  driver_phone VARCHAR(20),
  driver_lat DECIMAL(10,8),
  driver_lng DECIMAL(11,8),
  estimated_arrival TIMESTAMPTZ,
  picked_up_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 12. customer_accounts (حسابات العملاء)
```sql
CREATE TABLE customer_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES users(id) NOT NULL,
  store_id UUID REFERENCES stores(id) NOT NULL,
  balance DECIMAL(10,2) DEFAULT 0, -- negative = debt
  credit_limit DECIMAL(10,2) DEFAULT 500,
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

### 13. loyalty_points (نقاط الولاء)
```sql
CREATE TABLE loyalty_points (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES users(id) NOT NULL,
  store_id UUID REFERENCES stores(id) NOT NULL,
  points INT DEFAULT 0,
  total_earned INT DEFAULT 0,
  total_redeemed INT DEFAULT 0,
  tier VARCHAR(20) DEFAULT 'bronze',
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ,
  UNIQUE(customer_id, store_id)
);
```

---

### 14. stock_adjustments (تعديلات المخزون)
```sql
CREATE TABLE stock_adjustments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  product_id UUID REFERENCES products(id) NOT NULL,
  type VARCHAR(20) NOT NULL, -- received, sold, adjustment, damaged
  quantity INT NOT NULL,
  previous_qty INT NOT NULL,
  new_qty INT NOT NULL,
  reason TEXT,
  reference_id UUID, -- order_id or purchase_order_id
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now()
);
```

---

### 15. purchase_orders (أوامر الشراء)
```sql
CREATE TABLE purchase_orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  store_id UUID REFERENCES stores(id) NOT NULL,
  supplier_id UUID REFERENCES suppliers(id) NOT NULL,
  order_number VARCHAR(20),
  status VARCHAR(20) DEFAULT 'draft',
  items JSONB NOT NULL,
  subtotal DECIMAL(10,2) NOT NULL,
  tax DECIMAL(10,2) DEFAULT 0,
  total DECIMAL(10,2) NOT NULL,
  notes TEXT,
  expected_date DATE,
  received_at TIMESTAMPTZ,
  created_by UUID REFERENCES users(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ
);
```

---

## 🔐 صلاحيات الوصول (RLS Summary)

| الجدول | super_admin | store_owner | employee | customer | driver |
|--------|-------------|-------------|----------|----------|--------|
| users | CRUD | R own | R own | R own | R own |
| stores | CRUD | CRUD own | R own | R active | R assigned |
| products | CRUD | CRUD own | R own | R active | - |
| orders | CRUD | CRUD own | CRUD own | CRUD own | R assigned |
| deliveries | CRUD | R own | - | R own | CRUD assigned |
| debts | CRUD | CRUD own | R own | - | - |
| suppliers | CRUD | CRUD own | R own | - | - |

---

## 📱 ماذا يستخدم كل تطبيق؟

### POS App (Device A)
| الجدول | العمليات |
|--------|---------|
| users | R (login) |
| stores | R (select) |
| products | R (scan/search) |
| orders | CRU (create, read, update) |
| order_items | C (create with order) |
| debts | CRU |
| stock_adjustments | C |

### Customer App (Device B)
| الجدول | العمليات |
|--------|---------|
| users | RU (profile) |
| stores | R (browse) |
| products | R (catalog) |
| orders | CR (create, track) |
| addresses | CRUD |
| customer_accounts | R |
| loyalty_points | R |

### Driver App
| الجدول | العمليات |
|--------|---------|
| deliveries | RU (assigned) |
| orders | R (assigned) |

### Admin Portal
| الجدول | العمليات |
|--------|---------|
| All | CRUD (based on role) |

---

## 📈 Supabase Features المطلوبة

| الميزة | الاستخدام |
|--------|----------|
| **Auth** | OTP Phone login |
| **Database** | PostgreSQL tables |
| **RLS** | Row Level Security |
| **Realtime** | Order status updates |
| **Storage** | Product images |
| **Edge Functions** | Order number generation |

---

## 💰 تقدير الحجم (Free Plan)

| البند | Free Limit | تقديرك |
|-------|-----------|--------|
| Database | 500 MB | ~50 MB (كافي) |
| Storage | 1 GB | ~200 MB (كافي) |
| Users | 50,000 MAU | ~100 (كافي) |
| API Requests | Unlimited | ✅ |

**الخلاصة:** Free Plan كافية للتطوير والاختبار ✅

---

*Ready for Supabase Setup*
