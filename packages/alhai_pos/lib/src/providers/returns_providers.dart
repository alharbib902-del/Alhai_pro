/// Returns Providers - مزودات المرتجعات
///
/// توفر بيانات المرتجعات من قاعدة البيانات
library;

import 'package:alhai_auth/alhai_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

const _uuid = Uuid();

/// Raised when [createReturn] cannot proceed because the requested refund
/// would exceed the original sale's remaining refundable amount, or the
/// referenced sale doesn't exist. This is the foundation for ZATCA credit
/// note 381 issuance later (Wave 3b) — a credit note can never reduce a
/// portal-side invoice below zero, so we enforce the same invariant here.
class InvalidRefundException implements Exception {
  /// User-facing message. Already translated where the call site can
  /// supply localized strings; otherwise raw English for logging.
  final String message;

  /// Original sale total in cents (when known) — handy for surfacing
  /// "max refundable" in dialogs without re-querying.
  final int? originalTotalCents;

  /// Sum of previously completed refunds against the same sale, in
  /// cents. originalTotalCents − previouslyRefundedCents = remaining.
  final int? previouslyRefundedCents;

  const InvalidRefundException(
    this.message, {
    this.originalTotalCents,
    this.previouslyRefundedCents,
  });

  @override
  String toString() => 'InvalidRefundException: $message';
}

// ============================================================================
// DATA MODELS
// ============================================================================

/// بيانات تفاصيل المرتجع
class ReturnDetailData {
  final ReturnsTableData returnData;
  final List<ReturnItemsTableData> items;

  const ReturnDetailData({required this.returnData, required this.items});
}

// ============================================================================
// READ PROVIDERS
// ============================================================================

/// قائمة جميع المرتجعات
final returnsListProvider = FutureProvider.autoDispose<List<ReturnsTableData>>((
  ref,
) async {
  final storeId = ref.watch(currentStoreIdProvider);
  if (storeId == null) return [];
  final db = GetIt.I<AppDatabase>();
  return db.returnsDao.getAllReturns(storeId);
});

/// تفاصيل مرتجع واحد
final returnDetailProvider = FutureProvider.autoDispose
    .family<ReturnDetailData?, String>((ref, id) async {
      final db = GetIt.I<AppDatabase>();
      final returnData = await db.returnsDao.getReturnById(id);
      if (returnData == null) return null;
      final items = await db.returnsDao.getReturnItems(id);
      return ReturnDetailData(returnData: returnData, items: items);
    });

// ============================================================================
// ACTION HELPERS
// ============================================================================

