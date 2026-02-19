/// اختبارات تكامل مزودات الورديات - Shifts Providers Integration Tests
///
/// اختبارات تكامل تستخدم قاعدة بيانات SQLite في الذاكرة + Riverpod ProviderContainer
/// تختبر openShiftActionProvider, closeShiftActionProvider, addCashMovementProvider
///
/// 10 اختبارات تغطي:
/// - فتح وردية بنجاح
/// - فتح وردية تفشل بدون متجر
/// - فتح وردية تفشل إذا وردية مفتوحة موجودة
/// - إغلاق وردية بنجاح
/// - إضافة حركة نقدية بنجاح
/// - إضافة حركة نقدية تفشل بدون متجر
/// - قراءة الوردية المفتوحة
/// - قراءة ورديات اليوم
/// - قراءة حركات وردية
/// - عدم وجود وردية مفتوحة يعيد null
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_app/data/local/app_database.dart';
import 'package:pos_app/providers/shifts_providers.dart';
import 'package:pos_app/providers/products_providers.dart';

/// إنشاء قاعدة بيانات اختبار في الذاكرة
AppDatabase _createTestDb() => AppDatabase.forTesting(NativeDatabase.memory());

void main() {
  group('Shifts Providers Integration - اختبارات تكامل الورديات', () {
    late AppDatabase db;
    late GetIt getIt;

    setUp(() {
      db = _createTestDb();
      getIt = GetIt.instance;
      // تسجيل قاعدة البيانات في GetIt
      if (getIt.isRegistered<AppDatabase>()) {
        getIt.unregister<AppDatabase>();
      }
      getIt.registerSingleton<AppDatabase>(db);
    });

    tearDown(() async {
      await db.close();
      if (getIt.isRegistered<AppDatabase>()) {
        getIt.unregister<AppDatabase>();
      }
    });

    /// إنشاء ProviderContainer مع تعيين معرف المتجر
    ProviderContainer createContainer({String? storeId = 'store-test-1'}) {
      return ProviderContainer(
        overrides: [
          currentStoreIdProvider.overrideWith((ref) => storeId),
        ],
      );
    }

    // ========================================================================
    // اختبار فتح وردية بنجاح
    // ========================================================================

    test('openShiftActionProvider ينشئ وردية جديدة بنجاح', () async {
      // Arrange
      final container = createContainer();
      addTearDown(container.dispose);

      final openShiftAction = container.read(openShiftActionProvider);

      // Act
      final shiftId = await openShiftAction(
        openingCash: 500.0,
        cashierId: 'cashier-1',
        cashierName: 'أحمد',
      );

      // Assert
      expect(shiftId, isNotEmpty);

      // التحقق من وجود الوردية في قاعدة البيانات
      final shift = await db.shiftsDao.getShiftById(shiftId);
      expect(shift, isNotNull);
      expect(shift!.storeId, equals('store-test-1'));
      expect(shift.cashierId, equals('cashier-1'));
      expect(shift.cashierName, equals('أحمد'));
      expect(shift.openingCash, equals(500.0));
      expect(shift.status, equals('open'));
    });

    // ========================================================================
    // اختبار فتح وردية بدون متجر
    // ========================================================================

    test('openShiftActionProvider يرمي استثناء بدون متجر محدد', () async {
      // Arrange - بدون متجر
      final container = createContainer(storeId: null);
      addTearDown(container.dispose);

      final openShiftAction = container.read(openShiftActionProvider);

      // Act & Assert
      expect(
        () => openShiftAction(
          openingCash: 500.0,
          cashierId: 'cashier-1',
          cashierName: 'أحمد',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('لا يوجد متجر محدد'),
        )),
      );
    });

    // ========================================================================
    // اختبار فتح وردية عند وجود وردية مفتوحة
    // ========================================================================

    test('openShiftActionProvider يرمي استثناء إذا وردية مفتوحة موجودة', () async {
      // Arrange - فتح وردية أولى
      final container = createContainer();
      addTearDown(container.dispose);

      final openShiftAction = container.read(openShiftActionProvider);

      await openShiftAction(
        openingCash: 500.0,
        cashierId: 'cashier-1',
        cashierName: 'أحمد',
      );

      // Act & Assert - محاولة فتح وردية ثانية
      expect(
        () => openShiftAction(
          openingCash: 300.0,
          cashierId: 'cashier-2',
          cashierName: 'محمد',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('يوجد وردية مفتوحة بالفعل'),
        )),
      );
    });

    // ========================================================================
    // اختبار إغلاق وردية
    // ========================================================================

    test('closeShiftActionProvider يغلق الوردية بنجاح', () async {
      // Arrange
      final container = createContainer();
      addTearDown(container.dispose);

      final openShiftAction = container.read(openShiftActionProvider);
      final closeShiftAction = container.read(closeShiftActionProvider);

      final shiftId = await openShiftAction(
        openingCash: 500.0,
        cashierId: 'cashier-1',
        cashierName: 'أحمد',
      );

      // Act
      await closeShiftAction(
        shiftId: shiftId,
        closingCash: 1500.0,
        expectedCash: 1450.0,
        difference: 50.0,
        totalSales: 10,
        totalSalesAmount: 950.0,
        totalRefunds: 1,
        totalRefundsAmount: 50.0,
        notes: 'وردية جيدة',
      );

      // Assert
      final shift = await db.shiftsDao.getShiftById(shiftId);
      expect(shift, isNotNull);
      expect(shift!.status, equals('closed'));
      expect(shift.closingCash, equals(1500.0));
      expect(shift.expectedCash, equals(1450.0));
      expect(shift.difference, equals(50.0));
      expect(shift.totalSales, equals(10));
      expect(shift.notes, equals('وردية جيدة'));
    });

    // ========================================================================
    // اختبار إضافة حركة نقدية
    // ========================================================================

    test('addCashMovementProvider يضيف حركة نقدية بنجاح', () async {
      // Arrange
      final container = createContainer();
      addTearDown(container.dispose);

      // فتح وردية أولاً
      final openShiftAction = container.read(openShiftActionProvider);
      final shiftId = await openShiftAction(
        openingCash: 500.0,
        cashierId: 'cashier-1',
        cashierName: 'أحمد',
      );

      final addMovement = container.read(addCashMovementProvider);

      // Act
      await addMovement(
        shiftId: shiftId,
        type: 'cash_in',
        amount: 200.0,
        reason: 'إيداع نقدي',
        createdBy: 'cashier-1',
      );

      // Assert
      final movements = await db.shiftsDao.getShiftMovements(shiftId);
      expect(movements, hasLength(1));
      expect(movements.first.type, equals('cash_in'));
      expect(movements.first.amount, equals(200.0));
      expect(movements.first.reason, equals('إيداع نقدي'));
    });

    // ========================================================================
    // اختبار إضافة حركة نقدية بدون متجر
    // ========================================================================

    test('addCashMovementProvider يرمي استثناء بدون متجر', () async {
      // Arrange
      final container = createContainer(storeId: null);
      addTearDown(container.dispose);

      final addMovement = container.read(addCashMovementProvider);

      // Act & Assert
      expect(
        () => addMovement(
          shiftId: 'shift-1',
          type: 'cash_in',
          amount: 100.0,
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('لا يوجد متجر محدد'),
        )),
      );
    });

    // ========================================================================
    // اختبار قراءة الوردية المفتوحة
    // ========================================================================

    test('openShiftProvider يقرأ الوردية المفتوحة', () async {
      // Arrange
      final container = createContainer();
      addTearDown(container.dispose);

      final openShiftAction = container.read(openShiftActionProvider);
      await openShiftAction(
        openingCash: 500.0,
        cashierId: 'cashier-1',
        cashierName: 'أحمد',
      );

      // Act - قراءة مباشرة من الـ DAO
      final openShift = await db.shiftsDao.getAnyOpenShift('store-test-1');

      // Assert
      expect(openShift, isNotNull);
      expect(openShift!.status, equals('open'));
      expect(openShift.cashierName, equals('أحمد'));
    });

    // ========================================================================
    // اختبار عدم وجود وردية مفتوحة
    // ========================================================================

    test('openShiftProvider يعيد null عند عدم وجود وردية مفتوحة', () async {
      // Act
      final openShift = await db.shiftsDao.getAnyOpenShift('store-test-1');

      // Assert
      expect(openShift, isNull);
    });

    // ========================================================================
    // اختبار ورديات اليوم
    // ========================================================================

    test('getTodayShifts يعيد ورديات اليوم فقط', () async {
      // Arrange
      final container = createContainer();
      addTearDown(container.dispose);

      final openShiftAction = container.read(openShiftActionProvider);
      final closeShiftAction = container.read(closeShiftActionProvider);

      // فتح وإغلاق وردية أولى
      final shift1 = await openShiftAction(
        openingCash: 500.0,
        cashierId: 'cashier-1',
        cashierName: 'أحمد',
      );

      await closeShiftAction(
        shiftId: shift1,
        closingCash: 1000.0,
        expectedCash: 1000.0,
        difference: 0.0,
        totalSales: 5,
        totalSalesAmount: 500.0,
        totalRefunds: 0,
        totalRefundsAmount: 0.0,
      );

      // فتح وردية ثانية
      await openShiftAction(
        openingCash: 300.0,
        cashierId: 'cashier-2',
        cashierName: 'محمد',
      );

      // Act
      final todayShifts = await db.shiftsDao.getTodayShifts('store-test-1');

      // Assert
      expect(todayShifts, hasLength(2));
    });

    // ========================================================================
    // اختبار قراءة حركات وردية
    // ========================================================================

    test('getShiftMovements يعيد حركات الوردية المحددة فقط', () async {
      // Arrange
      final container = createContainer();
      addTearDown(container.dispose);

      final openShiftAction = container.read(openShiftActionProvider);
      final addMovement = container.read(addCashMovementProvider);

      final shiftId = await openShiftAction(
        openingCash: 500.0,
        cashierId: 'cashier-1',
        cashierName: 'أحمد',
      );

      // إضافة حركتين
      await addMovement(
        shiftId: shiftId,
        type: 'cash_in',
        amount: 100.0,
        reason: 'إيداع',
      );

      await addMovement(
        shiftId: shiftId,
        type: 'cash_out',
        amount: 50.0,
        reason: 'سحب',
      );

      // Act
      final movements = await db.shiftsDao.getShiftMovements(shiftId);

      // Assert
      expect(movements, hasLength(2));
      // التحقق من أن كلا النوعين موجودان (الترتيب يعتمد على createdAt)
      final types = movements.map((m) => m.type).toSet();
      expect(types, containsAll(['cash_in', 'cash_out']));
    });
  });
}
