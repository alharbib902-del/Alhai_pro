/// اختبارات DAO الورديات
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

Future<void> _insertTestShift(
  AppDatabase db, {
  required String id,
  required String storeId,
  String cashierId = 'cashier-1',
  String cashierName = 'كاشير اختبار',
  double openingCash = 500.0,
  String status = 'open',
  DateTime? openedAt,
}) async {
  await db.shiftsDao.openShift(ShiftsTableCompanion.insert(
    id: id,
    storeId: storeId,
    cashierId: cashierId,
    cashierName: cashierName,
    openingCash: Value(openingCash),
    status: Value(status),
    openedAt: openedAt ?? DateTime.now(),
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

  group('ShiftsDao', () {
    group('openShift', () {
      test('يفتح وردية جديدة', () async {
        // Act
        final result = await db.shiftsDao.openShift(
          ShiftsTableCompanion.insert(
            id: 'shift-1',
            storeId: 'store-1',
            cashierId: 'cashier-1',
            cashierName: 'أحمد',
            openingCash: const Value(500.0),
            openedAt: DateTime.now(),
          ),
        );

        // Assert
        expect(result, 1);
      });

      test('يفتح وردية بالحالة الافتراضية open', () async {
        // Arrange
        await _insertTestShift(db, id: 'shift-1', storeId: 'store-1');

        // Act
        final shift = await db.shiftsDao.getShiftById('shift-1');

        // Assert
        expect(shift, isNotNull);
        expect(shift!.status, 'open');
      });
    });

    group('getShiftById', () {
      test('يجد الوردية بالمعرف', () async {
        // Arrange
        await _insertTestShift(db, id: 'shift-1', storeId: 'store-1', openingCash: 750.0);

        // Act
        final shift = await db.shiftsDao.getShiftById('shift-1');

        // Assert
        expect(shift, isNotNull);
        expect(shift!.openingCash, 750.0);
        expect(shift.storeId, 'store-1');
      });

      test('يُرجع null إذا لم تُوجد الوردية', () async {
        // Act
        final shift = await db.shiftsDao.getShiftById('non-existent');

        // Assert
        expect(shift, isNull);
      });
    });

    group('getOpenShift', () {
      test('يجد الوردية المفتوحة للكاشير', () async {
        // Arrange
        await _insertTestShift(
          db,
          id: 'shift-1',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          status: 'open',
        );
        await _insertTestShift(
          db,
          id: 'shift-2',
          storeId: 'store-1',
          cashierId: 'cashier-2',
          status: 'open',
        );

        // Act
        final shift = await db.shiftsDao.getOpenShift('store-1', 'cashier-1');

        // Assert
        expect(shift, isNotNull);
        expect(shift!.id, 'shift-1');
        expect(shift.cashierId, 'cashier-1');
      });

      test('يُرجع null إذا لم تُوجد وردية مفتوحة', () async {
        // Arrange
        await _insertTestShift(
          db,
          id: 'shift-1',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          status: 'closed',
        );

        // Act
        final shift = await db.shiftsDao.getOpenShift('store-1', 'cashier-1');

        // Assert
        expect(shift, isNull);
      });
    });

    group('getAnyOpenShift', () {
      test('يجد أي وردية مفتوحة في المتجر', () async {
        // Arrange
        await _insertTestShift(
          db,
          id: 'shift-1',
          storeId: 'store-1',
          cashierId: 'cashier-1',
          status: 'open',
        );

        // Act
        final shift = await db.shiftsDao.getAnyOpenShift('store-1');

        // Assert
        expect(shift, isNotNull);
        expect(shift!.storeId, 'store-1');
      });

      test('يُرجع null إذا لم تُوجد ورديات مفتوحة في المتجر', () async {
        // Arrange
        await _insertTestShift(
          db,
          id: 'shift-1',
          storeId: 'store-1',
          status: 'closed',
        );

        // Act
        final shift = await db.shiftsDao.getAnyOpenShift('store-1');

        // Assert
        expect(shift, isNull);
      });
    });

    group('closeShift', () {
      test('يُغلق الوردية بالبيانات المطلوبة', () async {
        // Arrange
        await _insertTestShift(db, id: 'shift-1', storeId: 'store-1', openingCash: 500.0);

        // Act
        final result = await db.shiftsDao.closeShift(
          id: 'shift-1',
          closingCash: 1500.0,
          expectedCash: 1450.0,
          difference: 50.0,
          totalSales: 20,
          totalSalesAmount: 950.0,
          totalRefunds: 2,
          totalRefundsAmount: 100.0,
          notes: 'ملاحظة الإغلاق',
        );

        // Assert
        expect(result, 1);

        final shift = await db.shiftsDao.getShiftById('shift-1');
        expect(shift, isNotNull);
        expect(shift!.status, 'closed');
        expect(shift.closingCash, 1500.0);
        expect(shift.expectedCash, 1450.0);
        expect(shift.difference, 50.0);
        expect(shift.totalSales, 20);
        expect(shift.totalSalesAmount, 950.0);
        expect(shift.totalRefunds, 2);
        expect(shift.totalRefundsAmount, 100.0);
        expect(shift.notes, 'ملاحظة الإغلاق');
        expect(shift.closedAt, isNotNull);
      });

      test('لا تظهر الوردية المغلقة كمفتوحة', () async {
        // Arrange
        await _insertTestShift(db, id: 'shift-1', storeId: 'store-1', cashierId: 'cashier-1');
        await db.shiftsDao.closeShift(
          id: 'shift-1',
          closingCash: 500.0,
          expectedCash: 500.0,
          difference: 0.0,
          totalSales: 0,
          totalSalesAmount: 0.0,
          totalRefunds: 0,
          totalRefundsAmount: 0.0,
        );

        // Act
        final openShift = await db.shiftsDao.getOpenShift('store-1', 'cashier-1');

        // Assert
        expect(openShift, isNull);
      });
    });

    group('getTodayShifts', () {
      test('يُرجع ورديات اليوم فقط', () async {
        // Arrange
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));

        await _insertTestShift(
          db,
          id: 'shift-today-1',
          storeId: 'store-1',
          openedAt: now,
        );
        await _insertTestShift(
          db,
          id: 'shift-today-2',
          storeId: 'store-1',
          openedAt: now,
        );
        await _insertTestShift(
          db,
          id: 'shift-yesterday',
          storeId: 'store-1',
          openedAt: yesterday,
        );

        // Act
        final todayShifts = await db.shiftsDao.getTodayShifts('store-1');

        // Assert
        expect(todayShifts.length, 2);
      });

      test('لا يُرجع ورديات متجر آخر', () async {
        // Arrange
        await _insertTestShift(db, id: 'shift-1', storeId: 'store-1');
        await _insertTestShift(db, id: 'shift-2', storeId: 'store-2');

        // Act
        final shifts = await db.shiftsDao.getTodayShifts('store-1');

        // Assert
        expect(shifts.length, 1);
        expect(shifts.first.storeId, 'store-1');
      });
    });
  });
}
