# 🛒 POS App - Next.js + Tauri + Supabase Implementation Plan

> **Version:** 2.0.0 | **Date:** 2026-02-02 | **Status:** 📋 Planning

---

## 📌 نظرة عامة

| البند | القيمة |
|-------|--------|
| **نوع التطبيق** | Desktop App (Tauri) |
| **Frontend** | Next.js 14 (App Router) |
| **Desktop** | Tauri 2.0 (Rust) |
| **Backend** | Supabase (PostgreSQL + Auth + Realtime + Storage) |
| **UI Library** | Material UI (MUI) v5 |
| **State Management** | Zustand + React Query |
| **اللغات** | 6 لغات (AR, EN, HI, ID, BN, UR) |
| **إجمالي الشاشات** | **103 شاشة** |
| **إجمالي جداول DB** | **42 جدول** |
| **المدة المتوقعة** | **24 أسبوع** |

---

## 🆕 الميزات الجديدة (v2.0)

### 1️⃣ Split Payment (تقسيم الدفع)
- دعم تقسيم الدفع بين: نقد + بطاقة + آجل (دين)
- إمكانية تقسيم ثلاثي في نفس الفاتورة
- جدول `sale_payments` لتتبع كل دفعة

### 2️⃣ Debt Auto-Reminders (تذكير الديون الأوتوماتيكي)
- جدولة مرنة (بعد 7، 15، 30 يوم)
- دعم WhatsApp + SMS
- قوالب رسائل قابلة للتخصيص
- سجل تتبع الإرسال

### 3️⃣ Loyalty Program الموسع (نقاط الولاء)
- 4 مستويات: برونزي 🥉، فضي 🥈، ذهبي 🥇، ماسي 💎
- صلاحية النقاط (12 شهر)
- مضاعفات النقاط حسب المستوى
- استبدال النقاط بخصومات

### 4️⃣ Multi-Branch + AI Smart Transfer (الفروع المتعددة)
- إدارة فروع متعددة لصاحب البقالة
- مخزون منفصل لكل فرع
- نقل المخزون بين الفروع بسهولة
- اقتراحات AI ذكية للنقل بناءً على:
  - معدل البيع اليومي لكل فرع
  - المخزون الحالي والحد الأدنى
  - توقع نفاد المخزون

---

## 🏗️ Tech Stack التفصيلي

```yaml
Frontend:
  - Next.js 14 (App Router)
  - TypeScript 5.x
  - Material UI (MUI) 5.x
  - next-intl (i18n)
  - React Query (TanStack Query)
  - Zustand (State)
  - React Hook Form + Zod
  - date-fns (dates)
  - recharts (charts)

Desktop:
  - Tauri 2.0
  - SQLite (local DB via better-sqlite3-multiple-ciphers)
  - tauri-plugin-sql (encrypted local DB)
  - tauri-plugin-store (settings)

Backend:
  - Supabase (hosted PostgreSQL)
  - Supabase Auth (OTP + PIN)
  - Supabase Realtime (sync)
  - Supabase Storage (images)
  - Supabase Edge Functions (AI import)

DevOps:
  - pnpm (package manager)
  - ESLint + Prettier
  - Husky (git hooks)
  - GitHub Actions (CI/CD)
```

---

## 📁 هيكل المجلدات

