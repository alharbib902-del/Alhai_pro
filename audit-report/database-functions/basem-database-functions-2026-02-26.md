# تدقيق دوال قاعدة البيانات - منصة الحاي
**التاريخ:** 2026-02-26
**المدقق:** باسم
**النسخة:** 2.4.0
**النطاق:** جميع دوال SQL (Supabase) + Drift DAOs + Edge Functions

---

## الملخص التنفيذي

تم إجراء تدقيق شامل لجميع دوال قاعدة البيانات في منصة الحاي، شمل **10 ملفات SQL** في Supabase، و**2 Edge Functions**، و**28 DAO في Drift**، بالإضافة إلى خدمة البحث النصي FTS5. المنصة تستخدم بنية أمان متعددة الطبقات مع RLS و SECURITY DEFINER وتقسيم واضح للصلاحيات.

**التقييم العام: 7.2 / 10**

المنصة مبنية بأساس أمني جيد مع دوال مساعدة محكمة (is_super_admin, is_store_member, is_store_admin)، لكن هناك ثغرات حرجة في Edge Functions، ومشاكل في Race Conditions في عمليات الحسابات المالية، ونقص في التحقق من المدخلات في عدة أماكن.

---

## جدول ملخص بالأرقام

| البند | العدد |
|---|---|
| ملفات SQL في Supabase | 10 |
| Edge Functions | 2 |
| ملفات Dart DAO | 28 |
| خدمات مساعدة (FTS) | 1 |
| إجمالي الدوال المخزنة (PostgreSQL) | 10 |
| إجمالي Triggers (PostgreSQL) | 7 (5 SQL + 2 FTS) |
| إجمالي سياسات RLS | 65+ |
| إجمالي Custom SQL في DAOs | 25+ |
| مشاكل حرجة | 8 |
| مشاكل متوسطة | 12 |
| مشاكل منخفضة | 9 |

---

## قائمة بجميع الدوال

### أ. دوال PostgreSQL المخزنة (Stored Functions)

| # | اسم الدالة | الملف | السطر | النوع | SECURITY | الوصف |
|---|---|---|---|---|---|---|
| 1 | `is_super_admin()` | `supabase_init.sql` | 512 | Helper | DEFINER | التحقق من كون المستخدم سوبر أدمن |
| 2 | `is_store_member(TEXT)` | `supabase_init.sql` | 518 | Helper | DEFINER | التحقق من عضوية المستخدم في متجر |
| 3 | `is_store_admin(TEXT)` | `supabase_init.sql` | 527 | Helper | DEFINER | التحقق من كون المستخدم مدير/مالك متجر |
| 4 | `prevent_direct_role_update()` | `supabase_init.sql` | 544 | Trigger | - | منع تغيير الدور مباشرة |
| 5 | `prevent_store_id_change()` | `supabase_init.sql` | 558 | Trigger | - | منع تغيير store_id بعد الإنشاء |
| 6 | `deduct_stock_on_order_confirm()` | `supabase_init.sql` | 571 | Trigger | - | خصم المخزون عند تأكيد الطلب |
| 7 | `update_user_role(UUID, user_role, TEXT)` | `supabase_init.sql` | 630 | RPC | DEFINER | تحديث دور المستخدم مع سجل تدقيق |
| 8 | `handle_new_user()` | `fix_auth.sql` / `supabase_owner_only.sql` | 36/23 | Trigger | DEFINER | إنشاء سجل public.users عند التسجيل |
| 9 | `get_my_stores()` | `get_my_stores.sql` | 48 | RPC | DEFINER | جلب متاجر المستخدم الحالي |
| 10 | `get_store_categories(TEXT)` | `sync_rpc_functions.sql` | 10 | RPC | DEFINER | جلب تصنيفات المتجر |
| 11 | `get_store_products(TEXT)` | `sync_rpc_functions.sql` | 56 | RPC | DEFINER | جلب منتجات المتجر |
| 12 | `get_my_user_id()` | `fix_rls_recursion.sql` | 13 | Helper | DEFINER | إرجاع auth.uid() لتجنب التكرار |

### ب. Triggers في PostgreSQL

| # | اسم الـ Trigger | الجدول | الحدث | الملف | السطر |
|---|---|---|---|---|---|
| 1 | `prevent_direct_role_update` | users | BEFORE UPDATE OF role | `supabase_init.sql` | 690 |
| 2 | `prevent_store_id_change_products` | products | BEFORE UPDATE | `supabase_init.sql` | 696 |
| 3 | `prevent_store_id_change_store_members` | store_members | BEFORE UPDATE | `supabase_init.sql` | 700 |
| 4 | `prevent_store_id_change_debts` | debts | BEFORE UPDATE | `supabase_init.sql` | 704 |
| 5 | `prevent_store_id_change_purchase_orders` | purchase_orders | BEFORE UPDATE | `supabase_init.sql` | 708 |
| 6 | `on_order_status_change` | orders | AFTER UPDATE OF status | `supabase_init.sql` | 712 |
| 7 | `on_auth_user_created` | auth.users | AFTER INSERT | `fix_auth.sql` | 57 |

### ج. Edge Functions

