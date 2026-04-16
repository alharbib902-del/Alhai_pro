# تقرير تدقيق النشر والتوزيع - منصة الحي

**التاريخ:** 2026-02-26
**المدقق:** basem
**النموذج:** Claude Opus 4.6
**النطاق:** جميع التطبيقات والخدمات الخلفية في منصة الحي

---

## الملخص التنفيذي

تعاني منصة الحي من **نقص جوهري في جاهزية النشر للإنتاج**. المشروع في مرحلة تطوير مبكرة من حيث البنية التحتية للنشر، حيث تستخدم جميع التطبيقات إعدادات Flutter الافتراضية دون أي تخصيص للإنتاج. لا توجد إعدادات توقيع حقيقية لأندرويد، ولا إعدادات iOS كاملة للتطبيقات الأساسية، ولا بيئات منفصلة (تطوير/اختبار/إنتاج)، ولا تشفير للكود. خط أنابيب CI/CD موجود لكنه بدائي ويغطي تطبيقا واحدا فقط من أصل سبعة. تم اكتشاف **37 مشكلة** مصنفة حسب الخطورة.

### التقييم العام: 2.5 / 10

---

## جدول ملخص المشاكل

| التصنيف | العدد | النسبة |
|---------|-------|--------|
| حرج     | 14    | 37.8%  |
| متوسط   | 15    | 40.6%  |
| منخفض   | 8     | 21.6%  |
| **المجموع** | **37** | **100%** |

---

## 1. خط أنابيب CI/CD

### الملف: `.github/workflows/flutter_ci.yml`

#### 1.1 تغطية التطبيقات في CI/CD

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\.github\workflows\flutter_ci.yml`

السطر 72-73:
```yaml
      - name: Build Cashier APK
        run: melos run build:cashier:apk
```

السطر 108:
```yaml
        run: melos exec --scope="cashier" -- flutter build ios --release --no-codesign
```

السطر 137:
```yaml
        run: melos exec --scope="cashier" -- flutter build web --release
```

- يتم بناء تطبيق **cashier فقط** من أصل 7 تطبيقات (cashier, admin, admin_lite, customer_app, driver_app, distributor_portal, super_admin)
- لا يوجد أي بناء لـ: admin, admin_lite, customer_app, driver_app, distributor_portal, super_admin

> **المشكلة 1 - متوسط:** 6 تطبيقات من 7 ليس لها أي بناء آلي في CI/CD

#### 1.2 عدم وجود بيئات متعددة

لا يوجد أي تفريق بين بيئات التطوير والاختبار والإنتاج في خط الأنابيب:

- لا يوجد `--dart-define` لتمرير متغيرات البيئة أثناء البناء
- لا يوجد فصل بين بناء staging و production
- البناء يتم فقط عند الدفع إلى `main` (السطر 47: `if: github.ref == 'refs/heads/main'`)

> **المشكلة 2 - حرج:** لا توجد بيئات منفصلة (dev/staging/production) في CI/CD

#### 1.3 إصدار Flutter ثابت

**السطر 24:**
```yaml
          flutter-version: '3.24.0'
