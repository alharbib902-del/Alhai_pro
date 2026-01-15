# 📋 POS App - خطة التنفيذ التفصيلية

**التاريخ**: 2026-01-15  
**الإصدار**: 2.0 (مع

توافق alhai_core v3.4 + alhai_design_system)  
**المرجع**: POS_APP_SPEC.md v2.0

---

## القسم 0: نطاق العمل والفرضيات

### النطاق (Scope):
- تطبيق Flutter Desktop (Windows/macOS/Linux) لنقطة بيع بقالة
- 71 شاشة موزعة على 10 مراحل (Phases)
- المراحل 1-2: الأساسيات (Sprint 1-2)
- المراحل 3-6: الميزات الأساسية (Sprint 3-6)
- المراحل 7-10: الميزات المتقدمة (Sprint 7+)

### الفرضيات المعتمدة:
1. ✅ **alhai_core v3.4** جاهز ومتوفر
2. ✅ **alhai_design_system** جاهز (مكونات + theme)
3. ✅ **Supabase** مُعد (Auth + Database + RLS)
4. ✅ **Cloudflare R2** جاهز للصور
5. ✅ **State Management**: Riverpod كـ DI + ViewModels ChangeNotifier
6. ✅ **Local DB**: Drift (SQLite)
7. ✅ **Sync Queue**: من Sprint 1
8. ✅ **Printer**: Thermal 80mm (USB/Bluetooth)

### القرارات المعتمدة النهائية:
| القرار | القيمة |
|--------|--------|
| خصم المخزون | حجز عند Accept + خصم عند Delivered |
| الفوائد | شهرية بسيطة + periodKey لمنع التكرار |
| الديون | INVOICE(+), PAYMENT(-), INTEREST(+), WAIVE(-) |
| Returns | VOIDED status + حركة عكسية (لا حذف) |
| State | Riverpod (DI) + ChangeNotifier ViewModels |

---

## القسم 1: Sprint 1 - Foundation + Sync Skeleton

**المدة**: أسبوعان (Week 1-2)  
**الهدف**: بنية تحتية قوية + شاشة POS أساسية + Sync skeleton

### Module 1.1: Project Setup (يوم 1-2)

#### الهدف:
إنشاء المشروع + DI + Routing + Theme

#### الملفات المنشأة:
```
pos_app/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── di/
│   │   └── injection.dart  (GetIt + Injectable)
│   ├── core/
│   │   ├── router/
│   │   │   └── app_router.dart  (GoRouter)
│   │   └── constants/
│   │       └── app_constants.dart
│   └── shared/
│       └── widgets/
│
├── pubspec.yaml
└── analysis_options.yaml
```

#### المهام (Checklist):
```
[ ] flutter create pos_app
[ ] إضافة dependencies (alhai_core, alhai_design_system, drift, riverpod, etc)
[ ] Setup GetIt + Injectable
[ ] Configure GoRouter (routes skeleton)
[ ] Apply AlhaiTheme
[ ] Test: App launches + navigation works
```

#### Acceptance Criteria:
- ✅ App يفتح بدون أخطاء
- ✅ Dark/Light mode يعمل
- ✅ Navigation بين routes dummy يعمل

#### الاختبارات:
```dart
// test/app_test.dart
testWidgets('App launches successfully', (tester) async {
  await tester.pumpWidget(PosApp());
  expect(find.byType(MaterialApp), findsOneWidget);
});
```

---

### Module 1.2: Drift Setup + Models (يوم 3-4)

#### الهدف:
قاعدة بيانات محلية جاهزة + جميع Models

#### الملفات المنشأة:
```
lib/
├── data/
│   ├── local/
│   │   ├── database.dart  (Drift database)
│   │   ├── tables/
│   │   │   ├── products_table.dart
│   │   │   ├── inventory_table.dart
│   │   │   ├── sales_table.dart
│   │   │   ├── sale_items_table.dart
│   │   │   ├── accounts_table.dart
│   │   │   ├── transactions_table.dart
│   │   │   ├── purchases_table.dart
│   │   │   ├── orders_table.dart
│   │   │   ├── sync_queue_table.dart
│   │   │   ├── users_table.dart
│   │   │   └── settings_table.dart
│   │   └── daos/
│   │       ├── products_dao.dart
│   │       ├── inventory_dao.dart
│   │       ├── sales_dao.dart
│   │       ├── accounts_dao.dart
│   │       └── sync_dao.dart
```

