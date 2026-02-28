# 🚀 خطة تطوير منصة الحي - 90 يوم

**الإصدار:** 2.0.0  
**تاريخ البدء:** 2026-01-21  
**تاريخ الانتهاء المتوقع:** 2026-04-21  
**فريق العمل:** جهازين (A + B) × 3 حسابات Pro لكل جهاز

---

## 📊 نظرة عامة

### الهيكل العام:

```
┌─────────────────────────────────────────────────────────────┐
│                    منصة الحي SaaS                            │
│                       90 يوم                                 │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  الجهاز A (فريق نقطة البيع)     الجهاز B (فريق العميل)       │
│  ━━━━━━━━━━━━━━━━━━━━━━━━     ━━━━━━━━━━━━━━━━━━━━━━━━      │
│  ⏰ 12 ساعة/يوم               ⏰ 12 ساعة/يوم                │
│  👥 3 حسابات Pro              👥 3 حسابات Pro               │
│                                                              │
│  📱 التطبيقات:                 📱 التطبيقات:                 │
│  ├── cashier (نقطة البيع)     ├── customer_app (العميل)     │
│  ├── admin_pos (لوحة التحكم)   ├── driver_app (المندوب)      │
│  └── super_admin (الإدارة)     └── distributor_portal (B2B)  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### إحصائيات المشروع:

| البند | القيمة |
|-------|--------|
| **إجمالي التطبيقات** | 6 تطبيقات |
| **إجمالي الشاشات** | 277 شاشة |
| **مدة التطوير** | 35 يوم متوازي |
| **مدة الاختبار** | 25 يوم |
| **مدة الإطلاق** | 15 يوم |
| **المجموع** | 90 يوم |

---

## 📅 المرحلة الأولى: التطوير الأساسي (اليوم 1-35)

---

### 🗓️ الأسبوع 1-2 (اليوم 1-14): التطبيقات الرئيسية

#### الجهاز A - تطبيق نقطة البيع (cashier)

| اليوم | المهام | القصص (US) | الاختبارات |
|-------|--------|------------|-------------|
| **1** | إعداد المشروع + شاشة البداية | US-1.1 | ✅ Widget Test: SplashScreen renders |
| **2** | تسجيل الدخول (OTP + PIN) | US-1.2 | ✅ Unit Test: OTP validation |
| | | | ✅ Widget Test: Login form |
| **3** | اختيار المتجر | US-1.3 | ✅ Unit Test: Store selection |
| | | | ✅ Integration: Auth → Store flow |
| **4** | شاشة البيع السريع | US-2.1 | ✅ Widget Test: POS layout |
| | | | ✅ Unit Test: Product grid |
| **5** | البحث عن المنتجات | US-2.2 | ✅ Unit Test: Search algorithm |
| | | | ✅ Widget Test: Search results |
| **6** | قارئ الباركود | US-2.3 | ✅ Unit Test: Barcode parsing |
| | | | ✅ Integration: Scan → Cart |
| **7** | إدارة السلة | US-2.4-2.5 | ✅ Unit Test: Cart calculations |
| | | | ✅ Widget Test: Cart UI |

```dart
// مثال اختبار اليوم 7 - السلة
group('Cart Tests', () {
  test('إضافة منتج للسلة', () {
    final cart = CartCubit();
    cart.addProduct(product);
    expect(cart.items.length, 1);
  });
  
  test('حساب الإجمالي', () {
    final cart = CartCubit();
    cart.addProduct(Product(price: 10));
    cart.addProduct(Product(price: 20));
    expect(cart.total, 30);
  });
  
  test('تطبيق الخصم', () {
    final cart = CartCubit();
    cart.addProduct(Product(price: 100));
    cart.applyDiscount(10); // 10%
    expect(cart.total, 90);
  });
});
```

| اليوم | المهام | القصص (US) | الاختبارات |
|-------|--------|------------|-------------|
| **8** | الدفع النقدي | US-3.1 | ✅ Unit Test: Cash calculation |
| | | | ✅ Widget Test: Payment screen |
| **9** | الدفع بالبطاقة | US-3.2 | ✅ Integration: Payment gateway mock |
| **10** | الدفع المقسم | US-3.3 | ✅ Unit Test: Split payment logic |
| **11** | الإيصال + الطباعة | US-3.4 | ✅ Unit Test: Receipt generation |
| | | | ✅ Widget Test: Receipt preview |
| **12** | فتح/إغلاق الوردية | US-6.1-6.2 | ✅ Unit Test: Shift logic |
| | | | ✅ Integration: Shift → Sales |
| **13** | التقرير اليومي | US-6.3 | ✅ Unit Test: Report calculations |
| **14** | اختبارات شاملة | - | ✅ E2E: Complete sale flow |

```dart
// اختبار E2E اليوم 14
testWidgets('E2E: عملية بيع كاملة', (tester) async {
  // 1. تسجيل الدخول
  await tester.pumpWidget(PosApp());
  await tester.enterText(find.byKey(Key('phone')), '0501234567');
  await tester.tap(find.byKey(Key('login')));
  
  // 2. اختيار المتجر
  await tester.tap(find.text('بقالة الحي'));
  
  // 3. إضافة منتج
  await tester.tap(find.byType(ProductCard).first);
  expect(find.byType(CartItem), findsOneWidget);
  
  // 4. الدفع
  await tester.tap(find.text('إتمام البيع'));
  await tester.tap(find.text('نقدي'));
  
  // 5. التحقق من الإيصال
  expect(find.byType(ReceiptScreen), findsOneWidget);
});
```

#### ✅ إنجاز المرحلة 1: cashier MVP جاهز

---

#### الجهاز B - تطبيق العميل (customer_app)

| اليوم | المهام | الوصف | الاختبارات |
|-------|--------|-------|-------------|
| **1** | إعداد المشروع + البداية | Splash + Onboarding | ✅ Widget Test |
| **2** | تسجيل الدخول | Phone + OTP | ✅ Unit + Widget Tests |
| **3** | ربط المتجر | QR / رمز / بحث | ✅ Integration Test |
| **4** | كتالوج المنتجات | Grid + Categories | ✅ Widget Test |
| **5** | تفاصيل المنتج | Detail + Variants | ✅ Widget Test |
| **6** | سلة المشتريات | Cart UI + Logic | ✅ Unit + Widget Tests |
| **7** | منطق السلة | Add/Remove/Qty | ✅ Unit Tests |
| **8** | عملية الشراء | Checkout flow | ✅ Integration Test |
| **9** | بوابة الدفع | Payment integration | ✅ Mock Payment Test |
| **10** | تأكيد الطلب | Order confirmation | ✅ Widget Test |
| **11** | تتبع الطلب | Real-time tracking | ✅ Unit Test (Streams) |
| **12** | الملف الشخصي | Profile screen | ✅ Widget Test |
| **13** | سجل الطلبات | Order history | ✅ Unit Test |
| **14** | اختبارات شاملة | E2E Testing | ✅ E2E: Complete order |

```dart
// اختبار E2E للعميل
testWidgets('E2E: طلب كامل من العميل', (tester) async {
  await tester.pumpWidget(CustomerApp());
  
  // تسجيل الدخول
  await loginAsCustomer(tester);
  
  // تصفح المنتجات
  await tester.tap(find.text('الخضروات'));
  await tester.tap(find.text('طماطم'));
  
  // إضافة للسلة
  await tester.tap(find.text('أضف للسلة'));
  
  // إتمام الطلب
  await tester.tap(find.byIcon(Icons.shopping_cart));
  await tester.tap(find.text('إتمام الطلب'));
  
  // الدفع
  await tester.tap(find.text('الدفع عند الاستلام'));
  await tester.tap(find.text('تأكيد الطلب'));
  
  // التحقق
  expect(find.text('تم تأكيد طلبك'), findsOneWidget);
});
```

#### ✅ إنجاز المرحلة 1: customer_app MVP جاهز

---

### 🗓️ الأسبوع 3 (اليوم 15-21): الوضع الـ Offline والمزامنة

#### الجهاز A - وضع عدم الاتصال

| اليوم | المهام | القصص | الاختبارات |
|-------|--------|-------|-------------|
| **15** | اكتشاف الاتصال | US-4.1 | ✅ Unit: Connectivity detection |
| **16** | الطابور المحلي | US-4.2 | ✅ Unit: Queue operations |
| **17** | المزامنة الخلفية | US-4.3 | ✅ Unit: Background sync |
| **18** | حل التعارضات | US-4.4 | ✅ Unit: Conflict resolution |
| **19** | TOTP PIN | US-7.3 | ✅ Unit: TOTP generation |
| **20** | إيصال واتساب | US-3.5 | ✅ Integration: WhatsApp API |
| **21** | اختبار التكامل | - | ✅ E2E: Offline sale flow |

```dart
// اختبار الوضع Offline
group('Offline Mode Tests', () {
  test('البيع بدون انترنت', () async {
    // محاكاة انقطاع الاتصال
    when(connectivity.status).thenReturn(ConnectivityStatus.offline);
    
    // إجراء بيع
    final sale = await salesRepository.createSale(saleData);
    
    // التحقق من الحفظ محلياً
    expect(sale.syncStatus, SyncStatus.pending);
    
    // التحقق من الطابور
    final queue = await syncQueueService.getPendingItems();
    expect(queue.length, 1);
  });
  
  test('المزامنة عند العودة', () async {
    // محاكاة عودة الاتصال
    when(connectivity.status).thenReturn(ConnectivityStatus.online);
    
    // تشغيل المزامنة
    await syncService.processQueue();
    
    // التحقق من نجاح المزامنة
    final sale = await salesRepository.getSale(saleId);
    expect(sale.syncStatus, SyncStatus.synced);
  });
});
```

#### الجهاز B - الإشعارات والميزات

| اليوم | المهام | الوصف | الاختبارات |
|-------|--------|-------|-------------|
| **15** | الإشعارات Push | FCM Integration | ✅ Integration Test |
| **16** | التحديثات اللحظية | Realtime subscriptions | ✅ Unit Test (Streams) |
| **17** | المفضلة | Favorites feature | ✅ Unit + Widget Tests |
| **18** | البحث والفلترة | Advanced search | ✅ Unit Test |
| **19** | إدارة العناوين | Address CRUD | ✅ Widget Test |
| **20** | التقييمات | Ratings & Reviews | ✅ Unit + Widget Tests |
| **21** | اختبار التكامل | - | ✅ E2E: Full user journey |

#### ✅ إنجاز المرحلة 2: وضع Offline كامل

---

### 🗓️ الأسبوع 4 (اليوم 22-28): المرتجعات والولاء

#### الجهاز A - المرتجعات

| اليوم | المهام | القصص | الاختبارات |
|-------|--------|-------|-------------|
| **22** | طلب الإرجاع | US-5.1 | ✅ Unit: Return request validation |
| **23** | عملية الاسترداد | US-5.2 | ✅ Unit: Refund calculation |
| **24** | موافقة المشرف | US-5.3 | ✅ Integration: Approval flow |
| **25** | إلغاء المعاملة | - | ✅ Unit: Void logic |
| **26** | إيداع/سحب النقد | US-6.3 | ✅ Unit: Cash movement |
| **27** | تقرير نهاية اليوم | - | ✅ Unit: EOD calculations |
| **28** | اختبارات وتنظيف | - | ✅ E2E: Refund flow |

```dart
// اختبار المرتجعات
group('Refund Tests', () {
  test('حساب مبلغ الاسترداد الجزئي', () {
    final refund = RefundCalculator.partial(
      originalSale: sale,
      items: [
        RefundItem(productId: 'p1', quantity: 1),
      ],
    );
    
    expect(refund.amount, 50.0);
    expect(refund.type, RefundType.partial);
  });
  
  test('موافقة المشرف مطلوبة للمبالغ الكبيرة', () {
    final refund = Refund(amount: 500);
    expect(refund.requiresSupervisor, true);
  });
});
```

#### الجهاز B - الولاء والمحفظة

| اليوم | المهام | الوصف | الاختبارات |
|-------|--------|-------|-------------|
| **22** | نقاط الولاء | Points system | ✅ Unit: Points calculation |
| **23** | إعادة الطلب | Reorder feature | ✅ Widget Test |
| **24** | محادثة المتجر | Chat integration | ✅ Integration Test |
| **25** | أكواد الخصم | Promo codes | ✅ Unit: Code validation |
| **26** | المحفظة | Wallet balance | ✅ Unit + Widget Tests |
| **27** | مركز الإشعارات | Notification center | ✅ Widget Test |
| **28** | اختبارات وتنظيف | - | ✅ E2E Tests |

#### ✅ إنجاز المرحلة 3: cashier + customer_app كاملين

---

### 🗓️ الأسبوع 5 (اليوم 29-35): التطبيقات الثانوية

#### الجهاز A - لوحة تحكم المتجر (admin_pos)

| اليوم | المهام | الاختبارات |
|-------|--------|-------------|
| **29** | لوحة القيادة | ✅ Widget: Dashboard stats |
| **30** | تقارير المبيعات | ✅ Unit: Report generation |
| **31** | عرض المخزون | ✅ Unit: Inventory queries |
| **32** | إدارة المنتجات | ✅ CRUD Tests |
| **33** | إدارة الموظفين | ✅ Unit: Permissions |
| **34** | الإعدادات | ✅ Widget Test |
| **35** | اختبار شامل | ✅ E2E: Admin flow |

#### الجهاز B - تطبيق المندوب (driver_app)

| اليوم | المهام | الاختبارات |
|-------|--------|-------------|
| **29** | تسجيل المندوب | ✅ Auth Tests |
| **30** | الطلبات المتاحة | ✅ Unit: Order filtering |
| **31** | تفاصيل الطلب | ✅ Widget Test |
| **32** | الملاحة | ✅ Integration: Maps |
| **33** | تأكيد التسليم | ✅ Integration: Signature |
| **34** | الأرباح | ✅ Unit: Earnings calc |
| **35** | اختبار شامل | ✅ E2E: Delivery flow |

#### ✅ إنجاز المرحلة 4: admin_pos MVP + driver_app MVP

---

## 📅 المرحلة الثانية: الإدارة و B2B (اليوم 36-60)

---

### 🗓️ الأسبوع 6-7 (اليوم 36-49): لوحة الإدارة وبوابة الموزعين

#### الجهاز A - إكمال admin_pos

| اليوم | المهام | الاختبارات |
|-------|--------|-------------|
| **36** | إدارة العملاء | ✅ CRUD + Search Tests |
| **37** | إدارة الديون | ✅ Unit: Debt calculations |
| **38** | طلبات الموردين | ✅ Unit: PO creation |
| **39** | استلام البضاعة | ✅ Integration: Inventory update |
| **40** | تعديل المخزون | ✅ Unit: Stock adjustment |
| **41** | تنبيهات المخزون | ✅ Unit: Alert thresholds |
| **42** | إدارة الأصناف | ✅ CRUD Tests |
| **43** | العروض والخصومات | ✅ Unit: Promo logic |
| **44** | قوالب الإيصال | ✅ Widget Test |
| **45** | إعدادات التطبيق | ✅ Widget Test |
| **46** | التحليلات | ✅ Unit: Analytics queries |
| **47** | الإشعارات | ✅ Integration Test |
| **48** | اختبار شامل | ✅ E2E Tests |
| **49** | تنظيف وتحسين | Code review + Fixes |

#### الجهاز B - بوابة الموزعين (distributor_portal)

| اليوم | المهام | الاختبارات |
|-------|--------|-------------|
| **36** | تسجيل الموزع | ✅ Auth + Validation |
| **37** | كتالوج المنتجات | ✅ Widget Test |
| **38** | طلبات الجملة | ✅ Unit: Bulk order logic |
| **39** | إدارة الطلبات | ✅ CRUD Tests |
| **40** | تسعير الفئات | ✅ Unit: Tier pricing |
| **41** | إدارة الفواتير | ✅ Unit: Invoice generation |
| **42** | لوحة القيادة | ✅ Widget Test |
| **43** | التقارير | ✅ Unit Tests |
| **44** | الإعدادات | ✅ Widget Test |
| **45** | اختبار | ✅ E2E Tests |
| **46-49** | تكامل B2B | ✅ Integration Tests |

#### ✅ إنجاز المرحلة 5: admin_pos كامل + distributor_portal MVP

---

### 🗓️ الأسبوع 8-9 (اليوم 50-60): الإدارة العليا والتكامل

#### الجهاز A - super_admin

| اليوم | المهام | الاختبارات |
|-------|--------|-------------|
| **50** | لوحة المنصة | ✅ Widget: Platform stats |
| **51** | إدارة المتاجر | ✅ CRUD + Status Tests |
| **52** | إدارة المستخدمين | ✅ RBAC Tests |
| **53** | خطط الاشتراك | ✅ Unit: Subscription logic |
| **54** | تحليلات المنصة | ✅ Analytics Tests |
| **55** | إعدادات النظام | ✅ Widget Test |
| **56** | سجل التدقيق | ✅ Unit: Audit logging |
| **57** | تذاكر الدعم | ✅ Widget Test |
| **58-60** | اختبار وتنظيف | ✅ E2E + Review |

#### الجهاز B - التكامل بين التطبيقات

| اليوم | المهام | الاختبارات |
|-------|--------|-------------|
| **50** | اختبار APIs | ✅ API contract tests |
| **51** | تدفقات العمل | ✅ Cross-app flow tests |
| **52** | مزامنة البيانات | ✅ Sync integrity tests |
| **53** | الإشعارات | ✅ Push notification tests |
| **54** | الروابط العميقة | ✅ Deep link tests |
| **55** | معالجة الأخطاء | ✅ Error handling tests |
| **56** | الأداء | ✅ Performance tests |
| **57** | الأمان | ✅ Security audit |
| **58-60** | مراجعة شاملة | Full review |

#### ✅ إنجاز المرحلة 6: جميع التطبيقات مكتملة

---

## 📅 المرحلة الثالثة: الجودة والتحسين (اليوم 61-75)

---

### 🗓️ الأسبوع 10-11 (اليوم 61-75): الاختبارات والتحسين

| اليوم | الجهاز A | الجهاز B |
|-------|----------|----------|
| **61-63** | E2E Testing: cashier | E2E Testing: customer_app |
| **64-66** | E2E Testing: admin_pos | E2E Testing: driver_app, distributor |
| **67-68** | تحسين الأداء | تحسين الأداء |
| **69-70** | تعزيز الأمان | تعزيز الأمان |
| **71-72** | إصلاح الأخطاء | إصلاح الأخطاء |
| **73-74** | تحسين الواجهة | تحسين الواجهة |
| **75** | مراجعة نهائية | مراجعة نهائية |

### قائمة اختبارات الجودة:

```markdown
## ✅ اختبارات الأداء
- [ ] زمن تحميل الشاشة < 2 ثانية
- [ ] زمن استجابة API < 500ms
- [ ] استهلاك الذاكرة < 200MB
- [ ] حجم التطبيق < 50MB