```

الإصدار مثبت على 3.24.0 بينما SDK constraint في pubspec.yaml هو `>=3.4.0 <4.0.0`. يجب التأكد من التوافق مع أحدث إصدار مستقر.

> **المشكلة 3 - منخفض:** إصدار Flutter مثبت وقد يكون قديما

#### 1.4 نشر الويب عبر GitHub Pages فقط

**السطر 139-144:**
```yaml
      - name: Deploy to GitHub Pages
        uses: peaceiris/actions-gh-pages@v3
        if: github.ref == 'refs/heads/main'
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: apps/cashier/build/web
```

- يتم النشر مباشرة إلى GitHub Pages بدون أي مراجعة
- لا يوجد نشر لـ admin (الذي من المفترض أن يكون تطبيق ويب أيضا)
- لا يوجد نشر لـ super_admin أو distributor_portal (تطبيقات ويب فقط)

> **المشكلة 4 - متوسط:** استراتيجية نشر الويب بدائية - GitHub Pages فقط بدون CDN أو domain مخصص

#### 1.5 عدم وجود workflows منفصلة

يوجد ملف workflow واحد فقط (`.github/workflows/flutter_ci.yml`). لا يوجد:
- workflow لـ release/tag
- workflow لـ security scanning
- workflow لـ dependency audit
- workflow لـ deployment إلى Play Store / App Store

> **المشكلة 5 - متوسط:** ملف CI/CD واحد فقط - لا يوجد فصل للعمليات المختلفة

---

## 2. إعدادات بناء أندرويد

### 2.1 معرفات التطبيقات (Application IDs)

| التطبيق | Application ID | الملف |
|---------|---------------|-------|
| cashier | `com.example.cashier` | `apps/cashier/android/app/build.gradle.kts:24` |
| admin | `com.example.admin` | `apps/admin/android/app/build.gradle.kts:24` |
| admin_lite | `com.example.admin_lite` | `apps/admin_lite/android/app/build.gradle.kts:24` |
| customer_app | `com.alhai.customer_app` | `customer_app/android/app/build.gradle.kts:24` |
| driver_app | `com.alhai.driver_app` | `driver_app/android/app/build.gradle.kts:24` |

**3 تطبيقات أساسية (cashier, admin, admin_lite) تستخدم `com.example.*`** - وهو معرف افتراضي لا يمكن استخدامه على Google Play Store.

تطبيقا customer_app و driver_app يستخدمان `com.alhai.*` وهو الصحيح.

> **المشكلة 6 - حرج:** 3 تطبيقات تستخدم `com.example.*` كـ applicationId - مرفوض من Google Play

### 2.2 Namespace مطابق لـ applicationId

نفس المشكلة تنطبق على namespace:

```kotlin
// apps/cashier/android/app/build.gradle.kts:9
namespace = "com.example.cashier"

// apps/admin/android/app/build.gradle.kts:9
namespace = "com.example.admin"

// apps/admin_lite/android/app/build.gradle.kts:9
namespace = "com.example.admin_lite"
```

> **المشكلة 7 - حرج:** الـ namespace يحتوي على `com.example` ويجب تغييره قبل الإنتاج

### 2.3 Kotlin Package Names

```kotlin
// apps/cashier/android/app/src/main/kotlin/com/example/cashier/MainActivity.kt:1
package com.example.cashier

// apps/admin/android/app/src/main/kotlin/com/example/admin/MainActivity.kt:1
package com.example.admin

// apps/admin_lite/android/app/src/main/kotlin/com/example/admin_lite/MainActivity.kt:1
package com.example.admin_lite
```

> **المشكلة 8 - حرج:** ملفات Kotlin تستخدم `com.example.*` - يجب تحديث مسارات الملفات وأسماء الحزم

### 2.4 إعدادات التوقيع (Signing Configuration)

جميع التطبيقات الخمسة تستخدم توقيع debug للإصدار:

```kotlin
// apps/cashier/android/app/build.gradle.kts:37
signingConfig = signingConfigs.getByName("debug")
```

نفس السطر في كل من:
- `apps/admin/android/app/build.gradle.kts:37`
- `apps/admin_lite/android/app/build.gradle.kts:37`
- `customer_app/android/app/build.gradle.kts:37`
- `driver_app/android/app/build.gradle.kts:37`

لا يوجد:
- ملف `key.properties`
- ملف `*.keystore` أو `*.jks`
- أي إعداد لتوقيع الإنتاج

> **المشكلة 9 - حرج:** جميع التطبيقات تُوقَّع بمفتاح debug - مستحيل الرفع على Google Play

### 2.5 تعطيل تقليص الكود (Minification)

```kotlin
// apps/cashier/android/app/build.gradle.kts:38-39
isMinifyEnabled = false
isShrinkResources = false
```

نفس الإعداد في admin و admin_lite. أما customer_app و driver_app فلا يوجد فيهما إعداد minify أصلا.

> **المشكلة 10 - متوسط:** تعطيل minification و shrinkResources يزيد حجم APK ويكشف الكود

### 2.6 عدم تناسق إصدار Java

التطبيقات داخل `apps/` تستخدم Java 17:
```kotlin
// apps/cashier/android/app/build.gradle.kts:14-15
sourceCompatibility = JavaVersion.VERSION_17
targetCompatibility = JavaVersion.VERSION_17
```

بينما التطبيقات الخارجية تستخدم Java 11:
```kotlin
// customer_app/android/app/build.gradle.kts:14-15
sourceCompatibility = JavaVersion.VERSION_11
targetCompatibility = JavaVersion.VERSION_11
```

> **المشكلة 11 - منخفض:** عدم تناسق إصدار Java بين التطبيقات (17 vs 11)

### 2.7 عدم تناسق إصدار Gradle

```properties
# apps/cashier/android/gradle/wrapper/gradle-wrapper.properties:5
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip

# customer_app/android/gradle/wrapper/gradle-wrapper.properties:5
distributionUrl=https\://services.gradle.org/distributions/gradle-8.12-all.zip
```

> **المشكلة 12 - منخفض:** إصدارات Gradle مختلفة بين التطبيقات

### 2.8 إذن INTERNET في release manifest

إذن INTERNET موجود فقط في debug و profile manifests لكنه غير موجود في main manifest. هذا قد يسبب مشاكل في بعض الحالات لأن Flutter يضيفه تلقائيا لكن من الأفضل التصريح به.

جميع التطبيقات لا تصرح بإذن INTERNET في main/AndroidManifest.xml:
- `apps/cashier/android/app/src/main/AndroidManifest.xml`
- `apps/admin/android/app/src/main/AndroidManifest.xml`
- `customer_app/android/app/src/main/AndroidManifest.xml`
- `driver_app/android/app/src/main/AndroidManifest.xml`

> **المشكلة 13 - منخفض:** إذن INTERNET غير مصرح به في main manifest - يعمل لكن الأفضل التصريح

### 2.9 أسماء التطبيقات في AndroidManifest

```xml
<!-- apps/cashier/android/app/src/main/AndroidManifest.xml:3 -->
android:label="cashier"

<!-- apps/admin/android/app/src/main/AndroidManifest.xml:3 -->
android:label="admin"

<!-- customer_app/android/app/src/main/AndroidManifest.xml:3 -->
android:label="customer_app"
```

جميع الأسماء هي أسماء تقنية وليست أسماء عرض مناسبة للمستخدم.

> **المشكلة 14 - متوسط:** أسماء التطبيقات في AndroidManifest تقنية وليست مناسبة للمستخدم النهائي

---

## 3. إعدادات iOS

### 3.1 غياب مجلد iOS لـ 3 تطبيقات أساسية

| التطبيق | مجلد iOS | الحالة |
|---------|----------|--------|
| apps/cashier | غير موجود | لا يوجد |
| apps/admin | غير موجود | لا يوجد |
| apps/admin_lite | غير موجود | لا يوجد |
| customer_app | موجود | `com.alhai.customerApp` |
| driver_app | موجود | `com.alhai.driverApp` |
| distributor_portal | غير موجود | ويب فقط |
| super_admin | غير موجود | ويب فقط |

التطبيقات الثلاثة الأساسية (cashier, admin, admin_lite) ليس لديها مجلد iOS مما يعني أنها لا تدعم iOS حاليا.

> **المشكلة 15 - حرج:** 3 تطبيقات أساسية (cashier, admin, admin_lite) بدون إعداد iOS

### 3.2 إعدادات iOS الموجودة - بدائية

لتطبيقي customer_app و driver_app:

**`customer_app/ios/Runner.xcodeproj/project.pbxproj:550`:**
```
PRODUCT_BUNDLE_IDENTIFIER = com.alhai.customerApp;
```

**`driver_app/ios/Runner.xcodeproj/project.pbxproj:550`:**
```
PRODUCT_BUNDLE_IDENTIFIER = com.alhai.driverApp;
```

لا يوجد:
- إعدادات Signing (provisioning profiles, certificates)
- إعدادات Capabilities (Push Notifications, Maps, etc.)
- إعدادات Export Options

**`customer_app/ios/Runner/Info.plist`:**
- لا يوجد NSLocationWhenInUseUsageDescription (مطلوب لـ Google Maps)
- لا يوجد NSCameraUsageDescription (مطلوب لـ image_picker)
- لا يوجد privacy descriptions المطلوبة

**`driver_app/ios/Runner/Info.plist`:**
- نفس النقص - لا يوجد privacy descriptions المطلوبة
- التطبيق يحتاج NSLocationAlwaysUsageDescription (background tracking)

> **المشكلة 16 - حرج:** ملفات Info.plist لا تحتوي على Privacy Usage Descriptions المطلوبة - التطبيق سيُرفض من App Store

---

## 4. متغيرات البيئة والأسرار

### 4.1 ملف `.dart_define.env`

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\.dart_define.env`

