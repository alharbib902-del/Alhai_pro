# 🛒 Customer App - Multi-Store Support
**عميل واحد → عدة بقالات في الحي**

**التاريخ**: 2026-01-15

---

## 📱 السيناريو

### User Story:
> **كعميل**، أريد رؤية البقالات القريبة مني، واختيار أي واحدة، ورؤية مشترياتي وديوني مع كل بقالة بشكل منفصل.

### المثال:
```
العميل محمد:
├─ يفتح التطبيق
├─ يشوف 3 بقالات قريبة:
│  ├─ بقالة الحي (500م)
│  ├─ بقالة النور (800م)
│  └─ بقالة السلام (1.2كم)
│
├─ يختار "بقالة الحي"
│  ├─ يشوف ديونه: 150 ر.س
│  ├─ يشوف طلباته السابقة (5 طلبات)
│  └─ يطلب طلب جديد
│
└─ يختار "بقالة النور"
   ├─ يشوف ديونه: 0 ر.س (ما عليه دين)
   ├─ يشوف طلباته السابقة (2 طلبات)
   └─ يطلب طلب جديد
```

---

## 🗄️ Database Schema

### 1. Global Customers (سجل واحد للعميل)

```sql
CREATE TABLE global_customers (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  phone TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  email TEXT,
  location GEOGRAPHY(POINT), -- للبحث حسب القرب
  created_at TIMESTAMPTZ DEFAULT now()
);
```

### 2. Customer Accounts (حساب لكل بقالة)

```sql
CREATE TABLE customer_accounts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES global_customers(id),
  store_id UUID NOT NULL REFERENCES stores(id),
  balance DECIMAL(10,2) DEFAULT 0, -- الدين
  credit_limit DECIMAL(10,2) DEFAULT 500, -- الحد الأقصى للآجل
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(customer_id, store_id)
);

-- RLS: العميل يشوف حساباته فقط
CREATE POLICY "Customers view their accounts"
ON customer_accounts FOR SELECT
USING (customer_id = auth.uid());
```

### 3. Orders (الطلبات)

```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  account_id UUID NOT NULL REFERENCES customer_accounts(id),
  customer_id UUID NOT NULL REFERENCES global_customers(id),
  store_id UUID NOT NULL REFERENCES stores(id),
  total DECIMAL(10,2) NOT NULL,
  status TEXT NOT NULL, -- 'PENDING', 'ACCEPTED', 'DELIVERED'
  payment_status TEXT DEFAULT 'PENDING', -- 'PAID', 'CREDIT'
  created_at TIMESTAMPTZ DEFAULT now()
);

-- RLS: العميل يشوف طلباته فقط
CREATE POLICY "Customers view their orders"
ON orders FOR SELECT
USING (customer_id = auth.uid());
```

---

## 📱 User Flow الكامل

### Step 1: التسجيل (مرة واحدة)

```dart
// Customer App - Sign Up
final response = await supabase.auth.signUp(
  phone: '0501234567',
  password: 'password',
);

// إنشاء Global Customer
await supabase.from('global_customers').insert({
  'id': response.user!.id,
  'phone': '0501234567',
  'name': 'محمد أحمد',
  'location': 'POINT(46.6753 24.7136)', // Riyadh
});
```

### Step 2: رؤية البقالات القريبة

```dart
// API: GET /stores/nearby
final nearbyStores = await supabase.rpc('get_nearby_stores', params: {
  'lat': 24.7136,
  'lng': 46.6753,
  'radius_km': 5,
});

// Response:
// [
//   { id: 'store-1', name: 'بقالة الحي', distance: 0.5 },
//   { id: 'store-2', name: 'بقالة النور', distance: 0.8 },
//   { id: 'store-3', name: 'بقالة السلام', distance: 1.2 },
// ]
```

**SQL Function**:
```sql
CREATE OR REPLACE FUNCTION get_nearby_stores(
  lat DECIMAL,
  lng DECIMAL,
  radius_km DECIMAL DEFAULT 5
)
RETURNS TABLE (
  id UUID,
  name TEXT,
  distance_km DECIMAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    s.id,
    s.name,
    ST_Distance(
      s.location::geography,
      ST_MakePoint(lng, lat)::geography
    ) / 1000 AS distance_km
  FROM stores s
  WHERE ST_DWithin(
    s.location::geography,
    ST_MakePoint(lng, lat)::geography,
    radius_km * 1000
  )
  AND s.is_active = true
  ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql;
```

