import 'package:flutter_test/flutter_test.dart';
import 'package:super_admin/data/models/sa_user_model.dart';

void main() {
  group('SAUser.fromJson', () {
    test('parses complete JSON correctly', () {
      // Arrange
      final json = {
        'id': 'user-001',
        'name': 'Ahmed Ali',
        'phone': '+966500000000',
        'email': 'ahmed@test.com',
        'role': 'storeOwner',
        'created_at': '2024-01-15T10:00:00.000Z',
        'last_login_at': '2024-06-01T08:00:00.000Z',
        'is_active': true,
        'store_id': 'store-001',
      };

      // Act
      final user = SAUser.fromJson(json);

      // Assert
      expect(user.id, equals('user-001'));
      expect(user.name, equals('Ahmed Ali'));
      expect(user.phone, equals('+966500000000'));
      expect(user.email, equals('ahmed@test.com'));
      expect(user.role, equals('storeOwner'));
      expect(user.createdAt, equals('2024-01-15T10:00:00.000Z'));
      expect(user.lastLoginAt, equals('2024-06-01T08:00:00.000Z'));
      expect(user.isActive, isTrue);
      expect(user.storeId, equals('store-001'));
    });

    test('handles missing fields gracefully', () {
      // Arrange
      final json = <String, dynamic>{'id': null};

      // Act
      final user = SAUser.fromJson(json);

      // Assert
      expect(user.id, equals(''));
      expect(user.name, isNull);
      expect(user.phone, isNull);
      expect(user.email, isNull);
      expect(user.role, isNull);
      expect(user.isActive, isNull);
      expect(user.storeId, isNull);
    });
  });

  group('SAUser.toJson', () {
    test('serializes all fields', () {
      const user = SAUser(
        id: 'u1',
        name: 'Test',
        phone: '+966511111111',
        email: 'test@test.com',
        role: 'employee',
        createdAt: '2024-01-01T00:00:00Z',
        lastLoginAt: '2024-06-01T00:00:00Z',
        isActive: true,
        storeId: 'store-1',
      );

      final json = user.toJson();

      expect(json['id'], equals('u1'));
      expect(json['name'], equals('Test'));
      expect(json['phone'], equals('+966511111111'));
      expect(json['role'], equals('employee'));
      expect(json['is_active'], isTrue);
      expect(json['store_id'], equals('store-1'));
    });
  });

  group('SAUser.isOnline', () {
    test('returns true when last sign-in is within 5 minutes', () {
      final recentTime = DateTime.now()
          .subtract(const Duration(minutes: 2))
          .toIso8601String();

      final user = SAUser(id: 'u1', lastLoginAt: recentTime);

      expect(user.isOnline, isTrue);
    });

    test('returns false when last sign-in is older than 5 minutes', () {
      final oldTime = DateTime.now()
          .subtract(const Duration(minutes: 10))
          .toIso8601String();

      final user = SAUser(id: 'u2', lastLoginAt: oldTime);

      expect(user.isOnline, isFalse);
    });

    test('returns false when lastLoginAt is null', () {
      const user = SAUser(id: 'u3');
      expect(user.isOnline, isFalse);
    });

    test('returns false when lastLoginAt is unparseable', () {
      const user = SAUser(id: 'u4', lastLoginAt: 'not-a-date');
      expect(user.isOnline, isFalse);
    });
  });

  group('SAUser.lastActiveFormatted', () {
    test('returns "Just now" for recent sign-in (< 5 min)', () {
      final recentTime = DateTime.now()
          .subtract(const Duration(minutes: 1))
          .toIso8601String();

      final user = SAUser(id: 'u1', lastLoginAt: recentTime);
      expect(user.lastActiveFormatted, equals('Just now'));
    });

    test('returns minutes ago for sign-in between 5-59 min', () {
      final time = DateTime.now()
          .subtract(const Duration(minutes: 30))
          .toIso8601String();

      final user = SAUser(id: 'u2', lastLoginAt: time);
      expect(user.lastActiveFormatted, equals('30 min ago'));
    });

    test('returns hours ago for sign-in between 1-23 hours', () {
      final time = DateTime.now()
          .subtract(const Duration(hours: 3))
          .toIso8601String();

      final user = SAUser(id: 'u3', lastLoginAt: time);
      expect(user.lastActiveFormatted, equals('3 hr ago'));
    });

    test('returns days ago for sign-in between 1-6 days', () {
      final time = DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String();

      final user = SAUser(id: 'u4', lastLoginAt: time);
      expect(user.lastActiveFormatted, equals('3 days ago'));
    });

    test('returns formatted date for sign-in 7+ days ago', () {
      final time = DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String();

      final user = SAUser(id: 'u5', lastLoginAt: time);
      // Should be YYYY-MM-DD format
      expect(user.lastActiveFormatted, matches(RegExp(r'\d{4}-\d{2}-\d{2}')));
    });

    test('returns "Never" when lastLoginAt is null', () {
      const user = SAUser(id: 'u6');
      expect(user.lastActiveFormatted, equals('Never'));
    });

    test('returns "Unknown" when lastLoginAt is unparseable', () {
      const user = SAUser(id: 'u7', lastLoginAt: 'invalid');
      expect(user.lastActiveFormatted, equals('Unknown'));
    });
  });
}
