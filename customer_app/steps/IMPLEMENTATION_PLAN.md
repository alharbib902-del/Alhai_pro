# 📋 Customer App - خطة التنفيذ الشاملة

**التاريخ**: 2026-01-15  
**المشروع**: بقالة الحي - تطبيق العميل  
**المراجع**: PRD_FINAL.md + جميع الوثائق

---

## 🎯 ملخص تنفيذي

### المشروع:
تطبيق Flutter للعميل يدعم Multi-Store، يتيح الطلب من بقالات متعددة مع:
- إدارة الديون والآجل لكل بقالة
- نظام ولاء متقدم
- تتبع real-time
- محادثة مع المندوب (6 لغات + AI)
- عمل offline كامل

### الحجم:
- **80 شاشة** (30 P0 + 44 P1 + 6 P2)
- **50+ API Endpoints**
- **8-12 أسبوع** للنسخة الأولى (P0 + P1 الحرجة)

---

# القسم 1: تقسيم المشروع (Parts)

## Part 1: Foundation & Setup
**المدة**: أسبوع 1  
**الهدف**: بنية تحتية جاهزة للتطوير

### المخرجات:
- ✅ Flutter project setup (Clean Architecture)
- ✅ Supabase configuration (Auth + RLS)
- ✅ State management (Riverpod/Bloc)
- ✅ Design System (AlhaiDesignSystem)
- ✅ Routing (GoRouter)
- ✅ Local storage (Hive)
- ✅ Environment configs (dev/staging/prod)
- ✅ CI/CD pipeline basic
- ✅ Error tracking (Sentry/Firebase Crashlytics)

### الاعتماديات:
- Supabase project جاهز
- Cloudflare R2 bucket مُعد
- API keys (Maps, Push Notifications)

### المخاطر:
⚠️ **تأخير في setup Supabase RLS**  
✅ الحل: استخدام mock data أولاً

⚠️ **عدم وضوح Design System**  
✅ الحل: استخدام AlhaiDesignSystem الجاهز

---

## Part 2: Authentication Flow
**المدة**: أسبوع 1-2  
**الهدف**: المستخدم يسجل ويدخل بأمان

### المخرجات:
- ✅ `/onboarding` (3 slides)
- ✅ `/auth/signup` (Phone + OTP)
- ✅ `/auth/login` (OTP verification)
- ✅ Session management
- ✅ Auto-login on app launch
- ✅ Logout flow

### الاعتماديات:
- Supabase Auth configured
- SMS provider (Twilio/AWS SNS)

### المخاطر:
⚠️ **تكلفة SMS عالية في التطوير**  
✅ الحل: استخدام test numbers + bypass في dev

---

## Part 3: Stores & Location
**المدة**: أسبوع 2-3  
**الهدف**: المستخدم يشوف ويختار بقالات

### المخرجات:
- ✅ `/home` (Nearby stores)
- ✅ `/stores/:storeId` (Store details)
- ✅ `/location/select` (Location picker)
- ✅ GPS integration
- ✅ Store status (open/closed/busy)
- ✅ Customer account per store

### الاعتماديات:
- Maps API (Google Maps)
- Location permissions
- GET `/stores/nearby` API

### المخاطر:
⚠️ **GPS غير دقيق**  
✅ الحل: fallback على manual location

---

## Part 4: Catalog & Cart
**المدة**: أسبوع 3-4  
**الهدف**: المستخدم يتصفح ويضيف للسلة

### المخرجات:
- ✅ `/stores/:storeId/products` (Product list)
- ✅ `/products/:productId` (Product details)
- ✅ `/search` (Search products)
- ✅ `/stores/:storeId/products/filters` (Filters)
- ✅ `/cart` (Shopping cart)
- ✅ Product images (R2 + CDN)
- ✅ Lazy loading + caching

### الاعتماديات:
- Cloudflare CDN configured
- Product images uploaded to R2
- Category taxonomy ready

### المخاطر:
⚠️ **صور بطيئة**  
✅ الحل: Progressive loading + CDN

---

## Part 5: Checkout & Orders
**المدة**: أسبوع 4-6  
**الهدف**: المستخدم يطلب ويتتبع

### المخرجات:
- ✅ `/orders/new` (Checkout)
- ✅ `/orders/:orderId/schedule` (Delivery time)
- ✅ `/orders/:orderId/confirmation` (Success)
- ✅ `/orders` (Orders list)
- ✅ `/orders/:orderId` (Order details)
- ✅ `/orders/:orderId/track` (Real-time tracking)
- ✅ Order status updates (push)
- ✅ All P0 Edge Cases (8 شاشات)

### الاعتماديات:
- Payment gateway integration
- Push notifications setup
- Real-time database (Supabase Realtime)

### المخاطر:
⚠️ **Edge Cases معقدة**  
✅ الحل: أولوية للـ Happy Path أولاً

---

## Part 6: Payments & Debts
**المدة**: أسبوع 5-7  
**الهدف**: المستخدم يدفع ويسدد ديونه

