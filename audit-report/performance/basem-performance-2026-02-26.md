# تقرير تدقيق الأداء الشامل - منصة الحي (Alhai Platform)

**التاريخ:** 2026-02-26
**المدقق:** Basem
**النسخة:** تدقيق شامل لجميع الحزم والتطبيقات
**عدد الملفات المفحوصة:** ~1,210 ملف Dart (بدون الملفات المولدة)
**إجمالي أسطر الكود:** ~33,036 سطر (بدون `.g.dart` و `.freezed.dart`)

---

## ملخص تنفيذي

منصة الحي هي مشروع Flutter متعدد التطبيقات (Monorepo) يشمل تطبيقات: Cashier، Admin، Admin Lite، Customer، Distributor Portal، Driver، و Super Admin. يعتمد المشروع على بنية حزم مشتركة (`alhai_core`, `alhai_design_system`, `alhai_services`, `alhai_database`, `alhai_pos`, `alhai_shared_ui`, `alhai_auth`, `alhai_ai`, `alhai_reports`, `alhai_sync`, `alhai_l10n`).

بشكل عام، المشروع يُظهر مستوى **جيد** من الوعي بالأداء مع وجود أنماط محسّنة مثل: FTS للبحث السريع، Pagination في DAOs، استخدام `CachedNetworkImage` في الأماكن الحرجة، و `keepAlive` مع cache في Riverpod providers. لكن توجد فجوات ملموسة في عدة مجالات تحتاج معالجة.

### التقييم العام: 6.5 / 10

---

## جدول ملخص بالأرقام

| المعيار | الحالة | عدد المشاكل | التقييم |
|---------|--------|-------------|---------|
| حجم البناء (Build Size) | يحتاج تحسين | 4 | 5/10 |
| وقت البدء (Startup) | جيد | 2 | 7/10 |
| إدارة الذاكرة | جيد مع استثناءات | 3 | 7/10 |
| التحميل الكسول (Lazy Loading) | ضعيف | 3 | 3/10 |
| استراتيجيات التخزين المؤقت | جيد | 2 | 7/10 |
| تحسين الصور | يحتاج تحسين | 3 | 4/10 |
| Pagination | ممتاز في DAO، ضعيف في UI | 2 | 6/10 |
| أداء القوائم | متوسط | 4 | 5/10 |
| تحسين إعادة البناء (Widget Rebuild) | متوسط | 3 | 5/10 |
| كفاءة إدارة الحالة | جيد | 2 | 7/10 |
| تحسين الاستعلامات | ممتاز | 1 | 8/10 |
| تحسين طلبات الشبكة | يحتاج تحسين | 3 | 5/10 |
| تحميل الموارد | جيد | 1 | 7/10 |
| أداء الويب | متوسط | 3 | 5/10 |
| تسربات الذاكرة | جيد | 2 | 7/10 |

### ملخص التصنيفات

| التصنيف | العدد |
|---------|-------|
| حرج | 5 |
| متوسط | 18 |
| منخفض | 15 |
| **المجموع** | **38** |

---

## النتائج التفصيلية

---

### 1. حجم البناء (Build Size Considerations)

#### 1.1 عدم استخدام Deferred Loading (التحميل المؤجل)

**التصنيف:** متوسط

**التفاصيل:** لم يتم العثور على أي استخدام لـ `deferred as` في أي ملف من ملفات المشروع. هذا يعني أن جميع الشاشات والمكتبات يتم تحميلها مقدماً عند بناء التطبيق، مما يزيد من حجم الحزمة الأولية خاصة على الويب.

**الملفات المتأثرة:** جميع ملفات الـ Router:
- `apps/cashier/lib/router/cashier_router.dart` (سطر 1-65): يستورد 45+ شاشة مباشرة
- `apps/admin/lib/router/admin_router.dart`: يستورد جميع شاشات الإدارة مباشرة
- `apps/admin_lite/lib/router/lite_router.dart`: نفس النمط

**التأثير:** على الويب، يتم تحميل كل الكود دفعة واحدة بدلاً من تحميل الشاشات عند الحاجة فقط.

#### 1.2 استيرادات غير محددة (Barrel Imports)

**التصنيف:** منخفض

**التفاصيل:** استخدام استيرادات شاملة مثل `import 'package:alhai_shared_ui/alhai_shared_ui.dart'` و `import 'package:alhai_core/alhai_core.dart'` بدون تحديد ما يُستورد بـ `show`.

**الملفات المتأثرة:**
- `apps/cashier/lib/main.dart` (سطر 9): `import 'package:alhai_shared_ui/alhai_shared_ui.dart'`
- `apps/admin_lite/lib/main.dart` (سطر 9): نفس النمط
- `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart` (سطر 10): `import 'package:alhai_shared_ui/alhai_shared_ui.dart'`

**الملاحظة:** `apps/admin/lib/main.dart` (سطر 9) يستخدم النمط الصحيح: `import 'package:alhai_shared_ui/alhai_shared_ui.dart' show AppTheme, ThemeNotifier, ThemeState` -- وهذا مثال جيد يجب تعميمه.

