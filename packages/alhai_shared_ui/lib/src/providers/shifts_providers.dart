/// Shifts Providers - مزودات الورديات
///
/// توفر بيانات الورديات وحركات الصندوق من قاعدة البيانات
library;

import 'package:alhai_auth/alhai_auth.dart';
import 'package:drift/drift.dart' show OrderingTerm, Variable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

AuditLogDao get _auditDao => GetIt.I<AppDatabase>().auditLogDao;

const _uuid = Uuid();

// ============================================================================
// ZATCA CHAIN SNAPSHOT HELPER (Sprint 1 / P0-06 + P0-07)
// ============================================================================

/// Snapshot of the ZATCA invoice chain at a point in time, used to anchor
/// shift open/close to a verifiable position on the chain. See the
/// `shifts_table.dart` column comments for the audit motivation.
class _ZatcaChainSnapshot {
  /// Total invoices issued by the store at this moment.
  final int invoiceCount;

  /// `zatca_hash` of the most recent invoice (the next invoice's PIH).
  /// Null when the store has issued no invoices yet.
  final String? lastPih;

  /// UTC ISO-8601 timestamp captured at snapshot time.
  final String timestampUtc;

  const _ZatcaChainSnapshot({
    required this.invoiceCount,
    required this.lastPih,
    required this.timestampUtc,
  });
}

/// Capture a ZATCA chain snapshot for the given store. Pure read-only —
/// safe to call inside transactions or in either open / close flow.
/// Returns zeros / null when the store has no invoices yet (typical for
/// a brand-new store opening its first shift).
Future<_ZatcaChainSnapshot> _captureZatcaChainSnapshot(
  AppDatabase db,
  String storeId,
) async {
  // Count of invoices for the store. customSelect avoids loading the
  // entire invoices table — important for stores with thousands of rows.
  final countResult = await db.customSelect(
    'SELECT COUNT(*) AS c FROM invoices WHERE store_id = ?',
    variables: [Variable.withString(storeId)],
  ).getSingle();
  final int invoiceCount = countResult.read<int>('c');

  // Most recent invoice's zatca_hash (the PIH the next invoice will chain
  // from). Limit 1 so we don't pull entire history.
  String? lastPih;
  if (invoiceCount > 0) {
    final lastInvoice = await ((db.select(db.invoicesTable)
          ..where((i) => i.storeId.equals(storeId))
          ..orderBy([(i) => OrderingTerm.desc(i.createdAt)])
          ..limit(1))
        .getSingleOrNull());
    lastPih = lastInvoice?.zatcaHash;
  }

  return _ZatcaChainSnapshot(
    invoiceCount: invoiceCount,
    lastPih: lastPih,
    timestampUtc: DateTime.now().toUtc().toIso8601String(),
  );
}

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// الوردية المفتوحة حالياً
final openShiftProvider = FutureProvider.autoDispose<ShiftsTableData?>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return null;
  final db = GetIt.I<AppDatabase>();
  return db.shiftsDao.getAnyOpenShift(storeId);
});

