/// التحقق من أرقام الهواتف السعودية
///
/// يدعم:
/// - أرقام الجوال: 05xxxxxxxx
/// - الأرقام الدولية: +966 5xxxxxxxx
/// - أرقام الهاتف الثابت: 01xxxxxxx
library;

import 'validation_result.dart';

/// التحقق من الهاتف السعودي
class PhoneValidator {
  PhoneValidator._();

  /// نمط رقم الجوال السعودي
  /// يبدأ بـ 05 ويتكون من 10 أرقام
  static final RegExp _mobilePattern = RegExp(r'^05\d{8}$');

  /// نمط رقم الجوال السعودي مع كود الدولة
  /// +966 5xxxxxxxx أو 00966 5xxxxxxxx
  static final RegExp _mobileWithCountryPattern =
      RegExp(r'^(\+966|00966)5\d{8}$');

  /// نمط الهاتف الثابت السعودي
  /// يبدأ بـ 01 ويتكون من 9 أرقام
  static final RegExp _landlinePattern = RegExp(r'^01\d{7}$');

  /// التحقق من رقم الجوال السعودي
  static ValidationResult validateMobile(String? phone) {
    if (phone == null || phone.isEmpty) {
      return const ValidationResult.failure(
        messageAr: 'رقم الجوال مطلوب',
        messageEn: 'Phone number is required',
        code: 'PHONE_REQUIRED',
      );
    }

    // إزالة المسافات والشرطات
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');

    // التحقق من الصيغة المحلية
    if (_mobilePattern.hasMatch(cleanPhone)) {
      return const ValidationResult.success();
    }

    // التحقق من الصيغة الدولية
    if (_mobileWithCountryPattern.hasMatch(cleanPhone)) {
      return const ValidationResult.success();
    }

    return const ValidationResult.failure(
      messageAr: 'رقم الجوال غير صحيح. يجب أن يبدأ بـ 05',
      messageEn: 'Invalid phone number. Must start with 05',
      code: 'PHONE_INVALID_FORMAT',
    );
  }

  /// التحقق من أي رقم هاتف سعودي (جوال أو ثابت)
  static ValidationResult validate(String? phone) {
    if (phone == null || phone.isEmpty) {
      return const ValidationResult.failure(
        messageAr: 'رقم الهاتف مطلوب',
        messageEn: 'Phone number is required',
        code: 'PHONE_REQUIRED',
      );
    }

    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');

    // التحقق من الجوال
    if (_mobilePattern.hasMatch(cleanPhone) ||
        _mobileWithCountryPattern.hasMatch(cleanPhone)) {
      return const ValidationResult.success();
    }

    // التحقق من الثابت
    if (_landlinePattern.hasMatch(cleanPhone)) {
      return const ValidationResult.success();
    }

    return const ValidationResult.failure(
      messageAr: 'رقم الهاتف غير صحيح',
      messageEn: 'Invalid phone number',
      code: 'PHONE_INVALID',
    );
  }

  /// تنسيق رقم الجوال للعرض
  /// مثال: 0512345678 -> 051 234 5678
  static String format(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanPhone.length == 10 && cleanPhone.startsWith('05')) {
      return '${cleanPhone.substring(0, 3)} ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    }

    return phone;
  }

  /// تحويل إلى الصيغة الدولية
  /// مثال: 0512345678 -> +966512345678
  static String toInternational(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-]'), '');

    if (cleanPhone.startsWith('05')) {
      return '+966${cleanPhone.substring(1)}';
    }

    if (cleanPhone.startsWith('+966') || cleanPhone.startsWith('00966')) {
      return cleanPhone.startsWith('+')
          ? cleanPhone
          : '+${cleanPhone.substring(2)}';
    }

    return phone;
  }

  /// Form validator للاستخدام مع TextFormField
  static String? Function(String?) formValidator({
    String locale = 'ar',
    bool required = true,
  }) {
    return (String? value) {
      if (!required && (value == null || value.isEmpty)) {
        return null;
      }
      final result = validateMobile(value);
      return result.getError(locale);
    };
  }
}