#### المهام:
```
[ ] تعريف Drift tables (حسب schema في SPEC)
[ ] Generate Drift files (build_runner)
[ ] إنشاء DAOs لكل table
[ ] Test: Insert/Query/Update/Delete
```

#### Acceptance Criteria:
- ✅ جميع Tables معرفة
- ✅ DAOs تعمل (CRUD operations)
- ✅ No errors في build_runner

---

### Module 1.3: Sync Queue Skeleton (يوم 5-6)

#### الهدف:
نظام Sync Queue محلي جاهز (بدون API)

#### الملفات:
```
lib/
├── features/
│   └── sync/
│       ├── data/
│       │   ├── sync_repository.dart
│       │   └── sync_queue_service.dart
│       └── presentation/
│           └── sync_indicator_widget.dart
```

#### المهام:
```
[ ] SyncQueue table في Drift
[ ] SyncQueueService (enqueue/dequeue/updateStatus)
[ ] SyncRepository interface
[ ] Test: Enqueue sale → status PENDING
```

#### Acceptance Criteria:
- ✅ يمكن إضافة عملية للـ Queue
- ✅ يمكن قراءة pending items
- ✅ يمكن تحديث status (SYNCED/FAILED)

---

### Module 1.4: POS Screen Layout (يوم 7-8)

#### الهدف:
Split View جاهزة (Grid + Cart)

#### الملفات:
```
lib/
├── features/
│   └── pos/
│       ├── presentation/
│       │   ├── screens/
│       │   │   └── pos_screen.dart
│       │   ├── widgets/
│       │   │   ├── products_grid.dart
│       │   │   ├── cart_panel.dart
│       │   │   ├── category_tabs.dart
│       │   │   └── search_bar.dart
│       │   └── view_models/
│       │       └── pos_view_model.dart  (ChangeNotifier)
```

#### المهام:
```
[ ] POS Screen layout (70% grid / 30% cart)
[ ] Categories tabs (mock data)
[ ] Products grid (mock data)
[ ] Cart panel (empty state)
[ ] ViewModel skeleton
```

#### Acceptance Criteria:
- ✅ Split view responsive
- ✅ Categories clickable
- ✅ Grid displays products
- ✅ Cart panel visible

---

### Module 1.5: Products Grid + Cart (يوم 9-10)

#### الهدف:
إضافة منتجات للسلة

#### المهام:
```
[ ] ProductCard widget (image + name + price)
[ ] Click product → add to cart
[ ] CartItemCard widget
[ ] Update quantity (+/-)
[ ] Remove from cart
[ ] Calculate total
```

#### Acceptance Criteria:
- ✅ Click product → appears in cart
- ✅ Quantity controls work
- ✅ Total calculates correctly
- ✅ Remove item works

#### الاختبارات:
```dart
testWidgets('Add product to cart', (tester) async {
  // Test add to cart functionality
});
```

---

## القسم 2: Sprint 2 - POS Complete + API Integration

**المدة**: أسبوعان (Week 3-4)  
**الهدف**: نظام بيع كامل + Auth + Sync حقيقي

### Module 2.1: Authentication (يوم 11-12)

#### الهدف:
تسجيل دخول + Session management

#### الملفات:
```
lib/
├── features/
│   └── auth/
│       ├── data/
│       │   └── auth_repository.dart
│       ├── domain/
│       │   └── auth_service.dart
│       └── presentation/
│           ├── screens/
│           │   └── login_screen.dart
│           └── view_models/
│               └── auth_view_model.dart
```

