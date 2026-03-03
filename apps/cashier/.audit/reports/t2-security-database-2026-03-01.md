# تقرير مراجعة الحماية وقاعدة البيانات
## التاريخ: 2026-03-01

---

### ملخص تنفيذي
**حالة الأمان العامة: متوسط** — التطبيق يحتوي على أساسيات أمنية جيدة (تشفير قاعدة البيانات، عدم وجود مفاتيح مكشوفة، حماية المسارات) لكن يوجد ثغرات حرجة في سلامة البيانات المالية وحماية البيانات الشخصية.

**الإحصائيات:**
- 🔴 حرجة: 5 ثغرات
- 🟡 مهمة: 12 ثغرة
- 🟢 ثانوية: 4 ملاحظات

---

### 1. فحص الحماية (Security Audit)

| الفحص | الحالة | الخطورة | التفاصيل |
|-------|--------|---------|----------|
| أسرار مكشوفة | ✅ | 🟢 | لا توجد مفاتيح مكشوفة — Supabase عبر `--dart-define`، لا ملفات `.env` |
| مصادقة | ⚠️ | 🟡 | حماية مسارات جيدة عبر GoRouter، لكن لا يوجد session timeout أو حماية brute-force |
| تعقيم مدخلات | ✅ | 🟢 | Drift ORM يمنع SQL Injection، `InputSanitizer` موجود، Flutter canvas يحمي من XSS |
| ZATCA Security | ⬜ | — | لم يتم تطبيق ZATCA بعد |
| تبعيات آمنة | ✅ | 🟢 | جميع المكتبات محدّثة (`drift 2.31.0`, `supabase_flutter 2.12.0`, etc.) |
| تشفير البيانات | ⚠️ | 🟡 | SQLCipher + SecureStorage على native ممتاز، لكن على الويب مفتاح التشفير في localStorage |

#### تفاصيل فحص الحماية

**✅ نقاط القوة:**
- لا توجد مفاتيح API أو كلمات مرور مكشوفة في الكود المصدري
- Supabase URL و anon key عبر `String.fromEnvironment('SUPABASE_URL')` — لا قيم افتراضية مكتوبة
- لا يوجد `firebase_options.dart` أو ملفات `.env` في المستودع
- مفاتيح توقيع Android محمية في `.gitignore` (`key.properties`, `*.keystore`, `*.jks`)
- ProGuard/R8 مفعّل مع `isMinifyEnabled = true` و `isShrinkResources = true`
- لا يوجد raw SQL queries — جميع الاستعلامات عبر Drift ORM (حماية SQL Injection)
- حماية مسارات قوية: `_guardRedirect()` يعيد توجيه غير المصرّح لهم
- CSP جيد مع `frame-ancestors 'none'` و `X-Frame-Options: DENY`
- Service Worker لا يخزّن استجابات Auth في الكاش

**⚠️ مشاكل يجب معالجتها:**

1. **🟡 لا يوجد session timeout / قفل تلقائي للكاشير**
   - الملف: `lib/router/cashier_router.dart`
   - نظام POS يجب أن يقفل تلقائياً بعد فترة عدم نشاط (5-10 دقائق)
   - خطر: كاشير غير مراقب يمكن استخدامه من شخص غير مصرّح له

2. **🟡 لا يوجد حماية brute-force على تسجيل الدخول**
   - لا يوجد عدّاد محاولات تسجيل دخول فاشلة أو تأخير تدريجي
   - يعتمد بالكامل على rate limiting من Supabase server

3. **🟡 مفتاح تشفير قاعدة البيانات على الويب في localStorage**
   - الملف: `lib/main.dart` (سطر 117-127)
   - على native: `FlutterSecureStorage` مع `encryptedSharedPreferences` ✅
   - على web: `SharedPreferences` (أي `localStorage`) — مكشوف لأي JavaScript على الصفحة
   - خطر: هجوم XSS أو إضافة متصفح يمكنها قراءة المفتاح

4. **🟡 `.env` ليس في `.gitignore` ولا يوجد `.env.example`**
   - الملف: `.gitignore`
   - رغم عدم استخدام `.env` حالياً، يجب إضافة `*.env` و `.env*` كشبكة أمان
   - يجب إنشاء `.env.example` يوثّق المتغيرات المطلوبة

5. **🟡 CSP يسمح `unsafe-inline` و `unsafe-eval`**
   - الملف: `web/index.html` (سطر 24)
   - مطلوب من Flutter web لكن يضعف حماية XSS

