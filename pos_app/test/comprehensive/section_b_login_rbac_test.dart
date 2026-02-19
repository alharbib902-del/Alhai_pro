/// اختبارات قسم B: تسجيل الدخول / التحكم بالوصول (RBAC)
///
/// 6 اختبارات تغطي:
/// - B01: تسجيل دخول ناجح
/// - B02: فشل تسجيل الدخول
/// - B03: انتهاء الجلسة
/// - B04: الكاشير لا يستطيع الوصول للتقارير
/// - B05: المدير يملك صلاحيات التجاوز
/// - B06: عزل المبيعات بين الفروع
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_core/alhai_core.dart' hide CartItem, UserRole;
import 'package:pos_app/providers/auth_providers.dart';
import 'package:pos_app/services/permissions_service.dart';
import 'package:pos_app/services/sync/sync_service.dart' show SyncPriority;
import 'package:pos_app/providers/cart_providers.dart';

import 'fixtures/test_fixtures.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(SyncPriority.normal);
  });

  group('Section B: Login / RBAC', () {
    // ================================================================
    // B01-B02: تسجيل الدخول (نجاح / فشل)
    // ================================================================

    group('B01-B02 تسجيل الدخول', () {
      test('B01 تسجيل دخول ناجح: الحالة authenticated و isAuthenticated=true', () {
        // Arrange
        final state = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: DateTime.now().add(const Duration(minutes: 30)),
        );

        // Act & Assert
        expect(state.status, AuthStatus.authenticated);
        expect(state.isAuthenticated, isTrue);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
        expect(state.isSessionValid, isTrue);
      });

      test('B02 فشل تسجيل الدخول: الحالة unauthenticated مع رسالة خطأ', () {
        // Arrange
        const errorMessage = 'رمز OTP غير صحيح';
        final state = AuthState(
          status: AuthStatus.unauthenticated,
          error: errorMessage,
        );

        // Act & Assert
        expect(state.status, AuthStatus.unauthenticated);
        expect(state.isAuthenticated, isFalse);
        expect(state.error, errorMessage);
        expect(state.isSessionValid, isFalse);

        // التحقق من copyWith لمسح الخطأ
        final cleared = state.copyWith(clearError: true);
        expect(cleared.error, isNull);
        expect(cleared.status, AuthStatus.unauthenticated);
      });
    });

    // ================================================================
    // B03: انتهاء الجلسة
    // ================================================================

    group('B03 انتهاء الجلسة', () {
      test('B03 الجلسة المنتهية isSessionValid=false والجلسة الصالحة isSessionValid=true', () {
        // Arrange - جلسة منتهية (في الماضي)
        final expiredState = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: DateTime.now().subtract(const Duration(minutes: 5)),
        );

        // Assert - الجلسة المنتهية
        expect(expiredState.isSessionValid, isFalse);

        // Arrange - جلسة صالحة (في المستقبل)
        final validState = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: DateTime.now().add(const Duration(minutes: 25)),
        );

        // Assert - الجلسة الصالحة
        expect(validState.isSessionValid, isTrue);

        // Arrange - بدون تاريخ انتهاء
        const noExpiryState = AuthState(
          status: AuthStatus.authenticated,
        );

        // Assert - بدون تاريخ انتهاء → غير صالحة
        expect(noExpiryState.isSessionValid, isFalse);

        // التحقق من needsRefresh
        final nearExpiryState = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: DateTime.now().add(const Duration(minutes: 3)),
        );
        // 3 دقائق < 5 دقائق (kTokenRefreshBuffer) → يحتاج تجديد
        expect(nearExpiryState.needsRefresh, isTrue);

        final farExpiryState = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: DateTime.now().add(const Duration(minutes: 20)),
        );
        // 20 دقيقة > 5 دقائق → لا يحتاج تجديد
        expect(farExpiryState.needsRefresh, isFalse);
      });
    });

    // ================================================================
    // B04-B05: صلاحيات الأدوار (RBAC)
    // ================================================================

    group('B04-B05 صلاحيات الأدوار', () {
      test('B04 الكاشير لا يستطيع الوصول للتقارير الكاملة ولا تصدير التقارير', () {
        // Arrange
        const role = UserRole.cashier;

        // Act & Assert - الكاشير لا يملك صلاحيات التقارير
        expect(
          RolePermissions.hasPermission(role, Permission.viewFullReports),
          isFalse,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.exportReports),
          isFalse,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.viewBasicReports),
          isFalse,
        );

        // الكاشير يملك صلاحيات البيع الأساسية
        expect(
          RolePermissions.hasPermission(role, Permission.createSale),
          isTrue,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.viewSales),
          isTrue,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.viewProducts),
          isTrue,
        );

        // الكاشير لا يملك صلاحيات الإدارة
        expect(
          RolePermissions.hasPermission(role, Permission.editSettings),
          isFalse,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.manageUsers),
          isFalse,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.deleteProduct),
          isFalse,
        );

        // التحقق عبر CurrentUser
        const cashier = CurrentUser(
          id: uCashierId,
          name: 'كاشير اختبار',
          role: UserRole.cashier,
          storeId: 'store-1',
        );
        expect(cashier.canViewReports, isFalse);
        expect(cashier.canManageUsers, isFalse);
        expect(cashier.isCashier, isTrue);
      });

      test('B05 المدير يملك صلاحيات التجاوز والموافقة والتقارير الكاملة', () {
        // Arrange
        const role = UserRole.manager;

        // Act & Assert - المدير يملك صلاحيات التقارير الكاملة
        expect(
          RolePermissions.hasPermission(role, Permission.viewFullReports),
          isTrue,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.exportReports),
          isTrue,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.viewBasicReports),
          isTrue,
        );

        // المدير يملك صلاحيات التجاوز
        expect(
          RolePermissions.hasPermission(role, Permission.approveRefund),
          isTrue,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.applyLargeDiscount),
          isTrue,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.adjustInventory),
          isTrue,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.editSettings),
          isTrue,
        );

        // المدير لا يملك صلاحيات المالك الحصرية
        expect(
          RolePermissions.hasPermission(role, Permission.deleteProduct),
          isFalse,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.manageUsers),
          isFalse,
        );
        expect(
          RolePermissions.hasPermission(role, Permission.viewProfits),
          isFalse,
        );

        // التحقق عبر CurrentUser
        const manager = CurrentUser(
          id: uManagerId,
          name: 'مدير اختبار',
          role: UserRole.manager,
          storeId: 'store-1',
        );
        expect(manager.canViewReports, isTrue);
        expect(manager.canApproveRefunds, isTrue);
        expect(manager.canManageInventory, isTrue);
        expect(manager.isManager, isTrue);
        expect(manager.canManageUsers, isFalse);
      });
    });

    // ================================================================
    // B06: عزل المبيعات بين الفروع
    // ================================================================

    group('B06 عزل الفروع', () {
      late SaleServiceTestSetup setup;

      setUp(() async {
        setup = createSaleServiceSetup();
        await seedAllProducts(setup.db);
      });

      tearDown(() async {
        await setup.dispose();
      });

      test('B06 مبيعات المتجر 1 لا تظهر في المتجر 2 والعكس', () async {
        final p1 = createP1();

        // Arrange - إنشاء بيع في المتجر الأول
        await createCompletedSale(
          saleService: setup.saleService,
          items: [PosCartItem(product: p1, quantity: 2)],
          subtotal: 14.00,
          discount: 0,
          tax: 2.10,
          total: 16.10,
          storeId: 'store-1',
          cashierId: 'cashier-1',
        );

        // Arrange - إنشاء بيع في المتجر الثاني
        await createCompletedSale(
          saleService: setup.saleService,
          items: [PosCartItem(product: p1, quantity: 3)],
          subtotal: 21.00,
          discount: 0,
          tax: 3.15,
          total: 24.15,
          storeId: 'store-2',
          cashierId: 'cashier-2',
        );

        // إنشاء بيع ثانٍ في المتجر الأول
        await createCompletedSale(
          saleService: setup.saleService,
          items: [PosCartItem(product: p1, quantity: 1)],
          subtotal: 7.00,
          discount: 0,
          tax: 1.05,
          total: 8.05,
          storeId: 'store-1',
          cashierId: 'cashier-1',
        );

        // Act - استعلام مبيعات كل متجر
        final store1Sales = await setup.saleService.getTodaySales('store-1');
        final store2Sales = await setup.saleService.getTodaySales('store-2');

        // Assert - المتجر الأول يحتوي على 2 مبيعات فقط
        expect(store1Sales.length, 2);

        // Assert - المتجر الثاني يحتوي على 1 بيع فقط
        expect(store2Sales.length, 1);

        // Assert - مبيعات المتجر 1 تخص المتجر 1 فقط
        for (final sale in store1Sales) {
          expect(sale.storeId, 'store-1');
        }

        // Assert - مبيعات المتجر 2 تخص المتجر 2 فقط
        for (final sale in store2Sales) {
          expect(sale.storeId, 'store-2');
        }

        // Assert - التحقق من الإجماليات
        final store1Total = store1Sales.fold<double>(0, (s, sale) => s + sale.total);
        final store2Total = store2Sales.fold<double>(0, (s, sale) => s + sale.total);

        expect(roundSar(store1Total), 24.15); // 16.10 + 8.05
        expect(roundSar(store2Total), 24.15); // 24.15
      });
    });
  });
}