```
pos-app-nextjs/
├── src-tauri/                    # Tauri (Rust)
│   ├── src/
│   │   ├── main.rs
│   │   └── lib.rs
│   ├── Cargo.toml
│   └── tauri.conf.json
│
├── src/
│   ├── app/                      # Next.js App Router
│   │   ├── (auth)/               # Auth Layout
│   │   │   ├── login/
│   │   │   │   └── page.tsx
│   │   │   ├── store-select/
│   │   │   │   └── page.tsx
│   │   │   └── layout.tsx
│   │   │
│   │   ├── (dashboard)/          # Main Layout
│   │   │   ├── layout.tsx
│   │   │   ├── page.tsx          # Home Dashboard
│   │   │   │
│   │   │   ├── pos/              # نقاط البيع
│   │   │   │   ├── page.tsx      # Quick Sale
│   │   │   │   ├── cart/
│   │   │   │   ├── payment/
│   │   │   │   ├── receipt/
│   │   │   │   ├── hold/
│   │   │   │   ├── returns/
│   │   │   │   └── favorites/
│   │   │   │
│   │   │   ├── products/         # المنتجات
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [id]/
│   │   │   │   ├── add/
│   │   │   │   └── price-history/
│   │   │   │
│   │   │   ├── inventory/        # المخزون
│   │   │   │   ├── page.tsx
│   │   │   │   ├── adjust/
│   │   │   │   ├── expiry/
│   │   │   │   ├── count/
│   │   │   │   ├── transfer/           # نقل المخزون ⭐ NEW
│   │   │   │   └── ai-suggestions/     # اقتراحات AI ⭐ NEW
│   │   │   │
│   │   │   ├── customers/        # العملاء
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/
│   │   │   │       ├── page.tsx
│   │   │   │       ├── account/
│   │   │   │       └── payment/
│   │   │   │
│   │   │   ├── suppliers/        # الموردين
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [id]/
│   │   │   │   └── add/
│   │   │   │
│   │   │   ├── purchases/        # المشتريات
│   │   │   │   ├── page.tsx
│   │   │   │   ├── add/
│   │   │   │   ├── import/       # AI Import
│   │   │   │   ├── review/
│   │   │   │   └── smart-order/
│   │   │   │
│   │   │   ├── orders/           # الطلبات
│   │   │   │   ├── page.tsx
│   │   │   │   └── [id]/
│   │   │   │
│   │   │   ├── drivers/          # المناديب
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [id]/
│   │   │   │   └── add/
│   │   │   │
│   │   │   ├── reports/          # التقارير
│   │   │   │   ├── page.tsx      # Dashboard
│   │   │   │   ├── sales/
│   │   │   │   ├── debts/
│   │   │   │   ├── inventory/
│   │   │   │   ├── vat/
│   │   │   │   ├── top-products/
│   │   │   │   ├── peak-hours/
│   │   │   │   ├── profit-margin/
│   │   │   │   ├── comparison/
│   │   │   │   ├── cashier/
│   │   │   │   └── app-downloads/
│   │   │   │
│   │   │   ├── promotions/       # العروض
│   │   │   │   ├── page.tsx
│   │   │   │   └── add/
│   │   │   │
│   │   │   ├── loyalty/          # الولاء
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [accountId]/
│   │   │   │   ├── tiers/        # مستويات الولاء ⭐ NEW
│   │   │   │   └── expiring/     # النقاط المنتهية ⭐ NEW
│   │   │   │
│   │   │   ├── branches/         # الفروع ⭐ NEW
│   │   │   │   ├── page.tsx
│   │   │   │   ├── [id]/
│   │   │   │   └── new/
│   │   │   │
│   │   │   ├── debts/            # الديون
│   │   │   │   └── close-month/
│   │   │   │
│   │   │   ├── cash-drawer/      # الصندوق
│   │   │   │   └── page.tsx
│   │   │   │
│   │   │   ├── notifications/    # الإشعارات
│   │   │   │   └── page.tsx
│   │   │   │
│   │   │   ├── expenses/         # المصروفات
│   │   │   │   ├── page.tsx
│   │   │   │   └── add/
│   │   │   │
│   │   │   └── settings/         # الإعدادات
│   │   │       ├── page.tsx
│   │   │       ├── general/
│   │   │       ├── store/
│   │   │       ├── printer/
│   │   │       ├── interest/
│   │   │       ├── whatsapp/
│   │   │       ├── zatca/
│   │   │       ├── payment-devices/
│   │   │       ├── receipt/
│   │   │       ├── users/
│   │   │       ├── roles/
│   │   │       ├── backup/
│   │   │       ├── scale/
│   │   │       ├── cash-drawer-device/
│   │   │       ├── barcode/
│   │   │       ├── shortcuts/
│   │   │       ├── digital-receipt/
│   │   │       ├── referral/
│   │   │       ├── audit-log/
│   │   │       ├── loyalty/            # إعدادات الولاء ⭐ NEW
│   │   │       └── debt-reminders/     # إعدادات التذكير ⭐ NEW
│   │   │
│   │   ├── api/                  # API Routes (optional)
│   │   │   └── [...]/
│   │   │
│   │   ├── globals.css
│   │   ├── layout.tsx
│   │   └── not-found.tsx
│   │
│   ├── components/               # Shared Components
│   │   ├── ui/                   # Base UI (MUI wrappers)
│   │   │   ├── Button/
│   │   │   ├── Input/
│   │   │   ├── Card/
│   │   │   ├── Dialog/
│   │   │   ├── Table/
│   │   │   └── ...
│   │   │
│   │   ├── layout/               # Layout Components
│   │   │   ├── Sidebar/
│   │   │   ├── Header/
│   │   │   ├── OfflineIndicator/
│   │   │   └── LanguageSwitcher/
│   │   │
│   │   ├── pos/                  # POS Specific
│   │   │   ├── ProductGrid/
│   │   │   ├── CartPanel/
│   │   │   ├── PaymentMethods/
│   │   │   ├── ReceiptPreview/
│   │   │   └── BarcodeScanner/
│   │   │
│   │   ├── forms/                # Form Components
│   │   │   ├── ProductForm/
│   │   │   ├── CustomerForm/
│   │   │   └── ...
│   │   │
│   │   └── charts/               # Chart Components
│   │       ├── SalesChart/
│   │       ├── InventoryChart/
│   │       └── ...
│   │
│   ├── lib/                      # Utilities & Config
│   │   ├── supabase/
│   │   │   ├── client.ts         # Browser client
│   │   │   ├── server.ts         # Server client
│   │   │   ├── types.ts          # DB Types
│   │   │   └── queries/          # Query functions
│   │   │       ├── products.ts
│   │   │       ├── sales.ts
│   │   │       ├── inventory.ts
│   │   │       └── ...
│   │   │
│   │   ├── tauri/
│   │   │   ├── db.ts             # Local SQLite
│   │   │   ├── printer.ts        # Print functions
│   │   │   ├── sync.ts           # Sync logic
│   │   │   └── hardware.ts       # Hardware integrations
│   │   │
│   │   ├── i18n/
│   │   │   ├── config.ts
│   │   │   └── request.ts
│   │   │
│   │   ├── utils/
│   │   │   ├── format.ts
│   │   │   ├── validation.ts
│   │   │   ├── calculations.ts
│   │   │   └── constants.ts
│   │   │
│   │   └── hooks/                # Custom Hooks
│   │       ├── useAuth.ts
│   │       ├── useCart.ts
│   │       ├── useSync.ts
│   │       ├── useOffline.ts
│   │       └── ...
│   │
│   ├── stores/                   # Zustand Stores
│   │   ├── authStore.ts
│   │   ├── cartStore.ts
│   │   ├── settingsStore.ts
│   │   ├── syncStore.ts
│   │   └── notificationStore.ts
│   │
│   ├── types/                    # TypeScript Types
│   │   ├── database.ts           # Supabase generated
│   │   ├── api.ts
│   │   ├── models.ts
│   │   └── enums.ts
│   │
│   └── messages/                 # i18n Messages
│       ├── ar.json               # العربية
│       ├── en.json               # English
│       ├── hi.json               # हिन्दी
│       ├── id.json               # Bahasa Indonesia
│       ├── bn.json               # বাংলা
│       └── ur.json               # اردو
│
├── public/
│   ├── icons/
│   └── images/
│
├── supabase/                     # Supabase Config
│   ├── migrations/               # SQL Migrations
│   │   ├── 00001_initial_schema.sql
│   │   ├── 00002_rls_policies.sql
│   │   └── ...
│   ├── functions/                # Edge Functions
│   │   ├── ai-invoice-import/
│   │   └── whatsapp-send/
│   └── seed.sql                  # Seed Data
│
├── .env.local
├── .env.example
├── next.config.js
├── tailwind.config.js
├── tsconfig.json
├── package.json
└── README.md
```

