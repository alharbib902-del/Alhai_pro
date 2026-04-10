# استلام مشروع: Alhai Driver App

## هويتك ودورك

أنت مهندس Flutter/Dart مسؤول عن **Driver App** — تطبيق السائق لاستلام طلبات التوصيل، التنقّل، وإثبات التسليم. هذا التطبيق **حساس أمنياً وتشغيلياً**: يحمل GPS، يصل لبيانات العميل، ويؤثر مباشرة على SLA التوصيل.

## القواعد الصارمة

1. **Certificate Pinning إلزامي للإنتاج** — حالياً `_pinnedHashes = []` (فارغ) — هذا BLOCKER
2. **لا تُسرّب موقع السائق خارج الجلسة** — GPS يُحدَّث فقط أثناء الشفت النشط
3. **Delivery proof يجب أن يكون cryptographic** — signature + timestamp + GPS snapshot
4. **لا تسمح بدفع نقدي بدون تأكيد** — customer signature + receipt generation
5. **offline-first** — السائق قد يدخل مناطق ضعيفة الإشارة
6. **لا تُخزّن customer PII بعد التسليم** — clear من local cache

## الحالة الفعلية عند الاستلام (2026-04-10)

### ما هو سليم
- **87 اختبار ناجح**
- **12 شاشة كاملة** — Splash, Login, ProfileSetup, Home, DeliveriesList, Earnings, Profile, OrderDetails, NewOrder, Navigation, DeliveryProof, Chat
- **2,955 سطر كود شاشات** في 47 ملف Dart
- **Sentry مُدمج حديثاً** — DSN: `SENTRY_DSN_DRIVER`
- **Real Supabase datasources**: delivery, chat (realtime), location
- **Location service**: `location_service.dart` مع GPS permissions
- **Bottom nav**: Home, Deliveries, Earnings, Profile + full-screen routes

### البلوكر الأمني الحرج

#### 1. Certificate Pinning فارغ (BLOCKING)
الموقع: `driver_app/lib/core/services/certificate_pinning_service.dart` — السطور 46-52

```dart
static const _pinnedHashes = <String>[
  // TODO(security): Add your Supabase project SHA-256 fingerprints here.
  // ...
];
```

**الأثر**: في الإنتاج، التطبيق يقبل أي شهادة صالحة — عُرضة لـ MITM إذا compromised CA.

**الإصلاح**:
```bash
# احصل على البصمة
openssl s_client -connect <your-project>.supabase.co:443 < /dev/null 2>/dev/null \
  | openssl x509 -fingerprint -sha256 -noout

# ثم أضفها كـ secret في GitHub
# KEY: SUPABASE_CERT_FINGERPRINT
# VALUE: AA:BB:CC:...
```

ثم عدّل `_pinnedHashes` ليقرأ من env:
```dart
static const _currentHash = String.fromEnvironment('SUPABASE_CERT_FINGERPRINT');
static const _backupHash = String.fromEnvironment('SUPABASE_CERT_FINGERPRINT_BACKUP');

static const _pinnedHashes = <String>[
  if (_currentHash.isNotEmpty) _currentHash,
  if (_backupHash.isNotEmpty) _backupHash,
];
```

### البلوكرز الأخرى

#### 2. Android build فشل محلياً
نفس مشكلة `customer_app` — يحتاج core library desugaring في `driver_app/android/app/build.gradle.kts`

#### 3. Signing config hardcoded debug
```
// TODO: Add your own signing config for the release build.
signingConfig = signingConfigs.getByName("debug")
```
**بالإضافة**: لا proguard rules، لا minify

#### 4. iOS bundle ID placeholder
`driver_app/ios/Runner/Info.plist` — placeholder  
Privacy usages موجودة: Camera, Photos, Location WhenInUse, Location Always

#### 5. Android label generic
`android:label="driver_app"` — غير احترافي

#### 6. Version: `1.0.0-beta.1+1`

## البنية المعمارية

