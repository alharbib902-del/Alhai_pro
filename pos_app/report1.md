# Report 1: Generated Missing Drift Tables + org_id Modifications

## 3 New Table Files

### File 1: `lib/data/local/tables/organizations_table.dart`

```dart
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_organizations_is_active', columns: {#isActive})
@TableIndex(name: 'idx_organizations_slug', columns: {#slug})
class OrganizationsTable extends Table {
  @override
  String get tableName => 'organizations';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get nameEn => text().nullable()();
  TextColumn get slug => text().nullable()();
  TextColumn get logo => text().nullable()();
  TextColumn get ownerId => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get country => text().withDefault(const Constant('SA'))();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get commercialReg => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Riyadh'))();
  TextColumn get locale => text().withDefault(const Constant('ar'))();
  TextColumn get plan => text().withDefault(const Constant('free'))();
  IntColumn get maxStores => integer().withDefault(const Constant(1))();
  IntColumn get maxUsers => integer().withDefault(const Constant(3))();
  IntColumn get maxProducts => integer().withDefault(const Constant(100))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get trialEndsAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_subscriptions_org_id', columns: {#orgId})
@TableIndex(name: 'idx_subscriptions_status', columns: {#status})
class SubscriptionsTable extends Table {
  @override
  String get tableName => 'subscriptions';

  TextColumn get id => text()();
  TextColumn get orgId => text()();
  TextColumn get plan => text()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  RealColumn get amount => real().withDefault(const Constant(0))();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get billingCycle => text().withDefault(const Constant('monthly'))();
  DateTimeColumn get currentPeriodStart => dateTime()();
  DateTimeColumn get currentPeriodEnd => dateTime()();
  BoolColumn get cancelAtPeriodEnd => boolean().withDefault(const Constant(false))();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get externalSubscriptionId => text().nullable()();
  TextColumn get features => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### File 2: `lib/data/local/tables/org_members_table.dart`

```dart
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_org_members_org_id', columns: {#orgId})
@TableIndex(name: 'idx_org_members_user_id', columns: {#userId})
class OrgMembersTable extends Table {
  @override
  String get tableName => 'org_members';

  TextColumn get id => text()();
  TextColumn get orgId => text()();
  TextColumn get userId => text()();
  TextColumn get role => text().withDefault(const Constant('staff'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get invitedBy => text().nullable()();
  DateTimeColumn get invitedAt => dateTime().nullable()();
  DateTimeColumn get joinedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_user_stores_user_id', columns: {#userId})
@TableIndex(name: 'idx_user_stores_store_id', columns: {#storeId})
class UserStoresTable extends Table {
  @override
  String get tableName => 'user_stores';

  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get storeId => text()();
  TextColumn get role => text().withDefault(const Constant('cashier'))();
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### File 3: `lib/data/local/tables/pos_terminals_table.dart`

```dart
import 'package:drift/drift.dart';

@TableIndex(name: 'idx_pos_terminals_store_id', columns: {#storeId})
@TableIndex(name: 'idx_pos_terminals_org_id', columns: {#orgId})
@TableIndex(name: 'idx_pos_terminals_status', columns: {#status})
@TableIndex(name: 'idx_pos_terminals_is_active', columns: {#isActive})
class PosTerminalsTable extends Table {
  @override
  String get tableName => 'pos_terminals';

  TextColumn get id => text()();
  TextColumn get storeId => text()();
  TextColumn get orgId => text()();
  TextColumn get name => text()();
  IntColumn get terminalNumber => integer().withDefault(const Constant(1))();
  TextColumn get deviceId => text().nullable()();
  TextColumn get deviceName => text().nullable()();
  TextColumn get deviceModel => text().nullable()();
  TextColumn get osVersion => text().nullable()();
  TextColumn get appVersion => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();
  TextColumn get currentShiftId => text().nullable()();
  TextColumn get currentUserId => text().nullable()();
  DateTimeColumn get lastHeartbeatAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAt => dateTime().nullable()();
  TextColumn get settings => text().withDefault(const Constant('{}'))();
  TextColumn get receiptHeader => text().nullable()();
  TextColumn get receiptFooter => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## Edit Instructions: Add `orgId` to 19 Existing Tables

Add this line after `id` and before `storeId` in each table:

```dart
TextColumn get orgId => text().named('org_id').nullable()();
```

### Tables to modify:

| # | File | Table |
|---|------|-------|
| 1 | `products_table.dart` | ProductsTable |
| 2 | `categories_table.dart` | CategoriesTable |
| 3 | `customers_table.dart` | CustomersTable |
| 4 | `sales_table.dart` | SalesTable (also add `terminalId`) |
| 5 | `orders_table.dart` | OrdersTable |
| 6 | `inventory_movements_table.dart` | InventoryMovementsTable |
| 7 | `accounts_table.dart` | AccountsTable |
| 8 | `suppliers_table.dart` | SuppliersTable |
| 9 | `stores_table.dart` | StoresTable |
| 10 | `users_table.dart` | UsersTable (also add `authUid`, `roleId`) |
| 11 | `shifts_table.dart` | ShiftsTable (also add `terminalId`) |
| 12 | `audit_log_table.dart` | AuditLogTable |
| 13 | `loyalty_table.dart` | LoyaltyPointsTable |
| 14 | `expenses_table.dart` | ExpensesTable |
| 15 | `returns_table.dart` | ReturnsTable |
| 16 | `purchases_table.dart` | PurchasesTable |
| 17 | `discounts_table.dart` | DiscountsTable |
| 18 | `notifications_table.dart` | NotificationsTable |
| 19 | `daily_summaries_table.dart` | DailySummariesTable |

### Additional fields:

```dart
// UsersTable - add after id:
TextColumn get authUid => text().nullable()();
TextColumn get roleId => text().nullable()();

// SalesTable - add after cashierId:
TextColumn get terminalId => text().nullable()();

// ShiftsTable - add after storeId:
TextColumn get terminalId => text().nullable()();
```

### Barrel file update (`tables.dart`):

```dart
export 'organizations_table.dart';
export 'org_members_table.dart';
export 'pos_terminals_table.dart';
```