---

## 🗄️ Supabase Database Schema

### ERD Overview

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   stores    │────<│    users    │     │  categories │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  products   │────<│   sales     │     │  inventory  │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │
       │                   │                   │
       ▼                   ▼                   ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│ sale_items  │     │  accounts   │     │ movements   │
└─────────────┘     └─────────────┘     └─────────────┘
```

### SQL Migrations

```sql
-- ===========================================
-- 00001_initial_schema.sql
-- ===========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===========================================
-- 1. STORES (المتاجر)
-- ===========================================
CREATE TABLE stores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    logo_url TEXT,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    tax_number VARCHAR(50),
    commercial_registration VARCHAR(50),
    currency VARCHAR(3) DEFAULT 'SAR',
    tax_rate DECIMAL(5,2) DEFAULT 15.00,
    timezone VARCHAR(50) DEFAULT 'Asia/Riyadh',
    working_hours JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 2. USERS (المستخدمين)
-- ===========================================
CREATE TYPE user_role AS ENUM ('OWNER', 'MANAGER', 'SUPERVISOR', 'CASHIER');

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(255),
    pin VARCHAR(4),
    pin_hash TEXT,
    totp_secret TEXT,
    role user_role DEFAULT 'CASHIER',
    permissions TEXT[],
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 3. CATEGORIES (الفئات)
-- ===========================================
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    name VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    parent_id UUID REFERENCES categories(id),
    icon VARCHAR(50),
    color VARCHAR(7),
    sort_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 4. PRODUCTS (المنتجات)
-- ===========================================
CREATE TYPE tax_category AS ENUM ('STANDARD', 'REDUCED', 'EXEMPT');

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    category_id UUID REFERENCES categories(id),
    name VARCHAR(255) NOT NULL,
    name_en VARCHAR(255),
    barcode VARCHAR(50),
    sku VARCHAR(50),
    description TEXT,
    sell_price DECIMAL(10,2) NOT NULL,
    purchase_price DECIMAL(10,2),
    tax_inclusive BOOLEAN DEFAULT true,
    tax_category tax_category DEFAULT 'STANDARD',
    min_stock INT DEFAULT 0,
    image_thumbnail TEXT,
    image_medium TEXT,
    image_large TEXT,
    image_hash VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(store_id, barcode)
);

CREATE INDEX idx_products_barcode ON products(barcode);
CREATE INDEX idx_products_store ON products(store_id, is_active);

-- ===========================================
-- 5. INVENTORY (المخزون)
-- ===========================================
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) UNIQUE NOT NULL,
    quantity INT DEFAULT 0,
    reserved_qty INT DEFAULT 0,
    last_updated TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 6. INVENTORY_MOVEMENTS (حركات المخزون)
-- ===========================================
CREATE TYPE movement_type AS ENUM (
    'SALE_OUT', 'PURCHASE_IN', 'ADJUSTMENT',
    'RESERVATION', 'UNRESERVE', 'DEDUCT_FROM_RESERVATION',
    'RETURN_IN', 'VOID_RETURN', 'TRANSFER_IN', 'TRANSFER_OUT'
);

CREATE TYPE reference_type AS ENUM ('SALE', 'PURCHASE', 'ORDER', 'ADJUSTMENT', 'RETURN');

CREATE TABLE inventory_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id) NOT NULL,
    type movement_type NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2),
    unit_price DECIMAL(10,2),
    channel VARCHAR(10),
    reference_type reference_type,
    reference_id UUID,
    reason TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_movements_product ON inventory_movements(product_id, created_at DESC);

-- ===========================================
-- 7. ACCOUNTS (العملاء والموردين)
-- ===========================================
CREATE TYPE account_type AS ENUM ('CUSTOMER', 'SUPPLIER');

CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    type account_type NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    address TEXT,
    balance DECIMAL(12,2) DEFAULT 0,
    credit_limit DECIMAL(12,2),
    interest_rate_override DECIMAL(5,2),
    interest_enabled_override BOOLEAN,
    grace_days_override INT,
    loyalty_points INT DEFAULT 0,
    total_purchases INT DEFAULT 0,
    total_spent DECIMAL(12,2) DEFAULT 0,
    last_visit TIMESTAMPTZ,
    consent_given BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_accounts_phone ON accounts(phone);
CREATE INDEX idx_accounts_store_type ON accounts(store_id, type, is_active);

-- ===========================================
-- 8. ACCOUNT_TRANSACTIONS (حركات الحسابات)
-- ===========================================
CREATE TYPE transaction_type AS ENUM ('INVOICE', 'PAYMENT', 'INTEREST', 'WAIVE', 'REFUND');
CREATE TYPE payment_method AS ENUM ('CASH', 'CARD', 'CREDIT', 'ONLINE', 'MIXED', 'TRANSFER');

