# تقرير المرحلة 2 — فحص تطبيق الكاشير (POS Audit)

**التاريخ:** 2026-04-14
**المدقّق:** Claude Opus 4.6 — POS Industrial Auditor
**النطاق:** `apps/cashier/` + `packages/alhai_pos/`
**استثناء:** ZATCA (يُفحص في جلسة منفصلة)

---

## 1. ملخص تنفيذي

تطبيق الكاشير **ناضج هندسياً** مع 41 شاشة و1,180 اختبار ناجح (559 alhai_pos + 621 cashier). عملية البيع **atomic بالكامل** داخل transaction واحد مع حماية append-only للفواتير المكتملة. نظام offline-first متين مع sync queue وretry وcircuit breaker. **العيب الأخطر**: سجل التدقيق يُحذف بعد 90 يوم (`cleanupOldLogs`) مما يكسر مبدأ append-only للمراجعة. بوابات الدفع الإلكتروني (مدى/STC Pay/تمارا) **محاكاة فقط** — لا يوجد SDK فعلي مُدمج. 60+ نص عربي متصلّب في خدمات الطباعة يمنع التوسع للأسواق الـ7.

---

## 2. نتائج كل قسم

### القسم 1: عملية البيع الأساسية (Sale Lifecycle)

| البند | الحالة | الدليل | الخطورة |
|--------|--------|--------|---------|
| 1.1 شاشات البيع الرئيسية | ✅ PASSED | 41 شاشة في `apps/cashier/lib/screens/` + 4 شاشات POS في `packages/alhai_pos/lib/src/screens/pos/`. كل شاشة لها test file مقابل (44 screen test) | — |
| 1.1 حالات الشاشة (loading/error/empty) | ✅ PASSED | الشاشات تستخدم `FutureProvider.autoDispose` مع `AsyncValue` (loading/data/error). مثال: `returnsListProvider` في `returns_providers.dart:32` | — |
| 1.1 تغطية Widget tests | ✅ PASSED | 44 screen test + 11 service test + 6 unit test في cashier. 18 screen test + 6 provider test + 15 service test في alhai_pos | — |
| 1.2 إضافة منتج (barcode/search/category) | ✅ PASSED | `barcode_listener.dart` للباركود، `instant_search.dart` للبحث، `pos_category_widgets.dart` للتصفّح، `favorites_row.dart` للمفضّلة | — |
| 1.2 validation كميات سالبة/صفر | ✅ PASSED | `cart_providers.dart:522-553`: `addProduct` يستخدم `clamp(1, 9999)`، `updateQuantity:601` يحذف المنتج إذا `qty <= 0` | — |
| 1.2 توقيت خصم المخزون | 🟡 PARTIAL | `sale_service.dart:307-320`: المخزون يُخصم **داخل** transaction البيع (atomic). آمن ضد فقد البيانات، لكن يحجز المخزون قبل تأكيد الدفع فعلياً | MEDIUM |
| 1.2 حساب الضريبة لحظياً | ✅ PASSED | `payment_screen.dart` يستخدم `VatCalculator` من alhai_zatca. الضريبة تُحسب عند فتح شاشة الدفع وليس per-item في السلة (مقبول) | — |
| 1.3 أنواع الخصومات | 🟡 PARTIAL | خصم ثابت فقط على مستوى الفاتورة (`CartState.discount`). لا يوجد خصم نسبة مئوية مباشر في السلة ولا خصم per-item. `cart_providers.dart:678-683` | LOW |
| 1.3 صلاحية مدير للخصم > 20% | ✅ PASSED | `manager_approval_service.dart:93`: `'discount_over_20'` في `protectedActions`. يستخدم PIN مع PBKDF2 + lockout بعد 5 محاولات | — |
| 1.3 تسجيل الخصم في sales table | ✅ PASSED | `sale_service.dart:260`: `discount: Value(discount)` يُحفظ كقيمة مطلقة في DB | — |
| 1.4 atomicity البيع | ✅ PASSED | `sale_service.dart:119-395`: كل العمليات (إنشاء البيع + عناصر البيع + خصم المخزون + تسجيل الدين) داخل `_db.transaction()`. Sync enqueue **خارج** الـ transaction (سطر 427) — تصميم صحيح | — |
| 1.4 فاتورة completed = non-modifiable | ✅ PASSED | `sales_dao.dart:93-111`: `_immutableStatuses = ['completed', 'paid', 'refunded']`. `updateSale()` يرمي `AppendOnlyViolationException` عند محاولة تعديل حقول مالية | — |
| 1.4 retry لتصادم رقم الإيصال | ✅ PASSED | `sale_service.dart:117-420`: retry loop حتى 3 محاولات مع unique index `idx_sales_store_receipt_unique` | — |

