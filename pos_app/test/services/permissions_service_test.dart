import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/services/permissions_service.dart';

// ===========================================
// Permissions Service Tests
// ===========================================

void main() {
  group('UserRole', () {
    test('يحتوي على جميع الأدوار', () {
      expect(UserRole.values.length, 4);
      expect(UserRole.values, contains(UserRole.cashier));
      expect(UserRole.values, contains(UserRole.supervisor));
      expect(UserRole.values, contains(UserRole.manager));
      expect(UserRole.values, contains(UserRole.owner));
    });
  });

  group('Permission', () {
    test('يحتوي على جميع الصلاحيات', () {
      // التحقق من وجود صلاحيات المبيعات
      expect(Permission.values, contains(Permission.createSale));
      expect(Permission.values, contains(Permission.viewSales));
      expect(Permission.values, contains(Permission.cancelSale));
      expect(Permission.values, contains(Permission.applyDiscount));
      expect(Permission.values, contains(Permission.applyLargeDiscount));

      // صلاحيات المرتجعات
      expect(Permission.values, contains(Permission.createRefund));
      expect(Permission.values, contains(Permission.approveRefund));

      // صلاحيات المنتجات
      expect(Permission.values, contains(Permission.viewProducts));
      expect(Permission.values, contains(Permission.createProduct));
      expect(Permission.values, contains(Permission.editProduct));
      expect(Permission.values, contains(Permission.deleteProduct));

      // صلاحيات المخزون
      expect(Permission.values, contains(Permission.viewInventory));
      expect(Permission.values, contains(Permission.adjustInventory));

      // صلاحيات المالية
      expect(Permission.values, contains(Permission.viewCashDrawer));
      expect(Permission.values, contains(Permission.openCloseShift));
      expect(Permission.values, contains(Permission.viewProfits));
    });
  });

  group('RolePermissions', () {
    group('hasPermission', () {
      test('الكاشير له صلاحيات البيع الأساسية', () {
        expect(RolePermissions.hasPermission(UserRole.cashier, Permission.createSale), isTrue);
        expect(RolePermissions.hasPermission(UserRole.cashier, Permission.viewSales), isTrue);
        expect(RolePermissions.hasPermission(UserRole.cashier, Permission.applyDiscount), isTrue);
        expect(RolePermissions.hasPermission(UserRole.cashier, Permission.openCloseShift), isTrue);
      });

      test('الكاشير ليس له صلاحيات متقدمة', () {
        expect(RolePermissions.hasPermission(UserRole.cashier, Permission.cancelSale), isFalse);
        expect(RolePermissions.hasPermission(UserRole.cashier, Permission.createRefund), isFalse);
        expect(RolePermissions.hasPermission(UserRole.cashier, Permission.applyLargeDiscount), isFalse);
        expect(RolePermissions.hasPermission(UserRole.cashier, Permission.manageUsers), isFalse);
      });

      test('المشرف له صلاحيات أكثر من الكاشير', () {
        expect(RolePermissions.hasPermission(UserRole.supervisor, Permission.cancelSale), isTrue);
        expect(RolePermissions.hasPermission(UserRole.supervisor, Permission.createRefund), isTrue);
        expect(RolePermissions.hasPermission(UserRole.supervisor, Permission.applyLargeDiscount), isTrue);
        expect(RolePermissions.hasPermission(UserRole.supervisor, Permission.viewInventory), isTrue);
      });

      test('المشرف ليس له صلاحيات الإدارة', () {
        expect(RolePermissions.hasPermission(UserRole.supervisor, Permission.manageUsers), isFalse);
        expect(RolePermissions.hasPermission(UserRole.supervisor, Permission.deleteProduct), isFalse);
        expect(RolePermissions.hasPermission(UserRole.supervisor, Permission.editSettings), isFalse);
      });

      test('المدير له معظم الصلاحيات', () {
        expect(RolePermissions.hasPermission(UserRole.manager, Permission.approveRefund), isTrue);
        expect(RolePermissions.hasPermission(UserRole.manager, Permission.createProduct), isTrue);
        expect(RolePermissions.hasPermission(UserRole.manager, Permission.editProduct), isTrue);
        expect(RolePermissions.hasPermission(UserRole.manager, Permission.adjustInventory), isTrue);
        expect(RolePermissions.hasPermission(UserRole.manager, Permission.editSettings), isTrue);
      });

      test('المدير ليس له صلاحيات المالك', () {
        expect(RolePermissions.hasPermission(UserRole.manager, Permission.deleteProduct), isFalse);
        expect(RolePermissions.hasPermission(UserRole.manager, Permission.manageUsers), isFalse);
        expect(RolePermissions.hasPermission(UserRole.manager, Permission.viewProfits), isFalse);
      });

      test('المالك له كل الصلاحيات', () {
        for (final permission in Permission.values) {
          expect(
            RolePermissions.hasPermission(UserRole.owner, permission),
            isTrue,
            reason: 'المالك يجب أن يملك صلاحية $permission',
          );
        }
      });
    });

    group('getPermissions', () {
      test('يُرجع مجموعة صلاحيات الكاشير', () {
        final permissions = RolePermissions.getPermissions(UserRole.cashier);
        expect(permissions, isNotEmpty);
        expect(permissions, contains(Permission.createSale));
        expect(permissions, isNot(contains(Permission.manageUsers)));
      });

      test('صلاحيات المالك أكثر من المدير', () {
        final ownerPermissions = RolePermissions.getPermissions(UserRole.owner);
        final managerPermissions = RolePermissions.getPermissions(UserRole.manager);
        expect(ownerPermissions.length, greaterThan(managerPermissions.length));
      });

      test('صلاحيات المدير أكثر من المشرف', () {
        final managerPermissions = RolePermissions.getPermissions(UserRole.manager);
        final supervisorPermissions = RolePermissions.getPermissions(UserRole.supervisor);
        expect(managerPermissions.length, greaterThan(supervisorPermissions.length));
      });

      test('صلاحيات المشرف أكثر من الكاشير', () {
        final supervisorPermissions = RolePermissions.getPermissions(UserRole.supervisor);
        final cashierPermissions = RolePermissions.getPermissions(UserRole.cashier);
        expect(supervisorPermissions.length, greaterThan(cashierPermissions.length));
      });
    });

    group('getRoleName', () {
      test('يُرجع اسم الدور بالعربية', () {
        expect(RolePermissions.getRoleName(UserRole.cashier), 'كاشير');
        expect(RolePermissions.getRoleName(UserRole.supervisor), 'مشرف');
        expect(RolePermissions.getRoleName(UserRole.manager), 'مدير');
        expect(RolePermissions.getRoleName(UserRole.owner), 'مالك');
      });
    });
  });

  group('CurrentUser', () {
    test('يُنشئ مستخدم بشكل صحيح', () {
      const user = CurrentUser(
        id: 'user_001',
        name: 'محمد',
        role: UserRole.cashier,
        storeId: 'store_001',
      );

      expect(user.id, 'user_001');
      expect(user.name, 'محمد');
      expect(user.role, UserRole.cashier);
      expect(user.storeId, 'store_001');
    });

    group('hasPermission', () {
      test('الكاشير له صلاحية البيع', () {
        const user = CurrentUser(
          id: 'user_001',
          name: 'محمد',
          role: UserRole.cashier,
          storeId: 'store_001',
        );

        expect(user.hasPermission(Permission.createSale), isTrue);
        expect(user.hasPermission(Permission.manageUsers), isFalse);
      });

      test('المالك له كل الصلاحيات', () {
        const user = CurrentUser(
          id: 'user_001',
          name: 'أحمد',
          role: UserRole.owner,
          storeId: 'store_001',
        );

        expect(user.hasPermission(Permission.createSale), isTrue);
        expect(user.hasPermission(Permission.manageUsers), isTrue);
        expect(user.hasPermission(Permission.deleteProduct), isTrue);
      });
    });

    group('role checks', () {
      test('يُحدد الكاشير بشكل صحيح', () {
        const user = CurrentUser(
          id: 'user_001',
          name: 'محمد',
          role: UserRole.cashier,
          storeId: 'store_001',
        );

        expect(user.isCashier, isTrue);
        expect(user.isSupervisor, isFalse);
        expect(user.isManager, isFalse);
        expect(user.isOwner, isFalse);
      });

      test('يُحدد المشرف بشكل صحيح', () {
        const user = CurrentUser(
          id: 'user_001',
          name: 'علي',
          role: UserRole.supervisor,
          storeId: 'store_001',
        );

        expect(user.isCashier, isFalse);
        expect(user.isSupervisor, isTrue);
        expect(user.isManager, isFalse);
        expect(user.isOwner, isFalse);
      });

      test('يُحدد المدير بشكل صحيح', () {
        const user = CurrentUser(
          id: 'user_001',
          name: 'خالد',
          role: UserRole.manager,
          storeId: 'store_001',
        );

        expect(user.isCashier, isFalse);
        expect(user.isSupervisor, isFalse);
        expect(user.isManager, isTrue);
        expect(user.isOwner, isFalse);
      });

      test('يُحدد المالك بشكل صحيح', () {
        const user = CurrentUser(
          id: 'user_001',
          name: 'سعود',
          role: UserRole.owner,
          storeId: 'store_001',
        );

        expect(user.isCashier, isFalse);
        expect(user.isSupervisor, isFalse);
        expect(user.isManager, isFalse);
        expect(user.isOwner, isTrue);
      });
    });

    group('convenience getters', () {
      test('canManageInventory للكاشير', () {
        const cashier = CurrentUser(
          id: 'user_001',
          name: 'محمد',
          role: UserRole.cashier,
          storeId: 'store_001',
        );

        expect(cashier.canManageInventory, isFalse);
      });

      test('canManageInventory للمدير', () {
        const manager = CurrentUser(
          id: 'user_001',
          name: 'خالد',
          role: UserRole.manager,
          storeId: 'store_001',
        );

        expect(manager.canManageInventory, isTrue);
      });

      test('canApproveRefunds للمشرف', () {
        const supervisor = CurrentUser(
          id: 'user_001',
          name: 'علي',
          role: UserRole.supervisor,
          storeId: 'store_001',
        );

        expect(supervisor.canApproveRefunds, isFalse);
      });

      test('canApproveRefunds للمدير', () {
        const manager = CurrentUser(
          id: 'user_001',
          name: 'خالد',
          role: UserRole.manager,
          storeId: 'store_001',
        );

        expect(manager.canApproveRefunds, isTrue);
      });

      test('canViewReports للكاشير', () {
        const cashier = CurrentUser(
          id: 'user_001',
          name: 'محمد',
          role: UserRole.cashier,
          storeId: 'store_001',
        );

        expect(cashier.canViewReports, isFalse);
      });

      test('canViewReports للمشرف', () {
        const supervisor = CurrentUser(
          id: 'user_001',
          name: 'علي',
          role: UserRole.supervisor,
          storeId: 'store_001',
        );

        expect(supervisor.canViewReports, isTrue);
      });

      test('canManageUsers للمدير', () {
        const manager = CurrentUser(
          id: 'user_001',
          name: 'خالد',
          role: UserRole.manager,
          storeId: 'store_001',
        );

        expect(manager.canManageUsers, isFalse);
      });

      test('canManageUsers للمالك', () {
        const owner = CurrentUser(
          id: 'user_001',
          name: 'سعود',
          role: UserRole.owner,
          storeId: 'store_001',
        );

        expect(owner.canManageUsers, isTrue);
      });
    });
  });
}