CREATE TABLE account_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id) NOT NULL,
    type transaction_type NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL,
    period_key VARCHAR(7),
    payment_method payment_method,
    reference_id UUID,
    notes TEXT,
    created_by VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_transactions_account ON account_transactions(account_id, created_at DESC);

-- ===========================================
-- 9. SHIFTS (الورديات)
-- ===========================================
CREATE TYPE shift_status AS ENUM ('OPEN', 'CLOSED');

CREATE TABLE shifts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    cashier_id UUID REFERENCES users(id),
    opening_cash DECIMAL(10,2) NOT NULL,
    closing_cash DECIMAL(10,2),
    expected_cash DECIMAL(10,2),
    cash_difference DECIMAL(10,2),
    status shift_status DEFAULT 'OPEN',
    opened_at TIMESTAMPTZ DEFAULT NOW(),
    closed_at TIMESTAMPTZ,
    notes TEXT
);

CREATE INDEX idx_shifts_store_status ON shifts(store_id, status);

-- ===========================================
-- 10. CASH_MOVEMENTS (حركات الصندوق)
-- ===========================================
CREATE TYPE cash_movement_type AS ENUM ('IN', 'OUT');

CREATE TABLE cash_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shift_id UUID REFERENCES shifts(id),
    type cash_movement_type NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    reason VARCHAR(255) NOT NULL,
    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 11. SALES (المبيعات)
-- ===========================================
CREATE TYPE sale_status AS ENUM ('COMPLETED', 'VOIDED', 'PENDING');
CREATE TYPE sale_channel AS ENUM ('POS', 'APP');

CREATE TABLE sales (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    shift_id UUID REFERENCES shifts(id),
    receipt_no VARCHAR(50) NOT NULL,
    channel sale_channel DEFAULT 'POS',
    source_order_id UUID,
    customer_id UUID REFERENCES accounts(id),
    cashier_id UUID REFERENCES users(id),
    payment_method payment_method NOT NULL,
    subtotal DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    discount_percent DECIMAL(5,2),
    tax DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    cash_received DECIMAL(10,2),
    change_given DECIMAL(10,2),
    status sale_status DEFAULT 'COMPLETED',
    voided_at TIMESTAMPTZ,
    voided_by UUID REFERENCES users(id),
    void_reason TEXT,
    notes TEXT,
    client_created_at TIMESTAMPTZ,
    server_created_at TIMESTAMPTZ DEFAULT NOW(),
    sync_status VARCHAR(20) DEFAULT 'SYNCED',

    UNIQUE(store_id, receipt_no)
);

CREATE INDEX idx_sales_store_date ON sales(store_id, server_created_at DESC);
CREATE INDEX idx_sales_customer ON sales(customer_id);

-- ===========================================
-- 12. SALE_ITEMS (عناصر المبيعات)
-- ===========================================
CREATE TABLE sale_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_id UUID REFERENCES sales(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(255),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    unit_cost DECIMAL(10,2),
    discount DECIMAL(10,2) DEFAULT 0,
    tax DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL
);

CREATE INDEX idx_sale_items_sale ON sale_items(sale_id);

-- ===========================================
-- 13. ORDERS (الطلبات من التطبيق)
-- ===========================================
CREATE TYPE order_status AS ENUM (
    'PENDING', 'ACCEPTED', 'PREPARED', 'READY',
    'OUT_FOR_DELIVERY', 'DELIVERED', 'CANCELLED'
);

CREATE TYPE cancel_reason AS ENUM (
    'CUSTOMER_REQUEST', 'OUT_OF_STOCK', 'STORE_CLOSED', 'OTHER'
);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    order_no VARCHAR(50) NOT NULL,
    customer_id UUID REFERENCES accounts(id),
    driver_id UUID,
    status order_status DEFAULT 'PENDING',
    payment_method payment_method,
    payment_status VARCHAR(20) DEFAULT 'PENDING',
    subtotal DECIMAL(10,2) NOT NULL,
    discount DECIMAL(10,2) DEFAULT 0,
    delivery_fee DECIMAL(10,2) DEFAULT 0,
    tax DECIMAL(10,2) DEFAULT 0,
    total DECIMAL(10,2) NOT NULL,
    address TEXT,
    latitude DECIMAL(10,7),
    longitude DECIMAL(10,7),
    notes TEXT,
    cancel_reason_code cancel_reason,
    cancel_reason_text TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    accepted_at TIMESTAMPTZ,
    prepared_at TIMESTAMPTZ,
    ready_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    cancelled_at TIMESTAMPTZ,
    sync_status VARCHAR(20) DEFAULT 'SYNCED'
);

CREATE INDEX idx_orders_store_status ON orders(store_id, status);

-- ===========================================
-- 14. ORDER_ITEMS (عناصر الطلبات)
-- ===========================================
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    product_name VARCHAR(255),
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL
);

-- ===========================================
-- 15. PURCHASES (المشتريات)
-- ===========================================
CREATE TYPE purchase_status AS ENUM ('DRAFT', 'COMPLETED', 'VOIDED');

CREATE TABLE purchases (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    supplier_id UUID REFERENCES accounts(id),
    invoice_no VARCHAR(50),
    invoice_date DATE,
    total DECIMAL(12,2) NOT NULL,
    tax DECIMAL(10,2) DEFAULT 0,
    is_paid BOOLEAN DEFAULT false,
    payment_method payment_method,
    invoice_image_url TEXT,
    ai_raw_json JSONB,
    status purchase_status DEFAULT 'COMPLETED',
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    sync_status VARCHAR(20) DEFAULT 'SYNCED'
);