| # | الاسم | الملف | الوصف |
|---|---|---|---|
| 1 | `upload-product-images` | `supabase/functions/upload-product-images/index.ts` | رفع صور المنتجات إلى Cloudflare R2 |
| 2 | `public-products` | `supabase/functions/public-products/index.ts` | عرض المنتجات العامة مع rate limiting |

### د. Drift DAOs (Dart - قاعدة البيانات المحلية)

| # | الـ DAO | الملف | عدد الدوال | Custom SQL |
|---|---|---|---|---|
| 1 | ProductsDao | `packages/alhai_database/lib/src/daos/products_dao.dart` | 17 | 2 |
| 2 | SalesDao | `packages/alhai_database/lib/src/daos/sales_dao.dart` | 16 | 6 |
| 3 | SaleItemsDao | `packages/alhai_database/lib/src/daos/sale_items_dao.dart` | ~5 | 0 |
| 4 | InventoryDao | `packages/alhai_database/lib/src/daos/inventory_dao.dart` | 7 | 0 |
| 5 | AccountsDao | `packages/alhai_database/lib/src/daos/accounts_dao.dart` | 11 | 1 |
| 6 | SyncQueueDao | `packages/alhai_database/lib/src/daos/sync_queue_dao.dart` | 16 | 4 |
| 7 | TransactionsDao | `packages/alhai_database/lib/src/daos/transactions_dao.dart` | 9 | 1 |
| 8 | OrdersDao | `packages/alhai_database/lib/src/daos/orders_dao.dart` | 17 | 4 |
| 9 | AuditLogDao | `packages/alhai_database/lib/src/daos/audit_log_dao.dart` | 11 | 0 |
| 10 | CategoriesDao | `packages/alhai_database/lib/src/daos/categories_dao.dart` | 11 | 0 |
| 11 | LoyaltyDao | `packages/alhai_database/lib/src/daos/loyalty_dao.dart` | 18 | 1 |
| 12 | StoresDao | `packages/alhai_database/lib/src/daos/stores_dao.dart` | 8 | 0 |
| 13 | UsersDao | `packages/alhai_database/lib/src/daos/users_dao.dart` | 12 | 0 |
| 14 | CustomersDao | `packages/alhai_database/lib/src/daos/customers_dao.dart` | 11 | 0 |
| 15 | SuppliersDao | `packages/alhai_database/lib/src/daos/suppliers_dao.dart` | 9 | 0 |
| 16 | ShiftsDao | `packages/alhai_database/lib/src/daos/shifts_dao.dart` | 10 | 0 |
| 17 | ReturnsDao | `packages/alhai_database/lib/src/daos/returns_dao.dart` | 7 | 0 |
| 18 | ExpensesDao | `packages/alhai_database/lib/src/daos/expenses_dao.dart` | 12 | 1 |
| 19 | PurchasesDao | `packages/alhai_database/lib/src/daos/purchases_dao.dart` | 10 | 0 |
| 20 | DiscountsDao | `packages/alhai_database/lib/src/daos/discounts_dao.dart` | 11 | 0 |
| 21 | NotificationsDao | `packages/alhai_database/lib/src/daos/notifications_dao.dart` | 7 | 0 |
| 22 | WhatsAppMessagesDao | `packages/alhai_database/lib/src/daos/whatsapp_messages_dao.dart` | ~5 | 0 |
| 23 | WhatsAppTemplatesDao | `packages/alhai_database/lib/src/daos/whatsapp_templates_dao.dart` | ~5 | 0 |
| 24 | OrganizationsDao | `packages/alhai_database/lib/src/daos/organizations_dao.dart` | ~5 | 0 |
| 25 | OrgMembersDao | `packages/alhai_database/lib/src/daos/org_members_dao.dart` | ~5 | 0 |
| 26 | PosTerminalsDao | `packages/alhai_database/lib/src/daos/pos_terminals_dao.dart` | ~5 | 0 |
| 27 | SyncMetadataDao | `packages/alhai_database/lib/src/daos/sync_metadata_dao.dart` | 15 | 2 |
| 28 | StockDeltasDao | `packages/alhai_database/lib/src/daos/stock_deltas_dao.dart` | 10 | 5 |

### هـ. خدمات إضافية

| # | الخدمة | الملف | الوصف |
|---|---|---|---|
| 1 | ProductsFtsService | `packages/alhai_database/lib/src/fts/products_fts.dart` | بحث FTS5 في المنتجات مع triggers تلقائية |

---

## النتائج التفصيلية

---

### 1. مشاكل حرجة (8 مشاكل)

---

#### 1.1 SQL Injection في Edge Function (public-products)

**التصنيف:** مشكلة حرجة
**الملف:** `supabase/functions/public-products/index.ts`
**السطر:** 116

```typescript
query = query.or(`name.ilike.%${search}%,barcode.eq.${search},sku.eq.${search}`);
```

**المشكلة:** قيمة `search` تُدخل مباشرة في سلسلة الفلتر بدون أي تنظيف (sanitization). على الرغم من أن Supabase JS client يقوم ببعض الحماية، إلا أن إدراج أحرف خاصة مثل `%`, `,`, `.` يمكن أن يغير بنية الفلتر ويسبب سلوكاً غير متوقع.

**التوصية:** تنظيف المدخلات وإزالة الأحرف الخاصة قبل الاستخدام:
```typescript
const sanitizedSearch = search.replace(/[%,.\(\)]/g, '');
```

