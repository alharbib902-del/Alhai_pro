/// Input Sanitizer
///
/// تنظيف وتحقق المدخلات لمنع:
/// - SQL Injection
/// - XSS (Cross-Site Scripting)
/// - Path Traversal
/// - Command Injection
/// - NoSQL Injection
library;

import 'dart:convert';
import 'package:pos_app/core/monitoring/production_logger.dart';

/// نوع التنظيف
enum SanitizeMode {
  strict,   // إزالة كل شيء مشبوه
  moderate, // إزالة الخطير فقط
  lenient,  // escape فقط
}

/// نتيجة التحقق
class ValidationResult {
  final bool isValid;
  final String? sanitizedValue;
  final List<String> issues;

  const ValidationResult({
    required this.isValid,
    this.sanitizedValue,
    this.issues = const [],
  });

  factory ValidationResult.valid(String value) => ValidationResult(
    isValid: true,
    sanitizedValue: value,
  );

  factory ValidationResult.invalid(List<String> issues) => ValidationResult(
    isValid: false,
    issues: issues,
  );
}

/// Input Sanitizer
class InputSanitizer {
  InputSanitizer._();

  // أنماط خطيرة
  static final _sqlInjectionPatterns = [
    RegExp(r'(\b(SELECT|INSERT|UPDATE|DELETE|DROP|UNION|ALTER|CREATE|TRUNCATE)\b)', caseSensitive: false),
    RegExp(r'''['"]?\s*(OR|AND)\s*['"]?\s*\d+\s*=\s*\d+''', caseSensitive: false),
    RegExp(r';\s*--'),
    RegExp(r'/\*.*\*/'),
    RegExp(r'WAITFOR\s+DELAY', caseSensitive: false),
    RegExp(r'BENCHMARK\s*\(', caseSensitive: false),
  ];

