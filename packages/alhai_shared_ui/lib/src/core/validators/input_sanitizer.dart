/// تنظيف المدخلات من الهجمات
///
/// يوفر حماية ضد:
/// - XSS (Cross-Site Scripting)
/// - SQL Injection
/// - Command Injection
/// - Path Traversal
///
/// ## Usage Policy (L49)
///
/// **All user-facing text inputs MUST be sanitized before storage or display.**
///
/// ### Required usage:
/// - Call [InputSanitizer.sanitize] on free-text fields (names, notes, etc.)
/// - Call [InputSanitizer.sanitizePhone] on phone number fields
/// - Call [InputSanitizer.sanitizeEmail] on email fields
/// - Call [InputSanitizer.sanitizeHtml] when rendering user text in HTML/web contexts
/// - Call [InputSanitizer.sanitizeForDb] for raw SQL (Drift parameterized queries
///   handle this automatically, but use this for any manual queries)
///
/// ### Shorthand via extension:
/// ```dart
/// final clean = userInput.sanitized;       // general sanitization
/// final phone = rawPhone.sanitizedPhone;   // phone sanitization
/// final name  = rawName.sanitizedName;     // name sanitization
/// ```
///
/// ### Enforcement:
/// - Add `// ignore: unsanitized_input` if you intentionally skip sanitization
///   (e.g., for pre-validated internal data). Document the reason.
/// - In code review, flag any `TextField.onChanged` or `TextEditingController`
///   usage that stores user input without calling an [InputSanitizer] method.
/// - Consider wrapping [TextFormField] with [SanitizedTextFormField] (below)
///   which auto-sanitizes on save.
library;

import 'package:flutter/material.dart';

/// تنظيف المدخلات
///
/// Provides static sanitization methods for different input types.
/// Every public method is pure (no side effects) and null-safe.
///
/// See the library-level documentation above for the mandatory usage policy.
class InputSanitizer {
  InputSanitizer._();