6. **🟡 CSP يسمح `api.anthropic.com`**
   - يجب إزالته إذا لم يكن مطلوباً في الإنتاج

7. **🟡 `debugPrint` في release mode يسرّب تفاصيل أخطاء**
   - الملف: `lib/main.dart` (أسطر 29, 32, 46, 65, 107)
   - `debugPrint` يطبع في logcat على Android — يمكن قراءته عبر USB debugging
   - الأخطاء قد تحتوي على URLs أو معلومات حساسة

8. **🟡 `debugLogDiagnostics: true` دائماً مفعّل في GoRouter**
   - الملف: `lib/router/cashier_router.dart` (سطر 180)
   - يسجّل كل تنقل بين المسارات في جميع builds
   - يجب تغليفه بـ `kDebugMode`

---

### 2. فحص قاعدة البيانات (Database Audit)

| الفحص | الحالة | التفاصيل |
|-------|--------|----------|
| RLS مفعّل | ⬜ | لا يمكن التحقق — ملفات SQL في مشروع Supabase الخارجي |
| Indexes | ⬜ | لا يمكن التحقق — تعريفات الجداول في `alhai_database` package |
| Foreign Keys | ⬜ | لا FK مرئية في كود الكاشير — تحتاج مراجعة `alhai_database` |
| Multi-tenancy عزل | ⚠️ | `storeId` موجود في معظم الاستعلامات لكن ليس كلها |
| معاملات Atomic | ❌ | العمليات المالية بدون `transaction()` — خطر فقدان بيانات |
| Audit Trail | ❌ | `AuditLogDao` موجود لكن لا يُستخدم أبداً |
| Backup | ❌ | النسخ الاحتياطي وهمي (`Future.delayed` فقط) |

#### تفاصيل فحص قاعدة البيانات

**🔴 حرج — العمليات المالية ليست atomic:**
- الملف: `lib/screens/customers/new_transaction_screen.dart` (أسطر 748-762)
- الملف: `lib/screens/customers/customer_ledger_screen.dart` (أسطر 996-1008)
- الملف: `lib/screens/customers/apply_interest_screen.dart` (أسطر 659-668)
- الملف: `lib/screens/inventory/add_inventory_screen.dart` (أسطر 593-608)
- المشكلة: عمليتان منفصلتان (`insertTransaction` ثم `updateBalance`) بدون `_db.transaction()`
- الخطر: إذا تعطّل التطبيق بين العمليتين، يُسجَّل المعاملة بدون تحديث الرصيد (أو العكس)
- مثال:
  ```dart
  // ❌ الكود الحالي — غير آمن
  await _db.transactionsDao.insertTransaction(...);
  await _db.accountsDao.updateBalance(account.id, newBalance);

  // ✅ يجب أن يكون
  await _db.transaction(() async {
    await _db.transactionsDao.insertTransaction(...);
    await _db.accountsDao.updateBalance(account.id, newBalance);
  });
  ```

**🔴 حرج — النسخ الاحتياطي وهمي:**
- الملف: `lib/screens/settings/backup_screen.dart` (أسطر 97-131, 224-250)
- `_performBackup()` و `_performRestore()` هما فقط `Future.delayed` — لا يوجد تصدير أو استيراد فعلي
- الشاشة تعرض إحصائيات وهمية (12 نسخة، 45.8 MB)
- **لا يمكن استعادة البيانات في حالة فقدانها**

**🔴 حرج — لا يوجد audit trail للعمليات المالية:**
- `AuditLogDao` موجود في `mock_database.dart` لكن **لا يُستخدم أبداً** في `lib/`
- العمليات المالية (معاملات، تعديلات أرصدة، فوائد، حركات مخزون) لا تُسجَّل

**🟡 مهم — Multi-tenancy: بعض الاستعلامات بدون storeId:**
- `getAccountTransactions(widget.id)` — بدون `storeId` (`customer_ledger_screen.dart:53`)
- `getAccountById(widget.id)` — بدون `storeId` (`customer_ledger_screen.dart:51`)
- `getProductById(id)` — بدون `storeId` (`local_products_repository.dart:93`)
- `getAllStores()` — يحمّل كل المتاجر بدون فلترة (`transfer_inventory_screen.dart:59`)

**🟡 مهم — تحميل جداول كاملة بدون LIMIT:**

