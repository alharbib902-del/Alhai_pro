# تقرير التوافق بين الشاشات وقاعدة البيانات - تطبيق الحي POS

## نظرة عامة

| العنصر | العدد |
|--------|-------|
| عدد الشاشات الكلي | 110+ شاشة |
| عدد جداول قاعدة البيانات | 14 جدول |
| عدد DAOs | 11 DAO |
| عدد المستودعات (Repositories) | 2 |
| إصدار قاعدة البيانات | v7 |

---

## الحالة العامة

### الجداول الموجودة حالياً
| # | الجدول | الوصف |
|---|--------|-------|
| 1 | `products` | المنتجات |
| 2 | `categories` | التصنيفات |
| 3 | `sales` | المبيعات |
| 4 | `sale_items` | عناصر المبيعات |
| 5 | `orders` | الطلبات |
| 6 | `order_items` | عناصر الطلبات |
| 7 | `accounts` | حسابات العملاء والموردين |
| 8 | `transactions` | المعاملات المالية |
| 9 | `inventory_movements` | حركات المخزون |
| 10 | `sync_queue` | طابور المزامنة |
| 11 | `audit_log` | سجل المراجعة |
| 12 | `loyalty_points` | نقاط الولاء |
| 13 | `loyalty_transactions` | معاملات الولاء |
| 14 | `loyalty_rewards` | مكافآت الولاء |

---

## تحليل التوافق لكل قسم

---

### 1. قسم نقطة البيع (POS)
**الشاشات:** `pos_screen` | `payment_screen` | `receipt_screen` | `hold_invoices_screen` | `favorites_screen` | `quick_sale_screen`

| الحالة | التفاصيل |
|--------|---------|
| ✅ مكتمل | عرض المنتجات، السلة، البحث، الباركود |
| ✅ مكتمل | الدفع (نقدي/بطاقة/مختلط/آجل) |
| ✅ مكتمل | إنشاء فاتورة وحفظها في `sales` + `sale_items` |
| ⚠️ جزئي | الفواتير المعلقة تعمل بالذاكرة فقط (غير محفوظة في DB) |
| ❌ مفقود | جدول `favorites` غير موجود - المفضلة غير محفوظة |
| ❌ مفقود | جدول `held_invoices` غير موجود - الفواتير المعلقة تضيع عند إعادة التشغيل |

**الجداول المستخدمة:** `products`, `categories`, `sales`, `sale_items`, `accounts`, `transactions`, `inventory_movements`

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `favorites` | id, storeId, productId, sortOrder, createdAt | حفظ المنتجات المفضلة |
| `held_invoices` | id, storeId, cashierId, customerName, items (JSON), total, notes, createdAt | حفظ الفواتير المعلقة |

---

### 2. قسم المنتجات والتصنيفات
**الشاشات:** `products_screen` | `product_form_screen` | `product_detail_screen` | `categories_screen` | `product_categories_screen`

| الحالة | التفاصيل |
|--------|---------|
| ✅ مكتمل | CRUD كامل للمنتجات |
| ✅ مكتمل | CRUD كامل للتصنيفات |
| ✅ مكتمل | البحث النصي الكامل (FTS5) |
| ✅ مكتمل | الباركود و SKU |
| ⚠️ جزئي | لا يوجد جدول `product_images` منفصل - الصور محفوظة كأعمدة نص |
| ❌ مفقود | لا يوجد جدول `product_variants` (المتغيرات: مقاسات، ألوان) |
| ❌ مفقود | لا يوجد جدول `product_bundles` (الحزم/العروض المجمعة) |

**الجداول المستخدمة:** `products`, `categories`

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `product_variants` | id, productId, name, sku, barcode, price, costPrice, stockQty, attributes (JSON) | دعم متغيرات المنتج |
| `product_bundles` | id, storeId, name, products (JSON), bundlePrice, isActive | عروض الحزم المجمعة |

---

### 3. قسم العملاء والديون
**الشاشات:** `customers_screen` | `customer_detail_screen` | `customer_debt_screen` | `customer_ledger_screen` | `customer_analytics_screen`