### المخرجات:
- ✅ `/payments/:paymentId/pending` (Payment processing)
- ✅ `/payments/failed` (Payment failure)
- ✅ `/payments/:paymentId/refund` (Refunds)
- ✅ `/accounts` (All accounts)
- ✅ `/accounts/:storeId` (Account details)
- ✅ `/payments/debt/:storeId` (Debt payment)
- ✅ Credit limit handling
- ✅ Transaction history

### الاعتماديات:
- Payment gateway (Stripe/Tap/Moyasar)
- 3DS support
- Webhook handling

### المخاطر:
⚠️ **Payment gateway تأخير**  
✅ الحل: mock payment في dev

⚠️ **3DS معقد**  
✅ الحل: استخدام SDK جاهز

---

## Part 7: Loyalty & Chat
**المدة**: أسبوع 6-8  
**الهدف**: تفاعل محسّن ومكافآت

### المخرجات:
- ✅ `/loyalty` (Points dashboard)
- ✅ `/loyalty/challenges` (Challenges)
- ✅ `/loyalty/history` (Points history)
- ✅ `/chat` (Conversations list)
- ✅ `/chat/:orderId` (Chat with driver)
- ✅ Real-time messaging
- ✅ Translation toggle (6 languages)
- ✅ `/orders/:orderId/rate-driver` (Rating)
- ✅ `/stores/:storeId/rate` (Store rating)

### الاعتماديات:
- Chat backend (Supabase Realtime / Stream)
- Translation API (Google Translate)
- Points calculation logic

### المخاطر:
⚠️ **Translation بطيئة**  
✅ الحل: cache translations

---

## Part 8: Settings & Support
**المدة**: أسبوع 7-9  
**الهدف**: تحكم كامل وdعم قوي

### المخرجات:
- ✅ `/settings/profile` (Profile)
- ✅ `/settings/addresses` (Addresses)
- ✅ `/settings/payment-methods` (Cards)
- ✅ `/settings/notifications` (Preferences)
- ✅ `/settings/substitutions` (Substitution prefs)
- ✅ `/settings/general` (Dark mode, language)
- ✅ `/settings/delete-account` (Account deletion)
- ✅ `/support` (Support center)
- ✅ `/support/tickets/new` (Create ticket)
- ✅ `/security/devices` (Connected devices)
- ✅ `/security/activity` (Activity log)
- ✅ `/settings/data-export` (GDPR compliance)

### الاعتماديات:
- Support ticketing system
- GDPR compliance requirements

### المخاطر:
⚠️ **Account deletion معقد**  
✅ الحل: soft delete أولاً

---

## Part 9: Performance & Offline
**المدة**: مستمر من أسبوع 3  
**الهدف**: تطبيق سريع وموثوق

### المخرجات:
- ✅ Image caching (CachedNetworkImage)
- ✅ Offline-first architecture
- ✅ Local database (Hive)
- ✅ Background sync
- ✅ Offline queue
- ✅ Progressive loading
- ✅ Skeleton screens
- ✅ Route preloading

### الاعتماديات:
- Performance Strategy document

### المخاطر:
⚠️ **Sync conflicts**  
✅ الحل: Last-write-wins + conflict UI

---

## Part 10: QA & Release
**المدة**: أسبوع 10-12  
**الهدف**: إطلاق مستقر

### المخرجات:
- ✅ All critical paths tested
- ✅ Edge cases validated
- ✅ Performance benchmarks met
- ✅ Security audit passed
- ✅ App Store assets ready
- ✅ Beta testing completed
- ✅ Production deployment

### الاعتماديات:
- QA team availability
- Beta testers

### المخاطر:
⚠️ **Bugs في production**  
✅ الحل: staged rollout (10% → 50% → 100%)

---

# القسم 2: المراحل (Phases)

## Phase 0: Setup & Architecture
**المدة**: أسبوع 1  
**الهدف**: بنية قوية وجاهزة

### Scope:
1. Create Flutter project (clean architecture)
2. Setup Supabase (auth + database + RLS)
3. Configure Cloudflare R2 + CDN
4. Implement Design System
5. Setup state management (Riverpod)
6. Configure routing (GoRouter)
7. Setup local storage (Hive)
8. Environment configs (3 environments)
9. CI/CD basic (build + tests)
10. Error tracking (Sentry)

### Definition of Done:
- ✅ App builds successfully on iOS + Android
- ✅ Can login to Supabase
- ✅ Images load from CDN
- ✅ Navigation works
- ✅ Dark mode toggles
- ✅ Crashes tracked in Sentry

### Tasks:
```
[ ] Create Flutter project
[ ] Add dependencies (see DEPENDENCIES.md)
[ ] Setup folder structure (features/core/shared)
[ ] Create base models (Customer, Store, Product, Order)
[ ] Implement AlhaiDesignSystem
[ ] Configure Supabase client
[ ] Test R2 image loading
[ ] Setup Riverpod providers
[ ] Configure GoRouter routes
[ ] Initialize Hive boxes
[ ] Setup env configs (.env files)
[ ] Configure CI/CD (GitHub Actions)
[ ] Integrate Sentry
```

---

## Phase 1: P0 Screens (MVP + Critical)
**المدة**: أسبوع 2-6  
**الهدف**: تطبيق يعمل للسيناريو الأساسي

### Scope (30 شاشة P0):

