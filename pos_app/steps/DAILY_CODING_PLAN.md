# 💻 POS App - خطة البرمجة اليومية

**التاريخ**: 2026-01-15  
**المرجع**: IMPLEMENTATION_PLAN.md

---

## 📅 Sprint 1 - جدول يومي (10 أيام)

### 🔹 Day 1: Setup + DI

#### AM (4 ساعات):
**Task 1.1.1: إنشاء المشروع**
```bash
cd C:\Users\basem\OneDrive\Desktop\Alhai\pos_app
# المشروع موجود فعلاً - تم ✅
```

**Task 1.1.2: إنشاء البنية**
```bash
mkdir -p lib/di lib/core/router lib/core/constants lib/shared/widgets lib/features
mkdir -p assets/images assets/icons
```

**Task 1.1.3: كتابة main.dart**
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverp od/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'core/router/app_router.dart';
import 'di/injection.dart';

void main() {
  configureDependencies();
  runApp(const ProviderScope(child: PosApp()));
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'POS App',
      theme: AlhaiTheme.light(),
      darkTheme: AlhaiTheme.dark(),
      routerConfig: AppRouter.router,
    );
  }
}
```

#### PM (4 ساعات):
**Task 1.1.4: Setup GetIt + Injectable**
```dart
// lib/di/injection.dart
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();
```

```bash
# لاحقاً بعد إضافة @injectable
dart run build_runner build -d
```

**Task 1.1.5: Setup GoRouter**
```dart
// lib/core/router/app_router.dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/pos',
    routes: [
      GoRoute(
        path: '/pos',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('POS Screen - Coming Soon')),
        ),
      ),
    ],
  );
}
```

**Task 1.1.6: Constants**
```dart
// lib/core/constants/app_constants.dart
class AppConstants {
  static const String appName = 'POS App';
  static const String appVersion = '1.0.0';
  
  // Routes
  static const String posRoute = '/pos';
  static const String loginRoute = '/login';
}
```

#### DoD للـ Day 1:
```bash
flutter analyze  # لا أخطاء
flutter run -d windows  # يشتغل
```
- ✅ App يفتح
- ✅ Dark mode يعمل (F5 → toggle theme)
- ✅ "POS Screen - Coming Soon" ظاهر

---

### 🔹 Day 2: Drift Tables (أول دفعة)

#### AM (4 ساعات):
**Task 1.2.1: Setup Drift**
```dart
// lib/data/local/database.dart
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';

part 'database.g.dart';

@DriftDatabase(tables: [])  // نضيف tables لاحقاً
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'pos_db.sqlite'));
      return NativeDatabase(file);
    });
  }
}
```

**Task 1.2.2: Products Table**
```dart
// lib/data/local/tables/products_table.dart
import 'package:drift/drift.dart';

class ProductsTable extends Table {
  @override
  String get tableName => 'products';
  
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get barcode => text().nullable()();
  TextColumn get categoryId => text().nullable()();
  RealColumn get sellPrice => real()();
  RealColumn get purchasePrice => real().withDefault(const Constant(0))();
  RealColumn get minStock => real().withDefault(const Constant(0))();
  TextColumn get imageThumbnail => text().nullable()();
  TextColumn get imageMedium => text().nullable()();
  TextColumn get imageLarge => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

#### PM (4 ساعات):
**Task 1.2.3: Inventory + Sales Tables**
```dart
// lib/data/local/tables/inventory_table.dart
class InventoryTable extends Table {
  @override
  String get tableName => 'inventory';
  
  TextColumn get productId => text()();
  RealColumn get quantity => real()();
  RealColumn get reservedQty => real().withDefault(const Constant(0))();
  DateTimeColumn get lastUpdated => dateTime()();
  
  @override
  Set<Column> get primaryKey => {productId};
}

// lib/data/local/tables/sales_table.dart
class SalesTable extends Table {
  @override
  String get tableName => 'sales';
  
  TextColumn get id => text()();
  TextColumn get receiptNo => text()();
  TextColumn get channel => text()();  // POS/APP
  TextColumn get sourceOrderId => text().nullable()();
  TextColumn get customerId => text().nullable()();
  TextColumn get cashierId => text()();
  TextColumn get paymentMethod => text()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get tax => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get status => text()();  // COMPLETED/VOIDED
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

// lib/data/local/tables/sale_items_table.dart
class SaleItemsTable extends Table {
  @override
  String get tableName => 'sale_items';
  
  TextColumn get id => text()();
  TextColumn get saleId => text()();
  TextColumn get productId => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get unitCost => real()();
  RealColumn get total => real()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

**Task 1.2.4: أضف Tables للـ Database**
```dart
// lib/data/local/database.dart
import 'tables/products_table.dart';
import 'tables/inventory_table.dart';
import 'tables/sales_table.dart';
import 'tables/sale_items_table.dart';

@DriftDatabase(tables: [
  ProductsTable,
  InventoryTable,
  SalesTable,
  SaleItemsTable,
])
class AppDatabase extends _$AppDatabase {
  // ... same
}
```

**Task 1.2.5: Generate Drift Files**
```bash
dart run build_runner build -d
# انتظر 1-2 دقيقة
# database.g.dart تم إنشاؤه ✅
```

#### DoD للـ Day 2:
```bash
flutter analyze  # لا أخطاء
```
- ✅ Drift files generated
- ✅ No build errors

---

### 🔹 Day 3: DAOs + باقي Tables

#### AM (4 ساعات):
**Task 1.2.6: Products DAO**
```dart
// lib/data/local/daos/products_dao.dart
import 'package:drift/drift.dart';
import '../database.dart';
import '../tables/products_table.dart';

part 'products_dao.g.dart';

@DriftAccessor(tables: [ProductsTable])
class ProductsDao extends DatabaseAccessor<AppDatabase>
    with _$ProductsDaoMixin {
  ProductsDao(AppDatabase db) : super(db);
  
  Future<List<ProductsTableData>> getAllProducts() {
    return (select(productsTable)
      ..where((p) => p.isActive.equals(true)))
      .get();
  }
  
  Future<ProductsTableData?> getProductById(String id) {
    return (select(productsTable)..where((p) => p.id.equals(id)))
      .getSingleOrNull();
  }
  
  Future<int> insertProduct(ProductsTableCompanion product) {
    return into(productsTable).insert(product);
  }
  
  Future<bool> updateProduct(ProductsTableData product) {
    return update(productsTable).replace(product);
  }
  
  Future<int> deleteProduct(String id) {
    return (delete(productsTable)..where((p) => p.id.equals(id))).go();
  }
}
```

**Task 1.2.7: باقي Tables (Accounts, Sync, Settings)**
```dart
// lib/data/local/tables/accounts_table.dart
class AccountsTable extends Table {
  @override
  String get tableName => 'accounts';
  
