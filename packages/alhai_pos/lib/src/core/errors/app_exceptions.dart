/// استثناءات التطبيق المخصصة - Custom Exceptions
///
/// توفر رسائل خطأ واضحة بالعربي للمستخدم
library;

// ============================================================================
// BASE EXCEPTION
// ============================================================================

/// الاستثناء الأساسي للتطبيق
abstract class AppException implements Exception {
  /// رسالة الخطأ للمطور
  final String message;

  /// رسالة الخطأ للمستخدم (بالعربي)
  final String userMessage;

  /// كود الخطأ
  final String? code;

  /// تفاصيل إضافية
  final dynamic details;

  const AppException({
    required this.message,
    required this.userMessage,
    this.code,
    this.details,
  });

  @override
  String toString() => '$runtimeType: $message';
}

// ============================================================================
// NETWORK EXCEPTIONS
// ============================================================================

/// استثناءات الشبكة
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error',
    super.userMessage = 'خطأ في الاتصال بالخادم',
    super.code,
    super.details,
  });

  /// لا يوجد اتصال بالإنترنت
  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No internet connection',
      userMessage: 'لا يوجد اتصال بالإنترنت',
      code: 'NO_CONNECTION',
    );
  }

  /// انتهاء وقت الطلب
  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Request timeout',
      userMessage: 'انتهى وقت الطلب، حاول مرة أخرى',
      code: 'TIMEOUT',
    );
  }

  /// خطأ في الخادم
  factory NetworkException.serverError([int? statusCode]) {
    return NetworkException(
      message: 'Server error: $statusCode',
      userMessage: 'خطأ في الخادم، حاول لاحقاً',
      code: 'SERVER_ERROR',
      details: {'statusCode': statusCode},
    );
  }
}

// ============================================================================
// AUTH EXCEPTIONS
// ============================================================================

/// استثناءات المصادقة
class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication error',
    super.userMessage = 'خطأ في المصادقة',
    super.code,
    super.details,
  });

  /// جلسة منتهية
  factory AuthException.sessionExpired() {
    return const AuthException(
      message: 'Session expired',
      userMessage: 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً',
      code: 'SESSION_EXPIRED',
    );
  }

  /// غير مصرح
  factory AuthException.unauthorized() {
    return const AuthException(
      message: 'Unauthorized',
      userMessage: 'غير مصرح لك بهذا الإجراء',
      code: 'UNAUTHORIZED',
    );
  }

  /// رمز OTP غير صحيح
  factory AuthException.invalidOtp() {
    return const AuthException(
      message: 'Invalid OTP',
      userMessage: 'رمز التحقق غير صحيح',
      code: 'INVALID_OTP',
    );
  }

  /// رقم هاتف غير صالح
  factory AuthException.invalidPhone() {
    return const AuthException(
      message: 'Invalid phone number',
      userMessage: 'رقم الهاتف غير صالح',
      code: 'INVALID_PHONE',
    );
  }

  /// Token منتهي
  factory AuthException.tokenExpired() {
    return const AuthException(
      message: 'Token expired',
      userMessage: 'انتهت صلاحية التوكن',
      code: 'TOKEN_EXPIRED',
    );
  }
}

// ============================================================================
// DATABASE EXCEPTIONS
// ============================================================================

/// استثناءات قاعدة البيانات
class DatabaseException extends AppException {
  const DatabaseException({
    super.message = 'Database error',
    super.userMessage = 'خطأ في قاعدة البيانات',
    super.code,
    super.details,
  });

  /// فشل إدراج البيانات
  factory DatabaseException.insertFailed([String? table]) {
    return DatabaseException(
      message: 'Insert failed: $table',
      userMessage: 'فشل حفظ البيانات',
      code: 'INSERT_FAILED',
      details: {'table': table},
    );
  }

  /// فشل التحديث
  factory DatabaseException.updateFailed([String? table]) {
    return DatabaseException(
      message: 'Update failed: $table',
      userMessage: 'فشل تحديث البيانات',
      code: 'UPDATE_FAILED',
      details: {'table': table},
    );
  }

  /// العنصر غير موجود
  factory DatabaseException.notFound([String? id]) {
    return DatabaseException(
      message: 'Record not found: $id',
      userMessage: 'العنصر غير موجود',
      code: 'NOT_FOUND',
      details: {'id': id},
    );
  }
}

// ============================================================================
// VALIDATION EXCEPTIONS
// ============================================================================

/// استثناءات التحقق من البيانات
class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Validation error',
    super.userMessage = 'بيانات غير صالحة',
    super.code,
    super.details,
  });

  /// حقل مطلوب
  factory ValidationException.required(String field) {
    return ValidationException(
      message: 'Field required: $field',
      userMessage: 'هذا الحقل مطلوب',
      code: 'REQUIRED',
      details: {'field': field},
    );
  }

  /// قيمة غير صالحة
  factory ValidationException.invalid(String field) {
    return ValidationException(
      message: 'Invalid field: $field',
      userMessage: 'قيمة غير صالحة',
      code: 'INVALID',
      details: {'field': field},
    );
  }
}

