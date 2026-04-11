/// التحقق من الباركود
///
/// يدعم:
/// - EAN-13 (الأكثر شيوعاً)
/// - EAN-8
/// - UPC-A (12 رقم)
/// - Code 128 (أبجدي رقمي)
library;

import 'validation_result.dart';

/// أنواع الباركود المدعومة
enum BarcodeType { ean13, ean8, upcA, code128, any }

/// التحقق من الباركود
class BarcodeValidator {
  BarcodeValidator._();

  /// نمط EAN-13 (13 رقم)
  static final RegExp _ean13Pattern = RegExp(r'^\d{13}$');

  /// نمط EAN-8 (8 أرقام)
  static final RegExp _ean8Pattern = RegExp(r'^\d{8}$');

  /// نمط UPC-A (12 رقم)
  static final RegExp _upcAPattern = RegExp(r'^\d{12}$');

  /// نمط Code 128 (أبجدي رقمي)
  static final RegExp _code128Pattern = RegExp(r'^[\x00-\x7F]+$');

  /// التحقق من الباركود
  static ValidationResult validate(
    String? barcode, {
    BarcodeType type = BarcodeType.any,
  }) {
    if (barcode == null || barcode.isEmpty) {
      return const ValidationResult.failure(
        messageAr: 'الباركود مطلوب',
        messageEn: 'Barcode is required',
        code: 'BARCODE_REQUIRED',
      );
    }

    final cleanBarcode = barcode.trim();

    switch (type) {
      case BarcodeType.ean13:
        return _validateEan13(cleanBarcode);
      case BarcodeType.ean8:
        return _validateEan8(cleanBarcode);
      case BarcodeType.upcA:
        return _validateUpcA(cleanBarcode);
      case BarcodeType.code128:
        return _validateCode128(cleanBarcode);
      case BarcodeType.any:
        // محاولة التحقق من جميع الأنواع
        if (_ean13Pattern.hasMatch(cleanBarcode)) {
          return _validateEan13(cleanBarcode);
        }
        if (_ean8Pattern.hasMatch(cleanBarcode)) {
          return _validateEan8(cleanBarcode);
        }
        if (_upcAPattern.hasMatch(cleanBarcode)) {
          return _validateUpcA(cleanBarcode);
        }
        // Code 128 يقبل أي نص ASCII
        if (cleanBarcode.isNotEmpty) {
          return const ValidationResult.success();
        }
        return const ValidationResult.failure(
          messageAr: 'صيغة الباركود غير صحيحة',
          messageEn: 'Invalid barcode format',
          code: 'BARCODE_INVALID_FORMAT',
        );
    }
  }

  /// التحقق من EAN-13
  static ValidationResult _validateEan13(String barcode) {
    if (!_ean13Pattern.hasMatch(barcode)) {
      return const ValidationResult.failure(
        messageAr: 'باركود EAN-13 يجب أن يتكون من 13 رقم',
        messageEn: 'EAN-13 barcode must be 13 digits',
        code: 'BARCODE_EAN13_LENGTH',
      );
    }

    if (!_verifyEanChecksum(barcode)) {
      return const ValidationResult.failure(
        messageAr: 'رقم التحقق غير صحيح',
        messageEn: 'Invalid checksum',
        code: 'BARCODE_INVALID_CHECKSUM',
      );
    }

    return const ValidationResult.success();
  }

  /// التحقق من EAN-8
  static ValidationResult _validateEan8(String barcode) {
    if (!_ean8Pattern.hasMatch(barcode)) {
      return const ValidationResult.failure(
        messageAr: 'باركود EAN-8 يجب أن يتكون من 8 أرقام',
        messageEn: 'EAN-8 barcode must be 8 digits',
        code: 'BARCODE_EAN8_LENGTH',
      );
    }

    if (!_verifyEanChecksum(barcode)) {
      return const ValidationResult.failure(
        messageAr: 'رقم التحقق غير صحيح',
        messageEn: 'Invalid checksum',
        code: 'BARCODE_INVALID_CHECKSUM',
      );
    }

    return const ValidationResult.success();
  }