| الشاشة | الملف | الاستعلام |
|--------|-------|-----------|
| Sales History | `sales_history_screen.dart:60` | `getOrders(storeId)` — كل الطلبات |
| Payment History | `payment_history_screen.dart:53` | `getOrders(storeId)` — كل الطلبات |
| Custom Reports | `custom_report_screen.dart:108-171` | `getOrders` + `getAllProducts` + `getAllCustomers` |
| Stock Take | `stock_take_screen.dart:59-60` | `getAllProducts(storeId)` |
| Price Labels | `price_labels_screen.dart` | `getAllProducts(storeId)` |
| Payment Reports | `payment_reports_screen.dart:56` | `getOrders(storeId)` |
| Reprint Receipt | `reprint_receipt_screen.dart` | `getOrders(storeId)` |

- الفلترة تتم في Dart بدلاً من SQL WHERE
- مع آلاف الطلبات/المنتجات، سيتسبب في بطء وزيادة استهلاك الذاكرة

**🟡 مهم — N+1 query في شاشة التصنيفات:**
- الملف: `lib/screens/products/cashier_categories_screen.dart` (أسطر 61-72)
- يستعلم عن كل تصنيف على حدة لحساب عدد المنتجات (1 + N استعلام)
- يجب استخدام `COUNT(*) GROUP BY category_id`

**🟡 مهم — Hard Delete للمنتجات:**
- الملف: `lib/data/repositories/local_products_repository.dart` (أسطر 160-162)
- حذف فعلي بدلاً من Soft Delete — يفقد بيانات التقارير التاريخية
- المنتجات لديها `isActive` لكن `deleteProduct` يحذف نهائياً

**🟡 مهم — Hardcoded 'demo-store' fallback في 10+ شاشات:**
- شاشات مثل `new_transaction_screen.dart:744`, `customer_ledger_screen.dart:992`, `add_inventory_screen.dart:588` وغيرها
- تستخدم `'demo-store'` بدلاً من `kDefaultStoreId` عند فشل `currentStoreIdProvider`
- خطر: كتابة بيانات في store ID خاطئ

---

### 3. فحص التشفير وحماية البيانات

| الفحص | الحالة | الخطورة | التفاصيل |
|-------|--------|---------|----------|
| تشفير at rest | ✅ | 🟢 | SQLCipher مع `FlutterSecureStorage` على native |
| تشفير in transit | ✅ | 🟢 | Supabase عبر HTTPS فقط، CSP يقيّد connect-src |
| كلمات مرور | ✅ | 🟢 | Supabase Auth يستخدم bcrypt server-side |
| سياسة خصوصية | ❌ | 🔴 | لا توجد سياسة خصوصية — مطلوبة قانونياً (PDPL) |
| حذف بيانات العميل | ❌ | 🔴 | لا يوجد آلية لحذف بيانات العملاء عند الطلب |
| تنظيف عند الخروج | ❌ | 🟡 | لا يوجد logout أو تنظيف بيانات الجلسة |
| حماية root/jailbreak | ❌ | 🟡 | لا يوجد كشف أجهزة مخترقة |

#### تفاصيل حماية البيانات

**🔴 حرج — لا توجد سياسة خصوصية:**
- نظام حماية البيانات الشخصية السعودي (PDPL) يتطلب إفصاح واضح
- مطلوب أيضاً لنشر على Google Play و App Store
- لم يُعثر على أي ملف أو شاشة أو رابط لسياسة خصوصية

**🔴 حرج — لا يوجد آلية حذف بيانات العملاء:**
- بيانات العملاء المُجمّعة: الاسم، الهاتف، البريد، العنوان، المدينة، الرقم الضريبي
- `customerName` و `customerPhone` مكررة في سجلات المبيعات (denormalized)
- لا يوجد `deleteCustomer` أو `clearData` أو `deleteAccount` في الكود
- PDPL يمنح حق الحذف عند الطلب

**🟡 مهم — لا يوجد logout أو تنظيف جلسة:**
- لم يُعثر على أي دالة logout أو signOut في كود الكاشير
- البيانات المشفرة ومفتاحها يبقيان على الجهاز للأبد
- خطر: جهاز مشترك بين موظفين أو موظف سابق

**🟡 مهم — لا يوجد كشف root/jailbreak:**
- التطبيق يتعامل مع بيانات مالية (مبيعات، مدفوعات، صندوق نقدي)
- لا يوجد SafetyNet أو Play Integrity أو DeviceCheck