| الحالة | التفاصيل |
|--------|---------|
| ✅ مكتمل | إدارة حسابات العملاء في `accounts` |
| ✅ مكتمل | المعاملات المالية في `transactions` |
| ✅ مكتمل | حساب الأرصدة والديون |
| ⚠️ جزئي | `customer_analytics_screen` يستخدم بيانات وهمية (dummy data) |
| ❌ مفقود | لا يوجد جدول `customers` منفصل (العملاء مخزنين في `accounts`) |
| ❌ مفقود | لا يوجد جدول `customer_addresses` |
| ❌ مفقود | لا يوجد جدول `customer_notes` |

**الجداول المستخدمة:** `accounts`, `transactions`, `sales`

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `customers` | id, storeId, name, phone, email, address, city, taxNumber, type, notes, isActive, createdAt | فصل بيانات العملاء عن الحسابات |
| `customer_addresses` | id, customerId, label, address, city, lat, lng, isDefault | عناوين التوصيل المتعددة |

---

### 4. قسم المخزون
**الشاشات:** `inventory_screen` | `inventory_adjust_screen` | `stock_transfer_screen` | `stock_take_screen` | `barcode_scanner_screen` | `barcode_print_screen` | `inventory_alerts_screen` | `expiry_tracking_screen`

| الحالة | التفاصيل |
|--------|---------|
| ✅ مكتمل | حركات المخزون في `inventory_movements` |
| ✅ مكتمل | تعديل الكميات وتسجيل الحركات |
| ⚠️ جزئي | `stock_transfer_screen` يستخدم بيانات وهمية - لا يوجد جدول تحويلات |
| ⚠️ جزئي | `stock_take_screen` يستخدم بيانات وهمية - لا يوجد جدول جرد |
| ❌ مفقود | لا يوجد جدول `stock_transfers` (التحويلات بين الفروع) |
| ❌ مفقود | لا يوجد جدول `stock_takes` (عمليات الجرد) |
| ❌ مفقود | لا يوجد جدول `product_expiry` (تواريخ الصلاحية) |
| ❌ مفقود | لا يوجد جدول `inventory_alerts` (تنبيهات المخزون) |

**الجداول المستخدمة:** `products`, `inventory_movements`

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `stock_transfers` | id, fromStoreId, toStoreId, status, items (JSON), notes, createdBy, createdAt, completedAt | تحويلات المخزون بين الفروع |
| `stock_takes` | id, storeId, status, items (JSON), variance, notes, createdBy, startedAt, completedAt | عمليات الجرد الفعلي |
| `product_expiry` | id, productId, storeId, batchNumber, expiryDate, quantity, createdAt | تتبع تواريخ الصلاحية |

---

### 5. قسم الفواتير والمبيعات
**الشاشات:** `invoices_screen` | `invoice_detail_screen`

| الحالة | التفاصيل |
|--------|---------|
| ✅ مكتمل | عرض الفواتير من `sales` + `sale_items` |
| ✅ مكتمل | تفاصيل الفاتورة كاملة |
| ✅ مكتمل | إلغاء الفاتورة (void) |
| ⚠️ جزئي | لا يوجد دعم للفاتورة الضريبية المبسطة (ZATCA) في DB |

**الجداول المستخدمة:** `sales`, `sale_items`, `accounts`

---

### 6. قسم الطلبات (Online Orders)
**الشاشات:** `orders_screen` | `order_history_screen` | `order_tracking_screen`

| الحالة | التفاصيل |
|--------|---------|
| ✅ مكتمل | جدول `orders` + `order_items` موجود |
| ✅ مكتمل | تتبع حالة الطلب (pending → confirmed → preparing → ready → delivering → delivered) |
| ⚠️ جزئي | `order_history_screen` يستخدم بيانات وهمية |
| ⚠️ جزئي | `order_tracking_screen` يستخدم بيانات وهمية |
| ❌ مفقود | لا يوجد جدول `order_status_history` (سجل تغييرات الحالة) |

**الجداول المستخدمة:** `orders`, `order_items`

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `order_status_history` | id, orderId, fromStatus, toStatus, changedBy, notes, createdAt | تتبع تاريخ تغييرات حالة الطلب |

---

