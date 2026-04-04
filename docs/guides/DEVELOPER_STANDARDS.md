# 📋 Alhai Developer Standards
## معايير المبرمجين للتوافق 100%

> **Version:** 2.0.0 | **Date:** 2026-01-10

---

## ⚠️ قواعد إلزامية - يجب الالتزام بها

### 1. 📦 الحزم المشتركة (Shared Packages)

```yaml
# pubspec.yaml - يجب أن تكون متطابقة
dependencies:
  alhai_core:
    path: ../alhai_core
  alhai_design_system:
    path: ../alhai_design_system
```

> **⛔ ممنوع:** إضافة packages بديلة للموجودة في core أو design_system

---

## 2. 🏗️ بنية المجلدات (Folder Structure)

```
lib/
├── main.dart                    # Entry point فقط
├── app.dart                     # MaterialApp configuration
├── di/
│   └── injection.dart           # GetIt configuration
├── core/
│   ├── router/                  # go_router setup
│   └── constants/               # App-specific constants
├── features/
│   ├── [feature_name]/
│   │   ├── presentation/
│   │   │   ├── screens/         # Screen widgets
│   │   │   ├── widgets/         # Feature-specific widgets
│   │   │   └── view_models/     # State management
│   │   └── data/                # Feature-specific data (if any)
└── shared/
    └── widgets/                 # App-wide shared widgets
```

---

## 3. 📝 تسمية الملفات (Naming Conventions)

| النوع | الصيغة | مثال |
|-------|--------|------|
| **Files** | snake_case | `products_screen.dart` |
| **Classes** | PascalCase | `ProductsScreen` |
| **Variables** | camelCase | `productsViewModel` |
| **Constants** | camelCase | `defaultPageSize` |
| **Private** | _prefix | `_isLoading` |

### أسماء الملفات:
```
[feature]_screen.dart        → ProductsScreen
[feature]_view_model.dart    → ProductsViewModel
[feature]_widget.dart        → ProductCard (widget فقط)
```

---

## 4. 🎨 استخدام Design System

### ✅ صحيح:
```dart
import 'package:alhai_design_system/alhai_design_system.dart';

// Colors
Theme.of(context).colorScheme.primary

// Spacing
AlhaiSpacing.sm  // 8
AlhaiSpacing.md  // 16
AlhaiSpacing.lg  // 24
AlhaiSpacing.xl  // 32

// Radius
AlhaiRadius.sm   // 8
AlhaiRadius.md   // 12
AlhaiRadius.lg   // 16

// Components
AlhaiButton(text: 'إضافة', onPressed: () {})
AlhaiTextField(label: 'الاسم', controller: _controller)
```

### ❌ ممنوع:
```dart
// ❌ لا تستخدم قيم مباشرة
padding: EdgeInsets.all(16)  // استخدم AlhaiSpacing.md

// ❌ لا تستخدم ألوان مباشرة
color: Colors.blue  // استخدم Theme.of(context).colorScheme

// ❌ لا تنشئ buttons مخصصة
ElevatedButton(...)  // استخدم AlhaiButton
```

---

## 5. 📊 استخدام Core

### ✅ صحيح:
```dart
import 'package:alhai_core/alhai_core.dart';

// Repository Pattern
final products = await _productsRepository.getProducts(page: 1);

// Domain Models
Product product = products.items.first;
print(product.profitMargin);

// Error Handling
try {
  await repository.someOperation();
} on AppException catch (e) {
  showError(e.messageAr);
}
```

### ❌ ممنوع:
```dart
// ❌ لا تتعامل مع Dio مباشرة
final response = await dio.get('/products');

// ❌ لا تستخدم Map بدل Models
Map<String, dynamic> product = {};

// ❌ لا تتجاوز Repository
await datasource.getProducts();
```

---

## 6. 🤖 استخدام AI Analytics (NEW)

### الـ Repositories المتاحة:
```dart
// Analytics & AI
AnalyticsRepository   → getSmartAlerts, getSlowMovingProducts
                      → getSalesForecast, getReorderSuggestions
                      → getPeakHoursAnalysis, getDashboardSummary
```

### Models الذكية:
```dart
// AI Models
SlowMovingProduct    → daysSinceLastSale, riskLevel
SalesForecast        → predictedRevenue, confidence
SmartAlert           → type, priority, actionRoute
ReorderSuggestion    → suggestedQuantity, urgency
PeakHoursAnalysis    → peakHour, hourlyRevenue
CustomerPattern      → frequentProducts, averageOrderValue
```

