# 💰 Admin POS - المالية والمقارنات وإدارة الموارد

> **⚠️ تنبيه**: هذا ملف تفاصيل داعمة (Supporting Details).  
> - المرجع النهائي: [`ADMIN_POS_SPEC.md`](../ADMIN_POS_SPEC.md) | [`ADMIN_API_CONTRACT.md`](../ADMIN_API_CONTRACT.md)  
> - الـ SQL Schema هنا **مقترح فقط (Draft)** - غير نهائي

**التاريخ**: 2026-01-15  
**إضافة**: Financial Management + Inter-Branch Operations

---

## 1️⃣ المالية - إدارة الديون

### Dashboard الديون (Consolidated)

```
Financial Dashboard - Debts:
├── Overview (All Stores)
│   ├── Total Debt: 50,000 ر.س
│   │   ├── Store 1 (بقالة الحي): 30,000 ر.س
│   │   └── Store 2 (بقالة السوق): 20,000 ر.س
│   │
│   ├── Overdue (متأخر): 15,000 ر.س
│   │   ├── >30 days: 8,000 ر.س ⚠️
│   │   ├── >60 days: 5,000 ر.س 🔴
│   │   └── >90 days: 2,000 ر.س 🔴
│   │
│   ├── Collections This Month: 12,000 ر.س
│   └── Default Rate: 3% ✅
│
└── Filters:
    ├── By Store
    ├── By Customer
    ├── By Status (Overdue/Current)
    └── By Amount Range
```

### تقرير الديون التفصيلي

```
Debts Report:
┌─────────────────────────────────────────────────────┐
│ Customer: فهد السعيد                                │
├─────────────────────────────────────────────────────┤
│ Store 1 (بقالة الحي):                               │
│   ├── Current Balance: 1,500 ر.س                   │
│   ├── Credit Limit: 2,000 ر.س                      │
│   ├── Available: 500 ر.س ✅                         │
│   ├── Last Payment: 3 days ago (500 ر.س)           │
│   ├── Overdue: 0 ر.س ✅                             │
│   └── Interest: 0% (grace period)                  │
│                                                     │
│ Store 2 (بقالة السوق):                              │
│   ├── Current Balance: 800 ر.س                     │
│   ├── Credit Limit: 1,000 ر.س                      │
│   ├── Available: 200 ر.س ✅                         │
│   ├── Last Payment: 1 week ago (200 ر.س)           │
│   ├── Overdue: 300 ر.س ⚠️                           │
│   └── Interest: 45 ر.س (15 days @ 10%/month)       │
│                                                     │
│ Combined Total: 2,300 ر.س                          │
│ [Send Reminder] [Request Payment] [Waive Interest] │
└─────────────────────────────────────────────────────┘
```

### Actions على الديون

```
Debt Management Actions:

1. Send Reminder (تذكير)
   ├── SMS: "عزيزي فهد، لديك دين متأخر 300 ر.س في بقالة السوق"
   ├── WhatsApp: رسالة + رابط للدفع
   └── Email: فاتورة مفصلة

2. Request Payment (طلب دفع)
   ├── من التطبيق (customer_app)
   ├── Cash من الكاشير
   └── Online (Stripe/Tap)

3. Waive Interest (إعفاء فائدة)
   ├── Owner Permission Required
   ├── Reason: "عميل قديم"
   └── Audit Log: "Interest waived by Owner"

4. Adjust Credit Limit
   ├── Increase: 1,000 → 2,000 ر.س
   └── Decrease: 2,000 → 500 ر.س

5. Block Customer (إيقاف)
   ├── Reason: "Debt >90 days"
   └── Effect: لا يقدر يطلب آجل
```

---

## 2️⃣ مراقبة الدخل

### Income Dashboard (Real-time)

