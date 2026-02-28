/// نتيجة التحقق من المدخلات
///
/// تحتوي على:
/// - حالة النجاح/الفشل
/// - رسالة الخطأ (عربي/إنجليزي)
/// - كود الخطأ
library;

/// نتيجة التحقق
class ValidationResult {
  /// هل التحقق ناجح؟
  final bool isValid;

  /// رسالة الخطأ بالعربية
  final String? errorAr;

  /// رسالة الخطأ بالإنجليزية
  final String? errorEn;

  /// كود الخطأ للتتبع
  final String? errorCode;

  /// Constructor داخلي
  const ValidationResult._internal({
    required this.isValid,
    this.errorAr,
    this.errorEn,
    this.errorCode,
  });

  /// نتيجة ناجحة
  const ValidationResult.success()
      : isValid = true,
        errorAr = null,
        errorEn = null,
        errorCode = null;

  /// نتيجة فاشلة
  const ValidationResult.failure({
    required String messageAr,
    required String messageEn,
    String? code,
  })  : isValid = false,
        errorAr = messageAr,
        errorEn = messageEn,
        errorCode = code;

  /// Factory constructor للاستخدام العام
  factory ValidationResult.fromBool(bool valid, {String? errorAr, String? errorEn, String? code}) {
    return ValidationResult._internal(
      isValid: valid,
      errorAr: errorAr,
      errorEn: errorEn,
      errorCode: code,
    );
  }

  /// الحصول على رسالة الخطأ حسب اللغة
  String? getError(String locale) {
    if (isValid) return null;
    return locale == 'ar' ? errorAr : errorEn;
  }

  /// تحويل إلى String? للاستخدام مع TextFormField validator
  String? toFormError(String locale) => getError(locale);

  @override
  String toString() {
    if (isValid) return 'ValidationResult: Valid';
    return 'ValidationResult: Invalid - $errorAr';
  }
}

/// Extension للاستخدام السهل
extension ValidationResultExtension on ValidationResult {
  /// هل التحقق فاشل؟
  bool get isInvalid => !isValid;
}
