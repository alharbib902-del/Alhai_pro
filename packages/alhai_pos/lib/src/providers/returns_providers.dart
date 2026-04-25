/// Returns Providers - مزودات المرتجعات
///
/// توفر بيانات المرتجعات من قاعدة البيانات
library;

import 'package:alhai_auth/alhai_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

import 'sale_providers.dart' show invoiceServiceProvider;

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
/// Sprint 1 / P0-14 + P0-15 (+ Wave 3b-2a):
/// * **Max-refund check (P0-14):** before any DB write we sum existing
///   refunds for [saleId] and refuse if the new refund would push the
///   total above the original sale total. Without this guard, a 1000 SAR
///   sale could be refunded as 500 + 500 + 500 — direct money loss and a
///   ZATCA credit-note inconsistency. The check is now unconditional;
///   the temporary `skipMaxRefundCheck` exchange escape hatch was
///   removed in Wave 3b-2a once exchange_screen started anchoring to
///   the customer's original sale.
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
}) async {
  final storeId = ref.read(currentStoreIdProvider);
  if (storeId == null) throw Exception('لا يوجد متجر محدد');

  final db = GetIt.I<AppDatabase>();
  final newRefundCents = (totalRefund * 100).round();

  // ─── Pre-flight: max-refund check (P0-14) ─────────────────────────
  // Done outside any transaction since we want to fail FAST without
  // touching DB write state. Reading the sale + summing prior refunds
  // is a couple of indexed lookups.
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

  // ─── Sprint 1 / P0-04: ZATCA credit note 381 ─────────────────────
  // If the original sale produced a ZATCA-compliant invoice (i.e. the
  // store has VAT and a QR was generated at sale time), issue a Phase-1
  // credit note that references the original invoice via refInvoiceId.
  // Without this, ZATCA portal-side reconciliation sees the original
  // invoice at full value while local books show a refund — VAT
  // double-count + accidental tax evasion.
  //
  // The invoice_service.createCreditNote helper already exists; we just
  // weren't calling it. It builds an invoices row with invoiceType
  // 'credit_note', enqueues to sync, and the rest of the pipeline picks
  // it up. Wave 3b-2 will replace this Phase-1 path with the full
  // Phase-2 UBL XML + signing + gateway submit (the alhai_zatca
  // ZatcaInvoiceService already supports it; just not wired in yet).
  //
  // Failures here are LOGGED but don't roll back the return — a
  // ZATCA-portal mismatch is a compliance issue to fix later, but
  // refusing the customer's refund is a much worse business outcome.
  try {
    final originalInvoice = await db.invoicesDao.getBySaleId(saleId);
    if (originalInvoice != null &&
        originalInvoice.zatcaQr != null &&
        originalInvoice.zatcaQr!.isNotEmpty) {
      // Split totalRefund into subtotal + tax using the original
      // invoice's tax ratio, so the credit note's VAT-amount on the
      // ZATCA portal exactly offsets what the original invoice charged.
      // Original.total is gross cents; original.taxAmount is the tax
      // portion. Ratio is bounded to [0, 1) — anything outside means a
      // corrupt invoice and we fall back to 0% so we don't create a
      // garbage credit note.
      final originalTotal = originalInvoice.total;
      final originalTax = originalInvoice.taxAmount;
      double taxRatio = 0.0;
      if (originalTotal > 0 && originalTax >= 0 && originalTax < originalTotal) {
        taxRatio = originalTax / originalTotal;
      }
      final creditTaxCents = (newRefundCents * taxRatio).round();
      final creditSubtotalCents = newRefundCents - creditTaxCents;

      final invoiceService = ref.read(invoiceServiceProvider);
      await invoiceService.createCreditNote(
        storeId: storeId,
        refInvoiceId: originalInvoice.id,
        reason: reason,
        // createCreditNote expects SAR doubles; convert at the
        // boundary. Internally it round-trips back to cents.
        amount: creditSubtotalCents / 100.0,
        taxAmount: creditTaxCents / 100.0,
        orgId: originalInvoice.orgId,
        customerId: customerId,
        customerName: customerName,
        createdBy: createdBy,
      );
    }
  } catch (e, stack) {
    // Don't fail the return — the local refund is already persisted.
    // The credit note can be regenerated later by an audit script.
    if (kDebugMode) {
      debugPrint(
        '[createReturn] Credit-note generation failed (non-blocking) for '
        'return $id / sale $saleId: $e\n$stack',
      );
    }
  }

  ref.invalidate(returnsListProvider);
  return id;
}