**🟡 مهم — Supabase Project URL مكشوف في ملف CSV:**
- الملف: `assets/data/products.csv`
- يحتوي على URLs حقيقية: `https://jtgwboqushihwvvsdtud.supabase.co/storage/v1/...`
- يكشف Supabase Project ID في أصول التطبيق المُوزّعة

---

### 4. الثغرات المكتشفة (ملخص)

#### 🔴 حرجة (5 — خطر أمني/مالي فوري)
1. **العمليات المالية غير atomic** — `insertTransaction` + `updateBalance` بدون `db.transaction()` → خطر تلف البيانات المالية
2. **النسخ الاحتياطي وهمي** — `backup_screen.dart` يحتوي `Future.delayed` فقط → لا يمكن استعادة البيانات
3. **لا يوجد audit trail** — `AuditLogDao` موجود لكن غير مُستخدم → لا سجل للعمليات المالية
4. **لا توجد سياسة خصوصية** — مخالفة لنظام PDPL السعودي ومتطلبات المتاجر
5. **لا يوجد آلية حذف بيانات العملاء** — مخالفة لحق الحذف في PDPL

#### 🟡 مهمة (12 — يجب إصلاحها قبل الإطلاق)
1. لا يوجد session timeout / قفل تلقائي للكاشير
2. لا يوجد حماية brute-force على تسجيل الدخول
3. مفتاح تشفير DB على الويب في `localStorage` (plaintext)
4. تحميل جداول كاملة بدون LIMIT (7+ شاشات)
5. بعض الاستعلامات بدون `storeId` (multi-tenancy leak)
6. N+1 query في شاشة التصنيفات
7. Hard Delete للمنتجات بدلاً من Soft Delete
8. `debugPrint` في release mode يسرّب تفاصيل أخطاء
9. `debugLogDiagnostics: true` دائماً في GoRouter
10. لا يوجد logout أو تنظيف بيانات الجلسة
11. لا يوجد كشف root/jailbreak
12. Hardcoded `'demo-store'` fallback في 10+ شاشات + Supabase Project ID مكشوف في CSV

#### 🟢 ثانوية (4 — تحسينات أمنية)
1. `.env` ليس في `.gitignore` ولا يوجد `.env.example`
2. CSP يسمح `unsafe-inline` و `unsafe-eval` (مطلوب من Flutter web)
3. CSP يسمح `api.anthropic.com` (يجب إزالته إذا غير مطلوب)
4. `InputSanitizer` موجود لكن يحتاج تحقق من استخدامه في كل الشاشات

---

### 5. التقييم

| المجال | التقييم | الملاحظات |
|--------|---------|-----------|
| أمان التطبيق | **7/10** | أساسيات ممتازة (تشفير، عدم كشف أسرار، ORM)، ينقصه session timeout و brute-force protection |
| أمان قاعدة البيانات | **4/10** | عمليات مالية غير atomic، لا audit trail، تحميل جداول كاملة، backup وهمي |
| حماية البيانات | **3/10** | لا سياسة خصوصية، لا حذف بيانات، لا logout، لا root detection |
| **التقييم العام** | **4.5/10** | التطبيق يحتاج عمل جوهري في سلامة البيانات المالية وحماية البيانات الشخصية قبل الإطلاق |

---

### 6. أولويات الإصلاح المقترحة

#### المرحلة 1 — قبل الإطلاق (حرج)
1. لف العمليات المالية في `_db.transaction()`
2. تفعيل `AuditLogDao` في جميع العمليات المالية
3. تنفيذ backup/restore حقيقي (تصدير DB + رفع سحابي)
4. إضافة سياسة خصوصية (شاشة + رابط)
5. إضافة آلية حذف بيانات العملاء

#### المرحلة 2 — أولوية عالية
6. إضافة auto-lock بعد فترة عدم نشاط
7. تحويل `getOrders`/`getAllProducts` إلى استعلامات مُصفّاة مع LIMIT
8. إصلاح استعلامات بدون `storeId`
9. إضافة logout مع تنظيف البيانات المحلية
10. إصلاح `debugPrint` و `debugLogDiagnostics`

#### المرحلة 3 — تحسينات
11. إضافة brute-force protection للـ login
12. إضافة root/jailbreak detection
13. تحويل Hard Delete إلى Soft Delete
14. إصلاح N+1 query في التصنيفات
15. إضافة `.env*` في `.gitignore` وإنشاء `.env.example`
