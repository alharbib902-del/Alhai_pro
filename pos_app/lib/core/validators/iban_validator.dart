/// التحقق من IBAN السعودي وأرقام الحسابات البنكية
///
/// يدعم:
/// - IBAN السعودي (SA + 22 رقم)
/// - رقم الحساب البنكي
/// - رمز البنك (Bank Code)
library;

import 'validation_result.dart';

/// معلومات البنوك السعودية
class SaudiBanks {
  SaudiBanks._();

  /// رموز البنوك السعودية
  static const Map<String, String> codes = {
    '10': 'البنك الأهلي السعودي',
    '15': 'البنك الفرنسي',
    '20': 'الرياض',
    '30': 'العربي الوطني',
    '40': 'سامبا',
    '45': 'السعودي البريطاني',
    '50': 'الإنماء',
    '55': 'البلاد',
    '60': 'الجزيرة',
    '65': 'السعودي للاستثمار',
    '80': 'الراجحي',
    '90': 'Gulf International',
  };

  /// الحصول على اسم البنك من رمزه
  static String? getBankName(String code) => codes[code];
}

/// التحقق من IBAN
class IbanValidator {
  IbanValidator._();

  /// نمط IBAN السعودي
  /// SA + 2 أرقام تحقق + 2 رمز بنك + 18 رقم حساب
  static final RegExp _saudiIbanPattern = RegExp(r'^SA\d{22}$');

  /// طول IBAN السعودي
  static const int saudiIbanLength = 24;

  /// التحقق من IBAN السعودي
  static ValidationResult validate(String? iban) {
    if (iban == null || iban.isEmpty) {
      return const ValidationResult.failure(
        messageAr: 'رقم الآيبان مطلوب',
        messageEn: 'IBAN is required',
        code: 'IBAN_REQUIRED',
      );
    }

    // إزالة المسافات وتحويل للأحرف الكبيرة
    final cleanIban = iban.replaceAll(RegExp(r'\s'), '').toUpperCase();

    // التحقق من الطول
    if (cleanIban.length != saudiIbanLength) {
      return const ValidationResult.failure(
        messageAr: 'رقم الآيبان يجب أن يتكون من $saudiIbanLength حرف',
        messageEn: 'IBAN must be $saudiIbanLength characters',
        code: 'IBAN_INVALID_LENGTH',
      );
    }

    // التحقق من أنه يبدأ بـ SA
    if (!cleanIban.startsWith('SA')) {
      return const ValidationResult.failure(
        messageAr: 'رقم الآيبان السعودي يجب أن يبدأ بـ SA',
        messageEn: 'Saudi IBAN must start with SA',
        code: 'IBAN_INVALID_COUNTRY',
      );
    }

    // التحقق من الصيغة
    if (!_saudiIbanPattern.hasMatch(cleanIban)) {
      return const ValidationResult.failure(
        messageAr: 'صيغة رقم الآيبان غير صحيحة',
        messageEn: 'Invalid IBAN format',
        code: 'IBAN_INVALID_FORMAT',
      );
    }

    // التحقق من رمز البنك
    final bankCode = cleanIban.substring(4, 6);
    if (!SaudiBanks.codes.containsKey(bankCode)) {
      return const ValidationResult.failure(
        messageAr: 'رمز البنك غير معروف',
        messageEn: 'Unknown bank code',
        code: 'IBAN_UNKNOWN_BANK',
      );
    }

    // التحقق من checksum (MOD 97)
    if (!_verifyMod97(cleanIban)) {
      return const ValidationResult.failure(
        messageAr: 'رقم التحقق غير صحيح',
        messageEn: 'Invalid checksum',
        code: 'IBAN_INVALID_CHECKSUM',
      );
    }

    return const ValidationResult.success();
  }

  /// التحقق من checksum باستخدام MOD 97
  static bool _verifyMod97(String iban) {
    // نقل أول 4 أحرف للنهاية
    final rearranged = iban.substring(4) + iban.substring(0, 4);

    // تحويل الحروف إلى أرقام (A=10, B=11, etc.)
    final numericString = StringBuffer();
    for (var i = 0; i < rearranged.length; i++) {
      final char = rearranged[i];
      if (char.codeUnitAt(0) >= 65 && char.codeUnitAt(0) <= 90) {
        // حرف: تحويل A=10, B=11, etc.
        numericString.write(char.codeUnitAt(0) - 55);
      } else {
        // رقم: إضافة كما هو
        numericString.write(char);
      }
    }

    // حساب MOD 97
    final remainder = _mod97(numericString.toString());
    return remainder == 1;
  }

  /// حساب MOD 97 لعدد كبير (string)
  static int _mod97(String number) {
    var remainder = 0;
    for (var i = 0; i < number.length; i++) {
      final digit = int.parse(number[i]);
      remainder = (remainder * 10 + digit) % 97;
    }
    return remainder;
  }

  /// استخراج معلومات من IBAN
  static IbanInfo? parse(String iban) {
    final result = validate(iban);
    if (!result.isValid) return null;

    final cleanIban = iban.replaceAll(RegExp(r'\s'), '').toUpperCase();

    return IbanInfo(
      iban: cleanIban,
      countryCode: cleanIban.substring(0, 2),
      checkDigits: cleanIban.substring(2, 4),
      bankCode: cleanIban.substring(4, 6),
      accountNumber: cleanIban.substring(6),
      bankName: SaudiBanks.getBankName(cleanIban.substring(4, 6)),
    );
  }

  /// تنسيق IBAN للعرض
  /// مثال: SA0380000000608010167519 -> SA03 8000 0000 6080 1016 7519
  static String format(String iban) {
    final cleanIban = iban.replaceAll(RegExp(r'\s'), '').toUpperCase();
    final buffer = StringBuffer();

    for (var i = 0; i < cleanIban.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(cleanIban[i]);
    }

    return buffer.toString();
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
      final result = validate(value);
      return result.getError(locale);
    };
  }
}

/// معلومات IBAN المستخرجة
class IbanInfo {
  final String iban;
  final String countryCode;
  final String checkDigits;
  final String bankCode;
  final String accountNumber;
  final String? bankName;

  const IbanInfo({
    required this.iban,
    required this.countryCode,
    required this.checkDigits,
    required this.bankCode,
    required this.accountNumber,
    this.bankName,
  });

  @override
  String toString() {
    return 'IbanInfo(bank: $bankName, account: $accountNumber)';
  }
}
