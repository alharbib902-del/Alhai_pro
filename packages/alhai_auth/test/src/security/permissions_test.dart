/// Unit tests for the Wave 9 (P0-02 + P0-28) `Permissions` class.
library;

import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:flutter_test/flutter_test.dart';

User _user(UserRole role) => User(
      id: 'u-${role.name}',
      phone: '+966500000000',
      name: 'Test ${role.name}',
      role: role,
      createdAt: DateTime(2025),
    );

void main() {
  group('Permissions', () {
    group('identity buckets', () {
      test('isSuperAdmin', () {
        expect(Permissions.isSuperAdmin(_user(UserRole.superAdmin)), isTrue);
        expect(Permissions.isSuperAdmin(_user(UserRole.storeOwner)), isFalse);
        expect(Permissions.isSuperAdmin(_user(UserRole.employee)), isFalse);
        expect(Permissions.isSuperAdmin(null), isFalse);
      });

      test('isStoreOwner', () {
        expect(Permissions.isStoreOwner(_user(UserRole.storeOwner)), isTrue);
        expect(Permissions.isStoreOwner(_user(UserRole.superAdmin)), isFalse);
        expect(Permissions.isStoreOwner(null), isFalse);
      });

      test('isAnyAdmin covers super + owner', () {
        expect(Permissions.isAnyAdmin(_user(UserRole.superAdmin)), isTrue);
        expect(Permissions.isAnyAdmin(_user(UserRole.storeOwner)), isTrue);
        expect(Permissions.isAnyAdmin(_user(UserRole.employee)), isFalse);
        expect(Permissions.isAnyAdmin(_user(UserRole.delivery)), isFalse);
        expect(Permissions.isAnyAdmin(_user(UserRole.customer)), isFalse);
        expect(Permissions.isAnyAdmin(null), isFalse);
      });
    });

    group('admin-only capabilities reject non-admins', () {
      // Wave 9 (P0-02/28): every gate that depends on isAnyAdmin must
      // refuse employees, drivers, customers, and unauthenticated users.
      // Looping the table so a future role addition can't accidentally
      // gain one of these capabilities by inheriting the default true.
      final checks = <String, bool Function(User?)>{
        'canViewCustomerLedger': Permissions.canViewCustomerLedger,
        'canAdjustCustomerAccount': Permissions.canAdjustCustomerAccount,
        'canViewOtherUserPii': Permissions.canViewOtherUserPii,
        'canEditSalePrice': Permissions.canEditSalePrice,
        'canOverrideDiscountCap': Permissions.canOverrideDiscountCap,
        'canVoidSale': Permissions.canVoidSale,
        'canRecordStockAdjustment': Permissions.canRecordStockAdjustment,
        'canRunStockTake': Permissions.canRunStockTake,
        'canTransferStock': Permissions.canTransferStock,
        'canForceCloseShift': Permissions.canForceCloseShift,
        'canManageUsers': Permissions.canManageUsers,
        'canEditStoreSettings': Permissions.canEditStoreSettings,
        'canManageBackups': Permissions.canManageBackups,
      };

      for (final entry in checks.entries) {
        test('${entry.key} — admin yes / non-admin no / null no', () {
          expect(entry.value(_user(UserRole.superAdmin)), isTrue);
          expect(entry.value(_user(UserRole.storeOwner)), isTrue);
          expect(entry.value(_user(UserRole.employee)), isFalse);
          expect(entry.value(_user(UserRole.delivery)), isFalse);
          expect(entry.value(_user(UserRole.customer)), isFalse);
          expect(entry.value(null), isFalse);
        });
      }
    });

    group('any-authenticated capabilities', () {
      test('canReceiveStock allows any logged-in role', () {
        expect(Permissions.canReceiveStock(_user(UserRole.employee)), isTrue);
        expect(Permissions.canReceiveStock(_user(UserRole.storeOwner)), isTrue);
        expect(Permissions.canReceiveStock(null), isFalse);
      });

      test('canOpenShift allows any logged-in role', () {
        expect(Permissions.canOpenShift(_user(UserRole.employee)), isTrue);
        expect(Permissions.canOpenShift(null), isFalse);
      });

      test('canCloseShift allows any logged-in role', () {
        expect(Permissions.canCloseShift(_user(UserRole.employee)), isTrue);
        expect(Permissions.canCloseShift(null), isFalse);
      });
    });
  });
}