---

#### 1.2 Race Condition في عمليات الرصيد (AccountsDao)

**التصنيف:** مشكلة حرجة
**الملف:** `packages/alhai_database/lib/src/daos/accounts_dao.dart`
**الأسطر:** 71-84

```dart
Future<void> addToBalance(String id, double amount) async {
  final account = await getAccountById(id);
  if (account != null) {
    await updateBalance(id, account.balance + amount);
  }
}

Future<void> subtractFromBalance(String id, double amount) async {
  final account = await getAccountById(id);
  if (account != null) {
    await updateBalance(id, account.balance - amount);
  }
}
```

**المشكلة:** عمليات القراءة والكتابة غير ذرية (not atomic). إذا وصل طلبان متزامنان، يمكن أن يفقد أحدهما التحديث (lost update). هذا خطير جداً في العمليات المالية.

**التوصية:** استخدام `transaction()` مع Drift أو استخدام SQL ذري:
```dart
Future<void> addToBalance(String id, double amount) async {
  await customUpdate(
    'UPDATE accounts SET balance = balance + ?, updated_at = ? WHERE id = ?',
    variables: [Variable.withReal(amount), Variable.withDateTime(DateTime.now()), Variable.withString(id)],
    updates: {accountsTable},
    updateKind: UpdateKind.update,
  );
}
```

---

#### 1.3 Race Condition في نقاط الولاء (LoyaltyDao)

**التصنيف:** مشكلة حرجة
**الملف:** `packages/alhai_database/lib/src/daos/loyalty_dao.dart`
**الأسطر:** 41-71

```dart
Future<void> addPoints(String customerId, String storeId, int points) async {
  final loyalty = await getCustomerLoyalty(customerId, storeId);
  if (loyalty != null) {
    await (update(loyaltyPointsTable)...).write(LoyaltyPointsTableCompanion(
      currentPoints: Value(loyalty.currentPoints + points),
      totalEarned: Value(loyalty.totalEarned + points),
      // ...
    ));
  }
}
```

**المشكلة:** نفس مشكلة Race Condition. عمليات إضافة وخصم النقاط غير ذرية. يمكن فقدان نقاط في حالة التزامن.

**التوصية:** استخدام SQL ذري مع `currentPoints = currentPoints + ?`.

---

#### 1.4 عدم التحقق من صلاحية store_id في upload-product-images

**التصنيف:** مشكلة حرجة
**الملف:** `supabase/functions/upload-product-images/index.ts`
**الأسطر:** 7, 67-77

```typescript
const { product_id, hash, images } = await req.json()
// ...
const { error: updateError } = await supabase
  .from('products')
  .update({...})
  .eq('id', product_id)
```

**المشكلة:** لا يوجد تحقق من أن المستخدم المصادق لديه صلاحية تعديل هذا المنتج. يتم الاعتماد على RLS فقط، لكن بما أن `product_id` يأتي من المستخدم بدون تحقق، قد يتمكن مستخدم من تعديل منتج لا يملكه إذا كانت سياسات RLS غير كاملة.

**التوصية:** إضافة تحقق صريح من ملكية المنتج قبل التحديث:
```typescript
// التحقق من أن المنتج ينتمي لمتجر المستخدم
const { data: product } = await supabase.from('products').select('store_id').eq('id', product_id).single();
```

---

#### 1.5 عدم التحقق من حجم المدخلات في upload-product-images

**التصنيف:** مشكلة حرجة
**الملف:** `supabase/functions/upload-product-images/index.ts`
**الأسطر:** 7, 45-53

```typescript
const { product_id, hash, images } = await req.json()
// ...
for (const [size, base64Data] of Object.entries(images)) {
  const binaryString = atob(base64Data as string)
```

**المشكلة:** لا يوجد حد أقصى لحجم الصور المرفوعة. يمكن لمستخدم خبيث إرسال صورة بحجم كبير جداً مما يستنزف ذاكرة الخادم ويسبب DoS. كما لا يتم التحقق من أن `images` هو كائن صالح أو أن `product_id` و `hash` موجودان.

**التوصية:**
```typescript
if (!product_id || !hash || !images) {
  return new Response(JSON.stringify({ error: 'Missing required fields' }), { status: 400 });
}
const MAX_SIZE = 5 * 1024 * 1024; // 5MB per image
for (const [size, base64Data] of Object.entries(images)) {
  if (typeof base64Data !== 'string' || base64Data.length > MAX_SIZE) {
    return new Response(JSON.stringify({ error: 'Image too large' }), { status: 413 });
  }
}
```

---

#### 1.6 CORS مفتوح بالكامل (Access-Control-Allow-Origin: *)

**التصنيف:** مشكلة حرجة
**الملف:** `supabase/functions/_shared/cors.ts`
**السطر:** 2

```typescript
export const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
```

**المشكلة:** السماح لأي نطاق بالوصول إلى Edge Functions. هذا يعني أن أي موقع ويب يمكنه استدعاء هذه الدوال نيابة عن المستخدم.

**التوصية:** تحديد النطاقات المسموح بها:
```typescript
'Access-Control-Allow-Origin': 'https://app.alhai.sa,https://admin.alhai.sa'
```

---

#### 1.7 get_store_products يعيد جميع المنتجات كـ JSONB واحد