#### المهام:
```
[ ] Login screen (phone + PIN)
[ ] Supabase Auth integration
[ ] Token storage (secure_storage)
[ ] Auto-login on launch
[ ] Logout
```

#### Acceptance Criteria:
- ✅ Login redirects to POS
- ✅ Token saved securely
- ✅ Auto-login works
- ✅ Logout clears session

---

### Module 2.2: Basic Push/Pull Sync (يوم 13-14)

#### الهدف:
Sync حقيقي مع Supabase

#### الملفات:
```
lib/
├── features/
│   └── sync/
│       ├── data/
│       │   ├── sync_api_client.dart
│       │   └── sync_repository_impl.dart
│       └── domain/
│           └── sync_service.dart
```

#### المهام:
```
[ ] Pull: جلب Products من Supabase
[ ] Push: رفع Sales إلى Supabase
[ ] Conflict resolution (last-write-wins)
[ ] Retry mechanism
[ ] Background sync (periodic)
```

#### Acceptance Criteria:
- ✅ Products تُسحب من السيرفر
- ✅ Sales تُرفع بنجاح
- ✅ Sync queue status يتحدث
- ✅ Background sync يعمل تلقائياً

---

### Module 2.3: Payment + Customer Selection (يوم 15-16)

#### الهدف:
اختيار طريقة الدفع + عميل

#### الملفات:
```
lib/
├── features/
│   └── pos/
│       ├── presentation/
│       │   ├── screens/
│       │   │   └── payment_screen.dart
│       │   └── widgets/
│       │       ├── payment_method_selector.dart
│       │       └── customer_drawer.dart
```

#### المهام:
```
[ ] Payment screen (CASH/CARD/CREDIT)
[ ] Customer drawer (search + select)
[ ] CREDIT: check credit limit
[ ] Confirm payment
```

#### Acceptance Criteria:
- ✅ يمكن اختيار طريقة الدفع
- ✅ يمكن اختيار عميل (للآجل)
- ✅ Credit limit validation
- ✅ Proceed to receipt

---

### Module 2.4: Sale Creation + Inventory Deduct (يوم 17-18)

#### الهدف:
حفظ البيع + خصم المخزون

#### الملفات:
```
lib/
├── features/
│   └── sales/
│       ├── data/
│       │   ├── sales_dao.dart
│       │   └── sales_repository.dart
│       └── domain/
│           ├── sale.dart
│           └── create_sale_usecase.dart
```

#### المهام:
```
[ ] Create Sale record (receiptNo, channel=POS)
[ ] Create SaleItems
[ ] Deduct inventory (SALE_OUT movement)
[ ] If CREDIT: create Transaction (+)
[ ] Enqueue to sync
[ ] Clear cart
```

#### Acceptance Criteria:
- ✅ Sale saved to DB
- ✅ Inventory decreased
- ✅ Account transaction created (if credit)
- ✅ Sale queued for sync

---

### Module 2.5: Receipt Printing (يوم 19-20)

#### الهدف:
طباعة إيصال حراري 80mm

#### الملفات:
```
lib/
├── core/
│   └── printing/
│       ├── printer_service.dart
│       ├── receipt_template.dart
│       └── thermal_printer.dart
```

#### المهام:
```
[ ] Receipt template (compact/detailed)
[ ] Print to Thermal printer (USB/Bluetooth)
[ ] Fallback: PDF generation
[ ] Settings: auto-print toggle
[ ] "Reprint last receipt" button
```

#### Acceptance Criteria:
- ✅ Receipt prints after sale
- ✅ PDF fallback works
- ✅ Reprint works
- ✅ Template selection works

---

### Module 2.6: Printer Settings Screen (يوم 21)

#### الهدف:
إعدادات الطابعة

#### الملفات:
```
lib/
├── features/
│   └── settings/
│       └── presentation/
│           └── screens/
│               └── printer_settings_screen.dart
```

#### المهام:
```
[ ] Select printer type (Thermal/PDF)
[ ] Test print button
[ ] Auto-print toggle
[ ] Template selection
[ ] Save settings
```