  TextColumn get id => text()();
  TextColumn get type => text()();  // CUSTOMER/SUPPLIER
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  RealColumn get balance => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// lib/data/local/tables/sync_queue_table.dart
class SyncQueueTable extends Table {
  @override
  String get tableName => 'sync_queue';
  
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get action => text()();  // CREATE/UPDATE/DELETE
  TextColumn get payload => text()();  // JSON
  TextColumn get status => text()();  // PENDING/SYNCED/FAILED
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}

// lib/data/local/tables/settings_table.dart
class SettingsTable extends Table {
  @override
  String get tableName => 'settings';
  
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {key};
}
```

#### PM (4 ساعات):
**Task 1.2.8: أضف Tables + Generate**
```dart
// database.dart
@DriftDatabase(tables: [
  ProductsTable,
  InventoryTable,
  SalesTable,
  SaleItemsTable,
  AccountsTable,
  SyncQueueTable,
  SettingsTable,
])
```

```bash
dart run build_runner build -d
```

**Task 1.2.9: Test DAOs**
```dart
// test/database_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:pos_app/data/local/database.dart';

void main() {
  late AppDatabase database;
  
  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });
  
  tearDown(() async {
    await database.close();
  });
  
  test('Insert and retrieve product', () async {
    final dao = database.productsDao;
    
    await dao.insertProduct(ProductsTableCompanion.insert(
      id: 'test-1',
      name: 'Test Product',
      sellPrice: 10.0,
      createdAt: DateTime.now(),
    ));
    
    final product = await dao.getProductById('test-1');
    expect(product?.name, 'Test Product');
  });
}
```

```bash
flutter test test/database_test.dart
```

#### DoD للـ Day 3:
- ✅ All tables defined
- ✅ ProductsDao works
- ✅ Tests pass

---

### 🔹 Day 4: Sync Queue Service

#### Full Day (8 ساعات):
**Task 1.3.1: SyncQueueService**
```dart
// lib/features/sync/data/sync_queue_service.dart
import 'package:injectable/injectable.dart';
import '../../../data/local/database.dart';
import 'package:drift/drift.dart';

@injectable
class SyncQueueService {
  final AppDatabase _db;
  
  SyncQueueService(this._db);
  