#### 1.3 `--no-tree-shake-icons` مطلوب

**التصنيف:** منخفض

**التفاصيل:** وفقاً لملاحظات المشروع في MEMORY.md، أمر البناء يتطلب `flutter build web --no-tree-shake-icons`، مما يعني أن جميع أيقونات Material يتم تضمينها في البناء (~400KB إضافية). CI في `.github/workflows/flutter_ci.yml` (سطر 137) لا يتضمن هذا العلم: `flutter build web --release`.

#### 1.4 `prefer_const_constructors` معطّل

**التصنيف:** منخفض

**التفاصيل:** في `alhai_core/analysis_options.yaml` (سطر 21) و `alhai_design_system/analysis_options.yaml` (سطر 12): `prefer_const_constructors: false`. هذا يؤدي لعدم إنشاء widget instances ثابتة مما يزيد من إعادة البناء.

---

### 2. وقت البدء (Startup Time Optimization)

#### 2.1 تهيئة متسلسلة بدون توازي

**التصنيف:** متوسط

**التفاصيل:** في `apps/cashier/lib/main.dart` (سطور 19-82)، يتم تنفيذ عدة عمليات تهيئة بشكل **متسلسل** بينما يمكن تنفيذ بعضها بالتوازي:

```dart
// سطر 23-33: Firebase init (متسلسل)
await Firebase.initializeApp();

// سطر 36-54: Supabase init (متسلسل)
await Supabase.initialize(...);

// سطر 57-58: DB encryption key (متسلسل)
final dbKey = await _getOrCreateDbKey();

// سطر 61: DI (متسلسل)
await configureDependencies();

// سطر 64: Database seeding (متسلسل)
await _seedDatabaseFromCsv();

// سطر 67-68: Theme loading (متسلسل)
final prefs = await SharedPreferences.getInstance();
```

**التأثير:** يمكن تقليل وقت البدء ~30-40% بتشغيل Firebase و Supabase و SharedPreferences بالتوازي.

**نفس النمط في:**
- `apps/admin/lib/main.dart` (سطور 24-84)
- `apps/admin_lite/lib/main.dart` (سطور 18-78)

#### 2.2 Splash Screen - تهيئة FTS على الخيط الرئيسي

**التصنيف:** منخفض

**التفاصيل:** في `packages/alhai_auth/lib/src/screens/splash_screen.dart` (سطور 44-52):

```dart
// سطر 46: FTS initialization
await _initializeFts();

// سطر 50: Database seeding
await _seedDatabaseIfNeeded();
```

عمليات FTS و Database Seeding تعمل على الخيط الرئيسي. لا يوجد استخدام لـ `Isolate.run()` أو `compute()` في أي مكان بالمشروع.

---

### 3. أنماط إدارة الذاكرة (Memory Usage Patterns)

#### 3.1 أنماط Dispose - جيدة بشكل عام

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** تم العثور على 631 استدعاء لـ `dispose()` في 165 ملف، مما يدل على وعي جيد بتنظيف الموارد.

**أمثلة جيدة:**
- `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart` (سطور 57-60):
```dart
@override
void dispose() {
  _searchFocusNode.dispose();
  _keyboardFocusNode.dispose();
  super.dispose();
}
```

- `packages/alhai_shared_ui/lib/src/providers/sync_providers.dart` (سطور 24, 90, 105, 143, 160, 181): جميع الـ providers تستخدم `ref.onDispose()` بشكل صحيح.

#### 3.2 ScreenPreloader - Cache ثابت بدون حدود

**التصنيف:** متوسط

**التفاصيل:** في `packages/alhai_shared_ui/lib/src/widgets/common/lazy_screen.dart` (سطور 219-263):

```dart
class ScreenPreloader {
  static final Map<String, Widget> _cache = {};  // سطر 220 - بدون حد أقصى!
  static final Set<String> _loading = {};
```

الـ cache ثابت (static) ولا يحتوي على حد أقصى للحجم ولا سياسة إخلاء (eviction policy). مع ذلك، `ScreenPreloader.preload` و `ScreenPreloader.get` لم يتم استدعاؤهما فعلياً في أي مكان بالمشروع -- هذا كود ميت.

#### 3.3 Future.delayed بدون إلغاء

**التصنيف:** منخفض

**التفاصيل:** في `packages/alhai_shared_ui/lib/src/providers/products_providers.dart` (سطور 214-217):

```dart
final _ = Future.delayed(const Duration(minutes: 5), () {
  link.close();
});
```

هذا الـ `Future.delayed` لا يمكن إلغاؤه. إذا تم التخلص من الـ provider قبل 5 دقائق، سيستمر الـ Future في العمل.

---

### 4. التحميل الكسول (Lazy Loading)

#### 4.1 LazyScreen موجود لكن غير مستخدم في الـ Routers

**التصنيف:** حرج

