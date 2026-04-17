# خطة بناء دورة الشراء الكاملة + بوابة الموزع

## السياق
النظام يحتاج إلى إكمال دورة الشراء من البداية للنهاية:
**الكاشير/الأدمن** ← (طلب شراء ذكي) → **تطبيق الموزع** ← (يضع السعر ويوافق) → **التسليم للمخزن** ← (موافقة + تسجيل المستلم) → **فاتورة تلقائية + تحديث المخزون**

البنية التحتية جاهزة (PurchasesTable, SuppliersTable, PurchasesDao) لكن تنقص:
- 4 شاشات أدمن (قائمة الطلبات، تفاصيل، استلام، إرسال للموزع)
- 2 شاشة كاشير (استلام بضاعة، طلب شراء سريع)
- 8 شاشات + راوتر + شِل لـ distributor_portal (فارغ 100%)

---

## سير العمل (Workflow)
```
status: draft → sent → approved → received → completed

[أدمن] smart_reorder_screen → ينشئ purchase (status=draft)
     ↓ send_to_distributor_screen (status=sent)
[موزع] distributor_orders_screen → يرى الطلب
     ↓ distributor_order_detail_screen → يضع السعر ويوافق (status=approved)
[أدمن] purchase_detail_screen → يرى الموافقة
     ↓ receiving_goods_screen → يستلم البضاعة + يسجل المستلم (status=received)
     ↓ inventoryDao.updateStock تلقائي + fاتورة تُسجل
[كاشير] cashier_receiving_screen → يستلم البضاعة (إذا أُعطي صلاحية)
```

**تخزين البيانات الإضافية بدون تغيير schema:**
- `receivedBy` ← يُحفظ في `notes` JSON: `{"receivedBy":"اسم المستلم",...}`
- `sentAt` ← يُستنتج من `updatedAt` عند تغيير status لـ 'sent'
- `agreedTotal` ← يُحدَّث في `total` عند موافقة الموزع

---

## الملفات الحالية المرتبطة

| الملف | الدور |
|-------|-------|
| `packages/alhai_database/lib/src/tables/purchases_table.dart` | Schema: id, supplierId, status, total, receivedAt, notes... |
| `packages/alhai_database/lib/src/daos/purchases_dao.dart` | getAllPurchases, updateStatus, receivePurchase, getPurchaseItems |
| `apps/admin/lib/providers/purchases_providers.dart` | createPurchase() function + currentStoreIdProvider |
| `apps/admin/lib/screens/purchases/smart_reorder_screen.dart` | الشراء الذكي بالميزانية (موجود) |
| `apps/admin/lib/screens/purchases/purchase_form_screen.dart` | إنشاء فاتورة شراء (موجود) |
| `apps/admin/lib/router/admin_router.dart` | راوتر الأدمن (يحتاج إضافة routes جديدة) |
| `packages/alhai_shared_ui/lib/src/core/router/routes.dart` | ثوابت Routes (يحتاج إضافة) |
| `distributor_portal/lib/core/router/app_router.dart` | فارغ - 7 routes وهمية فقط |
| `distributor_portal/lib/main.dart` | Placeholder |

---

## الشاشات المطلوب بناؤها (15 شاشة + بنية تحتية)

### 1. Admin App (4 شاشات)
| الملف | الوظيفة |
|-------|---------|
| `apps/admin/lib/screens/purchases/purchases_list_screen.dart` | قائمة طلبات الشراء مع فلترة بالحالة |
| `apps/admin/lib/screens/purchases/purchase_detail_screen.dart` | تفاصيل طلب + Timeline الحالة + بنود الطلب |
| `apps/admin/lib/screens/purchases/receiving_goods_screen.dart` | استلام البضاعة + تسجيل المستلم + كميات جزئية |
| `apps/admin/lib/screens/purchases/send_to_distributor_screen.dart` | إرسال الطلب للموزع + اختيار مورد + ملاحظات |

### 2. Cashier App (2 شاشة)
| الملف | الوظيفة |
|-------|---------|
| `apps/cashier/lib/screens/purchases/cashier_receiving_screen.dart` | استلام بضاعة مبسط مع تأكيد المدير |
| `apps/cashier/lib/screens/purchases/cashier_purchase_request_screen.dart` | طلب شراء سريع (يذهب للمدير) |

