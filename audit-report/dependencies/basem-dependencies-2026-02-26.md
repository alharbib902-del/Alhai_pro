# تقرير تدقيق الاعتماديات (Dependencies Audit Report)
## منصة الحي - Alhai Platform
### التاريخ: 2026-02-26
### المدقق: باسم

---

## الملخص التنفيذي

تم إجراء تدقيق شامل لجميع ملفات `pubspec.yaml` و `pubspec.lock` عبر **19 وحدة** في مشروع منصة الحي (Alhai Platform). يغطي التدقيق تحليل الاعتماديات، تعارضات الإصدارات، قيود SDK، الحزم المكررة، والتوصيات الأمنية.

### النتيجة الإجمالية: 5.5 / 10

| التصنيف | العدد |
|---------|-------|
| مشاكل حرجة | 7 |
| مشاكل متوسطة | 12 |
| مشاكل منخفضة | 9 |
| **المجموع** | **28** |

---

## 1. هيكل الوحدات والاعتماديات

### 1.1 جدول الوحدات مع قيود SDK

| الوحدة | المسار | Dart SDK | Flutter SDK |
|--------|--------|----------|-------------|
| alhai_workspace (root) | `pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| alhai_core | `alhai_core/pubspec.yaml` | `>=3.0.0 <4.0.0` | - |
| alhai_design_system | `alhai_design_system/pubspec.yaml` | `>=3.0.0 <4.0.0` | `>=3.10.0` |
| alhai_services | `alhai_services/pubspec.yaml` | `^3.8.0` | `>=3.29.0` |
| admin | `apps/admin/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| admin_lite | `apps/admin_lite/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| cashier | `apps/cashier/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| customer_app | `customer_app/pubspec.yaml` | `>=3.0.0 <4.0.0` | - |
| distributor_portal | `distributor_portal/pubspec.yaml` | `>=3.0.0 <4.0.0` | - |
| driver_app | `driver_app/pubspec.yaml` | `>=3.0.0 <4.0.0` | - |
| super_admin | `super_admin/pubspec.yaml` | `>=3.0.0 <4.0.0` | - |
| alhai_ai | `packages/alhai_ai/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| alhai_auth | `packages/alhai_auth/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| alhai_database | `packages/alhai_database/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| alhai_l10n | `packages/alhai_l10n/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| alhai_pos | `packages/alhai_pos/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| alhai_reports | `packages/alhai_reports/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| alhai_shared_ui | `packages/alhai_shared_ui/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |
| alhai_sync | `packages/alhai_sync/pubspec.yaml` | `>=3.4.0 <4.0.0` | - |

---

## 2. النتائج التفصيلية

---

### 2.1 تعارضات قيود Dart SDK

#### مشكلة #1: تعارض قيود Dart SDK عبر الوحدات

| التصنيف | الخطورة |
|---------|---------|
| تعارض إصدارات | حرج |

**الوصف:** يوجد **4 أنماط مختلفة** لقيود Dart SDK عبر الوحدات:

- `>=3.0.0 <4.0.0` - في: `alhai_core` (سطر 7)، `alhai_design_system` (سطر 7)، `customer_app` (سطر 8)، `distributor_portal` (سطر 8)، `driver_app` (سطر 8)، `super_admin` (سطر 8)
- `>=3.4.0 <4.0.0` - في: root (سطر 5)، `admin` (سطر 7)، `admin_lite` (سطر 7)، `cashier` (سطر 7)، `alhai_ai` (سطر 6)، `alhai_auth` (سطر 6)، `alhai_database` (سطر 6)، `alhai_l10n` (سطر 6)، `alhai_pos` (سطر 6)، `alhai_reports` (سطر 6)، `alhai_shared_ui` (سطر 6)، `alhai_sync` (سطر 6)
- `^3.8.0` - في: `alhai_services/pubspec.yaml` (سطر 7)

**الخطر:** ملفات pubspec.lock الفعلية تحل إلى `dart: ">=3.8.0 <4.0.0"` و `dart: ">=3.10.3 <4.0.0"` مما يعني أن القيود المعلنة (`>=3.0.0`) قديمة ومضللة. `alhai_services` يتطلب `^3.8.0` بينما الوحدات الأخرى تعلن `>=3.0.0` وهذا تناقض.

**التوصية:** توحيد جميع الوحدات على `>=3.4.0 <4.0.0` كحد أدنى أو الأفضل `^3.8.0` لتتوافق مع المتطلبات الفعلية.

---

### 2.2 تعارضات إصدارات الحزم المشتركة

#### مشكلة #2: تعارض إصدارات الحزم المعلنة (Declared Constraints)

| التصنيف | الخطورة |
|---------|---------|
| تعارض إصدارات | حرج |

**الحزم المتعارضة:**

| الحزمة | الوحدات بإصدارات مختلفة |
|--------|------------------------|
| `get_it` | `^7.6.4` (alhai_core سطر 15، admin سطر 52، admin_lite سطر 35، cashier سطر 49، customer_app سطر 26، distributor_portal سطر 25، driver_app سطر 26) vs `^7.7.0` (alhai_services سطر 19) |
| `injectable` | `^2.3.2` (alhai_core سطر 16، customer_app سطر 27، distributor_portal سطر 26، driver_app سطر 27) vs `^2.5.0` (alhai_services سطر 20) |
| `dio` | `^5.4.0` (alhai_core سطر 12، customer_app سطر 34، distributor_portal سطر 27، driver_app سطر 34، alhai_ai سطر 32، alhai_auth سطر 26، alhai_pos سطر 58) - لا تعارض لكن الإصدار المحلول 5.9.0/5.9.1 |
| `firebase_core` | `^2.24.2` (customer_app سطر 59، driver_app سطر 68) vs `^3.8.0` (admin سطر 55، admin_lite سطر 39، cashier سطر 53) |
| `flutter_lints` | `^3.0.1` (alhai_core سطر 31، alhai_design_system سطر 22، customer_app سطر 73، distributor_portal سطر 39، driver_app سطر 88، cashier سطر 62، super_admin سطر 42) vs `^6.0.0` (alhai_services سطر 29) |

**firebase_core هو الأخطر:** customer_app و driver_app يستخدمان `^2.24.2` (Firebase v2) بينما التطبيقات الجديدة (admin, admin_lite, cashier) تستخدم `^3.8.0` (Firebase v3). هذا تعارض كبير في الإصدارات.

---

#### مشكلة #3: إصدارات الحزم المحلولة مختلفة عبر lock files

| التصنيف | الخطورة |
|---------|---------|
| عدم اتساق | حرج |

**أمثلة من ملفات pubspec.lock:**

| الحزمة | alhai_core lock | apps/admin lock | apps/cashier lock |
|--------|----------------|-----------------|-------------------|
| `dio` | 5.9.0 | 5.9.1 | 5.9.1 |
| `drift` | غير موجود | 2.31.0 | 2.31.0 |
| `json_annotation` | 4.9.0 | 4.11.0 | 4.11.0 |
| `image` | 4.7.2 | 4.5.4 | 4.5.4 |
| `shared_preferences` | 2.5.3 | 2.5.4 | 2.5.4 |
| `ffi` | 2.1.5 | 2.2.0 | 2.2.0 |

**السبب:** كل وحدة لها `pubspec.lock` مستقل مما يؤدي لإصدارات مختلفة. هذا متوقع في بنية monorepo بدون Dart workspaces لكنه يسبب مشاكل محتملة في وقت التشغيل.

---

### 2.3 مشاكل الاعتماديات المكررة بين DI Frameworks

#### مشكلة #4: استخدام get_it + injectable مع flutter_riverpod في نفس الوقت

| التصنيف | الخطورة |
|---------|---------|
| تضارب معماري | حرج |

**الملفات المتأثرة:**
- `apps/admin/pubspec.yaml` سطر 51-52: `flutter_riverpod: ^2.4.9` و `get_it: ^7.6.4`
- `apps/admin_lite/pubspec.yaml` سطر 34-35: `flutter_riverpod: ^2.4.9` و `get_it: ^7.6.4`
- `apps/cashier/pubspec.yaml` سطر 48-49: `flutter_riverpod: ^2.4.9` و `get_it: ^7.6.4`
- `customer_app/pubspec.yaml` سطر 24-27: `flutter_riverpod`, `riverpod_annotation`, `get_it`, `injectable`
- `driver_app/pubspec.yaml` سطر 24-27: نفس الشيء
- `super_admin/pubspec.yaml` سطر 22-25: `flutter_riverpod`, `riverpod_annotation`, `get_it`, `injectable`

**المشكلة:** المشروع يستخدم **نظامين مختلفين لحقن الاعتماديات** في نفس الوقت:
1. **Riverpod** (flutter_riverpod + riverpod_annotation) - لإدارة الحالة
2. **GetIt + Injectable** - لحقن الاعتماديات التقليدي

هذا يسبب:
- تعقيد غير ضروري في الكود
- صعوبة في الصيانة والاختبار
- زيادة حجم التطبيق النهائي

**التوصية:** اختيار نظام واحد (الأفضل Riverpod) وإزالة get_it/injectable.

---

### 2.4 حزم ثقيلة يمكن استبدالها

#### مشكلة #5: حزمة `image` في alhai_core

| التصنيف | الخطورة |
|---------|---------|
| أداء | متوسط |

**الملف:** `alhai_core/pubspec.yaml` سطر 22
```yaml
image: ^4.1.0
```

**المشكلة:** حزمة `image` (محلولة إلى 4.7.2) هي حزمة ضخمة لمعالجة الصور بشكل كامل (decode/encode لعشرات الصيغ). إذا كان الاستخدام محدودا (مثل resize أو compress) فهناك بدائل أخف.

**التوصية:** التحقق من الاستخدام الفعلي. إذا كان لتحميل الصور فقط، يمكن إزالتها والاعتماد على `cached_network_image`.

---

#### مشكلة #6: حزمة `syncfusion_flutter_charts` في super_admin

| التصنيف | الخطورة |
|---------|---------|
| ترخيص / حجم | متوسط |

**الملف:** `super_admin/pubspec.yaml` سطر 35
```yaml
syncfusion_flutter_charts: ^31.1.19
```

**المشكلة:** حزمة Syncfusion تتطلب ترخيصا تجاريا للاستخدام التجاري. كما أنها ثقيلة جدا. المشروع يستخدم أيضا `fl_chart` (سطر 33) مما يعني وجود حزمتين للرسوم البيانية.

**التوصية:** توحيد استخدام `fl_chart` (مفتوحة المصدر، MIT) وإزالة `syncfusion_flutter_charts` لتجنب مشاكل الترخيص.

---

#### مشكلة #7: حزمة `flutter_background_geolocation` في driver_app

| التصنيف | الخطورة |
|---------|---------|
| ترخيص | متوسط |

**الملف:** `driver_app/pubspec.yaml` سطر 65
```yaml
flutter_background_geolocation: ^4.14.4
```

**المشكلة:** هذه الحزمة تتطلب ترخيصا تجاريا (Transistor Software License) للنشر في الإنتاج. يجب التأكد من وجود الترخيص.

---

### 2.5 تعارض إصدارات firebase_core

#### مشكلة #8: إصدارات Firebase متناقضة

| التصنيف | الخطورة |
|---------|---------|
| تعارض كبير | حرج |

| الوحدة | الإصدار المعلن | الإصدار المحلول |
|--------|---------------|-----------------|
| customer_app | `^2.24.2` (سطر 59) | 3.15.2 (في lock) |
| driver_app | `^2.24.2` (سطر 68) | غير متاح (لا lock حديث) |
| admin | `^3.8.0` (سطر 55) | 3.15.2 |
| admin_lite | `^3.8.0` (سطر 39) | 3.15.2 |
| cashier | `^3.8.0` (سطر 53) | 3.15.2 |

**المشكلة:** `customer_app` و `driver_app` يعلنان `^2.24.2` لكن الإصدار المحلول في Lock هو `3.15.2`. هذا يعني أن القيد `^2.24.2` لا يتوافق مع `3.15.2` (لأن `^2.24.2` = `>=2.24.2 <3.0.0`). إما أن الـ lock file قديم أو أن هناك خطأ. **يجب تحديث القيد إلى `^3.8.0`**.

**ملاحظة إضافية:** `firebase_messaging: ^14.7.10` و `flutter_local_notifications: ^16.3.0` في customer_app و driver_app أيضا قد تحتاج تحديث.

---

### 2.6 اعتماديات Path مقابل Pub

#### مشكلة #9: جميع الحزم الداخلية تستخدم path dependencies

| التصنيف | الخطورة |
|---------|---------|
| بنية المشروع | منخفض |

**الوضع الحالي:** جميع الحزم الداخلية (alhai_core, alhai_services, إلخ) تستخدم `path:` dependencies وهذا صحيح ومناسب لبنية monorepo مع Melos.

**ملاحظة:** المسارات النسبية صحيحة ومتسقة:
- التطبيقات في `apps/` تستخدم `../../alhai_core` و `../../packages/xxx`
- التطبيقات المستقلة (customer_app, driver_app, إلخ) تستخدم `../alhai_core` و `../packages/xxx` غير موجود

**مشكلة فرعية:** التطبيقات القديمة (customer_app, driver_app, distributor_portal, super_admin) ليست تحت `apps/` مما يجعل المسارات النسبية مختلفة. هذا يعقّد الصيانة.

---

### 2.7 مشاكل Linting غير متسقة

#### مشكلة #10: استخدام حزم linting مختلفة

| التصنيف | الخطورة |
|---------|---------|
| جودة الكود | متوسط |

| الحزمة | الوحدات |
|--------|---------|
| `flutter_lints: ^3.0.1` | alhai_core، alhai_design_system، customer_app، distributor_portal، driver_app، super_admin، cashier |
| `flutter_lints: ^6.0.0` | alhai_services |
| `lints: ^3.0.0` | admin، admin_lite (مباشر)، alhai_ai، alhai_auth، alhai_database، alhai_pos، alhai_reports، alhai_shared_ui |
| بدون linting | alhai_sync |

**المشكلة:**
1. `flutter_lints` و `lints` هما حزمتان مختلفتان (الأولى تعتمد على الثانية)
2. `alhai_services` يستخدم `^6.0.0` بينما البقية `^3.0.1` - فرق كبير في الإصدارات
3. `alhai_sync` لا يحتوي على أي حزمة linting

**التوصية:** توحيد جميع الوحدات على `lints: ^3.0.0` أو `flutter_lints: ^3.0.1` (أو الأحدث) مع ملف `analysis_options.yaml` مشترك على مستوى الـ root.

---

### 2.8 اعتماديات تطوير (dev_dependencies)

#### مشكلة #11: عدم اتساق في أدوات الاختبار

| التصنيف | الخطورة |
|---------|---------|
| اختبارات | متوسط |

| الأداة | الوحدات |
|--------|---------|
| `mocktail: ^1.0.4` | alhai_core، alhai_design_system، admin، admin_lite، cashier، alhai_ai، alhai_auth، alhai_database، alhai_l10n، alhai_pos، alhai_reports، alhai_shared_ui، alhai_sync |
| `mockito: ^5.4.4` | customer_app (سطر 76)، driver_app (سطر 91) |
| `faker: ^2.1.0` | customer_app (سطر 77)، driver_app (سطر 92) |

**المشكلة:** المشروع يستخدم **أداتين مختلفتين للـ mocking**: `mocktail` (بدون code generation) و `mockito` (مع code generation). هذا يسبب عدم اتساق في أنماط كتابة الاختبارات.

**التوصية:** توحيد على `mocktail` لأنه لا يتطلب code generation ومتوافق أكثر مع بنية المشروع.

---

#### مشكلة #12: build_runner غير موجود في بعض الوحدات التي تحتاجه

| التصنيف | الخطورة |
|---------|---------|
| بناء الكود | متوسط |

| الوحدة | لديها build_runner | تحتاج code generation |
|--------|-------------------|-----------------------|
| alhai_core | نعم (سطر 27) | نعم (freezed, json_serializable, injectable) |
| alhai_database | نعم (سطر 24) | نعم (drift_dev) |
| customer_app | نعم (سطر 68) | نعم (riverpod_generator, injectable_generator) |
| driver_app | نعم (سطر 83) | نعم |
| distributor_portal | نعم (سطر 38) | نعم |
| super_admin | نعم (سطر 41) | نعم |
| admin | لا | ربما (يستخدم drift مباشرة) |
| admin_lite | لا | ربما |
| cashier | لا | ربما |

**ملاحظة:** admin, admin_lite, cashier تستخدم `drift: ^2.14.1` لكن ليس لديها `build_runner` أو `drift_dev` في dev_dependencies. إذا كانت تعتمد على الكود المولد من `alhai_database` فقد يكون ذلك مقبولا.

---

### 2.9 Drift Version Mismatch

#### مشكلة #13: تعارض إصدار drift المعلن مقابل المحلول

| التصنيف | الخطورة |
|---------|---------|
| قاعدة البيانات | حرج |

**الملفات المتأثرة:**
- `packages/alhai_database/pubspec.yaml` سطر 12: `drift: ^2.14.1`
- `packages/alhai_database/pubspec.yaml` سطر 25: `drift_dev: ^2.14.1`
- الإصدار المحلول في lock files: `drift: 2.31.0`

**المشكلة:** القيد `^2.14.1` يسمح بالتحديث إلى `2.31.0` لكن `drift_dev: ^2.14.1` يجب أن يتطابق مع إصدار `drift`. فرق كبير (2.14 vs 2.31) قد يسبب مشاكل في الكود المولد.

**التوصية:** تحديث القيود إلى `^2.31.0` لتتوافق مع الإصدارات المحلولة فعلا.

---

### 2.10 اعتماديات مشتركة بين الوحدات

#### مشكلة #14: تكرار الاعتماديات في التطبيقات بدلا من الحزم المشتركة

| التصنيف | الخطورة |
|---------|---------|
| هيكل | متوسط |

**الحزم المكررة بكثافة:**

| الحزمة | عدد الوحدات التي تعلنها مباشرة |
|--------|-------------------------------|
| `flutter_riverpod` | 10 وحدات |
| `get_it` | 10 وحدات |
| `go_router` | 9 وحدات |
| `shared_preferences` | 9 وحدات |
| `supabase_flutter` | 9 وحدات |
| `drift` | 7 وحدات |
| `intl` | 7 وحدات |
| `uuid` | 7 وحدات |
| `cached_network_image` | 5 وحدات |
| `dio` | 6 وحدات |
| `flutter_secure_storage` | 6 وحدات |
| `firebase_core` | 5 وحدات |
| `crypto` | 3 وحدات |

**المشكلة:** كل من هذه الحزم يجب أن تُعلن مرة واحدة في حزمة مشتركة (مثل alhai_core) وتنتقل تلقائيا للتطبيقات عبر transitive dependencies. إعادة الإعلان تزيد خطر تعارض الإصدارات.

**التوصية:** نقل الاعتماديات المشتركة إلى `alhai_core` أو إنشاء حزمة `alhai_deps` مشتركة.

---

### 2.11 حزم غير مستخدمة محتملة

#### مشكلة #15: اعتماديات قد تكون غير مستخدمة

| التصنيف | الخطورة |
|---------|---------|
| تنظيف | منخفض |

| الحزمة | الوحدة | الملاحظة |
|--------|--------|----------|
| `excel: ^4.0.2` | distributor_portal (سطر 33) | حزمة ثقيلة، تحقق من الاستخدام الفعلي |
| `data_table_2: ^2.5.10` | distributor_portal (سطر 31)، super_admin (سطر 34) | تحقق إذا كانت DataTable2 مستخدمة فعلا أم يمكن الاكتفاء بـ DataTable العادي |
| `riverpod_annotation: ^2.3.3` | customer_app (سطر 25)، driver_app (سطر 25)، super_admin (سطر 23) | تحتاج riverpod_generator في dev_dependencies للعمل |
| `golden_toolkit: ^0.15.0` | alhai_design_system (سطر 24) | تحقق إذا كانت Golden Tests مكتوبة فعلا |

---

### 2.12 Melos و Workspace Configuration

#### مشكلة #16: التطبيقات القديمة خارج مسار packages/apps

| التصنيف | الخطورة |
|---------|---------|
| بنية المشروع | متوسط |

**الملف:** `melos.yaml` سطر 3-8
```yaml
packages:
  - apps/**
  - packages/**
  - alhai_core
  - alhai_services
  - alhai_design_system
```

**المشكلة:** `customer_app/`، `distributor_portal/`، `driver_app/`، `super_admin/` غير مشمولة في Melos! لا تقع تحت `apps/` ولا `packages/` ولا مذكورة بشكل فردي.

**النتيجة:** أوامر `melos analyze`، `melos test`، `melos format` لن تعمل على هذه التطبيقات. كما أن `melos bootstrap` لن يدير اعتمادياتها.

**التوصية:** إضافة هذه المسارات إلى melos.yaml:
```yaml
packages:
  - apps/**
  - packages/**
  - alhai_core
  - alhai_services
  - alhai_design_system
  - customer_app
  - distributor_portal
  - driver_app
  - super_admin
```

---

### 2.13 إصدارات الحزم - مقارنة المعلن مع المحلول

#### مشكلة #17: قيود إصدارات فضفاضة جدا

| التصنيف | الخطورة |
|---------|---------|
| استقرار | منخفض |

| الحزمة | القيد المعلن | المحلول فعليا | الفرق |
|--------|-------------|---------------|-------|
| `drift` | `^2.14.1` | `2.31.0` | +17 إصدارات فرعية |
| `supabase_flutter` | `^2.0.0` (alhai_core) / `^2.3.4` (التطبيقات) | `2.12.0` | +12/+9 |
| `go_router` | `^13.0.0` | `13.2.5` | طبيعي |
| `flutter_riverpod` | `^2.4.9` | `2.6.1` | طبيعي |
| `firebase_core` | `^3.8.0` | `3.15.2` | +7 |

**ملاحظة:** `alhai_core` يعلن `supabase_flutter: ^2.0.0` (سطر 20) وهو فضفاض جدا. التطبيقات تعلن `^2.3.4` وهو أفضل لكن لا يزال فضفاضا.

---

### 2.14 الحزم التي تحتاج تراخيص تجارية

#### مشكلة #18: حزم تتطلب تراخيص خاصة

| التصنيف | الخطورة |
|---------|---------|
| قانوني | حرج |

| الحزمة | الوحدة | نوع الترخيص |
|--------|--------|------------|
| `syncfusion_flutter_charts: ^31.1.19` | super_admin (سطر 35) | Syncfusion Community/Commercial License - مجاني للشركات بأقل من $1M إيراد سنوي |
| `flutter_background_geolocation: ^4.14.4` | driver_app (سطر 65) | Transistor Software License - تجاري |
| `sqlcipher_flutter_libs: ^0.6.5` | alhai_database (سطر 14) | BSD-style لكن SQLCipher نفسها لها قيود |

**التوصية:** التأكد من الحصول على التراخيص المناسبة قبل النشر التجاري.

---

### 2.15 Dependency Overrides

#### ملاحظة #19: لا يوجد dependency_overrides

| التصنيف | الخطورة |
|---------|---------|
| إيجابي | لا يوجد مشكلة |

لم يتم العثور على أي `dependency_overrides` في أي ملف pubspec.yaml. هذا جيد ويعني عدم وجود تجاوزات قسرية.

---

### 2.16 الحزم بدون إصدار (version) في pubspec.yaml

#### مشكلة #20: وحدات بدون تحديد إصدار

| التصنيف | الخطورة |
|---------|---------|
| بنية | منخفض |

| الوحدة | لديها version |
|--------|--------------|
| alhai_core | `1.0.0` |
| alhai_design_system | `1.0.0` |
| alhai_services | `1.0.0` |
| admin | `1.0.0+1` |
| admin_lite | لا |
| cashier | `1.0.0+1` |
| customer_app | `1.0.0+1` |
| distributor_portal | `1.0.0+1` |
| driver_app | `1.0.0+1` |
| super_admin | `1.0.0+1` |
| alhai_ai | لا |
| alhai_auth | لا |
| alhai_database | لا |
| alhai_l10n | لا |
| alhai_pos | لا |
| alhai_reports | لا |
| alhai_shared_ui | لا |
| alhai_sync | لا |

**المشكلة:** 8 حزم بدون `version`. Lock files تظهر `version: "0.0.0"` لها. يفضل تحديد إصدار لكل حزمة للتتبع.

---

### 2.17 شجرة الاعتماديات الداخلية (Internal Dependency Tree)

#### مشكلة #21: تعقيد شجرة الاعتماديات الداخلية

| التصنيف | الخطورة |
|---------|---------|
| معمارية | متوسط |

```
alhai_core (قاعدة - لا تعتمد على حزم داخلية)
  |
  +-- alhai_services (يعتمد على alhai_core)
  |
  +-- alhai_design_system (مستقل - لا يعتمد على حزم داخلية)
  |
  +-- alhai_database (مستقل)
  |
  +-- alhai_l10n (مستقل)
  |
  +-- alhai_sync (يعتمد على alhai_database)
  |
  +-- alhai_auth (يعتمد على alhai_core, alhai_database, alhai_l10n, alhai_design_system)
  |
  +-- alhai_shared_ui (يعتمد على alhai_core, alhai_services, alhai_design_system, alhai_l10n, alhai_database, alhai_sync, alhai_auth)
  |
  +-- alhai_pos (يعتمد على alhai_core, alhai_services, alhai_design_system, alhai_l10n, alhai_database, alhai_sync, alhai_auth, alhai_shared_ui)
  |
  +-- alhai_ai (يعتمد على alhai_core, alhai_services, alhai_design_system, alhai_l10n, alhai_database, alhai_shared_ui, alhai_auth)
  |
  +-- alhai_reports (يعتمد على alhai_core, alhai_services, alhai_design_system, alhai_l10n, alhai_database, alhai_shared_ui, alhai_auth)
```

**المشكلة:** `alhai_shared_ui` يعتمد على **7 حزم داخلية** وهو كثير. `alhai_pos` يعتمد على **8 حزم**. هذا يخلق شجرة اعتماديات معقدة ويجعل التغييرات في الحزم الأساسية تؤثر على كل شيء.

**التوصية:** تقليل اعتماديات `alhai_shared_ui` بإزالة الاعتمادية على `alhai_sync` إذا لم تكن ضرورية.

---

### 2.18 حزم مفقودة محتملة

#### مشكلة #22: حزم Flutter SDK مفقودة

| التصنيف | الخطورة |
|---------|---------|
| نقص | منخفض |

| الوحدة | flutter_localizations مفقود |
|--------|---------------------------|
| alhai_core | نعم (ربما غير مطلوب) |
| alhai_design_system | نعم (ربما غير مطلوب) |
| alhai_services | نعم |
| alhai_ai | نعم (يعتمد على alhai_l10n لكن لا يعلن flutter_localizations) |

**ملاحظة:** هذا ليس بالضرورة مشكلة لأن flutter_localizations ينتقل عبر الاعتماديات. لكن في بعض الحزم المستقلة (alhai_l10n) تم إعلانها صراحة (سطر 12).

---

### 2.19 تكرار وظيفي عبر الحزم

#### مشكلة #23: تكرار وظائف الرسوم البيانية

| التصنيف | الخطورة |
|---------|---------|
| تكرار | منخفض |

- `super_admin/pubspec.yaml`: `fl_chart: ^0.65.0` (سطر 33) + `syncfusion_flutter_charts: ^31.1.19` (سطر 35)
- `distributor_portal/pubspec.yaml`: `fl_chart: ^0.65.0` (سطر 30)

**حزمتان للرسوم البيانية** في super_admin. يجب اختيار واحدة.

---

#### مشكلة #24: تكرار حزم Excel/CSV

| التصنيف | الخطورة |
|---------|---------|
| تكرار | منخفض |

- `packages/alhai_database/pubspec.yaml`: `csv: ^6.0.0` (سطر 19)
- `apps/cashier/pubspec.yaml`: `csv: ^6.0.0` (سطر 54)
- `distributor_portal/pubspec.yaml`: `excel: ^4.0.2` (سطر 33)

---

### 2.20 أمن الاعتماديات

#### مشكلة #25: حزمة flutter_secure_storage على الويب

| التصنيف | الخطورة |
|---------|---------|
| أمني | متوسط |

**الملفات:** `alhai_core/pubspec.yaml` سطر 18، `admin/pubspec.yaml` سطر 47، `admin_lite/pubspec.yaml` سطر 33، `cashier/pubspec.yaml` سطر 42، `customer_app/pubspec.yaml` سطر 38، `driver_app/pubspec.yaml` سطر 38، `alhai_auth/pubspec.yaml` سطر 22

**المشكلة:** `flutter_secure_storage` على الويب يستخدم localStorage مع base64 encoding وهو **غير آمن حقا** على الويب. بالنسبة للتطبيقات التي تعمل على الويب (admin, super_admin, distributor_portal) يجب استخدام بدائل مثل encrypted cookies أو الاعتماد على Supabase session management.

---

#### مشكلة #26: حزمة crypto مضمنة مع Supabase

| التصنيف | الخطورة |
|---------|---------|
| تكرار | منخفض |

**الملفات:** `alhai_core/pubspec.yaml` سطر 21، `alhai_services/pubspec.yaml` سطر 24، `alhai_auth/pubspec.yaml` سطر 25

`crypto` هي اعتمادية transitive من `supabase_flutter`. إعلانها مباشرة مقبول إذا كان الكود يستخدمها مباشرة، لكن يجب التحقق.

---

### 2.21 Flutter SDK Constraint المفقود

#### مشكلة #27: معظم الوحدات لا تعلن Flutter SDK constraint

| التصنيف | الخطورة |
|---------|---------|
| توافقية | منخفض |

فقط وحدتان تعلنان Flutter SDK constraint:
- `alhai_design_system/pubspec.yaml` سطر 8: `flutter: ">=3.10.0"`
- `alhai_services/pubspec.yaml` سطر 8: `flutter: '>=3.29.0'`

**التوصية:** إضافة Flutter SDK constraint لجميع الوحدات لمنع مشاكل التوافقية.

---

### 2.22 تطبيقات بدون pubspec.lock في المستودع

#### مشكلة #28: عدم اتساق في commit لملفات lock

| التصنيف | الخطورة |
|---------|---------|
| بنية | منخفض |

جميع الوحدات الـ 19 لديها `pubspec.lock`. هذا جيد للتطبيقات (يضمن إعادة إنتاج البناء) لكن للحزم (packages) يفضل عادة عدم commit الـ lock file. لكن في بنية monorepo هذا مقبول.

---

## 3. جدول ملخص جميع الحزم مع إصداراتها لكل وحدة

### 3.1 الاعتماديات الرئيسية (dependencies)

| الحزمة | core | services | design | admin | lite | cashier | customer | distrib | driver | super | ai | auth | database | l10n | pos | reports | shared_ui | sync |
|--------|------|----------|--------|-------|------|---------|----------|---------|--------|-------|-----|------|----------|------|-----|---------|-----------|------|
| flutter | Y | Y | Y | Y | Y | Y | Y | Y | Y | Y | Y | Y | Y | Y | Y | Y | Y | Y |
| flutter_localizations | - | - | - | Y | Y | Y | Y | Y | Y | Y | - | - | - | Y | - | - | - | - |
| alhai_core | - | Y | - | Y | Y | Y | Y | Y | Y | Y | Y | Y | - | - | Y | Y | Y | - |
| alhai_services | - | - | - | Y | Y | Y | Y | Y | Y | Y | Y | - | - | - | Y | Y | Y | - |
| alhai_design_system | - | - | - | Y | Y | Y | Y | Y | Y | Y | Y | Y | - | - | Y | Y | Y | - |
| alhai_database | - | - | - | Y | Y | Y | - | - | - | - | Y | Y | - | - | Y | Y | Y | - |
| alhai_sync | - | - | - | Y | Y | Y | - | - | - | - | - | - | - | - | Y | - | Y | - |
| alhai_l10n | - | - | - | Y | Y | Y | - | - | - | - | Y | Y | - | - | Y | Y | Y | - |
| alhai_auth | - | - | - | Y | Y | Y | - | - | - | - | Y | - | - | - | Y | Y | Y | - |
| alhai_shared_ui | - | - | - | Y | Y | Y | - | - | - | - | Y | - | - | - | Y | Y | - | - |
| alhai_pos | - | - | - | Y | - | Y | - | - | - | - | - | - | - | - | - | - | - | - |
| alhai_ai | - | - | - | Y | Y | - | - | - | - | - | - | - | - | - | - | - | - | - |
| alhai_reports | - | - | - | Y | Y | Y | - | - | - | - | - | - | - | - | - | - | - | - |
| flutter_riverpod | - | - | - | ^2.4.9 | ^2.4.9 | ^2.4.9 | ^2.4.9 | ^2.4.9 | ^2.4.9 | ^2.4.9 | ^2.4.9 | ^2.4.9 | - | ^2.4.9 | ^2.4.9 | ^2.4.9 | ^2.4.9 | - |
| get_it | ^7.6.4 | ^7.7.0 | - | ^7.6.4 | ^7.6.4 | ^7.6.4 | ^7.6.4 | ^7.6.4 | ^7.6.4 | ^7.6.4 | ^7.6.4 | - | - | - | ^7.6.4 | ^7.6.4 | ^7.6.4 | - |
| injectable | ^2.3.2 | ^2.5.0 | - | - | - | - | ^2.3.2 | ^2.3.2 | ^2.3.2 | ^2.3.2 | - | - | - | - | - | - | - | - |
| go_router | - | - | - | ^13.0.0 | ^13.0.0 | ^13.0.0 | ^13.0.0 | ^13.0.0 | ^13.0.0 | ^13.0.0 | ^13.0.0 | ^13.0.0 | - | - | ^13.0.0 | ^13.0.0 | ^13.0.0 | - |
| supabase_flutter | ^2.0.0 | - | - | ^2.3.4 | ^2.3.4 | ^2.3.4 | ^2.3.4 | ^2.3.4 | ^2.3.4 | ^2.3.4 | ^2.3.4 | ^2.3.4 | - | - | ^2.3.4 | - | ^2.3.4 | ^2.3.4 |
| shared_preferences | ^2.2.2 | - | - | ^2.2.2 | ^2.2.2 | ^2.2.2 | ^2.2.2 | ^2.2.2 | ^2.2.2 | ^2.2.2 | ^2.2.2 | ^2.2.2 | - | ^2.2.2 | ^2.2.2 | - | ^2.2.2 | - |
| dio | ^5.4.0 | - | - | - | - | - | ^5.4.0 | ^5.4.0 | ^5.4.0 | ^5.4.0 | ^5.4.0 | ^5.4.0 | - | - | ^5.4.0 | - | - | - |
| drift | - | - | - | ^2.14.1 | - | ^2.14.1 | - | - | - | - | ^2.14.1 | ^2.14.1 | ^2.14.1 | - | ^2.14.1 | ^2.14.1 | ^2.14.1 | ^2.14.1 |
| flutter_secure_storage | ^9.0.0 | - | - | ^9.0.0 | ^9.0.0 | ^9.0.0 | ^9.0.0 | - | ^9.0.0 | - | - | ^9.0.0 | - | - | - | - | - | - |
| uuid | - | ^4.4.0 | - | ^4.3.3 | - | ^4.3.3 | ^4.3.3 | - | ^4.3.3 | - | - | ^4.3.3 | ^4.3.3 | - | ^4.3.3 | - | ^4.3.3 | ^4.3.3 |
| intl | - | - | - | - | - | - | ^0.20.2 | ^0.20.2 | ^0.20.2 | ^0.20.2 | ^0.20.2 | - | - | ^0.20.2 | ^0.20.2 | ^0.20.2 | ^0.20.2 | - |
| cached_network_image | - | - | ^3.3.0 | - | - | - | ^3.3.1 | - | ^3.3.1 | - | - | ^3.3.1 | - | - | ^3.3.1 | - | ^3.3.1 | - |
| crypto | ^3.0.3 | ^3.0.3 | - | - | - | - | - | - | - | - | - | ^3.0.3 | - | - | - | - | - | - |
| firebase_core | - | - | - | ^3.8.0 | ^3.8.0 | ^3.8.0 | ^2.24.2 | - | ^2.24.2 | - | - | - | - | - | - | - | - | - |
| image | ^4.1.0 | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |
| freezed_annotation | ^2.4.1 | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |
| json_annotation | ^4.9.0 | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |
| image_picker | - | - | - | ^1.0.7 | - | - | ^1.0.7 | - | ^1.0.7 | - | - | - | - | - | - | - | - | - |
| connectivity_plus | - | - | - | - | - | - | ^5.0.2 | - | ^5.0.2 | - | - | - | - | - | - | - | - | ^5.0.2 |
| riverpod_annotation | - | - | - | - | - | - | ^2.3.3 | - | ^2.3.3 | ^2.3.3 | - | - | - | - | - | - | - | - |
| pdf | - | - | - | - | - | - | - | - | - | - | - | - | - | - | ^3.10.8 | ^3.10.8 | - | - |
| printing | - | - | - | - | - | - | - | - | - | - | - | - | - | - | ^5.12.0 | ^5.12.0 | - | - |
| fl_chart | - | - | - | - | - | - | - | ^0.65.0 | - | ^0.65.0 | - | - | - | - | - | - | - | - |
| csv | - | - | - | - | - | ^6.0.0 | - | - | - | - | - | - | ^6.0.0 | - | - | - | - | - |
| local_auth | - | - | - | - | - | - | - | - | - | - | - | ^2.1.8 | - | - | - | - | - | - |
| shimmer | - | - | - | - | - | - | ^3.0.0 | - | ^3.0.0 | - | - | - | - | - | - | - | ^3.0.0 | - |
| google_maps_flutter | - | - | - | - | - | - | ^2.5.0 | - | ^2.5.0 | - | - | - | - | - | - | - | - | - |
| geolocator | - | - | - | - | - | - | ^10.1.0 | - | ^10.1.0 | - | - | - | - | - | - | - | - | - |
| permission_handler | - | - | - | - | - | - | ^11.2.0 | - | ^11.2.0 | - | - | - | - | - | - | - | - | - |
| firebase_messaging | - | - | - | - | - | - | ^14.7.10 | - | ^14.7.10 | - | - | - | - | - | - | - | - | - |
| flutter_local_notifications | - | - | - | - | - | - | ^16.3.0 | - | ^16.3.0 | - | - | - | - | - | - | - | - | - |
| flutter_spinkit | - | - | - | - | - | - | ^5.2.0 | - | ^5.2.0 | - | - | - | - | - | - | - | - | - |
| data_table_2 | - | - | - | - | - | - | - | ^2.5.10 | - | ^2.5.10 | - | - | - | - | - | - | - | - |
| file_picker | - | - | - | - | - | - | - | ^8.0.0 | - | - | - | - | - | - | - | - | - | - |
| excel | - | - | - | - | - | - | - | ^4.0.2 | - | - | - | - | - | - | - | - | - | - |
| syncfusion_flutter_charts | - | - | - | - | - | - | - | - | - | ^31.1.19 | - | - | - | - | - | - | - | - |
| camera | - | - | - | - | - | - | - | - | ^0.10.5+9 | - | - | - | - | - | - | - | - | - |
| signature | - | - | - | - | - | - | - | - | ^5.4.1 | - | - | - | - | - | - | - | - | - |
| flutter_polyline_points | - | - | - | - | - | - | - | - | ^2.0.0 | - | - | - | - | - | - | - | - | - |
| flutter_background_service | - | - | - | - | - | - | - | - | ^5.0.1 | - | - | - | - | - | - | - | - | - |
| flutter_background_geolocation | - | - | - | - | - | - | - | - | ^4.14.4 | - | - | - | - | - | - | - | - | - |
| qr_flutter | - | - | - | - | - | - | - | - | - | - | - | - | - | - | ^4.1.0 | - | - | - |
| url_launcher | - | - | - | - | - | - | - | - | - | - | - | - | - | - | ^6.2.4 | - | - | - |
| drift_flutter | - | - | - | - | - | - | - | - | - | - | - | - | ^0.2.4 | - | - | - | - | - |
| sqlcipher_flutter_libs | - | - | - | - | - | - | - | - | - | - | - | - | ^0.6.5 | - | - | - | - | - |
| path | - | - | - | - | - | - | - | - | - | - | - | - | ^1.8.3 | - | - | - | - | - |
| path_provider | - | - | - | - | - | - | - | - | - | - | - | - | ^2.1.1 | - | - | ^2.1.2 | - | - |
| flutter_cache_manager | - | - | ^3.3.1 | - | - | - | - | - | - | - | - | - | - | - | - | - | - | - |

---

## 4. التوصيات مع أولوية التنفيذ

### أولوية عاجلة (خلال أسبوع)

| # | التوصية | الملفات المتأثرة |
|---|---------|------------------|
| 1 | تحديث `firebase_core` في customer_app و driver_app من `^2.24.2` إلى `^3.8.0` | `customer_app/pubspec.yaml`، `driver_app/pubspec.yaml` |
| 2 | توحيد قيود Dart SDK على `>=3.4.0 <4.0.0` في جميع الوحدات | جميع ملفات pubspec.yaml |
| 3 | إضافة التطبيقات القديمة إلى melos.yaml | `melos.yaml` |
| 4 | التحقق من تراخيص syncfusion و flutter_background_geolocation | `super_admin/pubspec.yaml`، `driver_app/pubspec.yaml` |

### أولوية عالية (خلال أسبوعين)

| # | التوصية | الملفات المتأثرة |
|---|---------|------------------|
| 5 | توحيد حزمة DI (إزالة get_it/injectable والاعتماد على Riverpod فقط) | جميع التطبيقات |
| 6 | إزالة syncfusion_flutter_charts والاكتفاء بـ fl_chart | `super_admin/pubspec.yaml` |
| 7 | توحيد حزمة linting (استخدام `lints: ^3.0.0` في الجميع) | جميع ملفات pubspec.yaml |
| 8 | تحديث قيود drift إلى `^2.31.0` مع drift_dev | `packages/alhai_database/pubspec.yaml` |

### أولوية متوسطة (خلال شهر)

| # | التوصية | الملفات المتأثرة |
|---|---------|------------------|
| 9 | نقل الاعتماديات المكررة إلى حزم مشتركة فقط | جميع الوحدات |
| 10 | توحيد على mocktail وإزالة mockito | `customer_app/pubspec.yaml`، `driver_app/pubspec.yaml` |
| 11 | إضافة Flutter SDK constraint لجميع الوحدات | جميع ملفات pubspec.yaml |
| 12 | إضافة version لجميع الحزم | 8 حزم بدون version |
| 13 | نقل customer_app, driver_app, distributor_portal, super_admin تحت apps/ | هيكل المجلدات |

### أولوية منخفضة (خلال ربع)

| # | التوصية | الملفات المتأثرة |
|---|---------|------------------|
| 14 | مراجعة حزمة image في alhai_core | `alhai_core/pubspec.yaml` |
| 15 | إضافة linting لـ alhai_sync | `packages/alhai_sync/pubspec.yaml` |
| 16 | تقييد قيود supabase_flutter من `^2.0.0` إلى `^2.3.4` في alhai_core | `alhai_core/pubspec.yaml` |

---

## 5. ملخص الأرقام

| المقياس | القيمة |
|---------|--------|
| إجمالي الوحدات (modules) | 19 |
| إجمالي الحزم المباشرة الفريدة (direct dependencies) | ~55 حزمة |
| حزم تحتاج ترخيص تجاري | 2-3 |
| تعارضات إصدارات حرجة | 4 (firebase_core, get_it, injectable, flutter_lints) |
| أنماط Dart SDK مختلفة | 3 |
| وحدات بدون version | 8 |
| وحدات بدون linting | 1 (alhai_sync) |
| حزم DI متعارضة | 2 (Riverpod + GetIt) |
| حزم رسوم بيانية مكررة | 2 في super_admin |
| أدوات mocking مختلفة | 2 (mocktail + mockito) |
| التطبيقات غير مشمولة في Melos | 4 |

---

## 6. التقييم النهائي

### التقييم: 5.5 / 10

| المعيار | الدرجة (من 10) | الملاحظة |
|---------|----------------|----------|
| اتساق الإصدارات | 4 | تعارضات firebase_core، SDK constraints مختلفة |
| بنية الـ Monorepo | 6 | Melos موجود لكن لا يشمل كل التطبيقات |
| أمن الاعتماديات | 5 | flutter_secure_storage على الويب، تراخيص غير مؤكدة |
| تكرار الحزم | 4 | اعتماديات مكررة كثيرا عبر الوحدات |
| التوافقية | 6 | SDK constraints مرنة لكن غير متسقة |
| اتساق أدوات التطوير | 5 | linting وmocking غير متسقين |
| وضوح شجرة الاعتماديات | 6 | path dependencies واضحة لكن معقدة |
| الصيانة | 5 | كثير من النقاط تحتاج تنظيف |
| التوثيق | 7 | pubspec.yaml فيها وصف جيد |
| أفضل الممارسات | 5 | DI مزدوج، عدم توحيد |

---

*نهاية التقرير - تم إنشاؤه بواسطة Claude Opus 4.6*
