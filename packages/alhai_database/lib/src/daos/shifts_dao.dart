import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shifts_table.dart';

part 'shifts_dao.g.dart';

/// DAO for shifts and cash movements
@DriftAccessor(tables: [ShiftsTable, CashMovementsTable])
class ShiftsDao extends DatabaseAccessor<AppDatabase> with _$ShiftsDaoMixin {
  ShiftsDao(super.db);

  Future<ShiftsTableData?> getOpenShift(String storeId, String cashierId) {
    return (select(shiftsTable)
          ..where((s) =>
              s.storeId.equals(storeId) &
              s.cashierId.equals(cashierId) &
              s.status.equals('open')))
        .getSingleOrNull();
  }

  Future<ShiftsTableData?> getAnyOpenShift(String storeId) {
    return (select(shiftsTable)
          ..where((s) => s.storeId.equals(storeId) & s.status.equals('open')))
        .getSingleOrNull();
  }

  Future<ShiftsTableData?> getShiftById(String id) =>
      (select(shiftsTable)..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<List<ShiftsTableData>> getTodayShifts(String storeId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(shiftsTable)
          ..where((s) =>
              s.storeId.equals(storeId) &
              s.openedAt.isBiggerOrEqualValue(startOfDay) &
              s.openedAt.isSmallerThanValue(endOfDay))
          ..orderBy([(s) => OrderingTerm.desc(s.openedAt)]))
        .get();
  }

  Future<List<ShiftsTableData>> getShiftsByDateRange(
      String storeId, DateTime startDate, DateTime endDate) {
    return (select(shiftsTable)
          ..where((s) =>
              s.storeId.equals(storeId) &
              s.openedAt.isBiggerOrEqualValue(startDate) &
              s.openedAt.isSmallerThanValue(endDate))
          ..orderBy([(s) => OrderingTerm.desc(s.openedAt)])
          ..limit(500))
        .get();
  }

  Future<int> openShift(ShiftsTableCompanion shift) =>
      into(shiftsTable).insert(shift);

  Future<int> closeShift(
      {required String id,
      required double closingCash,
      required double expectedCash,
      required double difference,
      required int totalSales,
      required double totalSalesAmount,
      required int totalRefunds,
      required double totalRefundsAmount,
      String? notes}) {
    return (update(shiftsTable)..where((s) => s.id.equals(id))).write(
        ShiftsTableCompanion(
            closingCash: Value(closingCash),
            expectedCash: Value(expectedCash),
            difference: Value(difference),
            totalSales: Value(totalSales),
            totalSalesAmount: Value(totalSalesAmount),
            totalRefunds: Value(totalRefunds),
            totalRefundsAmount: Value(totalRefundsAmount),
            status: const Value('closed'),
            notes: Value(notes),
            closedAt: Value(DateTime.now())));
  }

  Future<int> markAsSynced(String id) {
    return (update(shiftsTable)..where((s) => s.id.equals(id)))
        .write(ShiftsTableCompanion(syncedAt: Value(DateTime.now())));
  }

  Stream<ShiftsTableData?> watchOpenShift(String storeId, String cashierId) {
    return (select(shiftsTable)
          ..where((s) =>
              s.storeId.equals(storeId) &
              s.cashierId.equals(cashierId) &
              s.status.equals('open')))
        .watchSingleOrNull();
  }

  // Cash movements
  Future<List<CashMovementsTableData>> getShiftMovements(String shiftId) {
    return (select(cashMovementsTable)
          ..where((m) => m.shiftId.equals(shiftId))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)]))
        .get();
  }

  Future<int> insertCashMovement(CashMovementsTableCompanion movement) =>
      into(cashMovementsTable).insert(movement);

  // ============================================================================
  // H03: JOIN queries - استعلامات مع ربط الجداول
  // ============================================================================

  /// ورديات مع اسم الكاشير
  Future<List<ShiftWithCashier>> getShiftsWithCashierName(
    String storeId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var whereClause = 'sh.store_id = ?';
    final variables = <Variable>[Variable.withString(storeId)];

    if (startDate != null) {
      whereClause += ' AND sh.opened_at >= ?';
      variables.add(Variable.withDateTime(startDate));
    }
    if (endDate != null) {
      whereClause += ' AND sh.opened_at < ?';
      variables.add(Variable.withDateTime(endDate));
    }

    final result = await customSelect(
      '''SELECT sh.*, u.name as cashier_name
         FROM shifts sh
         LEFT JOIN users u ON sh.cashier_id = u.id
         WHERE $whereClause
         ORDER BY sh.opened_at DESC''',
      variables: variables,
      readsFrom: {shiftsTable},
    ).get();

    return result
        .map((row) => ShiftWithCashier(
              shift: shiftsTable.map(row.data),
              cashierName: row.data['cashier_name'] as String?,
            ))
        .toList();
  }
}

/// وردية مع اسم الكاشير
class ShiftWithCashier {
  final ShiftsTableData shift;
  final String? cashierName;

  const ShiftWithCashier({required this.shift, this.cashierName});
}