### مثال الاستخدام:
```dart
// Get slow moving products
final slowMoving = await _analyticsRepository.getSlowMovingProducts(
  storeId,
  daysThreshold: 30,
);

for (final product in slowMoving) {
  print('${product.productName}: ${product.riskLevel}');
}

// Get smart alerts
final alerts = await _analyticsRepository.getSmartAlerts(
  storeId,
  unreadOnly: true,
);

// Get dashboard summary
final summary = await _analyticsRepository.getDashboardSummary(storeId);
print('Today: ${summary.todaySales.revenue}');
print('Alerts: ${summary.alertsCount}');
```

---

## 7. 🔄 ViewModel Pattern

### القالب الإلزامي:
```dart
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:alhai_core/alhai_core.dart';

@injectable
class [Feature]ViewModel extends ChangeNotifier {
  final [Feature]Repository _repository;
  
  [Feature]ViewModel(this._repository);
  
  // State
  List<[Model]> _items = [];
  List<[Model]> get items => _items;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  AppException? _error;
  AppException? get error => _error;
  
  // Actions
  Future<void> load() async {
    _setLoading(true);
    try {
      final result = await _repository.getItems();
      _items = result.items;
      _error = null;
    } on AppException catch (e) {
      _error = e;
    }
    _setLoading(false);
  }
  
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
```

---

## 8. 🧭 RTL Support

### ✅ صحيح:
```dart
// Directional padding
padding: EdgeInsetsDirectional.only(
  start: AlhaiSpacing.md,
  end: AlhaiSpacing.sm,
)

// Directional alignment
alignment: AlignmentDirectional.centerStart

// Directional positioning
Positioned.directional(
  textDirection: Directionality.of(context),
  start: 0,
  child: widget,
)
```

### ❌ ممنوع:
```dart
// ❌ No left/right
padding: EdgeInsets.only(left: 16, right: 8)
alignment: Alignment.centerLeft
Positioned(left: 0, child: widget)
```

---

## 9. 🧪 Testing Requirements

### كل ViewModel يجب أن يكون له test:
```dart
// test/features/[feature]/[feature]_view_model_test.dart

void main() {
  late [Feature]ViewModel viewModel;
  late Mock[Feature]Repository mockRepository;
  
  setUp(() {
    mockRepository = Mock[Feature]Repository();
    viewModel = [Feature]ViewModel(mockRepository);
  });
  
  test('load fetches items successfully', () async {
    // Arrange
    when(() => mockRepository.getItems())
        .thenAnswer((_) async => Paginated(items: [...], ...));
    
    // Act
    await viewModel.load();
    
    // Assert
    expect(viewModel.items, isNotEmpty);
    expect(viewModel.error, isNull);
  });
}
```

---

## 10. 📋 Git Workflow

### Branch Naming:
```
feature/[feature-name]    → feature/products-grid
bugfix/[bug-description]  → bugfix/cart-total-calculation
hotfix/[fix-description]  → hotfix/login-crash
```

### Commit Messages (Arabic/English):
```
feat: إضافة شاشة المنتجات
fix: إصلاح حساب المجموع في السلة
refactor: تحسين ProductsViewModel
test: إضافة tests للـ CartViewModel
docs: تحديث README
```

### قبل كل Commit:
```bash
flutter analyze   # يجب أن يكون 0 issues
flutter test      # يجب أن تنجح جميع الـ tests
```

---

## 11. 📝 Documentation Requirements

