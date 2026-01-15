# 🛒 POS App Development Prompt
## دليل مطور تطبيق نقطة البيع

> **Version:** 2.0.0 | **Date:** 2026-01-10 | **Platform:** Tablet-first

---

## 🎯 نظرة عامة على المشروع

أنت تعمل على تطوير **POS App** - تطبيق نقطة بيع ذكي لإدارة بقالة مع ميزات AI Analytics.

### المنصة المستهدفة:
- **Primary:** Tablet (10" - 12")
- **Secondary:** Desktop

### اللغة:
- **Primary:** العربية (RTL)
- **Secondary:** English (LTR)

### الميزات المتقدمة:
- 🤖 **AI Analytics:** تقارير ذكية وتنبيهات
- 📊 **Dashboard:** لوحة تحكم لحظية
- 🔔 **Smart Alerts:** تنبيهات استباقية
- 📶 **Offline Mode:** عمل بدون انترنت

---

## 📦 الحزم الإلزامية

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Shared Packages (REQUIRED)
  alhai_core:
    path: ../alhai_core
  alhai_design_system:
    path: ../alhai_design_system
  
  # State Management
  provider: ^6.1.0
  
  # DI
  get_it: ^7.6.0
  injectable: ^2.3.0
  
  # Navigation
  go_router: ^13.0.0
  
  # Barcode
  mobile_scanner: ^4.0.0
  
  # Local Storage (Offline)
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Utils
  intl: ^0.18.0
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  injectable_generator: ^2.4.0
  build_runner: ^2.4.0
  hive_generator: ^2.0.1
  mocktail: ^1.0.0
```

---

## 🏗️ بنية المشروع

```
pos_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── di/
│   │   └── injection.dart
│   ├── core/
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── constants/
│   │   └── services/
│   │       ├── offline_service.dart
│   │       └── sync_service.dart
│   ├── features/
│   │   ├── dashboard/            ★ NEW
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── dashboard_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── stats_cards.dart
│   │   │   │       ├── alerts_widget.dart
│   │   │   │       └── sales_chart.dart
│   │   │   └── view_models/
│   │   │       └── dashboard_view_model.dart
│   │   ├── home/
│   │   │   ├── presentation/
│   │   │   │   ├── screens/
│   │   │   │   │   └── home_screen.dart
│   │   │   │   └── widgets/
│   │   │   │       ├── products_grid.dart
│   │   │   │       └── cart_panel.dart
│   │   │   └── view_models/
│   │   │       └── home_view_model.dart
│   │   ├── products/
│   │   ├── cart/
│   │   ├── orders/
│   │   ├── inventory/
│   │   ├── suppliers/
│   │   ├── debts/
│   │   ├── reports/
│   │   └── analytics/            ★ NEW
│   └── shared/
│       └── widgets/
└── test/
    └── features/
```

---

## 📱 الشاشات الرئيسية

### 1. Dashboard (لوحة التحكم) ★ NEW
```
┌─────────────────────────────────────────────────────────────┐
│  � لوحة التحكم                             [اليوم ▼]      │
├─────────────────────────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐            │
│ │ 💵      │ │ 📦      │ │ 👥      │ │ 📈      │            │
│ │ 5,420   │ │ 145     │ │ 32      │ │ +12%    │            │
│ │ المبيعات │ │ الطلبات │ │ العملاء │ │ النمو   │            │
│ └─────────┘ └─────────┘ └─────────┘ └─────────┘            │
├─────────────────────────────────────────────────────────────┤
│  ⚠️ تنبيهات ذكية (3)                                       │
│  • 🔴 5 منتجات راكدة منذ 30+ يوم                          │
│  • 🟡 "حليب طازج" على وشك النفاد                          │
│  • 🟢 "شيبس ليز" الأكثر مبيعاً اليوم                      │
├─────────────────────────────────────────────────────────────┤
│  🏆 Top 5             │  � راكد 5           │ 📈 Chart    │
│  1. شيبس - 45        │  1. معجون - 60 يوم   │   ▁▂▃▅▆▇█  │
│  2. بيبسي - 38       │  2. شامبو - 45 يوم   │   (by hour) │
└──────────────────────┴──────────────────────┴──────────────┘
```

### 2. الشاشة الرئيسية (Split View)
```
┌─────────────────────────────────────────────────────────────┐
│  🔍 بحث المنتجات          [📷 Barcode]    [☰ القائمة]      │
├─────────────────────────────────────────────────────────────┤
│ [الكل] [خضروات] [فواكه] [مشروبات] [منظفات] ...            │
├───────────────────────────────────┬─────────────────────────┤
│   ┌───┐ ┌───┐ ┌───┐ ┌───┐       │   🛒 السلة              │
│   │ 📦 │ │ 📦 │ │ 📦 │ │ 📦 │       │   ├─ منتج 1  ×2       │
│   └───┘ └───┘ └───┘ └───┘       │   ├─ منتج 2  ×1       │
│   Products Grid (70%)            │   المجموع: 150 ر.س      │
│                                   │   [💵 إتمام البيع]      │
└───────────────────────────────────┴─────────────────────────┘
```

---

## 🔧 Available Repositories (13)

### From alhai_core:
```dart
// Products & Categories
ProductsRepository    → getProducts, getByBarcode, CRUD
CategoriesRepository  → getCategories

// Orders
OrdersRepository      → createOrder, getOrders, updateStatus

// Inventory
InventoryRepository   → adjustStock, getLowStock