**التفاصيل:** المشروع يحتوي على نظام `LazyScreen` متكامل في `packages/alhai_shared_ui/lib/src/widgets/common/lazy_screen.dart` مع:
- `LazyScreen` widget
- `ScreenPreloader` للتحميل المسبق
- `LazyRouteHelper` لدمج سهل مع GoRouter
- شاشات تحميل مخصصة: `PosLoadingScreen`, `ReportsLoadingScreen`, `ProductsLoadingScreen`, `InventoryLoadingScreen`, `CustomersLoadingScreen`, `SuppliersLoadingScreen`

**لكن:** لا يتم استخدام أي منها في ملفات الـ Router:
- `apps/cashier/lib/router/cashier_router.dart`: جميع الشاشات (~80 route) يتم تحميلها مباشرة بـ `const Widget()`
- `apps/admin/lib/router/admin_router.dart`: نفس النمط
- `apps/admin_lite/lib/router/lite_router.dart`: نفس النمط

**التأثير:** فقدان كامل لمزايا التحميل عند الطلب. كل شاشة يتم تخصيص ذاكرتها عند بناء الـ Router.

#### 4.2 عدم استخدام Code Splitting على الويب

**التصنيف:** حرج

**التفاصيل:** لا يوجد أي استخدام لـ:
- `deferred as` في أي ملف Dart
- `deferred loading` في GoRouter
- Code splitting strategies

**التأثير المقدر:** حجم JavaScript bundle واحد كبير بدلاً من chunks صغيرة. على اتصال 3G، قد يستغرق التحميل الأولي 5-10 ثوانٍ إضافية.

#### 4.3 جميع الشاشات (~100+) يتم تسجيلها كـ routes مقدماً

**التصنيف:** متوسط

**التفاصيل:** في `apps/cashier/lib/router/cashier_router.dart` يوجد ~80 route مسجلة مسبقاً. بالنسبة لتطبيق Cashier الذي يستخدم بشكل رئيسي شاشة POS، هذا يعني تحميل imports لـ 70+ شاشة نادراً ما تُستخدم.

---

### 5. استراتيجيات التخزين المؤقت (Caching Strategies)

#### 5.1 استخدام جيد لـ keepAlive في Riverpod

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** `packages/alhai_shared_ui/lib/src/providers/products_providers.dart` (سطور 208-217):

```dart
final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final link = ref.keepAlive();
  final _ = Future.delayed(const Duration(minutes: 5), () {
    link.close();
  });
```

هذا نمط جيد لتخزين مؤقت بوقت محدد (5 دقائق).

#### 5.2 عدم وجود HTTP Response Caching

**التصنيف:** متوسط

**التفاصيل:** لم يتم العثور على أي استخدام لـ:
- `dio_cache_interceptor` أو أي HTTP cache interceptor
- `ETag` أو `If-Modified-Since` headers
- `Cache-Control` handling

**الملفات المفحوصة:**
- `packages/alhai_sync/lib/src/sync_api_service.dart`
- `alhai_services/lib/src/services/` -- جميع الخدمات

#### 5.3 عدم وجود LRU Cache للبيانات المتكررة

**التصنيف:** متوسط

**التفاصيل:** لا يوجد استخدام لأي نمط LRU Cache (مثل `lru_map` package). الـ `productsMapProvider` في `products_providers.dart` (سطر 187-189) يبني Map جديد كلما تغيرت القائمة:

```dart
final productsMapProvider = Provider<Map<String, Product>>((ref) {
  final products = ref.watch(productsListProvider);
  return {for (final p in products) p.id: p};
});
```

هذا تصميم O(1) للبحث وهو جيد، لكن يُعاد بناؤه مع كل تغيير في قائمة المنتجات.

---

### 6. تحسين الصور (Image Optimization)

#### 6.1 استخدام `Image.network` بدون تخزين مؤقت في 7 ملفات

**التصنيف:** حرج

**التفاصيل:** تم العثور على 9 استخدامات لـ `Image.network()` بدون `CachedNetworkImage` في الملفات التالية:

| الملف | السطر |
|-------|-------|
| `apps/cashier/lib/screens/settings/store_info_screen.dart` | 172 |
| `apps/admin/lib/screens/ecommerce/ecommerce_screen.dart` | 335 |
| `packages/alhai_shared_ui/lib/src/widgets/layout/app_sidebar.dart` | 350, 386 |
| `packages/alhai_shared_ui/lib/src/widgets/dashboard/top_selling_list.dart` | 146 |
| `packages/alhai_shared_ui/lib/src/screens/products/products_screen.dart` | 867, 1050 |
| `packages/alhai_shared_ui/lib/src/widgets/common/app_card.dart` | 357 |
| `apps/admin/lib/screens/media/media_library_screen.dart` | 391 |

**بينما** تم استخدام `CachedNetworkImage` بشكل صحيح في:
- `alhai_design_system/lib/src/components/images/product_image.dart` (سطر 75)
- `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart` (سطور 1244, 2203)
- `packages/alhai_auth/lib/src/widgets/branding/mascot_widget.dart` (سطر 227)

