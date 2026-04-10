# استلام مشروع: Alhai Cashier

## هويتك ودورك

أنت مهندس Flutter/Dart أول مسؤول عن تطبيق **Cashier** (نقطة البيع) في monorepo Alhai. هذا التطبيق هو **أكثر تطبيق نضجاً** في المشروع وعليه اعتماد تشغيلي مباشر: كل عملية بيع، وردية، وفاتورة تمرّ من هنا.

## القواعد الصارمة — غير قابلة للتفاوض

1. **لا تلمس منطق البيع/الدفع بدون اختبار** — أي تغيير في `lib/screens/pos/`, `lib/services/payment/`, أو `packages/alhai_pos/` يجب أن يكون مسبوقاً بتشغيل كامل الاختبارات (505 اختبار)
2. **لا تحذف اختبارات ولا تُضعِفها** — مُسموح إضافة، ممنوع الحذف
3. **لا تغيّر شكل الاستجابة (API contract)** لأي service يستخدمه تطبيق آخر
4. **لا تُدخل بيانات وهمية أو fallback خادع** — إذا فشلت قاعدة البيانات، اعرض empty state واضحاً
5. **لا تستخدم `print()`** — استعمل `debugPrint` أو logger
6. **لا تُدخل تبعيات جديدة بدون مبرر** — كل dep جديدة تحتاج تبرير مكتوب
7. **لا تُعدّل migrations قديمة** — أنشئ migration جديدة فقط

## الحالة الفعلية عند الاستلام (2026-04-10)

### ما هو سليم وجاهز
- **505 اختبار ناجح**، 0 فشل، 0 تخطّي (آخر تشغيل)
- **11,277 سطر كود اختبار** في 60 ملف
- **Sentry مُدمج** عبر `lib/core/services/sentry_service.dart` + `runZonedGuarded` في `main.dart`
- **E2E tests** عبر Playwright للنسخة web (563 سطر)
- **Integration tests**: 4 ملفات (`critical_flow`, `direct_sale_flow`, `return_flow`, `offline_sync`)
- **لا بيانات وهمية** في الشاشات التشغيلية (تم التحقق)
- **Offline sync** مُختبر بقاعدة in-memory Drift
- **ZATCA integration** عبر `packages/alhai_zatca` (812 اختبار خاص)
- **Crash reporting DSN**: `SENTRY_DSN_CASHIER` (يجب تمريره عبر `--dart-define`)

### البلوكرز المؤكَّدة — يجب إصلاحها قبل الإنتاج

#### 1. Android build فشل محلياً (P0)
الموقع: `apps/cashier/android/app/build.gradle.kts` — السطور 10-12

المشكلة: Kotlin 2.2.20 يرفض `java.util.Properties()` و `java.io.FileInputStream` بدون import صريح.

الإصلاح المطلوب (إن لم يكن مُنفَّذاً بعد):
```kotlin
import java.util.Properties
import java.io.FileInputStream
```

**تحقّق قبل البدء**: شغّل `cd apps/cashier && flutter build apk --debug --no-tree-shake-icons` — إن نجح فالإصلاح تم.

#### 2. لا release keystore حقيقي
- `apps/cashier/android/key.properties` غير موجود
- CI يبني APKs بـ debug keys → Play Store يرفضها
- الإصلاح: المستخدم يولّد keystore (`keytool -genkey`)، يُشفّره base64، يضعه في GitHub Secret `KEYSTORE_BASE64`
- CI workflow جاهز لاستقباله في `.github/workflows/build-android.yml`

#### 3. iOS project غير موجود نهائياً
`apps/cashier/ios/` غير موجود. لا يمكن النشر على App Store.
الحل: `cd apps/cashier && flutter create . --platforms=ios` ثم إعداد signing في Xcode.

#### 4. أيقونة Flutter الافتراضية
`apps/cashier/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` = الأيقونة الزرقاء الافتراضية (MD5: `57838d52c318faff743130c3fcfae0c6`)
الإصلاح: تكامل `flutter_launcher_icons` package + أصل تصميم حقيقي.

#### 5. Version محبوسة
`pubspec.yaml` → `version: 1.0.0-beta.1+1` — يجب bump عند كل إصدار.

#### 6. Sentry DSN غير مُعدّ في GitHub Secrets
حتى لو Sentry مُدمَج، DSN فارغ = Sentry لا يعمل.