/// ورديات اليوم
final todayShiftsProvider = FutureProvider.autoDispose<List<ShiftsTableData>>((
  ref,
) async {
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
    .family<({double cashSales, double cashRefunds}), String>((
      ref,
      shiftId,
    ) async {
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
final openShiftActionProvider =
    Provider<
      Future<String> Function({
        required double openingCash,
        required String cashierId,
        required String cashierName,
      })
    >((ref) {
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
        // Sprint 1 / P0-07: capture the ZATCA chain position so the
        // subsequent shift_close can compute (closing − opening) =
        // invoices issued during this shift, and so a chain auditor can
        // verify openingLastPih == previous shift's closingLastPih.
        final openingSnapshot = await _captureZatcaChainSnapshot(db, storeId);
        await db.shiftsDao.openShift(
          ShiftsTableCompanion(
            id: Value(id),
            storeId: Value(storeId),
            cashierId: Value(cashierId),
            cashierName: Value(cashierName),
            // C-4 Session 3: shifts.opening_cash is int cents. Caller
            // supplies SAR double; convert at the Drift boundary.
            openingCash: Value((openingCash * 100).round()),
            status: const Value('open'),
            openedAt: Value(DateTime.now()),
            openingInvoiceCount: Value(openingSnapshot.invoiceCount),
            openingLastPih: Value(openingSnapshot.lastPih),
            openingTimestampUtc: Value(openingSnapshot.timestampUtc),
          ),
        );

        // Sprint 1 / P0-10: sync payload must ship int cents to match the
        // remote schema. The caller supplies SAR doubles; the local DAO
        // already stores cents (line 117). Without this conversion the
        // remote row stored SAR while local stored cents → 100× drift.
        final openingCashCents = (openingCash * 100).round();
        await db.syncQueueDao.enqueue(
          id: _uuid.v4(),
          tableName: 'shifts',
          recordId: id,
          operation: 'CREATE',
          payload:
              '{"id":"$id","store_id":"$storeId","cashier_id":"$cashierId","status":"open","opening_cash":$openingCashCents}',
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
final closeShiftActionProvider =
    Provider<
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
      })
    >((ref) {
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
        // Sprint 1 / P0-06: snapshot the ZATCA chain + pending-queue size
        // before closing. The Z-Report reconciliation reads these to
        // surface "N invoices still pending gateway acknowledgement" so a
        // cashier doesn't think the shift is fully cleared when it isn't.
        final storeIdForSnapshot = ref.read(currentStoreIdProvider);
        _ZatcaChainSnapshot? closingSnapshot;
        int? pendingZatcaCount;
        if (storeIdForSnapshot != null && storeIdForSnapshot.isNotEmpty) {
          closingSnapshot = await _captureZatcaChainSnapshot(
            db,
            storeIdForSnapshot,
          );
          pendingZatcaCount = await db.zatcaOfflineQueueDao
              .getPendingCount(storeId: storeIdForSnapshot);
        }
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
          closingInvoiceCount: closingSnapshot?.invoiceCount,
          closingLastPih: closingSnapshot?.lastPih,
          closingTimestampUtc: closingSnapshot?.timestampUtc,
          pendingZatcaAtClose: pendingZatcaCount,
        );

        // Sprint 1 / P0-10: every monetary field in this payload is SAR on
        // the wire today but int cents in both local DB and remote schema.
        // Convert at the boundary. Counts (total_sales, total_refunds) are
        // plain integers — leave them unconverted.
        final closingCashCents = (closingCash * 100).round();
        final expectedCashCents = (expectedCash * 100).round();
        final differenceCents = (difference * 100).round();
        final totalSalesAmountCents = (totalSalesAmount * 100).round();
        final totalRefundsAmountCents = (totalRefundsAmount * 100).round();
        await db.syncQueueDao.enqueue(
          id: _uuid.v4(),
          tableName: 'shifts',
          recordId: shiftId,
          operation: 'UPDATE',
          payload:
              '{"id":"$shiftId","status":"closed","closing_cash":$closingCashCents,"expected_cash":$expectedCashCents,"difference":$differenceCents,"total_sales":$totalSales,"total_sales_amount":$totalSalesAmountCents,"total_refunds":$totalRefunds,"total_refunds_amount":$totalRefundsAmountCents}',
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
          description:
              'إغلاق وردية - نقد فعلي: $closingCash ر.س، فرق: $difference ر.س',
        );

        ref.invalidate(openShiftProvider);
        ref.invalidate(todayShiftsProvider);
      };
    });

/// إضافة حركة نقدية
final addCashMovementProvider =
    Provider<
      Future<void> Function({
        required String shiftId,
        required String type,
        required double amount,
        String? reason,
        String? createdBy,
      })
    >((ref) {
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
        await db.shiftsDao.insertCashMovement(
          CashMovementsTableCompanion(
            id: Value(movementId),
            shiftId: Value(shiftId),
            storeId: Value(storeId),
            type: Value(type),
            // C-4 Session 3: cash_movements.amount is int cents. Caller
            // supplies SAR double; convert at the Drift boundary.
            amount: Value((amount * 100).round()),
            reason: Value(reason),
            createdBy: Value(createdBy),
            createdAt: Value(DateTime.now()),
          ),
        );

        // Sprint 1 / P0-10: same SAR→cents pattern as the shift open/close
        // payloads above. The insertCashMovement call on line 258 already
        // converts; the sync payload was sending the unconverted SAR value.
        final amountCents = (amount * 100).round();
        await db.syncQueueDao.enqueue(
          id: _uuid.v4(),
          tableName: 'cash_movements',
          recordId: movementId,
          operation: 'CREATE',
          payload:
              '{"id":"$movementId","shift_id":"$shiftId","store_id":"$storeId","type":"$type","amount":$amountCents}',
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