**التأثير:** صور المنتجات في `products_screen.dart` و `app_sidebar.dart` و `top_selling_list.dart` تُحمّل من الشبكة كل مرة بدون cache، مما يسبب وميض الصور وزيادة استهلاك البيانات.

#### 6.2 عدم استخدام `cacheWidth`/`cacheHeight` للصور

**التصنيف:** متوسط

**التفاصيل:** لم يتم العثور على أي استخدام لـ `cacheWidth` أو `cacheHeight` أو `filterQuality` في جميع ملفات المشروع. هذا يعني أن الصور تُحمّل بدقتها الكاملة حتى لو عُرضت بحجم صغير (مثل thumbnails 48x48 بكسل).

**مثال:** `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart` (سطور 1244-1255):
```dart
CachedNetworkImage(
  imageUrl: product.imageThumbnail!,
  fit: BoxFit.cover,
  // لا يوجد cacheWidth أو cacheHeight
)
```

#### 6.3 عدم استخدام WebP أو تحسين الصور على مستوى الخادم

**التصنيف:** منخفض

**التفاصيل:** لا يوجد أي تحويل للصور إلى WebP أو استخدام Supabase Image Transform لتحسين حجم الصور المحملة.

---

### 7. Pagination Implementation

#### 7.1 Pagination ممتاز على مستوى الـ DAO

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** تم تنفيذ pagination بشكل ممتاز في:

- `packages/alhai_database/lib/src/daos/products_dao.dart` (سطور 171-236):
  - `getProductsPaginated()` مع `offset` و `limit`
  - `getProductsCount()` للعدد الكلي
  - `searchProductsPaginated()` للبحث مع pagination

- `packages/alhai_database/lib/src/daos/sales_dao.dart` (سطور 191-253):
  - `getSalesPaginated()` مع فلاتر متعددة
  - `getSalesCount()` مع نفس الفلاتر

#### 7.2 getAllSales و getAllProducts بدون حدود

**التصنيف:** متوسط

**التفاصيل:** لا تزال توجد methods تُحمّل جميع البيانات بدون حدود:

- `products_dao.dart` (سطر 21-26): `getAllProducts()` -- يُحمّل **جميع** المنتجات
- `sales_dao.dart` (سطر 14-18): `getAllSales()` -- يُحمّل **جميع** المبيعات
- `products_dao.dart` (سطور 42-67): `searchProducts()` -- بحث بدون limit

**التأثير:** مع نمو البيانات (آلاف المنتجات/المبيعات)، هذه الاستعلامات ستسبب بطئاً ملحوظاً.

---

### 8. أداء القوائم (List Performance)

#### 8.1 استخدام `ListView()` بدون `.builder` في 37 ملف

**التصنيف:** حرج

**التفاصيل:** تم العثور على 37 ملف يستخدم `ListView()` مباشرة بدلاً من `ListView.builder()`. الـ `ListView()` العادي يبني **جميع** العناصر مرة واحدة بينما `.builder()` يبني فقط ما هو مرئي.

**أبرز الملفات المتأثرة (بيانات ديناميكية):**

| الملف | السطر | السياق |
|-------|-------|--------|
| `packages/alhai_shared_ui/lib/src/screens/customers/customers_screen.dart` | 346 | قائمة العملاء |
| `packages/alhai_shared_ui/lib/src/screens/suppliers/suppliers_screen.dart` | 373 | قائمة الموردين |
| `packages/alhai_shared_ui/lib/src/screens/inventory/inventory_screen.dart` | 277 | قائمة المخزون |
| `packages/alhai_shared_ui/lib/src/screens/orders/order_history_screen.dart` | 494 | سجل الطلبات |
| `packages/alhai_reports/lib/src/screens/reports/customer_report_screen.dart` | 227, 733, 1012 | تقارير العملاء (3 مواقع!) |
| `packages/alhai_reports/lib/src/screens/reports/top_products_report_screen.dart` | 540, 661 | تقرير أفضل المنتجات (موقعان) |
| `packages/alhai_reports/lib/src/screens/reports/profit_report_screen.dart` | 264 | تقرير الأرباح |
| `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart` | 1007 | قائمة التصنيفات |
| `apps/admin/lib/screens/ecommerce/online_orders_screen.dart` | 195 | الطلبات الإلكترونية |
| `apps/admin/lib/screens/management/branch_management_screen.dart` | 276 | إدارة الفروع |
| `apps/admin/lib/screens/management/driver_management_screen.dart` | 321 | إدارة السائقين |

**التأثير:** استهلاك ذاكرة مرتفع وتأخير في عرض الشاشة عندما تحتوي القوائم على عدد كبير من العناصر.

**ملاحظة إيجابية:** العديد من الشاشات الأخرى تستخدم `ListView.builder()` بشكل صحيح (55 استخدام في 49 ملف).

#### 8.2 استخدام `GridView.count` بدون `.builder` في 5 ملفات

**التصنيف:** متوسط

**التفاصيل:**