  /// التحقق من UPC-A
  static ValidationResult _validateUpcA(String barcode) {
    if (!_upcAPattern.hasMatch(barcode)) {
      return const ValidationResult.failure(
        messageAr: 'باركود UPC-A يجب أن يتكون من 12 رقم',
        messageEn: 'UPC-A barcode must be 12 digits',
        code: 'BARCODE_UPCA_LENGTH',
      );
    }

    if (!_verifyUpcChecksum(barcode)) {
      return const ValidationResult.failure(
        messageAr: 'رقم التحقق غير صحيح',
        messageEn: 'Invalid checksum',
        code: 'BARCODE_INVALID_CHECKSUM',
      );
    }

    return const ValidationResult.success();
  }

  /// التحقق من Code 128
  static ValidationResult _validateCode128(String barcode) {
    if (barcode.isEmpty) {
      return const ValidationResult.failure(
        messageAr: 'الباركود مطلوب',
        messageEn: 'Barcode is required',
        code: 'BARCODE_REQUIRED',
      );
    }

    if (!_code128Pattern.hasMatch(barcode)) {
      return const ValidationResult.failure(
        messageAr: 'باركود Code 128 يجب أن يحتوي على أحرف ASCII فقط',
        messageEn: 'Code 128 barcode must contain ASCII characters only',
        code: 'BARCODE_CODE128_INVALID',
      );
    }

    return const ValidationResult.success();
  }

  /// التحقق من checksum لـ EAN-8 و EAN-13
  static bool _verifyEanChecksum(String barcode) {
    var sum = 0;
    final length = barcode.length;

    for (var i = 0; i < length - 1; i++) {
      final digit = int.parse(barcode[i]);
      // الأرقام في المواقع الفردية تضرب في 1، والزوجية في 3
      sum += digit * ((length - 1 - i) % 2 == 0 ? 1 : 3);
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit == int.parse(barcode[length - 1]);
  }

  /// التحقق من checksum لـ UPC-A
  static bool _verifyUpcChecksum(String barcode) {
    var oddSum = 0;
    var evenSum = 0;

    for (var i = 0; i < 11; i++) {
      final digit = int.parse(barcode[i]);
      if (i % 2 == 0) {
        oddSum += digit;
      } else {
        evenSum += digit;
      }
    }

    final checkDigit = (10 - ((oddSum * 3 + evenSum) % 10)) % 10;
    return checkDigit == int.parse(barcode[11]);
  }

  /// توليد checksum لـ EAN-13
  static String generateEan13Checksum(String barcode12) {
    if (barcode12.length != 12) {
      throw ArgumentError('EAN-13 barcode base must be 12 digits');
    }

    var sum = 0;
    for (var i = 0; i < 12; i++) {
      final digit = int.parse(barcode12[i]);
      sum += digit * (i % 2 == 0 ? 1 : 3);
    }

    final checkDigit = (10 - (sum % 10)) % 10;
    return '$barcode12$checkDigit';
  }

  /// تحديد نوع الباركود
  static BarcodeType? detectType(String barcode) {
    final cleanBarcode = barcode.trim();

    if (_ean13Pattern.hasMatch(cleanBarcode)) {
      return BarcodeType.ean13;
    }
    if (_ean8Pattern.hasMatch(cleanBarcode)) {
      return BarcodeType.ean8;
    }
    if (_upcAPattern.hasMatch(cleanBarcode)) {
      return BarcodeType.upcA;
    }
    if (_code128Pattern.hasMatch(cleanBarcode)) {
      return BarcodeType.code128;
    }

    return null;
  }

  /// Form validator للاستخدام مع TextFormField
  static String? Function(String?) formValidator({
    String locale = 'ar',
    bool required = true,
    BarcodeType type = BarcodeType.any,
  }) {
    return (String? value) {
      if (!required && (value == null || value.isEmpty)) {
        return null;
      }
      final result = validate(value, type: type);
      return result.getError(locale);
    };
  }
}