  static final _xssPatterns = [
    RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true),
    RegExp(r'javascript\s*:', caseSensitive: false),
    RegExp(r'on\w+\s*=', caseSensitive: false), // onclick, onerror, etc.
    RegExp(r'<iframe[^>]*>', caseSensitive: false),
    RegExp(r'<object[^>]*>', caseSensitive: false),
    RegExp(r'<embed[^>]*>', caseSensitive: false),
    RegExp(r'expression\s*\(', caseSensitive: false),
    RegExp(r'''url\s*\(\s*['"]?\s*data:''', caseSensitive: false),
  ];

  static final _pathTraversalPatterns = [
    RegExp(r"\.\.[\\/]"),
    RegExp(r"[\\/]\.\."),
    RegExp(r"%2e%2e[\\/]", caseSensitive: false),
    RegExp(r"\.\.%2f", caseSensitive: false),
    RegExp(r"%2f\.\.", caseSensitive: false),
  ];

  static final _commandInjectionPatterns = [
    RegExp(r"[;&|`$]"),
    RegExp(r"\$\([^)]+\)"),
    RegExp(r"`[^`]+`"),
    RegExp(r"\|\|"),
    RegExp(r"&&"),
  ];

  static final _noSqlInjectionPatterns = [
    RegExp(r'\$where\b', caseSensitive: false),
    RegExp(r'\$gt\b', caseSensitive: false),
    RegExp(r'\$lt\b', caseSensitive: false),
    RegExp(r'\$ne\b', caseSensitive: false),
    RegExp(r'\$regex\b', caseSensitive: false),
    RegExp(r'\$or\b', caseSensitive: false),
    RegExp(r'\$and\b', caseSensitive: false),
  ];

  /// تنظيف نص عام
  static String sanitize(String input, {SanitizeMode mode = SanitizeMode.moderate}) {
    var result = input;

    switch (mode) {
      case SanitizeMode.strict:
        result = _removeAllSpecialChars(result);
      case SanitizeMode.moderate:
        result = _escapeHtml(result);
        result = _removeControlChars(result);
      case SanitizeMode.lenient:
        result = _escapeHtml(result);
    }

    return result.trim();
  }

  /// تنظيف للـ SQL
  static String sanitizeForSql(String input) {
    var result = input;

    // Escape quotes
    result = result.replaceAll("'", "''");
    result = result.replaceAll('"', '""');

    // Remove dangerous patterns
    for (final pattern in _sqlInjectionPatterns) {
      result = result.replaceAll(pattern, '');
    }

    return result;
  }

  /// تنظيف للـ HTML/XSS
  static String sanitizeForHtml(String input) {
    var result = _escapeHtml(input);

    // Remove dangerous patterns
    for (final pattern in _xssPatterns) {
      result = result.replaceAll(pattern, '');
    }

    return result;
  }

  /// تنظيف مسار ملف
  static String sanitizeFilePath(String input) {
    var result = input;

    // Remove path traversal
    for (final pattern in _pathTraversalPatterns) {
      result = result.replaceAll(pattern, '');
    }

    // Remove null bytes
    result = result.replaceAll('\x00', '');

    // Only allow safe characters
    result = result.replaceAll(RegExp(r'[^a-zA-Z0-9._\-/\\]'), '');

    return result;
  }

  /// تنظيف للـ JSON
  static String sanitizeForJson(String input) {
    return jsonEncode(input).replaceAll(RegExp(r'^"|"$'), '');
  }

  /// التحقق من المدخلات
  static ValidationResult validate(String input, {
    bool checkSql = true,
    bool checkXss = true,
    bool checkPath = false,
    bool checkCommand = false,
    bool checkNoSql = false,
  }) {
    final issues = <String>[];

    if (checkSql && _containsPattern(input, _sqlInjectionPatterns)) {
      issues.add('Potential SQL injection detected');
    }

    if (checkXss && _containsPattern(input, _xssPatterns)) {
      issues.add('Potential XSS detected');
    }

    if (checkPath && _containsPattern(input, _pathTraversalPatterns)) {
      issues.add('Potential path traversal detected');
    }

    if (checkCommand && _containsPattern(input, _commandInjectionPatterns)) {
      issues.add('Potential command injection detected');
    }

    if (checkNoSql && _containsPattern(input, _noSqlInjectionPatterns)) {
      issues.add('Potential NoSQL injection detected');
    }

    if (issues.isEmpty) {
      return ValidationResult.valid(input);
    }

    AppLogger.warning('InputSanitizer: ${issues.join(", ")} in "$input"', tag: 'InputSanitizer');

    return ValidationResult.invalid(issues);
  }

  /// التحقق من البريد الإلكتروني
  static ValidationResult validateEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.invalid(['Invalid email format']);
    }

    // Check for injection attempts
    final validation = validate(email, checkSql: true, checkXss: true);
    if (!validation.isValid) {
      return validation;
    }

    return ValidationResult.valid(email.toLowerCase().trim());
  }

  /// التحقق من رقم الهاتف
  static ValidationResult validatePhone(String phone) {
    // Remove spaces and common separators
    final cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Saudi phone number pattern
    final phoneRegex = RegExp(r'^(\+966|966|0)?5\d{8}$');

    if (!phoneRegex.hasMatch(cleaned)) {
      return ValidationResult.invalid(['Invalid Saudi phone number']);
    }

    // Normalize to +966 format
    var normalized = cleaned;
    if (normalized.startsWith('0')) {
      normalized = '+966${normalized.substring(1)}';
    } else if (normalized.startsWith('966')) {
      normalized = '+$normalized';
    } else if (!normalized.startsWith('+')) {
      normalized = '+966$normalized';
    }

    return ValidationResult.valid(normalized);
  }

  /// التحقق من الـ PIN
  static ValidationResult validatePin(String pin) {
    if (pin.length < 4 || pin.length > 6) {
      return ValidationResult.invalid(['PIN must be 4-6 digits']);
    }

    if (!RegExp(r'^\d+$').hasMatch(pin)) {
      return ValidationResult.invalid(['PIN must contain only digits']);
    }

    // Check for weak patterns
    if (_isWeakPin(pin)) {
      return ValidationResult.invalid(['PIN is too weak']);
    }

    return ValidationResult.valid(pin);
  }

  /// التحقق من المبلغ المالي
  static ValidationResult validateAmount(String amount) {
    final amountRegex = RegExp(r'^\d+(\.\d{1,2})?$');

    if (!amountRegex.hasMatch(amount)) {
      return ValidationResult.invalid(['Invalid amount format']);
    }

    final value = double.tryParse(amount);
    if (value == null || value < 0) {
      return ValidationResult.invalid(['Amount must be positive']);
    }

    if (value > 999999999) {
      return ValidationResult.invalid(['Amount exceeds maximum limit']);
    }

    return ValidationResult.valid(value.toStringAsFixed(2));
  }

  /// التحقق من الباركود
  static ValidationResult validateBarcode(String barcode) {
    // Remove spaces
    final cleaned = barcode.replaceAll(' ', '');

    // Only alphanumeric
    if (!RegExp(r'^[a-zA-Z0-9\-]+$').hasMatch(cleaned)) {
      return ValidationResult.invalid(['Barcode contains invalid characters']);
    }

    if (cleaned.length < 4 || cleaned.length > 50) {
      return ValidationResult.invalid(['Barcode length is invalid']);
    }

    return ValidationResult.valid(cleaned.toUpperCase());
  }

  /// هل يحتوي على أنماط خطيرة؟
  static bool _containsPattern(String input, List<RegExp> patterns) {
    for (final pattern in patterns) {
      if (pattern.hasMatch(input)) {
        return true;
      }
    }
    return false;
  }

  /// Escape HTML entities
  static String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// إزالة الأحرف الخاصة
  static String _removeAllSpecialChars(String input) {
    return input.replaceAll(RegExp(r'[^a-zA-Z0-9\s\u0600-\u06FF]'), '');
  }

  /// إزالة Control Characters
  static String _removeControlChars(String input) {
    return input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
  }

  /// هل الـ PIN ضعيف؟
  static bool _isWeakPin(String pin) {
    // Sequential digits
    if (RegExp(r'(0123|1234|2345|3456|4567|5678|6789|9876|8765|7654|6543|5432|4321|3210)').hasMatch(pin)) {
      return true;
    }

    // Repeated digits
    if (RegExp(r'^(.)\1+$').hasMatch(pin)) {
      return true;
    }

    // Common PINs
    const weakPins = ['0000', '1111', '1234', '4321', '0123', '9999', '1212', '2580'];
    if (weakPins.contains(pin)) {
      return true;
    }

    return false;
  }
}

/// Extension للتنظيف السهل
extension SanitizeExtension on String {
  String get sanitized => InputSanitizer.sanitize(this);
  String get sqlSafe => InputSanitizer.sanitizeForSql(this);
  String get htmlSafe => InputSanitizer.sanitizeForHtml(this);
  String get pathSafe => InputSanitizer.sanitizeFilePath(this);
  ValidationResult get validated => InputSanitizer.validate(this);
}