| الملف | السطر |
|-------|-------|
| `distributor_portal/lib/screens/dashboard/distributor_dashboard_screen.dart` | 46 |
| `packages/alhai_shared_ui/lib/src/widgets/dashboard/quick_actions_panel.dart` | 94 |
| `apps/admin/lib/screens/subscription/subscription_screen.dart` | 178 |
| `packages/alhai_shared_ui/lib/src/screens/orders/orders_screen.dart` | 404 |
| `apps/admin/lib/screens/employees/employee_profile_screen.dart` | 450 |

#### 8.3 عدم استخدام `RepaintBoundary`

**التصنيف:** منخفض

**التفاصيل:** لم يتم العثور على أي استخدام لـ `RepaintBoundary` في المشروع. في الشاشات المعقدة مثل POS (2,677 سطر) و Payment (1,853 سطر)، يمكن أن يقلل `RepaintBoundary` من عمليات إعادة الرسم غير الضرورية.

#### 8.4 عدم استخدام `AutomaticKeepAliveClientMixin`

**التصنيف:** منخفض

**التفاصيل:** لم يتم العثور على أي استخدام لـ `AutomaticKeepAliveClientMixin`. في التبويبات والقوائم المتعددة الصفحات، هذا يعني إعادة بناء المحتوى كل مرة عند التبديل بين التبويبات.

---

### 9. تحسين إعادة بناء الـ Widgets (Widget Rebuild Optimization)

#### 9.1 ملفات شاشات كبيرة جداً بدون تقسيم

**التصنيف:** حرج

**التفاصيل:** عدة ملفات شاشات تتجاوز 1,000 سطر مما يجعل تحسين إعادة البناء صعباً:

| الملف | عدد الأسطر |
|-------|-----------|
| `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart` | 2,677 |
| `packages/alhai_pos/lib/src/screens/pos/payment_screen.dart` | 1,853 |
| `packages/alhai_shared_ui/lib/src/screens/customers/customers_screen.dart` | 1,252 |
| `packages/alhai_shared_ui/lib/src/screens/products/products_screen.dart` | 1,152 |
| `packages/alhai_pos/lib/src/screens/pos/quick_sale_screen.dart` | 1,013 |

**التأثير:** عند استخدام `ref.watch()` في هذه الشاشات الكبيرة، أي تغيير في الحالة يعيد بناء الشجرة بالكامل. على سبيل المثال، في `pos_screen.dart`:
- سطر 278: `ref.watch(cartItemCountProvider)` -- تغيير عدد العناصر يعيد بناء كامل الشاشة
- سطر 580: `ref.watch(productsStateProvider)` -- تغيير حالة المنتجات يعيد بناء كل شيء
- سطر 1397: `ref.watch(cartStateProvider)` -- نفس المشكلة

#### 9.2 استخدام `ref.watch()` في الأماكن الخطأ

**التصنيف:** متوسط

**التفاصيل:** في `packages/alhai_pos/lib/src/screens/pos/pos_screen.dart`، يتم استخدام `ref.watch()` على مستوى build method الرئيسي لحالات يمكن أن تكون محدودة النطاق:

```dart
// سطر 580: يُعاد بناء كامل شبكة المنتجات عند أي تغيير في الحالة
final productsState = ref.watch(productsStateProvider);
final categoriesAsync = ref.watch(categoriesProvider);
```

**التوصية:** استخراج أجزاء الـ UI إلى widgets فرعية مع `Consumer` أو `ConsumerWidget` منفصلة.

#### 9.3 عدم استخدام `const` في Widgets الثابتة داخل Build Methods

**التصنيف:** منخفض

**التفاصيل:** مع تعطيل `prefer_const_constructors` في analysis_options، لا يوجد إنذار عند عدم استخدام `const` في widgets ثابتة. هذا يؤدي لإنشاء instances جديدة كل rebuild.

---

### 10. كفاءة إدارة الحالة (State Management Efficiency)

#### 10.1 استخدام جيد لـ autoDispose

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** معظم الـ FutureProviders تستخدم `.autoDispose` بشكل صحيح:
- `packages/alhai_shared_ui/lib/src/providers/dashboard_providers.dart` (سطر 78): `FutureProvider.autoDispose<DashboardData>`
- `packages/alhai_shared_ui/lib/src/providers/invoices_providers.dart` (سطور 47, 56, 67, 76, 87): جميعها `.autoDispose`
- `packages/alhai_shared_ui/lib/src/providers/orders_providers.dart` (سطور 30, 38, 48, 57, 66, 75, 83, 94): جميعها `.autoDispose`

#### 10.2 `productsMapProvider` -- O(1) Lookup ممتاز

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** في `products_providers.dart` (سطور 187-190):
```dart
final productsMapProvider = Provider<Map<String, Product>>((ref) {
  final products = ref.watch(productsListProvider);
  return {for (final p in products) p.id: p};
});
```

هذا تصميم ممتاز يوفر بحث O(1) بدلاً من O(n) عند البحث بالـ ID.

