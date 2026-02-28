/// Validation patterns and validators for common use cases.
///
/// **DEPRECATION NOTICE (L65):** This class duplicates validation logic already
/// available in `package:alhai_shared_ui` at
/// `packages/alhai_shared_ui/lib/src/core/validators/`.
///
/// The canonical validation system is [FormValidators] and its backing
/// individual validators (PhoneValidator, EmailValidator, PriceValidator,
/// BarcodeValidator, IbanValidator, InputSanitizer) exported from
/// `package:alhai_shared_ui/alhai_shared_ui.dart`.
///
/// **Migration guide:**
/// ```dart
/// // Before (deprecated):
/// AlhaiValidators.saudiPhone(value);
/// AlhaiValidators.email(value);
/// AlhaiValidators.currency(value);
///
/// // After (canonical):
/// import 'package:alhai_shared_ui/alhai_shared_ui.dart';
/// FormValidators.phone()(value);
/// FormValidators.email()(value);
/// FormValidators.price()(value);
/// ```
///
/// New code should use `FormValidators` from `alhai_shared_ui`.
/// This class will be removed in a future release.
@Deprecated(
  'Use FormValidators from package:alhai_shared_ui instead. '
  'See packages/alhai_shared_ui/lib/src/core/validators/form_validators.dart '
  'for the canonical validation system.',
)
abstract final class AlhaiValidators {
  // ============================================
  // Phone Validators
  // ============================================

  /// Validate Saudi phone number
  static String? saudiPhone(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'رقم الهاتف مطلوب';
    }

    // Remove formatting
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    // Saudi number: 966 + 9 digits OR 05 + 8 digits
    final saudiPattern = RegExp(r'^(966[5][0-9]{8}|0[5][0-9]{8})$');

    if (!saudiPattern.hasMatch(digitsOnly)) {
      return errorMessage ?? 'رقم هاتف سعودي غير صالح';
    }

    return null;
  }

  /// Validate international phone number
  static String? internationalPhone(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'رقم الهاتف مطلوب';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 8 || digitsOnly.length > 15) {
      return errorMessage ?? 'رقم هاتف غير صالح';
    }

    return null;
  }

  // ============================================
  // OTP Validators
  // ============================================

  /// Validate OTP code
  static String? otp(String? value, {int length = 6, String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'رمز التحقق مطلوب';
    }

    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length != length) {
      return errorMessage ?? 'رمز التحقق يجب أن يكون $length أرقام';
    }

    return null;
  }

  // ============================================
  // Email Validator
  // ============================================

  /// Validate email address
  static String? email(String? value, {String? errorMessage}) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'البريد الإلكتروني مطلوب';
    }

    // RFC 5322 compliant pattern (domain labels limited to 63 chars per RFC 1035)
    final emailPattern = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
    );

    if (!emailPattern.hasMatch(value)) {
      return errorMessage ?? 'بريد إلكتروني غير صالح';
    }

    return null;
  }

  // ============================================
  // Required Validators
  // ============================================

  /// Required field validator
  static String? required(String? value, {String? errorMessage}) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage ?? 'هذا الحقل مطلوب';
    }
    return null;
  }

  /// Required with minimum length
  static String? requiredWithMinLength(
    String? value, {
    required int minLength,
    String? requiredMessage,
    String? minLengthMessage,
  }) {
    if (value == null || value.trim().isEmpty) {
      return requiredMessage ?? 'هذا الحقل مطلوب';
    }
    // استخدم trim لحساب الطول الفعلي
    final trimmed = value.trim();
    if (trimmed.length < minLength) {
      return minLengthMessage ?? 'يجب أن يكون $minLength أحرف على الأقل';
    }
    return null;
  }

  // ============================================
  // Number Validators
  // ============================================

  /// Validate currency/price
  static String? currency(
    String? value, {
    double? min,
    double? max,
    String? requiredMessage,
    String? invalidMessage,
    String? minMessage,
    String? maxMessage,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage ?? 'المبلغ مطلوب';
    }

    // تنظيف القيمة قبل التحليل
    final cleaned = value.replaceAll(RegExp(r'[^\d.]'), '');
    final number = double.tryParse(cleaned);
    if (number == null) {
      return invalidMessage ?? 'مبلغ غير صالح';
    }

    if (min != null && number < min) {
      // تنسيق الرقم بدون .0 إذا كان صحيح
      final minDisplay = min == min.truncateToDouble() ? min.toInt().toString() : min.toString();
      return minMessage ?? 'الحد الأدنى $minDisplay';
    }

    if (max != null && number > max) {
      final maxDisplay = max == max.truncateToDouble() ? max.toInt().toString() : max.toString();
      return maxMessage ?? 'الحد الأقصى $maxDisplay';
    }

    return null;
  }

  /// Validate quantity/integer
  static String? quantity(
    String? value, {
    int min = 1,
    int? max,
    String? requiredMessage,
    String? invalidMessage,
    String? minMessage,
    String? maxMessage,
  }) {
    if (value == null || value.isEmpty) {
      return requiredMessage ?? 'الكمية مطلوبة';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return invalidMessage ?? 'كمية غير صالحة';
    }

    if (number < min) {
      return minMessage ?? 'الحد الأدنى $min';
    }

    if (max != null && number > max) {
      return maxMessage ?? 'الحد الأقصى $max';
    }

    return null;
  }

  // ============================================
  // Password Validators
  // ============================================

  /// Validate password strength
  static String? password(
    String? value, {
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecialChar = true,
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'كلمة المرور مطلوبة';
    }

    if (value.length < minLength) {
      return errorMessage ?? 'كلمة المرور يجب أن تكون $minLength أحرف على الأقل';
    }

    if (requireUppercase && !value.contains(RegExp(r'[A-Z]'))) {
      return errorMessage ?? 'يجب أن تحتوي على حرف كبير';
    }

    if (requireLowercase && !value.contains(RegExp(r'[a-z]'))) {
      return errorMessage ?? 'يجب أن تحتوي على حرف صغير';
    }

    if (requireDigit && !value.contains(RegExp(r'[0-9]'))) {
      return errorMessage ?? 'يجب أن تحتوي على رقم';
    }

    if (requireSpecialChar && !value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return errorMessage ?? 'يجب أن تحتوي على رمز خاص';
    }

    return null;
  }

  /// Validate password confirmation
  static String? confirmPassword(
    String? value,
    String? originalPassword, {
    String? errorMessage,
  }) {
    if (value == null || value.isEmpty) {
      return errorMessage ?? 'تأكيد كلمة المرور مطلوب';
    }

    if (value != originalPassword) {
      return errorMessage ?? 'كلمتا المرور غير متطابقتين';
    }

    return null;
  }

  // ============================================
  // Composite Validator
  // ============================================

  /// Combine multiple validators
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