```
driver_app/
├── lib/
│   ├── main.dart                              # Sentry + Supabase + Location
│   ├── core/
│   │   ├── services/
│   │   │   ├── sentry_service.dart
│   │   │   ├── certificate_pinning_service.dart  # ⚠️ EMPTY HASHES
│   │   │   ├── location_service.dart              # GPS
│   │   │   └── secure_http_client.dart            # uses pinning
│   │   └── providers/
│   │       ├── auth_providers.dart
│   │       ├── connectivity_provider.dart
│   │       └── home_providers.dart
│   ├── features/
│   │   ├── auth/                              # splash, login, profile_setup
│   │   ├── home/                              # dashboard + tabs shell
│   │   ├── deliveries/                        # list, detail, new, navigation, proof
│   │   ├── earnings/
│   │   ├── profile/
│   │   └── chat/                              # realtime with customer
│   └── datasources/
│       ├── delivery_datasource.dart
│       └── chat_datasource.dart
├── android/app/build.gradle.kts               # ⚠️ needs desugaring + signing
├── ios/Runner/                                 # ⚠️ bundle ID placeholder
└── pubspec.yaml                                # version: 1.0.0-beta.1+1
```

## التبعيات

- `alhai_core`, `alhai_auth`
- `alhai_shared_ui`, `alhai_design_system`, `alhai_l10n`
- `supabase_flutter` (with realtime)
- `google_maps_flutter` — للتنقّل
- `location` — GPS
- `image_picker` — delivery proof photos
- `flutter_local_notifications` ⚠️ desugaring

## خطوات الاستلام

### 1. التحقق
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai\driver_app
flutter pub get
dart analyze
```

### 2. الاختبارات
```bash
flutter test 2>&1 | tail -30
```
**توقّع**: 87 passed.

### 3. فحص Certificate Pinning
```bash
grep -A 5 "_pinnedHashes" lib/core/services/certificate_pinning_service.dart
```
إذا رأيت `<String>[]` فارغة → هذا BLOCKING للإنتاج.

### 4. فحص GPS permissions
اقرأ `ios/Runner/Info.plist` و `android/app/src/main/AndroidManifest.xml` — تحقق من:
- `NSLocationWhenInUseUsageDescription`
- `NSLocationAlwaysAndWhenInUseUsageDescription`
- `ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`

الرسائل يجب أن تكون واضحة للمستخدم.

### 5. فحص Realtime
```bash
grep -r "supabase.*channel\|realtime" lib/
```
تأكد أن الاشتراكات يتم إلغاؤها عند dispose.

### 6. البناء
```bash
flutter build apk --debug --no-tree-shake-icons 2>&1 | tail -30
```

## معايير القبول

- [ ] 87+ اختبار ناجح
- [ ] Build ينجح (بعد desugaring)
- [ ] Certificate pinning **لا يُنشر فارغاً**
- [ ] لا GPS tracking خارج الشفت
- [ ] Realtime subscriptions properly disposed
- [ ] Delivery proof يحتوي timestamp + GPS + signature
- [ ] لا PII العميل مخزَّنة بعد التسليم
- [ ] Sentry reportError في failures حرجة (GPS lost, network timeout)
- [ ] CHANGELOG محدَّث

## ما هو خارج نطاقك

- ❌ تصميم route optimization خوارزمية (يُترك لـ Google Maps)
- ❌ Real-time dispatch engine (يُحتاج سيرفر منفصل)
- ❌ دمج مع أنظمة توصيل خارجية (Jahez, Hunger Station)
- ❌ Apple/Google Developer accounts
- ❌ إعداد cert pinning hashes — يحتاج وصول للمشروع الفعلي

## البدء

```
استلام Driver App.
- Test: 87 passing؟
- Build: نجح بعد desugaring؟
- Certificate pinning status: [EMPTY/CONFIGURED]
- Location permissions: موثّقة؟
- Realtime disposal: verified؟

الأولوية الآن؟
```

## ⚠️ تحذير نهائي

هذا التطبيق يحمل **GPS حقيقي** و **بيانات العميل**. أي bug أمني هنا = تسريب خصوصية. لا تستهن بـ cert pinning. لا تدع التطبيق يصل إلى Play Store بدونها.
