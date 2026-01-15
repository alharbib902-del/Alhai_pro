# 💻 POS App - خطة البرمجة اليومية (تابع)

## Day 6-10 + Sprint 2 + Checklists

---

### 🔹 Day 6-10: تابع Sprint 1

#### Day 6: Add to Cart Functionality

**Task 1.5.1: Product Card + Click**
```dart
// lib/features/pos/presentation/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view_models/pos_view_model.dart';

final posViewModelProvider = ChangeNotifierProvider((ref) => PosViewModel());

class ProductCard extends ConsumerWidget {
  final Map<String,dynamic> product;
  
  const ProductCard({super.key, required this.product});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        ref.read(posViewModelProvider).addToCart(product['id']);
      },
      child: AlhaiCard(
        child: Column(
          children: [
            Expanded(child: Icon(Icons.image, size: 64)),
            Text(product['name']),
            Text('${product['price']} ر.س'),
          ],
        ),
      ),
    );
  }
}
```

**Day 7-8: Cart Logic**
- Cart items display
- Quantity controls (+/-)
- Remove button
- Total calculation

**Day 9-10: Polish + Tests**
- Integration testing
- Bug fixes
- Code cleanup

```bash
flutter analyze
flutter test
```

---

## 📋 TODO List - أول أسبوع

### تقسيم حسب الأيام:

```markdown
## ✅ Week 1 TODO

### Day 1 (2 يناير):
- [ ] إنشاء البنية (folders)
- [ ] كتابة main.dart
- [ ] Setup GetIt + Injectable
- [ ] Setup GoRouter
- [ ] Test: App يشتغل

### Day 2 (3 يناير):
- [ ] تعريف Products table
- [ ] تعريف Inventory table
- [ ] تعريف Sales + SaleItems tables
- [ ] dart run build_runner build -d
- [ ] No errors

### Day 3 (4 يناير):
- [ ] باقي Tables (Accounts, SyncQueue, Settings)
- [ ] ProductsDao
- [ ] Generate + test
- [ ] flutter test

### Day 4 (5 يناير):
- [ ] SyncQueueService
- [ ] Enqueue/Dequeue logic
- [ ] Register في DI
- [ ] Test sync queue

### Day 5 (6 يناير):
- [ ] POS Screen layout
- [ ] Products Grid widget
- [ ] Cart Panel widget
- [ ] flutter run → verify UI

### Day 6-7 (7-8 يناير):
- [ ] Product Card clickable
- [ ] Add to cart logic
- [ ] Cart state management
- [ ] Display cart items

### Day 8-9 (9-10 يناير):
- [ ] Quantity +/-
- [ ] Remove from cart
- [ ] Calculate total
- [ ] Polish UI

### Day 10 (11 يناير):
- [ ] Integration tests
- [ ] Bug fixes
- [ ] flutter analyze clean
- [ ] Sprint 1 Demo!
```

---

## ✅ Checklist اليومي للمبرمج

### كل صباح:
```
[ ] git pull origin main
[ ] flutter pub get
[ ] flutter analyze
[ ] قراءة TODO اليوم
```

### أثناء البرمجة:
```
[ ] كتابة الكود
[ ] Commit بعد كل feature صغير
[ ] flutter analyze بعد كل تعديل كبير
```

### قبل نهاية اليوم:
```
[ ] flutter test
[ ] flutter analyze
[ ] git commit -m "feat: ما تم اليوم"
[ ] git push origin feature/sprint-1
[ ] تحديث TODO (mark done)
```

---

## ✅ Definition of Done العملي

### لكل Task:
```
 1. الكود مكتوب ✅
 2. flutter analyze بلا أخطاء ✅
 3. flutter test تمر ✅
 4. Committed to git ✅
```

### لكل Day:
```
 1. جميع Tasks اليوم منتهية ✅
 2. flutter run يشتغل ✅
 3. لا crashes ✅
 4. Code pushed ✅
```

