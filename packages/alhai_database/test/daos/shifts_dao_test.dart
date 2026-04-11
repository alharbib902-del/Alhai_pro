import 'package:flutter_test/flutter_test.dart';
import 'package:alhai_database/alhai_database.dart';
import '../helpers/database_test_helpers.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  ShiftsTableCompanion makeShift({
    String id = 'shift-1',
    String storeId = 'store-1',
    String cashierId = 'cashier-1',
    String cashierName = 'محمد الكاشير',
    double openingCash = 500.0,
    String status = 'open',
    DateTime? openedAt,
  }) {
    return ShiftsTableCompanion.insert(
      id: id,
      storeId: storeId,
      cashierId: cashierId,
      cashierName: cashierName,
      openingCash: Value(openingCash),
      status: Value(status),
      openedAt: openedAt ?? DateTime(2025, 6, 15, 8, 0),
    );
  }

  group('ShiftsDao', () {
    test('openShift and getShiftById', () async {
      await db.shiftsDao.openShift(makeShift());

      final shift = await db.shiftsDao.getShiftById('shift-1');
      expect(shift, isNotNull);
      expect(shift!.cashierName, 'محمد الكاشير');
      expect(shift.openingCash, 500.0);
      expect(shift.status, 'open');
    });

    test('getOpenShift finds open shift for cashier', () async {
      await db.shiftsDao.openShift(makeShift());

      final shift = await db.shiftsDao.getOpenShift('store-1', 'cashier-1');
      expect(shift, isNotNull);
      expect(shift!.id, 'shift-1');
    });

    test('getOpenShift returns null when no open shift', () async {
      await db.shiftsDao.openShift(makeShift(status: 'closed'));

      final shift = await db.shiftsDao.getOpenShift('store-1', 'cashier-1');
      expect(shift, isNull);
    });

    test('getAnyOpenShift finds any open shift for store', () async {
      await db.shiftsDao.openShift(makeShift());

      final shift = await db.shiftsDao.getAnyOpenShift('store-1');
      expect(shift, isNotNull);
    });

    test('closeShift updates all closing fields', () async {
      await db.shiftsDao.openShift(makeShift());

      await db.shiftsDao.closeShift(
        id: 'shift-1',
        closingCash: 1200.0,
        expectedCash: 1250.0,
        difference: -50.0,
        totalSales: 15,
        totalSalesAmount: 750.0,
        totalRefunds: 1,
        totalRefundsAmount: 50.0,
        notes: 'وردية جيدة',
      );

      final shift = await db.shiftsDao.getShiftById('shift-1');
      expect(shift!.status, 'closed');
      expect(shift.closingCash, 1200.0);
      expect(shift.expectedCash, 1250.0);
      expect(shift.difference, -50.0);
      expect(shift.totalSales, 15);
      expect(shift.totalSalesAmount, 750.0);
      expect(shift.totalRefunds, 1);
      expect(shift.closedAt, isNotNull);
    });

    test('markAsSynced sets syncedAt', () async {
      await db.shiftsDao.openShift(makeShift());

      await db.shiftsDao.markAsSynced('shift-1');

      final shift = await db.shiftsDao.getShiftById('shift-1');
      expect(shift!.syncedAt, isNotNull);
    });

    // Cash Movements
    test('insertCashMovement and getShiftMovements', () async {
      await db.shiftsDao.openShift(makeShift());
      await db.shiftsDao.insertCashMovement(
        CashMovementsTableCompanion.insert(
          id: 'cm-1',
          shiftId: 'shift-1',
          storeId: 'store-1',
          type: 'in',
          amount: 100.0,
          reason: const Value('إيداع نقدي'),
          createdAt: DateTime(2025, 6, 15, 9, 0),
        ),
      );

      final movements = await db.shiftsDao.getShiftMovements('shift-1');
      expect(movements, hasLength(1));
      expect(movements.first.type, 'in');
      expect(movements.first.amount, 100.0);
    });

    test('getShiftsByDateRange filters by date', () async {
      await db.shiftsDao.openShift(
        makeShift(id: 'shift-1', openedAt: DateTime(2025, 6, 15, 8, 0)),
      );
      await db.shiftsDao.openShift(
        makeShift(
          id: 'shift-2',
          cashierId: 'cashier-2',
          cashierName: 'علي',
          openedAt: DateTime(2025, 7, 1, 8, 0),
        ),
      );

      final results = await db.shiftsDao.getShiftsByDateRange(
        'store-1',
        DateTime(2025, 6, 1),
        DateTime(2025, 6, 30),
      );
      expect(results, hasLength(1));
      expect(results.first.id, 'shift-1');
    });
  });
}