### 7. قسم المرتجعات
**الشاشات:** `returns_screen` | `refund_request_screen` | `refund_reason_screen` | `refund_receipt_screen` | `void_transaction_screen`

| الحالة | التفاصيل |
|--------|---------|
| ⚠️ جزئي | الإلغاء يتم عبر تحديث حالة البيع في `sales` |
| ❌ مفقود | لا يوجد جدول `returns` (المرتجعات) |
| ❌ مفقود | لا يوجد جدول `return_items` (عناصر المرتجعات) |
| ❌ مفقود | لا يوجد جدول `return_reasons` (أسباب الإرجاع) |
| ❌ مفقود | جميع شاشات المرتجعات تستخدم بيانات وهمية |

**الجداول المستخدمة:** `sales` (فقط لتحديث الحالة)

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `returns` | id, saleId, storeId, customerId, reason, type (full/partial), refundMethod, totalRefund, status, createdBy, createdAt | تسجيل عمليات الإرجاع |
| `return_items` | id, returnId, saleItemId, productId, productName, qty, unitPrice, refundAmount | عناصر المرتجعات |

---

### 8. قسم الموردين والمشتريات
**الشاشات:** `suppliers_screen` | `supplier_form_screen` | `supplier_detail_screen` | `purchase_form_screen` | `smart_reorder_screen` | `ai_invoice_import_screen` | `ai_invoice_review_screen`

| الحالة | التفاصيل |
|--------|---------|
| ⚠️ جزئي | الموردون مخزنون في `accounts` (type = 'supplier') |
| ❌ مفقود | لا يوجد جدول `suppliers` منفصل |
| ❌ مفقود | لا يوجد جدول `purchases` (أوامر الشراء) |
| ❌ مفقود | لا يوجد جدول `purchase_items` (عناصر الشراء) |
| ❌ مفقود | جميع شاشات المشتريات تستخدم بيانات وهمية |

**الجداول المستخدمة:** `accounts`

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `suppliers` | id, storeId, name, phone, email, address, taxNumber, paymentTerms, rating, balance, isActive, createdAt | بيانات الموردين المفصلة |
| `purchases` | id, storeId, supplierId, purchaseNumber, status, subtotal, tax, total, paymentStatus, notes, receivedAt, createdAt | أوامر الشراء |
| `purchase_items` | id, purchaseId, productId, productName, qty, unitCost, total | عناصر الشراء |

---

### 9. قسم المصروفات
**الشاشات:** `expenses_screen` | `expense_categories_screen`

| الحالة | التفاصيل |
|--------|---------|
| ❌ مفقود | لا يوجد جدول `expenses` (المصروفات) |
| ❌ مفقود | لا يوجد جدول `expense_categories` (فئات المصروفات) |
| ❌ مفقود | الشاشات تستخدم بيانات وهمية بالكامل |

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `expenses` | id, storeId, categoryId, amount, description, paymentMethod, receiptImage, createdBy, createdAt, syncedAt | تسجيل المصروفات |
| `expense_categories` | id, storeId, name, icon, color, isActive, createdAt | فئات المصروفات |

---

### 10. قسم التقارير
**الشاشات:** `reports_screen` | `daily_sales_report_screen` | `sales_analytics_screen` | `customer_report_screen` | `inventory_report_screen` | `debts_report_screen` | `tax_report_screen` | `vat_report_screen` | `profit_report_screen` | `top_products_report_screen` | `peak_hours_report_screen` | `staff_performance_screen`

| الحالة | التفاصيل |
|--------|---------|
| ✅ مكتمل | تقرير المبيعات اليومي يعمل من `sales` |
| ⚠️ جزئي | تقرير الديون يعمل جزئياً من `accounts` + `transactions` |
| ❌ مفقود | 8 من 12 تقرير تستخدم بيانات وهمية |
| ❌ مفقود | لا توجد جداول تقارير مجمعة (aggregated) |

**الجداول المستخدمة:** `sales`, `sale_items`, `products`, `accounts`, `transactions`

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `daily_summaries` | id, storeId, date, totalSales, totalOrders, totalRefunds, totalExpenses, netProfit, cashTotal, cardTotal, creditTotal | ملخصات يومية لتسريع التقارير |