**التصنيف:** مشكلة حرجة
**الملف:** `supabase/sync_rpc_functions.sql`
**الأسطر:** 56-106

```sql
CREATE OR REPLACE FUNCTION get_store_products(p_store_id TEXT)
RETURNS jsonb
-- ...
RETURN COALESCE(
  (SELECT jsonb_agg(
    jsonb_build_object(
      'id', p.id, ...22 حقلاً...
    )
  )
  FROM public.products p
  WHERE p.store_id = p_store_id AND p.is_active = true),
  '[]'::jsonb
);
```

**المشكلة:** هذه الدالة تجلب **جميع المنتجات** للمتجر في استجابة JSONB واحدة بدون pagination. إذا كان لدى المتجر آلاف المنتجات، ستستهلك ذاكرة كبيرة وتبطئ الاستجابة بشكل كبير. نفس المشكلة في `get_store_categories`.

**التوصية:** إضافة pagination مع `LIMIT/OFFSET` أو `cursor-based pagination`:
```sql
CREATE OR REPLACE FUNCTION get_store_products(
  p_store_id TEXT,
  p_limit INT DEFAULT 100,
  p_offset INT DEFAULT 0
)
```

---

#### 1.8 عدم وجود updated_at trigger تلقائي

**التصنيف:** مشكلة حرجة

**المشكلة:** لا يوجد trigger لتحديث عمود `updated_at` تلقائياً عند تعديل السجلات في أي جدول. يتم الاعتماد على الكود في التطبيق لتعيين هذا القيمة يدوياً، مما يعني أنه يمكن نسيانها أو تجاوزها.

**التوصية:** إنشاء دالة trigger عامة:
```sql
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
-- تطبيق على جميع الجداول
CREATE TRIGGER update_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION update_updated_at();
-- ... تكرار لكل جدول
```

---

### 2. مشاكل متوسطة (12 مشكلة)

---

#### 2.1 Rate Limiter في الذاكرة فقط (public-products)

**التصنيف:** مشكلة متوسطة
**الملف:** `supabase/functions/public-products/index.ts`
**الأسطر:** 4-8

```typescript
const RATE_LIMIT_REQUESTS = 100;
const RATE_LIMIT_WINDOW = 60000;
const rateLimitMap = new Map<string, { count: number; resetAt: number }>();
```

**المشكلة:** Rate limiter يخزن في الذاكرة فقط. في بيئة Deno Deploy (serverless)، كل instance لها ذاكرة مستقلة، فيمكن تجاوز الحد بسهولة. كما يشير التعليق في الكود نفسه: "use Redis in production for distributed".

**التوصية:** استخدام Redis أو Supabase Edge Runtime مع KV Store مشترك.

---

#### 2.2 عدم تنظيف ذاكرة Rate Limiter

**التصنيف:** مشكلة متوسطة
**الملف:** `supabase/functions/public-products/index.ts`
**الأسطر:** 8, 43-67

**المشكلة:** `rateLimitMap` لا يُنظَّف أبداً. تتراكم المفاتيح القديمة وتستهلك الذاكرة بمرور الوقت (memory leak).

**التوصية:** إضافة تنظيف دوري أو استخدام LRU Cache محدود الحجم.

---

#### 2.3 deduct_stock_on_order_confirm لا يتعامل مع الإلغاءات

**التصنيف:** مشكلة متوسطة
**الملف:** `supabase/supabase_init.sql`
**الأسطر:** 571-624

```sql
IF NOT (OLD.status = 'created' AND NEW.status IN ('confirmed', 'preparing')) THEN
  RETURN NEW;
END IF;
```

**المشكلة:** الدالة تخصم المخزون عند تأكيد الطلب، لكن **لا يوجد trigger لإعادة المخزون عند إلغاء الطلب**. إذا تم إلغاء الطلب بعد التأكيد، يبقى المخزون مخصوماً.

**التوصية:** إضافة منطق إعادة المخزون:
```sql
IF OLD.status IN ('confirmed', 'preparing', 'ready') AND NEW.status = 'cancelled' THEN
  -- إعادة المخزون
  UPDATE products p SET stock_qty = p.stock_qty + oi.qty
  FROM order_items oi WHERE oi.order_id = NEW.id AND p.id = oi.product_id AND p.track_inventory = true;
END IF;
```

---

#### 2.4 voidSale لا يحدث updated_at

**التصنيف:** مشكلة متوسطة
**الملف:** `packages/alhai_database/lib/src/daos/sales_dao.dart`
**الأسطر:** 76-82

```dart
Future<int> voidSale(String id) {
  return (update(salesTable)..where((s) => s.id.equals(id)))
    .write(const SalesTableCompanion(
      status: Value('voided'),
      updatedAt: Value(null), // يضع null بدل التاريخ الحالي!
    ));
}
```

**المشكلة:** عند إلغاء البيع، يتم تعيين `updatedAt` إلى `null` بدلاً من التاريخ الحالي. هذا يكسر نظام المزامنة ويفقد تاريخ التعديل.

**التوصية:** تغيير إلى `Value(DateTime.now())`.

---

#### 2.5 عدم التحقق من قيم المدخلات في RPC Functions

