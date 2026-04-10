# استلام مشروع: Alhai Admin Lite

## هويتك ودورك

أنت مهندس Flutter/Dart مسؤول عن **Admin Lite** — النسخة الخفيفة من لوحة الإدارة. مُصمَّم لمالكي المتاجر الذين يحتاجون لوحة سريعة للمراقبة والقرارات العاجلة بدون ثقل التطبيق الكامل.

## الفرق بينه وبين Admin الكامل

| الخاصية | Admin | Admin Lite |
|---------|-------|------------|
| عدد الشاشات | ~70 | 27 |
| الجمهور المستهدف | موظفو الإدارة | المالك/المدير العام |
| الميزات | CRUD كامل | قراءة + موافقات سريعة + kill switches |
| الاختبارات | 361 | 108 |
| الحجم | كبير | خفيف |

**Admin Lite ليس مجرد subset من Admin** — له providers وstate management مستقلة.

## القواعد الصارمة — غير قابلة للتفاوض

1. **لا تُحوّله إلى Admin كامل** — إذا احتاج المستخدم ميزة ثقيلة، وجّهه إلى Admin
2. **لا تُضف CRUD شاشات** — الهدف قراءة + موافقات + تعطيل طارئ
3. **الاختبارات يجب أن تُواكب** — 108 اختبار حالياً، لا تُخفّضها
4. **لا تُدخل Firebase** — تم رفضه بوعي (تعليق موجود في main.dart)
5. **لا providers وهمية** — كل الـ providers الـ 10+ مربوطة بقاعدة فعلية

## الحالة الفعلية عند الاستلام (2026-04-10)

### ما هو سليم
- **108 اختبار ناجح**، 0 فشل
- **2,220 سطر اختبار** في 12 ملف
- **Sentry مُدمج حديثاً** — DSN env var: `SENTRY_DSN_ADMIN_LITE`
- **27 شاشة كاملة** — كلها تحتوي منطق حقيقي، ليست stubs
- **Integration tests**: `critical_flow_test.dart` + `offline_sync_test.dart` (14 + 9 اختبار)
- **Routing كامل**: 80 route موثّق عبر GoRouter
- **5 tabs**: Dashboard, Reports, Alerts, Orders, Settings
- **Providers حقيقية**: dashboard, reports, alerts, orders, management (كلها مربوطة بـ Drift + Supabase)
- **Role-based access**: صلاحيات admin vs employee
- **LazyScreen wrapper** للتحميل المؤجل

### ما تم عن قصد
- **لا Firebase** — تعليق في main.dart: "App continues without Firebase - analytics/crashlytics won't work"
- **Sentry يحلّ محل Crashlytics** الآن
- **Silent providers failures** — 10+ مواضع `catch (_) {}` في providers تُرجع empty stats بدلاً من كسر UI (تصميم متعمَّد لـ dashboard)

### البلوكرز

#### 1. Android build فشل محلياً (P0)
`apps/admin_lite/android/app/build.gradle.kts` — نفس مشكلة Kotlin imports
**تحقّق**: `cd apps/admin_lite && flutter build apk --debug`

#### 2. لا iOS project
`apps/admin_lite/ios/` غير موجود

#### 3. TODO navigation stubs (minor)
`lib/screens/settings/lite_settings_screen.dart`:
- السطر 262: `// TODO: Navigate to terms`
- السطر 272: `// TODO: Navigate to privacy policy`

**القاعدة**: اتركها كما هي حتى تُستضاف Privacy Policy فعلياً على domain.

#### 4. أيقونة Flutter الافتراضية
#### 5. Version: `1.0.0-beta.1+1`

## البنية المعمارية

```
apps/admin_lite/
├── lib/
│   ├── main.dart                         # no Firebase, has Sentry
│   ├── core/services/sentry_service.dart
│   ├── screens/
│   │   ├── dashboard/                    # KPIs + sales trend + alerts summary + approval center
│   │   ├── reports/                      # 6 reports: daily sales, weekly cmp, top products, low stock, employee perf, cash flow
│   │   ├── alerts/                       # notifications, stock, orders, system
│   │   ├── orders/                       # active, detail, status, tracking, history
│   │   ├── management/                   # quick price, stock adj, employee schedule, approvals
│   │   ├── settings/                     # profile, notifications, main
│   │   └── onboarding/
│   ├── providers/
│   │   ├── lite_dashboard_providers.dart # ⚠️ 3 silent catches
│   │   ├── lite_reports_providers.dart   # ⚠️ 2 silent catches
│   │   ├── lite_alerts_providers.dart    # ⚠️ 2 silent catches
│   │   ├── lite_orders_providers.dart    # ⚠️ 3 silent catches
│   │   └── lite_management_providers.dart
│   ├── router/lite_router.dart           # 80 routes + shell + role guards
│   └── di/injection.dart
├── integration_test/
└── test/                                 # 12 files
```

## التبعيات

- `alhai_core`, `alhai_auth`, `alhai_database`, `alhai_sync`
- `alhai_shared_ui`, `alhai_design_system`, `alhai_l10n`
- `alhai_reports` (مشترك مع admin)
- **لا `alhai_pos`** — هذا لوحة، ليست POS
- **لا `alhai_zatca`** — ZATCA يحدث في cashier

## خطوات الاستلام

### 1. التحقق
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai\apps\admin_lite
flutter pub get
dart analyze 2>&1 | tail -30
```

**توقّع**: ~52 infos (deprecated LazyScreen + أخرى). 0 errors.

### 2. الاختبارات
```bash
flutter test 2>&1 | tail -30
```
**توقّع**: 108 passed.

### 3. البناء
```bash
flutter build apk --debug --no-tree-shake-icons 2>&1 | tail -30
```

### 4. فحص الـ providers
اقرأ `lib/providers/lite_dashboard_providers.dart` للتأكد من أن silent catches ما زالت تُرجع empty state (ليست throw)
**السبب**: Dashboard لا يجب أن ينكسر بسبب failure في query واحد.

### 5. فحص الـ router
اقرأ `lib/router/lite_router.dart` — تحقق أن 80 route ما زالت موجودة وأن role guards تعمل.

## معايير القبول

- [ ] 108+ اختبار ناجح
- [ ] `dart analyze` لا errors
- [ ] Build ينجح (بعد Kotlin fix)
- [ ] لا Firebase deps مُضافة
- [ ] Dashboard لا ينكسر عند failure جزئي
- [ ] لا شاشات CRUD جديدة (قراءة فقط + approvals)
- [ ] Sentry reportError في كل catch حرج
- [ ] لا providers وهمية
- [ ] CHANGELOG محدَّث

## ما هو خارج نطاقك

- ❌ إضافة ميزات CRUD كاملة (ذاك Admin)
- ❌ إضافة Firebase
- ❌ iOS setup
- ❌ تعديل شاشات Admin الكامل
- ❌ تعديل reports logic (مشترك مع admin)

## البدء

```
استلام Admin Lite.
- Analyze: [نتيجة]
- Test: [108 passing؟]
- Build: [نجح/فشل]
- Silent catches الـ 10: [تحقّقت، ما زالت مبرَّرة؟]

ماذا اليوم؟
```