#### 10.3 lowStockProductsProvider يعيد الفلترة كل مرة

**التصنيف:** منخفض

**التفاصيل:** في `products_providers.dart` (سطور 193-196 و 199-202):
```dart
final lowStockProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsListProvider);
  return products.where((p) => p.isLowStock).toList();
});
```

كل تغيير في قائمة المنتجات يعيد فلترة وإنشاء قائمة جديدة. يمكن تحسين هذا باستخدام `select()` لتقليل إعادة البناء.

---

### 11. تحسين استعلامات قاعدة البيانات

#### 11.1 فهارس (Indexes) ممتازة

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** تم إنشاء فهارس شاملة في `packages/alhai_database/lib/src/app_database.g.dart` (سطور 34425-34560+):

- **Products:** 7 فهارس (`store_id`, `barcode`, `sku`, `category_id`, `name`, `synced_at`, `is_active`)
- **Sales:** 6 فهارس بما فيها composite index (`store_id, created_at`)
- **Orders:** 5 فهارس بما فيها composite (`store_id, status`)
- **Inventory Movements:** 6 فهارس بما فيها composite (`reference_type, reference_id`)
- **Sync Queue:** 4 فهارس بما فيها composite (`status, priority`)
- **Audit Log:** 5 فهارس بما فيها composite (`entity_type, entity_id`)
- **Categories, Loyalty, Transactions, Accounts:** جميعها مفهرسة

#### 11.2 FTS (Full Text Search) مُنفّذ

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** `packages/alhai_database/lib/src/daos/products_dao.dart` (سطور 14-97) يستخدم `ProductsFtsService` للبحث السريع مع fallback للبحث العادي:

```dart
Future<List<ProductsTableData>> searchProducts(String query, String storeId) async {
  try {
    if (await _ftsService.isFtsTableExists()) {
      final ftsResults = await _ftsService.search(query, storeId);
      ...
    }
  } catch (_) {
    // fallback to LIKE search
  }
}
```

#### 11.3 Batch Operations مطبقة

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** `products_dao.dart` (سطور 272-285):
```dart
Future<void> batchUpdateStock(Map<String, int> stockUpdates) async {
  await batch((b) {
    for (final entry in stockUpdates.entries) {
      b.update(...);
    }
  });
}
```

#### 11.4 استخدام `SELECT *` في raw queries

**التصنيف:** منخفض

**التفاصيل:** `products_dao.dart` (سطر 110):
```dart
'SELECT * FROM products WHERE store_id = ? AND stock_qty <= min_qty AND is_active = 1'
```

يمكن تحديد الأعمدة المطلوبة فقط لتقليل نقل البيانات.

---

### 12. تحسين طلبات الشبكة (Network Request Optimization)

#### 12.1 Debounce محدود -- فقط في البحث الفوري

**التصنيف:** متوسط

**التفاصيل:** تم العثور على debounce فقط في `packages/alhai_pos/lib/src/widgets/pos/instant_search.dart` (سطور 30, 47, 64-65):

```dart
final Duration debounceDuration; // سطر 30
Timer? _debounceTimer; // سطر 47

void _onChanged(String value) {
  _debounceTimer?.cancel();
  _debounceTimer = Timer(widget.debounceDuration, () { ... });
}
```

**لكن** لا يوجد debounce في:
- البحث في شاشات العملاء
- البحث في شاشات الموردين
- البحث في شاشات المخزون
- فلترة التقارير

#### 12.2 عدم وجود Request Batching

**التصنيف:** منخفض

**التفاصيل:** لا يوجد نمط لتجميع الطلبات المتعددة في طلب واحد (request batching/GraphQL-style). كل provider يرسل طلباً مستقلاً.

#### 12.3 عدم وجود Retry Strategy على مستوى HTTP

**التصنيف:** متوسط

**التفاصيل:** لم يتم العثور على retry interceptor أو exponential backoff على مستوى HTTP client. المزامنة في `alhai_sync` تحتوي على retry logic لكن الطلبات العادية لا.

---

### 13. تحميل الموارد (Asset Loading)

#### 13.1 خطوط Tajawal مضمنة محلياً (جيد)

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** في `alhai_design_system/pubspec.yaml` (سطور 27-38)، الخطوط محملة من الأصول المحلية:
```yaml
fonts:
  - family: Tajawal
    fonts:
      - asset: assets/fonts/Tajawal-Regular.ttf
      - asset: assets/fonts/Tajawal-Medium.ttf
      - asset: assets/fonts/Tajawal-Bold.ttf
      - asset: assets/fonts/Tajawal-Light.ttf
```

لا يتم استخدام `google_fonts` (مُعلّق في السطر 17) مما يجنب تحميل الخطوط من الشبكة.

#### 13.2 تحميل CSV في البدء

**التصنيف:** منخفض

**التفاصيل:** في `apps/cashier/lib/main.dart` (سطور 103-123)، يتم تحميل بيانات CSV عند أول تشغيل فقط:
```dart
if (await seeder.isDatabaseEmpty()) {
  final categoriesCsv = await rootBundle.loadString('assets/data/categories.csv');
  final productsCsv = await rootBundle.loadString('assets/data/products.csv');
  await seeder.seedFromCsv(...);
}
```