### Step 3: اختيار بقالة ورؤية الحساب

```dart
// العميل اختار "بقالة الحي"
final selectedStoreId = 'store-1';

// جلب (أو إنشاء) الحساب
var account = await supabase
  .from('customer_accounts')
  .select()
  .eq('customer_id', userId)
  .eq('store_id', selectedStoreId)
  .maybeSingle();

if (account == null) {
  // أول مرة يتعامل مع هذي البقالة
  account = await supabase.from('customer_accounts').insert({
    'customer_id': userId,
    'store_id': selectedStoreId,
    'balance': 0,
  }).select().single();
}

// عرض المعلومات:
print('الدين: ${account['balance']} ر.س');
```

### Step 4: رؤية الطلبات السابقة

```dart
// جلب طلبات العميل من هذه البقالة
final orders = await supabase
  .from('orders')
  .select('*, order_items(*)')
  .eq('customer_id', userId)
  .eq('store_id', selectedStoreId)
  .order('created_at', ascending: false);

// عرض:
// - طلب #123 - 50 ر.س - منذ 3 أيام
// - طلب #122 - 80 ر.س - منذ أسبوع
```

### Step 5: طلب جديد

```dart
// إنشاء طلب
final order = await supabase.from('orders').insert({
  'account_id': account['id'],
  'customer_id': userId,
  'store_id': selectedStoreId,
  'total': 120.00,
  'status': 'PENDING',
  'payment_status': 'CREDIT', // آجل
}).select().single();

// إضافة items
await supabase.from('order_items').insert([
  { 'order_id': order['id'], 'product_id': 'p1', 'quantity': 2 },
  { 'order_id': order['id'], 'product_id': 'p2', 'quantity': 3 },
]);

// تحديث الدين
await supabase.from('customer_accounts')
  .update({ 'balance': account['balance'] - 120.00 })
  .eq('id', account['id']);
```

---

## 🎨 UI Screens المقترحة

### Screen 1: Nearby Stores

```
┌─────────────────────────────────┐
│  📍 البقالات القريبة            │
├─────────────────────────────────┤
│                                 │
│  📦 بقالة الحي               ← │
│     500م · متاح الآن            │
│     الدين: 150 ر.س              │
│                                 │
│  📦 بقالة النور              ← │
│     800م · متاح الآن            │
│     ما عليك دين ✅              │
│                                 │
│  📦 بقالة السلام             ← │
│     1.2كم · متاح الآن           │
│     الدين: 50 ر.س               │
│                                 │
└─────────────────────────────────┘
```

### Screen 2: Store Details

```
┌─────────────────────────────────┐
│  ← بقالة الحي                   │
├─────────────────────────────────┤
│  📊 حسابك                       │
│  ┌───────────────────────────┐  │
│  │ الدين الحالي:  150 ر.س   │  │
│  │ آخر طلب:     منذ 3 أيام   │  │
│  └───────────────────────────┘  │
│                                 │
│  📦 الطلبات السابقة (5)        │
│  ┌───────────────────────────┐  │
│  │ #123 - 50 ر.س - منذ 3 أيام│ │
│  │ #122 - 80 ر.س - منذ أسبوع │  │
│  └───────────────────────────┘  │
│                                 │
│  [➕ طلب جديد]                 │
│  [💰 سداد الدين]               │
└─────────────────────────────────┘
```

### Screen 3: My Accounts (All Stores)

```
┌─────────────────────────────────┐
│  💳 حساباتي                     │
├─────────────────────────────────┤
│                                 │
│  إجمالي الديون: 200 ر.س        │
│                                 │
│  📦 بقالة الحي                  │
│     الدين: 150 ر.س              │
│     5 طلبات                      │
│                                 │
│  📦 بقالة النور                 │
│     بدون ديون ✅                │
│     2 طلبات                      │
│                                 │
│  📦 بقالة السلام                │
│     الدين: 50 ر.س               │
│     8 طلبات                      │
│                                 │
└─────────────────────────────────┘
```

---

## 🔌 APIs المطلوبة

### 1. GET /stores/nearby
```
Query: ?lat=24.7136&lng=46.6753&radius=5
Response: [{ id, name, distance, is_active }]
```