  Future<int> enqueue({
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    return await _db.into(_db.syncQueueTable).insert(
      SyncQueueTableCompanion.insert(
        entityType: entityType,
        entityId: entityId,
        action: action,
        payload: jsonEncode(payload),
        status: 'PENDING',
        createdAt: DateTime.now(),
      ),
    );
  }
  
  Future<List<SyncQueueTableData>> getPendingItems() {
    return (_db.select(_db.syncQueueTable)
      ..where((q) => q.status.equals('PENDING'))
      ..orderBy([(q) => OrderingTerm.asc(q.createdAt)]))
      .get();
  }
  
  Future<void> markAsSynced(int id) async {
    await (_db.update(_db.syncQueueTable)..where((q) => q.id.equals(id)))
      .write(SyncQueueTableCompanion(
        status: const Value('SYNCED'),
        syncedAt: Value(DateTime.now()),
      ));
  }
  
  Future<void> markAsFailed(int id, String error) async {
    final item = await (_db.select(_db.syncQueueTable)
      ..where((q) => q.id.equals(id)))
      .getSingle();
    
    await (_db.update(_db.syncQueueTable)..where((q) => q.id.equals(id)))
      .write(SyncQueueTableCompanion(
        status: const Value('FAILED'),
        attempts: Value(item.attempts + 1),
        lastError: Value(error),
      ));
  }
}
```

**Task 1.3.2: SyncRepository Interface**
```dart
// lib/features/sync/domain/sync_repository.dart
abstract class SyncRepository {
  Future<void> pushPendingChanges();
  Future<void> pullLatestData();
}
```

**Task 1.3.3: Register في DI**
```dart
// lib/data/local/database.dart
@injectable
class AppDatabase extends _$AppDatabase {
  // ... same
}
```

```bash
dart run build_runner build -d
```

**Task 1.3.4: Test Sync Queue**
```dart
// test/sync_queue_test.dart
test('Enqueue and retrieve', () async {
  final service = SyncQueueService(database);
  
  await service.enqueue(
    entityType: 'SALE',
    entityId: 'sale-1',
    action: 'CREATE',
    payload: {'total': 100},
  );
  
  final pending = await service.getPendingItems();
  expect(pending.length, 1);
  expect(pending.first.entityType, 'SALE');
});
```

#### DoD للـ Day 4:
- ✅ SyncQueueService registered
- ✅ Tests pass
-  ✅ `flutter analyze` clean

---

### 🔹 Day 5: POS Screen Layout

#### AM (4 ساعات):
**Task 1.4.1: POS ViewModel**
```dart
// lib/features/pos/presentation/view_models/pos_view_model.dart
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@injectable
class PosViewModel extends ChangeNotifier {
  List<String> _cartItems = [];
  
  List<String> get cartItems => _cartItems;
  
  void addToCart(String productId) {
    _cartItems.add(productId);
    notifyListeners();
  }
  
  void removeFromCart(String productId) {
    _cartItems.remove(productId);
    notifyListeners();
  }
  
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
  
  double get total => _cartItems.length * 10.0;  // mock
}
```

**Task 1.4.2: POS Screen**
```dart
// lib/features/pos/presentation/screens/pos_screen.dart
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import '../widgets/products_grid.dart';
import '../widgets/cart_panel.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AlhaiAppBar(title: 'POS'),
      body: Row(
        children: [
          // Products grid (70%)
          Expanded(
            flex: 7,
            child: ProductsGrid(),
          ),
          
          // Cart panel (30%)
          Expanded(
            flex: 3,
            child: CartPanel(),
          ),
        ],
      ),
    );
  }
}
```

#### PM (4 ساعات):
**Task 1.4.3: Products Grid Widget**
```dart
// lib/features/pos/presentation/widgets/products_grid.dart
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class ProductsGrid extends StatelessWidget {
  const ProductsGrid({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Mock data
    final products = List.generate(20, (i) => {
      'id': 'p-$i',
      'name': 'منتج $i',
      'price': (10 + i).toDouble(),
    });
    
    return GridView.builder(
      padding: EdgeInsets.all(AlhaiSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return AlhaiCard(
          child: Column(
            children: [
              Expanded(
                child: Icon(Icons.image, size: 64),
              ),
              Text(product['name'] as String),
              Text('${product['price']} ر.س'),
            ],
          ),
        );
      },
    );
  }
}
```

**Task 1.4.4: Cart Panel Widget**
```dart
// lib/features/pos/presentation/widgets/cart_panel.dart
import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(AlhaiSpacing.md),
            child: Text('السلة', style: AlhaiTypography.headlineMedium),
          ),
          
          Divider(),
          
          // Empty state
          Expanded(
            child: Center(
              child: Text('السلة فارغة'),
            ),
          ),
          
          // Total
          Padding(
            padding: EdgeInsets.all(AlhaiSpacing.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الإجمالي:'),
                    Text('0 ر.س', style: AlhaiTypography.headlineSmall),
                  ],
                ),
                SizedBox(height: AlhaiSpacing.sm),
                AlhaiButton(
                  text: 'إتمام البيع',
                  onPressed: () {},
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**Task 1.4.5: Update Router**
```dart
// lib/core/router/app_router.dart
import '../../features/pos/presentation/screens/pos_screen.dart';

GoRoute(
  path: '/pos',
  builder: (context, state) => const PosScreen(),
),
```

#### DoD Day 5:
```bash
flutter run -d windows
```
- ✅ POS screen shows
- ✅ Grid displays products
- ✅ Cart panel visible
- ✅ Split 70/30 works

---

## (يتبع في الملف التالي - Day 6-10 + Sprint 2)