  /// الأحرف الخطرة في HTML
  static const Map<String, String> _htmlEntities = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#x27;',
    '/': '&#x2F;',
    '`': '&#x60;',
    '=': '&#x3D;',
  };

  /// تنظيف النص من XSS
  /// يحول الأحرف الخطرة إلى HTML entities
  static String sanitizeHtml(String input) {
    var result = input;
    for (final entry in _htmlEntities.entries) {
      result = result.replaceAll(entry.key, entry.value);
    }
    return result;
  }

  /// إزالة علامات HTML بالكامل
  static String stripHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// تنظيف النص للاستخدام في قاعدة البيانات
  /// ملاحظة: هذا للحماية الإضافية، Drift يستخدم parameterized queries
  static String sanitizeForDb(String input) {
    // إزالة أحرف التحكم
    var result = input.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    // Escape الأحرف الخاصة
    result = result
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "''")
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');

    return result;
  }

  /// تنظيف النص للاستخدام في الـ shell commands
  /// ⚠️ تجنب استخدام shell commands مع مدخلات المستخدم قدر الإمكان
  static String sanitizeForShell(String input) {
    // إزالة الأحرف الخطرة
    return input.replaceAll(RegExp(r'[;&|`$(){}[\]<>\\!#*?~]'), '');
  }

  /// تنظيف مسار الملف من Path Traversal
  static String sanitizePath(String input) {
    // إزالة محاولات الخروج من المجلد
    var result = input
        .replaceAll('..', '')
        .replaceAll('//', '/')
        .replaceAll('\\\\', '\\');

    // إزالة الأحرف الخطرة
    result = result.replaceAll(RegExp(r'[<>:"|?*\x00-\x1F]'), '');

    return result;
  }

  /// تنظيف اسم الملف
  static String sanitizeFilename(String input) {
    // الأحرف المسموحة فقط
    var result = input.replaceAll(
      RegExp(r'[^a-zA-Z0-9._\-\u0600-\u06FF ]'),
      '',
    );

    // إزالة النقاط المتعددة
    result = result.replaceAll(RegExp(r'\.{2,}'), '.');

    // إزالة المسافات الزائدة
    result = result.trim().replaceAll(RegExp(r'\s+'), ' ');

    return result;
  }

  /// تنظيف URL
  static String sanitizeUrl(String input) {
    // إزالة javascript: و data: protocols
    if (input.toLowerCase().startsWith('javascript:') ||
        input.toLowerCase().startsWith('data:') ||
        input.toLowerCase().startsWith('vbscript:')) {
      return '';
    }

    // إزالة الأحرف الخطرة
    return input.replaceAll(
      RegExp(
        '[<>"'
        "'"
        ']',
      ),
      '',
    );
  }

  /// تنظيف عام للنصوص
  /// يزيل الأحرف الخطرة مع الحفاظ على النص العربي
  static String sanitize(String input) {
    // إزالة أحرف التحكم ما عدا السطر الجديد
    var result = input.replaceAll(RegExp(r'[\x00-\x09\x0B-\x1F\x7F]'), '');

    // تطبيع المسافات
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    return result.trim();
  }

  /// تنظيف رقم الهاتف
  static String sanitizePhone(String input) {
    // الاحتفاظ بالأرقام و + فقط
    return input.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// تنظيف البريد الإلكتروني
  static String sanitizeEmail(String input) {
    return input.trim().toLowerCase();
  }

  /// تنظيف الاسم
  static String sanitizeName(String input) {
    // السماح بالحروف العربية والإنجليزية والمسافات
    var result = input.replaceAll(RegExp(r'[^a-zA-Z\u0600-\u06FF\s\-]'), '');

    // تطبيع المسافات
    result = result.replaceAll(RegExp(r'\s+'), ' ');

    return result.trim();
  }

  /// تنظيف الأرقام فقط
  static String sanitizeNumeric(String input) {
    return input.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// تنظيف الأرقام مع الفاصلة العشرية
  static String sanitizeDecimal(String input) {
    // السماح بالأرقام ونقطة واحدة فقط
    var result = input.replaceAll(RegExp(r'[^\d.]'), '');

    // التأكد من نقطة واحدة فقط
    final parts = result.split('.');
    if (parts.length > 2) {
      result = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    return result;
  }

  /// التحقق من وجود محتوى خطر
  static bool containsDangerousContent(String input) {
    final lowered = input.toLowerCase();

    // فحص الـ scripts
    if (lowered.contains('<script') ||
        lowered.contains('javascript:') ||
        lowered.contains('onerror=') ||
        lowered.contains('onload=') ||
        lowered.contains('onclick=')) {
      return true;
    }

    // فحص SQL injection patterns
    // Match actual SQL attack patterns, not standalone English words like "or"/"and"
    final sqlPattern = RegExp(
      r"(--\s|;\s*\b(DROP|ALTER|TRUNCATE|EXEC)\b|'\s*OR\s+\d+\s*=\s*\d+|'\s*OR\s+'[^']*'\s*=\s*'|;\s*DROP\s|UNION\s+(ALL\s+)?SELECT\s|'\s*;\s*DELETE\s|'\s*;\s*INSERT\s|'\s*;\s*UPDATE\s|/\*.*\*/)",
      caseSensitive: false,
    );
    if (sqlPattern.hasMatch(input)) {
      return true;
    }

    return false;
  }

  /// تنظيف JSON string
  static String sanitizeJsonString(String input) {
    return input
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}

/// Extension لسهولة الاستخدام
extension StringSanitizer on String {
  /// تنظيف من XSS
  String get sanitizedHtml => InputSanitizer.sanitizeHtml(this);

  /// تنظيف للـ DB
  String get sanitizedForDb => InputSanitizer.sanitizeForDb(this);

  /// تنظيف عام
  String get sanitized => InputSanitizer.sanitize(this);

  /// تنظيف الاسم
  String get sanitizedName => InputSanitizer.sanitizeName(this);

  /// تنظيف الهاتف
  String get sanitizedPhone => InputSanitizer.sanitizePhone(this);

  /// تنظيف البريد
  String get sanitizedEmail => InputSanitizer.sanitizeEmail(this);

  /// هل يحتوي على محتوى خطر؟
  bool get hasDangerousContent => InputSanitizer.containsDangerousContent(this);
}

// ============================================================================
// SANITIZED FORM FIELD (L49)
// ============================================================================

/// A [TextFormField] wrapper that automatically sanitizes input on save/submit.
///
/// Use this instead of raw [TextFormField] for any user-facing text input
/// to enforce the sanitization policy without manual calls.
///
/// Example:
/// ```dart
/// SanitizedTextFormField(
///   sanitizer: InputSanitizer.sanitizeName,
///   decoration: const InputDecoration(labelText: 'الاسم'),
///   onSaved: (clean) => name = clean ?? '',
/// )
/// ```
class SanitizedTextFormField extends StatelessWidget {
  /// The sanitization function to apply. Defaults to [InputSanitizer.sanitize].
  final String Function(String) sanitizer;

  /// Standard [TextFormField] parameters.
  final InputDecoration? decoration;
  final TextEditingController? controller;
  final String? initialValue;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final bool enabled;
  final TextDirection? textDirection;
  final AutovalidateMode? autovalidateMode;

  const SanitizedTextFormField({
    super.key,
    this.sanitizer = InputSanitizer.sanitize,
    this.decoration,
    this.controller,
    this.initialValue,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.textDirection,
    this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      decoration: decoration,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      textDirection: textDirection,
      autovalidateMode: autovalidateMode,
      validator: (value) {
        if (value != null && value.hasDangerousContent) {
          return 'المدخل يحتوي على محتوى غير مسموح به';
        }
        return validator?.call(value);
      },
      onSaved: (value) {
        final sanitized = value != null ? sanitizer(value) : null;
        onSaved?.call(sanitized);
      },
      onChanged: (value) {
        onChanged?.call(sanitizer(value));
      },
    );
  }
}