/// إنشاء مرتجع جديد
///
/// Sprint 1 / P0-14 + P0-15:
/// * **Max-refund check (P0-14):** before any DB write we sum existing
///   refunds for [saleId] and refuse if the new refund would push the
///   total above the original sale total. Without this guard, a 1000 SAR
///   sale could be refunded as 500 + 500 + 500 — direct money loss and a
///   ZATCA credit-note inconsistency once Wave 3b lands.
/// * **Atomicity (P0-15):** the previous version inserted the return,
///   then return_items, then looped through products restocking +
///   recording movements — without a transaction. If updateStock failed
///   for product 3 of 5, the return + first-2 movements were already
///   persisted, leaving stock half-restocked. The whole local DB write
///   chain now lives inside a single `db.transaction(...)`. The sync
///   enqueue stays outside (it's a network operation, doesn't belong in
///   a DB tx, and can be re-driven by the queue if it fails).
///
/// Throws [InvalidRefundException] if the original sale doesn't exist
/// or the requested refund exceeds the remaining refundable amount.
Future<String> createReturn(
  WidgetRef ref, {
  required String saleId,
  String? customerId,
  String? customerName,
  required String reason,
  required double totalRefund,
  String refundMethod = 'cash',
  String? notes,
  String? createdBy,
  required List<ReturnItemsTableCompanion> items,
  // Sprint 1 / P0-14 escape hatch: today exchange_screen creates a NEW
  // sale and then a return whose FK points at that new sale (instead of
  // the customer's original purchase). The new sale's total is often
  // smaller than the refund amount (customer keeps part of the money),
  // so the max-refund guard would falsely reject every exchange. Wave 3b
  // will fix exchange_screen to link the return to the original sale,
  // at which point this flag should be removed and the guard always on.
  bool skipMaxRefundCheck = false,
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) throw Exception('لا يوجد متجر محدد');

  final db = GetIt.I<AppDatabase>();
  final newRefundCents = (totalRefund * 100).round();

  // ─── Pre-flight: max-refund check (P0-14) ─────────────────────────
  // Done outside any transaction since we want to fail FAST without
  // touching DB write state. Reading the sale + summing prior refunds
  // is a couple of indexed lookups.
  if (!skipMaxRefundCheck) {
    final originalSale = await db.salesDao.getSaleById(saleId);
    if (originalSale == null) {
      throw const InvalidRefundException(
        'Original sale not found. The receipt may have been deleted or '
        'never synced to this device.',
      );
    }
    final previouslyRefundedCents =
        await db.returnsDao.sumRefundedCentsBySaleId(saleId);
    final remainingCents = originalSale.total - previouslyRefundedCents;
    if (newRefundCents > remainingCents) {
      final remainingSar = remainingCents / 100.0;
      final priorSar = previouslyRefundedCents / 100.0;
      final originalSar = originalSale.total / 100.0;
      throw InvalidRefundException(
        'Refund $totalRefund SAR exceeds remaining refundable '
        '$remainingSar SAR (original $originalSar SAR, prior refunds '
        '$priorSar SAR).',
        originalTotalCents: originalSale.total,
        previouslyRefundedCents: previouslyRefundedCents,
      );
    }
  }

  final id = _uuid.v4();
  final returnNumber = 'RET-${DateTime.now().millisecondsSinceEpoch}';

  // ─── Atomic DB writes (P0-15) ─────────────────────────────────────
  // All-or-nothing: insertReturn, return_items, restock, movements.
  // Falls back together if any product is missing or stock update fails.
  await db.transaction(() async {
    await db.returnsDao.insertReturn(
      ReturnsTableCompanion(
        id: Value(id),
        returnNumber: Value(returnNumber),
        saleId: Value(saleId),
        storeId: Value(storeId),
        customerId: Value(customerId),
        customerName: Value(customerName),
        reason: Value(reason),
        totalRefund: Value(newRefundCents),
        refundMethod: Value(refundMethod),
        status: const Value('completed'),
        notes: Value(notes),
        createdBy: Value(createdBy),
        createdAt: Value(DateTime.now()),
      ),
    );

    if (items.isNotEmpty) {
      await db.returnsDao.insertReturnItems(items);

      // ─── Restock inventory for returned items ───────────────
      for (final item in items) {
        final productId = item.productId.value;
        final returnedQty = item.qty.value;

        final product = await db.productsDao.getProductById(productId);
        if (product != null) {
          final currentStock = product.stockQty;
          final newStock = currentStock + returnedQty;
          await db.productsDao.updateStock(productId, newStock);
          await db.inventoryDao.recordReturnMovement(
            id: _uuid.v4(),
            productId: productId,
            storeId: storeId,
            qty: returnedQty,
            previousQty: currentStock,
            returnId: id,
            userId: createdBy,
          );
        }
      }
    }
  });

  // Sprint 1 / P0-10: sync payload must match remote schema — total_refund
  // is int cents in DB but was being sent as SAR on the wire. Same 100×
  // drift pattern as shifts/cash_movements. Outside the tx by design —
  // a network blip on enqueue must not roll back a successful local
  // refund; the queue can re-drive it.
  await db.syncQueueDao.enqueue(
    id: _uuid.v4(),
    tableName: 'returns',
    recordId: id,
    operation: 'CREATE',
    payload:
        '{"id":"$id","sale_id":"$saleId","store_id":"$storeId","total_refund":$newRefundCents,"reason":"$reason","refund_method":"$refundMethod"}',
    idempotencyKey: 'return_create_$id',
  );

  ref.invalidate(returnsListProvider);
  return id;
}