```
SUPABASE_URL=https://jtgwboqushihwvvsdtud.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

هذا الملف:
- **غير مُتتبع** في Git (تم التحقق)
- **لكنه غير مضاف إلى `.gitignore`** بشكل صريح

الملف `.gitignore` يحتوي على:
```
.env
.env.local
.env.*.local
```

لكن لا يحتوي على `.dart_define.env` أو `.dart_define*`.

> **المشكلة 17 - حرج:** ملف `.dart_define.env` يحتوي على مفاتيح Supabase ولكنه غير مضاف إلى `.gitignore` - خطر تسريب عند `git add .`

### 4.2 Supabase URL مكشوف في الكود

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\ai_server\config.py:11`
```python
supabase_url: str = "https://jtgwboqushihwvvsdtud.supabase.co"
```

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\ai_server\.env.example:2`
```
SUPABASE_URL=https://jtgwboqushihwvvsdtud.supabase.co
```

عنوان Supabase الحقيقي مكتوب كقيمة افتراضية في الكود و في `.env.example`.

> **المشكلة 18 - متوسط:** عنوان Supabase الحقيقي hardcoded في `config.py` و `.env.example`

### 4.3 إعداد Supabase في تطبيقات Flutter - جيد

**الملف:** `apps/cashier/lib/core/config/supabase_config.dart`

```dart
static const String url = String.fromEnvironment(
  'SUPABASE_URL',
  // لا يوجد defaultValue - يجب تمريره دائماً
);
```

الإعداد صحيح - يستخدم `--dart-define` ولا يحتوي على قيم افتراضية. هذا النمط مُكرر في الملفات الثلاثة:
- `apps/cashier/lib/core/config/supabase_config.dart`
- `apps/admin/lib/core/config/supabase_config.dart`
- `apps/admin_lite/lib/core/config/supabase_config.dart`

**لكن** customer_app, driver_app, distributor_portal, super_admin ليس لديها ملف `supabase_config.dart` - لم تُهيأ بعد.

> **المشكلة 19 - متوسط:** 4 تطبيقات (customer_app, driver_app, distributor_portal, super_admin) بدون إعداد Supabase

### 4.4 CI/CD لا يمرر متغيرات البيئة

**الملف:** `.github/workflows/flutter_ci.yml:73`
```yaml
      - name: Build Cashier APK
        run: melos run build:cashier:apk
```

**الملف:** `melos.yaml:38`
```yaml
  build:cashier:apk:
    run: melos exec --scope="cashier" -- flutter build apk
```

أمر البناء لا يتضمن `--dart-define` لتمرير `SUPABASE_URL` و `SUPABASE_ANON_KEY`. التطبيق سيُبنى بقيم فارغة.

> **المشكلة 20 - حرج:** البناء الآلي لا يمرر متغيرات البيئة المطلوبة - التطبيق لن يعمل

---

## 5. Firebase

### 5.1 عدم وجود ملفات Firebase

لا يوجد في المشروع بالكامل:
- `google-services.json` (Android)
- `GoogleService-Info.plist` (iOS)
- `firebase_options.dart` (FlutterFire CLI)
- `firebase.json` (Firebase config)

ومع ذلك، Firebase مُدرج كـ dependency في 5 تطبيقات:

| التطبيق | firebase_core | firebase_messaging |
|---------|--------------|-------------------|
| cashier | `^3.8.0` | لا |
| admin | `^3.8.0` | لا |
| admin_lite | `^3.8.0` | لا |
| customer_app | `^2.24.2` | `^14.7.10` |
| driver_app | `^2.24.2` | `^14.7.10` |

**الملف:** `apps/cashier/lib/main.dart:23-33`
```dart
  try {
    await Firebase.initializeApp();
    ...
  } catch (e) {
    // App continues without Firebase
  }
