# ⚡ Customer App - استراتيجية الأداء والسرعة

**التاريخ**: 2026-01-15  
**المرجع**: PRD_FINAL.md + R2 Image Storage  
**الهدف**: تطبيق سريع جداً حتى مع اتصال ضعيف

---

## 🎯 المحاور الثلاثة للأداء

### 1️⃣ سرعة تحميل الصور
### 2️⃣ التنقل السريع بين الشاشات  
### 3️⃣ حفظ البيانات والعمل Offline

---

## 📸 المحور الأول: سرعة تحميل الصور

### 🔧 الحل المطبق: Cloudflare R2 + CDN

#### البنية التحتية (موجودة في R2_SETUP_INSTRUCTIONS.md):
```
Product Image Upload
       ↓
Supabase Edge Function
       ↓
Resize to 3 sizes + WebP
       ↓
Cloudflare R2 Bucket
       ↓
Cloudflare CDN (Cache)
       ↓
Mobile App (Cached)
```

---

### 📊 الأحجام المستخدمة

#### حسب السياق:
```dart
// في قائمة المنتجات (Product List)
thumbnail: 200x200 (~15 KB)

// في تفاصيل المنتج (Product Details)
medium: 500x500 (~50 KB)

// في معاينة الصورة (Full Screen Preview)
large: 1200x1200 (~150 KB)
```

**النتيجة**: توفير **80-90%** من bandwidth

---

### ⚡ استراتيجيات التحميل

#### 1. Progressive Loading
```dart
class ProductImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: product.thumbnailUrl,
      placeholder: (context, url) => 
        // Show blurred thumbnail FIRST
        Image.network(
          product.thumbnailUrl + '?blur=20&w=50',
          fit: BoxFit.cover,
        ),
      imageBuilder: (context, imageProvider) =>
        // Then show full quality
        FadeInImage(
          placeholder: imageProvider,
          image: NetworkImage(product.mediumUrl),
        ),
    );
  }
}
```

**النتيجة**: المستخدم يرى شيئاً **فوراً** (50ms)

---

#### 2. Prefetching (التحميل المسبق)
```dart
// عند دخول قائمة المنتجات، حمّل الشاشة التالية
void _prefetchNextPage() {
  for (var product in nextPageProducts) {
    // تحميل صامت للصور قبل أن يحتاجها المستخدم
    precacheImage(
      NetworkImage(product.thumbnailUrl),
      context,
    );
  }
}

// عند hover/scroll قرب منتج
void _onProductNearViewport(Product product) {
  // حمّل الصورة medium مسبقاً
  precacheImage(
    NetworkImage(product.mediumUrl),
    context,
  );
}
```

**النتيجة**: صور جاهزة **قبل** أن يطلبها المستخدم

---

#### 3. Lazy Loading (التحميل الكسول)
```dart
ListView.builder(
  itemCount: products.length,
  itemBuilder: (context, index) {
    // تحميل الصور فقط للمنتجات المرئية
    return VisibilityDetector(
      key: Key(products[index].id),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.2) {
          _loadProductImage(products[index]);
        }
      },
      child: ProductCard(products[index]),
    );
  },
)
```

**النتيجة**: لا نحمّل صور غير مرئية

---

#### 4. Caching Strategy (استراتيجية التخزين)
```dart
CachedNetworkImage(
  imageUrl: url,
  cacheManager: CustomCacheManager(
    Config(
      'productImages',
      stalePeriod: Duration(days: 7),  // صلاحية 7 أيام
      maxNrOfCacheObjects: 200,        // حد أقصى 200 صورة
    ),
  ),
)

// مسح الكاش القديم تلقائياً
void cleanOldCache() {
  CacheManager().emptyCache();  // كل 30 يوم
}
```

**النتيجة**:
- ✅ فتح قائمة منتجات مرتين = تحميل **فوري** (0 network)
- ✅ التطبيق يعمل offline للصور المحفوظة

---

### 🎨 Skeleton Screens (الهياكل الوهمية)

بدلاً من Spinner، نعرض شكل الصورة:

```dart
Widget _buildSkeleton() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300],
    highlightColor: Colors.grey[100],
    child: Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
```

**النتيجة**: التطبيق يبدو "سريع" حتى أثناء التحميل

---

### 📈 المقاييس المتوقعة (Metrics)

| السيناريو | الوقت |
|-----------|-------|
| **أول صورة** (First Image) | < 100ms |
| **قائمة 20 منتج** (Product List) | < 500ms |
| **فتح تفاصيل** (من الكاش) | **فوري** (0ms) |
| **فتح تفاصيل** (أول مرة) | < 300ms |

---