-- ===========================================
-- 16. PURCHASE_ITEMS (عناصر المشتريات)
-- ===========================================
CREATE TABLE purchase_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_id UUID REFERENCES purchases(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    raw_name VARCHAR(255),
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    ai_confidence DECIMAL(3,2),
    is_confirmed BOOLEAN DEFAULT true
);

-- ===========================================
-- 17. DRIVERS (المناديب)
-- ===========================================
CREATE TYPE driver_type AS ENUM ('INTERNAL', 'EXTERNAL');

CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    type driver_type DEFAULT 'INTERNAL',
    avg_rating DECIMAL(2,1) DEFAULT 0,
    total_deliveries INT DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 18. DRIVER_RATINGS (تقييمات المناديب)
-- ===========================================
CREATE TABLE driver_ratings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    driver_id UUID REFERENCES drivers(id),
    order_id UUID REFERENCES orders(id),
    rating INT CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 19. PROMOTIONS (العروض)
-- ===========================================
CREATE TYPE promotion_type AS ENUM ('DISCOUNT', 'BUY_X_GET_Y', 'BUNDLE');

CREATE TABLE promotions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    type promotion_type NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    discount_percent DECIMAL(5,2),
    discount_amount DECIMAL(10,2),
    product_ids UUID[],
    min_purchase_amount DECIMAL(10,2),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    geo_fence_enabled BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    is_ai_generated BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 20. LOYALTY_TRANSACTIONS (نقاط الولاء)
-- ===========================================
CREATE TYPE loyalty_type AS ENUM ('EARN', 'REDEEM');

CREATE TABLE loyalty_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id),
    type loyalty_type NOT NULL,
    points INT NOT NULL,
    balance_after INT NOT NULL,
    reference_type VARCHAR(20),
    reference_id UUID,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 21. SMART_ORDERS (الطلبات الذكية)
-- ===========================================
CREATE TYPE smart_order_status AS ENUM ('DRAFT', 'SENT', 'CONFIRMED', 'DELIVERED');

CREATE TABLE smart_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    supplier_id UUID REFERENCES accounts(id),
    total_amount DECIMAL(12,2) NOT NULL,
    payment_method payment_method,
    status smart_order_status DEFAULT 'DRAFT',
    sent_via VARCHAR(20),
    items_json JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    sent_at TIMESTAMPTZ,
    confirmed_at TIMESTAMPTZ
);

-- ===========================================
-- 22. HOLD_INVOICES (الفواتير المعلقة)
-- ===========================================
CREATE TABLE hold_invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    label VARCHAR(255),
    customer_id UUID REFERENCES accounts(id),
    items JSONB NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 23. RETURNS (المرتجعات)
-- ===========================================
CREATE TYPE refund_method AS ENUM ('CASH', 'CARD', 'CREDIT');

CREATE TABLE returns (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    return_no VARCHAR(50) NOT NULL,
    original_sale_id UUID REFERENCES sales(id),
    items JSONB NOT NULL,
    refund_amount DECIMAL(10,2) NOT NULL,
    refund_method refund_method NOT NULL,
    reason TEXT,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 24. EXPIRY_TRACKING (تتبع الصلاحية)
-- ===========================================
CREATE TABLE product_expiry (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id),
    batch_number VARCHAR(50),
    expiry_date DATE NOT NULL,
    quantity INT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_expiry_date ON product_expiry(expiry_date);

-- ===========================================
-- 25. AUDIT_LOG (سجل العمليات)
-- ===========================================
CREATE TABLE audit_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    user_id UUID REFERENCES users(id),
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50),
    entity_id UUID,
    old_value JSONB,
    new_value JSONB,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_audit_store_date ON audit_log(store_id, created_at DESC);

-- ===========================================
-- 26. SETTINGS (الإعدادات)
-- ===========================================
CREATE TABLE settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    key VARCHAR(100) NOT NULL,
    value TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(store_id, key)
);

-- ===========================================
-- 27. SYNC_QUEUE (طابور المزامنة)
-- ===========================================
CREATE TYPE sync_action AS ENUM ('CREATE', 'UPDATE', 'DELETE');
CREATE TYPE sync_status AS ENUM ('PENDING', 'SYNCED', 'FAILED');

CREATE TABLE sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    device_id VARCHAR(100),
    entity_type VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    action sync_action NOT NULL,
    payload JSONB,
    status sync_status DEFAULT 'PENDING',
    attempts INT DEFAULT 0,
    last_error TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    synced_at TIMESTAMPTZ
);

CREATE INDEX idx_sync_queue_status ON sync_queue(store_id, status);

-- ===========================================
-- 28. EXPENSES (المصروفات)
-- ===========================================
CREATE TYPE expense_category AS ENUM (
    'UTILITIES', 'RENT', 'SALARIES', 'MAINTENANCE',
    'SUPPLIES', 'MARKETING', 'OTHER'
);

CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    amount DECIMAL(10,2) NOT NULL,
    category expense_category NOT NULL,
    description TEXT,
    expense_date DATE NOT NULL,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 29. INVENTORY_COUNTS (جلسات الجرد)
-- ===========================================
CREATE TYPE count_status AS ENUM ('IN_PROGRESS', 'COMPLETED', 'CANCELLED');

CREATE TABLE inventory_counts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id),
    status count_status DEFAULT 'IN_PROGRESS',
    started_by UUID REFERENCES users(id),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    notes TEXT
);

