# استلام مشروع: Alhai Admin

## هويتك ودورك

أنت مهندس Flutter/Dart أول مسؤول عن تطبيق **Admin** — لوحة الإدارة الكاملة للمتاجر. هذا التطبيق الأوسع نطاقاً في المشروع: إدارة المنتجات، الطلبات، الموظفين، الموردين، التقارير، المالية، والتسويق.

## القواعد الصارمة — غير قابلة للتفاوض

1. **لا بيانات وهمية نهائياً** — سابقاً كانت شاشة `online_orders_screen.dart` تعرض طلبات مزيفة ("أحمد محمد", "0501234567") عند فراغ القاعدة. تم حذفها. **لا تُرجِعها**.
2. **لا silent error swallowing جديد** — حالياً يوجد 6 مواضع `catch (_)` في الشاشات — لا تُضف المزيد
3. **لا تلمس التقارير المالية بدون اختبار** — أي تغيير في `lib/screens/reports/` يحتاج اختبار unit + widget
4. **لا تُعدّل structure الـ migrations** — أنشئ migrations جديدة فقط
5. **لا تستخدم `print()`** — استعمل `debugPrint` أو logger
6. **لا تعرض معلومات حساسة في logs** — لا أرقام هواتف كاملة، لا أرصدة، لا tokens

## الحالة الفعلية عند الاستلام (2026-04-10)

### ما هو سليم
- **361 اختبار ناجح**، 0 فشل
- **7,370 سطر كود اختبار** في 72 ملف
- **Sentry مُدمج حديثاً** — `lib/core/services/sentry_service.dart` + `main.dart`
- **DSN env var**: `SENTRY_DSN_ADMIN`
- **Firebase** مُدمَج جزئياً
- **dart fix --apply**: تم تنفيذه مؤخراً — 24 إصلاح deprecation في 16 ملف
- **Integration tests**: `critical_flow_test.dart` + `offline_sync_test.dart` (15 + 12 اختبار)

### ما تم إصلاحه مؤخراً (لا تُرجعه)
- ❌ **شاشة `online_orders_screen.dart`**: كانت تعرض `_OnlineOrder('ORD-001', 'أحمد محمد', '0501234567', ...)` عند فراغ القاعدة. الآن `_orders = []` مع `AppEmptyState.noOrders()` تلقائياً.

### البلوكرز المؤكَّدة

#### 1. Android build فشل محلياً (P0)
الموقع: `apps/admin/android/app/build.gradle.kts` — السطور 10-12
نفس مشكلة Kotlin imports في cashier.
**تحقّق أولاً**: `cd apps/admin && flutter build apk --debug --no-tree-shake-icons`

#### 2. لا iOS project
`apps/admin/ios/` غير موجود. لا يمكن النشر على App Store.

#### 3. Silent error catches (6 مواضع)
لا تُضف المزيد، لا تحذف بدون مراجعة السياق:
- `lib/screens/ecommerce/delivery_zones_screen.dart:92` — "Fallback to empty on error"
- `lib/screens/ecommerce/online_orders_screen.dart:101` — "On error keep whatever we had"
- `lib/screens/products/product_form_screen.dart:81` — "Categories loading failed silently"
- `lib/screens/marketing/gift_cards_screen.dart:103` — "Keep existing data on error"
- `lib/screens/settings/business/store_settings_screen.dart:97` — "Supabase unavailable - keep defaults"
- `lib/screens/products/categories_screen.dart:59,73` — hardcoded fallback colors/icons

**القاعدة**: هذه مقبولة كـ legacy. أي جديد يحتاج logging صريح + report إلى Sentry.

#### 4. Media placeholder strings
`lib/screens/media/media_library_screen.dart` — السطور 375, 395, 511 — سلاسل placeholder "Image management placeholder"
**القاعدة**: احذفها فقط عند استبدالها بتنفيذ حقيقي، لا تتركها.

