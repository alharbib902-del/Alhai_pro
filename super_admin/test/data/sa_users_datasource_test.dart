import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/data/models/sa_user_model.dart';
import 'package:super_admin/data/sa_users_datasource.dart';

import '../helpers/mock_supabase_client.dart';
import '../helpers/test_factories.dart';

void main() {
  late MockSupabaseClient mock;
  late SAUsersDatasource ds;

  setUp(() {
    resetFactoryIds();
    mock = MockSupabaseClient();
    ds = SAUsersDatasource(mock.client);
  });

  // ==========================================================================
  // getPlatformUsers
  // ==========================================================================

  group('getPlatformUsers', () {
    test('returns parsed users from the users table', () async {
      // Arrange
      mock.setResponse('users', [
        SAUserFactory.json(id: 'u1', name: 'Alice', role: 'super_admin'),
        SAUserFactory.json(id: 'u2', name: 'Bob', role: 'support'),
      ]);

      // Act
      final result = await ds.getPlatformUsers();

      // Assert
      expect(result, hasLength(2));
      expect(result[0], isA<SAUser>());
      expect(result[0].id, equals('u1'));
      expect(result[0].name, equals('Alice'));
      expect(result[1].id, equals('u2'));
      expect(result[1].name, equals('Bob'));
    });

    test('applies inFilter for platform roles', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      await ds.getPlatformUsers();

      // Assert
      final ops = mock.queryLog['users']!.first;
      final inFilterOp = ops.firstWhere((op) => op.method == 'inFilter');
      expect(inFilterOp.args[0], equals('role'));
      expect(inFilterOp.args[1],
          containsAll(['super_admin', 'support', 'viewer']));
    });

    test('adds or filter when search is provided', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      await ds.getPlatformUsers(search: 'alice');

      // Assert
      final ops = mock.queryLog['users']!.first;
      final orOp = ops.firstWhere((op) => op.method == 'or');
      expect(orOp.args[0], contains('alice'));
    });

    test('does not add or filter when search is null', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      await ds.getPlatformUsers();

      // Assert
      final ops = mock.queryLog['users']!.first;
      final orOps = ops.where((op) => op.method == 'or');
      expect(orOps, isEmpty);
    });

    test('does not add or filter when search is empty', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      await ds.getPlatformUsers(search: '');

      // Assert
      final ops = mock.queryLog['users']!.first;
      final orOps = ops.where((op) => op.method == 'or');
      expect(orOps, isEmpty);
    });

    test('sanitizes search input (escapes % and _)', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      await ds.getPlatformUsers(search: '50%_off');

      // Assert
      final ops = mock.queryLog['users']!.first;
      final orOp = ops.firstWhere((op) => op.method == 'or');
      final filter = orOp.args[0] as String;
      // Should not contain raw % or _ from user input
      expect(filter, contains(r'50\%\_off'));
    });

    test('orders by created_at descending', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      await ds.getPlatformUsers();

      // Assert
      final ops = mock.queryLog['users']!.first;
      final orderOp = ops.firstWhere((op) => op.method == 'order');
      expect(orderOp.args[0], equals('created_at'));
      expect(orderOp.args[1], isFalse); // ascending = false
    });

    test('returns empty list when no users exist', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      final result = await ds.getPlatformUsers();

      // Assert
      expect(result, isEmpty);
    });
  });

  // ==========================================================================
  // getUser
  // ==========================================================================

  group('getUser', () {
    test('returns a single user by ID', () async {
      // Arrange
      mock.setResponse(
          'users',
          SAUserFactory.json(
            id: 'u42',
            name: 'Fatima',
            role: 'owner',
          ));

      // Act
      final user = await ds.getUser('u42');

      // Assert
      expect(user.id, equals('u42'));
      expect(user.name, equals('Fatima'));
    });

    test('sends eq filter for the user id', () async {
      // Arrange
      mock.setResponse('users', SAUserFactory.json(id: 'u42'));

      // Act
      await ds.getUser('u42');

      // Assert
      final ops = mock.queryLog['users']!.first;
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('id'));
      expect(eqOp.args[1], equals('u42'));
    });

    test('calls single() to get one record', () async {
      // Arrange
      mock.setResponse('users', SAUserFactory.json(id: 'u42'));

      // Act
      await ds.getUser('u42');

      // Assert
      final ops = mock.queryLog['users']!.first;
      expect(ops.any((op) => op.method == 'single'), isTrue);
    });
  });

  // ==========================================================================
  // updateUserRole
  // ==========================================================================

  group('updateUserRole', () {
    test('sends update with new role and eq filter for user id', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      await ds.updateUserRole('u1', 'support');

      // Assert
      final ops = mock.queryLog['users']!.first;
      final updateOp = ops.firstWhere((op) => op.method == 'update');
      expect(updateOp.args[0], equals({'role': 'support'}));
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('id'));
      expect(eqOp.args[1], equals('u1'));
    });
  });

  // ==========================================================================
  // getTotalUserCount
  // ==========================================================================

  group('getTotalUserCount', () {
    test('returns count from the users table', () async {
      // Arrange
      mock.setCount('users', 42);

      // Act
      final count = await ds.getTotalUserCount();

      // Assert
      expect(count, equals(42));
    });

    test('uses count(CountOption.exact)', () async {
      // Arrange
      mock.setCount('users', 0);

      // Act
      await ds.getTotalUserCount();

      // Assert
      final ops = mock.queryLog['users']!.first;
      expect(ops.any((op) => op.method == 'count'), isTrue);
    });

    test('returns 0 when no users exist', () async {
      // Arrange
      mock.setCount('users', 0);

      // Act
      final count = await ds.getTotalUserCount();

      // Assert
      expect(count, equals(0));
    });
  });

  // ==========================================================================
  // getActiveUserCount
  // ==========================================================================

  group('getActiveUserCount', () {
    test('returns count of recently active users', () async {
      // Arrange
      mock.setCount('users', 15);

      // Act
      final count = await ds.getActiveUserCount();

      // Assert
      expect(count, equals(15));
    });

    test('filters by last_login_at >= 30 days ago', () async {
      // Arrange
      mock.setCount('users', 0);

      // Act
      await ds.getActiveUserCount();

      // Assert
      final ops = mock.queryLog['users']!.first;
      final gteOp = ops.firstWhere((op) => op.method == 'gte');
      expect(gteOp.args[0], equals('last_login_at'));
      // The value should be an ISO 8601 string ~30 days ago
      final dateStr = gteOp.args[1] as String;
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date).inDays;
      expect(diff, inInclusiveRange(29, 31));
    });
  });

  // ==========================================================================
  // getNewSignupsCount
  // ==========================================================================

  group('getNewSignupsCount', () {
    test('returns count of new signups', () async {
      // Arrange
      mock.setCount('users', 7);

      // Act
      final count = await ds.getNewSignupsCount();

      // Assert
      expect(count, equals(7));
    });

    test('filters by created_at >= 30 days ago', () async {
      // Arrange
      mock.setCount('users', 0);

      // Act
      await ds.getNewSignupsCount();

      // Assert
      final ops = mock.queryLog['users']!.first;
      final gteOp = ops.firstWhere((op) => op.method == 'gte');
      expect(gteOp.args[0], equals('created_at'));
      final dateStr = gteOp.args[1] as String;
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date).inDays;
      expect(diff, inInclusiveRange(29, 31));
    });
  });

  // ==========================================================================
  // softDeleteUser
  // ==========================================================================

  group('softDeleteUser', () {
    test('sets is_active to false for the given user', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      await ds.softDeleteUser('u1');

      // Assert
      final ops = mock.queryLog['users']!.first;
      final updateOp = ops.firstWhere((op) => op.method == 'update');
      expect(updateOp.args[0], equals({'is_active': false}));
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('id'));
      expect(eqOp.args[1], equals('u1'));
    });
  });

  // ==========================================================================
  // restoreUser
  // ==========================================================================

  group('restoreUser', () {
    test('sets is_active to true for the given user', () async {
      // Arrange
      mock.setResponse('users', []);

      // Act
      await ds.restoreUser('u1');

      // Assert
      final ops = mock.queryLog['users']!.first;
      final updateOp = ops.firstWhere((op) => op.method == 'update');
      expect(updateOp.args[0], equals({'is_active': true}));
      final eqOp = ops.firstWhere((op) => op.method == 'eq');
      expect(eqOp.args[0], equals('id'));
      expect(eqOp.args[1], equals('u1'));
    });
  });

  // ==========================================================================
  // isUserOnline
  // ==========================================================================

  group('isUserOnline', () {
    test('returns true when user logged in less than 5 minutes ago', () {
      final user = SAUserFactory.online(id: 'u1');
      expect(ds.isUserOnline(user), isTrue);
    });

    test('returns false when user has no lastLoginAt', () {
      final user = SAUserFactory.create(id: 'u1', lastLoginAt: null);
      expect(ds.isUserOnline(user), isFalse);
    });

    test('returns false when user logged in more than 5 minutes ago', () {
      final old = DateTime.now().subtract(const Duration(minutes: 10));
      final user = SAUserFactory.create(
        id: 'u1',
        lastLoginAt: old.toIso8601String(),
      );
      expect(ds.isUserOnline(user), isFalse);
    });
  });

  // ==========================================================================
  // formatLastActive
  // ==========================================================================

  group('formatLastActive', () {
    test('returns "Never" for null input', () {
      expect(ds.formatLastActive(null), equals('Never'));
    });

    test('returns "Unknown" for unparseable string', () {
      expect(ds.formatLastActive('not-a-date'), equals('Unknown'));
    });

    test('returns "Just now" for less than 5 minutes ago', () {
      final recent = DateTime.now().subtract(const Duration(minutes: 2));
      expect(ds.formatLastActive(recent.toIso8601String()), equals('Just now'));
    });

    test('returns "X min ago" for 5-59 minutes ago', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 15));
      expect(ds.formatLastActive(dt.toIso8601String()), equals('15 min ago'));
    });

    test('returns "X hr ago" for 1-23 hours ago', () {
      final dt = DateTime.now().subtract(const Duration(hours: 3));
      expect(ds.formatLastActive(dt.toIso8601String()), equals('3 hr ago'));
    });

    test('returns "X days ago" for 1-6 days ago', () {
      final dt = DateTime.now().subtract(const Duration(days: 4));
      expect(ds.formatLastActive(dt.toIso8601String()), equals('4 days ago'));
    });

    test('returns formatted date for 7+ days ago', () {
      final result = ds.formatLastActive('2024-03-15T12:00:00Z');
      expect(result, equals('2024-03-15'));
    });
  });

  // ==========================================================================
  // Error handling
  // ==========================================================================

  group('error handling', () {
    test('getPlatformUsers propagates errors', () async {
      // Arrange
      mock.setError('users', Exception('Table not found'));

      // Act & Assert
      expect(
        () => ds.getPlatformUsers(),
        throwsA(isA<Exception>()),
      );
    });

    test('getUser propagates errors', () async {
      // Arrange
      mock.setError('users', Exception('Connection failed'));

      // Act & Assert
      expect(
        () => ds.getUser('u1'),
        throwsA(isA<Exception>()),
      );
    });

    test('getTotalUserCount propagates errors', () async {
      // Arrange
      mock.setError('users', Exception('Table does not exist'));

      // Act & Assert
      expect(
        () => ds.getTotalUserCount(),
        throwsA(isA<Exception>()),
      );
    });

    test('softDeleteUser propagates errors', () async {
      // Arrange
      mock.setError('users', Exception('Permission denied'));

      // Act & Assert
      expect(
        () => ds.softDeleteUser('u1'),
        throwsA(isA<Exception>()),
      );
    });
  });
}