```
Income Monitoring:
├── Today
│   ├── Total Revenue: 5,000 ر.س
│   │   ├── Store 1: 3,000 ر.س (60%)
│   │   └── Store 2: 2,000 ر.س (40%)
│   │
│   ├── By Payment Method:
│   │   ├── Cash: 2,500 ر.س (50%)
│   │   ├── Card: 1,500 ر.س (30%)
│   │   └── Credit: 1,000 ر.س (20%)
│   │
│   ├── By Channel:
│   │   ├── POS: 3,500 ر.س (70%)
│   │   └── App: 1,500 ر.س (30%)
│   │
│   └── Live Update: +150 ر.س (منذ 2 دقيقة) 📈
│
├── This Week
│   ├── Total: 35,000 ر.س
│   ├── Average/Day: 5,000 ر.س
│   ├── Growth: +12% vs last week ✅
│   └── Peak Day: Thursday (8,000 ر.س)
│
└── This Month
    ├── Total: 150,000 ر.س
    ├── Target: 200,000 ر.س
    ├── Achievement: 75% 📊
    └── Remaining Days: 10
```

### Income by Category

```
Revenue Breakdown:
├── Top Categories This Month:
│   ├── ألبان ومشتقاتها: 30,000 ر.س (20%)
│   ├── مواد غذائية: 25,000 ر.س (17%)
│   ├── مشروبات: 20,000 ر.س (13%)
│   ├── معلبات: 15,000 ر.س (10%)
│   └── Other: 60,000 ر.س (40%)
│
└── Top Products:
    ├── حليب نادك: 5,000 ر.س (200 units)
    ├── خبز: 4,000 ر.س (500 units)
    └── ماء: 3,000 ر.س (1000 units)
```

### Profit Margin Analysis

```
Profit Analysis:
├── Store 1 (بقالة الحي)
│   ├── Revenue: 90,000 ر.س
│   ├── Cost: 65,000 ر.س
│   ├── Gross Profit: 25,000 ر.س
│   └── Margin: 27.8% ✅
│
├── Store 2 (بقالة السوق)
│   ├── Revenue: 60,000 ر.س
│   ├── Cost: 45,000 ر.س
│   ├── Gross Profit: 15,000 ر.س
│   └── Margin: 25% ⚠️ (أقل من المتوسط)
│
└── Combined
    ├── Total Revenue: 150,000 ر.س
    ├── Total Cost: 110,000 ر.س
    ├── Gross Profit: 40,000 ر.س
    ├── Margin: 26.7%
    └── AI Insight: "هامش Store 2 منخفض. راجع أسعار البيع"
```

---

## 3️⃣ المقارنة بين الفروع

### Comparative Dashboard

```
Store Comparison:
┌─────────────────────────────────────────────────────┐
│                   Store 1 vs Store 2                │
├─────────────────────────────────────────────────────┤
│ Sales:                                              │
│   Store 1: ████████████████ 90,000 ر.س (60%)       │
│   Store 2: ██████████       60,000 ر.س (40%)       │
│                                                     │
│ Orders:                                             │
│   Store 1: ████████████████ 800 orders             │
│   Store 2: ████████         500 orders             │
│                                                     │
│ Avg Order Value:                                    │
│   Store 1: 112.5 ر.س ✅                             │
│   Store 2: 120 ر.س ✅ (أعلى)                        │
│                                                     │
│ Customers:                                          │
│   Store 1: 300 customers                           │
│   Store 2: 200 customers                           │
│   Shared: 50 customers (overlap)                   │
│                                                     │
│ Staff Efficiency:                                   │
│   Store 1: 3 cashiers → 30k/cashier/month          │
│   Store 2: 2 cashiers → 30k/cashier/month          │
│   Same! ✅                                          │
│                                                     │
│ Delivery Performance:                               │
│   Store 1: Avg 25 mins ✅                           │
│   Store 2: Avg 35 mins ⚠️ (بطيء)                    │
└─────────────────────────────────────────────────────┘
```

### Performance Metrics Comparison

```
KPI Comparison:
├── Revenue Growth
│   ├── Store 1: +15% 📈
│   └── Store 2: +8% ⚠️
│
├── Customer Retention
│   ├── Store 1: 85% ✅
│   └── Store 2: 78% ⚠️
│
├── Inventory Turnover
│   ├── Store 1: 6x/month ✅
│   └── Store 2: 4x/month ⚠️ (بطيء)
│
├── Debt Collection Rate
│   ├── Store 1: 92% ✅
│   └── Store 2: 88% ⚠️
│
└── AI Insight:
    "Store 2 يحتاج تحسين:
     - سرعة التوصيل (hire driver)
     - دوران المخزون (قلل الكميات)
     - استرجاع الديون (follow-up أكثر)"
```

### Side-by-Side Report

