/// Shifts Providers - مزودات الورديات
///
/// توفر بيانات الورديات وحركات الصندوق من قاعدة البيانات
library;

import 'package:drift/drift.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

AuditLogDao get _auditDao => GetIt.I<AppDatabase>().auditLogDao;

const _uuid = Uuid();

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// الوردية المفتوحة حالياً
final openShiftProvider =
    FutureProvider.autoDispose<ShiftsTableData?>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return null;
  final db = GetIt.I<AppDatabase>();
  return db.shiftsDao.getAnyOpenShift(storeId);
});

/// ورديات اليوم
final todayShiftsProvider =
    FutureProvider.autoDispose<List<ShiftsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.shiftsDao.getTodayShifts(storeId);
});

/// حركات الصندوق لوردية محددة
final shiftMovementsProvider = FutureProvider.autoDispose
    .family<List<CashMovementsTableData>, String>((ref, shiftId) async {
  final db = GetIt.I<AppDatabase>();
  return db.shiftsDao.getShiftMovements(shiftId);
});

/// مجاميع النقد فقط للوردية (مبيعات نقدية + جزء نقدي من المختلط - مرتجعات نقدية)
/// يُستخدم لحساب النقد المتوقع في الدرج بدقة (بدون بطاقة/آجل)
final shiftCashTotalsProvider = FutureProvider.autoDispose
    .family<({double cashSales, double cashRefunds}), String>((ref, shiftId) async {
  final db = GetIt.I<AppDatabase>();
  final shift = await db.shiftsDao.getShiftById(shiftId);
  if (shift == null) return (cashSales: 0.0, cashRefunds: 0.0);

  final storeId = shift.storeId;
  final startDate = shift.openedAt;

  // مبيعات نقدية بالكامل
  final cashSales = await db.salesDao.getCashSalesTotalForPeriod(
    storeId,
    startDate: startDate,
  );

  // الجزء النقدي من المبيعات المختلطة
  final mixedCash = await db.salesDao.getMixedCashAmountForPeriod(
    storeId,
    startDate: startDate,
  );

  // مرتجعات نقدية
  final cashRefunds = await db.returnsDao.getCashRefundsTotalForPeriod(
    storeId,
    startDate: startDate,
  );

  return (cashSales: cashSales + mixedCash, cashRefunds: cashRefunds);
});

// ============================================================================
// ACTION PROVIDERS
// ============================================================================

/// فتح وردية جديدة
final openShiftActionProvider = Provider<
    Future<String> Function({
      required double openingCash,
      required String cashierId,
      required String cashierName,
    })>((ref) {
  return ({
    required double openingCash,
    required String cashierId,
    required String cashierName,
  }) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) throw Exception('لا يوجد متجر محدد');

    final db = GetIt.I<AppDatabase>();
    final existing = await db.shiftsDao.getAnyOpenShift(storeId);
    if (existing != null) throw Exception('يوجد وردية مفتوحة بالفعل');

    final id = _uuid.v4();
    await db.shiftsDao.openShift(ShiftsTableCompanion(
      id: Value(id),
      storeId: Value(storeId),
      cashierId: Value(cashierId),
      cashierName: Value(cashierName),
      openingCash: Value(openingCash),
      status: const Value('open'),
      openedAt: Value(DateTime.now()),
    ));

    // إضافة لطابور المزامنة
    await db.syncQueueDao.enqueue(
      id: _uuid.v4(),
      tableName: 'shifts',
      recordId: id,
      operation: 'CREATE',
      payload: '{"id":"$id","store_id":"$storeId","cashier_id":"$cashierId","status":"open","opening_cash":$openingCash}',
      idempotencyKey: 'shift_open_$id',
    );

    // Audit log - shift open
    _auditDao.log(
      storeId: storeId,
      userId: cashierId,
      userName: cashierName,
      action: AuditAction.shiftOpen,
      entityType: 'shift',
      entityId: id,
      newValue: {'openingCash': openingCash},
      description: 'فتح وردية برصيد $openingCash ر.س',
    );

    ref.invalidate(openShiftProvider);
    ref.invalidate(todayShiftsProvider);
    return id;
  };
});

