import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';

/// Tests for [parseUserRoleFromDb], the pure role-mapping helper used
/// by `AuthNotifier._resolveUserRole` to translate a `public.users.role`
/// DB value into a [UserRole] enum.
///
/// P0 auth guard regression coverage:
///   a) super-admin login resolves to UserRole.superAdmin
///   b) normal employee login resolves to UserRole.employee
///   c) missing user row → safe default (employee)
///   d) role change after token refresh is picked up (same parser
///      re-invoked with the new DB value yields the new enum)
void main() {
  group('parseUserRoleFromDb - P0 role resolution', () {
    test('(a) super admin login resolves to UserRole.superAdmin', () {
      // Arrange: DB canonical snake_case value
      const dbValue = 'super_admin';

      // Act
      final result = parseUserRoleFromDb(dbValue);

      // Assert
      expect(result, UserRole.superAdmin);
    });

    test('(b) normal employee login resolves to UserRole.employee', () {
      expect(parseUserRoleFromDb('employee'), UserRole.employee);
    });

    test('(c) missing user row (null) → safe default employee', () {
      expect(parseUserRoleFromDb(null), kDefaultUserRole);
      expect(kDefaultUserRole, UserRole.employee,
          reason: 'Safe default must be the lowest-privilege role so that '
              'any super-admin gating still refuses unknown users.');
    });

    test('(c2) empty string row → safe default employee', () {
      expect(parseUserRoleFromDb(''), UserRole.employee);
      expect(parseUserRoleFromDb('   '), UserRole.employee);
    });

    test('(c3) unknown role value → safe default employee', () {
      expect(parseUserRoleFromDb('ceo'), UserRole.employee);
      expect(parseUserRoleFromDb('root'), UserRole.employee);
    });

    test(
        '(d) role change after token refresh is picked up '
        '(same helper returns new enum when DB value changes)', () {
      // Simulate: user was employee, then promoted to super_admin on
      // the server. On the next tokenRefreshed event, _resolveUserRole
      // re-queries public.users.role and re-invokes this parser.
      var dbRole = 'employee';
      expect(parseUserRoleFromDb(dbRole), UserRole.employee);

      // Promotion happens server-side.
      dbRole = 'super_admin';
      expect(parseUserRoleFromDb(dbRole), UserRole.superAdmin);

      // Demotion also propagates.
      dbRole = 'employee';
      expect(parseUserRoleFromDb(dbRole), UserRole.employee);
    });
  });

  group('parseUserRoleFromDb - canonical DB snake_case', () {
    test('maps all known snake_case values', () {
      expect(parseUserRoleFromDb('super_admin'), UserRole.superAdmin);
      expect(parseUserRoleFromDb('store_owner'), UserRole.storeOwner);
      expect(parseUserRoleFromDb('employee'), UserRole.employee);
      expect(parseUserRoleFromDb('delivery'), UserRole.delivery);
      expect(parseUserRoleFromDb('customer'), UserRole.customer);
    });
  });

  group('parseUserRoleFromDb - robustness', () {
    test('is case insensitive', () {
      expect(parseUserRoleFromDb('SUPER_ADMIN'), UserRole.superAdmin);
      expect(parseUserRoleFromDb('Store_Owner'), UserRole.storeOwner);
      expect(parseUserRoleFromDb('EMPLOYEE'), UserRole.employee);
    });

    test('trims whitespace', () {
      expect(parseUserRoleFromDb('  super_admin  '), UserRole.superAdmin);
    });

    test('accepts common aliases', () {
      expect(parseUserRoleFromDb('cashier'), UserRole.employee);
      expect(parseUserRoleFromDb('staff'), UserRole.employee);
      expect(parseUserRoleFromDb('owner'), UserRole.storeOwner);
      expect(parseUserRoleFromDb('driver'), UserRole.delivery);
    });

    test('accepts camelCase (Dart JSON) spellings as a safety net', () {
      expect(parseUserRoleFromDb('superAdmin'), UserRole.superAdmin);
      expect(parseUserRoleFromDb('storeOwner'), UserRole.storeOwner);
    });

    test('handles non-string inputs by calling toString()', () {
      expect(parseUserRoleFromDb(123), UserRole.employee);
    });
  });
}
