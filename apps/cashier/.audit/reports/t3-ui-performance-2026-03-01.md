# تقرير مراجعة واجهة المستخدم والأداء
## التاريخ: 2026-03-01

---

### ملخص تنفيذي

التطبيق يتمتع ببنية تصميم ممتازة مع Design System مركزي وتجاوب شامل مع أحجام الشاشات المختلفة. الأداء جيد بشكل عام مع وجود فرص تحسين في إعادة البناء غير الضرورية (336 setState). الوضع بدون إنترنت يعمل بشكل أساسي (100% offline-first) لكن ينقصه مراقبة الاتصال وحماية المعاملات ومزامنة البيانات. أبرز المشاكل: غياب Error States مع زر إعادة المحاولة، عدم استخدام RepaintBoundary، وعدم تفعيل SyncQueue الموجود في قاعدة البيانات.

---

### 1. واجهة المستخدم

| البند | الحالة | التفاصيل |
|-------|--------|----------|
| Design System | ✅ ممتاز | نظام تصميم مركزي عبر `alhai_shared_ui` — `AppColors` (1,740 استخدام)، `AppTypography`، `AppSizes` (lg/md/sm/xs)، `AppDurations`، `AppCurves` |
| تناسق التصميم | ✅ ممتاز | ألوان وخطوط ومسافات موحدة. مكونات مشتركة: `AppHeader`، `DenominationCounterWidget`، أزرار متسقة (`FilledButton`/`OutlinedButton`) |
| دعم RTL | ⚠️ جيد مع ثغرات | أساس قوي: `Directionality` wrapper في `main.dart`، استخدام `AlignmentDirectional`، `EdgeInsetsDirectional`. لكن 245 استخدام لـ `EdgeInsets.only` بحاجة مراجعة للتوافق مع RTL. لا توجد استراتيجية لعكس الأيقونات |
| حالات الشاشة | ⚠️ ناقص | Loading: ✅ موجود (Riverpod `.when()` pattern). Empty State: ⚠️ جزئي (موجود في بعض الشاشات فقط). Error State: ❌ غائب تماماً — لا توجد حوارات خطأ مع زر إعادة المحاولة. Skeleton Loaders: ❌ غير موجود |
| التجاوب | ✅ ممتاز | breakpoints شاملة: Desktop (≥905px)، Tablet، Mobile. 63 شاشة تستخدم responsive checks. Sidebar للديسكتوب، Drawer للموبايل. الجداول scrollable على الشاشات الصغيرة |
| سهولة الاستخدام | ⚠️ جيد | Snackbar: ✅ 149 استخدام. تأكيد قبل العمليات: ⚠️ جزئي — موجود لإغلاق الوردية لكن غائب للحذف والاسترجاع. أزرار اللمس: ⚠️ بعض الأيقونات في الجداول بحجم 15px (أقل من 48x48) |

**تفاصيل مشاكل RTL:**
- `EdgeInsets.only(left:, right:)` يجب تحويلها إلى `EdgeInsetsDirectional.only(start:, end:)` — 245 موقع
- `custom_report_screen.dart` — 5 استخدامات محتملة لـ hardcoded TextAlign
- الأيقونات تعتمد على auto-mirroring من Flutter بدون تحقق صريح

**تفاصيل حالات الشاشة المفقودة:**
- Error States: جميع الـ 47 شاشة تستخدم try/catch صامت بدون UI للخطأ
- Empty States مفقودة في: شاشات المخزون، بعض شاشات القوائم
- لا يوجد skeleton loaders — جميع حالات التحميل تعرض `CircularProgressIndicator` فقط

---

### 2. الأداء

| المقياس | القيمة | الحالة |
|---------|--------|--------|
| setState() calls | 336 في 45 ملف | ⚠️ عالي — شاشات مثل `create_invoice_screen` (15)، `new_transaction_screen` (13)، `add_inventory_screen` (12) |
| RepaintBoundary | 0 استخدام | ❌ غير موجود — subtrees مكلفة تُعاد رسمها بالكامل |
| const constructors | 2,008 استخدام | ⚠️ جيد لكن `prefer_const_constructors: false` في `analysis_options.yaml` |
| صور غير محسّنة | 0 | ✅ فقط أيقونات التطبيق القياسية (12 ملف) — لا صور تطبيق كبيرة |
| Image Caching | `cached_network_image` | ✅ مكتبة موجودة ومستخدمة في شاشات الإعدادات |
| Pagination | موجود | ✅ `LocalProductsRepository.getProducts()` — offset/limit مع `hasMore` flag |
| Debounce | 5 تطبيقات (300ms) | ✅ بحث المنتجات والعملاء مع debounce مناسب |
| Memory Leaks محتملة | 0 مؤكدة | ✅ 129 dispose() في 31 ملف — Controllers/Timers يتم إزالتها بشكل صحيح |
| MediaQuery.of() متكرر | 123 استخدام | ⚠️ يُستدعى عدة مرات في نفس الـ build — يجب تخزينه مؤقتاً |
| Isolate/compute | مستخدم | ✅ CSV parsing في background isolate عبر `compute()` في `main.dart` |
| حجم التطبيق (dependencies) | 30 مكتبة | ✅ معقول — `csv` قابلة للإزالة حسب TODO في pubspec |
| Tree Shaking | مفعّل (جزئياً) | ⚠️ `--no-tree-shake-icons` مستخدم في البناء |
| Animations | 60fps افتراضي | ✅ لا يوجد animation controllers بمشاكل |

