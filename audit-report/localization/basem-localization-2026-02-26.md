# تقرير تدقيق التعريب والترجمة - منصة الحي (Alhai Platform)

**التاريخ:** 2026-02-26
**المدقق:** Basem
**الإصدار:** 1.0
**النطاق:** جميع التطبيقات والحزم المشتركة

---

## ملخص تنفيذي

منصة الحي تدعم 7 لغات (العربية كلغة أساسية، الإنجليزية، الأردية، الهندية، الفلبينية، البنغالية، الإندونيسية) عبر حزمة توطين مركزية (`packages/alhai_l10n/`). البنية التحتية للتوطين قوية ومنظمة بشكل جيد باستخدام نظام ARB القياسي مع ملفات مولّدة تلقائياً. إلا أن هناك **فجوة كبيرة في التغطية** حيث أن 5 من 7 لغات تفتقد **883 مفتاح ترجمة** (30% من إجمالي المفاتيح). كذلك توجد **نصوص مكتوبة يدوياً** (hardcoded strings) في عدد كبير من الشاشات لم يتم ربطها بنظام الترجمة.

### التقييم العام: 5.5 / 10

---

## جدول ملخص بالأرقام

| البند | القيمة |
|-------|--------|
| إجمالي اللغات المدعومة | 7 |
| إجمالي مفاتيح الترجمة (الموحدة) | 2,956 |
| اللغات المكتملة 100% | 2 (العربية، الإنجليزية) |
| اللغات الناقصة | 5 (البنغالية، الفلبينية، الهندية، الإندونيسية، الأردية) |
| عدد المفاتيح المفقودة لكل لغة ناقصة | 883 |
| نسبة التغطية للغات الناقصة | 70% (2,073 من 2,956) |
| إجمالي النصوص المكتوبة يدوياً في التطبيقات | ~444 |
| إجمالي النصوص المكتوبة يدوياً في الحزم | ~291 |
| صيغ الجمع (Plural forms) | 0 |
| صيغ الجنس (Gender forms) | 0 |
| المفاتيح مع معاملات (Parameters) | 245 |
| اختبارات التوطين | 3 ملفات |

---

## جدول عدد المفاتيح لكل لغة

| اللغة | الكود | عدد المفاتيح | عدد الأسطر | المفاتيح المفقودة | نسبة الاكتمال |
|-------|-------|--------------|------------|-------------------|---------------|
| العربية | `ar` | 2,956 | 4,162 | 0 | 100% |
| الإنجليزية | `en` | 2,956 | 3,840 | 0 | 100% |
| البنغالية | `bn` | 2,073 | 2,283 | 883 | 70.1% |
| الفلبينية | `fil` | 2,073 | 2,283 | 883 | 70.1% |
| الهندية | `hi` | 2,073 | 2,283 | 883 | 70.1% |
| الإندونيسية | `id` | 2,073 | 2,361 | 883 | 70.1% |
| الأردية | `ur` | 2,073 | 2,283 | 883 | 70.1% |

---

## ملخص عدد المشاكل حسب التصنيف

| التصنيف | العدد |
|---------|-------|
| :red_circle: حرج | 3 |
| :yellow_circle: متوسط | 8 |
| :green_circle: منخفض | 6 |
| **الإجمالي** | **17** |

---

## النتائج التفصيلية

---

### 1. ملفات ARB وإعدادات التوطين

