import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;

import 'package:pos_app/data/local/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('OrganizationsDao', () {
    test('insert and retrieve organization', () async {
      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'Test Org',
          createdAt: DateTime.now(),
        ),
      );

      final org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org, isNotNull);
      expect(org!.name, 'Test Org');
    });

    test('update organization', () async {
      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'Old Name',
          createdAt: DateTime.now(),
        ),
      );

      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'New Name',
          createdAt: DateTime.now(),
        ),
      );

      final org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org!.name, 'New Name');
    });

    test('delete organization', () async {
      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'To Delete',
          createdAt: DateTime.now(),
        ),
      );

      await db.organizationsDao.deleteOrganization('org-1');
      final org = await db.organizationsDao.getOrganizationById('org-1');
      expect(org, isNull);
    });

    test('watch organization emits updates', () async {
      final stream = db.organizationsDao.watchOrganization('org-1');

      await db.organizationsDao.upsertOrganization(
        OrganizationsTableCompanion.insert(
          id: 'org-1',
          name: 'Stream Test',
          createdAt: DateTime.now(),
        ),
      );

      await expectLater(
        stream,
        emits(isNotNull),
      );
    });

    test('get active subscription', () async {
      await db.organizationsDao.upsertSubscription(
        SubscriptionsTableCompanion.insert(
          id: 'sub-1',
          orgId: 'org-1',
          plan: 'premium',
          currentPeriodStart: DateTime.now(),
          currentPeriodEnd: DateTime.now().add(const Duration(days: 30)),
          createdAt: DateTime.now(),
        ),
      );

      final sub = await db.organizationsDao.getActiveSubscription('org-1');
      expect(sub, isNotNull);
      expect(sub!.status, 'active');
    });
  });
}