**تفاصيل مشاكل الأداء:**
- `create_invoice_screen.dart` — 15 setState (أعلى شاشة)
- `new_transaction_screen.dart` — 13 setState
- `add_inventory_screen.dart` — 12 setState
- `apply_interest_screen.dart` — 9 setState
- `split_refund_screen.dart` — 7 setState
- عدم وجود `RepaintBoundary` حول widgets مكلفة مثل `denomination_counter_widget.dart`
- فلترة في الذاكرة بدون pagination في `customer_accounts_screen.dart` (lines 71-95)

**نقاط القوة في الأداء:**
- `Future.wait()` للتهيئة المتوازية في `main.dart` (lines 37-75)
- `ListView.builder` مستخدم في 14 ملف (lazy rendering)
- لا يوجد heavy computations في `build()` methods
- جميع الـ TextEditingController/ScrollController/Timer يتم dispose بشكل صحيح

---

### 3. Offline Mode

| البند | الحالة |
|-------|--------|
| يعمل بدون إنترنت | ✅ نعم — 100% offline-first architecture. Firebase/Supabase اختياريان مع try-catch |
| قاعدة بيانات محلية | ✅ Drift SQLite مشفّرة مع 28 DAO — منتجات، مبيعات، مخزون، عملاء، الخ |
| بذر البيانات الأولي | ✅ CSV seeding عند أول تشغيل مع parsing في background isolate |
| SharedPreferences | ✅ Theme، onboarding flag، encryption key مخزنة محلياً |
| Repository Pattern | ✅ `LocalProductsRepository` و `LocalCategoriesRepository` — فصل كامل عن الشبكة |
| Stream-based Updates | ✅ `watchProducts()` و `watchCategories()` — تحديثات reactive |
| مراقبة الاتصال | ❌ لا يوجد `connectivity_plus` — لا مؤشر offline في الواجهة |
| مزامنة البيانات | ❌ `alhai_sync` في dependencies لكن غير مستخدم. SyncQueueDao موجود في DB لكن لا يُكتب إليه |
| حماية المعاملات | ❌ عمليات الدفع بدون `database.transaction()` — خطر عدم تناسق البيانات |
| Idempotency | ❌ `TXN-${DateTime.now().millisecondsSinceEpoch}` — لا حماية من التكرار عند إعادة المحاولة |
| طابور العمليات المعلقة | ❌ لا يوجد queuing للعمليات الفاشلة |
| Cache Invalidation | ❌ لا سياسة لإبطال الكاش — المنتجات تُحمّل من CSV ولا تُحدّث من الخادم |
| حفظ السلة المؤقت | ❌ Cart في الذاكرة فقط — تضيع عند crash التطبيق |
| اختبارات Offline | ❌ جميع الاختبارات في `offline_sync_test.dart` placeholders بـ `expect(true, isTrue)` |

**تفاصيل مشكلة حماية المعاملات:**
```
// new_transaction_screen.dart, lines 748-762
await _db.transactionsDao.insertTransaction(...);  // Step 1
await _db.accountsDao.updateBalance(account.id, newBalance);  // Step 2
// إذا فشلت Step 2 بعد نجاح Step 1 → رصيد الحساب لا يتطابق مع المعاملات
```

**تفاصيل SyncQueue غير المستخدم:**
- `MockSyncQueueDao` في `test/helpers/mock_database.dart` (line 32) — موجود في schema
- `SyncMetadata`، `StockDeltas` DAOs موجودة لكن لا يُكتب إليها من أي شاشة
- لا يوجد كود لملء الطابور أو استهلاكه

---

### 4. المشاكل المكتشفة

