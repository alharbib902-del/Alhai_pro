/// Text input sanitizer for cashier-entered strings.
///
/// Complements the legacy [InputSanitizer] in `core/validators/` (which focuses
/// on XSS / SQL / shell hardening) by targeting the day-to-day integrity risks
/// of fast-moving POS data entry:
///
///   * Bidirectional override characters (U+202A..U+202E) that can flip "100"
///     into "001" on printed receipts or in audit log renderings.
///   * Zero-width joiners / spaces (U+200B..U+200F, U+2060..U+2064, U+FEFF)
///     that create invisible aliases — a loyalty-fraud vector where
///     "Ahmed" and "Ahmed\u200B" become distinct customer rows.
///   * C0 / C1 control characters that break thermal-printer raster output.
///   * Stray HTML-like angle brackets — defense in depth for notes that may
///     end up rendered in web admin panels.
///   * Whitespace normalization (collapse runs, trim) so duplicate detection
///     and audit diff tools don't fight leading spaces.
///
/// **Scope boundary**: sanitize at the write boundary (DAO / service), not in
/// UI `onChanged`. One call at the right spot is worth ten at the UI.
///
/// **Class name**: [TextInputSanitizer] — deliberately distinct from the
/// legacy [InputSanitizer] to allow both to be exported from the barrel.
library;

/// Sanitizes human-entered strings for storage, audit, and rendering.
///
/// Opinions:
///   - Strip C0/C1 control chars except optionally \n (0x0A) and \t (0x09)
///   - Strip zero-width chars: U+200B..U+200F, U+202A..U+202E (bidi overrides),
///     U+2060..U+2064, U+FEFF (BOM)
///   - Strip HTML-like angle brackets (defense-in-depth, since Dart Text widgets
///     don't parse HTML — but notes may end up in web admin panels)
///   - Collapse runs of whitespace to single space (except newlines if
///     [preserveNewlines] is true)
///   - Trim leading/trailing whitespace
///   - Optional maximum-length truncation with post-truncate re-trim
///
/// Unicode NFC normalization is intentionally skipped: Dart stdlib has no NFC
/// primitive, and Saudi IMEs emit NFC-normalized Arabic out of the box. Adding
/// a package dependency for a marginal correctness gain isn't worth it here.
class TextInputSanitizer {
  TextInputSanitizer._();

  /// Bidi overrides, zero-width joiners / spaces, invisible formatting marks.
  static final RegExp _invisibleChars = RegExp(
    r'[\u200B-\u200F\u202A-\u202E\u2060-\u2064\uFEFF]',
  );

  /// C0 + C1 control chars (keeps \n and \t).
  static final RegExp _controlCharsKeepNewlineTab = RegExp(
    r'[\x00-\x08\x0B\x0C\x0E-\x1F\x7F-\x9F]',
  );

  /// C0 + C1 control chars (strips everything, including \n and \t).
  static final RegExp _controlCharsStripAll = RegExp(
    r'[\x00-\x1F\x7F-\x9F]',
  );

  /// Simple HTML-tag pattern for defense-in-depth stripping.
  static final RegExp _htmlTagPattern = RegExp(r'<[^>]*>');

  /// Runs of 2+ spaces (newlines and single tabs preserved).
  static final RegExp _spaceRuns = RegExp(r' {2,}');

  /// Runs of any whitespace (including newlines).
  static final RegExp _allWhitespaceRuns = RegExp(r'\s+');

  /// General-purpose sanitizer.
  ///
  /// - [maxLength]: if non-null, truncate to this many characters and re-trim.
  /// - [preserveNewlines]: keep `\n` / `\t` and only collapse `[ \t]+`.
  /// - [allowHtml]: skip the HTML-tag strip (use only for pre-trusted markup).
  static String sanitize(
    String? input, {
    int? maxLength,
    bool preserveNewlines = false,
    bool allowHtml = false,
  }) {
    if (input == null) return '';
    var s = input;

    // Strip invisibles (bidi + zero-width).
    s = s.replaceAll(_invisibleChars, '');

    // Strip control chars. When not preserving newlines, convert \n/\r to
    // spaces FIRST so the later whitespace collapse can merge them — otherwise
    // the control-char strip eats the newline silently and joins lines.
    if (preserveNewlines) {
      s = s.replaceAll(_controlCharsKeepNewlineTab, '');
    } else {
      s = s.replaceAll(RegExp(r'[\r\n]'), ' ');
      s = s.replaceAll(_controlCharsStripAll, '');
    }

    // Strip HTML tags (defense-in-depth).
    if (!allowHtml) {
      s = s.replaceAll(_htmlTagPattern, '');
    }

    // Collapse whitespace. In preserve mode we keep newlines and single tabs
    // intact — only multi-space runs are collapsed (common typo-artifact).
    if (preserveNewlines) {
      s = s.replaceAll(_spaceRuns, ' ');
    } else {
      s = s.replaceAll(_allWhitespaceRuns, ' ');
    }

    s = s.trim();

    if (maxLength != null && s.length > maxLength) {
      s = s.substring(0, maxLength).trim();
    }

    return s;
  }

  /// Sanitize a phone-like input: keep digits and leading '+', drop everything
  /// else. Does NOT validate — pair with `FormValidators.saudiPhone()` for
  /// format validation.
  static String sanitizePhone(String? input) {
    if (input == null) return '';
    final s = input.trim();
    if (s.startsWith('+')) {
      return '+' + s.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
    }
    return s.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Sanitize a free-form name (customer, product, supplier).
  ///
  /// - Max 200 chars
  /// - No newlines (names don't need multi-line)
  /// - No HTML
  static String sanitizeName(String? input) =>
      sanitize(input, maxLength: 200);

  /// Sanitize a free-form note / memo.
  ///
  /// - Max 2000 chars
  /// - Preserves newlines for multi-line notes
  /// - No HTML
  static String sanitizeNote(String? input) =>
      sanitize(input, maxLength: 2000, preserveNewlines: true);
}
