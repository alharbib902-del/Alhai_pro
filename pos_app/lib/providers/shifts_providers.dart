/// Shifts Providers - مزودات الورديات
///
/// توفر بيانات الورديات وحركات الصندوق من قاعدة البيانات
library;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../data/local/app_database.dart';
import '../di/injection.dart';
import 'products_providers.dart';

const _uuid = Uuid();

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// الوردية المفتوحة حالياً
final openShiftProvider =
    FutureProvider.autoDispose<ShiftsTableData?>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return null;
  final db = getIt<AppDatabase>();
  return db.shiftsDao.getAnyOpenShift(storeId);
});

/// ورديات اليوم
final todayShiftsProvider =
    FutureProvider.autoDispose<List<ShiftsTableData>>((ref) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = getIt<AppDatabase>();
  return db.shiftsDao.getTodayShifts(storeId);
});

/// حركات الصندوق لوردية محددة
final shiftMovementsProvider = FutureProvider.autoDispose
    .family<List<CashMovementsTableData>, String>((ref, shiftId) async {
  final db = getIt<AppDatabase>();
  return db.shiftsDao.getShiftMovements(shiftId);
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

    final db = getIt<AppDatabase>();
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
    final db = getIt<AppDatabase>();
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

    final db = getIt<AppDatabase>();
    await db.shiftsDao.insertCashMovement(CashMovementsTableCompanion(
      id: Value(_uuid.v4()),
      shiftId: Value(shiftId),
      storeId: Value(storeId),
      type: Value(type),
      amount: Value(amount),
      reason: Value(reason),
      createdBy: Value(createdBy),
      createdAt: Value(DateTime.now()),
    ));
    ref.invalidate(shiftMovementsProvider(shiftId));
  };
});