```
Detailed Comparison (This Month):

┌──────────────────┬─────────────┬─────────────┐
│ Metric           │ Store 1     │ Store 2     │
├──────────────────┼─────────────┼─────────────┤
│ Revenue          │ 90,000 ✅   │ 60,000      │
│ Orders           │ 800 ✅      │ 500         │
│ Customers        │ 300 ✅      │ 200         │
│ Avg Order        │ 112.5       │ 120 ✅      │
│ Gross Margin     │ 27.8% ✅    │ 25%         │
│ Staff Count      │ 3           │ 2           │
│ Debt             │ 30,000      │ 20,000 ✅   │
│ Overdue%         │ 15%         │ 10% ✅      │
│ Delivery Time    │ 25 min ✅   │ 35 min      │
│ Rating           │ 4.7 ⭐      │ 4.5 ⭐      │
└──────────────────┴─────────────┴─────────────┘

Recommendation:
Store 1 = أداء ممتاز، استمر
Store 2 = يحتاج تحسينات (delivery, turnover)
```

---

## 4️⃣ نقل المنتجات بين الفروع

### Transfer Inventory Screen

```
Transfer Products:
├── From Store:
│   └── Store 1 (بقالة الحي)
│       └── Warehouse: المستودع الرئيسي
│
├── To Store:
│   └── Store 2 (بقالة السوق)
│       └── Warehouse: مستودع السوق
│
├── Products to Transfer:
│   ├── حليب نادك
│   │   ├── Available in Store 1: 200
│   │   ├── Transfer Qty: 50 ✅
│   │   └── Remaining: 150
│   │
│   ├── خبز
│   │   ├── Available: 500
│   │   ├── Transfer: 100 ✅
│   │   └── Remaining: 400
│   │
│   └── ماء
│       ├── Available: 1000
│       ├── Transfer: 200 ✅
│       └── Remaining: 800
│
├── Transfer Details:
│   ├── Transfer Date: 2026-01-15
│   ├── Expected Delivery: Today 6 PM
│   ├── Driver: خالد المندوب
│   ├── Vehicle: تويوتا هايلكس (ABC 1234)
│   ├── Notes: "نقل عاجل - Store 2 نفذ المخزون"
│   └── Total Value: 5,000 ر.س
│
└── [Confirm Transfer] [Save as Draft]
```

### Transfer Approval Flow

```
Transfer Request:
├── Created by: Owner (محمد أحمد)
├── Status: PENDING_APPROVAL
│
├── Approvers (if configured):
│   ├── Store 1 Manager: ✅ Approved
│   └── Store 2 Manager: ⏳ Pending
│
└── After Full Approval:
    ├── Inventory updated:
    │   ├── Store 1: -50 حليب, -100 خبز, -200 ماء
    │   └── Store 2: +50 حليب, +100 خبز, +200 ماء
    │
    ├── Movement logged:
    │   └── type: INTER_STORE_TRANSFER
    │
    └── Notification:
        ├── Driver: "لديك نقل مجدول اليوم 6 PM"
        └── Managers: "تم الموافقة على النقل"
```

### Transfer History & Tracking

```
Transfer History:
├── #TRF-001 (2026-01-15)
│   ├── From: Store 1 → To: Store 2
│   ├── Items: 3 products, 350 units
│   ├── Value: 5,000 ر.س
│   ├── Driver: خالد
│   ├── Status: IN_TRANSIT 🚚
│   ├── GPS Tracking: [View on Map]
│   └── ETA: 6:00 PM
│
├── #TRF-002 (2026-01-10)
│   ├── From: Store 2 → To: Store 1
│   ├── Items: 2 products, 100 units
│   ├── Value: 2,000 ر.س
│   ├── Status: DELIVERED ✅
│   └── Delivered: 2026-01-10 7:30 PM
│
└── Statistics:
    ├── Total Transfers This Month: 5
    ├── Total Value: 15,000 ر.س
    └── On-Time Rate: 100% ✅
```

---

## 5️⃣ نقل الموظفين بين الفروع

### Staff Transfer/Reassignment

