import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  OrganizationsTableCompanion makeOrg({
    String id = 'org-1',
    String name = 'مؤسسة الألهاي التجارية',
    bool isActive = true,
  }) {
    return OrganizationsTableCompanion.insert(
      id: id,
      name: name,
      isActive: Value(isActive),
      phone: const Value('0112345678'),
      city: const Value('الرياض'),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('OrganizationsDao', () {
    test('insertOrganization and getOrganizationById', () async {
      await db.organizationsDao.insertOrganization(makeOrg());

      final org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org, isNotNull);
      expect(org!.name, 'مؤسسة الألهاي التجارية');
    });

    test('getOrganizationById returns null for non-existent', () async {
      final org = await db.organizationsDao.getOrganizationById('non-existent');
      expect(org, isNull);
    });

    test('getAllOrganizations returns all orgs', () async {
      await db.organizationsDao.insertOrganization(makeOrg());
      await db.organizationsDao.insertOrganization(
        makeOrg(id: 'org-2', name: 'مؤسسة أخرى'),
      );

      final orgs = await db.organizationsDao.getAllOrganizations();
      expect(orgs, hasLength(2));
    });

    test('upsertOrganization inserts or replaces', () async {
      await db.organizationsDao.upsertOrganization(makeOrg());

      var org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org!.name, 'مؤسسة الألهاي التجارية');

      await db.organizationsDao.upsertOrganization(makeOrg(name: 'اسم محدّث'));
      org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org!.name, 'اسم محدّث');
    });

    test('deleteOrganization removes org', () async {
      await db.organizationsDao.insertOrganization(makeOrg());

      final deleted = await db.organizationsDao.deleteOrganization('org-1');
      expect(deleted, 1);

      final org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org, isNull);
    });

    test('markOrgAsSynced sets syncedAt', () async {
      await db.organizationsDao.insertOrganization(makeOrg());

      await db.organizationsDao.markOrgAsSynced('org-1');

      final org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org!.syncedAt, isNotNull);
    });

    // Subscriptions
    test('upsertSubscription and getSubscription', () async {
      await db.organizationsDao.insertOrganization(makeOrg());
      await db.organizationsDao.upsertSubscription(
        SubscriptionsTableCompanion.insert(
          id: 'sub-1',
          orgId: 'org-1',
          plan: 'pro',
          status: const Value('active'),
          amount: const Value(99.0),
          currentPeriodStart: DateTime(2025, 6, 1),
          currentPeriodEnd: DateTime(2025, 7, 1),
          createdAt: DateTime(2025, 6, 1),
        ),
      );

      final sub = await db.organizationsDao.getSubscription('org-1');
      expect(sub, isNotNull);
      expect(sub!.plan, 'pro');
      expect(sub.status, 'active');
    });

    test('getActiveSubscription finds active subscription', () async {
      await db.organizationsDao.insertOrganization(makeOrg());
      await db.organizationsDao.upsertSubscription(
        SubscriptionsTableCompanion.insert(
          id: 'sub-1',
          orgId: 'org-1',
          plan: 'pro',
          status: const Value('active'),
          currentPeriodStart: DateTime(2025, 6, 1),
          currentPeriodEnd: DateTime(2025, 7, 1),
          createdAt: DateTime(2025, 6, 1),
        ),
      );

      final activeSub = await db.organizationsDao.getActiveSubscription(
        'org-1',
      );
      expect(activeSub, isNotNull);
    });

    test('getActiveSubscription returns null for cancelled', () async {
      await db.organizationsDao.insertOrganization(makeOrg());
      await db.organizationsDao.upsertSubscription(
        SubscriptionsTableCompanion.insert(
          id: 'sub-1',
          orgId: 'org-1',
          plan: 'pro',
          status: const Value('cancelled'),
          currentPeriodStart: DateTime(2025, 6, 1),
          currentPeriodEnd: DateTime(2025, 7, 1),
          createdAt: DateTime(2025, 6, 1),
        ),
      );

      final activeSub = await db.organizationsDao.getActiveSubscription(
        'org-1',
      );
      expect(activeSub, isNull);
    });

    test('deleteSubscription removes subscription', () async {
      await db.organizationsDao.insertOrganization(makeOrg());
      await db.organizationsDao.upsertSubscription(
        SubscriptionsTableCompanion.insert(
          id: 'sub-1',
          orgId: 'org-1',
          plan: 'free',
          currentPeriodStart: DateTime(2025, 6, 1),
          currentPeriodEnd: DateTime(2025, 7, 1),
          createdAt: DateTime(2025, 6, 1),
        ),
      );

      final deleted = await db.organizationsDao.deleteSubscription('sub-1');
      expect(deleted, 1);
    });
  });
}