## ✅ اختبارات الأمان
- [ ] تشفير البيانات الحساسة
- [ ] صلاحية الـ JWT
- [ ] RLS policies فعالة
- [ ] حماية من SQL injection
- [ ] حماية من XSS

## ✅ اختبارات التوافق
- [ ] iOS 14+
- [ ] Android 8+
- [ ] Windows 10+
- [ ] macOS 11+

## ✅ اختبارات الـ RTL
- [ ] جميع الشاشات تدعم RTL
- [ ] الأيقونات معكوسة صحيحاً
- [ ] النصوص محاذاة صحيحة
```

#### ✅ إنجاز المرحلة 7: جودة جاهزة للإنتاج

---

## 📅 المرحلة الرابعة: الإطلاق (اليوم 76-90)

---

### 🗓️ الأسبوع 12-13 (اليوم 76-90): النشر والإطلاق

| اليوم | المهام | المسؤول |
|-------|--------|---------|
| **76-78** | إعداد بيئة الإنتاج | الجميع |
| | - Supabase Production | |
| | - Cloudflare R2 | |
| | - Firebase (Analytics, Crashlytics) | |
| **79-81** | سكريبتات الهجرة | الجميع |
| | - Database migration | |
| | - Data seeding | |
| | - RLS verification | |
| **82-84** | اختبار Beta داخلي | الجميع |
| | - فريق التطوير | |
| | - 5-10 مستخدمين | |
| **85-87** | اختبار Beta خارجي | الجميع |
| | - 50-100 مستخدم | |
| | - جمع الملاحظات | |
| **88-89** | إصلاحات نهائية | الجميع |
| | - Critical bugs | |
| | - UX improvements | |
| **90** | 🚀 **يوم الإطلاق!** | 🎉 |

---

## 📊 ملخص المعالم الرئيسية

```
┌─────────────────────────────────────────────────────────────┐
│                    المعالم الرئيسية                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  اليوم 14  →  ✅ M1: cashier MVP + customer_app MVP         │
│  اليوم 21  →  ✅ M2: وضع Offline كامل                       │
│  اليوم 28  →  ✅ M3: جميع الميزات الأساسية                  │
│  اليوم 35  →  ✅ M4: admin_pos MVP + driver_app MVP         │
│  اليوم 49  →  ✅ M5: admin_pos كامل + distributor MVP       │
│  اليوم 60  →  ✅ M6: جميع التطبيقات مكتملة                  │
│  اليوم 75  →  ✅ M7: جودة الإنتاج                           │
│  اليوم 90  →  🚀 M8: الإطلاق!                               │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 إحصائيات الاختبارات المتوقعة

