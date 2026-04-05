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

  group('OrgMembersDao - Org Members', () {
    test('upsertOrgMember and getOrgMembers', () async {
      await db.orgMembersDao.upsertOrgMember(
        OrgMembersTableCompanion.insert(
          id: 'om-1',
          orgId: 'org-1',
          userId: 'user-1',
          role: const Value('admin'),
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final members = await db.orgMembersDao.getOrgMembers('org-1');
      expect(members, hasLength(1));
      expect(members.first.role, 'admin');
    });

    test('getMemberByUserId finds member', () async {
      await db.orgMembersDao.upsertOrgMember(
        OrgMembersTableCompanion.insert(
          id: 'om-1',
          orgId: 'org-1',
          userId: 'user-1',
          role: const Value('staff'),
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final member =
          await db.orgMembersDao.getMemberByUserId('org-1', 'user-1');
      expect(member, isNotNull);
      expect(member!.id, 'om-1');
    });

    test('getMemberByUserId returns null when not found', () async {
      final member =
          await db.orgMembersDao.getMemberByUserId('org-1', 'non-existent');
      expect(member, isNull);
    });

    test('deleteOrgMember removes member', () async {
      await db.orgMembersDao.upsertOrgMember(
        OrgMembersTableCompanion.insert(
          id: 'om-1',
          orgId: 'org-1',
          userId: 'user-1',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final deleted = await db.orgMembersDao.deleteOrgMember('om-1');
      expect(deleted, 1);

      final members = await db.orgMembersDao.getOrgMembers('org-1');
      expect(members, isEmpty);
    });
  });

  group('OrgMembersDao - User Stores', () {
    test('upsertUserStore and getUserStores', () async {
      await db.orgMembersDao.upsertUserStore(
        UserStoresTableCompanion.insert(
          id: 'us-1',
          userId: 'user-1',
          storeId: 'store-1',
          role: const Value('cashier'),
          createdAt: DateTime(2025, 1, 1),
        ),
      );
      await db.orgMembersDao.upsertUserStore(
        UserStoresTableCompanion.insert(
          id: 'us-2',
          userId: 'user-1',
          storeId: 'store-2',
          role: const Value('admin'),
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final stores = await db.orgMembersDao.getUserStores('user-1');
      expect(stores, hasLength(2));
    });

    test('getStoreUsers returns users for store', () async {
      await db.orgMembersDao.upsertUserStore(
        UserStoresTableCompanion.insert(
          id: 'us-1',
          userId: 'user-1',
          storeId: 'store-1',
          createdAt: DateTime(2025, 1, 1),
        ),
      );
      await db.orgMembersDao.upsertUserStore(
        UserStoresTableCompanion.insert(
          id: 'us-2',
          userId: 'user-2',
          storeId: 'store-1',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final users = await db.orgMembersDao.getStoreUsers('store-1');
      expect(users, hasLength(2));
    });

    test('deleteUserStore removes assignment', () async {
      await db.orgMembersDao.upsertUserStore(
        UserStoresTableCompanion.insert(
          id: 'us-1',
          userId: 'user-1',
          storeId: 'store-1',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final deleted = await db.orgMembersDao.deleteUserStore('us-1');
      expect(deleted, 1);

      final stores = await db.orgMembersDao.getUserStores('user-1');
      expect(stores, isEmpty);
    });
  });
}
