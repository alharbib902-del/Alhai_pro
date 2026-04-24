import 'dart:developer' as developer;

import 'package:alhai_database/alhai_database.dart';

/// حمولة المزامنة المُحضَّرة للفحص قبل الدفع إلى Supabase.
///
/// [table]: اسم الجدول (مثال: `sales`, `sale_items`, `invoices`).
/// [operation]: نوع العملية — `create` | `update` | `delete`.
/// [data]: بيانات الصف كما ستُرسل إلى الخادم.
class SyncPayload {
  final String table;
  final String operation;
  final Map<String, dynamic> data;

  const SyncPayload({
    required this.table,
    required this.operation,
    required this.data,
  });
}

/// نتيجة فحص الحمولة — قائمة أخطاء وفشل أو نجاح.
class ValidationResult {
  final List<ValidationError> errors;

  const ValidationResult(this.errors);

  /// نتيجة ناجحة بلا أخطاء.
  const ValidationResult.success() : errors = const [];

  bool get hasErrors => errors.isNotEmpty;
  bool get isValid => errors.isEmpty;

  @override
  String toString() =>
      'ValidationResult(isValid=$isValid, errors=${errors.length})';
}

/// خطأ فحص مع سبب واضح — يُسجَّل في dead-letter ويُقرأ من قبل المسؤول.
class ValidationError {
  final String rule;
  final String message;
  final Map<String, dynamic>? context;

  const ValidationError({
    required this.rule,
    required this.message,
    this.context,
  });

  Map<String, dynamic> toJson() => {
        'rule': rule,
        'message': message,
        if (context != null) 'context': context,
      };

  @override
  String toString() => 'ValidationError($rule: $message)';
}

/// محرك فحص ما قبل المزامنة.
///
/// يطبّق قواعد تجارية على كل جدول قبل السماح بإرسال الصف إلى Supabase.
/// الهدف منع data-corruption (sale.total != SUM(items), invoice بلا QR, إلخ)
/// من الوصول للخادم.
///
/// الاستخدام:
/// ```dart
/// final validator = PreSyncValidator(db);
/// final result = await validator.validate(SyncPayload(
///   table: 'sales',
///   operation: 'create',
///   data: payload,
/// ));
/// if (result.hasErrors) { /* dead-letter */ }
/// ```
class PreSyncValidator {
  // ignore: unused_field
  final AppDatabase _db;

  /// هامش السماح للتقريب (cent واحد) للعمليات الحسابية على النقد.
  static const int _roundingMargin = 1;

  PreSyncValidator(this._db);

  /// الفحص الرئيسي — يوجّه لقواعد الجدول المناسبة.
  ///
  /// القواعد تُطبَّق فقط على عمليات `create` حالياً (تجنّب fragile checks
  /// على حمولات update جزئية قد لا تحتوي كل الحقول).
  Future<ValidationResult> validate(SyncPayload payload) async {
    final op = payload.operation.toLowerCase();
    // لا نفحص delete/update — update قد يحمل حقلاً واحداً فقط
    if (op != 'create') {
      return const ValidationResult.success();
    }

    final errors = <ValidationError>[];

    switch (payload.table) {
      case 'sales':
        _validateSale(payload.data, errors);
        break;
      case 'sale_items':
        _validateSaleItem(payload.data, errors);
        break;
      case 'invoices':
        _validateInvoice(payload.data, errors);
        break;
      case 'transactions':
        _validateTransaction(payload.data, errors);
        break;
      case 'returns':
        _validateReturn(payload.data, errors);
        break;
      case 'stock_deltas':
        _validateStockDelta(payload.data, errors);
        break;
      default:
        // بقية الجداول — لا قواعد خاصة بعد
        break;
    }

    if (errors.isNotEmpty) {
      developer.log(
        'PreSyncValidator: ${errors.length} violations on '
        '${payload.table}/${payload.operation}',
        name: 'PreSyncValidator',
      );
    }

    return ValidationResult(errors);
  }

  // ======================================================================
  // sales
  // ======================================================================