#### 1.1 إعداد l10n.yaml

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_l10n\l10n.yaml`

```yaml
arb-dir: lib/l10n
template-arb-file: app_ar.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/l10n/generated
```

:green_circle: **منخفض** - الإعداد سليم وجيد. ملف القالب هو العربية (`app_ar.arb`) وهو الأنسب كون العربية اللغة الأساسية. مخرجات الملفات المولّدة في مجلد `generated/`.

**ملاحظة:** لا يوجد إعداد `nullable-getter: false` مما يعني أن `AppLocalizations.of(context)` يرجع قيمة nullable. هذا يؤدي لاستخدام `!` في كل مكان:

```dart
// الاستخدام الحالي في جميع الشاشات:
final l10n = AppLocalizations.of(context)!;
```

#### 1.2 ملفات ARB - البنية

- **موقع الملفات:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_l10n\lib\l10n\`
- **7 ملفات ARB:** `app_ar.arb`, `app_en.arb`, `app_bn.arb`, `app_fil.arb`, `app_hi.arb`, `app_id.arb`, `app_ur.arb`
- **ملف القالب:** `app_ar.arb` (يحتوي على وصف `@` للمفاتيح)

#### 1.3 الملفات المولّدة

**المجلد:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_l10n\lib\l10n\generated\`

- `app_localizations.dart` - الكلاس الأساسي المجرد
- `app_localizations_ar.dart` - التنفيذ العربي
- `app_localizations_en.dart` - التنفيذ الإنجليزي
- `app_localizations_bn.dart` - التنفيذ البنغالي
- `app_localizations_fil.dart` - التنفيذ الفلبيني
- `app_localizations_hi.dart` - التنفيذ الهندي
- `app_localizations_id.dart` - التنفيذ الإندونيسي
- `app_localizations_ur.dart` - التنفيذ الأردي

---

### 2. الترجمات المفقودة

:red_circle: **حرج** - 5 لغات تفتقد 883 مفتاح ترجمة (30% من الإجمالي)

اللغات المتأثرة: **البنغالية، الفلبينية، الهندية، الإندونيسية، الأردية**

**ملاحظة مهمة:** جميع اللغات الخمس تفتقد نفس المفاتيح بالضبط، مما يشير إلى أن هذه المفاتيح أُضيفت للعربية والإنجليزية في تحديث لاحق ولم تُنقل للغات الأخرى.

#### عينة من المفاتيح المفقودة (50 من 883):

| المفتاح | القيمة الإنجليزية |
|---------|-------------------|
| `accept` | Accept |
| `acknowledgeAll` | Acknowledge All |
| `actualCashInDrawer` | Actual Cash in Drawer |
| `addNewProduct` | Add New Product |
| `addToCartAction` | Add to cart |
| `adjustStock` | Adjust Stock |
| `alertSettings` | Alert Settings |
| `allCategories` | All |
| `amountReceived` | Amount Received |
| `averageInvoice` | Average Invoice |
| `backEsc` | Back (Esc) |
| `barcodeLabel` | Barcode |
| `branchFieldLabel` | Branch |
| `bulkEdit` | Bulk Edit |
| `cancelButton` | Cancel |
| `cardPaymentInstructions` | Card Payment Instructions |
| `cashDrawer` | Cash Drawer |
| `categoryManagement` | Category Management |
| `closeShift` | Close Shift |
| `confirmDelete` | Confirm Delete |
| `couponCode` | Coupon Code |
| `createInvoice` | Create Invoice |
| `customerAccounts` | Customer Accounts |
| `dailySummary` | Daily Summary |
| `dateRange` | Date Range |
| `deliveryZone` | Delivery Zone |
| `discountApplied` | Discount Applied |
| `editInventory` | Edit Inventory |
| `exchangeRate` | Exchange Rate |
| `exportReport` | Export Report |
| `filterByDate` | Filter by Date |
| `giftCard` | Gift Card |
| `inventoryAlert` | Inventory Alert |
| `invoiceNumber` | Invoice Number |
| `manualEntry` | Manual Entry |
| `monthlyClose` | Monthly Close |
| `openingBalance` | Opening Balance |
| `paymentHistory` | Payment History |
| `priceLabel` | Price Label |
| `printBarcode` | Print Barcode |
| `purchaseRequest` | Purchase Request |
| `receiptTemplate` | Receipt Template |
| `refundAmount` | Refund Amount |
| `salesHistory` | Sales History |
| `shiftSummary` | Shift Summary |
| `stockTake` | Stock Take |
| `supplierReturn` | Supplier Return |
| `taxSettings` | Tax Settings |
| `wastageReport` | Wastage Report |
| `zatcaCompliance` | ZATCA Compliance |

---

### 3. النصوص المكتوبة يدوياً (Hardcoded Strings)

:red_circle: **حرج** - وجود عدد كبير من النصوص المكتوبة يدوياً في شاشات التطبيقات

#### 3.1 تطبيق الكاشير (apps/cashier)

**عدد النصوص المكتوبة يدوياً في الشاشات:** ~159

| الملف | السطر | النص |
|-------|-------|------|
| `screens/customers/apply_interest_screen.dart` | 202 | `'No outstanding debts'` |
| `screens/customers/apply_interest_screen.dart` | 208 | `'All customer accounts are settled'` |
| `screens/customers/apply_interest_screen.dart` | 603 | `'Apply Interest'` |
| `screens/customers/create_invoice_screen.dart` | 777 | `'Finalize Invoice'` |
| `screens/customers/create_invoice_screen.dart` | 797 | `'Save as Draft'` |
| `screens/customers/customer_accounts_screen.dart` | 312 | `'Customers'` |
| `screens/customers/customer_accounts_screen.dart` | 354 | `'Overdue'` |
| `screens/inventory/add_inventory_screen.dart` | 230 | `'Scan or enter barcode'` |
| `screens/inventory/add_inventory_screen.dart` | 383 | `'Quantity to Add'` |
| `screens/inventory/add_inventory_screen.dart` | 478 | `'Supplier Reference'` |
| `screens/inventory/stock_take_screen.dart` | 185 | `'Total Items'` |
| `screens/inventory/stock_take_screen.dart` | 381 | `'Variance'` |
| `screens/inventory/stock_take_screen.dart` | 436 | `'Save Draft'` |
| `screens/inventory/stock_take_screen.dart` | 454 | `'Finalize'` |
| `screens/inventory/transfer_inventory_screen.dart` | 213 | `'Transfer Details'` |
| `screens/inventory/transfer_inventory_screen.dart` | 220 | `'From Store'` |
| `screens/inventory/transfer_inventory_screen.dart` | 255 | `'To Store'` |
| `screens/inventory/wastage_screen.dart` | 334 | `'Quantity Wasted'` |
| `screens/inventory/wastage_screen.dart` | 582 | `'Record Wastage'` |
| `screens/offers/active_offers_screen.dart` | 241 | `'Auto Applied'` |
| `screens/offers/bundle_deals_screen.dart` | 221 | `'Included Products'` |
| `screens/offers/coupon_code_screen.dart` | 153 | `'Enter Coupon Code'` |
| `screens/payment/payment_history_screen.dart` | 296 | `'Payments'` |
| `screens/payment/split_receipt_screen.dart` | 516 | `'Share'` |
| `screens/payment/split_refund_screen.dart` | 580 | `'Process Refund'` |

**ملفات أخرى تحتوي على نصوص يدوية:** `edit_inventory_screen.dart`, `remove_inventory_screen.dart`, `cashier_categories_screen.dart`, `edit_price_screen.dart`, `print_barcode_screen.dart`, `quick_add_product_screen.dart`, `sale_detail_screen.dart`, `sales_history_screen.dart`, `exchange_screen.dart`, `reprint_receipt_screen.dart`, `cashier_receiving_screen.dart`, `cashier_purchase_request_screen.dart`, `custom_report_screen.dart`, `payment_reports_screen.dart`, وغيرها.

#### 3.2 تطبيق الأدمن (apps/admin)

**عدد النصوص المكتوبة يدوياً في الشاشات:** ~262

| الملف | السطر | النص |
|-------|-------|------|
| `screens/customers/customer_groups_screen.dart` | 165 | `'مجموعات العملاء'` (عربي مكتوب يدوياً) |
| `screens/customers/customer_groups_screen.dart` | 285 | `'دين'` |
| `screens/ecommerce/delivery_zones_screen.dart` | 117 | `'إلغاء'` |
| `screens/ecommerce/delivery_zones_screen.dart` | 192 | `'مناطق التوصيل'` |
| `screens/ecommerce/ecommerce_screen.dart` | 635 | `'Settings saved successfully'` |
| `screens/ecommerce/ecommerce_screen.dart` | 640 | `'Save Settings'` |
| `screens/employees/attendance_screen.dart` | 130 | `'حضور وانصراف الموظفين'` |
| `screens/employees/commission_screen.dart` | 121 | `'عمولات الموظفين'` |
| `screens/employees/employee_profile_screen.dart` | 261 | `'ملف الموظف'` |
| `screens/employees/employee_profile_screen.dart` | 587-589 | `'مدير'`, `'مشرف'`, `'كاشير'` |
| `screens/marketing/gift_cards_screen.dart` | 182 | `'تم إصدار بطاقة هدية بقيمة...'` |
| `screens/management/branch_management_screen.dart` | 109 | `'لا توجد فروع مسجلة'` (Unicode مشفر) |
| `screens/products/price_lists_screen.dart` | 107 | `'السعر الأساسي: ... ر.س'` |
| `screens/subscription/subscription_screen.dart` | 697 | `'سعر الخطة: ... ريال/شهر'` |

**ملاحظة:** في تطبيق الأدمن، بعض النصوص مكتوبة بالعربية يدوياً (ليست عبر l10n) مما يعني أنها ستظهر بالعربية حتى عند اختيار لغة أخرى.

#### 3.3 بوابة الموزع (distributor_portal)

**عدد النصوص المكتوبة يدوياً:** ~23

| الملف | السطر | النص |
|-------|-------|------|
| `screens/orders/distributor_orders_screen.dart` | 218-222 | `'رقم الطلب'`, `'المتجر'`, `'التاريخ'`, `'المبلغ'`, `'الحالة'` |
| `screens/orders/distributor_order_detail_screen.dart` | 423-458 | `'المنتج'`, `'الكمية'`, `'السعر المقترح'`, `'سعرك'`, `'الإجمالي'` |
| `screens/orders/distributor_order_detail_screen.dart` | 1008 | `'رفض الطلب'` |
| `screens/orders/distributor_order_detail_screen.dart` | 1034 | `'قبول وإرسال العرض'` |
| `screens/pricing/distributor_pricing_screen.dart` | 614 | `'حفظ التغييرات'` |
| `screens/products/distributor_products_screen.dart` | 117 | `'إضافة منتج'` |
| `ui/distributor_shell.dart` | 294 | `'بوابة الموزع'` |

#### 3.4 الحزم المشتركة (packages/)

**عدد النصوص المكتوبة يدوياً:** ~291

- `alhai_shared_ui/` شاشات: ~39
- `alhai_pos/` شاشات: ~49
- `alhai_ai/` شاشات: ~17
- `alhai_reports/` شاشات: ~98

#### 3.5 نصوص hintText المكتوبة يدوياً

:yellow_circle: **متوسط** - العديد من حقول الإدخال تحتوي على نصوص تلميح (hintText) مكتوبة يدوياً:

| الملف | السطر | النص |
|-------|-------|------|
| `cashier/screens/inventory/add_inventory_screen.dart` | 486 | `hintText: 'Optional'` |
| `cashier/screens/inventory/add_inventory_screen.dart` | 516 | `hintText: 'Optional note'` |
| `cashier/screens/inventory/transfer_inventory_screen.dart` | 264 | `hintText: 'Select Store'` |
| `admin/screens/devices/device_log_screen.dart` | 267 | `hintText: 'Search logs...'` |
| `admin/screens/media/media_library_screen.dart` | 129 | `hintText: 'Search products...'` |
| `admin/screens/purchases/send_to_distributor_screen.dart` | 525 | `hintText: 'أضف ملاحظات أو رسالة للموزع...'` |

---

### 4. دعم RTL (من اليمين لليسار)

#### 4.1 البنية التحتية لـ RTL

:green_circle: **جيد** - البنية التحتية لدعم RTL مبنية بشكل سليم:

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_l10n\lib\src\locale_provider.dart`

