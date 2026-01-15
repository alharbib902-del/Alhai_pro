# Alhai Core Documentation

الحزمة الأساسية للتطبيقات - Clean Architecture Implementation v3.1

---

## 📦 التثبيت

```yaml
# pubspec.yaml
dependencies:
  alhai_core:
    path: ../alhai_core
```

```dart
import 'package:alhai_core/alhai_core.dart';
```

---

## 🏗️ البنية (Clean Architecture)

```
alhai_core/
├── lib/
│   ├── alhai_core.dart          # Main export
│   └── src/
│       ├── config/              # App configuration
│       ├── models/              # Domain models (Freezed)
│       ├── dto/                 # Data Transfer Objects
│       ├── repositories/        # Repository interfaces
│       ├── datasources/         # Remote/Local data sources
│       ├── networking/          # Dio + Interceptors
│       ├── exceptions/          # App exceptions
│       └── di/                  # Dependency injection
```

---

## 🚀 البدء السريع

### 1. تهيئة DI

```dart
// main.dart
import 'package:alhai_core/alhai_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure API
  AppConfig.configure(baseUrl: 'https://api.alhai.app');
  
  // Initialize dependencies
  await configureDependencies();
  
  runApp(const MyApp());
}
```

### 2. استخدام Repositories

```dart
// الحصول على repository
final authRepo = getIt<AuthRepository>();
final ordersRepo = getIt<OrdersRepository>();
final productsRepo = getIt<ProductsRepository>();

// مثال: تسجيل الدخول
await authRepo.sendOtp('0500000000');
final result = await authRepo.verifyOtp('0500000000', '1234');
print('User: ${result.user.name}');
```

---

## ⚙️ التكوين (Config)

### AppConfig

```dart
// إعداد الـ API
AppConfig.configure(
  baseUrl: 'https://api.alhai.app',  // أو staging URL
);

// الثوابت المتاحة
AppConfig.apiBaseUrl       // Base URL
AppConfig.connectTimeout   // 30 seconds
AppConfig.receiveTimeout   // 30 seconds
AppConfig.sendTimeout      // 30 seconds
```

---

## 📊 Domain Models

جميع الـ models تستخدم **Freezed** للتحقق من Immutability.

### User

```dart
@freezed
class User {
  String id;
  String phone;
  String name;
  UserRole role;      // customer, merchant, delivery, admin
  String? storeId;
  DateTime createdAt;
}

// الاستخدام
final user = User(
  id: '123',
  phone: '0500000000',
  name: 'أحمد محمد',
  role: UserRole.customer,
  createdAt: DateTime.now(),
);

// JSON
final json = user.toJson();
final parsed = User.fromJson(json);
```

### Order

```dart
@freezed
class Order {
  String id;
  String customerId;
  String storeId;
  OrderStatus status;        // pending, confirmed, preparing, delivering, delivered, cancelled
  List<OrderItem> items;
  double total;
  DateTime createdAt;
  String? deliveryAddress;
  PaymentMethod paymentMethod;  // cash, card, wallet
}
```

### OrderItem

```dart
@freezed
class OrderItem {
  String productId;
  String name;
  int quantity;
  double price;
  double total;
}
```

### Product

```dart
@freezed
class Product {
  String id;
  String name;
  String? description;
  String? imageUrl;
  double price;
  bool available;
}
```

### Store

```dart
@freezed
class Store {
  String id;
  String name;
  String? address;
  String? phone;
  bool active;
}
```

### AuthResult

```dart
@freezed
class AuthResult {
  User user;
  AuthTokens tokens;
}
```

### AuthTokens

```dart
@freezed
class AuthTokens {
  String accessToken;
  String refreshToken;
  DateTime expiresAt;
}
```

---

## 🎭 Enums

### UserRole

```dart
enum UserRole {
  customer,   // عميل
  merchant,   // تاجر
  delivery,   // مندوب توصيل
  admin,      // مسؤول
}
```

### OrderStatus

```dart
enum OrderStatus {
  pending,     // قيد الانتظار
  confirmed,   // مؤكد
  preparing,   // قيد التحضير
  delivering,  // في الطريق
  delivered,   // تم التوصيل
  cancelled,   // ملغي
}
```

### PaymentMethod

```dart
enum PaymentMethod {
  cash,    // نقدي
  card,    // بطاقة
  wallet,  // محفظة
}
```

---

## 📁 Repositories

### AuthRepository

```dart
abstract class AuthRepository {
  /// إرسال OTP
  Future<void> sendOtp(String phone);
  
  /// التحقق من OTP
  Future<AuthResult> verifyOtp(String phone, String otp);
  
  /// تحديث الـ token
  Future<AuthTokens> refreshToken();
  
  /// تسجيل الخروج
  Future<void> logout();
  
  /// الحصول على المستخدم الحالي
  Future<User?> getCurrentUser();
  
  /// التحقق من حالة المصادقة
  Future<bool> isAuthenticated();
}
```

### مثال الاستخدام:

```dart
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  
  User? _user;
  User? get user => _user;
  
  AuthProvider(this._repo);
  
  Future<void> login(String phone, String otp) async {
    try {
      final result = await _repo.verifyOtp(phone, otp);
      _user = result.user;
      notifyListeners();
    } on AuthException catch (e) {
      // Handle auth error
      rethrow;
    }
  }
  
  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }
}
```

### OrdersRepository

