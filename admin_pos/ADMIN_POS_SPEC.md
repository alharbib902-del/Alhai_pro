# 📐 Admin POS - Technical Specification

**Version:** 1.0.0  
**Date:** 2026-01-15  
**Status:** ✅ Final

---

## 📋 جدول المحتويات

1. [نظرة عامة تقنية](#نظرة-عامة-تقنية)
2. [Multi-Tenant Architecture](#multi-tenant-architecture)
3. [User Roles & Permissions](#user-roles--permissions)
4. [Business Logic](#business-logic)
5. [RLS Strategy](#rls-strategy)
6. [Integration مع التطبيقات الأخرى](#integration-مع-التطبيقات-الأخرى)
7. [Subscription Management](#subscription-management)
8. [Security](#security)

---

## 🏗️ نظرة عامة تقنية

### Platform:
- **Frontend**: Flutter (Mobile + Web + Desktop)
- **Backend**: Supabase (PostgreSQL + Auth + Realtime + Storage)
- **Images**: Cloudflare R2 (via alhai_core)
- **State Management**: Riverpod (DI) + ChangeNotifier ViewModels
- **Local Storage**: SharedPreferences + SecureStorage

### Architecture Pattern:
- **Clean Architecture** (كما في alhai_core)
- **Feature-first structure**
- **Repository pattern**
- **Multi-tenant isolation**

---

## 🏢 Multi-Tenant Architecture

### التصميم:

```
Platform Level (Super Admin)
    ↓
Tenant Level (Owner Account)
    ↓
Store Level (Individual Store)
    ↓
Resource Level (Products, Orders, Staff)
```

### Tenant Isolation Strategy:

#### 1. Data Isolation
```
كل Owner له:
- معرف فريد (owner_id)
- بيانات معزولة تماماً
- لا يمكن رؤية بيانات Owners آخرين
```

#### 2. RLS (Row Level Security)
```sql
-- مثال (بدون schema كامل):
Policy: "Owner can only see their own stores"
WHERE store.owner_id = auth.uid()

Policy: "Owner can only see their own staff"
WHERE staff.owner_id = auth.uid()
```

#### 3. Shared Resources
```
Resources مشتركة (لكن معزولة):
- global_customers: عملاء عالميين
  └── customer_accounts: حسابات منفصلة per store
  
- products: منتجات (per owner)
  └── inventory: مخزون (per warehouse per store)
```

---

## 👥 User Roles & Permissions

### Hierarchy:

```
1. Super Admin (نحن)
   ├── إدارة Owners (approve/suspend)
   ├── إدارة Marketers
   ├── Platform settings
   └── Billing & Subscriptions
   
2. Marketer (المسوق)
   ├── Generate referral codes
   ├── View referral stats
   └── Earn commissions
   
3. Owner (صاحب البقالة)
   ├── إدارة Stores (create/edit/delete)
   ├── إدارة Staff (managers/cashiers/drivers)
   ├── إدارة Products & Inventory
   ├── View Reports & KPI
   ├── Transfer between stores
   └── Manage subscription
   
4. Store Manager (مدير البقالة)
   ├── إدارة المخزون (لبقالته فقط)
   ├── تعديل الأسعار
   ├── View reports (لبقالته)
   └── إدارة الموظفين (محدودة)
   
5. Cashier (الكاشير)
   ├── البيع (pos_app)
   ├── المرتجعات
   └── ❌ لا يدخل admin_pos
   
6. Driver (المندوب)
   ├── View assigned deliveries
   ├── Update delivery status
   └── ❌ لا يدخل admin_pos
```

### Permission Matrix:

| Feature | Super Admin | Owner | Manager | Cashier | Driver |
|---------|-------------|-------|---------|---------|--------|
| Create Store | ❌ | ✅ | ❌ | ❌ | ❌ |
| Add Staff | ❌ | ✅ | ✅* | ❌ | ❌ |
| Edit Products | ❌ | ✅ | ✅ | ❌ | ❌ |
| View Reports | ✅ (all) | ✅ | ✅* | ❌ | ❌ |
| Transfer Inventory | ❌ | ✅ | ✅* | ❌ | ❌ |
| Manage Subscription | ❌ | ✅ | ❌ | ❌ | ❌ |
| Approve Owners | ✅ | ❌ | ❌ | ❌ | ❌ |

*محدود لبقالته فقط

---

## 💼 Business Logic

### 1. Owner Registration & Approval Flow

```
Step 1: Owner Signs Up
├── يدخل بياناته
├── يرفع صورة الهوية
├── (Optional) Referral code
└── Status: PENDING_APPROVAL

Step 2: Super Admin Reviews
├── يراجع البيانات
├── يتحقق من الهوية
├── يوافق أو يرفض
└── If approved:
    ├── Status: APPROVED
    ├── Default plan: Basic (30 days trial)
    └── Email + SMS notification

Step 3: Owner Creates First Store
├── Wizard (4 steps)
├── Warehouse created automatically
└── Redirect to Dashboard
```

---

### 2. Subscription Tiers

```
┌──────────────────────────────────────┐
│ Basic - 99 ر.س/شهر (30 days trial)   │
├──────────────────────────────────────┤
│ Max Stores: 1                        │
│ Max Staff: 3                         │
│ Max Products: 1000                   │
│ Reports: Basic                       │
│ AI Insights: ❌                      │
│ Transfers: ❌                        │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ Pro - 249 ر.س/شهر                    │
├──────────────────────────────────────┤
│ Max Stores: 3                        │
│ Max Staff: 10                        │
│ Max Products: 5000                   │
│ Reports: Advanced                    │
│ AI Insights: ✅                      │
│ Transfers: ✅                        │
└──────────────────────────────────────┘

┌──────────────────────────────────────┐
│ Enterprise - Custom                  │
├──────────────────────────────────────┤
│ Max Stores: Unlimited                │
│ Max Staff: Unlimited                 │
│ Max Products: Unlimited              │
│ Reports: Custom                      │
│ AI Insights: ✅ Advanced             │
│ Transfers: ✅                        │
│ API Access: ✅                       │
│ Dedicated Support: ✅                │
└──────────────────────────────────────┘
```

#### Enforcement Logic:

```dart
// Before creating Store #2
final owner = await getOwner();
final plan = owner.subscriptionPlan;
final storeCount = await getStoreCount(owner.id);

if (storeCount >= plan.maxStores) {
  throw SubscriptionLimitException(
    'خطتك ${plan.name} تسمح بـ ${plan.maxStores} بقالة فقط. ترقية؟'
  );
}

// Before adding Staff #4 (on Basic plan)
final staffCount = await getStaffCount(owner.id);
if (staffCount >= plan.maxStaff) {
  throw SubscriptionLimitException(
    'خطتك تسمح بـ ${plan.maxStaff} موظفين فقط. ترقية؟'
  );
}
```

---

### 3. Shared Customers Logic

```
Scenario: عميل واحد، بقالتين

global_customers:
├── id: customer-uuid-123
├── name: "فهد السعيد"
├── phone: "0501234567"
└── address: "حي النخيل"

customer_accounts:
├── Account 1:
│   ├── customer_id: customer-uuid-123
│   ├── store_id: store-1 (بقالة الحي)
│   ├── balance: -150 ر.س (دين)
│   └── credit_limit: 500 ر.س
│
└── Account 2:
    ├── customer_id: customer-uuid-123
    ├── store_id: store-2 (بقالة السوق)
    ├── balance: -50 ر.س (دين)
    └── credit_limit: 300 ر.س

Business Rules:
✅ نفس العميل، حسابات منفصلة
✅ كل بقالة لها رصيد منفصل
✅ Credit limit منفصل
✅ Owner يرى الاثنين في Customer Details
```

---

### 4. Inventory Transfer Logic

```
Transfer بين مستودعات نفس Owner:

Validation:
1. Check ownership:
   if (warehouse1.ownerId !== warehouse2.ownerId) {
     throw "لا يمكن النقل بين مالكين مختلفين";
   }

2. Check quantity:
   if (product.availableQty < transferQty) {
     throw "الكمية غير متوفرة";
   }

3. Check subscription:
   if (!owner.plan.allowsTransfers) {
     throw "خطتك لا تسمح بالنقل. ترقية للـ Pro؟";
   }

Execution:
1. Create transfer record (status: PENDING)
2. If approval required:
   - Manager Store 1: approve
   - Manager Store 2: approve
3. Status: IN_TRANSIT (assign driver)
4. Update inventory:
   - From: minus qty
   - To: plus qty
5. Status: DELIVERED
6. Log: INTER_STORE_TRANSFER movement
```

---

### 5. Staff Transfer Logic

```
Transfer موظف من Store 1 → Store 2:

Types:
1. Permanent (نقل دائم):
   - تحديث store_id
   - Salary adjustment (optional)
   - Approval من Managers
   - Effective date

2. Temporary (إعارة):
   - Duration: start_date → end_date
   - Daily allowance
   - Return to original store بعد الفترة

3. Shared (Multi-store):
   - Assign % time per store
   - Salary split بين Stores
   - Example: Regional Manager (60% Store1, 40% Store2)
```

---

## 🔒 RLS Strategy

### Principles:

1. **Owner Isolation**
   ```
   Owner A لا يرى بيانات Owner B أبداً
   ```

2. **Store Scope**
   ```
   Manager يرى فقط بقالته
   Cashier يرى فقط بقالته
   ```

3. **Global Visibility**
   ```
   Super Admin يرى الكل
   Owner يرى كل بقالاته
   ```

### Policy Examples (بدون SQL):

```
Table: stores
Policy: owner_access
- Owner sees only their stores
- Filter: owner_id = current_user_id

Table: staff
Policy: owner_and_manager_access
- Owner sees all staff
- Manager sees staff in their store only

Table: products
Policy: owner_access
- Owner sees all products across stores
- Filter: owner_id = current_user_id

Table: customer_accounts
Policy: store_isolation
- Each store sees only its customer accounts
- Shared customers visible to both stores (different accounts)

Table: orders
Policy: store_access
- Store sees only its orders
- Owner sees all orders across stores
```

---

## 🔗 Integration مع التطبيقات الأخرى

### 1. Integration مع customer_app

```
customer_app → admin_pos:

Orders Flow:
1. Customer places order (customer_app)
2. Order synced to Supabase
3. admin_pos يراقب Orders (real-time)
4. Owner/Manager assigns driver
5. Order status updates → customer_app يتلقى

Shared Data:
✅ Customers (global_customers)
✅ Stores
✅ Products
✅ Orders
```

---

### 2. Integration مع pos_app

```
admin_pos → pos_app:

Setup Flow:
1. Owner creates Store (admin_pos)
2. Owner adds Cashier (admin_pos)
3. Cashier receives SMS + Email
4. Cashier downloads pos_app
5. Login with PIN
6. pos_app → connected to Store

Data Sync:
admin_pos → Supabase ← pos_app

✅ Products (admin_pos creates → pos_app sells)
✅ Inventory (pos_app deducts → admin_pos monitors)
✅ Sales (pos_app records → admin_pos reports)
✅ Customers (pos_app creates → admin_pos manages)
```

---

### 3. Integration مع alhai_core

```
admin_pos uses from alhai_core:

Models:
✅ Product, Category
✅ Order, OrderItem
✅ Store
✅ CustomerAccount
✅ LoyaltyPoints

Repositories:
✅ ProductRepository
✅ OrderRepository
✅ StoreRepository (إضافة جديدة)

Services:
✅ ImageService (R2 upload)
✅ SyncService
```

---

### 4. Integration مع alhai_design_system

```
admin_pos uses:

Components:
✅ AlhaiButton, AlhaiTextField
✅ AlhaiCard, AlhaiAppBar
✅ ProductImage (R2 images)
✅ AlhaiDialog, AlhaiBottomSheet

Theme:
✅ AlhaiTheme.light()
✅ AlhaiTheme.dark()
✅ AlhaiColors, AlhaiSpacing
✅ RTL support
```

---

## 💳 Subscription Management

### Billing Cycle:

```
1. Trial (30 days):
   - Free على Basic plan
   - Full features
   - 5 days قبل الانتهاء: Email reminder
   
2. Active:
   - Auto-renew شهرياً
   - Charge via Stripe/Tap
   - Invoice sent by email
   
3. Expired:
   - Grace period: 3 days
   - Features limited (read-only)
   - Email + SMS notifications
   
4. Cancelled:
   - Data retained for 30 days
   - Export data option
   - Reactivate option
```

### Upgrade/Downgrade:

```dart
Upgrade (Basic → Pro):
1. Calculate prorated amount
2. Charge difference
3. Instant upgrade
4. Unlock features:
   - +2 stores
   - AI Insights
   - Transfers

Downgrade (Pro → Basic):
1. Check current usage:
   - If 3 stores → "قلل عدد البقالات لـ 1 أولاً"
   - If using transfers → "أنهِ النقلات الجارية"
2. Schedule downgrade for next billing cycle
3. Features locked gradually
```

---

## 🔐 Security

### Authentication:

```
Owner Login:
✅ Phone + OTP (Supabase Auth)
✅ Or Email + Password
✅ 2FA (optional - P2)
✅ Session management (JWT)

Staff Login:
✅ Phone + PIN (للـ pos_app)
✅ Session tied to Store
```

### Authorization:

```
Permission Checks:
1. Route level:
   - Dashboard → Owner only
   - Reports → Owner + Manager
   - Settings → Owner only

2. Action level:
   - Delete Store → Owner only
   - Edit Product → Owner + Manager
   - Transfer Inventory → Pro+ plan only

3. Data level (RLS):
   - Owner sees only their data
   - Manager sees only their store
```

### Data Privacy:

```
✅ Owner data encrypted at rest
✅ RLS enforced on all tables
✅ No cross-tenant data leakage
✅ Audit log for sensitive operations
✅ GDPR compliant (data export/delete)
```

---

## 📊 Performance Considerations

### Caching Strategy:

```
Local Cache (SharedPreferences):
- Owner profile
- Subscription plan
- Stores list
- Settings

Image Cache (cached_network_image):
- Product images (من R2)
- Store logos
- Staff photos
```

### Real-time Updates:

```
Supabase Realtime channels:

1. orders:store_id=:id
   - New orders from customer_app
   - Status updates
   
2. inventory:store_id=:id
   - Stock level changes
   - Low stock alerts
   
3. sales:store_id=:id
   - New sales from pos_app
   - Revenue updates (live)
```

### Optimizations:

```
✅ Pagination (20 items per page)
✅ Lazy loading للـ images
✅ Debounce على Search (500ms)
✅ Batch operations (bulk updates)
✅ Background sync (non-blocking)
```

---

## 🎯 Platform Capabilities

### Supported Platforms:

```
✅ Android (Mobile)
✅ iOS (Mobile)
✅ Web (Desktop Browser - Chrome/Safari/Edge)
✅ Windows (Desktop)
✅ macOS (Desktop)
❌ Linux (مستقبلاً)
```

### Responsive Design:

```
Mobile (< 600px):
- Single column layout
- Bottom navigation
- Drawer menu

Tablet (600-1200px):
- 2 column layout
- Side navigation
- Dashboard cards

Desktop (> 1200px):
- Multi-column layout
- Persistent sidebar
- Advanced charts
```

---

## 📝 Error Handling

### Error Types:

```dart
1. SubscriptionLimitException
   - "خطتك لا تسمح بـ..."
   - Action: [Upgrade Plan]

2. PermissionDeniedException
   - "ليس لديك صلاحية لـ..."
   - Action: [Contact Owner]

3. InventoryTransferException
   - "الكمية غير متوفرة"
   - Action: [Adjust Quantity]

4. NetworkException
   - "تحقق من الاتصال"
   - Action: [Retry]

5. ValidationException
   - "البيانات غير صحيحة"
   - Action: [Fix Input]
```

---

## 🔄 Future Enhancements

### Roadmap (مستقبلي):

```
Phase 6 (Later):
✅ WhatsApp Business API integration
✅ Advanced AI (demand forecasting)
✅ Mobile app for Drivers
✅ Voice ordering (Alexa/Google)
✅ White Label (Enterprise)
✅ Multi-currency support
✅ Dark stores (fulfillment centers)
```

---

**📅 Last Updated**: 2026-01-15  
**✅ Status**: Ready for Development  
**🎯 Next**: ADMIN_POS_VISION.md
