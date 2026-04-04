import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/org_members_table.dart';
import '../tables/organizations_table.dart';

part 'organizations_dao.g.dart';

@DriftAccessor(
    tables: [OrganizationsTable, SubscriptionsTable, OrgMembersTable])
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
      into(organizationsTable).insert(org, mode: InsertMode.insertOrReplace);

  Future<int> deleteOrganization(String id) async {
    return transaction(() async {
      // Clean up related records first (cascade safety)
      await (delete(orgMembersTable)..where((m) => m.orgId.equals(id))).go();
      await (delete(subscriptionsTable)..where((s) => s.orgId.equals(id))).go();
      return (delete(organizationsTable)..where((o) => o.id.equals(id))).go();
    });
  }

  Future<int> markOrgAsSynced(String id) {
    return (update(organizationsTable)..where((o) => o.id.equals(id)))
        .write(OrganizationsTableCompanion(syncedAt: Value(DateTime.now())));
  }

  Stream<List<OrganizationsTableData>> watchOrganizations() {
    return (select(organizationsTable)
          ..orderBy([(o) => OrderingTerm.asc(o.name)]))
        .watch();
  }

  // === Subscriptions ===

  Future<SubscriptionsTableData?> getSubscription(String orgId) {
    return (select(subscriptionsTable)..where((s) => s.orgId.equals(orgId)))
        .getSingleOrNull();
  }

  Future<SubscriptionsTableData?> getSubscriptionById(String id) {
    return (select(subscriptionsTable)..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<SubscriptionsTableData?> watchSubscription(String orgId) {
    return (select(subscriptionsTable)..where((s) => s.orgId.equals(orgId)))
        .watchSingleOrNull();
  }

  Future<SubscriptionsTableData?> getActiveSubscription(String orgId) {
    return (select(subscriptionsTable)
          ..where((s) => s.orgId.equals(orgId) & s.status.equals('active')))
        .getSingleOrNull();
  }

  Future<int> upsertSubscription(SubscriptionsTableCompanion sub) =>
      into(subscriptionsTable).insert(sub, mode: InsertMode.insertOrReplace);

  Future<int> deleteSubscription(String id) =>
      (delete(subscriptionsTable)..where((s) => s.id.equals(id))).go();
}