### لكل Module:
```
 1. جميع Acceptance Criteria met ✅
 2. Manual testing done ✅
 3. Unit tests written ✅
 4. Code reviewed (إن أمكن) ✅
```

### لكل Sprint:
```
 1. جميع Modules done ✅
 2. Demo عملي ✅
 3. Documentation updated ✅
 4. Ready for next sprint ✅
```

---

## 🔄 متى تعمل build_runner

### مرة واحدة فقط بعد:
1. ✅ إضافة/تعديل Drift tables
2. ✅ إضافة @injectable class جديد
3. ✅ تعديل DAO methods

### الأمر:
```bash
dart run build_runner build -d
# -d = delete conflicting outputs
```

### لا تعمل build_runner عند:
- كتابة UI widgets عادية
- تعديل logic بسيط
- إضافة functions عادية

---

## 🧪 متى تعمل Tests

### بعد كل:
1. DAO method جديد
2. Business logic جديد
3. قبل Commit كبير

### الأوامر:
```bash
# All tests
flutter test

# Test واحد
flutter test test/database_test.dart

# With coverage
flutter test --coverage
```

---

## 📊 Sprint 2 - ملخص سريع (Day 11-24)

### Week 3 (Day 11-15):
- **Day 11-12**: Authentication (Login + Session)
- **Day 13-14**: Sync (Pull Products + Push Sales)
- **Day 15**: Payment Selection Screen

### Week 4 (Day 16-20):
- **Day 16-17**: Sale Creation + Inventory Deduct
- **Day 18-19**: Receipt Printing
- **Day 20**: Printer Settings

### Week 5 (Day 21-24):
- **Day 21-23**: Products CRUD Screens
- **Day 24**: Sprint 2 Demo + Cleanup

---

## 🎯 القرارات المتخذة (لا تسأل عنها)

### State Management:
- **القرار**: Riverpod للـ DI + ChangeNotifier للـ ViewModels
- **السبب**: DEVELOPER_STANDARDS

### Local DB:
- **القرار**: Drift (SQLite)
- **السبب**: Offline-first

### Images:
- **القرار**: استخدام R2 URLs من alhai_core
- **السبب**: Cloudflare CDN جاهز

### Printing:
- **القرار**: PDF fallback (مؤقتاً)
- **السبب**: Thermal printer libraries معقدة
- **لاحقاً**: نضيف thermal في Sprint 6

---

## 📁 البنية النهائية المتوقعة

```
pos_app/
├── lib/
│   ├── main.dart
│   ├── di/
│   │   ├── injection.dart
│   │   └── injection.config.dart (generated)
│   ├── core/
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── constants/
│   │   │   └── app_constants.dart
│   │   └── printing/
│   │       └── printer_service.dart
│   ├── data/
│   │   └── local/
│   │       ├── database.dart
│   │       ├── database.g.dart (generated)
│   │       ├── tables/
│   │       │   ├── products_table.dart
│   │       │   ├── inventory_table.dart
│   │       │   ├── sales_table.dart
│   │       │   └── ... (8 tables)
│   │       └── daos/
│   │           ├── products_dao.dart
│   │           └── products_dao.g.dart (generated)
│   ├── features/
│   │   ├── auth/
│   │   ├── pos/
│   │   ├── products/
│   │   ├── sales/
│   │   └── sync/
│   └── shared/
│       └── widgets/
├── test/
│   ├── database_test.dart
│   ├── sync_queue_test.dart
│   └── widget_test.dart
├── assets/
│   ├── images/
│   └── icons/
└── pubspec.yaml
```

---

## 🚀 أوامر سريعة

```bash
# Setup
flutter pub get

# Development
flutter run -d windows
flutter run -d macos
flutter run -d linux

# Code Generation
dart run build_runner build -d
dart run build_runner watch  # auto-generate

# Quality
flutter analyze
flutter test
flutter test --coverage

# Clean
flutter clean
dart run build_runner clean
```

---

**📅 آخر تحديث**: 2026-01-15  
**✅ جاهز للبدء**: Day 1, Task 1.1.1