CREATE TABLE inventory_count_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    count_id UUID REFERENCES inventory_counts(id),
    product_id UUID REFERENCES products(id),
    system_quantity INT NOT NULL,
    counted_quantity INT,
    difference INT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 30. PRICE_HISTORY (سجل الأسعار)
-- ===========================================
CREATE TABLE price_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID REFERENCES products(id),
    old_price DECIMAL(10,2) NOT NULL,
    new_price DECIMAL(10,2) NOT NULL,
    reason TEXT,
    changed_by UUID REFERENCES users(id),
    changed_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 31. SALE_PAYMENTS (دفعات الفاتورة المتعددة) ⭐ NEW
-- ===========================================
CREATE TABLE sale_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sale_id UUID REFERENCES sales(id) ON DELETE CASCADE,
    method payment_method NOT NULL,
    amount DECIMAL(10,2) NOT NULL,

    -- للبطاقة
    card_last4 VARCHAR(4),
    rrn VARCHAR(20),
    terminal_id VARCHAR(50),

    -- للآجل
    account_id UUID REFERENCES accounts(id),

    -- للتحويل/المحفظة
    transaction_ref VARCHAR(100),

    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_sale_payments_sale ON sale_payments(sale_id);

-- ===========================================
-- 32. DEBT_REMINDER_SETTINGS (إعدادات تذكير الديون) ⭐ NEW
-- ===========================================
CREATE TABLE debt_reminder_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) UNIQUE,
    is_enabled BOOLEAN DEFAULT false,
    send_time TIME DEFAULT '10:00:00',

    use_whatsapp BOOLEAN DEFAULT true,
    use_sms BOOLEAN DEFAULT true,
    use_email BOOLEAN DEFAULT false,

    message_template TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 33. DEBT_REMINDER_SCHEDULE (جدول التذكيرات) ⭐ NEW
-- ===========================================
CREATE TABLE debt_reminder_schedule (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    settings_id UUID REFERENCES debt_reminder_settings(id) ON DELETE CASCADE,
    reminder_order INT NOT NULL,
    days_after_due INT NOT NULL,
    is_final BOOLEAN DEFAULT false,

    UNIQUE(settings_id, reminder_order)
);

-- ===========================================
-- 34. DEBT_REMINDER_LOG (سجل إرسال التذكيرات) ⭐ NEW
-- ===========================================
CREATE TYPE reminder_status AS ENUM ('PENDING', 'SENT', 'DELIVERED', 'FAILED');

CREATE TABLE debt_reminder_log (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id),
    transaction_id UUID REFERENCES account_transactions(id),
    schedule_id UUID REFERENCES debt_reminder_schedule(id),

    channel VARCHAR(20) NOT NULL,
    status reminder_status DEFAULT 'PENDING',

    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    fail_reason TEXT,

    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_reminder_log_account ON debt_reminder_log(account_id, created_at DESC);

-- ===========================================
-- 35. LOYALTY_SETTINGS (إعدادات الولاء) ⭐ NEW
-- ===========================================
CREATE TABLE loyalty_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    store_id UUID REFERENCES stores(id) UNIQUE,
    is_enabled BOOLEAN DEFAULT false,

    -- قواعد الاكتساب
    points_per_riyal DECIMAL(5,2) DEFAULT 1,
    min_purchase_amount DECIMAL(10,2) DEFAULT 10,
    bonus_categories UUID[],
    bonus_multiplier DECIMAL(3,1) DEFAULT 2,

    -- قواعد الاستبدال
    points_per_riyal_redemption INT DEFAULT 100,
    min_redemption_points INT DEFAULT 500,
    max_discount_percent DECIMAL(5,2) DEFAULT 50,

    -- الصلاحية
    points_expiry_months INT DEFAULT 12,
    expiry_reminder_days INT DEFAULT 30,

    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 36. LOYALTY_TIERS (مستويات الولاء) ⭐ NEW
-- ===========================================
CREATE TABLE loyalty_tiers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    settings_id UUID REFERENCES loyalty_settings(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    name_en VARCHAR(50),
    min_points INT NOT NULL,
    multiplier DECIMAL(3,2) DEFAULT 1,
    color VARCHAR(7),
    icon VARCHAR(10),
    benefits TEXT[],
    sort_order INT DEFAULT 0
);

-- ===========================================
-- 37. ACCOUNT_LOYALTY (رصيد نقاط العميل) ⭐ NEW
-- ===========================================
CREATE TABLE account_loyalty (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    account_id UUID REFERENCES accounts(id) UNIQUE,
    current_points INT DEFAULT 0,
    lifetime_points INT DEFAULT 0,
    current_tier_id UUID REFERENCES loyalty_tiers(id),
    tier_achieved_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================
-- 38. BRANCH_INVENTORY (مخزون الفرع) ⭐ NEW
-- ===========================================
CREATE TABLE branch_inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_id UUID NOT NULL,
    product_id UUID REFERENCES products(id),
    quantity INT DEFAULT 0,
    reserved_qty INT DEFAULT 0,
    min_stock INT DEFAULT 0,
    last_updated TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(branch_id, product_id)
);

CREATE INDEX idx_branch_inventory ON branch_inventory(branch_id, product_id);

-- ===========================================
-- 39. STOCK_TRANSFERS (عمليات نقل المخزون) ⭐ NEW
-- ===========================================
CREATE TYPE transfer_status AS ENUM ('DRAFT', 'PENDING', 'IN_TRANSIT', 'RECEIVED', 'CANCELLED');

CREATE TABLE stock_transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    from_branch_id UUID NOT NULL,
    to_branch_id UUID NOT NULL,
    status transfer_status DEFAULT 'DRAFT',

    created_by UUID REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    received_by UUID REFERENCES users(id),

    is_ai_suggested BOOLEAN DEFAULT false,
    ai_reason TEXT,

    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    sent_at TIMESTAMPTZ,
    received_at TIMESTAMPTZ
);