```dart
abstract class OrdersRepository {
  /// إنشاء طلب جديد
  Future<Order> createOrder(CreateOrderParams params);
  
  /// الحصول على طلب
  Future<Order> getOrder(String id);
  
  /// الحصول على قائمة الطلبات
  Future<List<Order>> getOrders({
    OrderStatus? status,
    int page = 1,
    int limit = 20,
  });
  
  /// تحديث حالة الطلب
  Future<Order> updateStatus(String id, OrderStatus status);
  
  /// إلغاء الطلب
  Future<void> cancelOrder(String id, {String? reason});
}
```

### ProductsRepository

```dart
abstract class ProductsRepository {
  /// الحصول على المنتجات
  Future<List<Product>> getProducts(
    String storeId, {
    int page = 1,
    int limit = 20,
  });
  
  /// الحصول على منتج
  Future<Product> getProduct(String id);
  
  /// البحث بالباركود
  Future<Product?> getByBarcode(String barcode);
  
  /// إنشاء منتج
  Future<Product> createProduct(String storeId, Map<String, dynamic> data);
  
  /// تحديث منتج
  Future<Product> updateProduct(String id, Map<String, dynamic> data);
  
  /// حذف منتج
  Future<void> deleteProduct(String id);
}
```

---

## ⚠️ Exception Handling

### Hierarchy

```dart
sealed class AppException
├── NetworkException    // مشاكل الاتصال
├── AuthException       // 401, 403
├── ValidationException // 400 + field errors
├── ServerException     // 5xx
└── NotFoundException   // 404
```

### الاستخدام

```dart
try {
  final order = await ordersRepo.createOrder(params);
} on NetworkException catch (e) {
  // لا يوجد اتصال
  showError('تحقق من اتصال الإنترنت');
} on ValidationException catch (e) {
  // أخطاء التحقق
  if (e.fieldErrors != null) {
    e.fieldErrors!.forEach((field, errors) {
      print('$field: ${errors.join(", ")}');
    });
  }
} on AuthException catch (e) {
  // انتهت الجلسة
  navigateToLogin();
} on ServerException catch (e) {
  // خطأ في السيرفر
  showError('حدث خطأ، حاول لاحقاً');
} on NotFoundException catch (e) {
  // غير موجود
  showError('العنصر غير موجود');
}
```

### في Provider (النمط الموصى به)

```dart
Future<void> loadData() async {
  _state = ViewState.loading;
  notifyListeners();
  
  try {
    _data = await _repo.getData();
    _state = _data.isEmpty ? ViewState.empty : ViewState.ready;
  } on AppException catch (e) {
    _errorMessage = _mapError(e);
    _state = ViewState.error;
  }
  notifyListeners();
}

String _mapError(AppException e) {
  return switch (e) {
    NetworkException() => 'تحقق من اتصال الإنترنت',
    AuthException() => 'انتهت الجلسة، سجل الدخول مجدداً',
    ValidationException() => e.message,
    ServerException() => 'حدث خطأ، حاول لاحقاً',
    NotFoundException() => 'العنصر غير موجود',
  };
}
```

---

## 🔄 Dependency Injection

### GetIt + Injectable

```dart
// الحصول على كائن
final authRepo = getIt<AuthRepository>();

// في Provider constructor
class OrdersProvider extends ChangeNotifier {
  final OrdersRepository _repository;
  
  OrdersProvider(this._repository);
  // أو
  OrdersProvider() : _repository = getIt<OrdersRepository>();
}
```

### تسجيل في MultiProvider

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => AuthProvider(getIt<AuthRepository>()),
    ),
    ChangeNotifierProvider(
      create: (_) => OrdersProvider(getIt<OrdersRepository>()),
    ),
  ],
  child: const AlhaiApp(),
)
```

---

## 🌐 Networking

### Dio Configuration

```dart
// تتم تلقائياً عبر DI
// Interceptors:
// - AuthInterceptor: يضيف Authorization header
// - ErrorInterceptor: يحول Dio errors إلى AppException
// - LoggingInterceptor: (debug only)
```

### Token Refresh

```dart
// يتم تلقائياً عبر AuthInterceptor:
// 1. إذا كان الـ token منتهي → يحاول refreshToken()
// 2. إذا فشل refresh → يرمي AuthException
// 3. الـ UI يجب أن يستمع ويعيد التوجيه للـ login
```

---

## 📋 Best Practices

### 1. استخدم Repositories فقط

```dart
// ❌ WRONG
final dio = Dio();
final response = await dio.get('/orders');

// ✅ CORRECT
final orders = await getIt<OrdersRepository>().getOrders();
```

### 2. استخدم Domain Models

```dart
// ❌ WRONG
Map<String, dynamic> user = {'name': 'أحمد'};

// ✅ CORRECT
User user = User(name: 'أحمد', ...);
```

### 3. Handle Exceptions

```dart
// ❌ WRONG
try {
  await repo.getData();
} catch (e) {
  print(e);  // ❌
}

// ✅ CORRECT
try {
  await repo.getData();
} on AppException catch (e) {
  _errorMessage = _mapError(e);
  _state = ViewState.error;
}
```

### 4. Don't Expose DTOs

```dart
// ❌ WRONG (في UI)
final dto = OrderDto.fromJson(json);

// ✅ CORRECT (في UI)
final order = await ordersRepo.getOrder(id);
// Repositories تحول DTO → Model داخلياً
```

---

## 📊 الملخص

| المكون | الوصف |
|--------|-------|
| **Models** | User, Order, Product, Store (Freezed) |
| **Repositories** | AuthRepository, OrdersRepository, ProductsRepository |
| **Exceptions** | AppException sealed class |
| **DI** | GetIt + Injectable |
| **Networking** | Dio with interceptors |
| **Storage** | SharedPreferences + FlutterSecureStorage |

---

**Version:** 3.1  
**Last Updated:** 2026-01-10