### القسم 2: Offline-First

| البند | الحالة | الدليل | الخطورة |
|--------|--------|--------|---------|
| 2.1 كشف انقطاع الاتصال | ✅ PASSED | `connectivity_service.dart:17-167`: يستخدم `connectivity_plus`، يكشف wifi/mobile/ethernet/none، يطلق `onConnectivityChanged` stream | — |
| 2.1 UI indicator (online/offline/syncing) | ✅ PASSED | `smart_offline_banner.dart` + `offline_banner.dart` + `sync_status_indicator.dart` في alhai_shared_ui. يعرض: حالة الاتصال، عدد العمليات المعلقة، زر مزامنة يدوية، تنبيه dead-letter بعد 3 محاولات فاشلة | — |
| 2.1 البيع يستمر offline | ✅ PASSED | `sale_service.dart` يحفظ محلياً أولاً. Sync enqueue خارج الـ transaction — إذا فشل الإدراج في الطابور، البيع محفوظ محلياً. `offline_queue_service.dart` يخزّن في SharedPreferences | — |
| 2.2 استخدام alhai_sync صحيح | ✅ PASSED | `sale_service.dart:428-488` يستخدم `_syncService.enqueueCreate()` مع `SyncPriority.high`. لا يحاول HTTP مباشرة | — |
| 2.2 retry logic | ✅ PASSED | `OfflineQueueService`: max 3 retries مع exponential backoff. `SyncManager`: circuit breaker (5 failures → 5min cooldown). 621 اختبار ناجح يشمل retry scenarios | — |
| 2.2 المستخدم يعرف بالفواتير المعلقة | ✅ PASSED | `UnsyncedSalesBanner`: يظهر بعد 5 دقائق من وجود فواتير معلقة، يعرض العدد والمدة. `DeadLetterBanner`: ينبّه بالعناصر الفاشلة مع زر إعادة المحاولة | — |
| 2.3 فتح التطبيق offline أول مرة | ✅ PASSED | `main.dart:254-289`: seed من CSV مع `compute()` في isolate. `DatabaseSeeder.isDatabaseEmpty()` يفحص قبل التهيئة. المنتجات تُحمّل من assets محلية | — |
| 2.3 حفظ الفواتير بعد إعادة التشغيل | ✅ PASSED | `CartNotifier.dispose():416-419`: يحفظ فوراً بدون debounce عند الإغلاق. الفواتير المكتملة في SQLite. `cart_providers.dart:368-378`: المسودة تُحفظ وتُعرض للتأكيد عند إعادة الفتح | — |
| 2.3 انقطاع في منتصف البيع | ✅ PASSED | البيع atomic داخل transaction. إذا أُغلق التطبيق قبل commit، لا شيء يُحفظ. إذا تم commit، البيع كامل. لا half-write | — |
| 2.4 SQLCipher | ✅ PASSED | `main.dart:215-248`: `_getOrCreateDbKey()` يستخدم `FlutterSecureStorage` (native) أو SharedPreferences (web مع تحذير أمني موثّق). `setDatabaseEncryptionKey(dbKey)` يُستدعى قبل فتح DB | — |
| 2.4 تراكم البيانات بدون حد | ❌ FAILED | لا يوجد آلية cleanup لبيانات المبيعات. `sales_dao.dart` لا يحتوي cleanup. 365K سطر/سنة × بدون حد = مشكلة أداء محتملة بعد 2-3 سنوات. `audit_log_dao` فقط يحذف بعد 90 يوم | HIGH |

### القسم 3: أنواع الدفع (Payment Methods)

