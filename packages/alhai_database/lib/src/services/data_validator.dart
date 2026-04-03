/// خدمة التحقق من صحة البيانات قبل الكتابة
///
/// تتحقق من البيانات قبل إدراجها في قاعدة البيانات لمنع:
/// - القيم غير المنطقية (مبالغ سالبة، إجماليات صفرية)
/// - البيانات الناقصة (حقول مطلوبة فارغة)
/// - البيانات التالفة (NaN, Infinity, تواريخ مستقبلية بعيدة)

/// نتيجة التحقق من البيانات
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  const ValidationResult.valid()
      : isValid = true,
        errors = const [],
        warnings = const [];

  factory ValidationResult.invalid(List<String> errors, [List<String> warnings = const []]) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }

  @override
  String toString() {
    if (isValid && warnings.isEmpty) return 'ValidationResult: valid';
    final parts = <String>[];
    if (!isValid) parts.add('ERRORS: ${errors.join(', ')}');
    if (warnings.isNotEmpty) parts.add('WARNINGS: ${warnings.join(', ')}');
    return 'ValidationResult: ${parts.join(' | ')}';
  }
}

/// خدمة التحقق من صحة البيانات
class DataValidator {
  /// الحد الأقصى لتاريخ مستقبلي (24 ساعة)
  static const _maxFutureHours = 24;

  /// طرق الدفع المعتمدة
  static const _validPaymentMethods = {'cash', 'card', 'mixed', 'credit'};

  // ============================================================================
  // Sale Validation
  // ============================================================================