#### 🔴 حرجة
1. **غياب Error States بالكامل** — جميع الـ 47 شاشة تستخدم try/catch صامت. لا توجد حوارات خطأ مع زر إعادة المحاولة. المستخدم لا يعرف ماذا حدث عند الفشل
2. **عدم حماية المعاملات المالية** — عمليات الدفع في `new_transaction_screen.dart` بدون `database.transaction()`. فشل جزئي يؤدي لعدم تناسق الأرصدة
3. **عدم وجود Idempotency** — `TXN-${DateTime.now().millisecondsSinceEpoch}` يسمح بإنشاء معاملات مكررة عند الضغط المزدوج
4. **SyncQueue موجود لكن غير مفعّل** — البنية التحتية للمزامنة جاهزة في DB لكن لا كود يستخدمها

#### 🟡 مهمة
5. **336 setState في 45 ملف** — إعادة بناء مفرطة خاصة في شاشات الفواتير والمخزون. يجب التحويل لـ Riverpod providers
6. **عدم وجود RepaintBoundary** — subtrees مكلفة تُعاد رسمها مع الأب
7. **245 استخدام لـ EdgeInsets.only بدل EdgeInsetsDirectional** — مشاكل RTL محتملة في عرض البيانات
8. **غياب تأكيد الحذف** — لا confirmation dialogs لعمليات: حذف مخزون، تعديل معاملة، استرجاع مدفوعات
9. **Cart غير محفوظ محلياً** — السلة تضيع عند crash التطبيق أثناء عملية البيع
10. **لا مراقبة اتصال** — لا مؤشر offline/online في الواجهة، لا `connectivity_plus`
11. **MediaQuery.of() يُستدعى عدة مرات** في نفس الـ build method — 123 موقع

#### 🟢 ثانوية
12. **`prefer_const_constructors: false`** في `analysis_options.yaml` — فرصة ضائعة لتحسين الأداء
13. **Debounce يدوي بـ Timer** في 5 شاشات — يمكن توحيده في utility مشتركة
14. **مكتبة `csv` قابلة للإزالة** — مذكورة كـ TODO في pubspec.yaml
15. **`--no-tree-shake-icons`** في أمر البناء — يزيد حجم التطبيق
16. **لا skeleton loaders** — جميع حالات التحميل تعرض spinner فقط
17. **بعض أيقونات الجداول بحجم 15px** — أقل من الحد الأدنى 48x48 للمس
18. **اختبارات offline جميعها placeholders** — `expect(true, isTrue)` بدون اختبارات حقيقية

---

### 5. التقييم

| المحور | الدرجة | الملاحظات |
|--------|--------|-----------|
| جودة UI | 8/10 | Design System ممتاز، تناسق عالي، RTL بحاجة تحسين |
| تجربة المستخدم | 6/10 | تجاوب ممتاز، لكن غياب Error States وتأكيد الحذف يُضعف التجربة |
| الأداء | 7/10 | Memory management ممتاز، لكن setState مفرط وعدم وجود RepaintBoundary |
| Offline Support | 5/10 | يعمل offline أساسياً لكن بدون حماية معاملات أو مزامنة أو مراقبة اتصال |
| **التقييم العام: 6.5/10** | | بنية تحتية ممتازة تحتاج تفعيل المزامنة وحماية المعاملات وتحسين UX الأخطاء |

---

### 6. التوصيات ذات الأولوية

| # | الأولوية | التوصية | الجهد |
|---|----------|---------|-------|
| 1 | 🔴 حرج | لف عمليات الدفع بـ `database.transaction()` وإضافة idempotency keys | منخفض |
| 2 | 🔴 حرج | إضافة Error State widgets مع زر إعادة المحاولة لجميع العمليات async | متوسط |
| 3 | 🔴 حرج | تفعيل SyncQueueDao — كتابة العمليات الفاشلة للطابور | متوسط |
| 4 | 🟡 مهم | إضافة `connectivity_plus` ومؤشر offline/online في الواجهة | منخفض |
| 5 | 🟡 مهم | تحويل الشاشات ذات setState العالي لـ ConsumerStatefulWidget + Riverpod | عالي |
| 6 | 🟡 مهم | إضافة confirmation dialogs للحذف والاسترجاع | منخفض |
| 7 | 🟡 مهم | مراجعة 245 EdgeInsets.only وتحويلها لـ EdgeInsetsDirectional | متوسط |
| 8 | 🟡 مهم | حفظ Cart محلياً في قاعدة البيانات (draft orders) | متوسط |
| 9 | 🟢 ثانوي | إضافة RepaintBoundary حول widgets مكلفة | منخفض |
| 10 | 🟢 ثانوي | تفعيل `prefer_const_constructors: true` في linter | منخفض |