| البند | الحالة | الدليل | الخطورة |
|--------|--------|--------|---------|
| 3.1 الأنواع المدعومة | ✅ PASSED | `payment_gateway.dart:17-37`: Cash, Card, Mada, Visa, Mastercard, Apple Pay, STC Pay, Tamara, Tabby, Wallet. في `sales_table`: paymentMethod string مع cashAmount/cardAmount/creditAmount | — |
| 3.2 حساب الباقي | ✅ PASSED | `payment_screen.dart` يحسب `change = amountReceived - total`. `sale_service.dart:265-266`: `amountReceived` و `changeAmount` يُخزّنان في DB | — |
| 3.2 تقريب الأرقام | ✅ PASSED | `toStringAsFixed(2)` مستخدم في كل حسابات المال. Dart `double` (IEEE 754) كافٍ لـ POS amounts | — |
| 3.2 عملات أجنبية | ✅ PASSED | لا يدعم — SAR فقط. مقبول للسوق السعودي. `_currency = 'SAR'` | — |
| 3.3 الدفع الإلكتروني (Mada) | ❌ FAILED | `payment_gateway.dart:334-444`: `MadaPaymentGateway` **محاكاة فقط**. `kReleaseMode` يرجع `PaymentGatewayStatus.notConfigured`. TODO: Nearpay SDK. لا يوجد SDK مُدمج فعلي | HIGH |
| 3.3 تسجيل يدوي مع رقم مرجعي | 🟡 PARTIAL | يمكن اختيار "card" كطريقة دفع في `PaymentScreen` ويُسجّل كـ string في DB. لكن لا يوجد حقل مخصص لرقم مرجعي طرفية الدفع | MEDIUM |
| 3.4 الدفع المقسّم | ✅ PASSED | `split_payment_dialog.dart` موجود. `sale_service.dart:93-95`: يدعم `cashAmount` + `cardAmount` + `creditAmount`. `paymentMethod = 'mixed'` | — |
| 3.4 validation مجموع الأقساط = الفاتورة | 🟡 PARTIAL | `payment_screen.dart` يحسب الأقساط، لكن لا يوجد validation صريح مرئي أن مجموع (cash+card+credit) = total قبل الحفظ | MEDIUM |
| 3.5 الإرجاع عبر فاتورة جديدة | ✅ PASSED | `returns_providers.dart:56-110`: `createReturn()` يُنشئ سجل جديد في `returns` table مع `saleId` كـ reference. لا يعدّل الفاتورة الأصلية | — |
| 3.5 reference_invoice_id | ✅ PASSED | `returns_table.dart:25-26`: `saleId` يشير للبيع الأصلي مع `references(SalesTable, #id, onDelete: KeyAction.restrict)` | — |
| 3.5 استرجاع المخزون بعد الإرجاع | 🟡 PARTIAL | `returns_providers.dart:56-110`: `createReturn()` لا يستدعي `inventoryDao` لاستعادة المخزون. `voidSale` في `sales_dao.dart:137-241` يستعيد المخزون، لكن الإرجاع الجزئي لا يستعيده | HIGH |

### القسم 4: الطباعة (Printing)

| البند | الحالة | الدليل | الخطورة |
|--------|--------|--------|---------|
| 4.1 الطابعات المدعومة | ✅ PASSED | 3 أنواع: Sunmi (platform channel)، Bluetooth ESC/POS (chunked 512B)، Network TCP (port 9100). مغلّفة خلف `ThermalPrintService` interface في `print_service.dart` | — |
| 4.1 print queue مع retry | ✅ PASSED | `print_queue_service.dart`: exponential backoff (3s base, max 3 retries)، persistence في SharedPreferences، reprint capability | — |
| 4.2 حقول الفاتورة القانونية | ✅ PASSED | `receipt_builder.dart:30-164` + `receipt_pdf_generator.dart:96-176`: اسم المنشأة ✓، الرقم الضريبي ✓، السجل التجاري ✓، العنوان ✓، رقم الفاتورة ✓، التاريخ/الوقت ✓، تفاصيل المنتجات ✓، المجموع قبل الضريبة ✓، الضريبة 15% ✓، المجموع الكلي ✓، QR code (ZATCA) ✓ | — |
| 4.2 اتجاه النص العربي | ✅ PASSED | `receipt_builder.dart:8-9`: "RTL content printed LTR by the printer, which handles bidi internally". PDF: `textDirection: pw.TextDirection.rtl` | — |
| 4.2 الأرقام | ✅ PASSED | أرقام غربية (0-9) — مقبول في السوق السعودي. `_formatMoney` يستخدم `toStringAsFixed(2)` مع فواصل آلاف | — |
| 4.3 نصوص hardcoded عربية | ❌ FAILED | **60+ نص عربي متصلّب** في `receipt_builder.dart` و `sunmi_print_service.dart`. مثال: 'هاتف:', 'رقم الفاتورة:', 'الصنف', 'المجموع الفرعي:', 'ضريبة القيمة المضافة (15%):', 'شكراً لزيارتكم', 'طريقة الدفع:', وغيرها. **لم تُنقل لـ l10n** | MEDIUM |
| 4.3 رسائل خطأ الطباعة hardcoded | 🟡 PARTIAL | `bluetooth_print_service.dart`, `network_print_service_impl.dart`, `sunmi_print_service.dart`: ~15 رسالة خطأ عربية متصلّبة ('الطابعة غير متصلة', 'خطأ في طابعة سنمي', إلخ) | LOW |
| 4.4 PDF generation | ✅ PASSED | `receipt_pdf_generator.dart`: يستخدم `pdf` package مع خط Tajawal عربي (Regular + Bold). RTL support. QR code ZATCA. أحجام: 58mm/80mm | — |
| 4.4 حجم PDF | 🟡 PARTIAL | لا يوجد اختبار لحجم PDF. PDF يُولّد ديناميكياً — حجمه يعتمد على عدد المنتجات. لا يمكن تأكيد <200KB بدون اختبار فعلي | LOW |

