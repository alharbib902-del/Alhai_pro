# Fix 04 — Error States + Empty States + Loading States
## التاريخ: 2026-03-01
## الحالة: مكتمل

---

## ملخص
- **المشكلة:** 47 شاشة فيها try/catch صامت بدون أي تنبيه للمستخدم
- **الحل:** إضافة `AppErrorState` مع زر إعادة المحاولة + `AppLoadingState` + SnackBar للأخطاء الثانوية
- **الشاشات المعدّلة:** 31 شاشة
- **أخطاء بعد التعديل:** 0 errors, 67 warnings (pre-existing)

---

## Widgets المستخدمة (موجودة مسبقاً في alhai_shared_ui)
- `AppErrorState.general(message:, onRetry:)` — خطأ مع زر إعادة المحاولة
- `AppLoadingState()` — مؤشر تحميل مع رسالة اختيارية
- `AppEmptyState(icon:, title:)` — حالة فراغ

---

## النمط المُطبّق

### لأخطاء تحميل البيانات (Data-loading catches):
```dart
// 1. إضافة متغير الخطأ
String? _error;

// 2. في بداية دالة التحميل
setState(() { _isLoading = true; _error = null; });

// 3. في catch block
catch (e) {
  if (mounted) setState(() { _isLoading = false; _error = '$e'; });
}

// 4. في build method
_isLoading ? const AppLoadingState()
: _error != null ? AppErrorState.general(message: _error, onRetry: _loadMethod)
: ...المحتوى الأصلي...
```

### لأخطاء البحث (Search-only catches):
```dart
catch (e) {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
    );
  }
}
```

### لشاشات Riverpod `.when()`:
```dart
provider.when(
  loading: () => const AppLoadingState(),
  error: (e, _) => AppErrorState.general(
    message: '$e',
    onRetry: () => ref.invalidate(provider),
  ),
  data: (data) => ...content...,
)
```

---

## التغييرات بالتفصيل

### شاشات العملاء (5 شاشات)

| الملف | نوع الإصلاح | التفاصيل |
|-------|-------------|----------|
| `customers/customer_accounts_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` + `AppEmptyState` |
| `customers/customer_ledger_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `customers/create_invoice_screen.dart` | SnackBar (search) | SnackBar في `_searchProducts` و `_searchCustomers` catch blocks |
| `customers/apply_interest_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `customers/new_transaction_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |

### شاشات المبيعات (4 شاشات)

| الملف | نوع الإصلاح | التفاصيل |
|-------|-------------|----------|
| `sales/sales_history_screen.dart` | Error State | `_error` state + `AppErrorState` (kept ShimmerList for loading) |
| `sales/exchange_screen.dart` | SnackBar (search) | SnackBar في `_searchProducts` catch |
| `sales/sale_detail_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `sales/reprint_receipt_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |

### شاشات الدفع (3 شاشات)

| الملف | نوع الإصلاح | التفاصيل |
|-------|-------------|----------|
| `payment/payment_history_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `payment/split_refund_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `payment/split_receipt_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |

### شاشات المخزون (6 شاشات)

| الملف | نوع الإصلاح | التفاصيل |
|-------|-------------|----------|
| `inventory/add_inventory_screen.dart` | SnackBar (search) | SnackBar في `_searchProducts` catch |
| `inventory/edit_inventory_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `inventory/remove_inventory_screen.dart` | SnackBar (search) | SnackBar في `_searchProducts` catch |
| `inventory/stock_take_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `inventory/transfer_inventory_screen.dart` | Error State + Loading + SnackBar | `_error` for `_loadStores` + SnackBar for `_searchProducts` |
| `inventory/wastage_screen.dart` | SnackBar (search) | SnackBar في `_searchProducts` catch |

### شاشات المنتجات (5 شاشات)

| الملف | نوع الإصلاح | التفاصيل |
|-------|-------------|----------|
| `products/edit_price_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `products/price_labels_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `products/quick_add_product_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `products/cashier_categories_screen.dart` | Error State + Loading + SnackBar | `_error` for main load + SnackBar for category products |
| `products/print_barcode_screen.dart` | SnackBar (search) | SnackBar في `_searchProducts` catch |

### شاشات التقارير (2 شاشتين)

| الملف | نوع الإصلاح | التفاصيل |
|-------|-------------|----------|
| `reports/payment_reports_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `reports/custom_report_screen.dart` | SnackBar + Loading | SnackBar for report generation + `AppLoadingState` |

### شاشات الإعدادات (2 شاشتين)

| الملف | نوع الإصلاح | التفاصيل |
|-------|-------------|----------|
| `settings/backup_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `settings/users_permissions_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |

### شاشات الورديات (3 شاشات)

| الملف | نوع الإصلاح | التفاصيل |
|-------|-------------|----------|
| `shifts/shift_close_screen.dart` | Riverpod .when() | `AppLoadingState` + `AppErrorState` with `ref.invalidate` |
| `shifts/cash_in_out_screen.dart` | Riverpod .when() | `AppLoadingState` + `AppErrorState` with `ref.invalidate` |
| `shifts/daily_summary_screen.dart` | Riverpod .when() | `AppLoadingState` + `AppErrorState` with `ref.invalidate` |

### شاشات العروض (2 شاشتين + 1 تخطي)

| الملف | نوع الإصلاح | التفاصيل |
|-------|-------------|----------|
| `offers/active_offers_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `offers/bundle_deals_screen.dart` | Error State + Loading | `_error` state + `AppErrorState` + `AppLoadingState` |
| `offers/coupon_code_screen.dart` | تخطي | لا يوجد تحميل أولي — `_validateCoupon` يعرض خطأ مرئي بالفعل |

---

## شاشات لم تُعدَّل (لا تحتاج إصلاح)

| الملف | السبب |
|-------|-------|
| `settings/cashier_settings_screen.dart` | واجهة ثابتة بدون تحميل بيانات |
| `settings/keyboard_shortcuts_screen.dart` | واجهة ثابتة بدون تحميل بيانات |
| `settings/store_info_screen.dart` | يعرض SnackBar بالفعل |
| `settings/tax_settings_screen.dart` | يعرض SnackBar بالفعل |
| `settings/receipt_settings_screen.dart` | يعرض SnackBar بالفعل |
| `settings/printer_settings_screen.dart` | يعرض SnackBar بالفعل |
| `settings/payment_devices_screen.dart` | يعرض SnackBar بالفعل |
| `settings/add_payment_device_screen.dart` | يعرض SnackBar بالفعل |
| `shifts/shift_open_screen.dart` | يعرض AlertDialog بالفعل |
| `onboarding/onboarding_screen.dart` | واجهة بدون تحميل بيانات |
| `offers/coupon_code_screen.dart` | يعرض validation error بالفعل |
| `purchases/*` | يعرضون SnackBar بالفعل |

---

## الإحصائيات

| المقياس | قبل | بعد |
|---------|------|------|
| شاشات بـ catch صامت | ~25 | 0 |
| شاشات بـ AppErrorState | 0 | 22 |
| شاشات بـ AppLoadingState | 0 | 22 |
| شاشات بـ SnackBar للبحث | 0 | 9 |
| أخطاء تحليل | 0 | 0 |