#### Acceptance Criteria:
- ✅ يمكن اختيار طابعة
- ✅ Test print يعمل
- ✅ Settings تُحفظ محلياً

---

### Module 2.7: Products CRUD (يوم 22-24)

#### الهدف:
إدارة المنتجات كاملة

#### الملفات:
```
lib/
├── features/
│   └── products/
│       ├── data/
│       │   ├── products_dao.dart
│       │   └── products_repository.dart
│       ├── domain/
│       │   └── product.dart  (من alhai_core)
│       └── presentation/
│           ├── screens/
│           │   ├── products_list_screen.dart
│           │   ├── product_details_screen.dart
│           │   └── add_product_screen.dart
│           └── view_models/
│               └── products_view_model.dart
```

#### المهام:
```
[ ] Products list (search + filter)
[ ] Add product (with R2 image upload)
[ ] Edit product
[ ] Delete product (soft delete)
[ ] Category management
```

#### Acceptance Criteria:
- ✅ CRUD operations work
- ✅ Images upload to R2
- ✅ Search works
- ✅ Filter by category works

---

## القسم 3: المخاطر والتبعيات

### المخاطر:

#### 1. Thermal Printer Compatibility ⚠️
**الخطر**: قد لا تعمل الطابعة على جميع الأجهزة  
**التخفيف**:
- PDF fallback جاهز
- Test early على أجهزة مختلفة
- Driver documentation واضحة

#### 2. Sync Conflicts 🔴
**الخطر**: تعارضات البيانات بين offline/online  
**التخفيف**:
- Last-write-wins strategy
- Audit log لكل تعديل
- Manual conflict resolution UI (Phase 6)

#### 3. R2 Image Upload Performance ⚠️
**الخطر**: بطء في رفع الصور  
**التخفيف**:
- Progressive upload (background)
- Local caching
- Retry mechanism

#### 4. Drift Migration Complexity 🔴
**الخطر**: صعوبة migrations مع تطور Schema  
**التخفيف**:
- Version schema بعناية
- Test migrations على بيانات حقيقية
- Backup قبل كل migration

### التبعيات:

```
Sprint 1 → Sprint 2: Auth required for Sync
Sprint 2 → Sprint 3: Products CRUD required for Purchases
Sprint 3 → Sprint 4: Accounts required for Debts
Sprint 4 → Sprint 5: Debts required for Orders (credit)
```

---

## القسم 4: Definition of Done (DoD)

### لكل Module:

#### Code Quality:
- ✅ `flutter analyze` بدون errors
- ✅ `flutter test` جميع tests تمر
- ✅ Code coverage ≥ 70%

#### Functionality:
- ✅ جميع Acceptance Criteria met
- ✅ Manual testing done
- ✅ Edge cases handled

#### Documentation:
- ✅ Code comments for complex logic
- ✅ README updated (if needed)
- ✅ API docs (if public methods)

#### Integration:
- ✅ Compatible مع alhai_core
- ✅ Uses alhai_design_system components
- ✅ Follows DEVELOPER_STANDARDS

---

## القسم 5: أول 10 تذاكر (Tickets)

### Ticket #1: Project Setup
**الوصف**: إنشاء المشروع + dependencies + DI  
**Acceptance Criteria**:
- App launches successfully
- GetIt configured
- GoRouter setup
- Dark/Light mode works

**المهام**:
```
[ ] flutter create pos_app
[ ] Add pubspec dependencies
[ ] Setup GetIt + Injectable
[ ] Configure GoRouter
[ ] Apply AlhaiTheme
```

---

### Ticket #2: Drift Database Setup
**الوصف**: إعداد Drift + تعريف Tables الأساسية  
**Acceptance Criteria**:
- Products, Sales, Inventory tables defined
- DAOs created
- build_runner succeeds
- Basic CRUD works

**المهام**:
```
[ ] Define Drift tables
[ ] Create DAOs
[ ] Run build_runner
[ ] Test CRUD operations
```

---

