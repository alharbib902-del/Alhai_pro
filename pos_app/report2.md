# Report 2: Generated DAOs for New Tables

## File 1: `lib/data/local/daos/organizations_dao.dart`

```dart
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/organizations_table.dart';

part 'organizations_dao.g.dart';

@DriftAccessor(tables: [OrganizationsTable, SubscriptionsTable])
class OrganizationsDao extends DatabaseAccessor<AppDatabase>
    with _$OrganizationsDaoMixin {
  OrganizationsDao(super.db);

  // === Organizations ===

  Future<List<OrganizationsTableData>> getAllOrganizations() {
    return (select(organizationsTable)
          ..orderBy([(o) => OrderingTerm.asc(o.name)]))
        .get();
  }

  Future<OrganizationsTableData?> getOrganizationById(String id) {
    return (select(organizationsTable)..where((o) => o.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<OrganizationsTableData?> watchOrganization(String id) {
    return (select(organizationsTable)..where((o) => o.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<int> insertOrganization(OrganizationsTableCompanion org) =>
      into(organizationsTable).insert(org);

  Future<bool> updateOrganization(OrganizationsTableData org) =>
      update(organizationsTable).replace(org);

  Future<int> upsertOrganization(OrganizationsTableCompanion org) =>
      into(organizationsTable)
          .insert(org, mode: InsertMode.insertOrReplace);

  Future<int> deleteOrganization(String id) =>
      (delete(organizationsTable)..where((o) => o.id.equals(id))).go();

  Future<int> markOrgAsSynced(String id) {
    return (update(organizationsTable)..where((o) => o.id.equals(id)))
        .write(OrganizationsTableCompanion(
            syncedAt: Value(DateTime.now())));
  }

  Stream<List<OrganizationsTableData>> watchOrganizations() {
    return (select(organizationsTable)
          ..orderBy([(o) => OrderingTerm.asc(o.name)]))
        .watch();
  }

  // === Subscriptions ===

  Future<SubscriptionsTableData?> getSubscription(String orgId) {
    return (select(subscriptionsTable)
          ..where((s) => s.orgId.equals(orgId)))
        .getSingleOrNull();
  }

  Future<SubscriptionsTableData?> getSubscriptionById(String id) {
    return (select(subscriptionsTable)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<SubscriptionsTableData?> watchSubscription(String orgId) {
    return (select(subscriptionsTable)
          ..where((s) => s.orgId.equals(orgId)))
        .watchSingleOrNull();
  }

  Future<SubscriptionsTableData?> getActiveSubscription(String orgId) {
    return (select(subscriptionsTable)
          ..where((s) =>
              s.orgId.equals(orgId) & s.status.equals('active')))
        .getSingleOrNull();
  }

  Future<int> upsertSubscription(SubscriptionsTableCompanion sub) =>
      into(subscriptionsTable)
          .insert(sub, mode: InsertMode.insertOrReplace);

  Future<int> deleteSubscription(String id) =>
      (delete(subscriptionsTable)..where((s) => s.id.equals(id))).go();
}
```

## File 2: `lib/data/local/daos/org_members_dao.dart`