```

Firebase يفشل بصمت عند التشغيل - مما يعني أن Analytics و Crashlytics و Push Notifications لا تعمل.

> **المشكلة 21 - حرج:** Firebase مُدرج كـ dependency لكن غير مُعد - لا ملفات تكوين

### 5.2 عدم تناسق إصدارات Firebase

التطبيقات في `apps/` تستخدم `firebase_core: ^3.8.0` بينما customer_app و driver_app تستخدمان `firebase_core: ^2.24.2` - إصدارات رئيسية مختلفة.

> **المشكلة 22 - متوسط:** عدم تناسق إصدارات Firebase بين التطبيقات (v3 vs v2)

---

## 6. نظام Flavors/Schemes

لا يوجد أي نظام flavors أو schemes في أي تطبيق:

- لا يوجد `productFlavors` في أي `build.gradle.kts`
- لا يوجد `flavorDimensions`
- لا يوجد Xcode schemes متعددة
- لا يوجد ملفات environment مختلفة (dev.env, staging.env, prod.env)

> **المشكلة 23 - حرج:** عدم وجود نظام Flavors/Environments - بيئة واحدة فقط

---

## 7. ProGuard Rules

**الملف:** `apps/cashier/android/app/proguard-rules.pro`

```pro
# SQLCipher / sqlite3_flutter_libs
-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }
-keep class net.zetetic.database.** { *; }
-dontwarn net.zetetic.database.**

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
```

ملفات ProGuard موجودة في 3 تطبيقات (cashier, admin, admin_lite) لكنها:
- **معطلة** (`isMinifyEnabled = false`)
- غير شاملة (لا تحتوي على قواعد لـ Supabase, Riverpod, GoRouter, etc.)

customer_app و driver_app ليس لديهما ملف ProGuard.

> **المشكلة 24 - متوسط:** قواعد ProGuard موجودة لكن معطلة وغير شاملة

---

## 8. تشفير الكود (Code Obfuscation)

لا يوجد أي استخدام لـ `--obfuscate` أو `--split-debug-info` في أي مكان:
- ليس في CI/CD workflow
- ليس في melos scripts
- ليس في أي script بناء

> **المشكلة 25 - حرج:** لا يوجد تشفير للكود - كود Dart قابل للعكس بالكامل

---

## 9. نشر الويب

### 9.1 أسماء وأوصاف غير مخصصة

جميع ملفات `web/index.html` و `web/manifest.json` تحتوي على نصوص Flutter الافتراضية:

**`apps/cashier/web/index.html:21`:**
```html
<meta name="description" content="A new Flutter project.">
```

**`apps/cashier/web/index.html:32`:**
```html
<title>cashier</title>
```

**`apps/cashier/web/manifest.json:8`:**
```json
"description": "A new Flutter project.",
```

نفس المشكلة في جميع التطبيقات الستة التي لديها مجلد web:
- apps/cashier, apps/admin, apps/admin_lite
- customer_app, distributor_portal, super_admin

> **المشكلة 26 - متوسط:** جميع ملفات الويب تحتوي على وصف "A new Flutter project" الافتراضي

### 9.2 عدم وجود أيقونات مخصصة

لا يوجد `flutter_launcher_icons` أو `flutter_native_splash` في أي تطبيق. جميع التطبيقات تستخدم أيقونات Flutter الافتراضية.

> **المشكلة 27 - متوسط:** جميع التطبيقات تستخدم أيقونة Flutter الافتراضية

### 9.3 عدم وجود Security Headers

لا يوجد أي Content-Security-Policy أو X-Frame-Options أو X-Content-Type-Options في ملفات الويب.

> **المشكلة 28 - متوسط:** لا توجد Security Headers لتطبيقات الويب

### 9.4 عدم وجود استضافة مخصصة

- لا يوجد CNAME file
- لا يوجد vercel.json أو netlify.toml
- GitHub Pages فقط للـ cashier
- لا توجد خطة لاستضافة admin, super_admin, distributor_portal

> **المشكلة 29 - متوسط:** لا توجد استضافة ويب مخصصة - GitHub Pages فقط

---

## 10. Docker والخدمات الخلفية

### 10.1 AI Server - Dockerfile

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\ai_server\Dockerfile`

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

المشاكل:
- لا يوجد `.dockerignore`
- لا يوجد multi-stage build
- لا يوجد health check
- لا يوجد non-root user
- لا يوجد docker-compose لتنسيق الخدمات

> **المشكلة 30 - متوسط:** Dockerfile بدائي بدون أفضل ممارسات الأمان