---

### 11. قسم الورديات والصندوق
**الشاشات:** `shifts_screen` | `shift_open_screen` | `shift_close_screen` | `shift_summary_screen` | `cash_drawer_screen`

| الحالة | التفاصيل |
|--------|---------|
| ❌ مفقود | لا يوجد جدول `shifts` (الورديات) |
| ❌ مفقود | لا يوجد جدول `cash_movements` (حركات الصندوق) |
| ❌ مفقود | جميع الشاشات تستخدم بيانات وهمية |

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `shifts` | id, storeId, cashierId, cashierName, openingCash, closingCash, expectedCash, difference, status, openedAt, closedAt | إدارة الورديات |
| `cash_movements` | id, shiftId, storeId, type (in/out), amount, reason, reference, createdBy, createdAt | حركات الصندوق |

---

### 12. قسم التسويق والخصومات
**الشاشات:** `discounts_screen` | `coupon_management_screen` | `special_offers_screen` | `smart_promotions_screen`

| الحالة | التفاصيل |
|--------|---------|
| ❌ مفقود | لا يوجد جدول `discounts` (الخصومات) |
| ❌ مفقود | لا يوجد جدول `coupons` (الكوبونات) |
| ❌ مفقود | لا يوجد جدول `promotions` (العروض الترويجية) |
| ❌ مفقود | جميع الشاشات تستخدم بيانات وهمية |

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `discounts` | id, storeId, name, type (percentage/fixed), value, minPurchase, startDate, endDate, isActive, createdAt | الخصومات |
| `coupons` | id, storeId, code, discountId, maxUses, currentUses, expiresAt, isActive, createdAt | الكوبونات |
| `promotions` | id, storeId, name, type, rules (JSON), startDate, endDate, isActive, createdAt | العروض الترويجية |

---

### 13. قسم الولاء
**الشاشات:** `loyalty_program_screen`

| الحالة | التفاصيل |
|--------|---------|
| ✅ مكتمل | جداول الولاء الثلاثة موجودة |
| ✅ مكتمل | `LoyaltyDao` يدعم كل العمليات |
| ⚠️ جزئي | الشاشة لا تستخدم الـ DAO مباشرة بعد |

**الجداول المستخدمة:** `loyalty_points`, `loyalty_transactions`, `loyalty_rewards`

---

### 14. قسم المزامنة
**الشاشات:** `sync_status_screen` | `pending_transactions_screen` | `conflict_resolution_screen`

| الحالة | التفاصيل |
|--------|---------|
| ✅ مكتمل | جدول `sync_queue` يعمل بشكل كامل |
| ✅ مكتمل | `SyncQueueDao` يدعم كل العمليات |
| ⚠️ جزئي | `conflict_resolution_screen` يستخدم بيانات وهمية |

**الجداول المستخدمة:** `sync_queue`

---

### 15. قسم الإشعارات
**الشاشات:** `notifications_screen` | `notifications_settings_screen`

| الحالة | التفاصيل |
|--------|---------|
| ❌ مفقود | لا يوجد جدول `notifications` |
| ❌ مفقود | الإشعارات تعمل بالذاكرة فقط |

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `notifications` | id, storeId, userId, title, body, type, isRead, data (JSON), createdAt | حفظ الإشعارات |

---

### 16. قسم الإعدادات
**الشاشات:** 20+ شاشة إعدادات

| الحالة | التفاصيل |
|--------|---------|
| ⚠️ جزئي | معظم الإعدادات تستخدم `SharedPreferences` |
| ❌ مفقود | لا يوجد جدول `settings` موحد |
| ❌ مفقود | لا يوجد جدول `stores` (بيانات المتجر) |
| ❌ مفقود | لا يوجد جدول `users` (المستخدمين) |
| ❌ مفقود | لا يوجد جدول `roles` (الأدوار والصلاحيات) |

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `stores` | id, name, nameEn, phone, email, address, city, logo, taxNumber, commercialReg, currency, timezone, isActive | بيانات المتجر/الفرع |
| `users` | id, storeId, name, phone, email, pin, role, isActive, lastLoginAt, createdAt | المستخدمين والكاشير |
| `roles` | id, storeId, name, permissions (JSON), createdAt | الأدوار والصلاحيات |
| `settings` | id, storeId, key, value, updatedAt | إعدادات المتجر |