## 🚀 المحور الثاني: التنقل السريع بين الشاشات

### ⚡ الاستراتيجيات

#### 1. Route Preloading (التحميل المسبق للمسارات)
```dart
// عند دخول Home
class HomeScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    
    // حمّل البيانات المتوقعة مسبقاً
    _prefetchCommonRoutes();
  }
  
  void _prefetchCommonRoutes() {
    // المستخدم غالباً سيفتح أول بقالة
    if (nearbyStores.isNotEmpty) {
      final firstStore = nearbyStores.first;
      
      // حمّل منتجات البقالة في الخلفية
      StoreRepository().getProducts(firstStore.id);
      
      // حمّل حساب العميل
      AccountRepository().getAccount(firstStore.id);
    }
  }
}
```

**النتيجة**: لما يضغط على البقالة، **البيانات جاهزة**

---

#### 2. Optimistic Navigation (التنقل المتفائل)
```dart
void onStoreCardTap(Store store) {
  // انتقل فوراً للشاشة (بدون انتظار)
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => StoreDetailsScreen(
        store: store,
        // عرض بيانات من الكاش أولاً
        initialData: _getCachedStoreData(store.id),
      ),
    ),
  );
  
  // حمّل البيانات الجديدة في الخلفية
  _refreshStoreData(store.id).then((freshData) {
    // حدّث الشاشة بهدوء
    setState(() => storeData = freshData);
  });
}
```

**النتيجة**: 
- ✅ شاشة تفتح **فوراً** (بيانات قديمة)
- ✅ تتحدث بهدوء في الخلفية (بيانات جديدة)

---

#### 3. Hero Animations (انتقالات سلسة)
```dart
// في قائمة البقالات
Hero(
  tag: 'store-${store.id}',
  child: StoreCard(store),
)

// في تفاصيل البقالة
Hero(
  tag: 'store-${store.id}',
  child: StoreHeader(store),
)
```

**النتيجة**: انتقال **سينمائي** يخفي زمن التحميل

---

#### 4. State Management الذكي

```dart
// استخدام Provider/Riverpod للحفاظ على الحالة
final storeProvider = StateNotifierProvider<StoreNotifier, StoreState>(
  (ref) => StoreNotifier(),
);

// عند الرجوع من تفاصيل البقالة
// الـ Home Screen **كما هي** (لا إعادة بناء)
Navigator.pop(context);  // فوري!
```

**النتيجة**: الرجوع = **فوري** (0ms)

---

#### 5. Bottom Navigation الذكية

```dart
class MainScreen extends StatefulWidget {
  // احتفظ بـ state كل التابات
  final List<Widget> _pages = [
    HomeScreen(),
    OrdersScreen(),
    AccountsScreen(),
    ProfileScreen(),
  ];
  
  final PageController _pageController = PageController();
  
  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageController,
      children: _pages,
      // عند تغيير التاب، الصفحة موجودة = فوري
    );
  }
}
```

**النتيجة**: التنقل بين التابات = **فوري** (كل شيء محمّل)

---

### 📈 المقاييس المتوقعة

| الإجراء | الوقت |
|---------|-------|
| **فتح بقالة** (من Home) | < 100ms |
| **الرجوع** (Back) | **فوري** (16ms) |
| **تغيير Tab** | **فوري** (16ms) |
| **Scroll** في قائمة | **سلس** (60 FPS) |

---

## 💾 المحور الثالث: حفظ البيانات والعمل Offline

### 🎯 الاستراتيجية: Offline-First Architecture

```
User Action
    ↓
Local DB (SQLite/Hive)  ← قراءة فورية
    ↓
Show Data (Instant)
    ↓
Sync with Server (Background)
    ↓
Update Local DB (Silent)
```

---

### 📦 ما نحفظه محلياً

#### 1. بيانات حرجة (Critical Data)
```dart
// قائمة البقالات القريبة
Hive.box('stores').put('nearby', stores);

// حسابات العميل
Hive.box('accounts').put('all', accounts);

// آخر 20 طلب
Hive.box('orders').put('recent', orders);

// المنتجات المحفوظة
Hive.box('favorites').put('items', favoriteProducts);
```

**الصلاحية**: 
- البقالات: 1 ساعة
- الحسابات: 5 دقائق
- الطلبات: 30 ثانية
- المفضلة: دائم

---

#### 2. الصور (Images)
```dart
// كل صورة تُعرض = تُحفظ تلقائياً
CachedNetworkImage(
  // يحفظ في app storage
  // الحجم الأقصى: 100 MB
  // الصلاحية: 7 أيام
)
```

---