### القسم 5: الأداء (Performance)

| البند | الحالة | الدليل | الخطورة |
|--------|--------|--------|---------|
| 5.1 بحث المنتجات | ✅ PASSED | FTS5 مُفعّل من المرحلة 1. `instant_search.dart` يستخدمه. 559 اختبار في alhai_pos ناجح | — |
| 5.1 performance benchmark | 🟡 PARTIAL | لا يوجد اختبار أداء مخصص لقياس سرعة البحث في 50K منتج | MEDIUM |
| 5.2 سرعة فتح التطبيق | ✅ PASSED | `main.dart:60-111`: Firebase + Supabase + DB key + SharedPreferences + storeId تعمل **بالتوازي** عبر `Future.wait()`. CSV seeding في `compute()` isolate. Splash screen ضمني (MaterialApp يعرض فوراً) | — |
| 5.2 عدد async قبل الشاشة الأولى | 🟡 PARTIAL | 5 عمليات async متوازية + DI + CSV seed + session check (web). لا يوجد benchmark لقياس < 3 ثوانٍ فعلياً | LOW |
| 5.3 سرعة إتمام البيع | ✅ PASSED | `sale_service.dart`: لا يوجد اتصال شبكة في المسار الحرج (sync خارج transaction). العملية: DB transaction فقط | — |
| 5.4 flutter analyze | ✅ PASSED | 10 issues فقط — كلها `info` level (curly braces style). **صفر** errors أو warnings | — |
| 5.4 memory leaks | ✅ PASSED | `CartNotifier.dispose()` يحفظ ويلغي timer. `ConnectivityService.dispose()` يلغي subscription ويغلق controller. `_actualCashController.dispose()` في ShiftCloseScreen | — |

### القسم 6: إدارة الصندوق (Cash Drawer / Shift Management)

| البند | الحالة | الدليل | الخطورة |
|--------|--------|--------|---------|
| 6.1 نظام الورديات | ✅ PASSED | `shifts_dao.dart`: `openShift()`, `closeShift()`, `getOpenShift()`, `watchOpenShift()` (stream). `shifts_table.dart`: openingCash, closingCash, expectedCash, difference, status ('open'/'closed') | — |
| 6.1 المبلغ الافتتاحي | ✅ PASSED | `shift_open_screen.dart` + `shifts_dao.dart:64-65`: يُسجّل openingCash عند الفتح | — |
| 6.1 المقارنة عند الإغلاق | ✅ PASSED | `shifts_dao.dart:67-92`: `closeShift()` يحفظ closingCash + expectedCash + difference + totalSales + totalRefunds. `shift_close_screen.dart`: denomination counter + difference indicator | — |
| 6.2 إيداعات/سحوبات | ✅ PASSED | `cash_in_out_screen.dart` + `CashMovementsTable`: type ('cash_in'/'cash_out')، amount، description. `shifts_dao.dart:111-119`: `getShiftMovements()`, `insertCashMovement()` | — |
| 6.2 صلاحية مدير للسحب | ✅ PASSED | `manager_approval_service.dart:94`: `'cash_out'` في `protectedActions` — يتطلب PIN المدير | — |
| 6.3 تقرير نهاية الوردية | ✅ PASSED | `daily_summary_screen.dart` + `shift_close_screen.dart`: يحسب مبيعات نقدية + شبكة + إرجاعات + خصومات + مقارنة الرصيد | — |
| 6.3 PDF للأرشفة | 🟡 PARTIAL | لا يوجد دليل على إنتاج PDF مخصص لتقرير الوردية (PDF generator موجود للفواتير فقط) | LOW |

