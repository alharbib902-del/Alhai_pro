# 📦 POS App - Dependencies

**التاريخ**: 2026-01-15  
**الإصدار**: 1.0

---

## pubspec.yaml

```yaml
name: pos_app
description: Point of Sale application for Alhai grocery stores
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # ⭐ الحزم المشتركة (Priority)
  alhai_core:
    path: ../alhai_core
  alhai_design_system:
    path: ../alhai_design_system

  # State Management (DI + ViewModels)
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  get_it: ^7.6.4
  injectable: ^2.3.2

  # Routing
  go_router: ^13.0.0

  # Local Database
  drift: ^2.14.1
  sqlite3_flutter_libs: ^0.5.18
  path_provider: ^2.1.1
  path: ^1.8.3

  # Backend
  supabase_flutter: ^2.3.4
  dio: ^5.4.0

  # Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0

  # Images
  cached_network_image: ^3.3.1
  image_picker: ^1.0.7
  image: ^4.1.7

  # Printing
  esc_pos_printer: ^4.1.0
  esc_pos_utils: ^1.1.0
  pdf: ^3.10.7
  printing: ^5.12.0

  # Utils
  intl: ^0.19.0
  uuid: ^4.3.3
  connectivity_plus: ^5.0.2
  permission_handler: ^11.2.0
  file_picker: ^6.1.1

  # UI helpers
  shimmer: ^3.0.0
  flutter_spinkit: ^5.2.0

  # Analytics
  firebase_core: ^2.24.2
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9
  sentry_flutter: ^7.14.0

dev_dependencies:
  flutter_test:
    sdk: flutter

  # Code Generation
  build_runner: ^2.4.7
  riverpod_generator: ^2.3.9
  injectable_generator: ^2.4.1
  drift_dev: ^2.14.1

  # Linting
  flutter_lints: ^3.0.1

  # Testing
  mockito: ^5.4.4
  faker: ^2.1.0

flutter:
  uses-material-design: true

  assets:
    - assets/images/
    - assets/icons/
```

---

## التثبيت

### 1. Clone المشروع
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai
```

### 2. التأكد من alhai_core و alhai_design_system
```bash
cd alhai_core
flutter pub get
cd ../alhai_design_system
flutter pub get
```

### 3. إنشاء pos_app project
```bash
flutter create pos_app
cd pos_app
```

### 4. استبدل pubspec.yaml
نسخ المحتوى أعلاه

### 5. Install dependencies
```bash
flutter pub get
```

### 6. Generate code (بعد إضافة Models)
```bash
dart run build_runner build -d
```

### 7. Run
```bash
flutter run -d windows  # أو macos أو linux
```

---

## الأذونات المطلوبة

### Windows
لا توجد أذونات خاصة

### macOS
في `macos/Runner/DebugProfile.entitlements`:
```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

### Linux
`linux/my_application.cc` - no special permissions

---

## Environment Variables

إنشاء `.env` في root:
```env
# Development
SUPABASE_URL=https://dev-xyz.supabase.co
SUPABASE_ANON_KEY=eyJhbGc...
API_URL=https://dev-api.alhai.sa
CDN_URL=https://dev-cdn.alhai.sa

# Staging
# SUPABASE_URL=https://staging-xyz.supabase.co
# ...

# Production
# SUPABASE_URL=https://prod-xyz.supabase.co
# ...
```

---

**✅ جاهز للبدء!**
