# POS Vertical Slice Mapping

**Version:** 1.0.0  
**Date:** 2026-01-19

---

## تقسيم العمل (A/B Split)

```
┌─────────────────────────────────────────────────────────┐
│                    POS App                               │
├─────────────────────────┬───────────────────────────────┤
│     Device A            │        Device B               │
│     Sales Slice         │        Operations Slice       │
├─────────────────────────┼───────────────────────────────┤
│ • Login                 │ • Products List               │
│ • Store Select          │ • Product Detail              │
│ • Quick Sale            │ • Add/Edit Product            │
│ • Product Search        │ • Inventory Adjust            │
│ • Cart                  │ • Suppliers List              │
│ • Payment               │ • Daily Report                │
│ • Receipt               │                               │
├─────────────────────────┴───────────────────────────────┤
│                    Shared                                │
│           • Splash • Home Dashboard • Settings           │
└─────────────────────────────────────────────────────────┘
```

---

## Device A: Sales Slice

### Owner Responsibility
البيع من البداية للنهاية

### Screens (7)
| Screen | Priority | Dependencies |
|--------|----------|--------------|
| Login | P0 | AuthRepository |
| Store Select | P0 | StoresRepository |
| Quick Sale | P0 | ProductsRepository |
| Product Search | P0 | ProductsRepository |
| Cart | P0 | Local State |
| Payment | P0 | OrdersRepository |
| Receipt | P0 | None |

### File Ownership
```
lib/
├── features/
│   ├── auth/           ← A owns
│   │   ├── bloc/
│   │   ├── pages/
│   │   └── widgets/
│   ├── store_select/   ← A owns
│   ├── sales/          ← A owns
│   │   ├── quick_sale/
│   │   ├── product_search/
│   │   └── widgets/
│   ├── cart/           ← A owns
│   │   ├── bloc/
│   │   ├── pages/
│   │   └── widgets/
│   └── payment/        ← A owns
│       ├── bloc/
│       ├── pages/
│       └── widgets/
```

### Repositories Used
- `AuthRepository`
- `StoresRepository`
- `ProductsRepository` (read only)
- `OrdersRepository`

### State Management
```dart
// A owns these Blocs/Cubits
AuthBloc
StoreSelectCubit
SalesBloc
CartCubit
PaymentBloc
```

### APIs Used
| Endpoint | Screen |
|----------|--------|
| `POST /auth/send-otp` | Login |
| `POST /auth/verify-otp` | Login |
| `GET /stores/my` | Store Select |
| `GET /products/barcode/:barcode?store_id=xxx` | Quick Sale |
| `GET /products?store_id=xxx&search=xxx&category_id=xxx` | Product Search |
| `POST /orders` (with `Idempotency-Key`) | Payment |

---

## Device B: Operations Slice

### Owner Responsibility
إدارة المنتجات والمخزون والتقارير

### Screens (6)
| Screen | Priority | Dependencies |
|--------|----------|--------------|
| Products List | P1 | ProductsRepository |
| Product Detail | P1 | ProductsRepository |
| Add/Edit Product | P1 | ProductsRepository |
| Inventory Adjust | P1 | InventoryRepository |
| Suppliers List | P2 | SuppliersRepository |
| Daily Report | P1 | ReportsRepository |

### File Ownership
```
lib/
├── features/
│   ├── products/       ← B owns
│   │   ├── bloc/
│   │   ├── pages/
│   │   │   ├── products_list_page.dart
│   │   │   ├── product_detail_page.dart
│   │   │   └── product_form_page.dart
│   │   └── widgets/
│   ├── inventory/      ← B owns
│   │   ├── bloc/
│   │   ├── pages/
│   │   └── widgets/
│   ├── suppliers/      ← B owns
│   └── reports/        ← B owns
```

### Repositories Used
- `ProductsRepository` (full CRUD)
- `InventoryRepository`
- `SuppliersRepository`
- `ReportsRepository`

### State Management
```dart
// B owns these Blocs/Cubits
ProductsBloc
ProductDetailCubit
InventoryCubit
SuppliersBloc
ReportsBloc
```

### APIs Used
| Endpoint | Screen |
|----------|--------|
| `GET /products?store_id=xxx` | Products List |
| `GET /products/:id` | Product Detail |
| `POST /products` | Add Product |
| `PATCH /products/:id` | Edit Product |
| `DELETE /products/:id` | Product Detail |
| `POST /inventory/adjust` (with `Idempotency-Key`) | Inventory Adjust |
| `GET /suppliers?store_id=xxx` | Suppliers List |
| `GET /reports/daily-summary?store_id=xxx&date=xxx` | Daily Report |