```dart
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/org_members_table.dart';

part 'org_members_dao.g.dart';

@DriftAccessor(tables: [OrgMembersTable, UserStoresTable])
class OrgMembersDao extends DatabaseAccessor<AppDatabase>
    with _$OrgMembersDaoMixin {
  OrgMembersDao(super.db);

  // === Org Members ===

  Future<List<OrgMembersTableData>> getOrgMembers(String orgId) {
    return (select(orgMembersTable)
          ..where((m) => m.orgId.equals(orgId)))
        .get();
  }

  Stream<List<OrgMembersTableData>> watchOrgMembers(String orgId) {
    return (select(orgMembersTable)
          ..where((m) => m.orgId.equals(orgId)))
        .watch();
  }

  Future<OrgMembersTableData?> getMemberByUserId(
      String orgId, String userId) {
    return (select(orgMembersTable)
          ..where((m) =>
              m.orgId.equals(orgId) & m.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<int> upsertOrgMember(OrgMembersTableCompanion member) =>
      into(orgMembersTable)
          .insert(member, mode: InsertMode.insertOrReplace);

  Future<int> deleteOrgMember(String id) =>
      (delete(orgMembersTable)..where((m) => m.id.equals(id))).go();

  // === User Stores ===

  Future<List<UserStoresTableData>> getUserStores(String userId) {
    return (select(userStoresTable)
          ..where((us) => us.userId.equals(userId)))
        .get();
  }

  Stream<List<UserStoresTableData>> watchUserStores(String userId) {
    return (select(userStoresTable)
          ..where((us) => us.userId.equals(userId)))
        .watch();
  }

  Future<List<UserStoresTableData>> getStoreUsers(String storeId) {
    return (select(userStoresTable)
          ..where((us) => us.storeId.equals(storeId)))
        .get();
  }

  Future<int> upsertUserStore(UserStoresTableCompanion userStore) =>
      into(userStoresTable)
          .insert(userStore, mode: InsertMode.insertOrReplace);

  Future<int> deleteUserStore(String id) =>
      (delete(userStoresTable)..where((us) => us.id.equals(id))).go();
}
```

## File 3: `lib/data/local/daos/pos_terminals_dao.dart`

```dart
import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pos_terminals_table.dart';

part 'pos_terminals_dao.g.dart';

@DriftAccessor(tables: [PosTerminalsTable])
class PosTerminalsDao extends DatabaseAccessor<AppDatabase>
    with _$PosTerminalsDaoMixin {
  PosTerminalsDao(super.db);

  Future<PosTerminalsTableData?> getTerminal(String id) {
    return (select(posTerminalsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<PosTerminalsTableData>> getStoreTerminals(String storeId) {
    return (select(posTerminalsTable)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Stream<List<PosTerminalsTableData>> watchStoreTerminals(String storeId) {
    return (select(posTerminalsTable)
          ..where((t) => t.storeId.equals(storeId))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<PosTerminalsTableData>> getActiveTerminals(String storeId) {
    return (select(posTerminalsTable)
          ..where((t) =>
              t.storeId.equals(storeId) & t.isActive.equals(true)))
        .get();
  }

  Future<int> upsertTerminal(PosTerminalsTableCompanion terminal) =>
      into(posTerminalsTable)
          .insert(terminal, mode: InsertMode.insertOrReplace);

  Future<int> deleteTerminal(String id) =>
      (delete(posTerminalsTable)..where((t) => t.id.equals(id))).go();

  Future<int> updateHeartbeat(String id) {
    return (update(posTerminalsTable)..where((t) => t.id.equals(id)))
        .write(PosTerminalsTableCompanion(
            lastHeartbeatAt: Value(DateTime.now())));
  }

  Future<int> updateCurrentShift(String terminalId, String? shiftId) {
    return (update(posTerminalsTable)
          ..where((t) => t.id.equals(terminalId)))
        .write(PosTerminalsTableCompanion(
            currentShiftId: Value(shiftId)));
  }

  Future<int> updateCurrentUser(String terminalId, String? userId) {
    return (update(posTerminalsTable)
          ..where((t) => t.id.equals(terminalId)))
        .write(PosTerminalsTableCompanion(
            currentUserId: Value(userId)));
  }

  Future<int> markAsSynced(String id) {
    return (update(posTerminalsTable)..where((t) => t.id.equals(id)))
        .write(PosTerminalsTableCompanion(
            syncedAt: Value(DateTime.now())));
  }
}
```

## Required Modifications

### `daos.dart` barrel file - add exports:

```dart
export 'organizations_dao.dart';
export 'org_members_dao.dart';
export 'pos_terminals_dao.dart';
```

### `app_database.dart` - register new tables and DAOs:

Add to `@DriftDatabase` annotation `tables:` list:
```dart
OrganizationsTable,
SubscriptionsTable,
OrgMembersTable,
UserStoresTable,
PosTerminalsTable,
```

Add to `@DriftDatabase` annotation `daos:` list:
```dart
OrganizationsDao,
OrgMembersDao,
PosTerminalsDao,
```

Then run: `dart run build_runner build --delete-conflicting-outputs`
