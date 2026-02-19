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

  group('OrgMembersDao', () {
    test('add and retrieve org members', () async {
      await db.orgMembersDao.upsertOrgMember(
        OrgMembersTableCompanion.insert(
          id: 'member-1',
          orgId: 'org-1',
          userId: 'user-1',
          createdAt: DateTime.now(),
        ),
      );

      final members = await db.orgMembersDao.getOrgMembers('org-1');
      expect(members.length, 1);
      expect(members.first.role, 'staff');
    });

    test('get member by user id', () async {
      await db.orgMembersDao.upsertOrgMember(
        OrgMembersTableCompanion.insert(
          id: 'member-1',
          orgId: 'org-1',
          userId: 'user-1',
          createdAt: DateTime.now(),
        ),
      );

      final member =
          await db.orgMembersDao.getMemberByUserId('org-1', 'user-1');
      expect(member, isNotNull);
    });

    test('user store assignments', () async {
      await db.orgMembersDao.upsertUserStore(
        UserStoresTableCompanion.insert(
          id: 'us-1',
          userId: 'user-1',
          storeId: 'store-1',
          createdAt: DateTime.now(),
        ),
      );

      final stores = await db.orgMembersDao.getUserStores('user-1');
      expect(stores.length, 1);
      expect(stores.first.role, 'cashier');

      final users = await db.orgMembersDao.getStoreUsers('store-1');
      expect(users.length, 1);
    });
  });
}