هذا نمط جيد -- يتحقق من أن قاعدة البيانات فارغة قبل التحميل.

---

### 14. أداء الويب (Web-Specific Performance)

#### 14.1 WASM مُنفّذ لـ SQLite

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** في `packages/alhai_database/lib/src/connection.dart` (سطور 20-37):
```dart
if (kIsWeb) {
  return driftDatabase(
    name: dbName ?? 'pos_database',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.dart.js'),
    ),
  );
}
```

استخدام WASM لـ SQLite على الويب مع drift_worker هو أفضل ممارسة.

#### 14.2 عدم وجود Deferred Loading للويب

**التصنيف:** حرج (مكرر مع 4.2)

**التفاصيل:** كما ذُكر سابقاً، لا يوجد أي code splitting. على الويب، هذا حرج لأن كل الكود يُحمّل في ملف JavaScript واحد.

#### 14.3 عدم وجود Service Worker أو PWA Caching

**التصنيف:** متوسط

**التفاصيل:** CI يبني للويب (`flutter build web --release`) لكن لا يوجد دليل على تكوين Service Worker مخصص أو استراتيجية PWA caching.

#### 14.4 عدم استخدام Compute/Isolate للعمليات الثقيلة

**التصنيف:** متوسط

**التفاصيل:** لم يتم العثور على أي استخدام لـ `Isolate.run()` أو `compute()` في المشروع بالكامل. على الويب، هذا يعني أن العمليات الثقيلة (مثل تحليل CSV، بناء FTS index) تعمل على الخيط الرئيسي مما قد يسبب تجميد الواجهة.

---

### 15. أنماط تسرب الذاكرة (Memory Leak Patterns)

#### 15.1 StreamControllers و StreamSubscriptions -- مُدارة بشكل جيد

**التصنيف:** منخفض (إيجابي)

**التفاصيل:** في `packages/alhai_sync/`:
- `sync_engine.dart` (سطر 117): `_progressController = StreamController<SyncProgress>.broadcast()` -- يتم إغلاقه في `dispose()` (سطر 355)
- `sync_manager.dart` (سطر 47-48): `_statusController` و `_connectivitySubscription` -- يتم إلغاؤهما في `dispose()` (سطور 160-161)
- `offline_manager.dart` (سطر 106, 118, 240): جميع الـ subscriptions تُلغى في `dispose()`
- `connectivity_service.dart` (سطر 9-10, 55): `_controller` و `_subscription` -- تُنظف بشكل صحيح

#### 15.2 Timer في LoginScreen بدون تنظيف محتمل

**التصنيف:** منخفض

**التفاصيل:** في `packages/alhai_auth/lib/src/screens/login_screen.dart` (سطر 54):
```dart
_cooldownTimer = Timer.periodic(const Duration(seconds: 1), (_) { ... });
```

يتم إلغاؤه في dispose (مؤكد من grep results)، لكن:
- `Future.delayed` في السطور 225 و 258 لا يمكن إلغاؤها وقد تنفذ بعد dispose.

#### 15.3 كود ميت -- ScreenPreloader و LazyScreen غير مستخدمين

**التصنيف:** منخفض

**التفاصيل:** كامل ملف `lazy_screen.dart` (594 سطر) يحتوي على كود لم يُستخدم فعلياً:
- `ScreenPreloader` -- static cache بدون حدود -- كود ميت
- `LazyRouteHelper` -- helper غير مستخدم
- 6 شاشات تحميل مخصصة (`PosLoadingScreen`, `ReportsLoadingScreen`, etc.) -- كود ميت

---

## التوصيات مع أولوية التنفيذ

### أولوية عالية (تنفيذ فوري)

| # | التوصية | الأثر المتوقع | الجهد |
|---|---------|--------------|-------|
| 1 | **تفعيل LazyScreen في جميع الـ Routers** -- استخدام `LazyScreen(screenBuilder: () async => const Screen())` للشاشات غير الرئيسية | تقليل استخدام الذاكرة بنسبة ~40% | متوسط |
| 2 | **استبدال `Image.network` بـ `CachedNetworkImage` في 7 ملفات** | إزالة وميض الصور وتقليل استهلاك البيانات | منخفض |
| 3 | **تحويل `ListView()` إلى `ListView.builder()` في الشاشات ذات البيانات الديناميكية** (على الأقل: customers, suppliers, inventory, orders, reports) | تقليل استهلاك الذاكرة بشكل كبير | منخفض |
| 4 | **تقسيم PosScreen (2,677 سطر) إلى widgets فرعية** -- استخراج: ProductsGrid, CartPanel, CategoryBar, PaymentSection | تحسين selective rebuilds بنسبة ~60% | متوسط |

### أولوية متوسطة (خلال أسبوعين)