CREATE INDEX idx_transfers_branches ON stock_transfers(from_branch_id, to_branch_id, status);

-- ===========================================
-- 40. STOCK_TRANSFER_ITEMS (عناصر النقل) ⭐ NEW
-- ===========================================
CREATE TYPE item_condition AS ENUM ('GOOD', 'DAMAGED', 'MISSING');

CREATE TABLE stock_transfer_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    transfer_id UUID REFERENCES stock_transfers(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id),
    quantity INT NOT NULL,
    quantity_received INT,
    condition item_condition DEFAULT 'GOOD'
);

-- ===========================================
-- 41. AI_TRANSFER_SUGGESTIONS (اقتراحات AI) ⭐ NEW
-- ===========================================
CREATE TYPE suggestion_priority AS ENUM ('URGENT', 'NORMAL', 'LOW');
CREATE TYPE suggestion_status AS ENUM ('PENDING', 'APPLIED', 'IGNORED');

CREATE TABLE ai_transfer_suggestions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    owner_id UUID NOT NULL,
    from_branch_id UUID NOT NULL,
    to_branch_id UUID NOT NULL,
    product_id UUID REFERENCES products(id),
    suggested_qty INT NOT NULL,

    -- بيانات التحليل
    from_stock INT,
    to_stock INT,
    from_sales_rate DECIMAL(10,2),
    to_sales_rate DECIMAL(10,2),
    days_until_stockout DECIMAL(5,1),

    priority suggestion_priority DEFAULT 'NORMAL',
    reason TEXT,
    status suggestion_status DEFAULT 'PENDING',

    applied_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ai_suggestions_owner ON ai_transfer_suggestions(owner_id, status);

-- ===========================================
-- 42. BRANCH_SETTINGS (إعدادات الفرع) ⭐ NEW
-- ===========================================
CREATE TABLE branch_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    branch_id UUID NOT NULL UNIQUE,
    key VARCHAR(100) NOT NULL,
    value TEXT,
    updated_at TIMESTAMPTZ DEFAULT NOW(),

    UNIQUE(branch_id, key)
);

-- ===========================================
-- TRIGGERS & FUNCTIONS
-- ===========================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_stores_updated_at
    BEFORE UPDATE ON stores
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_products_updated_at
    BEFORE UPDATE ON products
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER update_accounts_updated_at
    BEFORE UPDATE ON accounts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-create inventory record