**التصنيف:** مشكلة متوسطة
**الملف:** `supabase/sync_rpc_functions.sql`
**الأسطر:** 10-52, 56-106

```sql
CREATE OR REPLACE FUNCTION get_store_categories(p_store_id TEXT)
-- لا يوجد تحقق من أن p_store_id ليس NULL أو فارغاً
```

**المشكلة:** دوال `get_store_categories` و `get_store_products` لا تتحقق من أن `p_store_id` ليس `NULL` أو سلسلة فارغة. على الرغم من وجود فحص العضوية، إلا أن القيم الفارغة قد تسبب سلوكاً غير متوقع.

**التوصية:** إضافة تحقق في بداية الدالة:
```sql
IF p_store_id IS NULL OR p_store_id = '' THEN
  RAISE EXCEPTION 'store_id is required';
END IF;
```

---

#### 2.6 استخدام LIKE مع مدخلات المستخدم بدون تنظيف (ProductsDao)

**التصنيف:** مشكلة متوسطة
**الملف:** `packages/alhai_database/lib/src/daos/products_dao.dart`
**الأسطر:** 60-66

```dart
return (select(productsTable)
  ..where((p) =>
    p.storeId.equals(storeId) &
    (p.name.like('%$query%') | p.barcode.like('%$query%') | p.sku.like('%$query%'))
  )
```

**المشكلة:** إدراج `query` مباشرة في نمط LIKE بدون تنظيف الأحرف الخاصة مثل `%` و `_` و `\`. يمكن للمستخدم إدخال `%` للحصول على جميع النتائج.

**التوصية:** تنظيف المدخلات:
```dart
final escapedQuery = query.replaceAll('%', '\\%').replaceAll('_', '\\_');
```

---

#### 2.7 تعريف مكرر للدوال المساعدة عبر عدة ملفات

**التصنيف:** مشكلة متوسطة
**الملفات:**
- `supabase/supabase_init.sql` (أسطر 512-538)
- `supabase/migrations/20260119_secure_public_products.sql` (أسطر 12-23)
- `supabase/migrations/20260223_tighten_rls_write_policies.sql` (أسطر 15-49)

**المشكلة:** الدوال `is_super_admin()`, `is_store_member()`, `is_store_admin()` معرّفة في 3 ملفات مختلفة باستخدام `CREATE OR REPLACE`. هذا يجعل من الصعب تتبع النسخة "الصحيحة" ويخلق احتمالية لتضارب التعريفات.

**التوصية:** تعريف الدوال في ملف واحد فقط (`supabase_init.sql`) وإزالة التعريفات المكررة من الـ migrations.

---

#### 2.8 سياسات RLS متضاربة على store_members

**التصنيف:** مشكلة متوسطة
**الملفات:**
- `supabase/supabase_init.sql` (أسطر 824-849) - `store_members_self_read`
- `supabase/fix_rls_recursion.sql` (سطر 28) - `store_members_self_select`
- `supabase/get_my_stores.sql` (سطر 40) - `store_members_self_read`
- `supabase/migrations/20260119_secure_public_products.sql` (سطر 32) - `store_members_owner_select_migration`

**المشكلة:** هناك 4 سياسات SELECT مختلفة على `store_members` معرّفة في ملفات مختلفة. بعضها يستخدم `auth.uid()` وبعضها `get_my_user_id()`. هذا يسبب تضارباً ويعقّد الصيانة.

**التوصية:** توحيد السياسات في ملف واحد وحذف المتضاربة.

---

#### 2.9 عدم استخدام Transaction في العمليات المركبة (InventoryDao)

**التصنيف:** مشكلة متوسطة
**الملف:** `packages/alhai_database/lib/src/daos/inventory_dao.dart`
**الأسطر:** 43-114

**المشكلة:** دوال `recordSaleMovement` و `recordPurchaseMovement` تسجل حركة مخزون لكن **لا تحدّث كمية المنتج فعلياً** في جدول المنتجات ضمن نفس الـ transaction. يجب أن تكون عمليات تعديل المخزون وتسجيل الحركة ذرية.

**التوصية:** دمج تحديث المخزون مع تسجيل الحركة في transaction واحد.

---

#### 2.10 عدم وجود INDEX على حقول البحث في FTS

**التصنيف:** مشكلة متوسطة
**الملف:** `packages/alhai_database/lib/src/fts/products_fts.dart`
**الأسطر:** 98-118

```dart
FROM products_fts fts
INNER JOIN products p ON fts.id = p.id
WHERE products_fts MATCH ?
  AND fts.store_id = ?
  AND p.is_active = 1