### القسم 7: الصلاحيات (Roles & Permissions)

| البند | الحالة | الدليل | الخطورة |
|--------|--------|--------|---------|
| 7.1 الأدوار المعرّفة | ✅ PASSED | `user_role.dart`: superAdmin, storeOwner, employee, delivery, customer. `user_role_resolver.dart`: يحوّل من DB string إلى enum مع fallback إلى employee | — |
| 7.1 فرق الصلاحيات | ✅ PASSED | `RolesTable`: permissions (JSON). `manager_approval_service.dart:86-99`: 12 إجراء محمي بما في ذلك void_sale, refund, cash_out, discount_over_20 | — |
| 7.2 إلغاء فاتورة (void) | ✅ PASSED | `manager_approval_service.dart:89`: `'void_sale'` يتطلب PIN مدير. `AuditService.logSaleCancel()` يسجّل في audit log | — |
| 7.2 خصم > 20% | ✅ PASSED | `manager_approval_service.dart:93`: `'discount_over_20'` يتطلب PIN مدير | — |
| 7.2 سحب نقدي | ✅ PASSED | `manager_approval_service.dart:94`: `'cash_out'` يتطلب PIN مدير. `AuditService.logCashDrawer()` يسجّل | — |
| 7.3 audit log | ✅ PASSED | `audit_log_table.dart`: 21 نوع action. `audit_log_dao.dart`: `log()`, `getLogs()`, `getLogsByDateRange()`, `getLogsByAction()`, `getLogsByUser()` | — |
| 7.3 audit log append-only | ❌ FAILED | `audit_log_dao.dart`: `cleanupOldLogs()` يحذف السجلات الأقدم من 90 يوم. **هذا يكسر مبدأ append-only** — سجلات التدقيق يجب أن تكون دائمة للمراجعة القانونية والضريبية | CRITICAL |
| 7.3 UI لمراجعة audit log | 🟡 PARTIAL | لا يوجد شاشة مخصصة في الكاشير لعرض audit log (الشاشة موجودة في admin فقط) | LOW |

### القسم 8: الاستثناءات والأخطاء (Error Handling)

| البند | الحالة | الدليل | الخطورة |
|--------|--------|--------|---------|
| 8.1 انقطاع كهرباء أثناء بيع | ✅ PASSED | `sale_service.dart`: DB transaction = checkpoint. إذا أُغلق قبل commit → لا شيء يُحفظ. إذا تم commit → بيع كامل. `CartNotifier.dispose()` يحفظ السلة فوراً | — |
| 8.1 امتلاء التخزين | ❌ FAILED | لا يوجد آلية لمراقبة مساحة التخزين أو تنبيه قبل الامتلاء. لا يوجد cleanup للمبيعات القديمة | HIGH |
| 8.1 فشل الاتصال بقاعدة البيانات | ✅ PASSED | `SaleException` مع `userMessage` عربي واضح. `sale_service.dart:171-176`: إذا المنتج غير موجود → رسالة واضحة 'المنتج "X" غير موجود في قاعدة البيانات' | — |
| 8.1 منتج بسعر سالب/صفر | 🟡 PARTIAL | `cart_providers.dart:659`: customPrice يُقبل `price >= 0` (يسمح بصفر). لا يوجد validation على سعر المنتج القادم من DB. منتج بسعر 0 يُباع بدون تحذير | MEDIUM |
| 8.2 رسائل الخطأ بالعربية | ✅ PASSED | `SaleException` + `PaymentErrorType` + رسائل الطباعة — كلها بالعربية مع وصف واضح | — |
| 8.2 الخطوة التالية في رسائل الخطأ | 🟡 PARTIAL | بعض الرسائل وصفية فقط ('الطابعة غير متصلة') بدون إرشاد ('حاول إعادة الاتصال') | LOW |

### القسم 9: التكامل مع المنظومة