#### 5. أيقونة Flutter الافتراضية (نفس مشكلة cashier)

#### 6. Version محبوسة
`pubspec.yaml` → `version: 1.0.0-beta.1+1`

## البنية المعمارية

```
apps/admin/
├── lib/
│   ├── main.dart                     # Sentry + Firebase + Supabase init
│   ├── core/
│   │   └── services/sentry_service.dart
│   ├── screens/                      # ~70 screens
│   │   ├── dashboard/
│   │   ├── products/                 # products, categories, stock
│   │   ├── orders/
│   │   ├── purchases/                # suppliers, purchase orders
│   │   ├── employees/
│   │   ├── loyalty/
│   │   ├── marketing/                # discounts, coupons, gifts
│   │   ├── ecommerce/                # online_orders, delivery_zones
│   │   ├── reports/                  # ⚠️ critical — financial
│   │   ├── settings/
│   │   └── wallet/
│   ├── router/                       # GoRouter with nested routes
│   └── providers/
├── integration_test/                 # critical_flow + offline_sync
├── test/                             # 72 files
└── android/app/build.gradle.kts      # ⚠️ needs Kotlin imports fix
```

## التبعيات من monorepo

- `alhai_core`, `alhai_auth`, `alhai_database`, `alhai_sync`
- `alhai_pos`, `alhai_zatca`
- `alhai_shared_ui`, `alhai_design_system`, `alhai_l10n`
- `alhai_reports` — خاص بلوحة الإدارة
- `alhai_ai` — ميزات التحليل

## خطوات الاستلام الإلزامية

### 1. التحقق من الحالة
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai
git status
git log --oneline -20 apps/admin/
cd apps/admin
flutter pub get
dart analyze 2>&1 | tail -40
```

**توقّع**: ~63 infos (كلها Flutter deprecations). 0 errors.

### 2. تشغيل الاختبارات
```bash
flutter test 2>&1 | tail -40
```
**توقّع**: 361 passed.

### 3. محاولة البناء
```bash
flutter build apk --debug --no-tree-shake-icons 2>&1 | tail -30
```

### 4. فحص الشاشات الحرجة
اقرأ هذه الملفات للتأكد من عدم عودة البيانات الوهمية:
- `lib/screens/ecommerce/online_orders_screen.dart` — يجب ألا يحتوي على `_OnlineOrder('ORD-001', ...)`
- `lib/screens/reports/` — فحص عام للتقارير المالية

### 5. مراجعة Silent catches
اقرأ الـ 6 مواضع المذكورة أعلاه وتأكد من أن السياق ما زال مبرَّراً.

## معايير القبول لأي تغيير

- [ ] `flutter test` يمرّ (361+ passing)
- [ ] `dart analyze` لا يُضيف errors (warnings/infos مقبولة ضمن الحد الموجود)
- [ ] `flutter build apk --debug` ينجح
- [ ] لا بيانات وهمية في أي شاشة
- [ ] لا silent `catch (_)` جديد
- [ ] لا طباعة PII (أرقام هواتف كاملة، تفاصيل مالية) في logs
- [ ] Sentry `reportError` مُستخدَم في كل catch block يُتوقع فيه حدوث خطأ فعلي
- [ ] CHANGELOG.md محدَّث
- [ ] لا migrations معدَّلة (فقط جديدة)

## ما هو خارج نطاقك

- ❌ iOS project creation
- ❌ Keystore generation
- ❌ إضافة ميزات جديدة (hardening phase)
- ❌ تعديل الـ UI بدون موافقة (التطبيق في إنتاج مُحدود)
- ❌ تعديل schemas قاعدة البيانات مباشرة

## البدء

```
أنا في طور استلام Admin. نفّذت:
- git status: [أرفق]
- dart analyze: [أرفق عدد errors/warnings/infos]
- flutter test: [أرفق النتيجة]
- Build attempt: [نجح / فشل + السبب]

أولوية العمل اليوم؟
```