#### Auth (3):
1. Onboarding
2. Signup
3. Login

#### Home & Stores (3):
4. Home
5. Store Details
6. Cart

#### Orders (5):
7. New Order
8. Schedule
9. Confirmation
10. Orders List
11. Order Details

#### Edge Cases (8):
12. No Stores
13. Credit Unavailable
14. Credit Limit
15. Price Changed
16. Min Order
17. Out of Area
18. Store Closed
19. No Slots

#### Delivery & Payment (6):
20. Payment Failed
21. Payment Pending
22. Refund
23. Product List
24. Cancelled by Store
25. Item Unavailable

### Definition of Done:
- ✅ User can complete full journey: Signup → Browse → Order → Track → Deliver
- ✅ All edge cases handled gracefully
- ✅ Payment flow works (test mode)
- ✅ App doesn't crash on any P0 screen
- ✅ Acceptance criteria met for all P0 screens

---

## Phase 2: P1 Core Features
**المدة**: أسبوع 7-10  
**الهدف**: تطبيق كامل الوظائف

### Scope (44 شاشة P1):
- Order operations (edit/reorder/fees/proof/help)
- Operational cases (high demand/edit rejected/account restricted/review)
- State screens (no internet/error/empty/loading)
- Accounts & debts (all accounts/account details/transactions)
- Invoices & receipts
- Loyalty (points/challenges/history)
- Chat (conversations/messages)
- Ratings (driver/store)
- Catalog (search/filters)
- Settings (8 screens)
- Location management
- Support (3 screens)
- Compliance (data export/permissions)
- Security (devices/activity)

### Definition of Done:
- ✅ All P1 features working
- ✅ Offline mode functional
- ✅ Chat real-time working
- ✅ Loyalty points calculating correctly
- ✅ Support tickets submittable

---

## Phase 3: P2 Enhancements
**المدة**: أسبوع 11-12  
**الهدف**: ميزات تنافسية

### Scope (6 شاشات P2):
- Reports (4: dashboard/purchases/debts/points)
- Promos/Coupons
- AI Assistant

### Definition of Done:
- ✅ Reports generate correctly
- ✅ Promos apply in checkout
- ✅ AI responds to queries

---

# القسم 3: Backlog التفصيلي

## Epic 1: Authentication

### Story 1.1: الصيس مستخدم هو الذي يتمكن من تسجيل حساب جديد
**المسار**: `/auth/signup`  
**الأولوية**: P0

**Acceptance Criteria**:
- عند إدخال رقم جوال صحيح، يُرسل OTP
- OTP يصل خلال 30 ثانية
- عند إدخال OTP صحيح + الاسم، يُنشأ الحساب
- يُسجل دخول تلقائياً بعد التسجيل
- رسالة خطأ واضحة عند OTP خاطئ

**Tasks**:
```
Backend:
[ ] POST /auth/send-otp endpoint
[ ] POST /auth/verify-otp endpoint
[ ] Create global_customers table entry
[ ] Generate JWT token

Frontend:
[ ] Build SignupScreen UI
[ ] Phone input validation (966...)
[ ] OTP input (6 digits)
[ ] Handle loading states
[ ] Handle errors (invalid phone, OTP expired, etc)
[ ] Navigate to Home on success
[ ] Save token to secure storage

QA:
[ ] Test happy path
[ ] Test invalid phone
[ ] Test wrong OTP
[ ] Test expired OTP
[ ] Test network failure
```

---

### Story 1.2: كمستخدم مسجل، أريد تسجيل الدخول
**المسار**: `/auth/login`  
**الأولوية**: P0

**Acceptance Criteria**:
- يتذكر رقم الجوال السابق
- OTP يُرسل للرقم المسجل
- تسجيل دخول ناجح عند OTP صحيح
- Session تبقى نشطة (Remember me)

**Tasks**:
```
Backend:
[ ] Validate phone exists
[ ] Send OTP to existing user

Frontend:
[ ] Build LoginScreen UI
[ ] Remember last phone (SharedPrefs)
[ ] OTP verification flow
[ ] Session management (auto-refresh token)

QA:
[ ] Test login flow
[ ] Test remember me
[ ] Test session expiry
```

---

## Epic 2: Stores & Location

### Story 2.1: كمستخدم، أريد رؤية البقالات القريبة
**المسار**: `/home`  
**الأولوية**: P0

**Acceptance Criteria**:
- يطلب location permission عند أول فتح
- يعرض البقالات مرتبة حسب المسافة
- يعرض حالة البقالة (مفتوح/مغلق/مزدحم)
- يعرض الدين الحالي لكل بقالة
- يعرض "لا بقالات" إذا لم يجد

**Tasks**:
```
Backend:
[ ] GET /stores/nearby?lat=X&lng=Y
[ ] Calculate distance
[ ] Return store status
[ ] Return customer account balance

Frontend:
[ ] Request location permission
[ ] Get current GPS location
[ ] Call /stores/nearby API
[ ] Display stores list
[ ] Show distance + status + debt
[ ] Handle "no stores" state
[ ] Pull to refresh

QA:
[ ] Test with different locations
[ ] Test permission denied
[ ] Test no stores nearby
[ ] Test offline mode
```