### 10.2 CORS - Wildcard في Supabase Functions

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\_shared\cors.ts:2`
```typescript
'Access-Control-Allow-Origin': '*',
```

بينما AI Server يستخدم إعدادات CORS محددة:
```python
# ai_server/config.py:24
allowed_origins: str = "http://localhost:3000,http://localhost:8080"
```

> **المشكلة 31 - حرج:** Supabase Edge Functions تستخدم `Access-Control-Allow-Origin: *` - خطر أمني

---

## 11. إدارة الإصدارات

### 11.1 جميع التطبيقات على الإصدار 1.0.0+1

| التطبيق | الإصدار |
|---------|---------|
| cashier | 1.0.0+1 |
| admin | 1.0.0+1 |
| admin_lite | (لا يوجد) |
| customer_app | 1.0.0+1 |
| driver_app | 1.0.0+1 |
| distributor_portal | 1.0.0+1 |
| super_admin | 1.0.0+1 |

لا يوجد:
- نظام إدارة إصدارات آلي
- Changelog تلقائي
- Git tags للإصدارات
- Semantic versioning strategy

> **المشكلة 32 - منخفض:** لا يوجد نظام إدارة إصدارات - الكل على 1.0.0+1

---

## 12. Supabase Configuration

### 12.1 عدم وجود Supabase CLI config

لا يوجد `supabase/config.toml` - مما يعني عدم استخدام Supabase CLI للتطوير المحلي.

> **المشكلة 33 - منخفض:** لا يوجد إعداد Supabase CLI للتطوير المحلي

### 12.2 Migration Files

**المجلد:** `supabase/migrations/`

يحتوي على 3 ملفات migration فقط:
- `20260115_add_r2_images.sql`
- `20260119_secure_public_products.sql`
- `20260223_tighten_rls_write_policies.sql`

بالإضافة إلى SQL files مفرقة:
- `supabase_init.sql`
- `supabase_owner_only.sql`
- `fix_auth.sql`
- `fix_stores_rls.sql`
- `fix_rls_recursion.sql`
- `sync_rpc_functions.sql`
- `get_my_stores.sql`

> **المشكلة 34 - منخفض:** ملفات SQL مبعثرة خارج مجلد migrations - يصعب تتبع تغييرات قاعدة البيانات

---

## 13. Build Scripts و Melos

### 13.1 Melos Scripts محدودة

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\melos.yaml`

```yaml
scripts:
  build:cashier:apk:
    run: melos exec --scope="cashier" -- flutter build apk
  build:admin:web:
    run: melos exec --scope="admin" -- flutter build web
  build:lite:apk:
    run: melos exec --scope="admin_lite" -- flutter build apk
```

لا يوجد:
- أوامر بناء لـ customer_app, driver_app, distributor_portal, super_admin
- أوامر بناء iOS
- أوامر بناء web لـ cashier و admin_lite
- لا `--dart-define` في أي أمر بناء

> **المشكلة 35 - متوسط:** أوامر Melos محدودة - تغطي 3 تطبيقات فقط بدون متغيرات بيئة

### 13.2 عدم وجود Makefile أو Scripts

لا يوجد:
- `Makefile`
- مجلد `scripts/`
- أي ملف shell script للبناء أو النشر

> **المشكلة 36 - منخفض:** لا يوجد build scripts مساعدة

---