  /// التحقق من بيانات البيع قبل الكتابة
  static ValidationResult validateSale({
    required String? id,
    required String? storeId,
    required String? cashierId,
    required double? subtotal,
    required double? total,
    required double? tax,
    required double? discount,
    required String? paymentMethod,
    required int itemCount,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // المعرفات المطلوبة
    if (id == null || id.isEmpty) {
      errors.add('sale id is required');
    }
    if (storeId == null || storeId.isEmpty) {
      errors.add('store_id is required');
    }
    if (cashierId == null || cashierId.isEmpty) {
      errors.add('cashier_id is required');
    }

    // عدد العناصر
    if (itemCount <= 0) {
      errors.add('sale must have at least 1 item (got $itemCount)');
    }

    // طريقة الدفع
    if (paymentMethod == null || !_validPaymentMethods.contains(paymentMethod)) {
      errors.add('invalid payment method: $paymentMethod (allowed: $_validPaymentMethods)');
    }

    // المبالغ
    if (total == null || total < 0) {
      errors.add('total must be >= 0 (got $total)');
    }
    if (subtotal != null && subtotal < 0) {
      errors.add('subtotal must be >= 0 (got $subtotal)');
    }
    if (tax != null && tax < 0) {
      errors.add('tax must be >= 0 (got $tax)');
    }
    if (discount != null && discount < 0) {
      errors.add('discount must be >= 0 (got $discount)');
    }

    // فحص NaN / Infinity
    if (total != null && (total.isNaN || total.isInfinite)) {
      errors.add('total is NaN or Infinity');
    }
    if (subtotal != null && (subtotal.isNaN || subtotal.isInfinite)) {
      errors.add('subtotal is NaN or Infinity');
    }

    // التحقق من تطابق الحساب: subtotal - discount + tax ~ total
    if (subtotal != null && total != null && tax != null && discount != null) {
      final expected = subtotal - discount + tax;
      final diff = (expected - total).abs();
      // سماح بفارق تقريب صغير (1 ريال)
      if (diff > 1.0) {
        warnings.add(
          'total mismatch: subtotal($subtotal) - discount($discount) + tax($tax) = $expected, but total = $total (diff=$diff)',
        );
      }
    }

    return errors.isEmpty
        ? ValidationResult(isValid: true, warnings: warnings)
        : ValidationResult.invalid(errors, warnings);
  }

  // ============================================================================
  // Product Validation
  // ============================================================================

  /// التحقق من بيانات المنتج قبل الكتابة
  static ValidationResult validateProduct({
    required String? id,
    required String? storeId,
    required String? name,
    required double? price,
    required double? stockQty,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    if (id == null || id.isEmpty) {
      errors.add('product id is required');
    }
    if (storeId == null || storeId.isEmpty) {
      errors.add('store_id is required');
    }
    if (name == null || name.trim().isEmpty) {
      errors.add('product name is required');
    }
    if (price == null || price < 0) {
      errors.add('price must be >= 0 (got $price)');
    }
    if (price != null && (price.isNaN || price.isInfinite)) {
      errors.add('price is NaN or Infinity');
    }
    if (stockQty != null && stockQty < 0) {
      warnings.add('stock_qty is negative ($stockQty)');
    }

    return errors.isEmpty
        ? ValidationResult(isValid: true, warnings: warnings)
        : ValidationResult.invalid(errors, warnings);
  }

  // ============================================================================
  // Sync Payload Validation
  // ============================================================================

  /// الحقول المطلوبة لكل جدول
  static const _requiredFieldsByTable = <String, List<String>>{
    'sales': ['id', 'storeId', 'receiptNo', 'cashierId', 'total', 'paymentMethod'],
    'sale_items': ['id', 'saleId', 'productId', 'productName', 'unitPrice', 'qty', 'total'],
    'products': ['id', 'storeId', 'name', 'price'],
    'customers': ['id', 'name'],
    'inventory_movements': ['id', 'productId', 'storeId', 'type', 'qty'],
    'returns': ['id', 'storeId', 'saleId'],
    'return_items': ['id', 'returnId', 'productId'],
  };

  /// التحقق من payload المزامنة قبل الإرسال
  static ValidationResult validateSyncPayload(String tableName, Map<String, dynamic> payload) {
    final errors = <String>[];
    final warnings = <String>[];

    // التحقق من وجود id
    final id = payload['id'];
    if (id == null || (id is String && id.isEmpty)) {
      errors.add('sync payload must have a non-empty id');
    }

    // التحقق من الحقول المطلوبة حسب الجدول
    final requiredFields = _requiredFieldsByTable[tableName];
    if (requiredFields != null) {
      for (final field in requiredFields) {
        final value = payload[field];
        if (value == null) {
          errors.add('required field "$field" is null for table "$tableName"');
        } else if (value is String && value.isEmpty) {
          errors.add('required field "$field" is empty for table "$tableName"');
        }
      }
    }

    // فحص القيم الرقمية (NaN, Infinity)
    for (final entry in payload.entries) {
      if (entry.value is double) {
        final val = entry.value as double;
        if (val.isNaN) {
          errors.add('field "${entry.key}" is NaN');
        } else if (val.isInfinite) {
          errors.add('field "${entry.key}" is Infinity');
        }
      }
    }

    // فحص التواريخ (ليست في المستقبل البعيد)
    final dateFields = ['createdAt', 'created_at', 'updatedAt', 'updated_at'];
    for (final field in dateFields) {
      final value = payload[field];
      if (value is String && value.isNotEmpty) {
        final date = DateTime.tryParse(value);
        if (date != null) {
          final maxFuture = DateTime.now().add(Duration(hours: _maxFutureHours));
          if (date.isAfter(maxFuture)) {
            warnings.add('date field "$field" is far in the future: $value');
          }
        }
      }
    }

    return errors.isEmpty
        ? ValidationResult(isValid: true, warnings: warnings)
        : ValidationResult.invalid(errors, warnings);
  }

  // ============================================================================
  // Numeric Safety
  // ============================================================================

  /// التحقق من أن القيمة الرقمية آمنة (ليست NaN أو Infinity)
  static bool isNumericSafe(double? value) {
    if (value == null) return true; // null مقبول إذا كان الحقل اختياري
    return !value.isNaN && !value.isInfinite;
  }

  /// تنظيف القيمة الرقمية - استبدال NaN/Infinity بالقيمة الافتراضية
  static double sanitizeNumeric(double? value, {double defaultValue = 0.0}) {
    if (value == null || value.isNaN || value.isInfinite) return defaultValue;
    return value;
  }
}