---

### Story 2.2: كمستخدم، أريد رؤية تفاصيل البقالة
**المسار**: `/stores/:storeId`  
**الأولوية**: P0

**Acceptance Criteria**:
- يعرض معلومات البقالة (اسم/عنوان/هاتف/ساعات عمل)
- يعرض حسابي في هذه البقالة (دين/حد ائتمان/آخر طلب)
- يعرض آخر 5 طلبات
- زر "طلب جديد" واضح
- زر "سداد الدين" إذا يوجد دين

**Tasks**:
```
Backend:
[ ] GET /stores/:storeId
[ ] GET /accounts/:storeId (customer account)
[ ] GET /orders?storeId=X&limit=5

Frontend:
[ ] Build StoreDetailsScreen
[ ] Display store info
[ ] Display customer account card
[ ] Display recent orders list
[ ] Navigate to products on "طلب جديد"
[ ] Navigate to payment on "سداد"

QA:
[ ] Test with different stores
[ ] Test with/without debt
[ ] Test with no orders
```

---

## Epic 3: Products & Cart

### Story 3.1: كمستخدم، أريد تصفح المنتجات
**المسار**: `/stores/:storeId/products`  
**الأولوية**: P0

**Acceptance Criteria**:
- يعرض المنتجات بصور من CDN
- يعرض السعر لكل منتج
- زر + لإضافة للسلة
- Search bar يعمل
- Filters (categories)
- Lazy loading (20 م at a time)

**Tasks**:
```
Backend:
[ ] GET /stores/:storeId/products?page=1&limit=20
[ ] Support search ?q=keyword
[ ] Support category filter ?category=dairy

Frontend:
[ ] Build ProductListScreen
[ ] Product grid/list view
[ ] CachedNetworkImage for images
[ ] Add to cart button
[ ] Search implementation
[ ] Category filters
[ ] Pagination (infinite scroll)
[ ] Empty state

QA:
[ ] Test image loading
[ ] Test search
[ ] Test filters
[ ] Test pagination
[ ] Test add to cart
```

---

### Story 3.2: كمستخدم، أريد إدارة السلة
**المسار**: `/cart`  
**الأولوية**: P0

**Acceptance Criteria**:
- يعرض جميع منتجات السلة
- يمكن تغيير الكمية (+/-)
- يمكن حذف منتج
- يعرض الإجمالي (subtotal + delivery)
- زر "إتمام الطلب" واضح
- يعرض "السلة فارغة" إذا فارغة

**Tasks**:
```
Backend:
[ ] GET /cart
[ ] POST /cart/items
[ ] PATCH /cart/items/:productId (update quantity)
[ ] DELETE /cart/items/:productId

Frontend:
[ ] Build CartScreen
[ ] List cart items
[ ] Quantity controls
[ ] Delete item
[ ] Calculate totals
[ ] Empty state
[ ] Navigate to checkout

QA:
[ ] Test add/remove items
[ ] Test quantity changes
[ ] Test total calculation
[ ] Test empty cart
```

---

## Epic 4: Checkout & Orders

### Story 4.1: كمستخدم، أريد إتمام الطلب
**المسار**: `/orders/new`  
**الأولوية**: P0

**Acceptance Criteria**:
- يعرض مراجعة السلة
- يختار طريقة الدفع (نقدي/آجل/إلكتروني)
- يختار العنوان
- يجدول وقت التوصيل
- يؤكد الطலب ≥ الحد الأدنى
- يتحقق من حد الائتمان (إذا آجل)

**Tasks**:
```
Backend:
[ ] POST /orders (create order)
[ ] Validate min order
[ ] Validate credit limit
[ ] Check delivery slots
[ ] Update customer account

Frontend:
[ ] Build CheckoutScreen
[ ] Cart review
[ ] Payment method selection
[ ] Address selection
[ ] Delivery time selection
[ ] Place order button
[ ] Handle edge cases (min order, credit limit, etc)

QA:
[ ] Test all payment methods
[ ] Test min order validation
[ ] Test credit limit
[ ] Test scheduling
```

---

### Story 4.2: كمستخدم، أريد تتبع طلبي
**المسار**: `/orders/:orderId/track`  
**الأولوية**: P1

**Acceptance Criteria**:
- يعرض حالة الطلب real-time
- يعرض موقع المندوب على الخريطة
- يعرض ETA
- يعرض معلومات المندوب (اسم/هاتف)
- زر محادثة مع المندوب

**Tasks**:
```
Backend:
[ ] GET /orders/:orderId/track
[ ] Real-time location updates (Supabase Realtime)
[ ] Calculate ETA

Frontend:
[ ] Build TrackingScreen
[ ] Google Maps integration
[ ] Driver marker on map
[ ] Real-time location listener
[ ] Status timeline
[ ] Driver info card
[ ] Navigate to chat

QA:
[ ] Test real-time updates
[ ] Test map rendering
[ ] Test ETA calculation
```

---

## Epic 5: Edge Cases (8 شاشات)

### Story 5.1: كمستخدم، أريد معرفة ماذا أفعل عند "لا بقالات قريبة"
**المسار**: `/states/no-stores`  
**الأولوية**: P0