/// إغلاق الوردية
final closeShiftActionProvider = Provider<
    Future<void> Function({
      required String shiftId,
      required double closingCash,
      required double expectedCash,
      required double difference,
      required int totalSales,
      required double totalSalesAmount,
      required int totalRefunds,
      required double totalRefundsAmount,
      String? notes,
    })>((ref) {
  return ({
    required String shiftId,
    required double closingCash,
    required double expectedCash,
    required double difference,
    required int totalSales,
    required double totalSalesAmount,
    required int totalRefunds,
    required double totalRefundsAmount,
    String? notes,
  }) async {
    final db = GetIt.I<AppDatabase>();
    await db.shiftsDao.closeShift(
      id: shiftId,
      closingCash: closingCash,
      expectedCash: expectedCash,
      difference: difference,
      totalSales: totalSales,
      totalSalesAmount: totalSalesAmount,
      totalRefunds: totalRefunds,
      totalRefundsAmount: totalRefundsAmount,
      notes: notes,
    );

    // إضافة لطابور المزامنة - تحديث حالة الوردية إلى مغلقة
    await db.syncQueueDao.enqueue(
      id: _uuid.v4(),
      tableName: 'shifts',
      recordId: shiftId,
      operation: 'UPDATE',
      payload: '{"id":"$shiftId","status":"closed","closing_cash":$closingCash,"expected_cash":$expectedCash,"difference":$difference,"total_sales":$totalSales,"total_sales_amount":$totalSalesAmount,"total_refunds":$totalRefunds,"total_refunds_amount":$totalRefundsAmount}',
      idempotencyKey: 'shift_close_$shiftId',
    );

    // Audit log - shift close
    final user = ref.read(currentUserProvider);
    _auditDao.log(
      storeId: ref.read(currentStoreIdProvider) ?? '',
      userId: user?.id ?? 'unknown',
      userName: user?.name ?? 'unknown',
      action: AuditAction.shiftClose,
      entityType: 'shift',
      entityId: shiftId,
      newValue: {
        'closingCash': closingCash,
        'expectedCash': expectedCash,
        'difference': difference,
        'totalSales': totalSales,
        'totalSalesAmount': totalSalesAmount,
      },
      description: 'إغلاق وردية - نقد فعلي: $closingCash ر.س، فرق: $difference ر.س',
    );

    ref.invalidate(openShiftProvider);
    ref.invalidate(todayShiftsProvider);
  };
});

/// إضافة حركة نقدية
final addCashMovementProvider = Provider<
    Future<void> Function({
      required String shiftId,
      required String type,
      required double amount,
      String? reason,
      String? createdBy,
    })>((ref) {
  return ({
    required String shiftId,
    required String type,
    required double amount,
    String? reason,
    String? createdBy,
  }) async {
    final storeId = ref.read(currentStoreIdProvider);
    if (storeId == null) throw Exception('لا يوجد متجر محدد');

    final db = GetIt.I<AppDatabase>();
    final movementId = _uuid.v4();
    await db.shiftsDao.insertCashMovement(CashMovementsTableCompanion(
      id: Value(movementId),
      shiftId: Value(shiftId),
      storeId: Value(storeId),
      type: Value(type),
      amount: Value(amount),
      reason: Value(reason),
      createdBy: Value(createdBy),
      createdAt: Value(DateTime.now()),
    ));

    // إضافة لطابور المزامنة - حركة نقدية جديدة
    await db.syncQueueDao.enqueue(
      id: _uuid.v4(),
      tableName: 'cash_movements',
      recordId: movementId,
      operation: 'CREATE',
      payload: '{"id":"$movementId","shift_id":"$shiftId","store_id":"$storeId","type":"$type","amount":$amount}',
      idempotencyKey: 'cash_movement_$movementId',
    );

    // Audit log - cash movement
    _auditDao.log(
      storeId: storeId,
      userId: createdBy ?? 'unknown',
      userName: createdBy ?? 'unknown',
      action: AuditAction.cashDrawerOpen,
      entityType: 'cash_movement',
      entityId: movementId,
      newValue: {
        'type': type,
        'amount': amount,
        if (reason != null) 'reason': reason,
      },
      description: type == 'cash_in'
          ? 'إيداع نقدي $amount ر.س'
          : 'سحب نقدي $amount ر.س',
    );

    ref.invalidate(shiftMovementsProvider(shiftId));
  };
});