| البند | الحالة | الدليل | الخطورة |
|--------|--------|--------|---------|
| 9.1 المزامنة admin → cashier | ✅ PASSED | `pull_sync_service.dart`: يجلب المنتجات والفئات والإعدادات من الخادم. `org_catalog_service.dart` للكتالوج المشترك | — |
| 9.1 cashier → admin reports | ✅ PASSED | `sale_service.dart:427-488`: مبيعات تُدفع عبر sync queue بأولوية عالية. `push_strategy` في alhai_sync | — |
| 9.1 تأخير المزامنة | ✅ PASSED | `connectivity_service.dart:142-166`: مزامنة فورية عند عودة الاتصال. `UnsyncedSalesBanner` ينبّه بعد 5 دقائق | — |
| 9.2 البيانات الأولية | ✅ PASSED | `main.dart:254-289`: CSV seed (categories + products) عند أول تشغيل. `DatabaseSeeder.isDatabaseEmpty()` يفحص. Parsing في background isolate | — |

---

## 3. العيوب المكتشفة (مرتبة حسب الخطورة)

### CRITICAL

| # | العيب | الملف:السطر | التأثير |
|---|-------|-------------|---------|
| C1 | **audit log يُحذف بعد 90 يوم** — `cleanupOldLogs()` يكسر مبدأ append-only. السجلات الضريبية والمالية يجب أن تبقى دائمة (5+ سنوات حسب نظام الزكاة) | `packages/alhai_database/lib/src/daos/audit_log_dao.dart` — method `cleanupOldLogs()` | فقدان سجل تدقيق = مخالفة نظامية محتملة. يجب إزالة أو تعطيل هذه الوظيفة أو نقل السجلات للأرشيف بدل الحذف |

### HIGH

| # | العيب | الملف:السطر | التأثير |
|---|-------|-------------|---------|
| H1 | **لا يوجد cleanup لبيانات المبيعات** — DB تتراكم بدون حد. ~365K سطر/سنة (sale_items) | `packages/alhai_database/lib/src/daos/sales_dao.dart` — لا يوجد method | أداء يتدهور تدريجياً + فشل تخزين محتمل بعد 2-3 سنوات |
| H2 | **لا يوجد مراقبة مساحة التخزين** — لا تنبيه قبل امتلاء القرص | `apps/cashier/` — غير موجود | فقدان فواتير إذا امتلأ التخزين أثناء البيع |
| H3 | **بوابات الدفع الإلكتروني محاكاة فقط** — مدى/STC Pay/تمارا كلها simulated. في kReleaseMode تُرفض | `packages/alhai_pos/lib/src/services/payment/payment_gateway.dart:334-701` | لا يمكن قبول دفع إلكتروني في الإنتاج. يحتاج تكامل Nearpay SDK أو بديل |
| H4 | **الإرجاع الجزئي لا يستعيد المخزون** — `createReturn()` يُنشئ سجل مرتجع لكن لا يستدعي `inventoryDao` لاستعادة الكميات | `packages/alhai_pos/lib/src/providers/returns_providers.dart:56-110` | خسارة مخزون صامتة عند الإرجاع الجزئي |

### MEDIUM

| # | العيب | الملف:السطر | التأثير |
|---|-------|-------------|---------|
| M1 | **60+ نص عربي متصلّب في خدمات الطباعة** — labels الفاتورة وأسماء طرق الدفع ورسائل الخطأ | `receipt_builder.dart` (30+) + `sunmi_print_service.dart` (30+) + `receipt_pdf_generator.dart` (15+) | يمنع التوسع للأسواق الـ7 (أوردو، إندونيسي، إلخ) |
| M2 | **خصم المخزون يحدث قبل تأكيد الدفع** — المخزون يُخصم داخل transaction البيع حتى لو فشل الدفع لاحقاً | `sale_service.dart:307-335` | race condition نظري: مخزون يُحجز لعمليات بيع لم تكتمل |
| M3 | **لا يوجد حقل رقم مرجعي لطرفية الدفع** — عند الدفع بالبطاقة يدوياً، لا يوجد مكان لإدخال approval code | `sales_table` — لا يوجد terminal_reference_id | صعوبة المطابقة مع كشف البنك |
| M4 | **لا يوجد validation أن مجموع الدفع المقسّم = الفاتورة** | `payment_screen.dart` | احتمال تسجيل مبالغ غير متطابقة |
| M5 | **منتج بسعر صفر يُباع بدون تحذير** | `cart_providers.dart:659` | تسرب بيع بدون قيمة |
| M6 | **لا يوجد performance benchmark** — لا اختبار أداء مخصص للبحث أو إتمام البيع | `packages/alhai_pos/test/` | لا يمكن التحقق من أهداف الأداء (200ms بحث، 1s إتمام) |

