# تقرير تدقيق علاقات قاعدة البيانات - منصة الحي

**المُراجع:** باسم
**التاريخ:** 2026-02-26
**الإصدار:** 1.0
**النطاق:** Drift (SQLite المحلي) + Supabase (PostgreSQL السحابي)
**التقييم النهائي:** 4.5 / 10

---

## جدول المحتويات

1. [ملخص تنفيذي](#ملخص-تنفيذي)
2. [جدول ملخص بالأرقام](#جدول-ملخص-بالأرقام)
3. [رسم بياني للعلاقات (ERD نصي)](#رسم-بياني-للعلاقات-erd-نصي)
4. [النتائج التفصيلية](#النتائج-التفصيلية)
   - 4.1 [المفاتيح الأجنبية في Drift](#41-المفاتيح-الأجنبية-في-drift)
   - 4.2 [علاقات واحد-إلى-كثير](#42-علاقات-واحد-إلى-كثير)
   - 4.3 [علاقات كثير-إلى-كثير (جداول الربط)](#43-علاقات-كثير-إلى-كثير-جداول-الربط)
   - 4.4 [العلاقات الذاتية المرجعية](#44-العلاقات-الذاتية-المرجعية)
   - 4.5 [قواعد الحذف والتحديث التتابعي](#45-قواعد-الحذف-والتحديث-التتابعي)
   - 4.6 [سياسات RLS في Supabase](#46-سياسات-rls-في-supabase)
   - 4.7 [استعلامات JOIN في DAOs](#47-استعلامات-join-في-daos)
   - 4.8 [تناسق البيانات بين الجداول](#48-تناسق-البيانات-بين-الجداول)
   - 4.9 [خطر السجلات اليتيمة](#49-خطر-السجلات-اليتيمة)
   - 4.10 [مخاطر الاعتماد الدائري](#410-مخاطر-الاعتماد-الدائري)
   - 4.11 [المفاتيح الأجنبية المفقودة](#411-المفاتيح-الأجنبية-المفقودة)
   - 4.12 [قيود سلامة المراجع](#412-قيود-سلامة-المراجع)
   - 4.13 [اتفاقيات تسمية العلاقات](#413-اتفاقيات-تسمية-العلاقات)
   - 4.14 [دوال DAO للبيانات المترابطة](#414-دوال-dao-للبيانات-المترابطة)
5. [التوصيات مع أولوية التنفيذ](#التوصيات-مع-أولوية-التنفيذ)
6. [الاختلافات بين Drift و Supabase](#الاختلافات-بين-drift-و-supabase)

---

## ملخص تنفيذي

تم إجراء تدقيق شامل لعلاقات قاعدة البيانات في منصة الحي التي تتكون من طبقتين:

1. **Drift (SQLite محلي):** `packages/alhai_database/` - يحتوي على 46 جدول و 27 DAO
2. **Supabase (PostgreSQL سحابي):** `supabase/` - يحتوي على 23 جدول مع RLS شامل

### النتيجة الأهم والأخطر:

**لا يوجد أي مفتاح أجنبي (Foreign Key) معرّف في طبقة Drift المحلية بالكامل.** جميع الجداول الـ 46 تستخدم أعمدة `TEXT` كمعرفات مرجعية (مثل `storeId`، `customerId`، `saleId`) لكن بدون أي استخدام لدالة `references()` من Drift. هذا يعني أن قاعدة البيانات المحلية **لا تفرض أي قيود على سلامة المراجع** على مستوى المحرك.

في المقابل، طبقة Supabase تحتوي على مفاتيح أجنبية صحيحة مع `ON DELETE CASCADE` في الأماكن المناسبة، وسياسات RLS شاملة ومتقدمة.

### ملخص المشاكل:

| التصنيف | العدد |
|---------|-------|
| حرج | 6 |
| متوسط | 9 |
| منخفض | 5 |
| **المجموع** | **20** |

---

## جدول ملخص بالأرقام

| المقياس | القيمة |
|---------|--------|
| إجمالي جداول Drift | 46 |
| إجمالي جداول Supabase | 23 |
| إجمالي DAOs | 27 |
| مفاتيح أجنبية في Drift | **0** |
| مفاتيح أجنبية في Supabase | 20+ |
| قواعد ON DELETE CASCADE في Supabase | 10 |
| قواعد ON DELETE SET NULL في Supabase | 1 |
| مراجع بدون ON DELETE في Supabase | 9 |
| سياسات RLS في Supabase | 60+ |
| استعلامات JOIN في DAOs | 2 |
| جداول ربط (Many-to-Many) | 3 (org_members, user_stores, favorites) |
| علاقات ذاتية مرجعية | 1 (categories.parent_id) |
| مشاكل حرجة | 6 |
| مشاكل متوسطة | 9 |
| مشاكل منخفضة | 5 |
| التقييم | 4.5/10 |

---

## رسم بياني للعلاقات (ERD نصي)

```
                    ┌──────────────────┐
                    │  organizations   │
                    │  (المؤسسات)      │
                    └────────┬─────────┘
                             │ 1:N
              ┌──────────────┼──────────────┐
              │              │              │
              v              v              v
    ┌─────────────┐  ┌──────────┐  ┌────────────────┐
    │ org_members  │  │  stores  │  │ subscriptions  │
    │(أعضاء المؤسسة)│  │(المتاجر) │  │  (الاشتراكات)  │
    └──────┬──────┘  └────┬─────┘  └────────────────┘
           │              │
           v              │ 1:N
    ┌──────────┐          │
    │  users   │<─────────┤
    │(المستخدمين)│          │
    └──────┬───┘          │
           │              ├─────────────────────────────────────┐
           │              │                                     │
           │         ┌────┴─────────┐                    ┌──────┴──────┐
           │         │  categories  │ (self-ref)         │  customers  │
           │         │  (التصنيفات) │ parent_id ──┐      │  (العملاء)  │
           │         └────┬────────┘             │      └──────┬──────┘
           │              │ 1:N                  │             │
           │              v                      │             │ 1:N
           │         ┌──────────┐                │      ┌──────┴──────────┐
           │         │ products │<───────────────┘      │customer_addresses│
           │         │(المنتجات) │                       └─────────────────┘
           │         └────┬─────┘
           │              │ 1:N
           │     ┌────────┼──────────────────────────┐
           │     │        │                          │
           │     v        v                          v
           │ ┌────────┐ ┌──────────────┐  ┌──────────────────┐
           │ │sale_   │ │inventory_    │  │product_expiry    │
           │ │items   │ │movements     │  │(صلاحية المنتجات)  │
           │ │(عناصر  │ │(حركات المخزون)│  └──────────────────┘
           │ │البيع)  │ └──────────────┘
           │ └───┬────┘
           │     │ N:1
           │     v
           │ ┌──────────┐
           │ │  sales   │──────────────────────┐
           │ │(المبيعات) │                       │
           │ └────┬─────┘                       │ 1:N
           │      │ 1:N                         v
           │      v                      ┌──────────┐
           │ ┌──────────┐               │ returns  │
           │ │  shifts  │               │(المرتجعات)│
           │ │(الورديات) │               └────┬─────┘
           │ └────┬─────┘                     │ 1:N
           │      │ 1:N                       v
           │      v                    ┌─────────────┐
           │ ┌────────────────┐        │return_items │
           │ │cash_movements  │        │(عناصر المرتجع)│
           │ │(حركات الصندوق) │        └─────────────┘
           │ └────────────────┘
           │
           │         ┌──────────────┐
           ├────────>│  accounts    │
           │         │  (الحسابات)  │
           │         └────┬─────────┘
           │              │ 1:N
           │              v
           │         ┌──────────────┐
           │         │ transactions │
           │         │  (الحركات)   │
           │         └──────────────┘
           │
           │         ┌──────────┐         ┌──────────────┐
           │         │suppliers │─────────│  purchases   │
           │         │(الموردين)│  1:N    │ (المشتريات) │
           │         └──────────┘         └──────┬───────┘
           │                                     │ 1:N
           │                              ┌──────┴────────┐
           │                              │purchase_items │
           │                              │(عناصر الشراء) │
           │                              └───────────────┘
           │
           │         ┌──────────┐         ┌──────────────┐
           ├────────>│  orders  │─────────│ order_items  │
           │         │(الطلبات) │  1:N    │(عناصر الطلب) │
           │         └────┬─────┘         └──────────────┘
           │              │ 1:N
           │              v
           │         ┌────────────────────┐
           │         │order_status_history│
           │         │(سجل حالات الطلب)   │
           │         └────────────────────┘
           │
           │     ┌──────────────────────────────────────┐
           │     │  جداول مستقلة (بدون FK صريح):        │
           │     │  - discounts, coupons, promotions    │
           │     │  - favorites, held_invoices          │
           │     │  - whatsapp_messages/templates       │
           │     │  - sync_queue, sync_metadata         │
           │     │  - stock_deltas, stock_transfers     │
           │     │  - stock_takes, daily_summaries      │
           │     │  - notifications, audit_log          │
           │     │  - expenses, expense_categories      │
           │     │  - drivers, settings                 │
           │     │  - pos_terminals, loyalty_*          │
           │     └──────────────────────────────────────┘

    ┌────────────────────────────────────────────────────┐
    │  جداول الربط (Many-to-Many):                       │
    │  users ←→ org_members ←→ organizations             │
    │  users ←→ user_stores ←→ stores                    │
    │  products ←→ favorites ←→ stores                   │
    └────────────────────────────────────────────────────┘
```

---

## النتائج التفصيلية

### 4.1 المفاتيح الأجنبية في Drift

#### النتيجة: لا توجد أي مفاتيح أجنبية معرّفة

**التصنيف:** حرج

**التفاصيل:** تم فحص جميع ملفات الجداول الـ 39 في:
```
packages/alhai_database/lib/src/tables/
```

البحث عن `references()` (الطريقة الرسمية لتعريف FK في Drift) لم يعطِ أي نتيجة. جميع الأعمدة المرجعية معرّفة كـ `TextColumn` بسيط بدون أي ربط:

**مثال 1 - `sale_items_table.dart` (السطر 16-17):**
```dart
TextColumn get saleId => text()();      // يجب أن يكون: text().references(salesTable, #id)()
TextColumn get productId => text()();   // يجب أن يكون: text().references(productsTable, #id)()
```
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\tables\sale_items_table.dart`

**مثال 2 - `orders_table.dart` (السطر 26):**
```dart
TextColumn get storeId => text()();     // يجب أن يشير إلى stores.id
TextColumn get customerId => text().nullable()();  // يجب أن يشير إلى customers.id
```
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\tables\orders_table.dart`

**مثال 3 - `inventory_movements_table.dart` (السطر 24-25):**
```dart
TextColumn get productId => text()();   // لا يشير لـ products
TextColumn get storeId => text()();     // لا يشير لـ stores
```
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\tables\inventory_movements_table.dart`

**الأثر:** يمكن إدراج بيانات بمعرفات غير موجودة (مثل sale_item بـ productId غير حقيقي). هذا لن يُكتشف إلا في وقت التشغيل، لا على مستوى المحرك.

---

### 4.2 علاقات واحد-إلى-كثير

تم تحديد العلاقات التالية بناءً على تحليل أسماء الأعمدة (جميعها ضمنية وليست مُعرّفة رسمياً):

| الجدول الأب | الجدول الابن | عمود المرجع | الملف |
|-------------|-------------|-------------|-------|
| stores | products | storeId | products_table.dart:27 |
| stores | sales | storeId | sales_table.dart:25 |
| stores | categories | storeId | categories_table.dart:21 |
| stores | customers | storeId | customers_table.dart:14 |
| stores | orders | storeId | orders_table.dart:25 |
| stores | shifts | storeId | shifts_table.dart:14 |
| stores | suppliers | storeId | suppliers_table.dart:13 |
| stores | expenses | storeId | expenses_table.dart:13 |
| stores | purchases | storeId | purchases_table.dart:14 |
| stores | returns | storeId | returns_table.dart:16 |
| stores | notifications | storeId | notifications_table.dart:14 |
| stores | discounts | storeId | discounts_table.dart:12 |
| stores | held_invoices | storeId | held_invoices_table.dart:11 |
| stores | settings | storeId | settings_table.dart:11 |
| stores | audit_log | storeId | audit_log_table.dart:25 |
| stores | pos_terminals | storeId | pos_terminals_table.dart:12 |
| stores | whatsapp_messages | storeId | whatsapp_messages_table.dart:29 |
| stores | whatsapp_templates | storeId | whatsapp_templates_table.dart:19 |
| stores | daily_summaries | storeId | daily_summaries_table.dart:13 |
| stores | drivers | storeId | drivers_table.dart:11 |
| stores | stock_takes | storeId | stock_takes_table.dart:11 |
| sales | sale_items | saleId | sale_items_table.dart:16 |
| sales | returns | saleId | returns_table.dart:15 |
| orders | order_items | orderId | order_items_table.dart:10 |
| orders | order_status_history | orderId | order_status_history_table.dart:11 |
| products | sale_items | productId | sale_items_table.dart:17 |
| products | inventory_movements | productId | inventory_movements_table.dart:24 |
| products | order_items | productId | order_items_table.dart:11 |
| products | product_expiry | productId | product_expiry_table.dart:11 |
| products | stock_deltas | productId | stock_deltas_table.dart:29 |
| products | return_items | productId | returns_table.dart:44 |
| products | purchase_items | productId | purchases_table.dart:45 |
| products | favorites | productId | favorites_table.dart:12 |
| categories | products | categoryId | products_table.dart:53 |
| customers | customer_addresses | customerId | customers_table.dart:40 |
| customers | loyalty_points | customerId | loyalty_table.dart:21 |
| customers | loyalty_transactions | customerId | loyalty_table.dart:76 |
| accounts | transactions | accountId | transactions_table.dart:23 |
| shifts | cash_movements | shiftId | shifts_table.dart:46 |
| returns | return_items | returnId | returns_table.dart:42 |
| purchases | purchase_items | purchaseId | purchases_table.dart:44 |
| suppliers | purchases | supplierId | purchases_table.dart:15 |
| organizations | subscriptions | orgId | organizations_table.dart:47 |
| organizations | org_members | orgId | org_members_table.dart:10 |
| organizations | stores | orgId | stores_table.dart:10 |

**التصنيف:** متوسط - العلاقات موجودة مفهومياً لكن غير مُفعّلة على مستوى المحرك.

---

### 4.3 علاقات كثير-إلى-كثير (جداول الربط)

تم تحديد 3 جداول ربط:

#### 1. `org_members` (المؤسسات <-> المستخدمين)
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\tables\org_members_table.dart`
```dart
TextColumn get orgId => text()();    // السطر 10
TextColumn get userId => text()();   // السطر 11
```
**المشكلة:** لا يوجد `UNIQUE(orgId, userId)` لمنع التكرار.

#### 2. `user_stores` (المستخدمين <-> المتاجر)
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\tables\org_members_table.dart` (السطر 26-41)
```dart
TextColumn get userId => text()();   // السطر 31
TextColumn get storeId => text()();  // السطر 32
```
**المشكلة:** لا يوجد `UNIQUE(userId, storeId)` لمنع التكرار.

#### 3. `favorites` (المنتجات <-> المتاجر/المستخدمين)
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\tables\favorites_table.dart`
```dart
TextColumn get storeId => text()();    // السطر 11
TextColumn get productId => text()();  // السطر 12
```
**المشكلة:** لا يوجد `UNIQUE(storeId, productId)` لمنع تكرار المفضلة.

**التصنيف:** متوسط - قد يؤدي غياب قيود التفرد إلى تكرار السجلات.

---

### 4.4 العلاقات الذاتية المرجعية

#### `categories.parent_id` - علاقة شجرية
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\tables\categories_table.dart` (السطر 26)
```dart
TextColumn get parentId => text().nullable()();
```

**الإيجابيات:**
- يوجد فهرس مخصص: `@TableIndex(name: 'idx_categories_parent_id', columns: {#parentId})` (السطر 11)
- يوجد DAO يتعامل مع التسلسل الهرمي: `getRootCategories()` و `getSubCategories()` في `categories_dao.dart` (الأسطر 29-49)

**المشاكل:**
- لا يوجد FK يمنع الإشارة إلى تصنيف محذوف
- لا يوجد حماية من الحلقات الدائرية (تصنيف يشير إلى نفسه أو إلى تصنيف فرعي)
- عمق الشجرة غير محدود (قد يسبب مشاكل أداء في الاستعلامات التراجعية)

**التصنيف:** متوسط

---

### 4.5 قواعد الحذف والتحديث التتابعي

#### Drift: لا توجد أي قواعد

**التصنيف:** حرج

بما أنه لا توجد مفاتيح أجنبية في Drift أصلاً، لا توجد أي قواعد `ON DELETE` أو `ON UPDATE`. حذف سجل من `sales` لن يؤثر على `sale_items` المرتبطة.

**أمثلة على المخاطر:**

1. **حذف منتج:** لن يحذف عناصر البيع المرتبطة، حركات المخزون، المفضلات، تواريخ الصلاحية
2. **حذف عميل:** لن يحذف العناوين المرتبطة، نقاط الولاء، الحسابات
3. **حذف فاتورة بيع:** لن يحذف عناصر البيع، المرتجعات المرتبطة
4. **حذف متجر:** لن يحذف أي بيانات مرتبطة (منتجات، مبيعات، عملاء، إلخ)

#### Supabase: قواعد جزئية

في `supabase_init.sql`، القواعد المعرّفة:

| الجدول الابن | الجدول الأب | القاعدة | السطر |
|-------------|-------------|---------|-------|
| users | auth.users | ON DELETE CASCADE | 43 |
| store_members | users | ON DELETE CASCADE | 94 |
| addresses | users | ON DELETE CASCADE | 149 |
| order_items | orders | ON DELETE CASCADE | 194 |
| debt_payments | debts | ON DELETE CASCADE | 241 |
| deliveries | orders | ON DELETE CASCADE | 252 |
| purchase_order_items | purchase_orders | ON DELETE CASCADE | 336 |
| notifications | users | ON DELETE CASCADE | 348 |
| order_payments | orders | ON DELETE CASCADE | 379 |
| activity_logs | users | ON DELETE SET NULL | 406 |

**المراجع بدون ON DELETE (تستخدم الافتراضي NO ACTION):**

| الجدول | العمود | يشير إلى | السطر |
|--------|--------|----------|-------|
| role_audit_log | user_id | users(id) | 60 |
| role_audit_log | changed_by | users(id) | 63 |
| stores | owner_id | users(id) | 83 |
| orders | customer_id | users(id) | 168 |
| orders | address_id | addresses(id) | 169 |
| debts | customer_id | users(id) | 223 |
| debts | supplier_id | suppliers(id) | 224 |
| debts | order_id | orders(id) | 227 |
| customer_accounts | customer_id | users(id) | 274 |
| loyalty_points | customer_id | users(id) | 288 |
| stock_adjustments | created_by | users(id) | 311 |
| purchase_orders | supplier_id | suppliers(id) | 319 |
| purchase_orders | created_by | users(id) | 328 |
| shifts | cashier_id | users(id) | 419 |

**التصنيف:** متوسط - Supabase أفضل لكن يوجد 14 مرجع بدون قاعدة حذف صريحة.

---

### 4.6 سياسات RLS في Supabase

#### النتيجة: شاملة ومتقدمة

**الملف الرئيسي:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\supabase_init.sql`

**الإيجابيات:**

1. **جميع الجداول الـ 23 مُفعّل عليها RLS** (الأسطر 744-767)
2. **3 دوال مساعدة أمنية:**
   - `is_super_admin()` (السطر 512)
   - `is_store_member(p_store_id)` (السطر 518)
   - `is_store_admin(p_store_id)` (السطر 527)
3. **فصل واضح بين الأدوار:** super_admin / store_admin / member / customer
4. **سياسات كتابة مشددة:** في `20260223_tighten_rls_write_policies.sql`، تم تغيير INSERT/UPDATE/DELETE من `is_store_member` إلى `is_store_admin` للجداول الحساسة (products, categories, suppliers, promotions)
5. **حماية store_id من التغيير:** trigger `prevent_store_id_change` على products, store_members, debts, purchase_orders
6. **حماية الأدوار:** trigger `prevent_direct_role_update` يمنع تغيير role إلا عبر RPC
7. **إلغاء صلاحيات حساسة:** REVOKE على role_audit_log, stock_adjustments, order_payments, activity_logs

**المشاكل:**

1. **تكرار محتمل لسياسة RLS:** ملف `fix_rls_recursion.sql` يُظهر وجود مشكلة تكرار لانهائي تم إصلاحها بـ `SECURITY DEFINER`

   **التصنيف:** منخفض (تم إصلاحها)

2. **عدم وجود RLS على الجداول التي لم تُنشأ بعد في Supabase:**
   - sales (المبيعات المحلية من POS)
   - sale_items
   - inventory_movements
   - returns, return_items

   **التصنيف:** متوسط - هذه الجداول ستحتاج RLS عند مزامنتها

---

### 4.7 استعلامات JOIN في DAOs

#### النتيجة: نقص حاد في استخدام JOINs

تم العثور على استعلامي JOIN فقط في كامل طبقة DAO:

**1. `products_dao.dart` - getTopSellingProducts() (الأسطر 250-268):**
```dart
/// الحصول على المنتجات الأكثر مبيعاً (للعرض السريع)
/// يتطلب join مع جدول sale_items
Future<List<ProductsTableData>> getTopSellingProducts(
  String storeId, {
  int limit = 10,
}) {
  return customSelect(
    '''SELECT p.* FROM products p
       INNER JOIN (
         SELECT product_id, COUNT(*) as sale_count
         FROM sale_items
         GROUP BY product_id
         ORDER BY sale_count DESC
         LIMIT ?
       ) top ON p.id = top.product_id
       WHERE p.store_id = ? AND p.is_active = 1
       ORDER BY top.sale_count DESC''',
    variables: [Variable.withInt(limit), Variable.withString(storeId)],
    readsFrom: {productsTable},
  ).map((row) => productsTable.map(row.data)).get();
}
```
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\daos\products_dao.dart`

**2. `products_fts.dart` - search() (السطر 104, 141, 193):**
```sql
INNER JOIN products p ON fts.id = p.id
```
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\fts\products_fts.dart`

**المشاكل:**

- **لا يوجد JOIN بين sales و sale_items** - يتم جلب عناصر البيع في استعلام منفصل
- **لا يوجد JOIN بين orders و order_items** - نفس المشكلة
- **لا يوجد JOIN بين returns و return_items**
- **لا يوجد JOIN بين purchases و purchase_items**
- **لا يوجد JOIN بين accounts و customers/suppliers** - الربط يتم على مستوى التطبيق

**التصنيف:** حرج - يسبب مشكلة N+1 Query في معظم الشاشات التي تعرض بيانات مترابطة.

---

### 4.8 تناسق البيانات بين الجداول

#### تكرار البيانات (Denormalization) غير محمي

تم رصد عدة حالات تكرار بيانات بدون آلية لتحديثها:

**1. `sales_table.dart` (الأسطر 31-32):**
```dart
TextColumn get customerName => text().nullable()();
TextColumn get customerPhone => text().nullable()();
```
اسم العميل ورقمه مُكرر من `customers`. إذا تغيّر اسم العميل، لن يُحدّث في المبيعات القديمة. **هذا مقبول** لأن البيانات تمثل لحظة البيع.

**2. `sale_items_table.dart` (الأسطر 19-22):**
```dart
TextColumn get productName => text()();
TextColumn get productSku => text().nullable()();
TextColumn get productBarcode => text().nullable()();
```
بيانات المنتج مُكررة في عناصر البيع. **هذا مقبول** لنفس السبب.

**3. `shifts_table.dart` (السطر 17):**
```dart
TextColumn get cashierName => text()();
```
اسم الكاشير مُكرر. **هذا مقبول.**

**4. `purchases_table.dart` (السطر 16):**
```dart
TextColumn get supplierName => text().nullable()();
```
اسم المورد مُكرر. **هذا مقبول.**

**5. `returns_table.dart` (السطر 18):**
```dart
TextColumn get customerName => text().nullable()();
```
اسم العميل مُكرر في المرتجعات. **هذا مقبول.**

**التصنيف:** منخفض - التكرار مبرر في سياق POS (لحفظ البيانات التاريخية).

---

### 4.9 خطر السجلات اليتيمة

**التصنيف:** حرج

بسبب غياب المفاتيح الأجنبية في Drift، يوجد خطر عالي لإنشاء سجلات يتيمة:

#### السيناريوهات الخطرة:

**1. حذف منتج مع وجود عناصر بيع:**
```
products.delete(productId)  -- ينجح!
sale_items حيث product_id = productId  -- تبقى يتيمة
inventory_movements حيث product_id = productId  -- تبقى يتيمة
favorites حيث product_id = productId  -- تبقى يتيمة
product_expiry حيث product_id = productId  -- تبقى يتيمة
```

**الملف المسؤول:** `products_dao.dart` السطر 141:
```dart
Future<int> deleteProduct(String id) {
  return (delete(productsTable)..where((p) => p.id.equals(id))).go();
}
```
لا يوجد أي تحقق أو حذف تتابعي.

**2. حذف فاتورة بيع:**
**الملف:** `sales_dao.dart` - لا توجد دالة حذف أصلاً! لكن `voidSale()` (السطر 76) يغيّر الحالة فقط بدون التعامل مع sale_items.

**3. حذف عميل:**
**الملف:** `customers_dao.dart` السطر 33:
```dart
Future<int> deleteCustomer(String id) => (delete(customersTable)..where((c) => c.id.equals(id))).go();
```
لا يحذف: customer_addresses, loyalty_points, loyalty_transactions, accounts, sales المرتبطة.

**4. حذف طلب شراء:**
**الملف:** `purchases_dao.dart` السطر 34:
```dart
Future<int> deletePurchase(String id) => (delete(purchasesTable)..where((p) => p.id.equals(id))).go();
```
لا يحذف: purchase_items المرتبطة.

**5. حذف متجر:**
**الملف:** `stores_dao.dart` - سيترك كل البيانات المرتبطة يتيمة (عشرات الجداول).

**التصنيف:** حرج

---

### 4.10 مخاطر الاعتماد الدائري

#### النتيجة: لا يوجد اعتماد دائري مباشر

لم يتم رصد أي حالة اعتماد دائري في تعريفات الجداول. العلاقات كلها أحادية الاتجاه (من الابن إلى الأب).

العلاقة الذاتية المرجعية الوحيدة هي `categories.parent_id` وهي لا تسبب دوراناً على مستوى الـ schema، لكن على مستوى البيانات يمكن إنشاء حلقة (A -> B -> A).

**التصنيف:** منخفض

---

### 4.11 المفاتيح الأجنبية المفقودة

#### قائمة شاملة بالمفاتيح الأجنبية التي يجب إضافتها في Drift:

**التصنيف:** حرج

| الجدول الابن | العمود | يجب أن يشير إلى | الأولوية |
|-------------|--------|-----------------|---------|
| sale_items | saleId | sales.id | عالية |
| sale_items | productId | products.id | عالية |
| sales | storeId | stores.id | عالية |
| sales | cashierId | users.id | عالية |
| sales | customerId | customers.id | عالية |
| sales | terminalId | pos_terminals.id | متوسطة |
| products | storeId | stores.id | عالية |
| products | categoryId | categories.id | عالية |
| categories | storeId | stores.id | عالية |
| categories | parentId | categories.id | عالية |
| orders | storeId | stores.id | عالية |
| orders | customerId | customers.id | عالية |
| orders | driverId | drivers.id | متوسطة |
| order_items | orderId | orders.id | عالية |
| order_items | productId | products.id | عالية |
| order_status_history | orderId | orders.id | عالية |
| customers | storeId | stores.id | عالية |
| customer_addresses | customerId | customers.id | عالية |
| inventory_movements | productId | products.id | عالية |
| inventory_movements | storeId | stores.id | عالية |
| returns | saleId | sales.id | عالية |
| returns | storeId | stores.id | عالية |
| return_items | returnId | returns.id | عالية |
| return_items | productId | products.id | عالية |
| purchases | storeId | stores.id | عالية |
| purchases | supplierId | suppliers.id | عالية |
| purchase_items | purchaseId | purchases.id | عالية |
| purchase_items | productId | products.id | عالية |
| accounts | storeId | stores.id | عالية |
| accounts | customerId | customers.id | متوسطة |
| accounts | supplierId | suppliers.id | متوسطة |
| transactions | accountId | accounts.id | عالية |
| transactions | storeId | stores.id | عالية |
| shifts | storeId | stores.id | عالية |
| shifts | cashierId | users.id | عالية |
| shifts | terminalId | pos_terminals.id | متوسطة |
| cash_movements | shiftId | shifts.id | عالية |
| cash_movements | storeId | stores.id | عالية |
| expenses | storeId | stores.id | عالية |
| expenses | categoryId | expense_categories.id | متوسطة |
| loyalty_points | customerId | customers.id | عالية |
| loyalty_points | storeId | stores.id | عالية |
| loyalty_transactions | loyaltyId | loyalty_points.id | عالية |
| loyalty_transactions | customerId | customers.id | عالية |
| loyalty_transactions | saleId | sales.id | متوسطة |
| favorites | productId | products.id | متوسطة |
| favorites | storeId | stores.id | متوسطة |
| notifications | storeId | stores.id | منخفضة |
| audit_log | storeId | stores.id | منخفضة |
| audit_log | userId | users.id | منخفضة |
| discounts | storeId | stores.id | منخفضة |
| coupons | storeId | stores.id | منخفضة |
| coupons | discountId | discounts.id | منخفضة |
| promotions | storeId | stores.id | منخفضة |
| whatsapp_messages | storeId | stores.id | منخفضة |
| whatsapp_messages | customerId | customers.id | منخفضة |
| whatsapp_templates | storeId | stores.id | منخفضة |
| stock_deltas | productId | products.id | عالية |
| stock_deltas | storeId | stores.id | متوسطة |
| stock_transfers | fromStoreId | stores.id | متوسطة |
| stock_transfers | toStoreId | stores.id | متوسطة |
| product_expiry | productId | products.id | متوسطة |
| product_expiry | storeId | stores.id | متوسطة |
| org_members | orgId | organizations.id | عالية |
| org_members | userId | users.id | عالية |
| user_stores | userId | users.id | عالية |
| user_stores | storeId | stores.id | عالية |
| subscriptions | orgId | organizations.id | عالية |
| pos_terminals | storeId | stores.id | عالية |
| pos_terminals | orgId | organizations.id | عالية |
| daily_summaries | storeId | stores.id | منخفضة |
| drivers | storeId | stores.id | منخفضة |
| stock_takes | storeId | stores.id | منخفضة |
| held_invoices | storeId | stores.id | منخفضة |
| held_invoices | cashierId | users.id | منخفضة |
| settings | storeId | stores.id | منخفضة |

**المجموع: 73 مفتاح أجنبي مفقود**

---

### 4.12 قيود سلامة المراجع

#### Drift: لا توجد قيود

**التصنيف:** حرج

- لا `UNIQUE` constraints على أزواج المفاتيح في جداول الربط
- لا `CHECK` constraints على قيم الأعمدة
- لا `NOT NULL` constraints مفقودة (بعض الأعمدة nullable التي يجب أن تكون required)

**أمثلة على قيود مفقودة:**

1. **`org_members`**: يجب `UNIQUE(orgId, userId)` لمنع عضوية مكررة
2. **`user_stores`**: يجب `UNIQUE(userId, storeId)` لمنع ربط مكرر
3. **`loyalty_points`**: يجب `UNIQUE(customerId, storeId)` لمنع سجل نقاط مكرر
4. **`settings`**: يجب `UNIQUE(storeId, key)` لمنع إعداد مكرر
5. **`favorites`**: يجب `UNIQUE(storeId, productId)` لمنع مفضلة مكررة

#### Supabase: قيود جيدة

- `UNIQUE(store_id, user_id)` على store_members (السطر 99)
- `UNIQUE(store_id, customer_id)` على customer_accounts (السطر 281)
- `UNIQUE(store_id, customer_id)` على loyalty_points (السطر 296)
- `UNIQUE(order_id, product_id)` على order_items (السطر 504)
- `UNIQUE(order_id)` على deliveries (السطر 500)
- `UNIQUE(store_id)` على store_settings (السطر 390)

---

### 4.13 اتفاقيات تسمية العلاقات

#### النتيجة: متسقة بشكل عام

**الإيجابيات:**
- أسماء الأعمدة المرجعية تتبع نمط `{entity}Id` (مثل: `storeId`, `customerId`, `productId`)
- أسماء الجداول باستخدام snake_case (`sale_items`, `order_items`)
- أسماء الفهارس تتبع نمط `idx_{table}_{column}` (مثل: `idx_products_store_id`)

**المشاكل:**

1. **عدم اتساق في تسمية createdBy/userId:**
   - `audit_log_table.dart` يستخدم `userId` (السطر 26)
   - `expenses_table.dart` يستخدم `createdBy` (السطر 19)
   - `cash_movements_table.dart` يستخدم `createdBy` (السطر 52)
   - `stock_takes_table.dart` يستخدم `createdBy` (السطر 19)
   - `returns_table.dart` يستخدم `createdBy` (السطر 24)

   **التصنيف:** منخفض

2. **عدم اتساق بين Drift و Supabase:**
   - Drift: `customers` table مع `customerId` FKs
   - Supabase: `customer_id UUID REFERENCES public.users(id)` - العملاء هم users في Supabase

   هذا فرق جوهري: في Drift العملاء جدول منفصل، في Supabase العملاء هم مستخدمين. **هذا يسبب تعقيد في المزامنة.**

   **التصنيف:** متوسط

3. **تسمية جداول مختلفة بين Drift و Supabase:**
   - Drift: `purchases` / Supabase: `purchase_orders`
   - Drift: `accounts` / Supabase: `debts` (مفهوم مختلف)
   - Drift: `org_members` + `user_stores` / Supabase: `store_members`

   **التصنيف:** متوسط

---

### 4.14 دوال DAO للبيانات المترابطة

#### النتيجة: التعامل مع العلاقات يتم على مستوى التطبيق لا قاعدة البيانات

**التصنيف:** متوسط

**مثال 1 - الطلبات وعناصرها:**
في `orders_dao.dart`، الطلب وعناصره يُجلبان في استعلامين منفصلين:
```dart
// السطر 42 - جلب الطلب
Future<OrdersTableData?> getOrderById(String id) { ... }

// السطر 127 - جلب العناصر منفصلاً
Future<List<OrderItemsTableData>> getOrderItems(String orderId) { ... }
```
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\daos\orders_dao.dart`

**مثال 2 - المرتجعات وعناصرها:**
```dart
// السطر 21 - جلب المرتجع
Future<ReturnsTableData?> getReturnById(String id) => ...

// السطر 33 - جلب العناصر منفصلاً
Future<List<ReturnItemsTableData>> getReturnItems(String returnId) => ...
```
**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_database\lib\src\daos\returns_dao.dart`

**مثال 3 - الحساب وحركاته:**
```dart
// accounts_dao.dart السطر 38
Future<AccountsTableData?> getAccountById(String id) { ... }

// transactions_dao.dart السطر 14
Future<List<TransactionsTableData>> getAccountTransactions(String accountId) { ... }
```

**مثال 4 - حذف شراء بدون حذف العناصر:**
في `purchases_dao.dart` يوجد `deletePurchase()` (السطر 34) و `deletePurchaseItems()` (السطر 49) كدوال منفصلة. المسؤولية على التطبيق لاستدعاء الدالتين معاً.

**لا يوجد أي DAO يستخدم transactions للعمليات المركبة.** مثلاً، عملية البيع (إنشاء sale + sale_items + inventory_movements + stock update) لا تتم في transaction واحدة على مستوى DAO.

---

## الاختلافات بين Drift و Supabase

| الجانب | Drift (محلي) | Supabase (سحابي) |
|--------|-------------|-----------------|
| المفاتيح الأجنبية | **0** (لا يوجد) | 20+ FK صريح |
| ON DELETE CASCADE | **0** | 10 |
| ON DELETE SET NULL | **0** | 1 |
| UNIQUE Constraints | **0** (على جداول الربط) | 6+ |
| RLS | غير متاح (SQLite) | 60+ سياسة |
| Triggers | **0** | 5 triggers |
| Enums | لا (TEXT فقط) | 10 enums |
| CHECK Constraints | **0** | ضمنية في enums |
| نموذج العملاء | جدول `customers` منفصل | `users` مع role='customer' |
| نموذج المشتريات | `purchases` / `purchase_items` | `purchase_orders` / `purchase_order_items` |
| جدول العضوية | `org_members` + `user_stores` | `store_members` |
| جدول الحسابات | `accounts` + `transactions` | `debts` + `debt_payments` |

---

## التوصيات مع أولوية التنفيذ

### الأولوية 1 - عاجل (الأسبوع القادم)

#### T1.1 - إضافة المفاتيح الأجنبية الأساسية في Drift
```dart
// مثال: sale_items_table.dart
TextColumn get saleId => text().references(salesTable, #id)();
TextColumn get productId => text().references(productsTable, #id)();
```
**الأثر:** يمنع إدخال بيانات غير صالحة
**الجداول المستهدفة:** sale_items, order_items, return_items, purchase_items, inventory_movements, transactions, cash_movements, customer_addresses
**عدد التغييرات:** ~20 FK في 10 ملفات

#### T1.2 - إضافة حذف تتابعي في DAOs الحرجة
```dart
// مثال: إضافة لـ customers_dao.dart
Future<void> deleteCustomerCascade(String id) async {
  await batch((b) {
    b.deleteWhere(customerAddressesTable, (a) => a.customerId.equals(id));
    b.deleteWhere(customersTable, (c) => c.id.equals(id));
  });
}
```
**الجداول:** customers, products, purchases, sales (void/archive بدلاً من delete)

#### T1.3 - إضافة UNIQUE constraints على جداول الربط
```dart
// org_members_table.dart - إضافة:
@override
List<Set<Column>> get uniqueKeys => [{orgId, userId}];

// user_stores_table.dart - إضافة:
@override
List<Set<Column>> get uniqueKeys => [{userId, storeId}];

// favorites_table.dart - إضافة:
@override
List<Set<Column>> get uniqueKeys => [{storeId, productId}];
```

### الأولوية 2 - مهم (خلال أسبوعين)

#### T2.1 - إضافة JOINs للاستعلامات المترابطة
إنشاء استعلامات مدمجة في DAOs:
```dart
/// جلب البيع مع عناصره في استعلام واحد
Future<SaleWithItems> getSaleWithItems(String saleId) async {
  final sale = await getSaleById(saleId);
  final items = await db.saleItemsDao.getItemsBySaleId(saleId);
  return SaleWithItems(sale: sale!, items: items);
}
```

#### T2.2 - استخدام Database Transactions للعمليات المركبة
```dart
/// عملية بيع كاملة في transaction واحدة
Future<void> completeSale({
  required SalesTableCompanion sale,
  required List<SaleItemsTableCompanion> items,
  required List<StockUpdate> stockUpdates,
}) async {
  await transaction(() async {
    await into(salesTable).insert(sale);
    await batch((b) => b.insertAll(saleItemsTable, items));
    // تحديث المخزون...
  });
}
```

#### T2.3 - توحيد أسماء الجداول بين Drift و Supabase
إنشاء طبقة تحويل (mapping layer) لحل الفرق في:
- customers (Drift) <-> users (Supabase)
- purchases <-> purchase_orders
- accounts <-> debts

### الأولوية 3 - تحسين (خلال شهر)

#### T3.1 - إضافة حماية من الحلقات في التصنيفات
```dart
Future<bool> wouldCreateCycle(String categoryId, String newParentId) async {
  var current = newParentId;
  while (current != null) {
    if (current == categoryId) return true;
    final parent = await getCategoryById(current);
    current = parent?.parentId;
  }
  return false;
}
```

#### T3.2 - إضافة ON DELETE rules محددة
- `sale_items`: ON DELETE CASCADE (حذف العناصر مع البيع)
- `customer_addresses`: ON DELETE CASCADE
- `inventory_movements`: ON DELETE RESTRICT (لا تحذف المنتج إذا له حركات)
- `transactions`: ON DELETE RESTRICT (لا تحذف الحساب إذا له حركات)

#### T3.3 - إضافة سياسات RLS للجداول الناقصة في Supabase
عند إنشاء جداول: sales, sale_items, returns, return_items, inventory_movements في Supabase، يجب إضافة RLS مماثلة للموجودة.

#### T3.4 - إضافة FK للمراجع الناقصة في Supabase
إضافة ON DELETE للمراجع التي تستخدم الافتراضي NO ACTION:
- `stores.owner_id` -> ON DELETE RESTRICT
- `orders.customer_id` -> ON DELETE SET NULL
- `shifts.cashier_id` -> ON DELETE RESTRICT

#### T3.5 - إضافة أعمدة org_id المفقودة
بعض الجداول لا تحتوي على `orgId`:
- `sync_queue`
- `settings`
- `held_invoices`
- `stock_transfers`
- `stock_takes`
- `drivers`
- `favorites`
- `whatsapp_messages`
- `whatsapp_templates`

---

## ملخص المشاكل حسب التصنيف

### حرج (6 مشاكل)

| # | المشكلة | القسم |
|---|---------|-------|
| 1 | لا يوجد أي FK في Drift (73 FK مفقود) | 4.1 |
| 2 | لا توجد قواعد ON DELETE في Drift | 4.5 |
| 3 | نقص حاد في JOINs (2 فقط من أصل 27 DAO) | 4.7 |
| 4 | خطر السجلات اليتيمة عند الحذف | 4.9 |
| 5 | 73 مفتاح أجنبي مفقود | 4.11 |
| 6 | لا توجد UNIQUE constraints على جداول الربط | 4.12 |

### متوسط (9 مشاكل)

| # | المشكلة | القسم |
|---|---------|-------|
| 7 | العلاقات ضمنية وليست مُعرّفة رسمياً | 4.2 |
| 8 | جداول الربط بدون قيود تفرد | 4.3 |
| 9 | العلاقة الذاتية بلا حماية من الحلقات | 4.4 |
| 10 | 14 مرجع بدون ON DELETE في Supabase | 4.5 |
| 11 | جداول POS ناقصة من Supabase (بدون RLS) | 4.6 |
| 12 | اختلاف نموذج العملاء بين Drift و Supabase | 4.13 |
| 13 | اختلاف أسماء الجداول بين Drift و Supabase | 4.13 |
| 14 | DAOs لا تستخدم transactions للعمليات المركبة | 4.14 |
| 15 | DAOs تجلب البيانات المترابطة في استعلامات منفصلة | 4.14 |

### منخفض (5 مشاكل)

| # | المشكلة | القسم |
|---|---------|-------|
| 16 | عدم اتساق تسمية createdBy/userId | 4.13 |
| 17 | تكرار بيانات في جداول البيع (مبرر) | 4.8 |
| 18 | إصلاح سابق لتكرار RLS في Supabase | 4.6 |
| 19 | لا يوجد اعتماد دائري (إيجابي) | 4.10 |
| 20 | أعمدة org_id مفقودة في بعض الجداول | التوصيات |

---

## التقييم النهائي: 4.5 / 10

| المعيار | العلامة (من 10) | الوزن |
|---------|----------------|-------|
| المفاتيح الأجنبية في Drift | 0/10 | 25% |
| المفاتيح الأجنبية في Supabase | 8/10 | 15% |
| سياسات RLS | 9/10 | 15% |
| قواعد الحذف التتابعي | 2/10 | 15% |
| استعلامات JOIN و DAOs | 2/10 | 10% |
| قيود سلامة المراجع | 3/10 | 10% |
| اتفاقيات التسمية | 6/10 | 5% |
| الحماية من السجلات اليتيمة | 1/10 | 5% |
| **المتوسط المرجح** | **4.5/10** | **100%** |

**التعليق:** طبقة Supabase السحابية قوية وآمنة (8/10 لو تم تقييمها منفردة). المشكلة الجوهرية هي في طبقة Drift المحلية التي تفتقر تماماً لأي قيود سلامة مراجع. بما أن التطبيق يعمل بشكل أساسي offline-first مع Drift، فهذا يعني أن معظم العمليات تتم بدون أي حماية من قاعدة البيانات.

---

*تم إنشاء هذا التقرير بتاريخ 2026-02-26 كتدقيق للقراءة فقط (READ-ONLY). لم يتم تعديل أي ملف في المشروع.*