| # | التوصية | الأثر المتوقع | الجهد |
|---|---------|--------------|-------|
| 5 | **إضافة `cacheWidth`/`cacheHeight` لصور المنتجات** | تقليل استهلاك الذاكرة ~30% للصور | منخفض |
| 6 | **تنفيذ Deferred Loading على الويب** للشاشات الثانوية (AI, Reports, Settings) | تقليل حجم initial bundle بنسبة ~40% | عالي |
| 7 | **تشغيل Firebase + Supabase + SharedPreferences بالتوازي** في main.dart | تقليل وقت البدء ~30-40% | منخفض |
| 8 | **إضافة debounce لجميع حقول البحث** وليس فقط POS instant search | تقليل استعلامات قاعدة البيانات | منخفض |
| 9 | **إزالة `getAllProducts()` و `getAllSales()` بدون حدود** واستبدالها بنسخ paginated | منع بطء مع نمو البيانات | منخفض |
| 10 | **إضافة `RepaintBoundary` حول القوائم والمخططات** في الشاشات المعقدة | تقليل عمليات إعادة الرسم | منخفض |

### أولوية منخفضة (خلال شهر)

| # | التوصية | الأثر المتوقع | الجهد |
|---|---------|--------------|-------|
| 11 | تفعيل `prefer_const_constructors` في analysis_options | const widgets = أقل rebuilds | منخفض |
| 12 | استخدام `compute()` للعمليات الثقيلة (CSV parsing, FTS rebuild) | منع تجميد الواجهة | متوسط |
| 13 | تنفيذ HTTP response caching مع ETag | تقليل طلبات الشبكة | متوسط |
| 14 | إزالة الكود الميت (ScreenPreloader, 6 شاشات تحميل غير مستخدمة) | تنظيف الكود | منخفض |
| 15 | استخدام `show` في جميع الاستيرادات الشاملة | تحسين tree shaking | منخفض |
| 16 | إضافة `AutomaticKeepAliveClientMixin` للتبويبات | منع إعادة بناء التبويبات | منخفض |

---

## ملخص النقاط الإيجابية

المشروع يتضمن العديد من الممارسات الجيدة التي تستحق التنويه:

1. **فهارس قاعدة البيانات شاملة** -- 60+ فهرس على جميع الجداول الرئيسية بما فيها composite indexes
2. **FTS للبحث السريع** -- مع fallback تلقائي للبحث العادي
3. **Pagination على مستوى DAO** -- `getProductsPaginated()` و `getSalesPaginated()` مع فلاتر
4. **Batch operations** -- `batchUpdateStock()` لتحديث المخزون بكفاءة
5. **`autoDispose` في Riverpod** -- معظم الـ providers تنظف نفسها تلقائياً
6. **`keepAlive` مع timeout** -- التصنيفات تُحفظ 5 دقائق ثم تُحرر
7. **`productsMapProvider` -- O(1) lookup** بدلاً من O(n)
8. **خطوط محلية** -- Tajawal مضمنة بدلاً من Google Fonts
9. **Dispose سليم** -- 631 dispose في 165 ملف مع تنظيف صحيح
10. **WASM + Drift Worker** -- أفضل أداء لـ SQLite على الويب
11. **`withValues(alpha:)` بدلاً من `withOpacity()`** -- 0 استخدامات لـ `withOpacity` المكلفة
12. **Debounce في البحث الفوري POS** -- 300ms debounce
13. **تهيئة Theme قبل runApp** -- لا وميض عند بدء التطبيق
14. **Database seeding مشروط** -- `isDatabaseEmpty()` يمنع إعادة التحميل

---

## التقييم النهائي

| المجال | التقييم |
|--------|---------|
| هيكلة قاعدة البيانات | 8.5/10 |
| إدارة الحالة | 7/10 |
| أداء القوائم | 5/10 |
| التحميل الكسول | 3/10 |
| تحسين الصور | 4/10 |
| أداء الويب | 5/10 |
| إدارة الذاكرة | 7/10 |
| وقت البدء | 7/10 |
| **المتوسط العام** | **6.5/10** |

---

## الخلاصة

المشروع يمتلك أساساً قوياً في طبقة قاعدة البيانات وإدارة الحالة، مع فهارس شاملة و FTS و pagination. لكن طبقة الـ UI تحتاج تحسينات ملموسة خاصة في:

1. **التحميل الكسول** -- البنية التحتية موجودة (LazyScreen) لكن غير مفعّلة
2. **أداء القوائم** -- 37 ملف يستخدم `ListView()` بدلاً من `.builder()`
3. **تقسيم الشاشات الكبيرة** -- pos_screen.dart بـ 2,677 سطر يحتاج تفكيك عاجل
4. **الصور** -- 7 ملفات تستخدم `Image.network` بدون cache

**تنفيذ التوصيات الأربع ذات الأولوية العالية وحدها يمكن أن يرفع التقييم إلى ~8/10.**

---

*تم إعداد هذا التقرير بتاريخ 2026-02-26 -- تدقيق للقراءة فقط، لم يتم تعديل أي ملف.*