  void _validateSale(Map<String, dynamic> data, List<ValidationError> errors) {
    // storeId مطلوب
    final storeId = data['storeId'] ?? data['store_id'];
    if (storeId == null || (storeId is String && storeId.isEmpty)) {
      errors.add(ValidationError(
        rule: 'sale.storeId.required',
        message: 'sales.storeId missing or empty',
        context: {'storeId': storeId},
      ));
    }

    // total > 0
    final total = _asNum(data['total']);
    if (total == null || total <= 0) {
      errors.add(ValidationError(
        rule: 'sale.total.positive',
        message: 'sales.total must be > 0',
        context: {'total': data['total']},
      ));
    }

    // المعادلة: subtotal - discount + tax == total
    final subtotal = _asNum(data['subtotal']);
    final discount = _asNum(data['discount']) ?? 0;
    final tax = _asNum(data['tax']) ?? _asNum(data['taxAmount']) ?? 0;
    if (subtotal != null && total != null) {
      final computed = subtotal - discount + tax;
      if ((computed - total).abs() > _roundingMargin) {
        errors.add(ValidationError(
          rule: 'sale.total.arithmetic',
          message:
              'sales.total mismatch: subtotal($subtotal) - discount($discount) + tax($tax) != total($total)',
          context: {
            'subtotal': subtotal,
            'discount': discount,
            'tax': tax,
            'total': total,
            'computed': computed,
          },
        ));
      }
    }

    // payments >= total (إن وُجدت؛ بعض البيانات القديمة null)
    final cash = _asNum(data['cashAmount']) ?? _asNum(data['cash_amount']);
    final card = _asNum(data['cardAmount']) ?? _asNum(data['card_amount']);
    final credit =
        _asNum(data['creditAmount']) ?? _asNum(data['credit_amount']);
    // نفحص فقط إن كانت على الأقل واحدة محدّدة — وإلا نتخطى
    final hasAny = cash != null || card != null || credit != null;
    if (hasAny && total != null) {
      final paid = (cash ?? 0) + (card ?? 0) + (credit ?? 0);
      if (paid + _roundingMargin < total) {
        errors.add(ValidationError(
          rule: 'sale.payments.coverage',
          message: 'sale payments ($paid) < total ($total)',
          context: {
            'cashAmount': cash,
            'cardAmount': card,
            'creditAmount': credit,
            'paid': paid,
            'total': total,
          },
        ));
      }
    }
  }

  // ======================================================================
  // sale_items
  // ======================================================================

  void _validateSaleItem(
      Map<String, dynamic> data, List<ValidationError> errors) {
    final productId = data['productId'] ?? data['product_id'];
    if (productId == null || (productId is String && productId.isEmpty)) {
      errors.add(ValidationError(
        rule: 'sale_item.productId.required',
        message: 'sale_items.productId missing or empty',
        context: {'productId': productId},
      ));
    }

    final qty = _asNum(data['qty']) ?? _asNum(data['quantity']);
    if (qty == null || qty <= 0) {
      errors.add(ValidationError(
        rule: 'sale_item.qty.positive',
        message: 'sale_items.qty must be > 0',
        context: {'qty': data['qty']},
      ));
    }

    final unitPrice =
        _asNum(data['unitPrice']) ?? _asNum(data['unit_price']);
    if (unitPrice == null || unitPrice < 0) {
      errors.add(ValidationError(
        rule: 'sale_item.unitPrice.nonNegative',
        message: 'sale_items.unitPrice must be >= 0',
        context: {'unitPrice': data['unitPrice']},
      ));
    }

    final subtotal = _asNum(data['subtotal']);
    if (subtotal != null && qty != null && unitPrice != null) {
      final computed = (qty * unitPrice).round();
      if ((computed - subtotal).abs() > _roundingMargin) {
        errors.add(ValidationError(
          rule: 'sale_item.subtotal.arithmetic',
          message:
              'sale_items.subtotal mismatch: qty($qty) * unitPrice($unitPrice) = $computed != subtotal($subtotal)',
          context: {
            'qty': qty,
            'unitPrice': unitPrice,
            'subtotal': subtotal,
            'computed': computed,
          },
        ));
      }
    }
  }

  // ======================================================================
  // invoices (ZATCA — P0 compliance gate)
  // ======================================================================

  void _validateInvoice(
      Map<String, dynamic> data, List<ValidationError> errors) {
    // P0: QR مطلوب لامتثال ZATCA
    final qr = data['zatcaQr'] ?? data['zatca_qr'];
    if (qr == null || (qr is String && qr.isEmpty)) {
      errors.add(ValidationError(
        rule: 'invoice.zatcaQr.required',
        message:
            'invoices.zatcaQr missing — ZATCA compliance P0 gate failed',
        context: {'zatcaQr': qr},
      ));
    }

    final uuid = data['zatcaUuid'] ?? data['zatca_uuid'];
    if (uuid == null) {
      errors.add(ValidationError(
        rule: 'invoice.zatcaUuid.required',
        message: 'invoices.zatcaUuid missing',
        context: {'zatcaUuid': uuid},
      ));
    }

    final total = _asNum(data['total']);
    if (total == null || total <= 0) {
      errors.add(ValidationError(
        rule: 'invoice.total.positive',
        message: 'invoices.total must be > 0',
        context: {'total': data['total']},
      ));
    }

    // subtotal - discount + taxAmount == total
    final subtotal = _asNum(data['subtotal']);
    final discount = _asNum(data['discount']) ?? 0;
    final taxAmount =
        _asNum(data['taxAmount']) ?? _asNum(data['tax_amount']) ?? 0;
    if (subtotal != null && total != null) {
      final computed = subtotal - discount + taxAmount;
      if ((computed - total).abs() > _roundingMargin) {
        errors.add(ValidationError(
          rule: 'invoice.total.arithmetic',
          message:
              'invoices.total mismatch: subtotal($subtotal) - discount($discount) + tax($taxAmount) != total($total)',
          context: {
            'subtotal': subtotal,
            'discount': discount,
            'taxAmount': taxAmount,
            'total': total,
            'computed': computed,
          },
        ));
      }
    }

    // amountPaid + amountDue == total
    final amountPaid =
        _asNum(data['amountPaid']) ?? _asNum(data['amount_paid']);
    final amountDue = _asNum(data['amountDue']) ?? _asNum(data['amount_due']);
    if (amountPaid != null && amountDue != null && total != null) {
      final computed = amountPaid + amountDue;
      if ((computed - total).abs() > _roundingMargin) {
        errors.add(ValidationError(
          rule: 'invoice.payments.balance',
          message:
              'invoices payments mismatch: paid($amountPaid) + due($amountDue) != total($total)',
          context: {
            'amountPaid': amountPaid,
            'amountDue': amountDue,
            'total': total,
            'computed': computed,
          },
        ));
      }
    }
  }

