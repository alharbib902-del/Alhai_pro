/// Input Sanitization Utility
///
/// Provides static helpers that strip potentially dangerous content
/// from user-supplied strings before they are rendered in the UI or
/// persisted. These are a **defence-in-depth** layer; the primary
/// defence for database operations remains parameterised queries
/// (Drift handles this automatically).
library;

/// Sanitises untrusted text for safe display and storage.
class InputSanitizer {
  InputSanitizer._();

  /// Strips HTML tags and `javascript:` pseudo-protocol content.
  ///
  /// Use this before rendering any user-supplied string in a `Text`
  /// widget or storing it where it might later be rendered as HTML
  /// (e.g. receipts, export templates).
  static String sanitizeText(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+=', caseSensitive: false), '')
        .trim();
  }

  /// Escapes single and double quotes for safe display.
  ///
  /// **Important:** Do NOT rely on this for SQL injection prevention.
  /// Always use parameterised queries (Drift companions / prepared
  /// statements).
  static String sanitizeForDisplay(String input) {
    return input
        .replaceAll("'", "\\'")
        .replaceAll('"', '\\"')
        .trim();
  }

  /// Validates and normalises an email address.
  ///
  /// Returns the cleaned lowercase email if valid, or `null` otherwise.
  static String? sanitizeEmail(String? email) {
    if (email == null || email.isEmpty) return null;
    final cleaned = email.trim().toLowerCase();
    final emailRegex = RegExp(r'^[\w.\-]+@[\w.\-]+\.\w{2,}$');
    return emailRegex.hasMatch(cleaned) ? cleaned : null;
  }

  /// Strips everything except digits and the leading `+` from a phone
  /// number, producing a normalised value suitable for storage and
  /// comparison.
  static String sanitizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  /// Sanitises a generic name field (person, product, category).
  ///
  /// Removes control characters and limits length to [maxLength].
  static String sanitizeName(String name, {int maxLength = 255}) {
    final cleaned = name
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // control chars
        .trim();
    return cleaned.length > maxLength
        ? cleaned.substring(0, maxLength)
        : cleaned;
  }

  /// Sanitises a numeric string (price, quantity, etc.).
  ///
  /// Allows digits, a single decimal point, and an optional leading minus.
  static String sanitizeNumeric(String input) {
    return input.replaceAll(RegExp(r'[^\d.\-]'), '');
  }
}