### كل ملف جديد يحتاج:
```dart
/// وصف قصير للـ class
/// 
/// استخدام:
/// ```dart
/// final vm = ProductsViewModel(repository);
/// await vm.loadProducts();
/// ```
class ProductsViewModel {
  /// وصف الـ method
  Future<void> loadProducts() async {
    // ...
  }
}
```

---

## 12. 📱 Responsive Design

### استخدم ResponsiveBuilder:
```dart
ResponsiveBuilder(
  mobile: (context) => MobileLayout(),
  tablet: (context) => TabletLayout(),
  desktop: (context) => DesktopLayout(),
)
```

### أو استخدم context extensions:
```dart
if (context.isMobile) {
  // Mobile layout
} else if (context.isTablet) {
  // Tablet layout
}
```

---

## 13. 🔐 Security Rules

### ممنوع:
- ❌ Hardcoded API keys
- ❌ Hardcoded passwords
- ❌ Logging sensitive data
- ❌ Storing tokens in SharedPreferences without encryption

### مطلوب:
- ✅ Use flutter_secure_storage for tokens
- ✅ Use environment variables for API keys
- ✅ Obfuscate release builds

---

## 14. ✅ Code Review Checklist

قبل طلب Review، تأكد من:

- [ ] `flutter analyze` = 0 issues
- [ ] `flutter test` = all passed
- [ ] لا يوجد hardcoded values
- [ ] استخدام AlhaiSpacing/AlhaiRadius
- [ ] استخدام components من design system
- [ ] RTL support (EdgeInsetsDirectional)
- [ ] Error handling مع AppException
- [ ] ViewModel يتبع القالب المعتمد
- [ ] Unit tests للـ ViewModel
- [ ] التوثيق للـ public APIs

---

## 15. 📞 Communication

### عند وجود سؤال:
1. راجع DEVELOPMENT_GUIDELINES.md
2. راجع STANDARD_APP_PROMPT.md
3. راجع POS_APP_PROMPT.md (للـ POS)
4. راجع الكود الموجود للأمثلة
5. اسأل في قناة الفريق

### عند إضافة dependency جديد:
1. تأكد أنه غير موجود في core/design_system
2. ناقش مع الفريق قبل الإضافة
3. وثق السبب في PR

---

## 📋 Quick Reference Card

```
┌─────────────────────────────────────────────────────┐
│ 🎨 DESIGN SYSTEM                                    │
├─────────────────────────────────────────────────────┤
│ Spacing: AlhaiSpacing.sm/md/lg/xl                  │
│ Radius:  AlhaiRadius.sm/md/lg                      │
│ Colors:  Theme.of(context).colorScheme.*           │
│ Button:  AlhaiButton                               │
│ Input:   AlhaiTextField                            │
│ Card:    AlhaiCard                                 │
├─────────────────────────────────────────────────────┤
│ 📦 CORE REPOSITORIES (13)                           │
├─────────────────────────────────────────────────────┤
│ Auth, Orders, Products, Categories, Stores         │
│ Addresses, Delivery, Inventory, Suppliers          │
│ Purchases, Debts, Reports, Analytics ★             │
├─────────────────────────────────────────────────────┤
│ 🤖 AI MODELS                                        │
├─────────────────────────────────────────────────────┤
│ SlowMovingProduct, SalesForecast, SmartAlert       │
│ ReorderSuggestion, PeakHoursAnalysis               │
│ CustomerPattern, DashboardSummary                  │
├─────────────────────────────────────────────────────┤
│ ✅ DO                    │ ❌ DON'T                 │
├─────────────────────────────────────────────────────┤
│ Use Repositories        │ Direct Dio calls        │
│ Use Domain Models       │ Map<String, dynamic>    │
│ EdgeInsetsDirectional   │ EdgeInsets left/right   │
│ AlhaiSpacing.md         │ EdgeInsets.all(16)      │
│ Theme.of(context)       │ Colors.blue             │
│ AlhaiButton             │ ElevatedButton          │
│ AnalyticsRepository     │ Manual calculations     │
└─────────────────────────────────────────────────────┘
```

---

## 16. 📷 استخدام الصور (Images) ★ R2 Integration

### ✅ صحيح:
```dart
import 'package:cached_network_image/cached_network_image.dart';

// للمنتجات - استخدم الحجم المناسب
Widget buildProductImage(Product product, ImageSize size) {
  final imageUrl = switch (size) {
    ImageSize.thumbnail => product.imageThumbnail,
    ImageSize.medium => product.imageMedium,
    ImageSize.large => product.imageLarge,
  } ?? product.imageUrl ?? '';
  
  return CachedNetworkImage(
    imageUrl: imageUrl,
    placeholder: (context, url) => AlhaiSkeleton(),
    errorWidget: (context, url, error) => Icon(Icons.broken_image),
    cacheManager: CacheManager(
      Config('product_images', stalePeriod: Duration(days: 30)),
    ),
  );
}

// في Grid/List → استخدم thumbnail
ProductImage(product, ImageSize.thumbnail)

// في صفحة التفاصيل → استخدم large
ProductImage(product, ImageSize.large)
```

### ❌ ممنوع:
```dart
// ❌ لا تستخدم Image.network بدون caching
Image.network(product.imageUrl)

// ❌ لا تحمّل الصورة الكبيرة في Grid
Image.network(product.imageLarge)  // استخدم thumbnail

// ❌ لا تستخدم imageUrl القديم (deprecated)
Image.network(product.imageUrl)  // استخدم imageThumbnail/Medium/Large
```

### متى تستخدم كل حجم:
| الحجم | الاستخدام | الأبعاد |
|-------|----------|---------|
| **thumbnail** | Grid, List, Search | 300×300 |
| **medium** | Quick View, Drawer | 600×600 |
| **large** | Product Detail, Zoom | 1200×1200 |

---

## 📝 Version History

| Version | Date       | Changes                              |
|---------|------------|--------------------------------------|
| 1.0.0   | 2026-01-10 | Initial standards release            |
| 2.0.0   | 2026-01-10 | Added AI Analytics section (§6)      |
| 3.0.0   | 2026-01-15 | Added R2 Image Storage (§16)         |
