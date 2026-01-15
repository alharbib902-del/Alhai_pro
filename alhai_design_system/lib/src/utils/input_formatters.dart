import 'package:flutter/services.dart';

/// Input formatters for common use cases
abstract final class AlhaiInputFormatters {
  // ============================================
  // Phone Formatters
  // ============================================

  /// Saudi phone number formatter (+966 5XX XXX XXXX)
  static TextInputFormatter saudiPhone() => _SaudiPhoneFormatter();

  /// International phone formatter (digits only with + prefix)
  static TextInputFormatter internationalPhone() => _InternationalPhoneFormatter();

  // ============================================
  // OTP Formatter
  // ============================================

  /// OTP code formatter (digits only, max length)
  static TextInputFormatter otp({int maxLength = 6}) =>
      _OtpFormatter(maxLength: maxLength);

  // ============================================
  // Currency Formatters
  // ============================================

  /// Currency formatter with 2 decimal places
  static TextInputFormatter currency({
    int maxIntegerDigits = 10,
    int decimalDigits = 2,
  }) =>
      _CurrencyFormatter(
        maxIntegerDigits: maxIntegerDigits,
        decimalDigits: decimalDigits,
      );

  /// Integer currency (no decimals)
  static TextInputFormatter integerCurrency({int maxDigits = 10}) =>
      _IntegerCurrencyFormatter(maxDigits: maxDigits);

  // ============================================
  // Quantity Formatter
  // ============================================

  /// Quantity formatter (positive integers only)
  static TextInputFormatter quantity({int maxDigits = 5, int maxValue = 99999}) =>
      _QuantityFormatter(maxDigits: maxDigits, maxValue: maxValue);

  // ============================================
  // General Formatters
  // ============================================

  /// Digits only
  static TextInputFormatter digitsOnly() => FilteringTextInputFormatter.digitsOnly;

  /// Allow only specific characters
  static TextInputFormatter allow(String pattern) =>
      FilteringTextInputFormatter.allow(RegExp(pattern));

  /// Deny specific characters
  static TextInputFormatter deny(String pattern) =>
      FilteringTextInputFormatter.deny(RegExp(pattern));

  /// Max length
  static TextInputFormatter maxLength(int length) =>
      LengthLimitingTextInputFormatter(length);

  /// Uppercase only
  static TextInputFormatter uppercase() => _UppercaseFormatter();

  /// Lowercase only
  static TextInputFormatter lowercase() => _LowercaseFormatter();

  /// No spaces
  static TextInputFormatter noSpaces() =>
      FilteringTextInputFormatter.deny(RegExp(r'\s'));

  /// Arabic letters only
  static TextInputFormatter arabicOnly() =>
      FilteringTextInputFormatter.allow(RegExp(r'[\u0600-\u06FF\s]'));

  /// English letters only
  static TextInputFormatter englishOnly() =>
      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'));
}

/// Saudi phone formatter (+966 5XX XXX XXXX)
class _SaudiPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all non-digits
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 12 digits (966 + 9 digits)
    final limited = digitsOnly.length > 12 ? digitsOnly.substring(0, 12) : digitsOnly;

    // Format: +966 5XX XXX XXXX
    final buffer = StringBuffer();
    for (int i = 0; i < limited.length; i++) {
      if (i == 0) {
        buffer.write('+');
      }
      buffer.write(limited[i]);
      if (i == 2 || i == 4 || i == 7) {
        if (i < limited.length - 1) buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// International phone formatter
class _InternationalPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow + at start and digits
    var text = newValue.text;
    if (text.isEmpty) {
      return newValue;
    }

    // Keep + if at start
    final hasPlus = text.startsWith('+');
    final digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');

    // Limit to 15 digits
    final limited = digitsOnly.length > 15 ? digitsOnly.substring(0, 15) : digitsOnly;

    final formatted = hasPlus ? '+$limited' : limited;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// OTP formatter
class _OtpFormatter extends TextInputFormatter {
  final int maxLength;

  _OtpFormatter({required this.maxLength});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final limited =
        digitsOnly.length > maxLength ? digitsOnly.substring(0, maxLength) : digitsOnly;

    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

/// Currency formatter
class _CurrencyFormatter extends TextInputFormatter {
  final int maxIntegerDigits;
  final int decimalDigits;

  _CurrencyFormatter({
    required this.maxIntegerDigits,
    required this.decimalDigits,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow only digits and one decimal point
    var text = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');

    // Ensure only one decimal point
    final parts = text.split('.');
    if (parts.length > 2) {
      text = '${parts[0]}.${parts.skip(1).join('')}';
    }

    // Limit integer part
    if (parts.isNotEmpty && parts[0].length > maxIntegerDigits) {
      final intPart = parts[0].substring(0, maxIntegerDigits);
      text = parts.length > 1 ? '$intPart.${parts[1]}' : intPart;
    }

    // Limit decimal part
    final newParts = text.split('.');
    if (newParts.length > 1 && newParts[1].length > decimalDigits) {
      text = '${newParts[0]}.${newParts[1].substring(0, decimalDigits)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

/// Integer currency formatter
class _IntegerCurrencyFormatter extends TextInputFormatter {
  final int maxDigits;

  _IntegerCurrencyFormatter({required this.maxDigits});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    var limited =
        digitsOnly.length > maxDigits ? digitsOnly.substring(0, maxDigits) : digitsOnly;

    // Remove leading zeros
    limited = limited.replaceFirst(RegExp(r'^0+'), '');
    if (limited.isEmpty) limited = '0';

    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

/// Quantity formatter
class _QuantityFormatter extends TextInputFormatter {
  final int maxDigits;
  final int maxValue;

  _QuantityFormatter({required this.maxDigits, required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    var limited =
        digitsOnly.length > maxDigits ? digitsOnly.substring(0, maxDigits) : digitsOnly;

    // Remove leading zeros
    limited = limited.replaceFirst(RegExp(r'^0+'), '');
    if (limited.isEmpty) limited = '';

    // Check max value
    if (limited.isNotEmpty) {
      final value = int.tryParse(limited) ?? 0;
      if (value > maxValue) {
        limited = maxValue.toString();
      }
    }

    return TextEditingValue(
      text: limited,
      selection: TextSelection.collapsed(offset: limited.length),
    );
  }
}

/// Uppercase formatter
class _UppercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

/// Lowercase formatter
class _LowercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toLowerCase(),
      selection: newValue.selection,
    );
  }
}