---

### 17. قسم السائقين والفروع
**الشاشات:** `driver_management_screen` | `branch_management_screen`

| الحالة | التفاصيل |
|--------|---------|
| ❌ مفقود | لا يوجد جدول `drivers` (السائقين) |
| ❌ مفقود | بيانات الفروع غير منفصلة |

**الجداول المقترح إضافتها:**
| الجدول | الأعمدة | السبب |
|--------|---------|-------|
| `drivers` | id, storeId, name, phone, vehicleType, vehiclePlate, isActive, createdAt | بيانات السائقين |

---

## ملخص الحالة الكلية

### إحصائيات التوافق
| الحالة | العدد | النسبة |
|--------|-------|--------|
| ✅ شاشات مكتملة ومتصلة بالـ DB | ~25 شاشة | 23% |
| ⚠️ شاشات تعمل جزئياً | ~20 شاشة | 18% |
| ❌ شاشات بدون جداول (بيانات وهمية) | ~65 شاشة | 59% |

### الجداول المقترح إضافتها (الأولوية)

#### أولوية عالية (مطلوبة فوراً) 🔴
| # | الجدول | القسم |
|---|--------|-------|
| 1 | `shifts` + `cash_movements` | الورديات والصندوق |
| 2 | `returns` + `return_items` | المرتجعات |
| 3 | `expenses` + `expense_categories` | المصروفات |
| 4 | `customers` | العملاء (فصل عن accounts) |
| 5 | `suppliers` | الموردين (فصل عن accounts) |
| 6 | `stores` | بيانات المتجر |
| 7 | `users` + `roles` | المستخدمين والصلاحيات |

#### أولوية متوسطة 🟡
| # | الجدول | القسم |
|---|--------|-------|
| 8 | `purchases` + `purchase_items` | المشتريات |
| 9 | `discounts` + `coupons` | التسويق |
| 10 | `held_invoices` | الفواتير المعلقة |
| 11 | `notifications` | الإشعارات |
| 12 | `stock_transfers` | تحويلات المخزون |
| 13 | `settings` | الإعدادات |

#### أولوية منخفضة 🟢
| # | الجدول | القسم |
|---|--------|-------|
| 14 | `stock_takes` | الجرد |
| 15 | `product_expiry` | تواريخ الصلاحية |
| 16 | `product_variants` | متغيرات المنتج |
| 17 | `promotions` | العروض الترويجية |
| 18 | `drivers` | السائقين |
| 19 | `daily_summaries` | ملخصات التقارير |
| 20 | `order_status_history` | سجل حالات الطلبات |
| 21 | `favorites` | المنتجات المفضلة |
| 22 | `customer_addresses` | عناوين العملاء |

---

## توزيع العمل على الوكلاء (Agents)

### الوكيل 1: قاعدة البيانات الأساسية (DB Core Agent)
**المهمة:** إنشاء الجداول والـ DAOs والمهاجرات (Migrations)

| الخطوة | المهمة | الملفات |
|--------|--------|---------|
| 1.1 | إنشاء `StoresTable` + `StoresDao` | `tables/stores_table.dart`, `daos/stores_dao.dart` |
| 1.2 | إنشاء `UsersTable` + `RolesTable` + `UsersDao` | `tables/users_table.dart`, `tables/roles_table.dart`, `daos/users_dao.dart` |
| 1.3 | إنشاء `CustomersTable` + `SuppliersTable` | `tables/customers_table.dart`, `tables/suppliers_table.dart` |
| 1.4 | إنشاء `ShiftsTable` + `CashMovementsTable` + `ShiftsDao` | `tables/shifts_table.dart`, `daos/shifts_dao.dart` |
| 1.5 | إنشاء `ReturnsTable` + `ReturnItemsTable` + `ReturnsDao` | `tables/returns_table.dart`, `daos/returns_dao.dart` |
| 1.6 | إنشاء `ExpensesTable` + `ExpenseCategoriesTable` + `ExpensesDao` | `tables/expenses_table.dart`, `daos/expenses_dao.dart` |
| 1.7 | تحديث `AppDatabase` وإضافة المهاجرة v7 → v8 | `app_database.dart` |
| 1.8 | تشغيل `build_runner` لتوليد الكود | أمر: `dart run build_runner build` |