CREATE OR REPLACE FUNCTION create_inventory_on_product()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO inventory (product_id, quantity) VALUES (NEW.id, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER create_inventory_trigger
    AFTER INSERT ON products
    FOR EACH ROW EXECUTE FUNCTION create_inventory_on_product();

-- ===========================================
-- DEFAULT SETTINGS SEED
-- ===========================================
-- Will be inserted per store on creation
```

---

## 📅 خطة التنفيذ (24 أسبوع)

### Phase 0: Setup (Week 1)
| المهمة | الأيام |
|--------|--------|
| إنشاء Supabase Project | 0.5 |
| تشغيل SQL Migrations | 0.5 |
| إعداد Next.js + Tauri Project | 1 |
| إعداد MUI + Theme + RTL | 1 |
| إعداد i18n (6 لغات) | 1 |
| إعداد Zustand + React Query | 0.5 |
| إعداد ESLint + Prettier | 0.5 |

### Phase 1: Auth + Core (Week 2-3)
| المهمة | الأيام |
|--------|--------|
| Splash Screen | 0.5 |
| Login (OTP) | 2 |
| Store Select | 1 |
| Main Layout + Sidebar | 2 |
| Home Dashboard | 2 |
| Offline Indicator | 1 |
| Role-based Navigation | 1.5 |

### Phase 2: POS Core (Week 4-5)
| المهمة | الأيام |
|--------|--------|
| POS Layout (Split View) | 2 |
| Product Grid + Search | 2 |
| Barcode Scanner | 1.5 |
| Cart Panel | 2 |
| Customer Lookup | 1.5 |
| **Split Payment Screen** ⭐ | 2 |
| Receipt Screen | 1.5 |
| Print Queue | 1.5 |

### Phase 3: Products + Inventory (Week 6-7)
| المهمة | الأيام |
|--------|--------|
| Products List | 1.5 |
| Product Detail | 1 |
| Add/Edit Product | 2 |
| Categories | 1 |
| Inventory Overview | 1.5 |
| Stock Adjustment | 1.5 |
| Low Stock Alerts | 1 |

### Phase 4: Customers + Debts (Week 8-9)
| المهمة | الأيام |
|--------|--------|
| Customers List | 1.5 |
| Customer Account | 2 |
| Payment Recording | 1.5 |
| Interest Settings | 1.5 |
| Month Close | 2 |
| Debt Reports | 1.5 |

### Phase 5: Suppliers + Purchases (Week 10-11)
| المهمة | الأيام |
|--------|--------|
| Suppliers List | 1 |
| Supplier Detail | 1 |
| Manual Purchase | 2 |
| AI Invoice Import | 3 |
| Review Screen | 2 |
| Smart Order | 2 |

### Phase 6: Orders + Drivers (Week 12-13)
| المهمة | الأيام |
|--------|--------|
| Orders List | 1.5 |
| Order Detail | 2 |
| Status Flow | 1.5 |
| Driver Management | 2 |
| Driver Assignment | 1 |
| Driver Rating | 1 |

### Phase 7: Reports (Week 14-15)
| المهمة | الأيام |
|--------|--------|
| Sales Report | 2 |
| Inventory Report | 1.5 |
| Debts Report | 1.5 |
| VAT Report | 2 |
| Top Products | 1 |
| Peak Hours | 1 |
| Profit Margin | 1.5 |
| Period Comparison | 1.5 |
| Cashier Report | 1.5 |

### Phase 8: Loyalty Program ⭐ NEW (Week 16-17)
| المهمة | الأيام |
|--------|--------|
| Loyalty Settings | 2 |
| Loyalty Tiers (4 مستويات) | 2 |
| Points Earning Logic | 1.5 |
| Points Redemption (في POS) | 2 |
| Customer Points History | 1.5 |
| Expiring Points Alerts | 1 |

### Phase 9: WhatsApp + Debt Reminders ⭐ NEW (Week 18-19)
| المهمة | الأيام |
|--------|--------|
| WhatsApp Integration | 2 |
| Debt Reminder Settings | 2 |
| Reminder Scheduling | 2 |
| Auto-Send Cron Job | 2 |
| Reminder Log | 1 |
| ZATCA QR | 2 |

### Phase 10: Multi-Branch + AI Transfer ⭐ NEW (Week 20-21)
| المهمة | الأيام |
|--------|--------|
| Branches List | 1.5 |
| Branch Detail | 1 |
| Branch Inventory | 2 |
| Stock Transfer Screen | 2 |
| AI Transfer Suggestions | 3 |
| Transfer Status Flow | 1.5 |

### Phase 11: Settings + Operations (Week 22-23)
| المهمة | الأيام |
|--------|--------|
| General Settings | 1 |
| Store Settings | 1 |
| Printer Settings | 1.5 |
| Payment Devices | 2 |
| Cash Drawer | 2 |
| Expiry Tracking | 1.5 |
| User Management | 1.5 |
| Roles & Permissions | 1.5 |
| Backup | 1 |
| Audit Log | 1.5 |
| Promotions | 2 |
| Hold Invoice | 1 |
| Returns | 2 |

### Phase 12: Polish + Testing (Week 24)
| المهمة | الأيام |
|--------|--------|
| Sync Improvements | 2 |
| Error Handling | 1 |
| Performance Optimization | 1 |
| Testing | 3 |
| Documentation | 1 |
| Build & Package | 1 |

---

## 📊 ملخص الشاشات (103 شاشة)

| التصنيف | العدد |
|---------|-------|
| Auth | 3 |
| POS | 9 |
| Products | 5 |
| Inventory | 6 |
| Customers | 4 |
| Suppliers | 3 |
| Purchases | 4 |
| Orders | 4 |
| Drivers | 4 |
| Reports | 12 |
| Promotions | 4 |
| **Loyalty** ⭐ | **5** |
| **Branches** ⭐ | **5** |
| **WhatsApp & Reminders** ⭐ | **4** |
| Refunds | 6 |
| Offline & Sync | 4 |
| Shift & Cash | 5 |
| Printing | 3 |
| Settings | 8 |
| Other | 5 |

---

## 🔗 API Endpoints Summary

راجع ملف [POS_API_CONTRACT.md](./POS_API_CONTRACT.md) للتفاصيل الكاملة.

| Section | Endpoints |
|---------|-----------|
| Auth | 6 |
| Products | 7 |
| Inventory | 5 |
| Sales | 4 |
| Orders | 5 |
| Accounts | 6 |
| Purchases | 4 |
| Reports | 12 |
| Drivers | 5 |
| Promotions | 5 |
| Loyalty | 5 |
| WhatsApp | 4 |
| ZATCA | 4 |
| Settings | 20+ |

---

## 🛠️ أوامر البدء

```bash
# 1. إنشاء المشروع
pnpm create next-app pos-app --typescript --tailwind --app --src-dir

# 2. إضافة Tauri
pnpm add -D @tauri-apps/cli
pnpm tauri init

# 3. إضافة Dependencies
pnpm add @mui/material @emotion/react @emotion/styled
pnpm add @supabase/supabase-js @supabase/auth-helpers-nextjs
pnpm add zustand @tanstack/react-query
pnpm add next-intl react-hook-form @hookform/resolvers zod
pnpm add date-fns recharts

# 4. تشغيل Development
pnpm tauri dev

# 5. Build للإنتاج
pnpm tauri build
```

---

## 📝 ملاحظات مهمة

1. **Offline-First**: استخدام SQLite محلي مع Sync Queue
2. **i18n**: 6 لغات مع RTL support للعربية والأردو
3. **ZATCA**: QR Code متوافق مع المرحلة 2
4. **Security**: RLS policies في Supabase + Role-based UI
5. **Print**: دعم طابعات Thermal عبر Tauri
6. **Split Payment**: دعم تقسيم الفاتورة بين نقد + بطاقة + آجل
7. **Multi-Branch**: دعم إدارة فروع متعددة مع مخزون منفصل
8. **AI Transfer**: اقتراحات ذكية لنقل المخزون بين الفروع
9. **Loyalty**: برنامج ولاء مع 4 مستويات وصلاحية نقاط
10. **Auto-Reminders**: تذكير أوتوماتيكي للديون عبر WhatsApp/SMS

---

## 📊 ملخص جداول قاعدة البيانات (42 جدول)

| الفئة | العدد |
|-------|-------|
| Core (موجودة) | 20 |
| Split Payment | 1 |
| Debt Reminders | 3 |
| Loyalty | 4 |
| Multi-Branch | 5 |
| Additional | 9 |

---

**آخر تحديث:** 2026-02-02 | **Version:** 2.0.0