// ============================================================================
// BUSINESS EXCEPTIONS
// ============================================================================

/// استثناءات منطق العمل
class BusinessException extends AppException {
  const BusinessException({
    super.message = 'Business error',
    super.userMessage = 'خطأ في العملية',
    super.code,
    super.details,
  });

  /// نفاذ المخزون
  factory BusinessException.outOfStock([String? productName]) {
    return BusinessException(
      message: 'Out of stock: $productName',
      userMessage: productName != null
          ? 'المنتج "$productName" غير متوفر'
          : 'المنتج غير متوفر في المخزون',
      code: 'OUT_OF_STOCK',
      details: {'product': productName},
    );
  }

  /// رصيد غير كافي
  factory BusinessException.insufficientBalance() {
    return const BusinessException(
      message: 'Insufficient balance',
      userMessage: 'الرصيد غير كافي',
      code: 'INSUFFICIENT_BALANCE',
    );
  }

  /// الحد الأقصى للكمية
  factory BusinessException.maxQuantity(int max) {
    return BusinessException(
      message: 'Max quantity exceeded: $max',
      userMessage: 'الحد الأقصى للكمية هو $max',
      code: 'MAX_QUANTITY',
      details: {'max': max},
    );
  }
}

// ============================================================================
// SALE EXCEPTIONS
// ============================================================================

/// استثناءات المبيعات
class SaleException extends AppException {
  const SaleException({
    super.message = 'Sale error',
    super.userMessage = 'خطأ في عملية البيع',
    super.code,
    super.details,
  });

  /// البيع غير موجود
  factory SaleException.notFound(String saleId) {
    return SaleException(
      message: 'Sale not found: $saleId',
      userMessage: 'عملية البيع غير موجودة',
      code: 'SALE_NOT_FOUND',
      details: {'saleId': saleId},
    );
  }

  /// البيع ملغي مسبقاً
  factory SaleException.alreadyVoided(String saleId) {
    return SaleException(
      message: 'Sale already voided: $saleId',
      userMessage: 'عملية البيع ملغية مسبقاً',
      code: 'SALE_ALREADY_VOIDED',
      details: {'saleId': saleId},
    );
  }

  /// السلة فارغة
  factory SaleException.emptyCart() {
    return const SaleException(
      message: 'Cart is empty',
      userMessage: 'السلة فارغة، أضف منتجات أولاً',
      code: 'EMPTY_CART',
    );
  }

  /// طريقة دفع غير صالحة
  factory SaleException.invalidPaymentMethod(String method) {
    return SaleException(
      message: 'Invalid payment method: $method',
      userMessage: 'طريقة الدفع غير صالحة',
      code: 'INVALID_PAYMENT_METHOD',
      details: {'method': method},
    );
  }

  /// لا يمكن إلغاء البيع
  factory SaleException.cannotVoid(String reason) {
    return SaleException(
      message: 'Cannot void sale: $reason',
      userMessage: 'لا يمكن إلغاء البيع: $reason',
      code: 'CANNOT_VOID',
      details: {'reason': reason},
    );
  }

  /// المخزون غير كافٍ
  factory SaleException.insufficientStock(
    String productName,
    double available,
    double requested,
  ) {
    return SaleException(
      message:
          'Insufficient stock for "$productName": available=$available, requested=$requested',
      userMessage:
          'المنتج "$productName" لا يتوفر بالكمية المطلوبة. المتاح: $available، المطلوب: $requested',
      code: 'INSUFFICIENT_STOCK',
      details: {
        'productName': productName,
        'available': available,
        'requested': requested,
      },
    );
  }
}

// ============================================================================
// PERMISSION EXCEPTIONS
// ============================================================================

/// استثناءات الصلاحيات
class PermissionException extends AppException {
  const PermissionException({
    super.message = 'Permission denied',
    super.userMessage = 'ليس لديك صلاحية لهذا الإجراء',
    super.code,
    super.details,
  });

  /// صلاحية مطلوبة
  factory PermissionException.required(String permission) {
    return PermissionException(
      message: 'Permission required: $permission',
      userMessage: 'ليس لديك صلاحية لهذا الإجراء',
      code: 'PERMISSION_REQUIRED',
      details: {'permission': permission},
    );
  }

  /// دور غير كافي
  factory PermissionException.insufficientRole(
    String required,
    String current,
  ) {
    return PermissionException(
      message: 'Role required: $required, current: $current',
      userMessage: 'هذا الإجراء يتطلب صلاحيات أعلى',
      code: 'INSUFFICIENT_ROLE',
      details: {'required': required, 'current': current},
    );
  }
}