### LOW

| # | العيب | الملف:السطر | التأثير |
|---|-------|-------------|---------|
| L1 | لا يوجد خصم نسبة مئوية مباشر في السلة (مبلغ ثابت فقط) | `cart_providers.dart:678-683` | UX limitation طفيفة |
| L2 | ~15 رسالة خطأ طباعة عربية متصلّبة | `bluetooth_print_service.dart` + `network_print_service_impl.dart` + `sunmi_print_service.dart` | minor i18n gap |
| L3 | لا يوجد PDF لتقرير نهاية الوردية | `apps/cashier/lib/screens/shifts/` | أرشفة يدوية فقط |
| L4 | HeldInvoice ID يستخدم milliseconds بدل UUID | `cart_providers.dart:722` | احتمال تصادم نظري |
| L5 | 10 info-level lint issues (curly braces style) | `apps/cashier/lib/` | تجميلي |
| L6 | لا يوجد شاشة audit log في الكاشير | `apps/cashier/lib/screens/` | المدير يحتاج الرجوع لتطبيق admin |
| L7 | رسائل الخطأ لا تُرشد للخطوة التالية | متعدد | UX improvement |

---

## 4. الاختبارات التي شُغّلت

### packages/alhai_pos/ — 559 اختبار ✅ كلها ناجحة

```
flutter test packages/alhai_pos/ --reporter compact
+559: All tests passed!
```

**التوزيع:**
- 18 screen test (pos_screen, payment_screen, cart_panel, returns, refund, etc.)
- 6 provider test (cart, customer_display, favorites, held_invoices, returns, online_orders)
- 15 service test (sale_service, invoice_service, payment_gateway, receipt_pdf, whatsapp, zatca, NFC, etc.)
- 1 model test (online_order)
- 1 refund_prevention test

### apps/cashier/ — 621 اختبار ✅ كلها ناجحة

```
flutter test apps/cashier/ --reporter compact
+621: All tests passed!
```

**التوزيع:**
- 1 DI injection test
- 1 router test
- 44 screen tests (customers, inventory, offers, payment, products, purchases, reports, sales, settings, shifts)
- 11 service tests (audit, backup, clock_validation, connectivity, offline_queue, printing ×4, sentry)
- 1 UI test (cashier_shell)
- 6 unit tests (cart, payment, stock, vat, zatca_tlv)
- 1 shift cash formula test

### flutter analyze — 10 info-level issues فقط

```
flutter analyze apps/cashier/ --no-fatal-infos
10 issues found. (all info-level: curly_braces_in_flow_control_structures)
```

---

## 5. الأكواد التي فُحصت يدوياً

| الملف | الأسطر المفحوصة | الغرض |
|-------|-----------------|-------|
| `packages/alhai_pos/lib/src/providers/cart_providers.dart` | 1-827 (كامل) | سلوك السلة، validation، persistence، undo |
| `packages/alhai_pos/lib/src/services/sale_service.dart` | 1-761 (كامل) | atomicity، price correction، sync، debt recording |
| `packages/alhai_pos/lib/src/providers/returns_providers.dart` | 1-110 (كامل) | إنشاء مرتجع، sync queue، inventory gap |
| `packages/alhai_pos/lib/src/screens/pos/payment_screen.dart` | 1-100+ (header + structure) | طرق الدفع، change calculation |
| `packages/alhai_database/lib/src/daos/sales_dao.dart` | 1-812 (كامل) | append-only، void، pagination، cache |
| `packages/alhai_database/lib/src/daos/shifts_dao.dart` | 1-171 (كامل) | open/close shift، cash movements |
| `packages/alhai_database/lib/src/tables/returns_table.dart` | 1-79 (كامل) | FK constraints، schema |
| `apps/cashier/lib/services/printing/receipt_builder.dart` | 1-288 (كامل) | ESC/POS receipt format، hardcoded strings |
| `apps/cashier/lib/services/printing/sunmi_print_service.dart` | 1-412 (كامل) | Sunmi platform channel، receipt printing |
| `packages/alhai_pos/lib/src/services/receipt_pdf_generator.dart` | 1-469 (كامل) | PDF generation، ZATCA QR، Arabic fonts |
| `packages/alhai_pos/lib/src/services/payment/payment_gateway.dart` | 1-862 (كامل) | Cash/Mada/STC/Tamara gateways، simulation status |
| `packages/alhai_pos/lib/src/services/manager_approval_service.dart` | 1-195 (كامل) | protected actions، PIN verification |
| `apps/cashier/lib/core/services/audit_service.dart` | 1-363 (كامل) | centralized audit logging |
| `apps/cashier/lib/core/services/connectivity_service.dart` | 1-167 (كامل) | connectivity detection، auto-sync |
| `apps/cashier/lib/main.dart` | 1-389 (كامل) | initialization، security، DI، session recovery |
| `apps/cashier/lib/screens/shifts/shift_close_screen.dart` | 1-100 (header) | denomination counter، expected vs actual |
| `packages/alhai_pos/lib/src/screens/returns/returns_screen.dart` | 1-80 (header) | return model، screen structure |

