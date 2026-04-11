import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_core/src/models/enums/user_role.dart';
import 'package:alhai_core/src/repositories/store_members_repository.dart';

/// Tests for StoreMember, StorePermissions classes
/// defined in store_members_repository.dart.
/// StoreMembersRepository is an abstract interface - no implementation to test yet.
void main() {
  group('StoreMember Model', () {
    test('should construct with all required fields', () {
      final member = StoreMember(
        id: 'member-1',
        storeId: 'store-1',
        userId: 'user-1',
        userName: 'Ahmed',
        userPhone: '+966500000001',
        role: UserRole.employee,
        permissions: [
          StorePermissions.manageProducts,
          StorePermissions.manageOrders,
        ],
        isActive: true,
        joinedAt: DateTime(2026, 1, 15),
      );

      expect(member.id, equals('member-1'));
      expect(member.storeId, equals('store-1'));
      expect(member.userId, equals('user-1'));
      expect(member.userName, equals('Ahmed'));
      expect(member.role, equals(UserRole.employee));
      expect(member.permissions, hasLength(2));
      expect(member.isActive, isTrue);
    });

    test('should have null optional fields by default', () {
      final member = StoreMember(
        id: 'member-1',
        storeId: 'store-1',
        userId: 'user-1',
        role: UserRole.employee,
        permissions: const [],
        isActive: true,
        joinedAt: DateTime(2026, 1, 15),
      );

      expect(member.userName, isNull);
      expect(member.userPhone, isNull);
      expect(member.nickname, isNull);
      expect(member.lastActiveAt, isNull);
    });

    test('should support empty permissions list', () {
      final member = StoreMember(
        id: 'member-1',
        storeId: 'store-1',
        userId: 'user-1',
        role: UserRole.employee,
        permissions: const [],
        isActive: true,
        joinedAt: DateTime(2026, 1, 15),
      );

      expect(member.permissions, isEmpty);
    });
  });

  group('StorePermissions', () {
    test('should have all expected permission constants', () {
      expect(StorePermissions.viewDashboard, equals('view_dashboard'));
      expect(StorePermissions.manageProducts, equals('manage_products'));
      expect(StorePermissions.manageOrders, equals('manage_orders'));
      expect(StorePermissions.manageInventory, equals('manage_inventory'));
      expect(StorePermissions.manageCustomers, equals('manage_customers'));
      expect(StorePermissions.viewReports, equals('view_reports'));
      expect(StorePermissions.manageRefunds, equals('manage_refunds'));
      expect(StorePermissions.manageDiscounts, equals('manage_discounts'));
      expect(StorePermissions.manageCashDrawer, equals('manage_cash_drawer'));
      expect(StorePermissions.manageMembers, equals('manage_members'));
      expect(StorePermissions.manageSettings, equals('manage_settings'));
    });

    test('all should return list of all permissions', () {
      final all = StorePermissions.all;

      expect(all, hasLength(11));
      expect(all, contains(StorePermissions.viewDashboard));
      expect(all, contains(StorePermissions.manageProducts));
      expect(all, contains(StorePermissions.manageSettings));
    });
  });
}