**Acceptance Criteria**:
- رسالة واضحة "لا بقالات في نطاق 5كم"
- خيار "تغيير الموقع"
- خيار "توسيع نطاق البحث"
- خيار "إشعار عند التوفر"

**Tasks**:
```
Frontend:
[ ] Build NoStoresScreen
[ ] Clear message
[ ] Change location button
[ ] Expand radius button
[ ] Notify button
[ ] Navigate back to location selection

QA:
[ ] Test all options
[ ] Test notification setup
```

---

### Story 5.2: كمستخدم، أريد معرفة ماذا أفعل عند "تجاوز حد الدين"
**المسار**: `/states/credit-limit`  
**الأولوية**: P0

**Acceptance Criteria**:
- يعرض الدين الحالي + مبلغ الطلب + الحد الأقصى
- يعرض المبلغ الزائد
- خيارات: سداد جزئي / تعديل السلة / تغيير طريقة الدفع

**Tasks**:
```
Frontend:
[ ] Build CreditLimitScreen
[ ] Show breakdown
[ ] Pay now button → payment
[ ] Edit cart button → cart
[ ] Change payment button → checkout

QA:
[ ] Test all options
[ ] Test paymentflow
```

---

*(... وهكذا لباقي الـ Edge Cases)*

---

# القسم 4: خطة البنية (Architecture)

## Modules Structure

```
lib/
├── core/
│   ├── config/
│   │   ├── environment.dart
│   │   ├── theme.dart
│   │   └── routes.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── interceptors.dart
│   │   └── error_handler.dart
│   ├── storage/
│   │   ├── hive_service.dart
│   │   ├── cache_manager.dart
│   │   └── secure_storage.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── formatters.dart
│   │   └── extensions.dart
│   └── widgets/
│       ├── loading_indicator.dart
│       ├── error_view.dart
│       └── empty_state.dart
│
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── data_sources/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── providers/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── stores/
│   ├── products/
│   ├── cart/
│   ├── orders/
│   ├── payments/
│   ├── accounts/
│   ├── loyalty/
│   ├── chat/
│   └── settings/
│
└── main.dart
```

---

## State Management: Riverpod

```dart
// Example: Store Provider
final nearbyStoresProvider = FutureProvider<List<Store>>((ref) async {
  final location = ref.watch(locationProvider);
  final storeRepository = ref.watch(storeRepositoryProvider);
  
  return storeRepository.getNearby(
    lat: location.lat,
    lng: location.lng,
  );
});

// With auto-refresh every 5 minutes
final nearbyStoresProvider = StreamProvider<List<Store>>((ref) {
  return Stream.periodic(Duration(minutes: 5)).asyncMap((_) async {
    final location = ref.watch(locationProvider);
    return ref.read(storeRepositoryProvider).getNearby(location);
  });
});
```

---

## Data Layer + Caching

```dart
class StoreRepository {
  final ApiClient _api;
  final HiveService _cache;
  
  Future<List<Store>> getNearby({double lat, double lng}) async {
    // 1. Try cache first
    final cached = await _cache.get('stores_nearby');
    if (cached != null && !_isStale(cached)) {
      return cached.stores;
    }
    
    // 2. Fetch from API
    try {
      final stores = await _api.get('/stores/nearby', {
        'lat': lat,
        'lng': lng,
      });
      
      // 3. Update cache
      await _cache.set('stores_nearby', stores, ttl: Duration(hours: 1));
      
      return stores;
    } catch (e) {
      // 4. Return stale cache on error
      if (cached != null) return cached.stores;
      rethrow;
    }
  }
}
```

---

## Offline Queue

```dart
class OrderRepository {
  final OfflineQueue _queue;
  
  Future<Order> createOrder(Order order) async {
    if (await _isOnline()) {
      return _api.post('/orders', order.toJson());
    } else {
      // Queue for later
      await _queue.add('create_order', order);
      return order.copyWith(status: OrderStatus.pending_sync);
    }
  }
}

// Background sync
class OfflineQueue {
  void startSync() {
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _processPendingItems();
      }
    });
  }
  
  Future<void> _processPendingItems() async {
    final items = await _hive.box('queue').values;
    for (var item in items) {
      try {
        await _execute(item);
        await _hive.box('queue').delete(item.id);
      } catch (e) {
        // Retry later
      }
    }
  }
}
```

---

## Error Handling Pattern

```dart
sealed class Result<T> {
  const Result();
}

class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends Result<T> {
  final AppException error;
  const Failure(this.error);
}

// Usage
final result = await storeRepository.getNearby();
result.when(
  success: (stores) => _showStores(stores),
  failure: (error) => _showError(error),
);
```

---

## Analytics & Logging

```dart
class AnalyticsService {
  void logScreenView(String screenName) {
    FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }
  
  void logEvent(String event, Map<String, dynamic> params) {
    FirebaseAnalytics.instance.logEvent(name: event, parameters: params);
  }
  
  void logPurchase(Order order) {
    FirebaseAnalytics.instance.logPurchase(
      value: order.total,
      currency: 'SAR',
      items: order.items.map((i) => AnalyticsEventItem(...)).toList(),
    );
  }
}
```