// Suppliers
SuppliersRepository   → CRUD suppliers
PurchasesRepository   → create/receive purchase orders

// Debts
DebtsRepository       → createDebt, recordPayment, getSummary

// Reports
ReportsRepository     → getDailySummary, getTopProducts

// AI Analytics ★ NEW
AnalyticsRepository   → getSlowMovingProducts, getSalesForecast
                      → getSmartAlerts, getReorderSuggestions
                      → getPeakHoursAnalysis, getDashboardSummary
```

---

## 🤖 AI Analytics Models (NEW)

### Available Models:
```dart
// Slow Moving Products
SlowMovingProduct {
  productId, productName, daysSinceLastSale,
  stockQty, stockValue, suggestedDiscount,
  riskLevel  // "عالي جداً" | "عالي" | "متوسط" | "منخفض"
}

// Sales Forecast
SalesForecast {
  date, predictedRevenue, predictedOrders,
  confidence, confidenceLevel  // "عالي" | "متوسط" | "منخفض"
}

// Smart Alerts
SmartAlert {
  id, type, title, message, actionLabel,
  priority, isRead, createdAt
}
AlertType: lowStock, slowMoving, expiringSoon,
           highDemand, debtOverdue, reorderSuggestion

// Reorder Suggestions
ReorderSuggestion {
  productId, productName, currentStock,
  suggestedQuantity, daysUntilStockout,
  urgency  // "عاجل" | "مهم" | "عادي"
}

// Dashboard Summary
DashboardSummary {
  todaySales, alertsCount, lowStockCount,
  slowMovingCount, revenueChange, totalDebtsAmount
}
```

---

## 📋 Dashboard ViewModel Template

```dart
@injectable
class DashboardViewModel extends ChangeNotifier {
  final AnalyticsRepository _analyticsRepository;
  final ReportsRepository _reportsRepository;
  
  DashboardViewModel(this._analyticsRepository, this._reportsRepository);
  
  // State
  DashboardSummary? _summary;
  DashboardSummary? get summary => _summary;
  
  List<SmartAlert> _alerts = [];
  List<SmartAlert> get alerts => _alerts;
  
  List<SlowMovingProduct> _slowMoving = [];
  List<SlowMovingProduct> get slowMoving => _slowMoving;
  
  List<ProductSales> _topProducts = [];
  List<ProductSales> get topProducts => _topProducts;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  Future<void> loadDashboard(String storeId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final results = await Future.wait([
        _analyticsRepository.getDashboardSummary(storeId),
        _analyticsRepository.getSmartAlerts(storeId, unreadOnly: true),
        _analyticsRepository.getSlowMovingProducts(storeId, limit: 5),
        _reportsRepository.getTopProducts(storeId,
          startDate: DateTime.now().subtract(Duration(days: 7)),
          endDate: DateTime.now(),
          limit: 5,
        ),
      ]);
      
      _summary = results[0] as DashboardSummary;
      _alerts = results[1] as List<SmartAlert>;
      _slowMoving = results[2] as List<SlowMovingProduct>;
      _topProducts = results[3] as List<ProductSales>;
    } on AppException catch (e) {
      // Handle error
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> markAlertRead(String alertId) async {
    await _analyticsRepository.markAlertRead(alertId);
    _alerts = _alerts.map((a) => 
      a.id == alertId ? a.copyWith(isRead: true) : a
    ).toList();
    notifyListeners();
  }
}
```

---

## ✅ قواعد إلزامية

### 1. RTL Support:
```dart
// ✅ صحيح
EdgeInsetsDirectional.only(start: AlhaiSpacing.md)
AlignmentDirectional.centerStart

// ❌ ممنوع
EdgeInsets.only(left: 16)
```

### 2. Spacing/Colors:
```dart
// ✅ صحيح
padding: EdgeInsetsDirectional.all(AlhaiSpacing.md)
color: Theme.of(context).colorScheme.primary

// ❌ ممنوع
padding: EdgeInsets.all(16)
color: Colors.blue
```

### 3. Repository Pattern:
```dart
// ✅ صحيح
final alerts = await _analyticsRepository.getSmartAlerts(storeId);

// ❌ ممنوع
final response = await dio.get('/analytics/alerts');
```

---

## 🧪 Testing Requirements

### قبل كل PR:
```bash
flutter analyze   # 0 issues
flutter test      # All passed
```

---

## 🚀 Quick Start

```bash
# 1. Create project
flutter create pos_app
cd pos_app

# 2. Update pubspec.yaml with dependencies above

# 3. Get dependencies
flutter pub get

# 4. Generate DI
dart run build_runner build

# 5. Run on tablet simulator
flutter run -d [tablet_device_id]
```

---

## 📚 Related Documents

- [DEVELOPER_STANDARDS.md](./DEVELOPER_STANDARDS.md) - معايير المبرمجين
- [STANDARD_APP_PROMPT.md](./STANDARD_APP_PROMPT.md) - Prompt عام
- [DEVELOPMENT_GUIDELINES.md](./DEVELOPMENT_GUIDELINES.md) - إرشادات التطوير
- [alhai_core/DOCUMENTATION.md](./alhai_core/DOCUMENTATION.md) - توثيق Core

---

## 📝 Version History

| Version | Date       | Changes                        |
|---------|------------|--------------------------------|
| 1.0.0   | 2026-01-10 | Initial prompt                 |
| 2.0.0   | 2026-01-10 | Added AI Analytics & Dashboard |