---

## 6. ما لم يُمكن اختباره

| البند | السبب | توصية الاختبار اللاحق |
|-------|-------|----------------------|
| **طباعة فعلية** | لا توجد طابعة حرارية فيزيائية | اختبار مع Sunmi V2/P2 + Xprinter 80mm Bluetooth. تحقق من RTL واتساق القالب |
| **Mada terminal** | لا يوجد SDK مُدمج (محاكاة فقط) | تكامل Nearpay SDK ثم اختبار مع بطاقة مدى حقيقية |
| **STC Pay / Tamara** | محاكاة فقط | تكامل SDKs ثم اختبار sandbox |
| **50 فاتورة offline** | يتطلب جهاز فيزيائي بدون إنترنت | اختبار يدوي: فصل WiFi → بيع 50 فاتورة → إعادة الاتصال → تحقق من المزامنة |
| **أداء 50K منتج** | يتطلب seed data كبيرة | seed 50K منتج → قياس FTS5 search latency. الهدف: < 200ms |
| **سرعة فتح التطبيق** | يتطلب جهاز حقيقي (APK أو web deploy) | قياس cold start على جهاز Android متوسط. الهدف: < 3 ثوانٍ |
| **حجم PDF** | يتطلب فاتورة بـ 20+ منتج | توليد PDF مع 30 منتج → تحقق < 200KB |
| **تصادم HeldInvoice ID** | نظري (milliseconds) | اختبار بـ parallel holdInvoice calls |
| **امتلاء التخزين** | يتطلب ملء القرص فعلياً | محاكاة بتقليل quota → تحقق من سلوك التطبيق |

---

## 7. التوصية النهائية

### 🟡 مقبول مع تحفّظات

**المبررات:**

**نقاط القوة:**
- 1,180 اختبار ناجح (559 + 621) مع تغطية شاملة
- عملية البيع atomic بالكامل مع حماية append-only
- نظام offline-first متين (sync queue + retry + circuit breaker + dead-letter alerts)
- إدارة ورديات كاملة مع denomination counter ومقارنة الرصيد
- صلاحيات محمية بـ PIN مع PBKDF2 + lockout
- 41 شاشة مع responsive design وdark/light theme

**شروط الانتقال للمرحلة 4:**

1. **[CRITICAL — يجب إصلاحه قبل الانتقال]** تعطيل أو إزالة `cleanupOldLogs()` في audit_log_dao. السجلات يجب أن تبقى دائمة. بديل مقبول: أرشفة (نقل لجدول archive) بدل الحذف
2. **[HIGH — يجب وضع خطة قبل الإطلاق]** إضافة استرجاع المخزون في `createReturn()` (returns_providers.dart)
3. **[HIGH — يجب وضع خطة قبل الإطلاق]** إضافة آلية مراقبة مساحة التخزين مع تنبيه عند 90%+ استخدام
4. **[HIGH — خارطة طريق مطلوبة]** وضع خطة لتكامل بوابات الدفع الإلكتروني (Nearpay SDK أو بديل) مع جدول زمني
5. **[MEDIUM — قبل إطلاق الأسواق الـ7]** نقل النصوص العربية المتصلّبة في ملفات الطباعة إلى l10n

**التصنيف:** الكاشير جاهز للاستخدام الداخلي/التجريبي (soft launch) مع السوق السعودي والدفع النقدي فقط. يحتاج إصلاح C1 قبل أي deployment إنتاجي.

---

*تم التوقيع رقمياً بواسطة Claude Opus 4.6 — POS Industrial Auditor*
*التاريخ: 2026-04-14*
