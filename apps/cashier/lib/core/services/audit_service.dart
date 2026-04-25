/// Centralized Audit Service for financial and admin operations
///
/// Wraps AuditLogDao to provide a single entry point for all audit logging.
/// Registered in GetIt for dependency injection across the app.
library;

import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show TextInputSanitizer;
import 'package:get_it/get_it.dart';

/// Centralized audit service wrapping AuditLogDao
class AuditService {
  final AppDatabase _db;

  AuditService(this._db);

  AuditLogDao get _dao => _db.auditLogDao;

  /// Unified append that always routes through the tamper-evident hash chain.
  ///
  /// All `logXxx` methods funnel through here, replacing what used to be a
  /// direct `_dao.log(...)` call. Business semantics (oldValue, entityType,
  /// description, etc.) are preserved — only the storage format changes:
  /// newValue JSON now carries a `__meta__` envelope with contentHash /
  /// previousHash, verifiable via [AuditLogDao.verifyChain].
  ///
  /// Defense in depth: all string fields in `newValue` / `oldValue` / meta
  /// identifiers are sanitized via [TextInputSanitizer.sanitize] before
  /// persistence, so the hash chain can't be poisoned by bidi overrides or
  /// zero-width chars in audit payloads.
  Future<void> _append({
    required String storeId,
    required String userId,
    required String userName,
    required AuditAction action,
    String? entityType,
    String? entityId,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? description,
    String? ipAddress,
    String? deviceInfo,
  }) async {
    await _dao.appendLogWithHashChain(
      storeId: storeId,
      userId: TextInputSanitizer.sanitize(userId, maxLength: 200),
      userName: TextInputSanitizer.sanitize(userName, maxLength: 200),
      action: action,
      payload: _sanitizePayload(newValue) ?? const <String, dynamic>{},
      entityType: entityType,
      entityId: entityId,
      oldValue: _sanitizePayload(oldValue),
      description: description == null
          ? null
          : TextInputSanitizer.sanitize(description, maxLength: 2000),
      ipAddress: ipAddress,
      deviceInfo: deviceInfo,
    );
  }

  /// Shallow-sanitize string values in an audit payload map. Non-string
  /// primitives (numbers, bools, nested maps/lists) pass through untouched —
  /// they can't carry the bidi/zero-width risk we're defending against.
  Map<String, dynamic>? _sanitizePayload(Map<String, dynamic>? payload) {
    if (payload == null) return null;
    final out = <String, dynamic>{};
    for (final entry in payload.entries) {
      final v = entry.value;
      out[entry.key] = v is String
          ? TextInputSanitizer.sanitize(v, maxLength: 2000)
          : v;
    }
    return out;
  }

  /// Verify the tamper-evident hash chain for a store.
  ///
  /// Returns the id of the first broken row, or `null` if the chain is intact.
  /// Useful for ZATCA audit handoff and periodic self-checks.
  Future<String?> verifyChain({String? storeId}) =>
      _dao.verifyChain(storeId: storeId);

  // ============================================================================
  // SALE OPERATIONS
  // ============================================================================

