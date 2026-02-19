/// تنظيف المدخلات من الهجمات
///
/// يوفر حماية ضد:
/// - XSS (Cross-Site Scripting)
/// - SQL Injection
/// - Command Injection
/// - Path Traversal
library;

/// تنظيف المدخلات
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
    var result = input.replaceAll(RegExp(r'[^a-zA-Z0-9._\-\u0600-\u06FF ]'), '');

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
    return input.replaceAll(RegExp('[<>"' "'" ']'), '');
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
    var result = input.replaceAll(
      RegExp(r'[^a-zA-Z\u0600-\u06FF\s\-]'),
      '',
    );

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
    final sqlPattern = RegExp(
      r'(--|;|\bor\b|\band\b|\bunion\b|\bselect\b|\bdrop\b|\bdelete\b|\binsert\b|\bupdate\b)',
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
  bool get hasDangerousContent =>
      InputSanitizer.containsDangerousContent(this);
}
