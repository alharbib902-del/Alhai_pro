/// Centralized Audit Service for financial and admin operations
///
/// Wraps AuditLogDao to provide a single entry point for all audit logging.
/// Registered in GetIt for dependency injection across the app.
library;

import 'package:alhai_database/alhai_database.dart';
import 'package:get_it/get_it.dart';

/// Centralized audit service wrapping AuditLogDao
class AuditService {
  final AppDatabase _db;

  AuditService(this._db);

  AuditLogDao get _dao => _db.auditLogDao;

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
  }) => _dao.log(
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
  }) => _dao.log(
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
  }) => _dao.logRefund(
    storeId: storeId,
    userId: userId,
    userName: userName,
    saleId: saleId,
    amount: amount,
    reason: reason ?? 'مرتجع',
  );

  /// Log exchange
  Future<void> logExchange({
    required String storeId,
    required String userId,
    required String userName,
    required int returnCount,
    required int newCount,
  }) => _dao.log(
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
  }) => _dao.log(
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

  /// Log interest application
  Future<void> logInterestApply({
    required String storeId,
    required String userId,
    required String userName,
    required int accountCount,
    required double rate,
    required double totalInterest,
  }) => _dao.log(
    storeId: storeId,
    userId: userId,
    userName: userName,
    action: AuditAction.interestApply,
    entityType: 'accounts',
    newValue: {
      'accountCount': accountCount,
      'rate': rate,
      'totalInterest': totalInterest,
    },
    description:
        'تطبيق فائدة $rate% على $accountCount حساب - إجمالي $totalInterest ر.س',
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
  }) => _dao.log(
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
  }) => _dao.log(
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
  }) => _dao.log(
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
  }) => _dao.log(
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
  }) => _dao.logPriceChange(
    storeId: storeId,
    userId: userId,
    userName: userName,
    productId: productId,
    productName: productName,
    oldPrice: oldPrice,
    newPrice: newPrice,
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
  }) => _dao.logStockAdjust(
    storeId: storeId,
    userId: userId,
    userName: userName,
    productId: productId,
    productName: productName,
    oldQty: oldQty,
    newQty: newQty,
    reason: reason,
  );

  /// Log stock receive (purchase receiving)
  Future<void> logStockReceive({
    required String storeId,
    required String userId,
    required String userName,
    required String purchaseId,
    String? purchaseNumber,
    required int itemCount,
  }) => _dao.log(
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
  }) => _dao.log(
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
  }) => _dao.log(
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