**المدة المقدرة:** مهمة كبيرة

---

### الوكيل 2: الورديات والصندوق (Shifts Agent)
**المهمة:** ربط شاشات الورديات والصندوق بقاعدة البيانات

| الخطوة | المهمة | الملفات |
|--------|--------|---------|
| 2.1 | إنشاء `ShiftsProvider` | `providers/shifts_provider.dart` |
| 2.2 | ربط `shift_open_screen` بالـ DB | `screens/shifts/shift_open_screen.dart` |
| 2.3 | ربط `shift_close_screen` بالـ DB | `screens/shifts/shift_close_screen.dart` |
| 2.4 | ربط `shifts_screen` بالـ DB | `screens/shifts/shifts_screen.dart` |
| 2.5 | ربط `shift_summary_screen` بالـ DB | `screens/shifts/shift_summary_screen.dart` |
| 2.6 | ربط `cash_drawer_screen` بالـ DB | `screens/cash/cash_drawer_screen.dart` |

---

### الوكيل 3: المرتجعات (Returns Agent)
**المهمة:** ربط شاشات المرتجعات بقاعدة البيانات

| الخطوة | المهمة | الملفات |
|--------|--------|---------|
| 3.1 | إنشاء `ReturnsProvider` | `providers/returns_provider.dart` |
| 3.2 | ربط `returns_screen` بالـ DB | `screens/returns/returns_screen.dart` |
| 3.3 | ربط `refund_request_screen` بالـ DB | `screens/returns/refund_request_screen.dart` |
| 3.4 | ربط `void_transaction_screen` بالـ DB | `screens/returns/void_transaction_screen.dart` |
| 3.5 | ربط `refund_receipt_screen` | `screens/returns/refund_receipt_screen.dart` |
| 3.6 | تحديث المخزون تلقائياً عند الإرجاع | `providers/`, DAO updates |

---

### الوكيل 4: المصروفات (Expenses Agent)
**المهمة:** ربط شاشات المصروفات بقاعدة البيانات

| الخطوة | المهمة | الملفات |
|--------|--------|---------|
| 4.1 | إنشاء `ExpensesProvider` | `providers/expenses_provider.dart` |
| 4.2 | ربط `expenses_screen` بالـ DB | `screens/expenses/expenses_screen.dart` |
| 4.3 | ربط `expense_categories_screen` بالـ DB | `screens/expenses/expense_categories_screen.dart` |

---

### الوكيل 5: الموردين والمشتريات (Suppliers Agent)
**المهمة:** ربط شاشات الموردين والمشتريات بقاعدة البيانات

| الخطوة | المهمة | الملفات |
|--------|--------|---------|
| 5.1 | إنشاء `SuppliersDao` + `PurchasesDao` | `daos/suppliers_dao.dart`, `daos/purchases_dao.dart` |
| 5.2 | إنشاء `SuppliersProvider` | `providers/suppliers_provider.dart` |
| 5.3 | ربط `suppliers_screen` بالـ DB | `screens/suppliers/suppliers_screen.dart` |
| 5.4 | ربط `supplier_form_screen` بالـ DB | `screens/suppliers/supplier_form_screen.dart` |
| 5.5 | ربط `purchase_form_screen` بالـ DB | `screens/purchases/purchase_form_screen.dart` |

---

### الوكيل 6: التقارير (Reports Agent)
**المهمة:** ربط شاشات التقارير بالبيانات الحقيقية