### 2. GET /customers/me/accounts
```
Headers: Authorization: Bearer {token}
Response: [
  { 
    store_id, 
    store_name, 
    balance, 
    order_count,
    last_order_date 
  }
]
```

### 3. GET /customers/me/orders
```
Query: ?store_id={store_id}
Response: [{ id, total, status, created_at, items[] }]
```

### 4. POST /orders
```
Body: {
  store_id,
  items: [{ product_id, quantity }],
  payment_method: 'CREDIT' | 'CASH'
}
Response: { order_id, total, new_balance }
```

### 5. POST /customers/me/payments
```
Body: {
  store_id,
  amount,
  payment_method: 'ONLINE' | 'CASH'
}
Response: { new_balance }
```

---

## 🛡️ Security & RLS

### RLS Policies

```sql
-- Global Customers: يشوف بياناته فقط
CREATE POLICY "Customers manage their profile"
ON global_customers FOR ALL
USING (id = auth.uid());

-- Customer Accounts: يشوف حساباته فقط
CREATE POLICY "Customers view their accounts"
ON customer_accounts FOR SELECT
USING (customer_id = auth.uid());

-- Orders: يشوف طلباته فقط
CREATE POLICY "Customers view their orders"
ON orders FOR SELECT
USING (customer_id = auth.uid());

CREATE POLICY "Customers create orders"
ON orders FOR INSERT
WITH CHECK (customer_id = auth.uid());

-- Store يشوف طلبات عملائه
CREATE POLICY "Stores view their orders"
ON orders FOR SELECT
USING (
  store_id IN (
    SELECT id FROM stores WHERE owner_id = auth.uid()
  )
);
```

---

## 📊 أمثلة عملية

### مثال 1: العميل يشوف كل حساباته

```dart
final myAccounts = await supabase
  .from('customer_accounts')
  .select('*, stores(name)')
  .eq('customer_id', userId);

// Result:
// [
//   { store: { name: 'بقالة الحي' }, balance: -150 },
//   { store: { name: 'بقالة النور' }, balance: 0 },
//   { store: { name: 'بقالة السلام' }, balance: -50 },
// ]
```

### مثال 2: البقالة تشوف طلبات عملائها

```dart
// في POS App
final storeOrders = await supabase
  .from('orders')
  .select('*, global_customers(name, phone)')
  .eq('store_id', myStoreId)
  .eq('status', 'PENDING');

// Result:
// [
//   { 
//     id: 'order-1',
//     customer: { name: 'محمد', phone: '050...' },
//     total: 120,
//     status: 'PENDING'
//   }
// ]
```

### مثال 3: العميل يسدد دين

```dart
// العميل يسدد 100 ر.س لبقالة الحي
await supabase.rpc('process_payment', params: {
  'p_customer_id': userId,
  'p_store_id': storeId,
  'p_amount': 100.00,
});
```

**SQL Function**:
```sql
CREATE OR REPLACE FUNCTION process_payment(
  p_customer_id UUID,
  p_store_id UUID,
  p_amount DECIMAL
) RETURNS void AS $$
DECLARE
  v_account_id UUID;
BEGIN
  -- جلب الحساب
  SELECT id INTO v_account_id
  FROM customer_accounts
  WHERE customer_id = p_customer_id
    AND store_id = p_store_id;
  
  -- تحديث الرصيد
  UPDATE customer_accounts
  SET balance = balance + p_amount
  WHERE id = v_account_id;
  
  -- تسجيل الحركة
  INSERT INTO transactions (account_id, store_id, type, amount)
  VALUES (v_account_id, p_store_id, 'PAYMENT', p_amount);
END;
$$ LANGUAGE plpgsql;
```

---

## ✅ الخلاصة

### الفوائد:

1. ✅ **عميل واحد → عدة بقالات**
2. ✅ **ديون منفصلة** لكل بقالة
3. ✅ **طلبات منفصلة** لكل بقالة
4. ✅ **أمان كامل** - RLS policies
5. ✅ **تجربة سلسة** - يختار ويطلب بسهولة

### الخطوات القادمة:

1. تطبيق Migration
2. بناء Customer App screens
3. APIs implementation
4. Testing مع عدة عملاء وبقالات

---

**جاهز للتطبيق!** 🚀