### Ticket #3: Sync Queue Skeleton
**الوصف**: نظام Queue محلي  
**Acceptance Criteria**:
- Enqueue operation works
- Read pending items works
- Update status works
- No API integration yet

**المهام**:
```
[ ] SyncQueue table
[ ] SyncQueueService
[ ] Test enqueue/dequeue
```

---

###  #4: POS Screen Layout
**الوصف**: Split view (Grid + Cart)  
**Acceptance Criteria**:
- 70/30 split
- Categories tabs visible
- Grid layout responsive
- Cart panel present

**المهام**:
```
[ ] Create POS screen
[ ] Products grid widget
[ ] Cart panel widget
[ ] Category tabs
```

---

### Ticket #5: Add to Cart Functionality
**الوصف**: إضافة منتجات للسلة  
**Acceptance Criteria**:
- Click product → cart
- Quantity controls work
- Remove item works
- Total calculates

**المهام**:
```
[ ] ProductCard click handler
[ ] Cart state management
[ ] Quantity +/-
[ ] Remove button
[ ] Calculate total
```

---

### Ticket #6: Authentication
**الوصف**: Login + Session  
**Acceptance Criteria**:
- Login with phone + PIN
- Token saved
- Auto-login works
- Logout clears session

**المهام**:
```
[ ] Login screen UI
[ ] Supabase Auth integration
[ ] Token storage
[ ] Auto-login logic
```

---

### Ticket #7: Products Pull Sync
**الوصف**: سحب Products من Supabase  
**Acceptance Criteria**:
- Products fetched
- Saved to local DB
- Images cached
- Works offline after first sync

**المهام**:
```
[ ] GET /products API
[ ] Save to Drift
[ ] Image caching
[ ] Conflict resolution
```

---

### Ticket #8: Payment Selection
**الوصف**: شاشة اختيار طريقة الدفع  
**Acceptance Criteria**:
- CASH/CARD/CREDIT options
- Customer selection (for credit)
- Credit limit validation
- Proceed to receipt

**المهام**:
```
[ ] Payment screen UI
[ ] Payment method selector
[ ] Customer drawer
[ ] Credit validation
```

---

### Ticket #9: Sale Creation
**الوصف**: حفظ البيع + خصم المخزون  
**Acceptance Criteria**:
- Sale record created
- Inventory deducted
- Transaction created (if credit)
- Queued for sync

**المهام**:
```
[ ] Create Sale
[ ] Create SaleItems
[ ] Inventory movement
[ ] Account transaction
[ ] Enqueue sync
```

---

### Ticket #10: Receipt Printing
**الوصف**: طباعة إيصال حراري  
**Acceptance Criteria**:
- Print to thermal printer
- PDF fallback
- Template selection
- Reprint works

**المهام**:
```
[ ] Receipt template
[ ] Thermal printer integration
[ ] PDF generation
[ ] Reprint functionality
```

---

## ملحق: التوافق مع alhai_core و alhai_design_system

### استخدام alhai_core:

```dart
import 'package:alhai_core/alhai_core.dart';

// ✅ Models جاهزة
Product
Order
OrderItem
Payment
Category
Store
Sale
Debt

// ✅ Repositories
final productRepo = getIt<ProductRepository>();
await productRepo.getAll();

// ✅ Services
final imageService = ImageService();
await imageService.uploadProductImage(file, productId);
```

### استخدام alhai_design_system:

```dart
import 'package:alhai_design_system/alhai_design_system.dart';

// ✅ Components
AlhaiButton(text: 'حفظ', onPressed: _save)
AlhaiTextField(label: 'الاسم', controller: _controller)
ProductImage(url: product.thumbnailUrl, size: 100)
AlhaiCard(child: ...)

// ✅ Tokens
AlhaiSpacing.md
AlhaiRadius.lg
AlhaiColors.primary

// ✅ Theme
AlhaiTheme.light()
AlhaiTheme.dark()
```

---

**📅 آخر تحديث**: 2026-01-15  
**✅ الحالة**: Ready for Sprint 1  
**🎯 الخطوة التالية**: تنفيذ Ticket #1 - Project Setup
