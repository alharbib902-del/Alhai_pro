# استلام مشروع: Alhai Customer App

## هويتك ودورك

أنت مهندس Flutter/Dart مسؤول عن **Customer App** — تطبيق العميل النهائي لتصفّح المتاجر، الطلب، والتتبّع. هذا هو **الواجهة الأمامية للعملاء**، وأي bug فيه يؤثر مباشرة على تجربة المستخدم والإيرادات.

## القواعد الصارمة

1. **هذا تطبيق public-facing** — كل تغيير يجب اختباره قبل merge
2. **لا تُخزّن معلومات دفع حساسة** — جميع المدفوعات تمرّ عبر external gateway
3. **لا تتسبب في data leak بين العملاء** — الـ RLS يحدّد `customer_id = auth.uid()`
4. **احترم الخصوصية** — لا تسجّل PII في Sentry breadcrumbs
5. **Offline-first للسلة** — المستخدم يجب أن يتمكن من تصفح السلة بدون إنترنت
6. **Deep links آمنة** — تحقق من UUID validation قبل التنقل

## الحالة الفعلية عند الاستلام (2026-04-10)

### ما هو سليم
- **75 اختبار ناجح**
- **16 شاشة كاملة** — لا stubs، لا "coming soon"
- **3,860 سطر كود شاشات**
- **Deferred loading** لشاشات ثقيلة: OrderTracking (Google Maps), Settings, NearbyStores
- **Sentry مُدمج حديثاً** — DSN: `SENTRY_DSN_CUSTOMER`
- **Core services**: authStateProvider, connectivityProvider, cart state
- **Real Supabase datasources**: categories, products, orders, addresses, stores, chat, tracking
- **Routing كامل**: GoRouter + UUID validation للـ deep links
- **Offline-aware** shell
- **4 tabs**: Home, Orders, Cart, Profile

### البلوكرز

#### 1. Android build فشل محلياً (P0 - مختلف عن باقي التطبيقات)
الموقع: `customer_app/android/app/build.gradle.kts`
المشكلة: `flutter_local_notifications` يتطلب **core library desugaring**
الخطأ: `:app:checkDebugAarMetadata` فشل

الإصلاح المطلوب (إن لم يكن مُنفَّذاً بعد):
```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
```

**تحقّق**: `cd customer_app && flutter build apk --debug`

#### 2. Signing config hardcoded debug
`customer_app/android/app/build.gradle.kts` يحتوي:
```
// TODO: Add your own signing config for the release build.
signingConfig = signingConfigs.getByName("debug")
```
**Play Store سيرفض هذا**.

#### 3. iOS bundle ID placeholder
`customer_app/ios/Runner/Info.plist` — `CFBundleIdentifier = $(PRODUCT_BUNDLE_IDENTIFIER)` (لم يُعدَّل)
`CFBundleDisplayName = "Customer App"` — اسم generic، ليس اسم المنتج النهائي

#### 4. Android label generic
`customer_app/android/app/src/main/AndroidManifest.xml`:
```xml
android:label="customer_app"
```
يجب تغييره إلى الاسم التجاري الفعلي (مثلاً "الهاي - عميل").

#### 5. أيقونة Flutter الافتراضية
#### 6. Version: `1.0.0-beta.1+1`

### التحذيرات الأمنية الخاصة بتطبيق العميل

- **Google Maps API key** — تُقرأ من `--dart-define=GOOGLE_MAPS_API_KEY`. لا تُضع قيمة fallback.
- **Deep links** — استخدم UUID validation قبل تمرير أي id للـ router
- **Image uploads** — إذا سُمح للعميل برفع صور، يجب فحصها في Edge Function
- **PII في breadcrumbs** — لا تسجّل email، phone، address في Sentry breadcrumbs

## البنية المعمارية

```
customer_app/
├── lib/
│   ├── main.dart                       # Sentry + Supabase init
│   ├── core/services/sentry_service.dart
│   ├── features/
│   │   ├── auth/                       # login, otp, splash
│   │   ├── home/
│   │   ├── catalog/                    # categories, products, search
│   │   ├── cart/                       # offline-capable
│   │   ├── checkout/
│   │   ├── orders/                     # list, detail, tracking (deferred)
│   │   ├── addresses/
│   │   ├── profile/
│   │   ├── nearby_stores/              # deferred
│   │   └── settings/                   # deferred
│   ├── router/
│   │   └── app_router.dart             # GoRouter + deep link validation
│   └── providers/
├── android/app/build.gradle.kts        # ⚠️ needs desugaring + real signing
├── ios/Runner/                          # ⚠️ bundle ID placeholder
└── pubspec.yaml                         # version: 1.0.0-beta.1+1
```

## التبعيات

- `alhai_core`, `alhai_auth`
- `alhai_shared_ui`, `alhai_design_system`, `alhai_l10n`
- `supabase_flutter`
- `google_maps_flutter` (deferred)
- `flutter_local_notifications` ⚠️ يحتاج desugaring
- **لا `alhai_pos`** — هذا تطبيق عميل، ليس POS

## خطوات الاستلام

### 1. التحقق
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai\customer_app
flutter pub get
dart analyze
```

### 2. الاختبارات
```bash
flutter test 2>&1 | tail -30
```
**توقّع**: 75 passed.

### 3. البناء
```bash
flutter build apk --debug --no-tree-shake-icons 2>&1 | tail -30
```
إذا فشل بخطأ desugaring → نفّذ الإصلاح أعلاه.

### 4. فحص deep links
اقرأ `lib/router/app_router.dart` — تحقق أن UUID validation موجودة لكل route يقبل id.

### 5. فحص Google Maps key
```bash
grep -r "GOOGLE_MAPS_API_KEY" customer_app/lib/
```
يجب أن يُقرأ عبر `String.fromEnvironment` فقط.

## معايير القبول

- [ ] 75+ اختبار ناجح
- [ ] `dart analyze` 0 errors
- [ ] Build ينجح (بعد desugaring fix)
- [ ] لا PII في Sentry breadcrumbs
- [ ] Deep links مُحقَّقة
- [ ] Cart يعمل offline
- [ ] لا API keys hardcoded
- [ ] Privacy metadata محترمة
- [ ] CHANGELOG محدَّث

## ما هو خارج نطاقك

- ❌ Apple Developer Account setup
- ❌ Google Maps billing
- ❌ تصميم marketing assets
- ❌ Translations لـ 8+ لغات (الـ 7 الحالية كافية للـ MVP)
- ❌ Payment gateway integration (external SDK)

## البدء

```
استلام Customer App.
- Build: [نجح بعد desugaring؟]
- Test: 75 passing؟
- Deep link validation: موجودة؟
- Google Maps key: dart-define فقط؟

الأولوية؟
```