```dart
// السطر 49-55
static const List<String> rtlLanguages = ['ar', 'ur'];

static bool isRtl(Locale locale) {
  return rtlLanguages.contains(locale.languageCode);
}

static TextDirection getTextDirection(Locale locale) {
  return isRtl(locale) ? TextDirection.rtl : TextDirection.ltr;
}
```

- اللغات المعرّفة كـ RTL: العربية (`ar`)، الأردية (`ur`) -- صحيح
- يتم تطبيق `Directionality` في كل تطبيق عبر `MaterialApp.builder`

**مثال من main.dart (الكاشير):**

```dart
// السطر 148-153
builder: (context, child) {
  return Directionality(
    textDirection: localeState.textDirection,
    child: child ?? const SizedBox.shrink(),
  );
},
```

#### 4.2 استخدام EdgeInsets.only مع left/right

:yellow_circle: **متوسط** - وجود 3 حالات استخدام `EdgeInsets.only(left:)` أو `EdgeInsets.only(right:)` في التطبيقات والتي لا تتوافق مع RTL:

| الملف | السطر | الكود |
|-------|-------|-------|
| `admin/screens/marketing/gift_cards_screen.dart` | 307 | `EdgeInsets.only(left: 8)` |
| `admin/screens/settings/whatsapp_management_screen.dart` | 357 | `EdgeInsets.only(right: 8)` |
| `admin/screens/ecommerce/online_orders_screen.dart` | 204 | `EdgeInsets.only(left: 6)` |