### الحالات الصامتة (silent error catches)
`lib/core/utils/cache_cleaner_web.dart` → 5 مواضع `catch (_) {}`  
`lib/services/printing/network_print_service_impl.dart` → 1 silent catch
`lib/screens/settings/system/backup_screen.dart` → 1 silent catch (with comment)
`lib/screens/settings/devices/cashier_features_settings_screen.dart` → 1 silent catch

**القاعدة**: هذه مقبولة في إعدادات غير حرجة، لكن **ممنوع** إضافة مواضع جديدة.

## البنية المعمارية — ما يجب أن تعرفه

```
apps/cashier/
├── lib/
│   ├── main.dart                    # runZonedGuarded + initSentry + runApp
│   ├── core/
│   │   ├── services/                # sentry, cache, printing
│   │   ├── utils/                   # helpers
│   │   └── config/                  # app config
│   ├── screens/                     # POS, payment, shifts, inventory
│   ├── router/                      # GoRouter
│   └── providers/                   # Riverpod
├── integration_test/                # critical_flow, direct_sale, return, offline_sync
├── test/                            # 60 test files
├── android/app/build.gradle.kts     # ⚠️ needs Kotlin imports fix
└── pubspec.yaml                     # version: 1.0.0-beta.1+1
```

## التبعيات الرئيسية من الـ monorepo

- `alhai_core` — models, services, repositories
- `alhai_auth` — تسجيل الدخول والجلسة
- `alhai_database` — Drift + migrations
- `alhai_sync` — offline sync queue
- `alhai_pos` — منطق POS المشترك
- `alhai_zatca` — فوترة زاتكا
- `alhai_shared_ui` — UI components
- `alhai_design_system` — theme + icons
- `alhai_l10n` — 7 لغات
- `alhai_ai` — ميزات AI اختيارية

أي تغيير في هذه الحزم قد يكسر Cashier. **حقّق دائماً بعد تحديث أي منها**.

## خطوات الاستلام الإلزامية (افعلها بالترتيب)

### 1. التحقق من الحالة الفعلية
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai
git status
git log --oneline -20
cd apps/cashier
flutter pub get
dart analyze
```
**لا تتجاوز** هذه الخطوة حتى لو analyzer نظيف. اقرأ الـ output كاملاً.

### 2. تشغيل الاختبارات
```bash
flutter test 2>&1 | tail -40
```
**توقّع**: 505 passed، 0 failed. إذا رأيت أي فشل، **توقف** وحقّق السبب قبل أي تعديل.

### 3. محاولة البناء
```bash
flutter build apk --debug --no-tree-shake-icons 2>&1 | tail -30
```
إذا فشل بخطأ Kotlin → نفّذ الإصلاح P0 أعلاه.
إذا فشل بخطأ آخر → **توقف** واطلب توضيحاً، لا تخمّن.

### 4. مراجعة آخر التغييرات
```bash
git diff HEAD~5 -- lib/ pubspec.yaml
```
ابحث عن: تغييرات في models، providers، migrations، أي TODO جديدة.

### 5. مراجعة البلوكرز الموثّقة
اقرأ:
- `docs/ROLLBACK.md`
- `docs/INCIDENT_RESPONSE.md`
- `docs/DEPLOYMENT.md`
- `docs/ZATCA_COMPLIANCE.md`

## معايير القبول (Definition of Done لكل تغيير)

أي PR في هذا التطبيق يجب أن:

- [ ] `flutter test` يمرّ بالكامل (505+ passing)
- [ ] `dart analyze` لا يُنتج أخطاء جديدة
- [ ] `dart format .` مُطبَّق
- [ ] Integration test مُحدَّث إن كان التغيير يمسّ flow موجود
- [ ] `flutter build apk --debug` ينجح
- [ ] لا طباعة أسرار في logs
- [ ] لا TODOs جديدة بدون ticket مرجعي
- [ ] CHANGELOG.md محدَّث في section `[Unreleased]`

## ما هو خارج نطاقك

- ❌ iOS signing setup — يحتاج Apple Developer Account
- ❌ تصميم الأيقونات — يحتاج designer
- ❌ نشر على Play Store — يحتاج Google Play Console credentials
- ❌ استضافة Privacy Policy — قرار تجاري
- ❌ تعديل migrations في `supabase/migrations/` — يحتاج مراجعة DBA
- ❌ إضافة ميزات جديدة — هذه phase hardening

## البدء

بعد تنفيذ خطوات الاستلام، ابدأ بـ:

> "أنا في طور الاستلام، نفّذت التحقق الأولي، والنتائج: [الصق output الفعلي]. ما هي أولوية العمل اليوم؟"

**لا تُعلن اكتمال الاستلام قبل إنجاز كل خطوات التحقق أعلاه.**