```

**المشكلة:** الجدول FTS يستخدم `JOIN` مع `products` على عمود `id` (نصي)، لكن FTS5 يخزن `id` كـ UNINDEXED. الـ JOIN يعتمد على ربط `fts.id = p.id` وهو TEXT = TEXT بدون index خاص على جانب FTS.

**التوصية:** التأكد من وجود index على `products.id` (موجود كـ PRIMARY KEY) والنظر في استخدام `content_rowid` بدل `id` للربط.

---

#### 2.11 معرف audit_log يعتمد على الطابع الزمني فقط

**التصنيف:** مشكلة متوسطة
**الملف:** `packages/alhai_database/lib/src/daos/audit_log_dao.dart`
**السطر:** 69

```dart
final id = '${DateTime.now().millisecondsSinceEpoch}_${action.name}';
```

**المشكلة:** المعرف يعتمد على `millisecondsSinceEpoch` + اسم العملية. في حالة تسجيل عمليتين من نفس النوع في نفس الميلي ثانية (ممكن على الأجهزة السريعة)، سيحدث تعارض PRIMARY KEY.

**التوصية:** استخدام UUID:
```dart
final id = const Uuid().v4();
```

---

#### 2.12 عدم وجود تحقق من store_members FK في supabase_init

**التصنيف:** مشكلة متوسطة
**الملف:** `supabase/supabase_init.sql`
**السطر:** 93

```sql
CREATE TABLE IF NOT EXISTS public.store_members (
  store_id TEXT NOT NULL,
  -- لا يوجد REFERENCES public.stores(id)
```

**المشكلة:** عمود `store_id` في `store_members` ليس له Foreign Key يربطه بجدول `stores`. يمكن إدراج سجلات بـ `store_id` غير موجود.

**التوصية:** إضافة `REFERENCES public.stores(id) ON DELETE CASCADE`.

---

### 3. مشاكل منخفضة (9 مشاكل)

---

#### 3.1 تكرار تعريف handle_new_user في ملفين

**التصنيف:** مشكلة منخفضة
**الملفات:** `supabase/fix_auth.sql` (سطر 36) و `supabase/supabase_owner_only.sql` (سطر 23)

**المشكلة:** الدالة معرّفة في ملفين بنفس الكود. يمكن أن يسبب ارتباكاً عند التعديل.

**التوصية:** الاحتفاظ بنسخة واحدة في `supabase_owner_only.sql` فقط.

---

#### 3.2 UUIDs ثابتة في fix_auth.sql

**التصنيف:** مشكلة منخفضة
**الملف:** `supabase/fix_auth.sql`
**الأسطر:** 7-8, 11-14

```sql
DELETE FROM auth.identities WHERE user_id = '5e399530-3b30-434a-bd2c-b9940b90d40d';
DELETE FROM auth.users WHERE id = '5e399530-3b30-434a-bd2c-b9940b90d40d';
```

**المشكلة:** ملف إصلاح يحتوي على UUIDs لمستخدمين محددين. هذا ملف تصحيحي لمرة واحدة ويجب ألا يكون جزءاً من الـ migrations العادية.

**التوصية:** نقله إلى مجلد `scripts/` أو `hotfixes/` منفصل مع ملاحظة أنه نُفذ بالفعل.

---

#### 3.3 عدم تحديد STABLE/VOLATILE في trigger functions

**التصنيف:** مشكلة منخفضة
**الملف:** `supabase/supabase_init.sql`
**الأسطر:** 544, 558, 571

**المشكلة:** دوال الـ Trigger (`prevent_direct_role_update`, `prevent_store_id_change`, `deduct_stock_on_order_confirm`) لا تحدد `VOLATILE` صراحة (وهو الافتراضي). على الرغم من أنها volatile بطبيعتها، إلا أن التحديد الصريح يحسن وضوح الكود.

---

#### 3.4 عدم وجود تعليقات (COMMENT ON FUNCTION) على الدوال

**التصنيف:** مشكلة منخفضة

**المشكلة:** معظم الدوال المخزنة لا تحتوي على تعليقات `COMMENT ON FUNCTION` لتوثيق الغرض منها.

**التوصية:** إضافة تعليقات على كل دالة:
```sql
COMMENT ON FUNCTION public.is_store_member(TEXT) IS 'التحقق من عضوية المستخدم الحالي في المتجر المحدد';
```

---

#### 3.5 خصائص image_url القديمة لا تزال موجودة

**التصنيف:** مشكلة منخفضة
**الملف:** `supabase/migrations/20260115_add_r2_images.sql`
**السطر:** 19

```sql
COMMENT ON COLUMN products.image_url IS 'Deprecated - use image_thumbnail/medium/large instead';
```

**المشكلة:** العمود `image_url` القديم مُعلّم كـ deprecated لكنه لا يزال موجوداً. كود الـ Sync RPC (`get_store_products`) لا يستعلم عنه مما يعني أنه فقد الاستخدام.

**التوصية:** حذف العمود في migration مستقبلي بعد التأكد من عدم استخدامه.

---

#### 3.6 عدم وجود فهرس على sync_status في stock_deltas

**التصنيف:** مشكلة منخفضة
**الملف:** `packages/alhai_database/lib/src/daos/stock_deltas_dao.dart`

**المشكلة:** استعلامات متعددة تفلتر بـ `sync_status = 'pending'` لكن لا يوجد فهرس على هذا العمود في تعريف الجدول.

**التوصية:** إضافة فهرس في الـ migration:
```sql
CREATE INDEX idx_stock_deltas_sync_status ON stock_deltas(sync_status);
```

---

#### 3.7 عدم وجود حد أعلى لعدد المحاولات في SyncQueueDao.retryItem

**التصنيف:** مشكلة منخفضة
**الملف:** `packages/alhai_database/lib/src/daos/sync_queue_dao.dart`
**الأسطر:** 180-187

```dart
Future<int> retryItem(String id) {
  return (update(syncQueueTable)..where((q) => q.id.equals(id)))
    .write(const SyncQueueTableCompanion(
      status: Value('pending'),
      retryCount: Value(0), // يعيد تعيين عداد المحاولات!
    ));
}
```

**المشكلة:** `retryItem` يعيد تعيين `retryCount` إلى 0 بدون حد أقصى لعدد مرات إعادة المحاولة اليدوية. يمكن أن يؤدي ذلك إلى محاولات لا نهائية لعنصر فاشل بشكل دائم.

---

#### 3.8 عدم وجود index على `orders.order_date` محلياً

**التصنيف:** مشكلة منخفضة
**الملف:** `packages/alhai_database/lib/src/daos/orders_dao.dart`

**المشكلة:** العديد من الاستعلامات تفلتر بـ `order_date >= ?` لكن لا يوجد ذكر لإنشاء index على هذا العمود في Drift محلياً.

---

#### 3.9 isFtsTableExists دائماً تعيد true

**التصنيف:** مشكلة منخفضة
**الملف:** `packages/alhai_database/lib/src/fts/products_fts.dart`
**الأسطر:** 225-235

```dart
Future<bool> isFtsTableExists() async {
  try {
    await _db.customSelect(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name='products_fts'",
      readsFrom: {},
    ).getSingleOrNull();
    return true; // تعيد true حتى لو لم يُوجد الجدول!
  } catch (_) {
    return false;
  }
}
```

**المشكلة:** الدالة تعيد `true` دائماً حتى لو كان الاستعلام يعيد `null` (أي الجدول غير موجود). يجب التحقق من نتيجة الاستعلام.

**التوصية:**
```dart
final result = await _db.customSelect(...).getSingleOrNull();
return result != null;
```

---

## تحليل الأمان (SECURITY DEFINER vs INVOKER)

### الدوال المحمية بـ SECURITY DEFINER

| الدالة | SET search_path | التقييم |
|---|---|---|
| `is_super_admin()` | `public, auth` | جيد |
| `is_store_member(TEXT)` | `public, auth` | جيد |
| `is_store_admin(TEXT)` | `public, auth` | جيد |
| `update_user_role(...)` | `public, auth` | جيد - يتضمن تحقق من الصلاحيات |
| `handle_new_user()` | `public, auth` | جيد - مطلوب للوصول لـ auth schema |
| `get_my_stores()` | `public, auth` | جيد |
| `get_store_categories(TEXT)` | `public, auth` | جيد - يتضمن تحقق من العضوية |
| `get_store_products(TEXT)` | `public, auth` | جيد - يتضمن تحقق من العضوية |
| `get_my_user_id()` | `public, auth` | جيد |

**ملاحظة إيجابية:** جميع الدوال SECURITY DEFINER تحدد `SET search_path` بشكل صحيح لمنع هجمات path manipulation. هذا ممتاز.

### صلاحيات GRANT/REVOKE

| الدالة | GRANT | REVOKE |
|---|---|---|
| `update_user_role` | authenticated | PUBLIC, anon |
| `get_store_categories` | authenticated | - |
| `get_store_products` | authenticated | - |
| `get_my_stores` | authenticated | - |

**ملاحظة:** دوال `get_store_categories` و `get_store_products` و `get_my_stores` لا تحتوي على `REVOKE FROM anon` صريح. يجب إضافته لمنع الوصول المجهول.

---

## تحليل الأداء

### نقاط القوة

1. **استخدام FTS5** في `ProductsFtsService` لبحث سريع بدل LIKE - ممتاز
2. **Pagination** مُطبق في `ProductsDao` و `SalesDao` - جيد
3. **Batch operations** في `batchUpdateStock` و `insertCategories` - جيد
4. **Group BY queries** بدل N+1 في `OrdersDao.getOrdersCountByStatus` - ممتاز
5. **فهارس PostgreSQL شاملة** في `supabase_init.sql` (30+ فهرس) - ممتاز
6. **Unique index مشروط** على `shifts(cashier_id) WHERE status = 'open'` لمنع فتح ورديتين - ذكي

### نقاط الضعف

1. **get_store_products/categories** - بدون pagination (مشكلة حرجة - ذُكرت أعلاه)
2. **getTopSellingProducts** في `ProductsDao` (سطر 255) - يستخدم subquery مع `GROUP BY` و `ORDER BY` ثم `JOIN` - قد يكون بطيئاً مع بيانات كبيرة
3. **عدم وجود index على sync_status** في stock_deltas و sync_queue محلياً
4. **customSelect بدون readsFrom** في بعض DAOs - يمنع Drift من إبطال الـ cache بشكل صحيح

---

## تحليل التوافق بين Supabase و Drift

### عدم تطابق الجداول

| الجدول | Supabase | Drift | ملاحظة |
|---|---|---|---|
| `stores.id` | TEXT | TEXT | متطابق |
| `products.price` | DOUBLE PRECISION | REAL (double) | متطابق |
| `orders.subtotal` | DECIMAL(10,2) | REAL (double) | قد يسبب فقدان دقة |
| `debts` | موجود | غير موجود | مختلف - Drift يستخدم accounts+transactions |
| `loyalty_points` | Supabase schema | Drift schema | هياكل مختلفة |

**ملاحظة:** هناك فجوة واضحة بين schema الـ Supabase (الذي يركز على النظام الإلكتروني B2C) و schema الـ Drift المحلي (الذي يركز على نقاط البيع POS). هذا تصميم مقصود لكنه يتطلب طبقة مزامنة دقيقة.

---

## التوصيات مع أولوية التنفيذ

### أولوية عاجلة (خلال أسبوع)

| # | التوصية | المرجع |
|---|---|---|
| 1 | إصلاح Race Condition في AccountsDao باستخدام SQL ذري | 1.2 |
| 2 | إصلاح Race Condition في LoyaltyDao باستخدام SQL ذري | 1.3 |
| 3 | إضافة تحقق من المدخلات في upload-product-images | 1.4, 1.5 |
| 4 | تنظيف مدخلات البحث في public-products | 1.1 |
| 5 | إصلاح voidSale لتعيين updated_at بشكل صحيح | 2.4 |
| 6 | إصلاح isFtsTableExists | 3.9 |

### أولوية عالية (خلال أسبوعين)

| # | التوصية | المرجع |
|---|---|---|
| 7 | إضافة pagination لـ get_store_products و get_store_categories | 1.7 |
| 8 | تقييد CORS لنطاقات محددة | 1.6 |
| 9 | إنشاء trigger عام لـ updated_at | 1.8 |
| 10 | إضافة trigger لإعادة المخزون عند إلغاء الطلب | 2.3 |
| 11 | إضافة REVOKE FROM anon على دوال RPC | تحليل الأمان |

### أولوية متوسطة (خلال شهر)

| # | التوصية | المرجع |
|---|---|---|
| 12 | توحيد تعريف الدوال في ملف واحد | 2.7 |
| 13 | توحيد سياسات RLS على store_members | 2.8 |
| 14 | إضافة FK على store_members.store_id | 2.12 |
| 15 | استخدام UUID في audit_log IDs | 2.11 |
| 16 | إضافة indexes على sync_status محلياً | 3.6 |
| 17 | دمج inventory movement مع stock update في transaction | 2.9 |

### أولوية منخفضة (خلال ربع)

| # | التوصية | المرجع |
|---|---|---|
| 18 | تنظيف ملفات الإصلاح المؤقتة | 3.2 |
| 19 | إضافة COMMENT ON FUNCTION | 3.4 |
| 20 | حذف عمود image_url المهمل | 3.5 |
| 21 | استبدال Rate Limiter في الذاكرة بحل موزع | 2.1, 2.2 |
| 22 | تنظيف أحرف LIKE الخاصة في البحث | 2.6 |

---

## جدول ملخص المشاكل

| التصنيف | العدد | الوصف |
|---|---|---|
| مشاكل حرجة | **8** | ثغرات أمنية، Race Conditions مالية، DoS، SQL Injection |
| مشاكل متوسطة | **12** | تضارب سياسات، عدم ذرية العمليات، أداء |
| مشاكل منخفضة | **9** | توثيق، تنظيف، تحسينات بسيطة |
| **الإجمالي** | **29** | |

---

## نقاط القوة الملحوظة

1. **نظام صلاحيات متعدد الطبقات** - RLS + SECURITY DEFINER + Helper Functions + REVOKE statements - بنية أمنية ممتازة
2. **SET search_path** على جميع دوال SECURITY DEFINER - يمنع هجمات path manipulation
3. **Trigger لمنع تغيير store_id** - حماية سلامة البيانات
4. **Trigger لمنع تغيير Role مباشرة** مع سجل تدقيق - ممتاز
5. **نظام FTS5** مع triggers تلقائية للمزامنة - أداء بحث ممتاز
6. **نظام Delta Sync** لتتبع تغييرات المخزون - تصميم ذكي للمزامنة
7. **Idempotency keys** في sync_queue - يمنع تكرار العمليات
8. **Batch operations** في ProductsDao و CategoriesDao - أداء جيد
9. **Pagination مُطبق** في معظم الـ DAOs - مهم للأداء
10. **Edge Function للمنتجات العامة** مع rate limiting ومحقق store_id - تصميم جيد

---

## التقييم النهائي

| المحور | التقييم | ملاحظة |
|---|---|---|
| الأمان (SQL Functions) | 8/10 | SECURITY DEFINER + search_path + صلاحيات محكمة |
| الأمان (Edge Functions) | 5/10 | CORS مفتوح، عدم تحقق من المدخلات |
| الأمان (DAOs) | 7/10 | تصفية store_id جيدة لكن بدون تنظيف مدخلات LIKE |
| الأداء (SQL Functions) | 5/10 | بدون pagination في RPC functions |
| الأداء (DAOs) | 8/10 | FTS5 + Pagination + Batch + Group BY |
| سلامة البيانات | 6/10 | Race Conditions في العمليات المالية |
| التوثيق | 5/10 | تعليقات عربية جيدة في الكود لكن بدون COMMENT ON |
| قابلية الصيانة | 6/10 | تكرار تعريفات، تضارب سياسات |
| التعامل مع الأخطاء | 7/10 | رسائل خطأ واضحة بالعربية والإنجليزية |
| المزامنة | 8/10 | Delta Sync + Idempotency + Conflict Resolution |

**التقييم الإجمالي: 7.2 / 10**

---

*تم إعداد هذا التقرير بواسطة Claude Opus 4.6 بتاريخ 2026-02-26*