---

## Feature Flags

```dart
class FeatureFlags {
  static const enableAIAssistant = false; // P2
  static const enableVoiceOrdering = false; // Future
  static const enableBNPL = false; // Future
  
  static bool isEnabled(String feature) {
    // Can be controlled from Firebase Remote Config
    return RemoteConfig.instance.getBool(feature);
  }
}
```

---

# القسم 5: خطة الاختبار (QA)

## Critical Paths (من PRD)

### Path 1: Happy Path
```
Signup → Browse Store → Add to Cart → Checkout → 
Pay (Credit) → Track Order → Rate Driver → Complete
```

**Test Cases**:
1. ✅ New user can signup
2. ✅ Can see nearby stores
3. ✅ Can browse products
4. ✅ Can add to cart
5. ✅ Can checkout with credit payment
6. ✅ Order appears in orders list
7. ✅ Can track order real-time
8. ✅ Can rate driver after delivery
9. ✅ Points are awarded

---

### Path 2: Credit Path
```
Browse → Cart → Credit Limit Exceeded → 
Pay Partial → Order Complete
```

**Test Cases**:
1. ✅ System detects credit limit exceeded
2. ✅ Shows correct credit limit screen
3. ✅ Can pay partial amount
4. ✅ Order proceeds with remaining credit
5. ✅ Account balance updates correctly

---

### Path 3: Error Recovery
```
Checkout → Payment Pending → Timeout → Refund
```

**Test Cases**:
1. ✅ Payment shows pending state
2. ✅ Auto-refresh works
3. ✅ Timeout handled gracefully
4. ✅ Refund initiated
5. ✅ User notified

---

### Path 4: Substitution
```
Order → Item Unavailable → Accept Substitute → Deliver
```

**Test Cases**:
1. ✅ Notification received
2. ✅ Can view substitution options
3. ✅ Can accept/reject
4. ✅ Price difference shown
5. ✅ Order updated correctly

---

## Test Matrix للشاشات P0

| Screen | Happy Path | Edge Case | Offline | Performance |
|--------|-----------|-----------|---------|-------------|
| `/home` | ✅ | No stores | ✅ | Image load < 500ms |
| `/stores/:id` | ✅ | Store closed | ✅ | < 300ms |
| `/cart` | ✅ | Empty cart | ✅ | Instant |
| `/orders/new` | ✅ | Min order, Credit limit | - | < 500ms |
| `/orders/:id/track` | ✅ | GPS失败 | - | Real-time |
| `/payments/pending` | ✅ | Timeout | - | Auto-refresh 5s |

---

## Smoke Tests قبل الإطلاق

```
[ ] App launches successfully
[ ] Can login
[ ] Can see stores
[ ] Can browse products
[ ] Images load
[ ] Can add to cart
[ ] Can checkout
[ ] Payment works (test mode)
[ ] Push notifications received
[ ] Dark mode works
[ ] Arabic RTL correct
[ ] Offline mode works
[ ] No crashes in 30 min session
```

---

# القسم 6: الجدول الزمني (12 أسبوع)

## أسبوع 1: Foundation
**الهدف**: بنية جاهزة

**المخرجات**:
- ✅ Flutter project setup
- ✅ Supabase configured
- ✅ AlhaiDesignSystem integrated
- ✅ Routing working
- ✅ Authentication skeleton

**Milestone**: App runs, can navigate, dark mode works

---

## أسبوع 2: Auth + Location
**الهدف**: المستخدم يسجل ويختار موقع

**المخرجات**:
- ✅ Onboarding
- ✅ Signup/Login
- ✅ Location permissions
- ✅ Home screen (stores list)

**Milestone**: Can signup and see nearby stores

---

## أسبوع 3: Stores & Products
**الهدف**: تصفح كامل

**المخرجات**:
- ✅ Store details
- ✅ Product list (with images from CDN)
- ✅ Product search
- ✅ Filters

**Milestone**: Can browse products with images loading fast

---

## أسبوع 4: Cart & Checkout
**الهدف**: الطلب الأساسي

**المخرجات**:
- ✅ Cart management
- ✅ Checkout flow
- ✅ Delivery scheduling
- ✅ Payment method selection

**Milestone**: Can place an order (mock payment)

---

## أسبوع 5: Orders & Tracking
**الهدف**: تتبع كامل

**المخرجات**:
- ✅ Orders list
- ✅ Order details
- ✅ Real-time tracking
- ✅ Push notifications

**Milestone**: Can track orders real-time

---

## أسبوع 6: Edge Cases
**الهدف**: معالجة جميع الحالات الحرجة

**المخرجات**:
- ✅ All 8 edge cases implemented
- ✅ Error handling robust
- ✅ User feedback clear

**Milestone**: App handles all error scenarios gracefully

---

## أسبوع 7: Payments & Debts
**الهدف**: نظام الدفع كامل

**المخرجات**:
- ✅ Payment integration (real)
- ✅ 3DS support
- ✅ Refunds
- ✅ Debt management
- ✅ Transaction history

**Milestone**: Can pay with real cards

---