  /// Log sale creation
  Future<void> logSaleCreate({
    required String storeId,
    required String userId,
    required String userName,
    required String saleId,
    required double total,
    required String paymentMethod,
    String? receiptNo,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.saleCreate,
    entityType: 'sale',
    entityId: saleId,
    newValue: {
      'total': total,
      'paymentMethod': paymentMethod,
      if (receiptNo != null) 'receiptNo': receiptNo,
    },
    description: 'بيع جديد بمبلغ $total ر.س - $paymentMethod',
  );

  /// Log sale cancellation / void
  Future<void> logSaleCancel({
    required String storeId,
    required String userId,
    required String userName,
    required String saleId,
    required double total,
    String? reason,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.saleCancel,
    entityType: 'sale',
    entityId: saleId,
    newValue: {'total': total, if (reason != null) 'reason': reason},
    description: 'إلغاء بيع بمبلغ $total ر.س',
  );

  /// Log refund
  Future<void> logRefund({
    required String storeId,
    required String userId,
    required String userName,
    required String saleId,
    required double amount,
    String? reason,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.saleRefund,
    entityType: 'sale',
    entityId: saleId,
    newValue: {'amount': amount, 'reason': reason ?? 'مرتجع'},
    description: 'مرتجع بمبلغ $amount ر.س - ${reason ?? 'مرتجع'}',
  );

  /// Log exchange
  Future<void> logExchange({
    required String storeId,
    required String userId,
    required String userName,
    required int returnCount,
    required int newCount,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.saleRefund,
    entityType: 'exchange',
    newValue: {'returnItems': returnCount, 'newItems': newCount},
    description: 'استبدال: $returnCount منتج مرتجع، $newCount منتج جديد',
  );

  // ============================================================================
  // PAYMENT / TRANSACTION OPERATIONS
  // ============================================================================

  /// Log customer debt/payment transaction
  Future<void> logTransaction({
    required String storeId,
    required String userId,
    required String userName,
    required String transactionId,
    required String accountName,
    required String type,
    required double amount,
    required double balanceAfter,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.paymentRecord,
    entityType: 'transaction',
    entityId: transactionId,
    newValue: {
      'type': type,
      'amount': amount,
      'balanceAfter': balanceAfter,
      'accountName': accountName,
    },
    description: type == 'invoice'
        ? 'تسجيل دين على $accountName بمبلغ ${amount.abs()} ر.س'
        : 'تسجيل دفعة من $accountName بمبلغ ${amount.abs()} ر.س',
  );

  /// P0-13: Log a credit-limit override approved by a manager PIN.
  ///
  /// Called whenever the cashier proceeds with a credit obligation that
  /// would push a customer past their `accounts.creditLimit`. The audit
  /// trail captures who approved it, what the limit was, and how far
  /// the override pushed the balance — required for risk-management
  /// review and (in regulated tenants) compliance audit.
  Future<void> logCreditLimitOverride({
    required String storeId,
    required String userId,
    required String userName,
    required String accountId,
    required String accountName,
    required int currentBalanceCents,
    required int limitCents,
    required int newBalanceCents,
    required int overByCents,
    String? entityType,
    String? entityId,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.creditLimitOverride,
    entityType: entityType ?? 'account',
    entityId: entityId ?? accountId,
    newValue: {
      'accountId': accountId,
      'accountName': accountName,
      'currentBalanceSar': currentBalanceCents / 100,
      'limitSar': limitCents / 100,
      'newBalanceSar': newBalanceCents / 100,
      'overBySar': overByCents / 100,
    },
    description:
        'تجاوز حد الائتمان لـ $accountName بمبلغ ${(overByCents / 100).toStringAsFixed(2)} ر.س',
  );

  // ============================================================================
  // SHIFT OPERATIONS
  // ============================================================================

  /// Log shift open
  Future<void> logShiftOpen({
    required String storeId,
    required String userId,
    required String userName,
    required String shiftId,
    required double openingCash,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.shiftOpen,
    entityType: 'shift',
    entityId: shiftId,
    newValue: {'openingCash': openingCash},
    description: 'فتح وردية برصيد $openingCash ر.س',
  );

  /// Log shift close
  Future<void> logShiftClose({
    required String storeId,
    required String userId,
    required String userName,
    required String shiftId,
    required double closingCash,
    required double expectedCash,
    required double difference,
    required int totalSales,
    required double totalSalesAmount,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
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

  /// Log cash drawer movement (cash in/out)
  Future<void> logCashDrawer({
    required String storeId,
    required String userId,
    required String userName,
    required String type,
    required double amount,
    String? reason,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.cashDrawerOpen,
    entityType: 'cash_movement',
    newValue: {
      'type': type,
      'amount': amount,
      if (reason != null) 'reason': reason,
    },
    description: type == 'cash_in'
        ? 'إيداع نقدي $amount ر.س'
        : 'سحب نقدي $amount ر.س',
  );

  // ============================================================================
  // PRODUCT OPERATIONS
  // ============================================================================

  /// Log product creation
  Future<void> logProductCreate({
    required String storeId,
    required String userId,
    required String userName,
    required String productId,
    required String productName,
    required double price,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.productCreate,
    entityType: 'product',
    entityId: productId,
    newValue: {'name': productName, 'price': price},
    description: 'إضافة منتج: $productName بسعر $price ر.س',
  );

  /// Log price change
  Future<void> logPriceChange({
    required String storeId,
    required String userId,
    required String userName,
    required String productId,
    required String productName,
    required double oldPrice,
    required double newPrice,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.priceChange,
    entityType: 'product',
    entityId: productId,
    oldValue: {'price': oldPrice},
    newValue: {'price': newPrice},
    description: 'تغيير سعر $productName من $oldPrice إلى $newPrice',
  );

  // ============================================================================
  // INVENTORY OPERATIONS
  // ============================================================================

  /// Log stock adjustment (add, remove, wastage, stock take, transfer)
  Future<void> logStockAdjust({
    required String storeId,
    required String userId,
    required String userName,
    required String productId,
    required String productName,
    required double oldQty,
    required double newQty,
    required String reason,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.stockAdjust,
    entityType: 'product',
    entityId: productId,
    oldValue: {'quantity': oldQty},
    newValue: {'quantity': newQty},
    description: '$reason: تعديل كمية $productName من $oldQty إلى $newQty',
  );

  /// Log stock receive (purchase receiving)
  Future<void> logStockReceive({
    required String storeId,
    required String userId,
    required String userName,
    required String purchaseId,
    String? purchaseNumber,
    required int itemCount,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.stockReceive,
    entityType: 'purchase',
    entityId: purchaseId,
    newValue: {
      if (purchaseNumber != null) 'purchaseNumber': purchaseNumber,
      'itemCount': itemCount,
    },
    description:
        'استلام مشتريات${purchaseNumber != null ? ' #$purchaseNumber' : ''} - $itemCount صنف',
  );

  // ============================================================================
  // CUSTOMER OPERATIONS
  // ============================================================================

  /// Log customer creation
  Future<void> logCustomerCreate({
    required String storeId,
    required String userId,
    required String userName,
    required String customerId,
    required String customerName,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.customerCreate,
    entityType: 'customer',
    entityId: customerId,
    newValue: {'name': customerName},
    description: 'إضافة عميل: $customerName',
  );

  /// Log customer edit
  Future<void> logCustomerEdit({
    required String storeId,
    required String userId,
    required String userName,
    required String customerId,
    required String customerName,
    Map<String, dynamic>? changes,
  }) => _append(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.customerEdit,
    entityType: 'customer',
    entityId: customerId,
    newValue: {'name': customerName, ...?changes},
    description: 'تعديل بيانات عميل: $customerName',
  );
}

/// Convenience getter for the audit service from GetIt
AuditService get auditService => GetIt.I<AuditService>();