**التوصية:** استخدام `EdgeInsetsDirectional.only(start:)` و `EdgeInsetsDirectional.only(end:)` بدلاً من ذلك.

#### 4.3 TextDirection مكتوب يدوياً في حزمة AI

:yellow_circle: **متوسط** - حزمة `alhai_ai` تحتوي على 21 حالة `TextDirection.rtl` مكتوبة يدوياً بدلاً من قراءتها من السياق:

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_ai\lib\src\widgets\ai\market_position_chart.dart`

```dart
// السطور 312, 323, 334, 344, 374, 453, 468
textDirection: TextDirection.rtl,  // مكتوب يدوياً - لن يعمل مع LTR
```

**الملفات المتأثرة:**
- `ai_chat_input.dart` (1 حالة)
- `abc_analysis_chart.dart` (1 حالة)
- `demand_elasticity_chart.dart` (1 حالة)
- `generated_report_view.dart` (1 حالة)
- `market_position_chart.dart` (7 حالات)
- `query_result_view.dart` (4 حالات)
- `roi_forecast_chart.dart` (2 حالات)
- `sentiment_gauge.dart` (1 حالة)
- `shift_optimization_chart.dart` (2 حالات)
- `ai_sentiment_analysis_screen.dart` (1 حالة)

#### 4.4 استخدام EdgeInsets.fromLTRB

:yellow_circle: **متوسط** - وجود استخدامات `EdgeInsets.fromLTRB` و `Alignment.centerLeft/Right` في 107 ملف بإجمالي 516 حالة. هذه الاستخدامات قد تسبب مشاكل عند RTL لأنها لا تنعكس تلقائياً.

**ملاحظة:** بعض هذه الحالات قد تكون مقصودة (مثل padding عام)، لكن الحالات المرتبطة بمحاذاة النص أو الأيقونات تحتاج مراجعة.

---

### 5. تنسيق التاريخ والوقت

:yellow_circle: **متوسط** - وجود حالات DateFormat بدون تمرير locale:

| الملف | السطر | الكود | المشكلة |
|-------|-------|-------|---------|
| `alhai_pos/lib/src/services/receipt_pdf_generator.dart` | 82 | `DateFormat('yyyy/MM/dd HH:mm')` | لا يوجد locale |
| `alhai_shared_ui/lib/src/screens/inventory/expiry_tracking_screen.dart` | 189 | `DateFormat('yyyy/MM/dd')` | لا يوجد locale |
| `distributor_portal/lib/screens/pricing/distributor_pricing_screen.dart` | 186 | `DateFormat('dd/MM').format(...)` | لا يوجد locale |
| `distributor_portal/lib/screens/orders/distributor_order_detail_screen.dart` | 274 | `DateFormat('yyyy/MM/dd - HH:mm').format(...)` | لا يوجد locale |

**الاستخدامات الصحيحة (مع locale):**

| الملف | السطر | الكود |
|-------|-------|-------|
| `admin/screens/purchases/purchase_detail_screen.dart` | 137 | `DateFormat('yyyy/MM/dd - HH:mm', 'ar')` |
| `admin/screens/purchases/purchases_list_screen.dart` | 243 | `DateFormat('yyyy/MM/dd', 'ar')` |
| `alhai_pos/lib/src/screens/pos/pos_screen.dart` | 272 | `DateFormat('d MMMM yyyy', locale)` |
| `alhai_pos/lib/src/services/whatsapp_receipt_service.dart` | 107 | `DateFormat('yyyy/MM/dd - hh:mm a', 'ar')` |

**ملاحظة:** حتى الاستخدامات "الصحيحة" تستخدم `'ar'` مكتوب يدوياً بدلاً من قراءة locale الحالي، مما يعني أنها ستعرض التاريخ بالعربية حتى لو كانت اللغة المختارة الإنجليزية.

---

### 6. تنسيق العملة

:yellow_circle: **متوسط** - استخدام رمز العملة السعودية مكتوب يدوياً في عدة مواضع

#### 6.1 رمز العملة في ARB (صحيح)

```json
// app_ar.arb
"sar": "ر.س",
"currency": "ر.س",
"sarCurrency": "ر.س"
```

#### 6.2 رمز العملة مكتوب يدوياً (مشكلة)

| الملف | السطر | النص |
|-------|-------|------|
| `cashier/widgets/cash/denomination_counter_widget.dart` | 121 | `'${_total.toStringAsFixed(2)} ريال'` |
| `cashier/widgets/cash/denomination_counter_widget.dart` | 222 | `'= ${subtotal.toStringAsFixed(...)} ر.س'` |
| `cashier/widgets/cash/denomination_counter_widget.dart` | 323 | `'تأكيد: ${currentTotal.toStringAsFixed(2)} ر.س'` |
| `admin/screens/ecommerce/delivery_zones_screen.dart` | 84, 96 | `suffixText: 'ر.س'` |
| `admin/screens/inventory/damaged_goods_screen.dart` | 161 | `suffixText: 'ر.س'` |
| `admin/screens/products/price_lists_screen.dart` | 107, 117 | `'السعر الأساسي: ... ر.س'`, `suffixText: 'ر.س'` |
| `admin/screens/subscription/subscription_screen.dart` | 697 | `'سعر الخطة: $price ريال/شهر'` |
| `cashier/widgets/cash/denomination_counter_widget.dart` | 24-30 | `'500 ريال'`, `'100 ريال'`, الخ |

#### 6.3 عدم استخدام NumberFormat للعملة

:yellow_circle: **متوسط** - لا يوجد استخدام `NumberFormat.currency()` أو `NumberFormat.simpleCurrency()` في أي مكان. يتم تنسيق الأرقام باستخدام `toStringAsFixed()` فقط:

```dart
// مثال من shift_close_screen.dart السطر 785
'$prefix${value.toStringAsFixed(0)} $currency'
```

---

### 7. تنسيق الأرقام

:green_circle: **منخفض** - لا يوجد استخدام `NumberFormat` في التطبيقات. يتم استخدام `toStringAsFixed()` في جميع الأماكن. هذا يعني أن الأرقام ستُعرض دائماً بالتنسيق الغربي (1,234.56) بغض النظر عن اللغة المختارة.

---

### 8. جودة عرض النص العربي

:green_circle: **جيد** - خط Tajawal المخصص للعربية مضمّن في المشروع

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_shared_ui\lib\src\core\theme\app_typography.dart`