| الخطوة | المهمة | الملفات |
|--------|--------|---------|
| 6.1 | ربط `profit_report_screen` بالـ DB (sales + expenses) | `screens/reports/profit_report_screen.dart` |
| 6.2 | ربط `top_products_report_screen` بالـ DB | `screens/reports/top_products_report_screen.dart` |
| 6.3 | ربط `peak_hours_report_screen` بالـ DB | `screens/reports/peak_hours_report_screen.dart` |
| 6.4 | ربط `inventory_report_screen` بالـ DB | `screens/reports/inventory_report_screen.dart` |
| 6.5 | ربط `customer_report_screen` بالـ DB | `screens/reports/customer_report_screen.dart` |
| 6.6 | ربط `staff_performance_screen` بالـ DB | `screens/reports/staff_performance_screen.dart` |
| 6.7 | ربط `tax_report_screen` + `vat_report_screen` بالـ DB | تقارير الضرائب |
| 6.8 | إنشاء `daily_summaries` table + DAO | تسريع التقارير |

---

### الوكيل 7: التسويق والخصومات (Marketing Agent)
**المهمة:** ربط شاشات التسويق بقاعدة البيانات

| الخطوة | المهمة | الملفات |
|--------|--------|---------|
| 7.1 | إنشاء الجداول + DAOs | tables + daos |
| 7.2 | إنشاء `DiscountsProvider` | `providers/discounts_provider.dart` |
| 7.3 | ربط `discounts_screen` | `screens/marketing/discounts_screen.dart` |
| 7.4 | ربط `coupon_management_screen` | `screens/marketing/coupon_management_screen.dart` |
| 7.5 | ربط `special_offers_screen` | `screens/marketing/special_offers_screen.dart` |

---

### الوكيل 8: الإعدادات والمستخدمين (Settings Agent)
**المهمة:** ربط شاشات الإعدادات وإدارة المستخدمين

| الخطوة | المهمة | الملفات |
|--------|--------|---------|
| 8.1 | ربط `store_settings_screen` بجدول `stores` | شاشة إعدادات المتجر |
| 8.2 | ربط `users_management_screen` بجدول `users` | إدارة المستخدمين |
| 8.3 | ربط `roles_permissions_screen` بجدول `roles` | الأدوار والصلاحيات |
| 8.4 | إنشاء `SettingsProvider` لحفظ الإعدادات في DB | الإعدادات الموحدة |

---

### الوكيل 9: الإشعارات والمخزون المتقدم (Misc Agent)
**المهمة:** ربط الشاشات المتبقية

| الخطوة | المهمة | الملفات |
|--------|--------|---------|
| 9.1 | إنشاء `notifications` table + DAO + Provider | الإشعارات |
| 9.2 | ربط `notifications_screen` | شاشة الإشعارات |
| 9.3 | ربط `stock_transfer_screen` | تحويلات المخزون |
| 9.4 | ربط `stock_take_screen` | الجرد |
| 9.5 | ربط `expiry_tracking_screen` | تواريخ الصلاحية |
| 9.6 | ربط `held_invoices` بالـ DB | الفواتير المعلقة |

---

## ترتيب التنفيذ المقترح

```
المرحلة 1: الوكيل 1 (DB Core) ← يجب أن ينتهي أولاً
    ↓
المرحلة 2: (بالتوازي)
    ├── الوكيل 2 (الورديات)
    ├── الوكيل 3 (المرتجعات)
    ├── الوكيل 4 (المصروفات)
    └── الوكيل 8 (الإعدادات)
    ↓
المرحلة 3: (بالتوازي)
    ├── الوكيل 5 (الموردين)
    ├── الوكيل 6 (التقارير) ← يعتمد على الوكيل 4
    └── الوكيل 7 (التسويق)
    ↓
المرحلة 4:
    └── الوكيل 9 (الإشعارات والمتبقي)
```

---

## ملاحظات مهمة

1. **كل جدول جديد يحتاج عمود `syncedAt`** لدعم المزامنة مع السيرفر
2. **يجب تحديث `SyncQueueDao`** لدعم الجداول الجديدة
3. **المهاجرة (Migration)** يجب أن تكون من v7 → v8 بشكل تدريجي
4. **`build_runner`** يجب تشغيله بعد كل تغيير في الجداول
5. **الاختبارات** يجب كتابتها مع كل DAO جديد
6. **الترجمة** يجب تحديث ملفات ARB الـ 7 مع أي نصوص جديدة

---

*تم إنشاء هذا التقرير بتاريخ: 2026-02-10*