#### 3. User Preferences
```dart
// الإعدادات الشخصية
SharedPreferences.setString('language', 'ar');
SharedPreferences.setBool('darkMode', true);
SharedPreferences.setString('defaultAddress', addressId);

// Substitution Preferences
SharedPreferences.setString('substitutionPolicy', 'ask_me');
```

---

### ⚡ Smart Sync Strategy

#### 1. عند فتح التطبيق
```dart
void onAppLaunch() async {
  // اعرض البيانات المحفوظة **فوراً**
  final cachedStores = await Hive.box('stores').get('nearby');
  setState(() => stores = cachedStores);
  
  // حدّث في الخلفية
  final freshStores = await StoreRepository().getNearby();
  
  if (freshStores != cachedStores) {
    // حدّث بهدوء
    setState(() => stores = freshStores);
    Hive.box('stores').put('nearby', freshStores);
  }
}
```

**النتيجة**: 
- ✅ فتح التطبيق = **بيانات فورية** (من الكاش)
- ✅ تحديث صامت في الخلفية

---

#### 2. Offline Queue (طابور الإجراءات)

```dart
// عند إنشاء طلب وأنت offline
void createOrderOffline(Order order) {
  // احفظ الطلب محلياً
  Hive.box('pending_orders').add(order);
  
  // اعرض للمستخدم أنه "قيد المعالجة"
  showSuccess('تم حفظ طلبك، سيُرسل عند الاتصال');
  
  // عند عودة الإنترنت
  onInternetRestored(() async {
    final pendingOrders = Hive.box('pending_orders').values;
    
    for (var order in pendingOrders) {
      try {
        await OrderRepository().create(order);
        Hive.box('pending_orders').delete(order.id);
      } catch (e) {
        // إعادة المحاولة لاحقاً
      }
    }
  });
}
```

**النتيجة**: 
- ✅ المستخدم يطلب حتى لو offline
- ✅ يُرسل تلقائياً عند عودة النت

---

#### 3. Smart Refresh (التحديث الذكي)

```dart
// لا نحدّث كل شيء، فقط ما تغيّر
void refreshData() async {
  // تحقق من آخر تحديث
  final lastSync = prefs.getInt('lastSync');
  final now = DateTime.now().millisecondsSinceEpoch;
  
  if (now - lastSync < 5 * 60 * 1000) {
    // آخر تحديث قبل أقل من 5 دقائق
    // لا داعي للتحديث
    return;
  }
  
  // حدّث فقط البيانات المتغيرة
  final updates = await API.getUpdates(since: lastSync);
  
  // طبّق التحديثات محلياً
  _applyUpdates(updates);
  
  prefs.setInt('lastSync', now);
}
```

---

### 🔄 Pull-to-Refresh

```dart
RefreshIndicator(
  onRefresh: () async {
    // حدّث البيانات من السيرفر
    await _refreshStores();
    
    // حدّث الكاش
    await _updateCache();
  },
  child: StoresList(),
)
```

---

### 📈 المقاييس المتوقعة

| السيناريو | الوقت | ملاحظات |
|-----------|-------|----------|
| **فتح التطبيق** | < 200ms | من الكاش |
| **تحديث البيانات** | 1-2 ثواني | في الخلفية |
| **طلب offline** | **فوري** | يُرسل لاحقاً |
| **استعادة طلب offline** | تلقائي | عند عودة النت |

---

## 🎯 الملخص التنفيذي

### الصور:
- ✅ 3 أحجام (thumbnail/medium/large)
- ✅ CDN Caching عالمي
- ✅ Progressive + Lazy Loading
- ✅ Prefetching ذكي

### التنقل:
- ✅ Route Preloading
- ✅ Optimistic Navigation
- ✅ Hero Animations
- ✅ State يبقى حي

### البيانات:
- ✅ Offline-First
- ✅ Smart Caching (Hive/SQLite)
- ✅ Background Sync
- ✅ Offline Queue

---

## 📊 النتيجة النهائية المتوقعة

### السرعة:
- **Cold Start**: < 1 ثانية
- **Warm Start**: < 200ms
- **التنقل**: **فوري** (< 100ms)
- **تحميل صور**: < 300ms

### الموثوقية:
- ✅ يعمل 100% offline (بيانات محفوظة)
- ✅ Sync تلقائي عند عودة النت
- ✅ لا فقدان بيانات

### تجربة المستخدم:
- ⚡ **يحس التطبيق سريع جداً**
- ⚡ لا توقف/انتظار
- ⚡ انتقالات سلسة

---

**📅 آخر تحديث**: 2026-01-15  
**🎯 الهدف**: تطبيق سريع مثل Instagram/WhatsApp  
**✅ الحالة**: Strategy Ready for Implementation