## أسبوع 8: Loyalty & Chat
**الهدف**: التفاعل المحسّن

**المخرجات**:
- ✅ Loyalty points
- ✅ Challenges
- ✅ Chat with driver
- ✅ Translation
- ✅ Ratings

**Milestone**: Chat works real-time, points calculate

---

## أسبوع 9: Settings & Support
**الهدف**: تحكم كامل

**المخرجات**:
- ✅ Profile management
- ✅ Addresses
- ✅ Payment methods
- ✅ Preferences (8 settings)
- ✅ Support tickets

**Milestone**: All settings functional

---

## أسبوع 10: Performance & Offline
**الهدف**: تطبيق سريع جداً

**المخرجات**:
- ✅ Offline-first working
- ✅ Image caching optimized
- ✅ Navigation smooth (< 100ms)
- ✅ Background sync working

**Milestone**: App feels instant, works offline

---

## أسبوع 11: QA & Polishing
**الهدف**: تطبيق مستقر

**المخرجات**:
- ✅ All critical paths tested
- ✅ Bugs fixed
- ✅ Performance benchmarks met
- ✅ Animations polished

**Milestone**: Zero critical bugs

---

## أسبوع 12: Release Prep
**الهدف**: جاهز للإطلاق

**المخرجات**:
- ✅ App Store assets
- ✅ Privacy policy
- ✅ Terms & conditions
- ✅ Beta testing done
- ✅ Production deployment

**Milestone**: Live on stores!

---

# القسم 7: مخرجات جاهزة للفريق

## أول أسبوعين - تفصيلي

### الأسبوع 1 - يومي

#### اليوم 1 (الإثنين)
**AM**:
- [ ] Create Flutter project: `flutter create alhai_customer_app`
- [ ] Setup folder structure (core/features)
- [ ] Add dependencies to pubspec.yaml (see below)
- [ ] Create `.env` files (dev/staging/prod)

**PM**:
- [ ] Configure Supabase client
- [ ] Test connection to Supabase
- [ ] Setup Hive (init + boxes)
- [ ] Create base models (Customer, Store)

---

#### اليوم 2 (الثلاثاء)
**AM**:
- [ ] Integrate AlhaiDesignSystem package
- [ ] Test design system components
- [ ] Setup dark/light themes
- [ ] Configure localization (ar/en)

**PM**:
- [ ] Setup Riverpod (providers structure)
- [ ] Configure GoRouter (routes.dart)
- [ ] Create main navigation shell
- [ ] Test navigation between dummy screens

---

#### اليوم 3 (الأربعاء)
**AM**:
- [ ] Setup Cloudflare R2 credentials
- [ ] Test image loading from CDN
- [ ] Configure CachedNetworkImage
- [ ] Create ProductImage widget

**PM**:
- [ ] Create API client (Dio)
- [ ] Add interceptors (auth/logging/error)
- [ ] Setup Sentry
- [ ] Test error tracking

---

#### اليوم 4 (الخميس)
**AM**:
- [ ] Build Onboarding screen (3 slides)
- [ ] Build Signup screen (Phone input)
- [ ] Build OTP screen

**PM**:
- [ ] Implement POST /auth/send-otp
- [ ] Implement POST /auth/verify-otp
- [ ] Test signup flow end-to-end
- [ ] Save token to secure storage

---

#### اليوم 5 (الجمعة)
**AM**:
- [ ] Build Login screen
- [ ] Implement session management
- [ ] Test auto-login on app launch
- [ ] Test logout flow

**PM**:
- [ ] Code review
- [ ] Fix any critical bugs
- [ ] Update documentation
- [ ] Sprint retrospective

---

### الأسبوع 2 - يومي

#### اليوم 6 (الأحد)
**AM**:
- [ ] Request location permissions
- [ ] Get GPS location
- [ ] Build location selector screen
- [ ] Handle permission denied

**PM**:
- [ ] Implement GET /stores/nearby
- [ ] Build Home screen UI
- [ ] Display stores list
- [ ] Test with different locations

---

#### اليوم 7 (الإثنين)
**AM**:
- [ ] Build Store details screen
- [ ] Implement GET /stores/:id
- [ ] Display customer account
- [ ] Display recent orders

**PM**:
- [ ] Add pull-to-refresh
- [ ] Handle store closed state
- [ ] Test navigation flow
- [ ] Optimize image loading

---

#### اليوم 8 (الثلاثاء)
**AM**:
- [ ] Build Product list screen
- [ ] Implement GET /stores/:id/products
- [ ] Display products grid
- [ ] Add search bar

**PM**:
- [ ] Implement lazy loading (pagination)
- [ ] Add category filters
- [ ] Test image caching
- [ ] Performance testing

---

#### اليوم 9 (الأربعاء)
**AM**:
- [ ] Implement add to cart
- [ ] POST /cart/items
- [ ] Update cart badge
- [ ] Show success feedback

**PM**:
- [ ] Build Cart screen
- [ ] Display cart items
- [ ] Implement quantity controls
- [ ] Calculate totals

---

#### اليوم 10 (الخميس)
**AM**:
- [ ] Test entire flow: Browse → Cart
- [ ] Fix any bugs
- [ ] Code review

