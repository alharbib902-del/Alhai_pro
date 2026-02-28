# دليل المطور الشامل - منصة الهاي (Alhai Platform)

> هذا الدليل موجه للمطورين الجدد والحاليين. يغطي كل ما تحتاجه من إعداد البيئة حتى نشر التطبيق في الإنتاج.
>
> آخر تحديث: 2026-02-28

---

## فهرس المحتويات

1. [مقدمة](#1-مقدمة)
2. [خطوات إعداد البيئة من الصفر](#2-خطوات-إعداد-البيئة-من-الصفر)
3. [كيفية تشغيل كل تطبيق](#3-كيفية-تشغيل-كل-تطبيق)
4. [كيفية إضافة شاشة جديدة](#4-كيفية-إضافة-شاشة-جديدة)
5. [كيفية إضافة جدول جديد في Drift](#5-كيفية-إضافة-جدول-جديد-في-drift)
6. [كيفية إضافة خدمة جديدة](#6-كيفية-إضافة-خدمة-جديدة)
7. [كيفية إضافة ترجمة جديدة](#7-كيفية-إضافة-ترجمة-جديدة)
8. [أوامر melos المهمة](#8-أوامر-melos-المهمة)
9. [كيفية عمل Build للإنتاج](#9-كيفية-عمل-build-للإنتاج)
10. [قواعد الكود (Code Style)](#10-قواعد-الكود-code-style)
11. [كيفية كتابة الاختبارات](#11-كيفية-كتابة-الاختبارات)
12. [الأخطاء الشائعة وحلولها](#12-الأخطاء-الشائعة-وحلولها)
13. [قائمة المتغيرات البيئية (.env)](#13-قائمة-المتغيرات-البيئية-env)
14. [أوامر Drift / build_runner](#14-أوامر-drift--build_runner)
15. [نصائح وأفضل الممارسات](#15-نصائح-وأفضل-الممارسات)

---

## 1. مقدمة

### ما هي منصة الهاي؟

منصة الهاي هي نظام متكامل لإدارة نقاط البيع (POS) والمتاجر، مبني بتقنية Flutter مع معمارية Monorepo تُدار عبر أداة Melos. المنصة تتكون من عدة تطبيقات وحزم مشتركة تعمل معاً.

### التطبيقات

| التطبيق | الموقع | الوصف | المنصات |
|---------|--------|-------|---------|
| **Cashier** (الكاشير) | `apps/cashier/` | نقطة بيع احترافية للكاشير (100% offline) | Web, Android |
| **Admin** (لوحة الإدارة) | `apps/admin/` | نظام إدارة كامل (123+ شاشة) | Web, Android |
| **Admin Lite** (إدارة خفيفة) | `apps/admin_lite/` | مراقبة سريعة، موافقات، تقارير، ذكاء اصطناعي | Web, Android |
| **Customer App** (تطبيق العميل) | `customer_app/` | تطبيق العملاء للمتاجر | Android, iOS |
| **Driver App** (تطبيق السائق) | `driver_app/` | تطبيق التوصيل والسائقين | Android, iOS |
| **Super Admin** | `super_admin/` | لوحة إدارة المنصة الكاملة | Web فقط |
| **Distributor Portal** | `distributor_portal/` | بوابة الموزعين | Web فقط |

### الحزم المشتركة

| الحزمة | الموقع | الوصف |
|--------|--------|-------|
| **alhai_core** | `alhai_core/` | الطبقة الأساسية: Models, Repositories, DI, Networking |
| **alhai_services** | `alhai_services/` | طبقة منطق الأعمال (Business Logic Services) |
| **alhai_design_system** | `alhai_design_system/` | نظام التصميم: ألوان، خطوط، مكونات UI |
| **alhai_database** | `packages/alhai_database/` | قاعدة بيانات Drift المشتركة: 40+ جدول، 28+ DAO |
| **alhai_l10n** | `packages/alhai_l10n/` | الترجمة المشتركة (7 لغات) وإدارة اللغة |
| **alhai_auth** | `packages/alhai_auth/` | شاشات وخدمات المصادقة والأمان |
| **alhai_pos** | `packages/alhai_pos/` | شاشات نقطة البيع، السلة، المدفوعات، المرتجعات |
| **alhai_shared_ui** | `packages/alhai_shared_ui/` | ويدجتات مشتركة، تخطيط، شاشات عامة |
| **alhai_reports** | `packages/alhai_reports/` | شاشات التقارير والإحصائيات |
| **alhai_ai** | `packages/alhai_ai/` | ميزات الذكاء الاصطناعي |
| **alhai_sync** | `packages/alhai_sync/` | محرك المزامنة، إدارة الاتصال |

### التقنيات الأساسية

| التقنية | الإصدار | الاستخدام |
|---------|---------|-----------|
| Flutter SDK | `>=3.10.0` (مستقر: 3.27.4) | إطار العمل الأساسي |
| Dart SDK | `>=3.4.0 <4.0.0` | لغة البرمجة |
| Riverpod | `^2.4.9` | إدارة الحالة (State Management) |
| Drift | `^2.14.1` | قاعدة بيانات SQLite محلية |
| GoRouter | `^13.0.0` | التنقل (Routing) |
| GetIt | `^7.7.0` | حقن التبعيات (Dependency Injection) |
| Supabase | `^2.3.4` | الخادم الخلفي (Backend) |
| Firebase | `^3.8.0` | الإشعارات والتحليلات |
| Melos | `^6.2.0` | إدارة Monorepo |

---

## 2. خطوات إعداد البيئة من الصفر

### 2.1 تثبيت Flutter SDK

1. حمّل Flutter SDK من الموقع الرسمي:
   - Windows: https://docs.flutter.dev/get-started/install/windows
   - macOS: https://docs.flutter.dev/get-started/install/macos
   - Linux: https://docs.flutter.dev/get-started/install/linux

2. الإصدار المطلوب: **3.27.4** (القناة المستقرة - stable)

3. تحقق من التثبيت:
```bash
flutter --version
# يجب أن يظهر: Flutter 3.27.4 (أو أحدث)

flutter doctor
# تحقق من عدم وجود أخطاء
```

### 2.2 تثبيت Dart SDK

Dart SDK يأتي مضمناً مع Flutter SDK. تحقق من الإصدار:
```bash
dart --version
# يجب أن يكون >= 3.4.0
```

### 2.3 إعداد المحرر

#### VS Code (موصى به):
1. ثبّت VS Code من https://code.visualstudio.com/
2. ثبّت الإضافات التالية:
   - **Flutter** (Dart-Code.flutter)
   - **Dart** (Dart-Code.dart-code)
   - **Flutter Riverpod Snippets** (robert-brunhage.flutter-riverpod-snippets)
   - **Melos** (إضافة Melos لـ VS Code)
3. إعدادات موصى بها في `settings.json`:
```json
{
  "editor.formatOnSave": true,
  "dart.lineLength": 80,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code"
  }
}
```

#### Android Studio:
1. ثبّت Android Studio من https://developer.android.com/studio
2. ثبّت إضافة Flutter من Settings > Plugins
3. إضافة Dart تُثبّت تلقائياً مع Flutter

### 2.4 إعداد Java (للبناء على Android)

- مطلوب **Java 17** (Temurin/OpenJDK)
- تثبيت عبر:
  - Windows: https://adoptium.net/
  - macOS: `brew install openjdk@17`
  - Linux: `sudo apt install openjdk-17-jdk`

### 2.5 استنساخ المشروع

```bash
git clone https://github.com/your-org/alhai.git
cd alhai
```

### 2.6 تثبيت Melos

Melos هي أداة إدارة Monorepo. يجب تثبيتها عالمياً:

```bash
dart pub global activate melos
```

تأكد من أن مسار Dart global packages مضاف إلى `PATH`:
- Windows: `%LOCALAPPDATA%\Pub\Cache\bin`
- macOS/Linux: `$HOME/.pub-cache/bin`

### 2.7 تشغيل Melos Bootstrap

هذا الأمر يحمّل جميع التبعيات لكل الحزم والتطبيقات ويربط الحزم المحلية:

```bash
melos bootstrap
```

هذا يعادل تشغيل `flutter pub get` في كل مجلد فرعي، مع ربط الحزم المحلية تلقائياً.

### 2.8 تشغيل Code Generation

بعد Bootstrap، شغّل توليد الكود (Drift, Freezed, Injectable):

```bash
melos run codegen
```

هذا يعادل:
```bash
dart run build_runner build --delete-conflicting-outputs
```
في كل حزمة تعتمد على `build_runner`.

---

## 3. كيفية تشغيل كل تطبيق

### 3.1 تطبيق الكاشير (Cashier)

#### Web:
```bash
cd apps/cashier
flutter run -d chrome
```

#### Android:
```bash
cd apps/cashier
flutter run -d <device_id>
```

#### Web مع متغيرات بيئية:
```bash
cd apps/cashier
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_key_here
```

### 3.2 تطبيق الإدارة (Admin)

```bash
cd apps/admin
flutter run -d chrome
```

### 3.3 تطبيق الإدارة الخفيف (Admin Lite)

```bash
cd apps/admin_lite
flutter run -d chrome
```

### 3.4 تطبيق العميل (Customer App)

```bash
cd customer_app
flutter run -d <device_id>   # Android أو iOS
```

### 3.5 تطبيق السائق (Driver App)

```bash
cd driver_app
flutter run -d <device_id>   # Android أو iOS
```

### 3.6 Super Admin

```bash
cd super_admin
flutter run -d chrome   # Web فقط
```

### 3.7 Distributor Portal

```bash
cd distributor_portal
flutter run -d chrome   # Web فقط
```

### ملاحظة مهمة حول الويب

تطبيقات الويب تحتاج ملف `sqlite3.wasm` للعمل مع Drift. تأكد من وجوده في مجلد `web/` الخاص بالتطبيق.

---

## 4. كيفية إضافة شاشة جديدة

### الخطوة 1: إنشاء ملف الشاشة

أنشئ ملف Dart جديد في المجلد المناسب. مثلاً لإضافة شاشة "تقرير الأرباح" في تطبيق الكاشير:

```dart
// apps/cashier/lib/screens/reports/profit_report_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class ProfitReportScreen extends ConsumerWidget {
  const ProfitReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profitReport), // يجب إضافة المفتاح في ARB
      ),
      body: const Center(
        child: Text('تقرير الأرباح'),
      ),
    );
  }
}
```

### الخطوة 2: إضافة ثابت المسار (Route Constant)

أضف المسار في ملف `AppRoutes` المشترك في `alhai_shared_ui` أو `alhai_auth`:

```dart
// مثال: في ملف ثوابت المسارات المشتركة
static const String profitReport = '/reports/profit';
```

### الخطوة 3: إضافة المسار في GoRouter

افتح ملف الـ Router الخاص بالتطبيق وأضف المسار الجديد. مثلاً في `apps/cashier/lib/router/cashier_router.dart`:

```dart
GoRoute(
  path: AppRoutes.profitReport,
  name: 'profit-report',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: LazyScreen(
      screenBuilder: () async => const ProfitReportScreen(),
      loadingWidget: const ReportsLoadingScreen(),
    ),
    transitionsBuilder: _fadeTransition,
  ),
),
```

ملاحظة: يُستخدم `LazyScreen` للشاشات الثقيلة لتحسين الأداء، و `_fadeTransition` لتوحيد انتقالات الشاشات.

### الخطوة 4: إنشاء الـ Provider إذا لزم

إذا كانت الشاشة تحتاج بيانات من قاعدة البيانات، أنشئ Provider:

```dart
// في الحزمة المناسبة (مثلاً alhai_reports أو التطبيق نفسه)

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

final profitReportProvider = FutureProvider.autoDispose<List<ProfitData>>((ref) async {
  final db = GetIt.I<AppDatabase>();
  // استعلام قاعدة البيانات
  return db.salesDao.getProfitReport();
});
```

### الخطوة 5: إضافة الترجمة

أضف مفتاح الترجمة في ملفات ARB (انظر [القسم 7](#7-كيفية-إضافة-ترجمة-جديدة)).

---

## 5. كيفية إضافة جدول جديد في Drift

### الهيكل العام

قاعدة البيانات المشتركة موجودة في `packages/alhai_database/` وتحتوي على:
- **الجداول**: `lib/src/tables/` - تعريفات الجداول
- **الـ DAOs**: `lib/src/daos/` - عمليات الوصول للبيانات
- **FTS**: `lib/src/fts/` - البحث النصي الكامل
- **المهاجرات**: في `app_database.dart` - ضمن `MigrationStrategy`
- **الإصدار الحالي**: `schemaVersion => 13`

### الخطوة 1: إنشاء ملف الجدول

أنشئ ملفاً جديداً في `packages/alhai_database/lib/src/tables/`:

```dart
// packages/alhai_database/lib/src/tables/coupons_usage_table.dart

import 'package:drift/drift.dart';
import 'customers_table.dart';

/// جدول استخدام الكوبونات
@TableIndex(name: 'idx_coupon_usage_customer', columns: {#customerId})
@TableIndex(name: 'idx_coupon_usage_coupon', columns: {#couponCode})
class CouponsUsageTable extends Table {
  @override
  String get tableName => 'coupons_usage';

  TextColumn get id => text()();
  TextColumn get orgId => text().nullable()();
  TextColumn get couponCode => text()();
  TextColumn get customerId => text()
      .references(CustomersTable, #id, onDelete: KeyAction.cascade)();
  RealColumn get discountAmount => real()();
  DateTimeColumn get usedAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### الخطوة 2: تصدير الجدول في tables.dart

أضف سطر التصدير في `packages/alhai_database/lib/src/tables/tables.dart`:

```dart
// أضف في المكان المناسب حسب الأولوية
export 'coupons_usage_table.dart';
```

### الخطوة 3: إنشاء الـ DAO

أنشئ ملفاً جديداً في `packages/alhai_database/lib/src/daos/`:

```dart
// packages/alhai_database/lib/src/daos/coupons_usage_dao.dart

import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/coupons_usage_table.dart';

part 'coupons_usage_dao.g.dart';

/// DAO لاستخدام الكوبونات
@DriftAccessor(tables: [CouponsUsageTable])
class CouponsUsageDao extends DatabaseAccessor<AppDatabase>
    with _$CouponsUsageDaoMixin {
  CouponsUsageDao(super.db);

  /// إضافة استخدام كوبون
  Future<void> insertUsage(CouponsUsageTableCompanion usage) {
    return into(couponsUsageTable).insert(usage);
  }

  /// الحصول على استخدامات عميل معين
  Future<List<CouponsUsageTableData>> getByCustomer(String customerId) {
    return (select(couponsUsageTable)
      ..where((u) => u.customerId.equals(customerId))
      ..orderBy([(u) => OrderingTerm.desc(u.usedAt)]))
      .get();
  }
}
```

### الخطوة 4: تصدير الـ DAO في daos.dart

أضف سطر التصدير في `packages/alhai_database/lib/src/daos/daos.dart`:

```dart
export 'coupons_usage_dao.dart';
```

### الخطوة 5: تسجيل الجدول والـ DAO في AppDatabase

افتح `packages/alhai_database/lib/src/app_database.dart` وأضف:

```dart
@DriftDatabase(
  tables: [
    // ... الجداول الموجودة
    CouponsUsageTable,  // أضف هنا
  ],
  daos: [
    // ... الـ DAOs الموجودة
    CouponsUsageDao,    // أضف هنا
  ],
)
class AppDatabase extends _$AppDatabase {
  // ...

  @override
  int get schemaVersion => 14;  // ارفع رقم الإصدار

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await ftsService.createFtsTable();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // ... المهاجرات الحالية

      // Migration v13 -> v14: إضافة جدول استخدام الكوبونات
      if (from < 14) {
        await m.createTable(couponsUsageTable);
      }
    },
    // ...
  );
}
```

### الخطوة 6: تشغيل build_runner

```bash
cd packages/alhai_database
dart run build_runner build --delete-conflicting-outputs
```

أو عبر melos:
```bash
melos run codegen
```

هذا سيُنشئ الملفات التالية تلقائياً:
- `coupons_usage_dao.g.dart`
- تحديث `app_database.g.dart`

### الخطوة 7: تصدير في الحزمة الرئيسية

إذا لزم الأمر، أضف التصدير في `packages/alhai_database/lib/alhai_database.dart`:

```dart
// يتم التصدير تلقائياً عبر tables.dart و daos.dart
```

---

## 6. كيفية إضافة خدمة جديدة

### الهيكل

الخدمات موجودة في `alhai_services/lib/src/services/`. كل خدمة تحتوي على منطق أعمال محدد.

### الخطوة 1: إنشاء ملف الخدمة

```dart
// alhai_services/lib/src/services/discount_calculator_service.dart

import 'package:alhai_core/alhai_core.dart';

/// خدمة حساب الخصومات
class DiscountCalculatorService {
  /// حساب الخصم حسب النوع
  double calculateDiscount({
    required double originalPrice,
    required double discountValue,
    required DiscountType type,
  }) {
    switch (type) {
      case DiscountType.percentage:
        return originalPrice * (discountValue / 100);
      case DiscountType.fixed:
        return discountValue;
      case DiscountType.buyXGetY:
        // منطق خاص
        return 0;
    }
  }

  /// تطبيق الخصم مع التحقق من الحد الأقصى
  double applyDiscount({
    required double originalPrice,
    required double discountValue,
    required DiscountType type,
    double? maxDiscount,
  }) {
    var discount = calculateDiscount(
      originalPrice: originalPrice,
      discountValue: discountValue,
      type: type,
    );

    if (maxDiscount != null && discount > maxDiscount) {
      discount = maxDiscount;
    }

    return originalPrice - discount;
  }
}
```

### الخطوة 2: تسجيل في DI (حقن التبعيات)

يمكنك تسجيل الخدمة في GetIt مباشرة في ملف DI الخاص بالتطبيق:

```dart
// في apps/cashier/lib/di/injection.dart أو alhai_core/lib/src/di/di.dart

getIt.registerLazySingleton<DiscountCalculatorService>(
  () => DiscountCalculatorService(),
);
```

### الخطوة 3: تصدير الخدمة

أضف التصدير في `alhai_services/lib/alhai_services.dart` أو الملف المناسب:

```dart
export 'src/services/discount_calculator_service.dart';
```

### الخطوة 4: إنشاء Provider إذا لزم

```dart
final discountCalculatorProvider = Provider<DiscountCalculatorService>((ref) {
  return GetIt.I<DiscountCalculatorService>();
});
```

---

## 7. كيفية إضافة ترجمة جديدة

### هيكل الترجمة

الترجمة تُدار مركزياً في `packages/alhai_l10n/`:

```
packages/alhai_l10n/
  lib/
    l10n/
      app_ar.arb          # العربية (الأساسية - القالب)
      app_en.arb          # الإنجليزية
      app_ur.arb          # الأردية
      app_hi.arb          # الهندية
      app_bn.arb          # البنغالية
      app_fil.arb         # الفلبينية
      app_id.arb          # الإندونيسية
      generated/          # ملفات مُولّدة تلقائياً
        app_localizations.dart
        app_localizations_ar.dart
        ...
  l10n.yaml             # إعدادات التوليد
```

### إعدادات l10n.yaml

```yaml
arb-dir: lib/l10n
template-arb-file: app_ar.arb          # القالب الأساسي
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/generated
nullable-getter: false
```

### اللغات المدعومة (7 لغات)

| اللغة | الكود | الملف | اتجاه النص |
|-------|-------|-------|------------|
| العربية | `ar` | `app_ar.arb` | RTL |
| الإنجليزية | `en` | `app_en.arb` | LTR |
| الأردية | `ur` | `app_ur.arb` | RTL |
| الهندية | `hi` | `app_hi.arb` | LTR |
| البنغالية | `bn` | `app_bn.arb` | LTR |
| الفلبينية | `fil` | `app_fil.arb` | LTR |
| الإندونيسية | `id` | `app_id.arb` | LTR |

### الخطوة 1: إضافة المفتاح في الملف العربي (القالب)

افتح `packages/alhai_l10n/lib/l10n/app_ar.arb` وأضف:

```json
{
  "profitReport": "تقرير الأرباح",
  "@profitReport": {
    "description": "عنوان شاشة تقرير الأرباح"
  }
}
```

#### للنصوص التي تحتوي parameters:

```json
{
  "orderCount": "عدد الطلبات: {count}",
  "@orderCount": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

### الخطوة 2: إضافة المفتاح في جميع ملفات ARB الأخرى

**مهم جداً**: يجب إضافة نفس المفتاح في **كل** ملفات ARB الست الأخرى. عدم إضافته سيسبب fallback في وقت التشغيل.

```json
// app_en.arb
{ "profitReport": "Profit Report" }

// app_ur.arb
{ "profitReport": "منافع کی رپورٹ" }

// app_hi.arb
{ "profitReport": "लाभ रिपोर्ट" }

// app_bn.arb
{ "profitReport": "মুনাফা রিপোর্ট" }

// app_fil.arb
{ "profitReport": "Ulat ng Kita" }

// app_id.arb
{ "profitReport": "Laporan Laba" }
```

### الخطوة 3: توليد الملفات

```bash
cd packages/alhai_l10n
flutter gen-l10n
```

### الخطوة 4: استخدام الترجمة في الكود

```dart
import 'package:alhai_l10n/alhai_l10n.dart';

// في build method:
final l10n = AppLocalizations.of(context);
Text(l10n.profitReport);

// مع parameters:
Text(l10n.orderCount(42));
```

### اختبار تطابق المفاتيح

يوجد اختبار تلقائي يتحقق من تطابق المفاتيح بين جميع ملفات ARB:

```bash
cd packages/alhai_l10n
flutter test test/arb_keys_test.dart
```

هذا الاختبار يفشل إذا كان أي ملف ARB يفتقد مفتاحاً موجوداً في القالب (`app_ar.arb`)، أو يحتوي مفاتيح زائدة.

---

## 8. أوامر melos المهمة

### أوامر أساسية

| الأمر | الوصف |
|-------|-------|
| `melos bootstrap` | تحميل التبعيات وربط الحزم المحلية |
| `melos run analyze` | تشغيل المحلل (Analyzer) في جميع الحزم |
| `melos run test` | تشغيل الاختبارات في جميع الحزم |
| `melos run format` | تنسيق الكود في جميع الحزم |
| `melos run format:check` | التحقق من التنسيق بدون تعديل (CI) |
| `melos run codegen` | توليد الكود (Drift, Injectable, Freezed) |
| `melos run clean` | تنظيف جميع الحزم |
| `melos run fix` | تطبيق إصلاحات Dart التلقائية |
| `melos run deps:check` | التحقق من التبعيات القديمة |

### أوامر البناء

| الأمر | الوصف |
|-------|-------|
| `melos run build:cashier:apk` | بناء APK للكاشير |
| `melos run build:admin:web` | بناء Web للإدارة |
| `melos run build:lite:apk` | بناء APK للإدارة الخفيفة |
| `melos run build:all` | بناء جميع التطبيقات |

### أوامر الاختبار

| الأمر | الوصف |
|-------|-------|
| `melos run test` | تشغيل جميع الاختبارات |
| `melos run test:coverage` | تشغيل الاختبارات مع تغطية الكود |
| `melos run test:responsive` | اختبارات التصميم المتجاوب (Golden) |
| `melos run test:responsive:update` | تحديث ملفات Golden للتصميم المتجاوب |

### تنفيذ أمر في حزمة محددة

```bash
melos exec --scope="cashier" -- flutter test
melos exec --scope="alhai_database" -- dart run build_runner build
```

---

## 9. كيفية عمل Build للإنتاج

### 9.1 بناء Web

```bash
cd apps/cashier  # أو أي تطبيق يدعم الويب
flutter build web --release --no-tree-shake-icons \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

**لماذا `--no-tree-shake-icons`؟**

بعض الشاشات تستخدم `IconData` ديناميكي (أكواد الأيقونات مخزنة في قاعدة البيانات للفئات، وأيقونات شرطية في التقارير). إزالة هذا العلم يسبب أيقونات مفقودة أثناء التشغيل. الكلفة ~400KB (تُضغط إلى ~60KB عبر gzip).

### 9.2 بناء Android APK

```bash
cd apps/cashier
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

#### إعداد مفتاح التوقيع (Release Signing)

أنشئ ملف `apps/cashier/android/app/key.properties`:
```properties
storeFile=path/to/your/keystore.jks
storePassword=your_store_password
keyAlias=your_key_alias
keyPassword=your_key_password
```

**تحذير أمني**: لا تضف `key.properties` إلى Git. أضفه إلى `.gitignore`.

#### إعدادات build.gradle.kts

ملف البناء في `apps/cashier/android/app/build.gradle.kts` يحتوي على:
- `namespace = "com.alhai.cashier"` - معرف التطبيق
- Java 17 مطلوب
- ProGuard مفعّل للإنتاج (`isMinifyEnabled = true`, `isShrinkResources = true`)
- استبدال `sqlite3_flutter_libs` بـ `sqlcipher_flutter_libs` لدعم التشفير

### 9.3 بناء iOS

```bash
cd customer_app  # أو driver_app
flutter build ios --release --no-codesign \
  --obfuscate \
  --split-debug-info=build/debug-info \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

ملاحظة: `--no-codesign` يستخدم في CI. للنشر الفعلي، تحتاج شهادة Apple Developer وإعداد Xcode.

### 9.4 CI/CD (GitHub Actions)

المشروع يحتوي على 4 ملفات Workflow:

| الملف | الوظيفة | المُفعّل |
|-------|--------|----------|
| `flutter_ci.yml` | تحليل الكود + اختبارات + تغطية | push/PR إلى main/develop |
| `build-web.yml` | بناء Web لجميع التطبيقات | بعد نجاح Analyze & Test |
| `build-android.yml` | بناء APK لجميع التطبيقات | بعد نجاح Analyze & Test |
| `build-ios.yml` | بناء iOS (customer_app, driver_app) | بعد نجاح Analyze & Test |

#### هيكل CI:
1. **flutter_ci.yml** يعمل أولاً عند كل push/PR
2. عند نجاحه، تعمل workflows البناء بالتوازي عبر `workflow_run`
3. الحد الأدنى لتغطية الكود: **60%**
4. يوجد فحص دوري كل 3 أشهر لانتهاء شهادات SSL

---

## 10. قواعد الكود (Code Style)

### إعدادات Analysis Options

المشروع يستخدم `package:flutter_lints/flutter.yaml` مع قواعد إضافية:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - '**/*.g.dart'          # ملفات مُولّدة (Drift, Freezed)
    - '**/*.freezed.dart'    # ملفات Freezed مُولّدة
  errors:
    invalid_annotation_target: ignore
    sort_constructors_first: ignore
    dangling_library_doc_comments: ignore
    deprecated_member_use_from_same_package: info

linter:
  rules:
    avoid_print: true                    # لا تستخدم print() - استخدم debugPrint()
    prefer_const_constructors: true      # استخدم const دائماً
    prefer_const_declarations: true      # القيم الثابتة يجب أن تكون const
    prefer_final_fields: true            # المتغيرات الخاصة يجب أن تكون final
```

### قواعد أساسية يجب اتباعها

1. **لا تستخدم `print()`** - استخدم `debugPrint()` بدلاً منها (يُحذف تلقائياً في الإنتاج).

2. **استخدم `const` دائماً** حيثما أمكن:
   ```dart
   // صحيح
   const EdgeInsets.all(16)
   const Text('مرحباً')

   // خطأ
   EdgeInsets.all(16)
   Text('مرحباً')
   ```

3. **استخدم `withValues(alpha: X)` بدلاً من `withOpacity(X)`**:
   ```dart
   // صحيح (Flutter الحديث)
   color.withValues(alpha: 0.5)

   // خطأ (deprecated)
   color.withOpacity(0.5)
   ```

4. **استخدم `ConsumerWidget` بدلاً من `StatefulWidget` + `Consumer`**:
   ```dart
   // صحيح
   class MyScreen extends ConsumerWidget {
     @override
     Widget build(BuildContext context, WidgetRef ref) { ... }
   }

   // أو إذا كنت تحتاج State:
   class MyScreen extends ConsumerStatefulWidget {
     @override
     ConsumerState<MyScreen> createState() => _MyScreenState();
   }
   ```

5. **اتبع اصطلاح تسمية الملفات**:
   - الشاشات: `snake_case_screen.dart` (مثلاً `profit_report_screen.dart`)
   - الـ Providers: `snake_case_providers.dart`
   - الـ DAOs: `snake_case_dao.dart`
   - الجداول: `snake_case_table.dart`

6. **اكتب تعليقات بالعربية** للكود الأساسي والتوثيق الداخلي.

7. **لا تعدّل الملفات المُولّدة** (`*.g.dart`, `*.freezed.dart`).

### بنية مجلدات التطبيق (Convention)

```
apps/cashier/
  lib/
    di/                    # حقن التبعيات
      injection.dart
    router/                # إعدادات التنقل
      cashier_router.dart
    screens/               # الشاشات (مجلد لكل ميزة)
      reports/
        profit_report_screen.dart
      pos/
        ...
    ui/                    # مكونات UI خاصة بالتطبيق
      cashier_shell.dart
    main.dart              # نقطة الدخول
```

---

## 11. كيفية كتابة الاختبارات

### أنواع الاختبارات

| النوع | الموقع | الوصف |
|-------|--------|-------|
| Unit Tests | `test/` | اختبارات الوحدات (DAOs, Services) |
| Widget Tests | `test/` | اختبارات الويدجتات |
| Integration Tests | `integration_test/` | اختبارات تكاملية |
| Golden Tests | `test/responsive/` | اختبارات التصميم المتجاوب |
| ARB Key Tests | `test/arb_keys_test.dart` | تطابق مفاتيح الترجمة |

### مثال: اختبار DAO

```dart
// packages/alhai_database/test/app_database_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:alhai_database/alhai_database.dart';

/// إنشاء قاعدة بيانات في الذاكرة للاختبارات
AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  group('AppDatabase', () {
    test('database can perform basic CRUD operations', () async {
      final db = createTestDatabase();

      // إضافة منتج
      await db.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'test-prod',
          storeId: 'test-store',
          name: 'منتج اختبار',
          price: 10.0,
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      // قراءة المنتج
      final product = await db.productsDao.getProductById('test-prod');
      expect(product, isNotNull);
      expect(product!.name, 'منتج اختبار');

      // حذف المنتج
      await db.productsDao.deleteProduct('test-prod');
      final deleted = await db.productsDao.getProductById('test-prod');
      expect(deleted, isNull);

      await db.close();
    });

    test('multiple databases are independent', () async {
      final db1 = createTestDatabase();
      final db2 = createTestDatabase();

      await db1.productsDao.insertProduct(
        ProductsTableCompanion.insert(
          id: 'prod-db1',
          storeId: 'store-1',
          name: 'منتج قاعدة بيانات 1',
          price: 5.0,
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      // db2 يجب أن لا يحتوي هذا المنتج
      final inDb2 = await db2.productsDao.getProductById('prod-db1');
      expect(inDb2, isNull);

      await db1.close();
      await db2.close();
    });
  });
}
```

### مثال: اختبار تطابق مفاتيح الترجمة

```dart
// packages/alhai_l10n/test/arb_keys_test.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('app_en.arb contains all keys from app_ar.arb', () {
    final baseArb = jsonDecode(
      File('lib/l10n/app_ar.arb').readAsStringSync(),
    ) as Map<String, dynamic>;

    final enArb = jsonDecode(
      File('lib/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;

    final baseKeys = baseArb.keys
        .where((k) => !k.startsWith('@'))
        .toSet();
    final enKeys = enArb.keys
        .where((k) => !k.startsWith('@'))
        .toSet();

    final missing = baseKeys.difference(enKeys);
    expect(missing, isEmpty,
        reason: 'Missing keys in app_en.arb: $missing');
  });
}
```

### تشغيل الاختبارات

```bash
# جميع الاختبارات
melos run test

# اختبارات حزمة محددة
cd packages/alhai_database
flutter test

# اختبار ملف محدد
flutter test test/app_database_test.dart

# مع تغطية الكود
melos run test:coverage

# اختبارات Golden
melos run test:responsive
```

### أدوات الاختبار المستخدمة

- **flutter_test**: إطار الاختبار الأساسي
- **mocktail** (`^1.0.4`): إنشاء Mocks (بديل Mockito بدون codegen)
- **golden_toolkit** (`^0.15.0`): اختبارات Golden للتصميم
- **faker** (`^2.1.0`): توليد بيانات وهمية (في customer_app و driver_app)

---

## 12. الأخطاء الشائعة وحلولها

### 1. خطأ: "Type Sqlite3FlutterLibsPlugin is defined multiple times"

**السبب**: تعارض بين `sqlite3_flutter_libs` و `sqlcipher_flutter_libs`.

**الحل**: تأكد من وجود الكود التالي في `android/app/build.gradle.kts`:
```kotlin
configurations.configureEach {
    resolutionStrategy.dependencySubstitution {
        substitute(project(":sqlite3_flutter_libs"))
            .using(project(":sqlcipher_flutter_libs"))
    }
}
```

### 2. خطأ: "Could not find the generated implementation of AppDatabase"

**السبب**: لم يتم تشغيل `build_runner` بعد تعديل الجداول أو DAOs.

**الحل**:
```bash
cd packages/alhai_database
dart run build_runner build --delete-conflicting-outputs
```

### 3. خطأ: "MissingPluginException" على الويب

**السبب**: بعض الإضافات لا تدعم الويب (مثل `flutter_secure_storage`).

**الحل**: استخدم `kIsWeb` للتحقق من المنصة:
```dart
if (kIsWeb) {
  // استخدم SharedPreferences
} else {
  // استخدم FlutterSecureStorage
}
```

### 4. خطأ: "Supabase not configured"

**السبب**: المتغيرات البيئية (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) غير معرّفة.

**الحل**: مرر المتغيرات عبر `--dart-define`:
```bash
flutter run -d chrome \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your_key
```

### 5. خطأ: "melos: command not found"

**السبب**: Melos غير مثبت أو مسار Dart غير مضاف لـ PATH.

**الحل**:
```bash
dart pub global activate melos

# إضافة المسار (Windows):
# أضف %LOCALAPPDATA%\Pub\Cache\bin إلى PATH

# إضافة المسار (macOS/Linux):
export PATH="$HOME/.pub-cache/bin:$PATH"
```

### 6. خطأ: "firebase_core" initialization failed

**السبب**: Firebase غير مُهيّأ.

**الحل**: التطبيق يتعامل مع هذا الخطأ تلقائياً ويستمر بدون Firebase:
```dart
try {
  await Firebase.initializeApp();
} catch (e) {
  debugPrint('Firebase not configured: $e');
}
```
إذا كنت تحتاج Firebase فعلاً، قم بإعداد `google-services.json` (Android) أو `GoogleService-Info.plist` (iOS).

### 7. خطأ: "withOpacity is deprecated"

**السبب**: Flutter أوقفت `Color.withOpacity()`.

**الحل**: استخدم `withValues(alpha: X)`:
```dart
// بدلاً من:
Colors.red.withOpacity(0.5)

// استخدم:
Colors.red.withValues(alpha: 0.5)
```

### 8. خطأ: الأيقونات مفقودة في Web

**السبب**: tree-shaking يحذف الأيقونات غير المُستخدمة مباشرة.

**الحل**: دائماً استخدم `--no-tree-shake-icons` عند بناء الويب:
```bash
flutter build web --no-tree-shake-icons
```

### 9. خطأ: "PRAGMA key" فشل في الويب

**السبب**: الويب لا يدعم SQLCipher/تشفير قاعدة البيانات.

**الحل**: هذا طبيعي. ملف `connection_web.dart` يعمل بدون تشفير تلقائياً. قاعدة بيانات الويب تُخزّن في IndexedDB بدون تشفير.

### 10. خطأ: "flutter gen-l10n" لا تعمل

**السبب**: `l10n.yaml` مفقود أو إعداداته خاطئة.

**الحل**: تأكد من وجود `l10n.yaml` في `packages/alhai_l10n/`:
```yaml
arb-dir: lib/l10n
template-arb-file: app_ar.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/generated
nullable-getter: false
```

---

## 13. قائمة المتغيرات البيئية (.env)

### المتغيرات المطلوبة للتطبيقات

تُمرر عبر `--dart-define` عند التشغيل أو البناء:

| المتغير | الوصف | مطلوب |
|---------|-------|-------|
| `SUPABASE_URL` | رابط مشروع Supabase | نعم (للمزامنة) |
| `SUPABASE_ANON_KEY` | مفتاح Supabase العام | نعم (للمزامنة) |

### المتغيرات الخاصة بـ AI Server

ملف `ai_server/.env.example` يوضح المتغيرات المطلوبة:

| المتغير | الوصف | مثال |
|---------|-------|------|
| `SUPABASE_URL` | رابط Supabase | `https://your-project-id.supabase.co` |
| `SUPABASE_ANON_KEY` | المفتاح العام | `your_anon_key_here` |
| `SUPABASE_SERVICE_ROLE_KEY` | مفتاح الخدمة (سري) | `your_service_role_key_here` |
| `JWT_SECRET` | سر JWT | `your_jwt_secret_here` |
| `HOST` | عنوان الخادم | `0.0.0.0` |
| `PORT` | منفذ الخادم | `8000` |
| `DEBUG` | وضع التصحيح | `true` |
| `ALLOWED_ORIGINS` | مصادر CORS المسموحة | `http://localhost:3000,http://localhost:8080` |

### المتغيرات في CI/CD (GitHub Secrets)

| Secret | الاستخدام |
|--------|-----------|
| `SUPABASE_URL` | رابط Supabase (للبناء في CI) |
| `SUPABASE_ANON_KEY` | مفتاح Supabase (للبناء في CI) |
| `GITHUB_TOKEN` | نشر على GitHub Pages (تلقائي) |

### تنبيهات أمنية

- لا تضع أبداً `SUPABASE_SERVICE_ROLE_KEY` في الكود أو في `--dart-define` للتطبيقات
- `SUPABASE_ANON_KEY` آمن للاستخدام في التطبيقات (يعتمد على RLS)
- استخدم `flutter_secure_storage` لتخزين المفاتيح على الأجهزة المحلية
- على الويب، لا يوجد تخزين مشفر - البيانات الحساسة قابلة للوصول عبر DevTools

---

## 14. أوامر Drift / build_runner

### أوامر build_runner الأساسية

```bash
# توليد الكود (بناء المرة الأولى)
dart run build_runner build --delete-conflicting-outputs

# توليد مع مراقبة التغييرات (أثناء التطوير)
dart run build_runner watch --delete-conflicting-outputs

# تنظيف الملفات المُولّدة
dart run build_runner clean
```

### عبر melos (لجميع الحزم)

```bash
# توليد الكود لكل الحزم التي تعتمد على build_runner
melos run codegen
```

### الحزم التي تحتاج codegen

| الحزمة | ما يُولّد |
|--------|----------|
| `alhai_database` | `app_database.g.dart`, `*_dao.g.dart` (Drift) |
| `alhai_core` | `*.freezed.dart`, `*.g.dart` (Freezed, json_serializable, Injectable) |

### تسلسل العمل مع Drift

1. **عدّل الجدول** في `tables/` أو الـ DAO في `daos/`
2. **شغّل build_runner**:
   ```bash
   cd packages/alhai_database
   dart run build_runner build --delete-conflicting-outputs
   ```
3. **تحقق من الملفات المُولّدة** (`*.g.dart`)
4. **عدّل `schemaVersion`** في `app_database.dart` إذا غيّرت هيكل الجدول
5. **أضف Migration** في `onUpgrade` إذا غيّرت هيكل جدول موجود
6. **شغّل الاختبارات**:
   ```bash
   flutter test
   ```

### ملاحظات مهمة حول المهاجرات (Migrations)

- إصدار قاعدة البيانات الحالي: **13**
- كل تغيير في هيكل الجداول يتطلب رفع `schemaVersion`
- استخدم `m.createTable()` لإضافة جداول جديدة
- استخدم `customStatement()` لتعديلات ALTER TABLE
- المهاجرات تراكمية (من أي إصدار إلى الأحدث)
- اختبر المهاجرات دائماً قبل الدفع

### مثال: هجرة تضيف عمود جديد

```dart
if (from < 14) {
  await customStatement(
    'ALTER TABLE products ADD COLUMN weight REAL',
  );
}
```

### مثال: هجرة تضيف جدول جديد

```dart
if (from < 14) {
  await m.createTable(couponsUsageTable);
}
```

---

## 15. نصائح وأفضل الممارسات

### 15.1 هيكلة الكود

- **اتبع معمارية Clean Architecture**: فصل طبقات Data و Domain و Presentation
- **استخدم الحزم المشتركة** بدلاً من تكرار الكود بين التطبيقات
- **اتبع اصطلاح Path Dependencies**:
  - من تطبيق تحت `apps/<app>/`:
    ```yaml
    alhai_core: { path: ../../alhai_core }
    alhai_database: { path: ../../packages/alhai_database }
    ```
  - من حزمة تحت `packages/<pkg>/`:
    ```yaml
    alhai_core: { path: ../../alhai_core }
    <sibling>: { path: ../<sibling> }
    ```
  - من تطبيق في الجذر (`customer_app/`, `driver_app/`, etc.):
    ```yaml
    alhai_core: { path: ../alhai_core }
    alhai_database: { path: ../packages/alhai_database }
    ```

### 15.2 إدارة الحالة (State Management)

- استخدم **Riverpod** لكل إدارة الحالة
- **Providers** لكل حالة عامة أو مشتركة
- **FutureProvider.autoDispose** للبيانات المؤقتة (شاشة واحدة)
- **StateNotifierProvider** للحالة القابلة للتعديل
- **GetIt** فقط لحقن التبعيات (Services, Database)، ليس لإدارة الحالة

### 15.3 قاعدة البيانات

- استخدم **Transactions** للعمليات المركبة (بيع = sale + items + stock update):
  ```dart
  await db.createSaleTransaction(
    sale: saleData,
    items: itemsList,
    stockDeductions: deductions,
  );
  ```
- **فعّل PRAGMA foreign_keys** (مُفعّل تلقائياً في `beforeOpen`)
- استخدم **Soft Delete** (`deletedAt`) بدلاً من الحذف الفعلي
- استخدم **FTS** (Full-Text Search) للبحث السريع في المنتجات
- استخدم **Indexes** (`@TableIndex`) لتحسين أداء الاستعلامات
- قاعدة البيانات مشفرة على الأجهزة المحلية عبر **SQLCipher** (مفتاح مخزن في Secure Storage)
- قاعدة بيانات الويب **غير مشفرة** (IndexedDB)

### 15.4 التنقل (Routing)

- استخدم **GoRouter** مع **ShellRoute** لإنشاء تخطيط مع شريط جانبي
- استخدم **LazyScreen** للشاشات الثقيلة لتحسين الأداء
- استخدم **_fadeTransition** لتوحيد انتقالات الشاشات
- استخدم **Auth Guards** في `redirect` لحماية المسارات:
  ```dart
  redirect: (context, state) => _guardRedirect(ref, state),
  ```

### 15.5 الأمان

- **تشفير قاعدة البيانات**: SQLCipher على الأجهزة المحلية، المفتاح في Secure Storage
- **HTTPS دائماً**: تأكد من استخدام HTTPS في الإنتاج
- **Content Security Policy**: مُعدّ في `web/index.html`
- **مفاتيح التوقيع**: لا تضع `key.properties` في Git
- **لا تخزن أسراراً في الكود**: استخدم `--dart-define` أو GitHub Secrets
- **Rate Limiter**: للحماية من هجمات brute force
- **CSRF Protection**: متاح عبر Security Services

### 15.6 RTL والتصميم المتجاوب

- **اللغات RTL**: العربية (`ar`) والأردية (`ur`)
- استخدم `Directionality` widget أو `localeState.textDirection`
- تجنب `EdgeInsets.only(left: ...)` - استخدم `EdgeInsetsDirectional.only(start: ...)`
- اختبر كل شاشة بالعربية والإنجليزية
- **Breakpoints**: Mobile (375px), Tablet (768px), Desktop (1440px)

### 15.7 الترجمة

- القالب الأساسي هو **العربي** (`app_ar.arb`)
- أضف المفتاح في **جميع** ملفات ARB السبعة
- شغّل `flutter gen-l10n` بعد كل تعديل
- اختبر التطابق عبر `flutter test test/arb_keys_test.dart`
- لا تستخدم نصوصاً مكتوبة مباشرة (hardcoded) - استخدم `AppLocalizations.of(context)`

### 15.8 الأداء

- **تحميل Splash سريع**: 500ms فقط (بدلاً من 2000ms سابقاً)
- **تحميل موازي**: Firebase + Supabase + DB Key + SharedPreferences تُحمّل بالتوازي عبر `Future.wait`
- **CSV Parsing في خلفية**: يستخدم `compute()` لتحليل CSV في Isolate منفصل
- **Lazy Loading**: الشاشات الثقيلة تُحمّل عند الحاجة عبر `LazyScreen`
- **FTS Index**: بحث النصوص يستخدم FTS5 لأداء أفضل بدلاً من LIKE
- **WAL Mode**: قاعدة البيانات تعمل في وضع WAL للأداء الأفضل

### 15.9 الخطوط (Fonts)

نظام التصميم يستخدم خطوطاً مخصصة حسب اللغة:
- **العربية**: خط Tajawal (Regular 400, Medium 500, Bold 700, Light 300)
- **الهندية**: Noto Sans Devanagari (Regular, Medium, Bold)
- **البنغالية**: Noto Sans Bengali (Regular, Medium, Bold)

الخطوط مخزنة في `alhai_design_system/assets/fonts/`.

### 15.10 الرسوم البيانية (Charts)

- استخدم **fl_chart** (MIT license) فقط
- **لا تستخدم** Syncfusion (ترخيص تجاري مقيّد)
- بدائل مجانية إذا لزم: `graphic` (BSD) أو `community_charts_flutter` (Apache 2.0)

### 15.11 CSV و Excel

- **CSV**: حزمة `csv` الأساسية موجودة في `alhai_database` (الموقع الأساسي)
- **Excel (.xlsx)**: فقط في `distributor_portal` (Web B2B). لا تضف `excel` في التطبيقات المحمولة (+2MB)

### 15.12 عادات التطوير اليومية

```bash
# بداية اليوم
melos bootstrap       # تحديث التبعيات

# أثناء العمل على alhai_database
cd packages/alhai_database
dart run build_runner watch --delete-conflicting-outputs

# قبل الـ Commit
melos run analyze     # تحليل الكود
melos run format      # تنسيق
melos run test        # اختبارات

# بعد تعديل ARB
cd packages/alhai_l10n
flutter gen-l10n
flutter test          # تحقق من التطابق
```

### 15.13 DI (حقن التبعيات) - النمط المتبع

التطبيقات تستخدم نمط Override للمستودعات المحلية:

```dart
// في apps/cashier/lib/di/injection.dart

Future<void> configureDependencies() async {
  getIt.allowReassignment = true;

  // 1. تهيئة التبعيات الأساسية أولاً
  await core.configureDependencies();

  // 2. تسجيل قاعدة البيانات المحلية
  if (!getIt.isRegistered<AppDatabase>()) {
    getIt.registerSingleton<AppDatabase>(AppDatabase());
  }

  // 3. استبدال المستودعات البعيدة بالمحلية (offline-first)
  final db = getIt<AppDatabase>();
  getIt.registerLazySingleton<core.ProductsRepository>(
    () => LocalProductsRepository(db),
  );
  getIt.registerLazySingleton<core.CategoriesRepository>(
    () => LocalCategoriesRepository(db),
  );

  getIt.allowReassignment = false;
}
```

### 15.14 التعامل مع الأخطاء

- استخدم `runZonedGuarded` في `main()` لالتقاط الأخطاء غير المعالجة
- سجّل الأخطاء عبر `FlutterError.onError` و `PlatformDispatcher.instance.onError`
- في الإنتاج، استخدم `debugPrint` (يُحذف تلقائياً)
- لا تستخدم `print()` أبداً

### 15.15 الإصدارات (Versioning)

- جميع التطبيقات حالياً في الإصدار `1.0.0+1`
- مخطط لاستخدام Melos Versioning مع Conventional Commits
- يجب تحديث استراتيجية الإصدار قبل أول إصدار إنتاجي

---

## ملحق: خريطة الحزم والتبعيات

```
alhai_core (لا يعتمد على حزم داخلية)
  |
  +-- alhai_services (يعتمد على alhai_core)
  |
  +-- alhai_design_system (مستقل)
  |
  +-- alhai_database (يعتمد على alhai_core)
  |     |
  |     +-- alhai_sync (يعتمد على alhai_database)
  |     |
  |     +-- alhai_l10n (مستقل)
  |     |
  |     +-- alhai_auth (يعتمد على alhai_core, alhai_database, alhai_l10n, alhai_design_system)
  |     |
  |     +-- alhai_shared_ui (يعتمد على الكل ما عدا alhai_ai)
  |     |
  |     +-- alhai_pos (يعتمد على الكل ما عدا alhai_ai)
  |     |
  |     +-- alhai_reports (يعتمد على حزم محددة)
  |     |
  |     +-- alhai_ai (يعتمد على حزم محددة)
  |
  +-- التطبيقات (تعتمد على الحزم المطلوبة)
       |
       +-- cashier (POS, Auth, Shared UI, Reports, Database, Sync, L10n)
       +-- admin (الكل بما فيها AI)
       +-- admin_lite (الكل بما فيها AI)
       +-- customer_app (Core, Services, Design System)
       +-- driver_app (Core, Services, Design System)
       +-- super_admin (Core, Services, Design System, Auth)
       +-- distributor_portal (Core, Services, Design System)
```

---

## ملحق: جداول قاعدة البيانات (40+ جدول)

### الجداول الأساسية
| الجدول | الملف | الوصف |
|--------|-------|-------|
| `products` | `products_table.dart` | المنتجات |
| `sales` | `sales_table.dart` | المبيعات |
| `sale_items` | `sale_items_table.dart` | عناصر المبيعات |
| `inventory_movements` | `inventory_movements_table.dart` | حركات المخزون |
| `accounts` | `accounts_table.dart` | حسابات العملاء |
| `sync_queue` | `sync_queue_table.dart` | طابور المزامنة |
| `transactions` | `transactions_table.dart` | المعاملات المالية |
| `orders` | `orders_table.dart` | الطلبات |
| `order_items` | `order_items_table.dart` | عناصر الطلبات |
| `audit_log` | `audit_log_table.dart` | سجل المراجعة |
| `categories` | `categories_table.dart` | الفئات |
| `loyalty_points` | `loyalty_table.dart` | نقاط الولاء |
| `loyalty_transactions` | `loyalty_table.dart` | معاملات الولاء |
| `loyalty_rewards` | `loyalty_table.dart` | مكافآت الولاء |

### جداول الأولوية العالية
| الجدول | الوصف |
|--------|-------|
| `stores` | المتاجر |
| `users` | المستخدمين |
| `customers` | العملاء |
| `customer_addresses` | عناوين العملاء |
| `suppliers` | الموردين |
| `shifts` | الورديات |
| `cash_movements` | حركات النقد |
| `returns` | المرتجعات |
| `return_items` | عناصر المرتجعات |
| `expenses` | المصروفات |
| `expense_categories` | فئات المصروفات |

### جداول الأولوية المتوسطة
| الجدول | الوصف |
|--------|-------|
| `purchases` | المشتريات |
| `purchase_items` | عناصر المشتريات |
| `discounts` | الخصومات |
| `coupons` | الكوبونات |
| `promotions` | العروض |
| `held_invoices` | الفواتير المعلقة |
| `notifications` | الإشعارات |
| `stock_transfers` | تحويلات المخزون |
| `settings` | الإعدادات |

### جداول إضافية
| الجدول | الوصف |
|--------|-------|
| `stock_takes` | جرد المخزون |
| `product_expiry` | صلاحية المنتجات |
| `drivers` | السائقين |
| `daily_summaries` | ملخصات يومية |
| `order_status_history` | تاريخ حالة الطلبات |
| `favorites` | المفضلة |
| `whatsapp_messages` | رسائل واتساب |
| `whatsapp_templates` | قوالب واتساب |

### جداول متعددة المستأجرين (Multi-Tenant)
| الجدول | الوصف |
|--------|-------|
| `organizations` | المؤسسات |
| `subscriptions` | الاشتراكات |
| `org_members` | أعضاء المؤسسة |
| `user_stores` | ربط المستخدمين بالمتاجر |
| `pos_terminals` | أجهزة نقاط البيع |

### جداول المزامنة
| الجدول | الوصف |
|--------|-------|
| `sync_metadata` | بيانات المزامنة الوصفية |
| `stock_deltas` | تغييرات المخزون (للمزامنة) |

---

> **ملاحظة أخيرة**: هذا الدليل يُحدّث بشكل دوري. إذا وجدت معلومة قديمة أو خاطئة، يرجى تحديثها وإعلام الفريق.