  // ======================================================================
  // transactions
  // ======================================================================

  static const _validTransactionTypes = {
    'payment',
    'refund',
    'interest',
    'adjustment',
    'receipt',
  };

  void _validateTransaction(
      Map<String, dynamic> data, List<ValidationError> errors) {
    final accountId = data['accountId'] ?? data['account_id'];
    if (accountId == null || (accountId is String && accountId.isEmpty)) {
      errors.add(ValidationError(
        rule: 'transaction.accountId.required',
        message: 'transactions.accountId missing or empty',
        context: {'accountId': accountId},
      ));
    }

    final amount = _asNum(data['amount']);
    if (amount == null || amount == 0) {
      errors.add(ValidationError(
        rule: 'transaction.amount.nonZero',
        message: 'transactions.amount must be != 0',
        context: {'amount': data['amount']},
      ));
    }

    final type = data['type'];
    if (type is! String || !_validTransactionTypes.contains(type)) {
      errors.add(ValidationError(
        rule: 'transaction.type.enum',
        message:
            'transactions.type "$type" not in $_validTransactionTypes',
        context: {'type': type},
      ));
    }
  }

  // ======================================================================
  // returns
  // ======================================================================

  void _validateReturn(
      Map<String, dynamic> data, List<ValidationError> errors) {
    final saleId = data['saleId'] ?? data['sale_id'];
    if (saleId == null || (saleId is String && saleId.isEmpty)) {
      errors.add(ValidationError(
        rule: 'return.saleId.required',
        message: 'returns.saleId missing or empty (FK to sales)',
        context: {'saleId': saleId},
      ));
    }

    final totalRefund =
        _asNum(data['totalRefund']) ?? _asNum(data['total_refund']);
    if (totalRefund == null || totalRefund <= 0) {
      errors.add(ValidationError(
        rule: 'return.totalRefund.positive',
        message: 'returns.totalRefund must be > 0',
        context: {'totalRefund': data['totalRefund']},
      ));
    }

    final reason = data['reason'];
    if (reason == null) {
      errors.add(ValidationError(
        rule: 'return.reason.required',
        message: 'returns.reason missing',
        context: {'reason': reason},
      ));
    }
  }

  // ======================================================================
  // stock_deltas
  // ======================================================================

  static const _validStockOperationTypes = {
    'sale',
    'return',
    'adjustment',
    'transfer',
    'purchase',
    'wastage',
  };

  void _validateStockDelta(
      Map<String, dynamic> data, List<ValidationError> errors) {
    final productId = data['productId'] ?? data['product_id'];
    if (productId == null || (productId is String && productId.isEmpty)) {
      errors.add(ValidationError(
        rule: 'stock_delta.productId.required',
        message: 'stock_deltas.productId missing or empty',
        context: {'productId': productId},
      ));
    }

    final deviceId = data['deviceId'] ?? data['device_id'];
    if (deviceId == null || (deviceId is String && deviceId.isEmpty)) {
      errors.add(ValidationError(
        rule: 'stock_delta.deviceId.required',
        message: 'stock_deltas.deviceId missing or empty',
        context: {'deviceId': deviceId},
      ));
    }

    final qty = _asNum(data['quantityChange']) ??
        _asNum(data['quantity_change']);
    if (qty == null || qty == 0) {
      errors.add(ValidationError(
        rule: 'stock_delta.quantityChange.nonZero',
        message: 'stock_deltas.quantityChange must be != 0',
        context: {'quantityChange': data['quantityChange']},
      ));
    }

    final opType = data['operationType'] ?? data['operation_type'];
    if (opType is! String || !_validStockOperationTypes.contains(opType)) {
      errors.add(ValidationError(
        rule: 'stock_delta.operationType.enum',
        message:
            'stock_deltas.operationType "$opType" not in $_validStockOperationTypes',
        context: {'operationType': opType},
      ));
    }
  }

  // ======================================================================
  // Helpers
  // ======================================================================

  /// يحوّل قيمة JSON إلى num. يرجع null للقيم غير الرقمية/الفاسدة.
  num? _asNum(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      if (value is double && (value.isNaN || value.isInfinite)) return null;
      return value;
    }
    if (value is String) {
      return num.tryParse(value);
    }
    return null;
  }
}