**PM**:
- [ ] Demo to stakeholders
- [ ] Gather feedback
- [ ] Plan Week 3

---

## قرارات يجب تثبيتها قبل البدء

### 1. Technical Decisions

#### State Management:
- **القرار**: Riverpod
- **البديل**: Bloc, GetX
- **يجب تثبيته**: اليوم 1

#### Routing:
- **القرار**: GoRouter
- **البديل**: Auto Route, Navigator 2.0
- **يجب تثبيته**: اليوم 2

#### Local Database:
- **القرار**: Hive
- **البديل**: Isar, SQLite
- **يجب تثبيته**: اليوم 1

---

### 2. Third-Party Services

#### Maps Provider:
- **الخيارات**: Google Maps, Mapbox, Apple Maps
- **التكلفة**: Google Maps = $7/1000 requests
- **يجب تثبيته**: قبل أسبوع 2

#### Push Notifications:
- **الخيارات**: Firebase Cloud Messaging, OneSignal
- **القرار المقترح**: FCM (مجاني)
- **يجب تثبيته**: قبل أسبوع 5

#### SMS Provider (OTP):
- **الخيارات**: Twilio, AWS SNS, Unifonic
- **التكلفة**: ~0.05 SAR per SMS
- **يجب تثبيته**: قبل أسبوع 1

#### Payment Gateway:
- **الخيارات**: Stripe, Tap, Moyasar, Hyperpay
- **المتطلبات**: 3DS support, Apple Pay, Mada
- **يجب تثبيته**: قبل أسبوع 7

#### Translation API:
- **الخيارات**: Google Translate, DeepL, AWS Translate
- **التكلفة**: Google = $20/million chars
- **يجب تثبيته**: قبل أسبوع 8

---

### 3. Environment Setup

#### Environments:
```
Development:
- Supabase URL: https://dev.alhai.sa
- API URL: https://dev-api.alhai.sa
- CDN: https://dev-cdn.alhai.sa

Staging:
- Supabase URL: https://staging.alhai.sa
- API URL: https://staging-api.alhai.sa
- CDN: https://staging-cdn.alhai.sa

Production:
- Supabase URL: https://alhai.sa
- API URL: https://api.alhai.sa
- CDN: https://cdn.alhai.sa
```

**يجب تثبيته**: اليوم 1

---

### 4. Naming Conventions

#### Routes:
```
✅ Correct:
/stores/:storeId
/orders/:orderId
/payments/:paymentId

❌ Wrong:
/store/:id
/order/:id
/payment/:id
```

#### API Endpoints:
```
✅ Correct:
GET /stores/nearby
POST /orders
GET /orders/:orderId

❌ Wrong:
GET /getNearbyStores
POST /createOrder
```

#### Git Branches:
```
feature/auth-signup
feature/stores-list
fix/cart-total-calculation
hotfix/payment-crash
```

**يجب تثبيته**: اليوم 1

---

### 5. Permissions

#### iOS (Info.plist):
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>نحتاج موقعك لعرض البقالات القريبة</string>

<key>NSCameraUsageDescription</key>
<string>نحتاج الكاميرا لإضافة صور للشكاوى</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>نحتاج الوصول للصور</string>
```

#### Android (AndroidManifest.xml):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.CAMERA" />
```

**يجب تثبيته**: اليوم 1

---

### 6. Analytics Events

#### تثبيت الـ Events المهمة:
```
- screen_view (automatic)
- signup_completed
- login_completed
- store_viewed
- product_viewed
- add_to_cart
- checkout_started
- order_placed
- payment_completed
- order_delivered
- driver_rated
```

**يجب تثبيته**: أسبوع 1

---

### 7. Feature Flags

```dart
class FeatureFlags {
  // P0 - Always ON
  static const enableAuth = true;
  static const enableOrders = true;
  static const enablePayments = true;
  
  // P1 - Can be toggled
  static const enableChat = true;
  static const enableLoyalty = true;
  static const enableRatings = true;
  
  // P2 - OFF initially
  static const enableReports = false;
  static const enableAI = false;
  static const enablePromos = false;
}
```

**يجب تثبيته**: أسبوع 1

---

## Dependencies المطلوبة (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3
  
  # Dependency Injection (like pos_app)
  get_it: ^7.6.4
  injectable: ^2.3.2
  
  # Routing
  go_router: ^13.0.0
  
  # UI
  alhai_design_system:
    path: ../alhai_design_system
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  
  # Backend
  supabase_flutter: ^2.3.4
  dio: ^5.4.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Location
  geolocator: ^11.0.0
  google_maps_flutter: ^2.5.3
  
  # Utils
  intl: ^0.19.0
  connectivity_plus: ^5.0.2
  permission_handler: ^11.2.0
  
  # Analytics
  firebase_core: ^2.24.2
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9
  firebase_messaging: ^14.7.10
  sentry_flutter: ^7.14.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.7
  injectable_generator: ^2.4.1
  flutter_lints: ^3.0.1
```

---

**📅 آخر تحديث**: 2026-01-15  
**✅ الحالة**: Execution Plan Ready  
**🚀 الخطوة التالية**: موافقة القرارات المطلوبة + البدء!
