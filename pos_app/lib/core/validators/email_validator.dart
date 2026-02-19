/// التحقق من البريد الإلكتروني
///
/// يتبع معيار RFC 5322 مع بعض التبسيط للاستخدام العملي
library;

import 'validation_result.dart';

/// التحقق من البريد الإلكتروني
class EmailValidator {
  EmailValidator._();

  /// نمط البريد الإلكتروني
  /// يتبع RFC 5322 مبسط
  static final RegExp _emailPattern = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@'
    r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );

  /// الحد الأقصى لطول البريد الإلكتروني
  static const int maxLength = 254;

  /// التحقق من البريد الإلكتروني
  static ValidationResult validate(String? email) {
    if (email == null || email.isEmpty) {
      return const ValidationResult.failure(
        messageAr: 'البريد الإلكتروني مطلوب',
        messageEn: 'Email is required',
        code: 'EMAIL_REQUIRED',
      );
    }

    final trimmedEmail = email.trim().toLowerCase();

    // التحقق من الطول
    if (trimmedEmail.length > maxLength) {
      return const ValidationResult.failure(
        messageAr: 'البريد الإلكتروني طويل جداً',
        messageEn: 'Email is too long',
        code: 'EMAIL_TOO_LONG',
      );
    }

    // التحقق من الصيغة
    if (!_emailPattern.hasMatch(trimmedEmail)) {
      return const ValidationResult.failure(
        messageAr: 'البريد الإلكتروني غير صحيح',
        messageEn: 'Invalid email format',
        code: 'EMAIL_INVALID_FORMAT',
      );
    }

    // التحقق من وجود @ واحدة فقط
    if (trimmedEmail.split('@').length != 2) {
      return const ValidationResult.failure(
        messageAr: 'البريد الإلكتروني غير صحيح',
        messageEn: 'Invalid email format',
        code: 'EMAIL_INVALID_FORMAT',
      );
    }

    // التحقق من وجود domain
    final parts = trimmedEmail.split('@');
    final domain = parts[1];

    if (!domain.contains('.')) {
      return const ValidationResult.failure(
        messageAr: 'البريد الإلكتروني غير صحيح',
        messageEn: 'Invalid email domain',
        code: 'EMAIL_INVALID_DOMAIN',
      );
    }

    // التحقق من طول الـ TLD
    final tld = domain.split('.').last;
    if (tld.length < 2) {
      return const ValidationResult.failure(
        messageAr: 'امتداد البريد الإلكتروني غير صحيح',
        messageEn: 'Invalid email TLD',
        code: 'EMAIL_INVALID_TLD',
      );
    }

    return const ValidationResult.success();
  }

  /// التحقق من أن البريد ليس من domain مؤقت
  static ValidationResult validateNotDisposable(String? email) {
    final basicResult = validate(email);
    if (!basicResult.isValid) return basicResult;

    final domain = email!.trim().toLowerCase().split('@')[1];

    // قائمة domains مؤقتة شائعة
    const disposableDomains = [
      'tempmail.com',
      'throwaway.email',
      'guerrillamail.com',
      'mailinator.com',
      '10minutemail.com',
      'temp-mail.org',
      'fakeinbox.com',
      'trashmail.com',
    ];

    if (disposableDomains.contains(domain)) {
      return const ValidationResult.failure(
        messageAr: 'لا يمكن استخدام بريد إلكتروني مؤقت',
        messageEn: 'Disposable email addresses are not allowed',
        code: 'EMAIL_DISPOSABLE',
      );
    }

    return const ValidationResult.success();
  }

  /// تنسيق البريد الإلكتروني
  static String normalize(String email) {
    return email.trim().toLowerCase();
  }

  /// Form validator للاستخدام مع TextFormField
  static String? Function(String?) formValidator({
    String locale = 'ar',
    bool required = true,
    bool allowDisposable = true,
  }) {
    return (String? value) {
      if (!required && (value == null || value.isEmpty)) {
        return null;
      }

      final result = allowDisposable
          ? validate(value)
          : validateNotDisposable(value);

      return result.getError(locale);
    };
  }
}