### 3. Distributor Portal (9 ملفات)
| الملف | الوظيفة |
|-------|---------|
| `distributor_portal/lib/router/distributor_router.dart` | راوتر كامل يستبدل app_router.dart |
| `distributor_portal/lib/ui/distributor_shell.dart` | Shell مع Sidebar navigation |
| `distributor_portal/lib/screens/dashboard/distributor_dashboard_screen.dart` | لوحة: إجمالي الطلبات، المنتظرة، الإيرادات |
| `distributor_portal/lib/screens/orders/distributor_orders_screen.dart` | قائمة طلبات الشراء الواردة مع حالتها |
| `distributor_portal/lib/screens/orders/distributor_order_detail_screen.dart` | تفاصيل طلب + وضع الأسعار + الموافقة/الرفض |
| `distributor_portal/lib/screens/products/distributor_products_screen.dart` | كتالوج المنتجات التي يوزعها |
| `distributor_portal/lib/screens/pricing/distributor_pricing_screen.dart` | قائمة الأسعار وتحديثها |
| `distributor_portal/lib/screens/reports/distributor_reports_screen.dart` | تقارير المبيعات والطلبات |
| `distributor_portal/lib/screens/settings/distributor_settings_screen.dart` | إعدادات الحساب والتنبيهات |

---

## التحديثات على الملفات الموجودة

### routes.dart — إضافات:
```dart
// Purchases (new)
static const String purchasesList = '/purchases';
static const String purchaseDetail = '/purchases/:id';
static String purchaseDetailPath(String id) => '/purchases/$id';
static const String receivingGoods = '/purchases/:id/receive';
static String receivingGoodsPath(String id) => '/purchases/$id/receive';
static const String sendToDistributor = '/purchases/:id/send';
static String sendToDistributorPath(String id) => '/purchases/$id/send';

// Cashier Purchases (new)
static const String cashierReceiving = '/cashier-receiving';
static const String cashierPurchaseRequest = '/purchase-request';

// Distributor Portal Routes (new)
static const String distributorDashboard = '/dashboard';
static const String distributorOrders = '/orders';
static const String distributorOrderDetail = '/orders/:id';
static String distributorOrderDetailPath(String id) => '/orders/$id';
static const String distributorProducts = '/products';
static const String distributorPricing = '/pricing';
static const String distributorReports = '/reports';
static const String distributorSettings = '/settings';
```

### admin_router.dart — إضافات:
```dart
import '../screens/purchases/purchases_list_screen.dart';
import '../screens/purchases/purchase_detail_screen.dart';
import '../screens/purchases/receiving_goods_screen.dart';
import '../screens/purchases/send_to_distributor_screen.dart';

// في GoRoute list:
GoRoute(path: AppRoutes.purchasesList, name: 'purchases-list', builder: ...)
GoRoute(path: AppRoutes.purchaseDetail, name: 'purchase-detail', builder: ...) // :id param
GoRoute(path: AppRoutes.receivingGoods, name: 'receiving-goods', builder: ...) // :id param
GoRoute(path: AppRoutes.sendToDistributor, name: 'send-to-distributor', builder: ...)
```

### admin_shell.dart / dashboard_shell — إضافة:
- nav item: "Purchases List" بجانب smart_reorder وpurchase_form الموجودَين

### cashier_router.dart — إضافات:
```dart
GoRoute(path: AppRoutes.cashierReceiving, name: 'cashier-receiving', ...)
GoRoute(path: AppRoutes.cashierPurchaseRequest, name: 'purchase-request', ...)
```

### cashier_shell.dart — إضافة:
- nav item: "استلام" يربط بـ cashierReceiving

### purchases_providers.dart — إضافات:
```dart
// Provider لقائمة الطلبات
final purchasesListProvider = FutureProvider.family<List<PurchasesTableData>, String>((ref, storeId) async {
  final db = GetIt.I<AppDatabase>();
  return db.purchasesDao.getAllPurchases(storeId);
});

// Provider لتغيير الحالة
Future<void> sendToDistributor(WidgetRef ref, String purchaseId, String supplierName) async { ... }
Future<void> receivePurchaseWithDetails(WidgetRef ref, String purchaseId, String receivedBy) async { ... }
```

### distributor_portal/lib/main.dart — تحديث:
- استخدام distributorRouter بدلاً من app_router وهمي

---

## نمط الشاشات (يجب الالتزام به)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

