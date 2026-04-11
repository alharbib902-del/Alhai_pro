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

  UsersTableCompanion makeUser({
    String id = 'user-1',
    String? storeId = 'store-1',
    String name = 'محمد الكاشير',
    String? phone = '0501112222',
    String? pin = '1234',
    String role = 'cashier',
    bool isActive = true,
  }) {
    return UsersTableCompanion.insert(
      id: id,
      storeId: Value(storeId),
      name: name,
      phone: Value(phone),
      pin: Value(pin),
      role: Value(role),
      isActive: Value(isActive),
      createdAt: DateTime(2025, 1, 1),
    );
  }

  group('UsersDao', () {
    test('insertUser and getUserById', () async {
      await db.usersDao.insertUser(makeUser());

      final user = await db.usersDao.getUserById('user-1');
      expect(user, isNotNull);
      expect(user!.name, 'محمد الكاشير');
      expect(user.role, 'cashier');
    });

    test('getAllUsers returns all for store', () async {
      await db.usersDao.insertUser(makeUser());
      await db.usersDao.insertUser(
        makeUser(id: 'user-2', name: 'علي المدير', role: 'admin'),
      );

      final users = await db.usersDao.getAllUsers('store-1');
      expect(users, hasLength(2));
    });

    test('getActiveUsers excludes inactive', () async {
      await db.usersDao.insertUser(makeUser());
      await db.usersDao.insertUser(
        makeUser(id: 'user-2', name: 'موظف سابق', isActive: false),
      );

      final active = await db.usersDao.getActiveUsers('store-1');
      expect(active, hasLength(1));
    });

    test('getUserByPhone finds user', () async {
      await db.usersDao.insertUser(makeUser());

      final user = await db.usersDao.getUserByPhone('0501112222');
      expect(user, isNotNull);
      expect(user!.id, 'user-1');
    });

    test('verifyPin finds active user with matching pin', () async {
      await db.usersDao.insertUser(makeUser(pin: '5678'));

      final user = await db.usersDao.verifyPin('store-1', '5678');
      expect(user, isNotNull);
      expect(user!.id, 'user-1');
    });

    test('verifyPin returns null for wrong pin', () async {
      await db.usersDao.insertUser(makeUser(pin: '5678'));

      final user = await db.usersDao.verifyPin('store-1', '0000');
      expect(user, isNull);
    });

    test('verifyPin returns null for inactive user', () async {
      await db.usersDao.insertUser(makeUser(pin: '5678', isActive: false));

      final user = await db.usersDao.verifyPin('store-1', '5678');
      expect(user, isNull);
    });

    test('updateLastLogin sets lastLoginAt', () async {
      await db.usersDao.insertUser(makeUser());

      await db.usersDao.updateLastLogin('user-1');

      final user = await db.usersDao.getUserById('user-1');
      expect(user!.lastLoginAt, isNotNull);
    });

    test('deleteUser removes user', () async {
      await db.usersDao.insertUser(makeUser());

      final deleted = await db.usersDao.deleteUser('user-1');
      expect(deleted, 1);
    });

    test('markUserAsSynced sets syncedAt', () async {
      await db.usersDao.insertUser(makeUser());

      await db.usersDao.markUserAsSynced('user-1');

      final user = await db.usersDao.getUserById('user-1');
      expect(user!.syncedAt, isNotNull);
    });

    // Roles
    test('insertRole and getAllRoles', () async {
      await db.usersDao.insertRole(
        RolesTableCompanion.insert(
          id: 'role-1',
          storeId: 'store-1',
          name: 'كاشير',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final roles = await db.usersDao.getAllRoles('store-1');
      expect(roles, hasLength(1));
      expect(roles.first.name, 'كاشير');
    });

    test('getRoleById finds role', () async {
      await db.usersDao.insertRole(
        RolesTableCompanion.insert(
          id: 'role-1',
          storeId: 'store-1',
          name: 'مدير',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final role = await db.usersDao.getRoleById('role-1');
      expect(role, isNotNull);
      expect(role!.name, 'مدير');
    });

    test('deleteRole removes role', () async {
      await db.usersDao.insertRole(
        RolesTableCompanion.insert(
          id: 'role-1',
          storeId: 'store-1',
          name: 'مؤقت',
          createdAt: DateTime(2025, 1, 1),
        ),
      );

      final deleted = await db.usersDao.deleteRole('role-1');
      expect(deleted, 1);
    });
  });
}
