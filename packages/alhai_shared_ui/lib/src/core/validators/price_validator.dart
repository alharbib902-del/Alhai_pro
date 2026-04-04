/// التحقق من الأسعار والمبالغ المالية
///
/// يتحقق من:
/// - القيم الموجبة
/// - الحد الأقصى للمنازل العشرية
/// - الحد الأقصى للقيمة
library;

import 'validation_result.dart';

/// التحقق من الأسعار
class PriceValidator {
  PriceValidator._();

  /// الحد الأقصى للمنازل العشرية (2 للريال السعودي)
  static const int maxDecimalPlaces = 2;

  /// الحد الأقصى للسعر (مليون ريال)
  static const double maxPrice = 1000000.0;

  /// الحد الأدنى للسعر (صفر أو أكثر)
  static const double minPrice = 0.0;

  /// التحقق من السعر
  static ValidationResult validate(
    String? price, {
    bool allowZero = true,
    double? maxValue,
    double? minValue,
  }) {
    if (price == null || price.isEmpty) {
      return const ValidationResult.failure(
        messageAr: 'السعر مطلوب',
        messageEn: 'Price is required',
        code: 'PRICE_REQUIRED',
      );
    }

    // إزالة الفواصل الآلاف
    final cleanPrice = price.replaceAll(',', '');

    // التحقق من أنه رقم صالح
    final numericValue = double.tryParse(cleanPrice);
    if (numericValue == null) {
      return const ValidationResult.failure(
        messageAr: 'السعر غير صحيح',
        messageEn: 'Invalid price format',
        code: 'PRICE_INVALID_FORMAT',
      );
    }

    // التحقق من القيمة السالبة
    if (numericValue < 0) {
      return const ValidationResult.failure(
        messageAr: 'السعر لا يمكن أن يكون سالباً',
        messageEn: 'Price cannot be negative',
        code: 'PRICE_NEGATIVE',
      );
    }

    // التحقق من الصفر
    if (!allowZero && numericValue == 0) {
      return const ValidationResult.failure(
        messageAr: 'السعر يجب أن يكون أكبر من صفر',
        messageEn: 'Price must be greater than zero',
        code: 'PRICE_ZERO',
      );
    }

    // التحقق من الحد الأدنى
    final effectiveMin = minValue ?? minPrice;
    if (numericValue < effectiveMin) {
      return ValidationResult.failure(
        messageAr: 'السعر يجب أن يكون $effectiveMin على الأقل',
        messageEn: 'Price must be at least $effectiveMin',
        code: 'PRICE_TOO_LOW',
      );
    }

    // التحقق من الحد الأقصى
    final effectiveMax = maxValue ?? maxPrice;
    if (numericValue > effectiveMax) {
      return ValidationResult.failure(
        messageAr: 'السعر يجب أن يكون أقل من $effectiveMax',
        messageEn: 'Price must be less than $effectiveMax',
        code: 'PRICE_TOO_HIGH',
      );
    }

    // التحقق من المنازل العشرية
    if (cleanPrice.contains('.')) {
      final decimalPart = cleanPrice.split('.')[1];
      if (decimalPart.length > maxDecimalPlaces) {
        return const ValidationResult.failure(
          messageAr:
              'السعر يجب أن يحتوي على $maxDecimalPlaces منازل عشرية كحد أقصى',
          messageEn: 'Price can have at most $maxDecimalPlaces decimal places',
          code: 'PRICE_TOO_MANY_DECIMALS',
        );
      }
    }

    return const ValidationResult.success();
  }

  /// التحقق من الكمية
  static ValidationResult validateQuantity(
    String? quantity, {
    bool allowZero = false,
    bool allowDecimal = false,
    int? maxValue,
  }) {
    if (quantity == null || quantity.isEmpty) {
      return const ValidationResult.failure(
        messageAr: 'الكمية مطلوبة',
        messageEn: 'Quantity is required',
        code: 'QUANTITY_REQUIRED',
      );
    }

    // التحقق من أنه رقم صالح
    final numericValue = allowDecimal
        ? double.tryParse(quantity)
        : int.tryParse(quantity)?.toDouble();

    if (numericValue == null) {
      return ValidationResult.failure(
        messageAr: allowDecimal
            ? 'الكمية غير صحيحة'
            : 'الكمية يجب أن تكون رقماً صحيحاً',
        messageEn: allowDecimal
            ? 'Invalid quantity'
            : 'Quantity must be a whole number',
        code: 'QUANTITY_INVALID',
      );
    }

    if (numericValue < 0) {
      return const ValidationResult.failure(
        messageAr: 'الكمية لا يمكن أن تكون سالبة',
        messageEn: 'Quantity cannot be negative',
        code: 'QUANTITY_NEGATIVE',
      );
    }

    if (!allowZero && numericValue == 0) {
      return const ValidationResult.failure(
        messageAr: 'الكمية يجب أن تكون أكبر من صفر',
        messageEn: 'Quantity must be greater than zero',
        code: 'QUANTITY_ZERO',
      );
    }

    if (maxValue != null && numericValue > maxValue) {
      return ValidationResult.failure(
        messageAr: 'الكمية يجب أن تكون أقل من $maxValue',
        messageEn: 'Quantity must be less than $maxValue',
        code: 'QUANTITY_TOO_HIGH',
      );
    }

    return const ValidationResult.success();
  }

  /// التحقق من نسبة الخصم (0-100)
  static ValidationResult validateDiscount(String? discount) {
    if (discount == null || discount.isEmpty) {
      return const ValidationResult.success(); // الخصم اختياري
    }

    final numericValue = double.tryParse(discount);
    if (numericValue == null) {
      return const ValidationResult.failure(
        messageAr: 'نسبة الخصم غير صحيحة',
        messageEn: 'Invalid discount percentage',
        code: 'DISCOUNT_INVALID',
      );
    }

    if (numericValue < 0 || numericValue > 100) {
      return const ValidationResult.failure(
        messageAr: 'نسبة الخصم يجب أن تكون بين 0 و 100',
        messageEn: 'Discount must be between 0 and 100',
        code: 'DISCOUNT_OUT_OF_RANGE',
      );
    }

    return const ValidationResult.success();
  }

  /// تنسيق السعر للعرض
  /// مثال: 1234.5 -> 1,234.50 ريال
  static String format(
    double price, {
    String currency = 'ريال',
    bool showCurrency = true,
  }) {
    final formatted = price.toStringAsFixed(maxDecimalPlaces);
    final parts = formatted.split('.');
    final intPart = parts[0];
    final decPart = parts[1];

    // إضافة فواصل الآلاف
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(intPart[i]);
    }

    final result = '$buffer.$decPart';
    return showCurrency ? '$result $currency' : result;
  }

  /// تحويل النص إلى رقم
  static double? parse(String? price) {
    if (price == null || price.isEmpty) return null;
    final cleanPrice = price.replaceAll(RegExp(r'[,\s]'), '');
    return double.tryParse(cleanPrice);
  }

  /// Form validator للاستخدام مع TextFormField
  static String? Function(String?) formValidator({
    String locale = 'ar',
    bool required = true,
    bool allowZero = true,
    double? maxValue,
    double? minValue,
  }) {
    return (String? value) {
      if (!required && (value == null || value.isEmpty)) {
        return null;
      }
      final result = validate(
        value,
        allowZero: allowZero,
        maxValue: maxValue,
        minValue: minValue,
      );
      return result.getError(locale);
    };
  }
}