---

## Shared (Both A & B)

### Screens
| Screen | Who Creates | Who Can Modify |
|--------|-------------|----------------|
| Splash | A | Both (coordinate) |
| Home Dashboard | A | Both (coordinate) |
| Settings | B | Both (coordinate) |

### Shared Files (Coordinate Before Edit!)
```
lib/
├── core/               ← Coordinate
│   ├── app.dart
│   ├── routes.dart
│   ├── di.dart
│   └── theme.dart
├── shared/             ← Coordinate
│   ├── widgets/
│   └── utils/
└── features/
    ├── splash/         ← A creates
    ├── home/           ← A creates
    └── settings/       ← B creates
```

---

## Dependency Map

```
                    alhai_core
                        │
         ┌──────────────┼──────────────┐
         │              │              │
    AuthRepo      ProductsRepo    ReportsRepo
         │              │              │
         └──────┬───────┴──────┬───────┘
                │              │
            Device A       Device B
```

### No Cross-Slice Dependencies During Development
- A لا يستدعي B's Blocs
- B لا يستدعي A's Blocs
- التواصل فقط عبر shared state (current user, current store)

---

## Integration Points

### Store Context (مصدر الحقيقة الموحد)

> **أين يُخزن؟** `lib/core/session/`  
> **من يكتب؟** A فقط (Login + Store Select)  
> **من يقرأ؟** A و B (عبر Stream)

**Dependencies:**
- `rxdart` (BehaviorSubject)
- `shared_preferences` (persistence)

**Lifecycle:**
- Singleton في DI (GetIt)
- يُغلق عند app termination فقط
- **لا dispose أثناء التشغيل**

```dart
// lib/core/session/app_session.dart
// يُنشئ مرة واحدة في Sprint 1 - متفق عليه بين A و B

abstract class AppSession {
  // Write (A only)
  Future<void> setUser(User user);
  Future<void> setStore(Store store);
  Future<void> clear();
  
  // Read (Both A & B)
  Stream<User?> get user$;
  Stream<Store?> get store$;
  User? get currentUser;
  Store? get currentStore;
  String? get currentStoreId;
  
  // Lifecycle
  Future<void> dispose();
}
```

**التنفيذ:**
```dart
// lib/core/session/app_session_impl.dart
@LazySingleton(as: AppSession)
class AppSessionImpl implements AppSession {
  final BehaviorSubject<User?> _user = BehaviorSubject.seeded(null);
  final BehaviorSubject<Store?> _store = BehaviorSubject.seeded(null);
  final SharedPreferences _prefs;
  
  AppSessionImpl(this._prefs) {
    _loadFromPrefs();
  }
  
  // A writes
  @override
  Future<void> setUser(User user) async {
    _user.add(user);
    await _prefs.setString('user', jsonEncode(user.toJson()));
  }
  
  // B reads
  @override
  String? get currentStoreId => _store.value?.id;
  
  // Cleanup (app exit only)
  @override
  Future<void> dispose() async {
    await _user.close();
    await _store.close();
  }
}
```

**قواعد صارمة:**
- A: يستخدم `setUser()`, `setStore()`, `clear()`
- B: يستخدم `currentStoreId`, `store$`, `currentUser` **قراءة فقط**
- B **لا يستدعي** StoreSelectCubit أو AuthBloc
- ⚠️ **يُمنع استدعاء `dispose()` داخل features/Blocs/Widgets**
- **الاستدعاء الوحيد**: داخل `main()` عند `WidgetsBindingObserver.didChangeAppLifecycleState(AppLifecycleState.detached)`

### Navigation
```dart
// A creates these routes
/login
/stores
/sale
/cart
/payment

// B creates these routes
/products
/products/:id
/inventory
/suppliers
/reports
```

---

## Development Order

### Sprint 1 (Core MVP)
| Device A | Device B |
|----------|----------|
| Login | Products List |
| Store Select | Product Detail |
| Quick Sale | Inventory Adjust |
| Cart | |
| Payment | |

### Sprint 2 (Complete)
| Device A | Device B |
|----------|----------|
| Receipt polish | Add/Edit Product |
| | Suppliers List |
| | Daily Report |

### Sprint 3 (Integration)
| Both |
|------|
| Home Dashboard |
| Settings |
| End-to-end testing |

---

## Conflict Prevention Checklist

Before each commit:
- [ ] Am I only editing files in my slice?
- [ ] If editing shared files, did I coordinate?
- [ ] Does my code compile?
- [ ] Are my tests passing?

---

*Ready for Development*
