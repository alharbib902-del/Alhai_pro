# 🛠️ دليل المطور - نظام نقاط البيع

## 📁 هيكل المشروع

```
pos_app/
├── lib/
│   ├── core/                 # الإعدادات الأساسية
│   │   ├── config/           # ثوابت التطبيق
│   │   ├── router/           # GoRouter setup
│   │   └── theme/            # Material Theme
│   │
│   ├── data/                 # طبقة البيانات
│   │   ├── local/            # Drift Database
│   │   │   ├── tables/       # تعريف الجداول
│   │   │   ├── daos/         # Data Access Objects
│   │   │   └── app_database.dart
│   │   └── remote/           # API Layer
│   │       ├── api_client.dart
│   │       └── api_endpoints.dart
│   │
│   ├── providers/            # Riverpod Providers
│   │   ├── auth_providers.dart
│   │   ├── cart_provider.dart
│   │   └── products_provider.dart
│   │
│   ├── screens/              # UI Screens
│   │   ├── pos/
│   │   ├── products/
│   │   ├── customers/
│   │   ├── reports/
│   │   └── settings/
│   │
│   ├── services/             # Business Logic
│   │   ├── sale_service.dart
│   │   ├── sync_service.dart
│   │   └── zatca_service.dart
│   │
│   └── widgets/              # Reusable Widgets
│
├── test/                     # Unit Tests
├── integration_test/         # Integration Tests
└── docs/                     # Documentation
```

---

## 🗄️ قاعدة البيانات (Drift)

### Schema Version: 4

### إضافة جدول جديد

```dart
// 1. أنشئ ملف الجدول في lib/data/local/tables/
class NewTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
}

// 2. أضفه للـ AppDatabase
@DriftDatabase(tables: [
  ...,
  NewTable,
])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 5; // زيادة الإصدار
  
  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 5) {
        await m.createTable(newTable);
      }
    },
  );
}

// 3. شغل build_runner
// dart run build_runner build --delete-conflicting-outputs
```

---

## 🔄 State Management (Riverpod)

### إنشاء Provider

```dart
// StateNotifierProvider للحالة المعقدة
final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  return CartNotifier();
});

// FutureProvider للبيانات من API/Database
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final db = ref.read(databaseProvider);
  return db.productsDao.getAllProducts();
});

// StreamProvider للبيانات المباشرة
final salesStreamProvider = StreamProvider<List<Sale>>((ref) {
  final db = ref.read(databaseProvider);
  return db.salesDao.watchTodaySales();
});
```

---

## 🌐 API Integration

### إضافة Endpoint جديد

```dart
// في api_endpoints.dart
class ApiEndpoints {
  static const String newEndpoint = '/api/v1/new-endpoint';
}

// في api_client.dart
Future<Response> fetchNewData() async {
  return await _dio.get(ApiEndpoints.newEndpoint);
}
```

---

## 🧪 الاختبارات

### تشغيل الاختبارات

```bash
# Unit Tests
flutter test

# Integration Tests
flutter test integration_test/

# مع التغطية
flutter test --coverage
```

### مثال Unit Test

```dart
void main() {
  group('CartNotifier', () {
    test('should add product to cart', () {
      final notifier = CartNotifier();
      notifier.addProduct(testProduct);
      expect(notifier.state.items.length, 1);
    });
  });
}
```

---

## 📱 البناء والنشر

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Play Store)
flutter build appbundle
```

### iOS

```bash
flutter build ios --release
```

---

## 🔧 الأدوات المستخدمة

| الأداة | الغرض |
|--------|-------|
| `flutter_riverpod` | إدارة الحالة |
| `drift` | قاعدة البيانات |
| `go_router` | التنقل |
| `dio` | HTTP Client |
| `shared_preferences` | التخزين المحلي |
| `flutter_blue_plus` | Bluetooth (طابعة) |

---

## 📝 معايير الكود

### التسمية
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Files: `snake_case.dart`
- Constants: `camelCase` أو `SCREAMING_SNAKE_CASE`

### التنظيم
- ملف واحد لكل Class رئيسي
- Private widgets في نفس الملف (بـ _)
- فصل Business Logic عن UI

---

## 🐛 التصحيح

### Analyze
```bash
flutter analyze
dart analyze
```

### Logs
```dart
import 'package:flutter/foundation.dart';
debugPrint('Debug message');
```

---

## 📞 للاستفسارات

راجع الوثائق أو تواصل مع فريق التطوير.