| نوع الاختبار | العدد المتوقع |
|--------------|---------------|
| **Unit Tests** | 500+ |
| **Widget Tests** | 200+ |
| **Integration Tests** | 50+ |
| **E2E Tests** | 30+ |
| **المجموع** | **780+ اختبار** |

### تغطية الكود المستهدفة:

| التطبيق | التغطية المستهدفة |
|---------|-------------------|
| `alhai_core` | 90%+ |
| `cashier` | 80%+ |
| `customer_app` | 80%+ |
| `admin_pos` | 75%+ |
| `driver_app` | 75%+ |
| `distributor_portal` | 75%+ |
| `super_admin` | 70%+ |

---

## 🔧 أدوات الاختبار

```yaml
# dev_dependencies في كل تطبيق
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  bloc_test: ^9.1.5
  network_image_mock: ^2.1.1
  golden_toolkit: ^0.15.0
  patrol: ^2.3.0  # E2E tests
  integration_test:
    sdk: flutter
```

---

## 📞 بروتوكول التنسيق اليومي

### التقرير اليومي (5 دقائق):

```markdown
📢 **تقرير الجهاز A - اليوم [X]**
- ✅ المنجز: [قائمة المهام]
- 🧪 الاختبارات: [عدد] جديدة، [عدد] فاشلة
- 🚧 المعوقات: [إن وجدت]
- 📌 غداً: [المهام القادمة]
```

---

**بالتوفيق! 🚀**

*آخر تحديث: 2026-01-20*