## 14. R2/CDN Configuration

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\supabase\functions\upload-product-images\index.ts:63`

```typescript
urls[size] = `https://cdn.alhai.sa/${key}`
```

يشير إلى CDN domain `cdn.alhai.sa` لكن لا يوجد أي إعداد DNS أو CNAME في المشروع.

بيانات R2 (Access Key, Secret) تُمرر عبر Deno.env (Supabase Edge Function secrets) وهذا صحيح.

> **المشكلة 37 - منخفض:** domain الـ CDN مُحدد في الكود لكن لا يوجد إعداد DNS مُوثق

---

## التوصيات مع أولوية التنفيذ

### الأولوية 1 - حرج (يجب تنفيذه فورا قبل أي نشر)

| # | التوصية | المشاكل المرتبطة |
|---|---------|-----------------|
| 1 | تغيير applicationId من `com.example.*` إلى `com.alhai.*` لـ cashier, admin, admin_lite | 6, 7, 8 |
| 2 | إنشاء مفاتيح توقيع إنتاج وإعداد signing config | 9 |
| 3 | إعداد Firebase (تشغيل `flutterfire configure`) وإضافة ملفات التكوين | 21 |
| 4 | إضافة `.dart_define.env` إلى `.gitignore` | 17 |
| 5 | تمرير `--dart-define` في CI/CD عبر GitHub Secrets | 20 |
| 6 | إنشاء مجلدات iOS لـ cashier, admin, admin_lite | 15 |
| 7 | إضافة Privacy Usage Descriptions لـ Info.plist | 16 |
| 8 | إعداد نظام Flavors (dev/staging/prod) | 2, 23 |
| 9 | تفعيل `--obfuscate --split-debug-info` | 25 |
| 10 | إصلاح CORS في Supabase Functions | 31 |

### الأولوية 2 - متوسط (يجب تنفيذه قبل الإطلاق)

| # | التوصية | المشاكل المرتبطة |
|---|---------|-----------------|
| 11 | إضافة CI/CD لجميع التطبيقات | 1 |
| 12 | تفعيل minification و shrinkResources | 10 |
| 13 | تخصيص web manifest و index.html لكل تطبيق | 26 |
| 14 | إنشاء أيقونات مخصصة لكل تطبيق | 27 |
| 15 | إعداد استضافة ويب مناسبة (Cloudflare Pages أو Vercel) | 4, 29 |
| 16 | إضافة Security Headers لتطبيقات الويب | 28 |
| 17 | تحسين Dockerfile (multi-stage, non-root, health check) | 30 |
| 18 | إعداد Supabase Config لـ customer_app, driver_app, etc. | 19 |
| 19 | توحيد إصدارات Firebase | 22 |
| 20 | تحديث أسماء التطبيقات في AndroidManifest | 14 |
| 21 | توسيع melos scripts | 35 |
| 22 | فصل workflows لـ CI/CD | 5 |
| 23 | توسيع قواعد ProGuard | 24 |

### الأولوية 3 - منخفض (تحسينات مستقبلية)

| # | التوصية | المشاكل المرتبطة |
|---|---------|-----------------|
| 24 | تحديث Flutter version في CI | 3 |
| 25 | توحيد Java versions | 11 |
| 26 | توحيد Gradle versions | 12 |
| 27 | إضافة INTERNET permission في main manifest | 13 |
| 28 | إعداد نظام إدارة إصدارات آلي | 32 |
| 29 | إعداد Supabase CLI محلي | 33 |
| 30 | تنظيم ملفات SQL في migrations | 34 |
| 31 | إنشاء build scripts | 36 |
| 32 | توثيق إعداد CDN | 37 |

---

## الملخص النهائي

| البند | الحالة | التفاصيل |
|-------|--------|----------|
| CI/CD | ضعيف | ملف واحد، تطبيق واحد، بدون secrets |
| Android Signing | غير موجود | debug signing فقط |
| iOS Setup | غير مكتمل | 3/5 تطبيقات بدون iOS |
| Environment Vars | جزئي | dart-define جيد لكن CI لا يمرر القيم |
| Firebase | غير مُعد | dependency موجودة لكن بدون تكوين |
| Flavors | غير موجود | بيئة واحدة فقط |
| Code Obfuscation | غير موجود | لا تشفير للكود |
| Web Deployment | بدائي | GitHub Pages فقط |
| Docker | بدائي | Dockerfile بسيط بدون أفضل ممارسات |
| Version Management | غير موجود | الكل 1.0.0+1 |
| ProGuard | معطل | قواعد موجودة لكن غير مفعلة |
| Store Listing | غير جاهز | أيقونات وأسماء افتراضية |
| Supabase | جزئي | 3/7 تطبيقات معدة |
| Security | ضعيف | CORS wildcard, لا headers |

### التقييم النهائي: 2.5 / 10

المشروع يحتاج عملا كبيرا في البنية التحتية للنشر قبل أن يكون جاهزا للإنتاج. الكود التطبيقي متقدم نسبيا لكن إعدادات النشر والأمان في مرحلة بدائية جدا. يُنصح بتخصيص sprint كامل (أسبوعين) لمعالجة المشاكل الحرجة قبل أي محاولة للنشر.