// ConsumerStatefulWidget + ConsumerState
// AppColors.getTextPrimary(isDark) للألوان
// Responsive: isWide = width > 900, isMedium = width > 600
// AppHeader للعنوان
// GetIt.I<AppDatabase>() لقاعدة البيانات
// currentStoreIdProvider للمتجر الحالي
// Drift Value() wrapper في insert/update
```

---

## التنفيذ بالتوازي (4 وكلاء)

### الوكيل 1 — البنية التحتية (routes + providers + admin_router + cashier_router)
- تحديث `routes.dart` (إضافة route constants جديدة)
- تحديث `purchases_providers.dart` (إضافة providers)
- تحديث `admin_router.dart` (إضافة 4 routes جديدة + imports)
- تحديث `cashier_router.dart` (إضافة 2 routes جديدة)
- تحديث cashier_shell (إضافة nav item)

### الوكيل 2 — شاشات الأدمن (4 شاشات)
- `purchases_list_screen.dart`
- `purchase_detail_screen.dart`
- `receiving_goods_screen.dart`
- `send_to_distributor_screen.dart`

### الوكيل 3 — بوابة الموزع الأساسية (router + shell + dashboard + orders)
- `distributor_router.dart` (راوتر كامل)
- `distributor_shell.dart` (Sidebar: Dashboard, Orders, Products, Pricing, Reports, Settings)
- `distributor_dashboard_screen.dart`
- `distributor_orders_screen.dart`
- تحديث `main.dart` ليستخدم DistributorRouter

### الوكيل 4 — بوابة الموزع الثانوية + شاشتا الكاشير
- `distributor_order_detail_screen.dart` ← الأهم (وضع السعر + الموافقة)
- `distributor_products_screen.dart`
- `distributor_pricing_screen.dart`
- `distributor_reports_screen.dart`
- `distributor_settings_screen.dart`
- `cashier_receiving_screen.dart`
- `cashier_purchase_request_screen.dart`

---

## تفاصيل شاشة الموزع الرئيسية (distributor_order_detail_screen.dart)

```
┌─────────────────────────────────────────────┐
│ طلب شراء #PO-1234567890    [حالة: منتظر]   │
├─────────────────────────────────────────────┤
│ المتجر: متجر الرياض        التاريخ: 22/2/26 │
│ المبلغ المقترح: 15,000 ريال                 │
├─────────────────────────────────────────────┤
│ بنود الطلب:                                 │
│ ┌──────────┬──────┬──────────┬─────────────┐│
│ │ المنتج   │ الكمية│ السعر المقترح│ سعرك   ││
│ ├──────────┼──────┼──────────┼─────────────┤│
│ │ منتج A   │ 50   │ 100 ريال │ [TextField] ││
│ │ منتج B   │ 30   │ 150 ريال │ [TextField] ││
│ └──────────┴──────┴──────────┴─────────────┘│
├─────────────────────────────────────────────┤
│ إجمالي سعرك: 8,500 ريال                     │
│ ملاحظات: [TextField]                        │
├─────────────────────────────────────────────┤
│      [رفض الطلب]    [قبول وإرسال العرض]    │
└─────────────────────────────────────────────┘
```
**عند الموافقة:** يُحدَّث purchase status إلى 'approved' + يُحدَّث total بسعر الموزع + يُرسل إشعار للأدمن

---

## تفاصيل شاشة استلام البضاعة (receiving_goods_screen.dart)

```
┌────────────────────────────────────────────┐
│ استلام البضاعة — PO-1234567890            │
│ الموزع: شركة X    الحالة: تمت الموافقة   │
├────────────────────────────────────────────┤
│ البنود المطلوبة:                           │
│ ┌──────────┬──────────┬─────────────────┐  │
│ │ المنتج   │ مطلوب   │ مستلم فعلي      │  │
│ ├──────────┼──────────┼─────────────────┤  │
│ │ منتج A   │ 50       │ [50] ±          │  │
│ │ منتج B   │ 30       │ [30] ±          │  │
│ └──────────┴──────────┴─────────────────┘  │
├────────────────────────────────────────────┤
│ اسم المستلم: [TextField] (إلزامي)          │
│ ملاحظات الاستلام: [TextField]              │
├────────────────────────────────────────────┤
│           [تأكيد استلام البضاعة]           │
└────────────────────────────────────────────┘
```
**عند التأكيد:**
1. `purchasesDao.updateStatus(id, 'received')`
2. `purchasesDao.receivePurchase(id)` (sets receivedAt)
3. تحديث notes JSON بـ receivedBy
4. لكل بند: `productsDao.updateStock(productId, receivedQty)`
5. `inventoryMovementsDao` تسجيل حركة نوع 'purchase'

---

## التحقق النهائي

```bash
# تحليل كل تطبيق
flutter analyze apps/admin
flutter analyze apps/cashier
flutter analyze distributor_portal

# اختبارات
flutter test apps/admin
flutter test apps/cashier

# عدد الشاشات الجديدة في الأدمن
find apps/admin/lib/screens/purchases -name "*_screen.dart" | wc -l
# يجب: 9 شاشات (5 قديمة + 4 جديدة)

# عدد شاشات الموزع
find distributor_portal/lib/screens -name "*_screen.dart" | wc -l
# يجب: 7 شاشات

# عدد routes في cashier
grep -c "GoRoute" apps/cashier/lib/router/cashier_router.dart
# يجب: 85+ routes
```