```
Transfer Staff:
├── Employee: علي الكاشير
│   ├── Current Store: Store 1 (بقالة الحي)
│   ├── Role: Cashier
│   ├── Hire Date: 2025-06-01
│   ├── Performance: ⭐⭐⭐⭐ (4/5)
│   └── Current Salary: 4,000 ر.س/month
│
├── Transfer To:
│   └── Store 2 (بقالة السوق)
│
├── Transfer Type:
│   ├── ⚪ Permanent (نقل دائم)
│   └── ⚫ Temporary (إعارة مؤقتة - 1 month)
│
├── Effective Date: 2026-02-01
│
├── Reason:
│   └── "Store 2 يحتاج كاشير إضافي، Store 1 عنده زيادة"
│
├── Salary Adjustment:
│   ├── Current: 4,000 ر.س
│   ├── New: 4,500 ر.س (+12.5%)
│   └── Reason: "Cost of living Store 2 أعلى"
│
└── Approvals Required:
    ├── Owner: ⏳ Pending
    ├── Store 1 Manager: ✅ Approved
    ├── Store 2 Manager: ✅ Approved
    └── Employee: ✅ Accepted
```

### Multi-Store Staff (Shared Staff)

```
Shared Staff Assignment:
├── Employee: سالم المدير
│   └── Role: Regional Manager (مدير إقليمي)
│
├── Assigned Stores:
│   ├── Store 1 (Primary): 60% time
│   │   ├── Monday-Wednesday
│   │   └── Salary Split: 60%
│   │
│   └── Store 2 (Secondary): 40% time
│       ├── Thursday-Saturday
│       └── Salary Split: 40%
│
├── Total Salary: 8,000 ر.س/month
│   ├── Paid by Store 1: 4,800 ر.س
│   └── Paid by Store 2: 3,200 ر.س
│
└── Permissions:
    ├── Full access to both stores
    ├── Can view/edit all data
    └── Can approve transfers between stores
```

### Temporary Coverage (إعارة مؤقتة)

```
Temporary Assignment:
├── Scenario: "Store 2 cashier مريض، Store 1 عنده زيادة"
│
├── Solution:
│   ├── Employee: أحمد الكاشير (من Store 1)
│   ├── Temporary Store: Store 2
│   ├── Duration: 1 week (2026-01-15 → 2026-01-22)
│   ├── Daily Allowance: +50 ر.س/day (مصاريف انتقال)
│   └── Return Date: 2026-01-23
│
└── Tracking:
    ├── Attendance:
    │   ├── Store 1: 0 days this week
    │   └── Store 2: 7 days (temporary)
    │
    └── Salary:
        ├── Base: 4,000 ر.س (Store 1 pays)
        ├── Allowance: 350 ر.س (Store 2 pays)
        └── Total: 4,350 ر.س this week
```

---

## 📊 Database Schema Updates

> **⚠️ تنبيه**: هذه جداول **مقترحة فقط (Draft Schema)** - ليست نهائية.  
> لا تستخدمها كمرجع للتنفيذ. انتظر الـ Database Schema النهائي.

### New Tables (Proposed):

```sql
-- Transfers بين الفروع
CREATE TABLE inventory_transfers (
  id UUID PRIMARY KEY,
  from_store_id UUID REFERENCES stores(id),
  to_store_id UUID REFERENCES stores(id),
  from_warehouse_id UUID,
  to_warehouse_id UUID,
  driver_id UUID,
  status TEXT,  -- PENDING/IN_TRANSIT/DELIVERED/CANCELLED
  transfer_date TIMESTAMP,
  expected_delivery TIMESTAMP,
  actual_delivery TIMESTAMP,
  total_value DECIMAL,
  notes TEXT,
  created_by UUID,
  created_at TIMESTAMP
);

CREATE TABLE transfer_items (
  id UUID PRIMARY KEY,
  transfer_id UUID REFERENCES inventory_transfers(id),
  product_id UUID,
  quantity DECIMAL,
  unit_cost DECIMAL,
  total DECIMAL
);

-- نقل الموظفين
CREATE TABLE staff_transfers (
  id UUID PRIMARY KEY,
  employee_id UUID REFERENCES users(id),
  from_store_id UUID,
  to_store_id UUID,
  transfer_type TEXT,  -- PERMANENT/TEMPORARY
  effective_date DATE,
  end_date DATE,  -- للمؤقت
  old_salary DECIMAL,
  new_salary DECIMAL,
  reason TEXT,
  status TEXT,  -- PENDING/APPROVED/REJECTED/COMPLETED
  created_by UUID,
  created_at TIMESTAMP
);

-- موظفين مشتركين
CREATE TABLE staff_store_assignments (
  id UUID PRIMARY KEY,
  employee_id UUID,
  store_id UUID,
  time_percentage INTEGER,  -- 60, 40, etc
  salary_split DECIMAL,
  is_primary BOOLEAN,
  start_date DATE,
  end_date DATE
);
```

