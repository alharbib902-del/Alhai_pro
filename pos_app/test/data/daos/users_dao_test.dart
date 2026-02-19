/// اختبارات DAO المستخدمين
///
/// اختبارات تكامل تستخدم قاعدة بيانات SQLite في الذاكرة
library;

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pos_app/data/local/app_database.dart';

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================

Future<void> _insertTestUser(
  AppDatabase db, {
  required String id,
  required String storeId,
  String name = 'مستخدم اختبار',
  String? phone,
  String? pin,
  String? role,
  bool isActive = true,
}) async {
  await db.usersDao.insertUser(UsersTableCompanion.insert(
    id: id,
    storeId: storeId,
    name: name,
    phone: Value(phone),
    pin: Value(pin),
    role: role != null ? Value(role) : const Value.absent(),
    isActive: Value(isActive),
    createdAt: DateTime.now(),
  ));
}

// ============================================================================
// TESTS
// ============================================================================

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('UsersDao', () {
    group('insertUser', () {
      test('inserts a new user', () async {
        // Act
        final result = await db.usersDao.insertUser(
          UsersTableCompanion.insert(
            id: 'user-1',
            storeId: 'store-1',
            name: 'أحمد',
            createdAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });
    });

    group('getUserById', () {
      test('finds user by id', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1', name: 'أحمد');

        // Act
        final user = await db.usersDao.getUserById('user-1');

        // Assert
        expect(user, isNotNull);
        expect(user!.name, 'أحمد');
      });

      test('returns null when user not found', () async {
        // Act
        final user = await db.usersDao.getUserById('non-existent');

        // Assert
        expect(user, isNull);
      });
    });

    group('getAllUsers', () {
      test('returns all users for the store', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1');
        await _insertTestUser(db, id: 'user-2', storeId: 'store-1');
        await _insertTestUser(db, id: 'user-3', storeId: 'store-2');

        // Act
        final users = await db.usersDao.getAllUsers('store-1');

        // Assert
        expect(users.length, 2);
      });

      test('orders users by name', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1', name: 'محمد');
        await _insertTestUser(db, id: 'user-2', storeId: 'store-1', name: 'أحمد');

        // Act
        final users = await db.usersDao.getAllUsers('store-1');

        // Assert
        expect(users.first.name, 'أحمد');
        expect(users.last.name, 'محمد');
      });
    });

    group('getActiveUsers', () {
      test('returns only active users', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1', isActive: true);
        await _insertTestUser(db, id: 'user-2', storeId: 'store-1', isActive: false);
        await _insertTestUser(db, id: 'user-3', storeId: 'store-1', isActive: true);

        // Act
        final users = await db.usersDao.getActiveUsers('store-1');

        // Assert
        expect(users.length, 2);
      });
    });

    group('getUserByPhone', () {
      test('finds user by phone number', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1', name: 'أحمد', phone: '0501234567');
        await _insertTestUser(db, id: 'user-2', storeId: 'store-1', name: 'محمد', phone: '0559876543');

        // Act
        final user = await db.usersDao.getUserByPhone('0501234567');

        // Assert
        expect(user, isNotNull);
        expect(user!.name, 'أحمد');
      });

      test('returns null when phone not found', () async {
        // Act
        final user = await db.usersDao.getUserByPhone('0000000000');

        // Assert
        expect(user, isNull);
      });
    });

    group('verifyPin', () {
      test('returns user when pin matches active user in store', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1', name: 'كاشير 1', pin: '1234', isActive: true);

        // Act
        final user = await db.usersDao.verifyPin('store-1', '1234');

        // Assert
        expect(user, isNotNull);
        expect(user!.name, 'كاشير 1');
      });

      test('returns null when pin does not match', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1', pin: '1234');

        // Act
        final user = await db.usersDao.verifyPin('store-1', '9999');

        // Assert
        expect(user, isNull);
      });

      test('returns null for inactive user with correct pin', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1', pin: '1234', isActive: false);

        // Act
        final user = await db.usersDao.verifyPin('store-1', '1234');

        // Assert
        expect(user, isNull);
      });

      test('returns null for correct pin in wrong store', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1', pin: '1234');

        // Act
        final user = await db.usersDao.verifyPin('store-2', '1234');

        // Assert
        expect(user, isNull);
      });
    });

    group('updateUser', () {
      test('updates user data', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1', name: 'اسم قديم');
        final user = await db.usersDao.getUserById('user-1');

        // Act
        final updated = user!.copyWith(name: 'اسم جديد');
        final result = await db.usersDao.updateUser(updated);

        // Assert
        expect(result, true);
        final fetched = await db.usersDao.getUserById('user-1');
        expect(fetched!.name, 'اسم جديد');
      });
    });

    group('deleteUser', () {
      test('deletes the user', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1');

        // Act
        final deleted = await db.usersDao.deleteUser('user-1');
        final user = await db.usersDao.getUserById('user-1');

        // Assert
        expect(deleted, 1);
        expect(user, isNull);
      });
    });

    group('updateLastLogin', () {
      test('sets lastLoginAt and updatedAt', () async {
        // Arrange
        await _insertTestUser(db, id: 'user-1', storeId: 'store-1');

        // Act
        await db.usersDao.updateLastLogin('user-1');
        final user = await db.usersDao.getUserById('user-1');

        // Assert
        expect(user!.lastLoginAt, isNotNull);
        expect(user.updatedAt, isNotNull);
      });
    });
  });
}
