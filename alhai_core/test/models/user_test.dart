import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('User Model', () {
    test('should return correct initials for two-word name', () {
      final user = User(
        id: '1',
        phone: '+966501234567',
        name: 'Mohammed Ali',
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );

      expect(user.initials, 'MA');
    });

    test('should return correct initials for single-word name', () {
      final user = User(
        id: '1',
        phone: '+966501234567',
        name: 'Mohammed',
        role: UserRole.customer,
        createdAt: DateTime.now(),
      );

      expect(user.initials, 'M');
    });

    test('should detect admin role correctly', () {
      final admin = User(
        id: '1',
        phone: '+966501234567',
        name: 'Admin',
        role: UserRole.superAdmin,
        createdAt: DateTime.now(),
      );

      expect(admin.isAdmin, isTrue);
      expect(admin.canManageStore, isTrue);
    });

    test('should detect store owner correctly', () {
      final owner = User(
        id: '1',
        phone: '+966501234567',
        name: 'Owner',
        role: UserRole.storeOwner,
        createdAt: DateTime.now(),
      );

      expect(owner.isStoreOwner, isTrue);
      expect(owner.canManageStore, isTrue);
    });

    test('should detect delivery role correctly', () {
      final driver = User(
        id: '1',
        phone: '+966501234567',
        name: 'Driver',
        role: UserRole.delivery,
        createdAt: DateTime.now(),
      );

      expect(driver.isDelivery, isTrue);
      expect(driver.canManageStore, isFalse);
    });
  });
}