---

## 🎯 الملخص

### الميزات المضافة:

1. ✅ **إدارة الديون المتقدمة**
   - Consolidated view
   - Per-store breakdown
   - Overdue tracking
   - Actions (remind, waive, block)

2. ✅ **مراقبة الدخل Real-time**
   - Live updates
   - By payment method
   - By channel (POS/App)
   - Profit margin analysis

3. ✅ **المقارنة بين الفروع**
   - Side-by-side metrics
   - Performance benchmarking
   - AI recommendations

4. ✅ **نقل المنتجات**
   - Inter-store transfers
   - Approval workflow
   - GPS tracking
   - History log

5. ✅ **نقل الموظفين**
   - Permanent/Temporary
   - Multi-store assignments
   - Salary adjustments
   - Coverage management


---

## 6️⃣ Revenue Analytics (POS vs Delivery) - جديد

### Channel Breakdown:

```
Total Revenue = POS Revenue + Delivery Revenue

Example:
Total: 10,000 ر.س/day
├── POS (60%): 6,000 ر.س
│   ├── Cash: 3,000 ر.س
│   ├── Card: 2,000 ر.س
│   └── Credit: 1,000 ر.س
│
└── Delivery (40%): 4,000 ر.س
    ├── Net Revenue: 3,850 ر.س
    ├── Delivery Fees: 150 ر.س
    └── Driver Commission: Included
```

### Metrics:

**POS Performance:**
- Avg transaction value
- Peak hours (18:00-19:00)
- Busiest day (Thursday)
- Payment method preference

**Delivery Performance:**
- Avg order value: 266 ر.س
- Avg delivery time: 28 min
- On-time rate: 85%
- Orders count per day

### Store Comparison:

```
بقالة الحي:
├── POS: 66% (strong in-store)
├── Delivery: 34%
└── Delivery time: 25 min ⚡

بقالة السوق:
├── POS: 50% (needs improvement)
├── Delivery: 50%
└── Delivery time: 35 min ⚠️
```

### API Integration:
```
GET /analytics/revenue/channels
- Total revenue breakdown
- POS vs Delivery
- Trends (7 days)
- Growth percentages

GET /analytics/revenue/comparison
- Multi-store comparison
- Performance metrics
- AI recommendations
```

---

## 7️⃣ Real-time Order Tracking - جديد

### GPS Tracking:

```
Order Lifecycle with Real-time Updates:

1. Order Created (10:00 AM)
   └── Notification to owner

2. Order Confirmed (10:02 AM)
   └── Auto-assign driver

3. Driver Assigned (10:05 AM)
   └── Notification to driver

4. Driver at Store (10:15 AM)
   └── Pickup confirmation

5. Out for Delivery (10:20 AM)
   └── GPS tracking starts
   └── Location updates every 5 sec
   └── ETA: 27 minutes
   └── Distance: 8.2 km

6. Delivered (10:47 AM)
   └── Photo/Signature proof
   └── Payment collected (if COD)
```

### Features:

**Real-time Data:**
- Driver location (lat, lng)
- Speed: 45 km/h
- Heading: 180°
- ETA calculations
- Distance remaining

**Timeline Visualization:**
- Complete order history
- Status changes
- Timestamps
- Notes/comments

### Notification Integration:

```
Owner receives:
├── NEW_ORDER
├── ORDER_ACCEPTED
├── DRIVER_ASSIGNED
├── DRIVER_CHANGED (if needed)
└── DELIVERY_STATUS (delivered)

Each notification has:
- Real-time updates
- Click to track
- Quick actions (Accept/Reject)
```

---

**📅 التاريخ**: 2026-01-15  
**🔄 آخر تحديث**: 2026-01-15 (Added Revenue Analytics + Order Tracking)  
**✅ الحالة**: Financial & Operations Features Complete
