# 📱 Admin POS - Product Requirements Document (PRD)

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Status:** ✅ Final - Ready for Development

---

## 📋 جدول المحتويات

1. [نظرة عامة](#نظرة-عامة)
2. [قائمة الشاشات الكاملة](#قائمة-الشاشات-الكاملة)
3. [Route Dictionary](#route-dictionary)
4. [User Stories & Acceptance Criteria](#user-stories--acceptance-criteria)
5. [الأولويات والمراحل](#الأولويات-والمراحل)

---

## 🎯 نظرة عامة

### ما هو Admin POS؟
**Admin POS** هو تطبيق SaaS Multi-Tenant لأصحاب البقالات (Owners) لإدارة:
- بقالة واحدة أو أكثر (حسب الاشتراك)
- الموظفين (مدراء/كاشيرات/مناديب)
- المخزون والمستودعات
- العملاء والطلبات
- التقارير المالية و KPI
- النقل بين الفروع

### المنصات:
- Flutter (Mobile - iOS/Android)
- Flutter Web (Desktop Browser)
- Flutter Desktop (Windows/macOS)

### التكامل:
- **customer_app**: مراقبة الطلبات القادمة
- **pos_app**: إنشاء Stores + تعيين Cashiers
- **alhai_core**: Models + Repositories مشتركة
- **alhai_design_system**: UI Components

---

## 📱 قائمة الشاشات الكاملة

### إجمالي الشاشات: **106 شاشة** (94 أساسية + 12 للـ B2B)

---

## Phase 1: Onboarding & Authentication (6 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 1 | Splash Screen | `/splash` | P0 |
| 2 | Onboarding (Slides) | `/onboarding` | P0 |
| 3 | Login | `/login` | P0 |
| 4 | Sign Up | `/signup` | P0 |
| 5 | Pending Approval | `/pending-approval` | P0 |
| 6 | Forgot Password | `/forgot-password` | P1 |

---

## Phase 2: Dashboard & Stores (14 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 7 | Main Dashboard | `/dashboard` | P0 |
| 8 | Stores List | `/stores` | P0 |
| 9 | Create Store (Wizard) | `/stores/create` | P0 |
| 10 | Store Details | `/stores/:id` | P0 |
| 11 | Store Settings | `/stores/:id/settings` | P0 |
| 12 | Store Analytics | `/stores/:id/analytics` | P1 |
| 13 | Store QR Code | `/stores/:id/qr` | P1 |
| 14 | Store Hours | `/stores/:id/hours` | P1 |
| 15 | Delivery Zones | `/stores/:id/zones` | P1 |
| 16 | Payment Methods | `/stores/:id/payment-methods` | P1 |
| 17 | Store Comparison | `/stores/compare` | P1 |
| 18 | Store Map View | `/stores/map` | P2 |
| 19 | Store Performance | `/stores/:id/performance` | P2 |
| 20 | Store Branding | `/stores/:id/branding` | P2 |

---

## Phase 3: Staff Management (10 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 21 | Staff List | `/staff` | P0 |
| 22 | Add Cashier | `/staff/add/cashier` | P0 |
| 23 | Add Driver | `/staff/add/driver` | P0 |
| 24 | Add Manager | `/staff/add/manager` | P0 |
| 25 | Staff Details | `/staff/:id` | P0 |
| 26 | Permissions Editor | `/staff/:id/permissions` | P1 |
| 27 | Staff Transfer | `/staff/:id/transfer` | P1 |
| 28 | Attendance Tracker | `/staff/attendance` | P2 |
| 29 | Staff Performance | `/staff/:id/performance` | P2 |
| 30 | Payroll (Basic) | `/staff/payroll` | P2 |

---

## Phase 4: Products & Inventory (14 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 31 | Products List (All Stores) | `/products` | P0 |
| 32 | Add Product | `/products/add` | P0 |
| 33 | Product Details | `/products/:id` | P0 |
| 34 | Edit Product | `/products/:id/edit` | P0 |
| 35 | Categories Management | `/categories` | P0 |
| 36 | Warehouses List | `/warehouses` | P0 |
| 37 | Warehouse Details | `/warehouses/:id` | P0 |
| 38 | Transfer Inventory | `/warehouses/transfer` | P1 |
| 39 | Transfer History | `/warehouses/transfers` | P1 |
| 40 | Stock Alerts | `/inventory/alerts` | P1 |
| 41 | Expiry Tracking | `/inventory/expiry` | P1 |
| 42 | Barcode Scanner | `/products/scan` | P2 |
| 43 | Bulk Import Products | `/products/import` | P2 |
| 44 | Inventory Audit | `/inventory/audit` | P2 |

---

## Phase 5: Customers (8 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 45 | Customers List | `/customers` | P0 |
| 46 | Customer Details | `/customers/:id` | P0 |
| 47 | Customer Accounts (Multi-Store) | `/customers/:id/accounts` | P0 |
| 48 | Customer Map View | `/customers/map` | P1 |
| 49 | Customer Segments | `/customers/segments` | P1 |
| 50 | Customer Loyalty | `/customers/:id/loyalty` | P1 |
| 51 | Shared Customers | `/customers/shared` | P2 |
| 52 | Customer Behavior Analytics | `/customers/analytics` | P2 |

---

## Phase 6: Orders & Deliveries (9 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 53 | Orders List (All Stores) | `/orders` | P0 |
| 54 | Order Details | `/orders/:id` | P0 |
| 55 | Assign Driver | `/orders/:id/assign-driver` | P0 |
| 56 | Deliveries Map | `/deliveries/map` | P1 |
| 57 | Driver Tracking | `/deliveries/track/:orderId` | P1 |
| 58 | Order States Management | `/orders/states` | P1 |
| 59 | Returns Management | `/orders/returns` | P1 |
| 60 | Refunds | `/orders/refunds` | P2 |
| 61 | Delivery Zones Heatmap | `/deliveries/heatmap` | P2 |

---

## Phase 7: Financial & Reports (12 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 62 | Financial Dashboard | `/financial` | P0 |
| 63 | Sales Report | `/reports/sales` | P0 |
| 64 | Debts Dashboard | `/financial/debts` | P0 |
| 65 | Debts Report (Detailed) | `/reports/debts` | P0 |
| 66 | Payments History | `/financial/payments` | P0 |
| 67 | VAT Report | `/reports/vat` | P1 |
| 68 | Profit/Loss Statement | `/reports/profit-loss` | P1 |
| 69 | Cashier Performance | `/reports/cashier` | P1 |
| 70 | Driver Commission | `/reports/driver-commission` | P2 |
| 71 | Income Trends | `/reports/income-trends` | P2 |
| 72 | Expense Tracking | `/financial/expenses` | P2 |
| 73 | Tax Summary | `/reports/tax-summary` | P2 |

---

## Phase 8: KPI & AI Insights (7 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 74 | KPI Dashboard | `/kpi` | P1 |
| 75 | AI Insights | `/ai/insights` | P1 |
| 76 | Sales Trends | `/analytics/sales-trends` | P1 |
| 77 | Customer Behavior | `/analytics/customer-behavior` | P1 |
| 78 | Inventory Optimization | `/ai/inventory-optimization` | P2 |
| 79 | Predictive Analytics | `/ai/predictions` | P2 |
| 80 | Recommendations Engine | `/ai/recommendations` | P2 |

---

## Phase 9: Settings (8 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 81 | General Settings | `/settings` | P0 |
| 82 | Notification Settings | `/settings/notifications` | P1 |
| 83 | Payment Gateway | `/settings/payment-gateway` | P1 |
| 84 | Backup & Restore | `/settings/backup` | P2 |
| 85 | API Keys | `/settings/api-keys` | P2 |
| 86 | Webhooks | `/settings/webhooks` | P2 |
| 87 | Integrations | `/settings/integrations` | P2 |
| 88 | Security Settings | `/settings/security` | P2 |

---

## Phase 10: Account & Subscription (6 شاشات)

| # | الشاشة | المسار | الأولوية |
|---|--------|--------|----------|
| 89 | My Profile | `/profile` | P0 |
| 90 | Subscription Plan | `/subscription` | P0 |
| 91 | Billing History | `/billing` | P0 |
| 92 | Upgrade Plan | `/subscription/upgrade` | P0 |
| 93 | My Referrals | `/referrals` | P1 |
| 94 | Referral Earnings | `/referrals/earnings` | P2 |

---

## 📍 Route Dictionary

```dart
class AppRoutes {
  // Phase 1: Auth
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const pendingApproval = '/pending-approval';
  static const forgotPassword = '/forgot-password';
  
  // Phase 2: Dashboard & Stores
  static const dashboard = '/dashboard';
  static const stores = '/stores';
  static const createStore = '/stores/create';
  static const storeDetails = '/stores/:id';
  static const storeSettings = '/stores/:id/settings';
  static const storeAnalytics = '/stores/:id/analytics';
  static const storeQR = '/stores/:id/qr';
  static const storeHours = '/stores/:id/hours';
  static const deliveryZones = '/stores/:id/zones';
  static const paymentMethods = '/stores/:id/payment-methods';
  static const storeComparison = '/stores/compare';
  
  // Phase 3: Staff
  static const staff = '/staff';
  static const addCashier = '/staff/add/cashier';
  static const addDriver = '/staff/add/driver';
  static const addManager = '/staff/add/manager';
  static const staffDetails = '/staff/:id';
  static const staffPermissions = '/staff/:id/permissions';
  static const staffTransfer = '/staff/:id/transfer';
  
  // Phase 4: Products & Inventory
  static const products = '/products';
  static const addProduct = '/products/add';
  static const productDetails = '/products/:id';
  static const categories = '/categories';
  static const warehouses = '/warehouses';
  static const warehouseDetails = '/warehouses/:id';
  static const transferInventory = '/warehouses/transfer';
  static const stockAlerts = '/inventory/alerts';
  
  // Phase 5: Customers
  static const customers = '/customers';
  static const customerDetails = '/customers/:id';
  static const customerAccounts = '/customers/:id/accounts';
  static const customerMap = '/customers/map';
  
  // Phase 6: Orders
  static const orders = '/orders';
  static const orderDetails = '/orders/:id';
  static const assignDriver = '/orders/:id/assign-driver';
  static const deliveriesMap = '/deliveries/map';
  static const driverTracking = '/deliveries/track/:orderId';
  
  // Phase 7: Financial
  static const financial = '/financial';
  static const salesReport = '/reports/sales';
  static const debts = '/financial/debts';
  static const debtsReport = '/reports/debts';
  static const vatReport = '/reports/vat';
  static const profitLoss = '/reports/profit-loss';
  
  // Phase 8: KPI & AI
  static const kpi = '/kpi';
  static const aiInsights = '/ai/insights';
  static const salesTrends = '/analytics/sales-trends';
  static const inventoryOptimization = '/ai/inventory-optimization';
  
  // Phase 9: Settings
  static const settings = '/settings';
  static const notifications = '/settings/notifications';
  static const paymentGateway = '/settings/payment-gateway';
  static const apiKeys = '/settings/api-keys';
  
  // Phase 10: Account
  static const profile = '/profile';
  static const subscription = '/subscription';
  static const billing = '/billing';
  static const upgradeSubscription = '/subscription/upgrade';
  static const myReferrals = '/referrals';
}
```

---

## 📝 User Stories & Acceptance Criteria

### US-1.1: تسجيل حساب جديد (Owner Signup)

**كصاحب بقالة**، أريد التسجيل في المنصة

#### Acceptance Criteria:
- [ ] حقول التسجيل:
  - الاسم الكامل
  - رقم الجوال (OTP verification)
  - البريد الإلكتروني
  - رقم السجل التجاري (اختياري)
  - صورة الهوية (للتوثيق)
  - Referral Code (إن وجد)
- [ ] OTP يُرسل للجوال
- [ ] التحقق من OTP
- [ ] Upload صورة الهوية (R2)
- [ ] الحالة: PENDING_APPROVAL
- [ ] رسالة: "سيتم مراجعة طلبك خلال 24 ساعة"

---

### US-1.2: تسجيل الدخول

**كصاحب بقالة**، أريد تسجيل الدخول

#### Acceptance Criteria:
- [ ] Login بالجوال + Password
- [ ] أو Login بالـ OTP مباشرة
- [ ] Remember me checkbox
- [ ] Forgot password link
- [ ] إذا PENDING_APPROVAL → شاشة الانتظار
- [ ] إذا APPROVED → Dashboard

---

### US-2.1: إنشاء بقالة جديدة

**كصاحب بقالة مُعتمد**، أريد إنشاء بقالتي الأولى

#### Acceptance Criteria:
- [ ] Wizard بـ 4 خطوات:
  - Step 1: معلومات أساسية
  - Step 2: الموقع (GPS + Address)
  - Step 3: الإعدادات (ضريبة، عملة، رسوم توصيل)
  - Step 4: المستودع الأساسي
- [ ] التحقق من حد الاشتراك (Basic = 1 store max)
- [ ] Upload لوغو البقالة (R2)
- [ ] حفظ GPS location
- [ ] إنشاء Warehouse تلقائياً
- [ ] Redirect to Dashboard بعد الانتهاء

---

### US-2.2: عرض Dashboard متعدد البقالات

**كصاحب بقالة بأكثر من فرع**، أريد رؤية أداء جميع البقالات

#### Acceptance Criteria:
- [ ] عرض KPI لكل بقالة:
  - مبيعات اليوم
  - الطلبات
  - العملاء النشطين
  - الديون
- [ ] إجمالي (Consolidated) لكل البقالات
- [ ] Filters: Today/Week/Month
- [ ] Quick actions لكل بقالة
- [ ] Live updates (كل دقيقتين)

---

### US-2.3: مقارنة الأداء بين الفروع

**كصاحب بقالة**، أريد مقارنة أداء البقالات

#### Acceptance Criteria:
- [ ] Side-by-side comparison
- [ ] Metrics:
  - Revenue
  - Orders
  - Customers
  - Avg Order Value
  - Delivery Time
  - Debt Collection Rate
- [ ] Charts: Bar charts, Line graphs
- [ ] AI Recommendations لكل بقالة
- [ ] Export to PDF

---

### US-3.1: تعيين كاشير

**كصاحب بقالة**، أريد تعيين كاشير لبقالتي

#### Acceptance Criteria:
- [ ] إدخال:  - الاسم، الجوال
  - Store assignment
  - PIN (4 digits للـ POS)
  - Permissions (البيع، المرتجعات، etc)
- [ ] إرسال دعوة بالـ SMS + Email
- [ ] الكاشير يحمّل pos_app
- [ ] Login with PIN
- [ ] ربط الكاشير بالـ Store

---

### US-3.2: نقل موظف بين الفروع

**كصاحب بقالة**، أريد نقل موظف من فرع لآخر

#### Acceptance Criteria:
- [ ] اختيار الموظف
- [ ] From Store / To Store
- [ ] Transfer type: Permanent / Temporary
- [ ] Effective date
- [ ] Salary adjustment (اختياري)
- [ ] Approval من Managers (optional)
- [ ] تحديث الـ assignments
- [ ] Notification للموظف

---

### US-4.1: نقل مخزون بين الفروع

**كصاحب بقالة**، أريد نقل منتجات من مستودع لآخر

#### Acceptance Criteria:
- [ ] From Warehouse / To Warehouse
- [ ] اختيار المنتجات + الكميات
- [ ] Validation: الكمية متوفرة؟
- [ ] Assign Driver
- [ ] Expected delivery time
- [ ] Confirm transfer
- [ ] تحديث Inventory:
  - From: minus quantities
  - To: plus quantities
- [ ] Log movement (INTER_STORE_TRANSFER)
- [ ] GPS tracking للمندوب (optional)

---

### US-5.1: عرض العملاء المشتركين

**كصاحب بقالة**، أريد رؤية العملاء المشتركين بين بقالتيّ

#### Acceptance Criteria:
- [ ] Filter: Shared Customers
- [ ] عرض:
  - اسم العميل
  - الحي
  - Stores: [Store 1, Store 2]
  - Debts per store
  - Total orders per store
- [ ] Click → Customer Details
- [ ] عرض Multi-store accounts

---

### US-6.1: مراقبة الطلبات (من customer_app)

**كصاحب بقالة**، أريد رؤية الطلبات القادمة من التطبيق

#### Acceptance Criteria:
- [ ] عرض Orders list (all stores)
- [ ] Filter by:
  - Store
  - Status (PENDING/ACCEPTED/DELIVERED)
  - Date range
- [ ] Real-time updates (Supabase Realtime)
- [ ] Click → Order Details
- [ ] Assign driver
- [ ] Update status

---

### US-7.1: تقرير الديون الموحد

**كصاحب بقالة**، أريد رؤية جميع الديون عبر كل البقالات

#### Acceptance Criteria:
- [ ] Total Debt (all stores)
- [ ] Breakdown per store
- [ ] Overdue categories:
  - >30 days
  - >60 days
  - >90 days
- [ ] Filters: By store, By customer, By overdue
- [ ] Actions:
  - Send Reminder (SMS/WhatsApp)
  - Request Payment
  - Waive Interest
  - Block Customer
- [ ] Export to Excel

---

### US-7.2: مراقبة الدخل Real-time

**كصاحب بقالة**، أريد رؤية الدخل لحظياً

#### Acceptance Criteria:
- [ ] Live updates (كل دقيقتين)
- [ ] Today's revenue بالثانية
- [ ] Breakdown:
  - By store
  - By payment method (Cash/Card/Credit)
  - By channel (POS/App)
- [ ] Week/Month comparisons
- [ ] Growth percentage vs last period
- [ ] Charts: Line graph للـ trends

---

### US-8.1: AI Insights (اقتراحات ذكية)

**كصاحب بقالة**، أريد اقتراحات AI لتحسين الأداء

#### Acceptance Criteria:
- [ ] AI يحلل:
  - معدل دوران المخزون
  - المنتجات الأكثر مبيعاً
  - أوقات الذروة
  - سلوك العملاء
- [ ] Recommendations:
  - "منتج X ينفد كل 3 أيام، اطلب كمية أكبر"
  - "الطلبات تزيد 30% يوم الخميس"
  - "Store 2 delivery time بطيء، hire driver"
- [ ] Actionable insights (click to act)

---

### US-9.1: ترقية الاشتراك

**كصاحب بقالة**، أريد ترقية خطتي من Basic إلى Pro

#### Acceptance Criteria:
- [ ] Current plan: Basic
- [ ] Available plans: Pro, Enterprise
- [ ] Plan comparison table
- [ ] Price difference prorated
- [ ] Payment via Stripe/Tap
- [ ] Instant upgrade بعد الدفع
- [ ] Unlock features:
  - +2 stores (Pro)
  - +7 staff
  - AI Insights
  - Transfers
- [ ] Invoice sent by email

---

## 🎯 الأولويات والمراحل

### P0 (Must Have - Sprint 1-2): 40 شاشة
```
Phase 1: Auth (5 screens)
Phase 2: Dashboard & Stores (7 screens)
Phase 3: Staff (5 screens)
Phase 4: Products (6 screens)
Phase 5: Customers (3 screens)
Phase 6: Orders (3 screens)
Phase 7: Financial (6 screens)
Phase 10: Subscription (5 screens)
```

### P1 (Should Have - Sprint 3-4): 30 شاشة
```
Phase 2: Store features (7 screens)
Phase 3: Staff advanced (3 screens)
Phase 4: Inventory (5 screens)
Phase 5: Customer analytics (3 screens)
Phase 6: Deliveries (4 screens)
Phase 7: Reports (2 screens)
Phase 8: KPI (4 screens)
Phase 9: Settings (3 screens)
```

### P2 (Nice to Have - Sprint 5+): 24 شاشة
```
Phase 2: Store branding (3 screens)
Phase 3: Payroll (3 screens)
Phase 4: Bulk operations (3 screens)
Phase 5: Behavior (2 screens)
Phase 6: Heatmaps (2 screens)
Phase 7: Advanced (5 screens)
Phase 8: AI Advanced (3 screens)
Phase 9: Integrations (4 screens)
```

---

## 📊 Status Models

```dart
// Owner Account Status
enum OwnerStatus {
  PENDING_APPROVAL,
  APPROVED,
  SUSPENDED,
  BANNED
}

// Store Status
enum StoreStatus {
  ACTIVE,
  INACTIVE,
  SUSPENDED
}

// Subscription Status
enum SubscriptionStatus {
  TRIAL,
  ACTIVE,
  EXPIRED,
  CANCELLED
}

// Staff Transfer Status
enum TransferStatus {
  PENDING,
  APPROVED,
  REJECTED,
  COMPLETED
}

// Inventory Transfer Status
enum InventoryTransferStatus {
  PENDING,
  IN_TRANSIT,
  DELIVERED,
  CANCELLED
}
```

---

## ✅ Development Checklist

### Phase 1 (Weeks 1-2):
- [ ] Auth flow (Signup → Approval → Login)
- [ ] Dashboard skeleton
- [ ] Create first store
- [ ] Basic stores list

### Phase 2 (Weeks 3-4):
- [ ] Staff management (Add cashier/driver)
- [ ] Products CRUD
- [ ] Customers list
- [ ] Orders monitoring

### Phase 3 (Weeks 5-6):
- [ ] Financial reports
- [ ] Debts management
- [ ] Store comparison
- [ ] Subscription management

### Phase 4 (Weeks 7-8):
- [ ] Inventory transfers
- [ ] Staff transfers
- [ ] KPI dashboard
- [ ] AI Insights (basic)

### Phase 5 (Weeks 9-10):
- [ ] Advanced reports
- [ ] Settings
- [ ] Integrations
- [ ] Polish & Testing

---

**📅 Last Updated**: 2026-01-15  
**✅ Status**: Ready for Development  
**🎯 Next**: ADMIN_POS_SPEC.md