```dart
// السطر 17-20
static const String fontFamily = 'Tajawal';
static const String fontFamilyNumbers = 'Tajawal';
```

**ملفات الخط المتاحة (في `alhai_design_system/assets/fonts/`):**
- `Tajawal-Black.ttf`
- `Tajawal-ExtraBold.ttf`
- `Tajawal-Bold.ttf`
- `Tajawal-Medium.ttf`
- `Tajawal-Regular.ttf`
- `Tajawal-Light.ttf`
- `Tajawal-ExtraLight.ttf`

**ملاحظة:** خط Tajawal ممتاز للعربية، لكنه **ليس مثالياً** للغات الأخرى مثل البنغالية والهندية التي تحتاج خطوط مخصصة (مثل Noto Sans Bengali, Noto Sans Devanagari). حالياً يتم استخدام نفس الخط لجميع اللغات.

---

### 9. صيغ الجمع والجنس (Plural/Gender Forms)

:red_circle: **حرج** - لا توجد أي صيغ جمع أو جنس في ملفات ARB

- **صيغ الجمع:** 0 مفتاح
- **صيغ الجنس:** 0 مفتاح
- **مفاتيح مع معاملات:** 245 مفتاح

هذا يعني أن جميع النصوص التي تحتاج صيغ جمع تُعامل بشكل واحد:

```json
// app_ar.arb - لا يوجد تفريق بين المفرد والجمع
"pinAttemptsRemaining": "المحاولات المتبقية: {count}",
"otpResendIn": "إعادة الإرسال خلال {seconds} ثانية"
```

**المشكلة في العربية:** العربية لها 6 صيغ جمع (zero, one, two, few, many, other)، وعدم دعمها يؤدي لنصوص غير طبيعية مثل:
- "المحاولات المتبقية: 1" (يجب أن تكون: "محاولة واحدة متبقية")
- "إعادة الإرسال خلال 1 ثانية" (يجب أن تكون: "ثانية واحدة")
- "إعادة الإرسال خلال 2 ثانية" (يجب أن تكون: "ثانيتين")

---

### 10. مزود اللغة (Locale Provider)

:green_circle: **جيد** - تنفيذ منظم وشامل

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_l10n\lib\src\locale_provider.dart`

**المميزات:**
- استخدام Riverpod `StateNotifier<LocaleState>`
- حفظ تفضيل اللغة في `SharedPreferences`
- تحميل اللغة المحفوظة عند بدء التشغيل
- providers متعددة: `localeProvider`, `currentLocaleProvider`, `textDirectionProvider`, `isRtlProvider`
- التحقق من دعم اللغة قبل التطبيق

**مشكلة بسيطة:** خطأ في حفظ locale مع underscore قد يسبب مشكلة:

```dart
// السطر 170
'${locale.languageCode}_${locale.countryCode ?? ''}'
// النتيجة لـ Locale('ar'): 'ar_' (underscore زائد)
```

---

### 11. آلية تبديل اللغة

:green_circle: **جيد** - توجد 3 طرق لتغيير اللغة:

1. **شاشة اللغة الكاملة** (`LanguageScreen`) - في الإعدادات
2. **حوار اختيار اللغة** (`LanguagePickerDialog`) - نافذة منبثقة
3. **زر اللغة المصغر** (`LanguageSelectorButton`) - في Header

**مشكلة:** نص إشعار تغيير اللغة مكتوب بالعربية يدوياً في `LanguagePickerDialog` و `LanguageScreen`:

```dart
// language_screen.dart السطر 121
Text('\u062A\u0645 \u062A\u063A\u064A\u064A\u0631 \u0627\u0644\u0644\u063A\u0629 \u0625\u0644\u0649 $nativeName')
// = "تم تغيير اللغة إلى $nativeName" - مكتوب بالعربية دائماً
```

**مشكلة أخرى:** في `language_selector.dart` السطر 143:

```dart
AppLocalizations.of(context)?.selectLanguage ?? 'Select Language'
// fallback بالإنجليزية
```

وفي السطور 226-244، أوصاف اللغات مكتوبة بالإنجليزية يدوياً:

```dart
case 'ar': return 'Arabic - Saudi Arabia';
case 'en': return 'English - United States';
// ...
```

---

### 12. الحزمة المصدّرة (Export)

:green_circle: **جيد** - حزمة `alhai_l10n` تصدّر الملفات بشكل نظيف:

**الملف:** `C:\Users\basem\OneDrive\Desktop\Alhai\packages\alhai_l10n\lib\alhai_l10n.dart`

```dart
library alhai_l10n;
export 'src/locale_provider.dart';
export 'l10n/generated/app_localizations.dart';
```

---

### 13. تكامل التوطين في التطبيقات

:green_circle: **جيد** - جميع التطبيقات الثلاثة (cashier, admin, admin_lite) تدمج التوطين بنفس النمط في `main.dart`:

```dart
// في كل main.dart
locale: localeState.locale,
supportedLocales: SupportedLocales.all,
localizationsDelegates: const [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
],
builder: (context, child) {
  return Directionality(
    textDirection: localeState.textDirection,
    child: child ?? const SizedBox.shrink(),
  );
},
```

---

### 14. الاختبارات

:green_circle: **منخفض** - توجد 3 ملفات اختبار للتوطين:

| الملف | الوصف | عدد الاختبارات |
|-------|-------|---------------|
| `supported_locales_test.dart` | اختبار اللغات المدعومة والأسماء والأعلام | ~20 |
| `text_direction_test.dart` | اختبار اتجاه النص RTL/LTR | ~8 |
| `locale_provider_test.dart` | اختبار مزود اللغة | غير محدد |

**المفقود:**
- لا توجد اختبارات للتحقق من اكتمال الترجمات
- لا توجد اختبارات لعرض الشاشات بلغات مختلفة
- لا توجد اختبارات golden/snapshot للتحقق من RTL

---

### 15. دعم الخطوط لجميع اللغات

:yellow_circle: **متوسط** - خط Tajawal يدعم العربية بشكل ممتاز لكن:

| اللغة | الخط المستخدم | مناسب؟ |
|-------|--------------|--------|
| العربية | Tajawal | ممتاز |
| الأردية | Tajawal | جيد (مشترك مع العربية) |
| الإنجليزية | Tajawal | مقبول |
| الهندية | Tajawal | غير مثالي - يحتاج Noto Sans Devanagari |
| البنغالية | Tajawal | غير مثالي - يحتاج Noto Sans Bengali |
| الفلبينية | Tajawal | مقبول (حروف لاتينية) |
| الإندونيسية | Tajawal | مقبول (حروف لاتينية) |

---

### 16. نصوص إشعارات الأخطاء (SnackBar)

:yellow_circle: **متوسط** - العديد من رسائل الخطأ في SnackBar مكتوبة يدوياً:

| الملف | السطر | النص |
|-------|-------|------|
| `admin/screens/ecommerce/ecommerce_screen.dart` | 108 | `'Error updating setting: $e'` |
| `admin/screens/ecommerce/ecommerce_screen.dart` | 135 | `'Error saving setting: $e'` |
| `admin/screens/categories_screen.dart` | 207 | `'Error: $e'` |
| `admin/screens/employees/employee_profile_screen.dart` | 226 | `'خطأ: $e'` |
| `admin/screens/inventory/damaged_goods_screen.dart` | 235 | `'خطأ: $e'` |
| `cashier/screens/customers/customer_ledger_screen.dart` | 1020 | `'Error: $e'` |

---

## قائمة المفاتيح المفقودة لكل لغة

### البنغالية / الفلبينية / الهندية / الإندونيسية / الأردية (883 مفتاح مشترك)

جميع اللغات الخمس تفتقد نفس المجموعة من 883 مفتاح. فيما يلي تصنيف المفاتيح المفقودة حسب الفئة:

#### فئة إدارة المخزون (~80 مفتاح)
`adjustStock`, `adjustmentHistory`, `adjustmentSavedSuccess`, `adjustmentSummary`, `addExpiryDate`, `addBarcodeFirst`, `barcodeLabel`, `barcodeOrProductName`, `barcodePrint`, `barcodeScanner2`, `batch`, `batchNumberOptional`, `editInventory`, `inventoryAlert`, `stockTake`, `transferDetails`, `wastageReport`, وغيرها...

#### فئة نقطة البيع (~60 مفتاح)
`addToCartAction`, `addedProductToCart`, `addedToCart`, `amountReceived`, `backEsc`, `cancelButton`, `cancelLabel`, `cashDrawer`, `closeShift`, `confirmDelete`, `createInvoice`, `dailySummary`, `holdInvoice`, `paymentHistory`, `quickSale`, `receiptTemplate`, `splitPayment`, وغيرها...

#### فئة العملاء والحسابات (~50 مفتاح)
`activeCustomersInfo`, `activeCustomersLabel`, `activeCustomersLast30`, `addCustomersToStart`, `customerAccounts`, `customerAnalytics`, `customerDebt`, `customerLedger`, `monthlyClose`, `outstandingDebt`, وغيرها...

#### فئة التقارير والإحصائيات (~70 مفتاح)
`activityHeatmap`, `activitySummary`, `analysis`, `analysisRecommendations`, `averageInvoice`, `avgOrderPerCustomer`, `avgOrderValueLabel`, `customReport`, `dateRange`, `exportReport`, `filterByDate`, `peakHours`, `profitReport`, `salesHistory`, `taxReport`, `topProducts`, وغيرها...

#### فئة الإعدادات (~40 مفتاح)
`alertSettings`, `activateShippingGateways`, `barcodePrint`, `deliveryZone`, `giftCard`, `printerSettings`, `receiptTemplate`, `securitySettings`, `taxSettings`, `zatcaCompliance`, وغيرها...

#### فئة العروض والتسويق (~30 مفتاح)
`actionDiscount`, `actionDonate`, `couponCode`, `discountApplied`, `giftCard`, `loyaltyPoints`, `specialOffers`, وغيرها...

#### فئة الوقت والتواريخ (~30 مفتاح)
`aprilMonth`, `wedShort`, `wednesdayDay`, `yesterdayDate`, `withinDays`, `withinMonth`, وغيرها...

#### فئة أخرى (~523 مفتاح)
بقية المفاتيح تغطي: المشتريات، الموردين، الموظفين، الفروع، المحفظة، الاشتراكات، التجارة الإلكترونية، وغيرها.

---

## التوصيات مع أولوية التنفيذ

### أولوية 1 - حرجة (يجب التنفيذ فوراً)

| # | التوصية | الجهد المقدر |
|---|---------|-------------|
| 1 | **ترجمة 883 مفتاح مفقود** للغات الخمس (bn, fil, hi, id, ur). يمكن استخدام أدوات ترجمة آلية كنقطة بداية ثم مراجعة يدوية | 3-5 أيام |
| 2 | **نقل النصوص المكتوبة يدوياً** (~735 نص) من شاشات التطبيقات والحزم إلى ملفات ARB | 5-7 أيام |
| 3 | **إضافة صيغ الجمع** للعربية على الأقل (المفاتيح التي تحتوي على أعداد مثل `pinAttemptsRemaining`, `otpResendIn`, وغيرها) | 2-3 أيام |

### أولوية 2 - متوسطة (خلال 2-4 أسابيع)

| # | التوصية | الجهد المقدر |
|---|---------|-------------|
| 4 | **إصلاح TextDirection المكتوب يدوياً** في حزمة alhai_ai (21 حالة) ليقرأ من السياق | 1 يوم |
| 5 | **إصلاح DateFormat** لتمرير locale الحالي بدلاً من 'ar' المكتوب يدوياً | 0.5 يوم |
| 6 | **استبدال EdgeInsets.only(left/right)** بـ EdgeInsetsDirectional | 0.5 يوم |
| 7 | **إضافة NumberFormat** لتنسيق العملة والأرقام حسب اللغة | 2 أيام |
| 8 | **إضافة nullable-getter: false** في l10n.yaml لتجنب استخدام `!` | 0.5 يوم |
| 9 | **إصلاح حفظ locale** مع underscore الزائد في locale_provider.dart | 0.5 يوم |
| 10 | **إضافة خطوط مخصصة** للهندية (Noto Sans Devanagari) والبنغالية (Noto Sans Bengali) | 1 يوم |

### أولوية 3 - منخفضة (خلال 1-3 أشهر)

| # | التوصية | الجهد المقدر |
|---|---------|-------------|
| 11 | **إضافة اختبارات اكتمال الترجمة** (اختبار تلقائي يتحقق من تطابق المفاتيح) | 1 يوم |
| 12 | **إضافة اختبارات RTL golden** للتحقق البصري من تخطيط الشاشات | 3 أيام |
| 13 | **ترجمة أوصاف اللغات** في language_selector.dart من الإنجليزية | 0.5 يوم |
| 14 | **مراجعة 516 حالة EdgeInsets/Alignment** للتأكد من توافقها مع RTL | 2-3 أيام |
| 15 | **إضافة lint rule** لمنع النصوص المكتوبة يدوياً في Widget Tree | 1 يوم |
| 16 | **إضافة CI check** للتحقق من تطابق مفاتيح ARB في جميع اللغات | 0.5 يوم |

---

## ملاحظات إضافية

1. **البنية التحتية ممتازة:** حزمة `alhai_l10n` المركزية مع Riverpod providers هي حل عصري ونظيف. المشكلة ليست في الهيكلة بل في عدم اكتمال التغطية.

2. **نمط مزدوج في الأدمن:** بعض شاشات الأدمن تستخدم نصوص عربية مكتوبة يدوياً وبعضها يستخدم إنجليزية مكتوبة يدوياً، مما يشير إلى عدم اتساق بين المطورين.

3. **بوابة الموزع شبه معزولة:** جميع النصوص مكتوبة بالعربية يدوياً ولا تستخدم نظام الترجمة إطلاقاً.

4. **خط Tajawal اختيار ذكي:** يدعم العربية واللاتينية بشكل جيد، لكنه لا يغطي البنغالية والهندية بشكل كامل.

5. **اللغة القالب (template-arb-file):** كون العربية هي ملف القالب يعني أن الوصف `@description` موجود فقط في ملف العربية، وهذا صحيح تقنياً لكن قد يصعّب على المترجمين فهم السياق.

---

## التقييم النهائي

| المعيار | الدرجة (من 10) | ملاحظات |
|---------|---------------|---------|
| بنية ملفات التوطين | 9/10 | حزمة مركزية نظيفة |
| اكتمال الترجمة (ar/en) | 10/10 | كاملة |
| اكتمال الترجمة (5 لغات أخرى) | 4/10 | 30% مفقود |
| دعم RTL | 7/10 | بنية جيدة مع بعض المشاكل |
| تنسيق التاريخ/الوقت | 5/10 | حالات بدون locale |
| تنسيق العملة/الأرقام | 3/10 | لا يوجد NumberFormat |
| صيغ الجمع/الجنس | 1/10 | غير موجودة |
| خطوط متعددة اللغات | 6/10 | Tajawal جيد للعربية فقط |
| نصوص مكتوبة يدوياً | 3/10 | ~735 نص بحاجة للنقل |
| آلية تبديل اللغة | 8/10 | منظمة مع 3 طرق |
| الاختبارات | 5/10 | أساسية فقط |
| **المعدل العام** | **5.5/10** | |

---

*تم إنشاء هذا التقرير تلقائياً بتاريخ 2026-02-26*
