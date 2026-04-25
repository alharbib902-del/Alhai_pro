/// P0-31: receipt customisation settings.
///
/// Persisted as a per-store KV record in `settings_table` (one row per
/// `(storeId, key)` pair). The receipt_settings screen reads/writes
/// these via [ReceiptSettingsRepository], and `ReceiptPdfGenerator`
/// honors them at print time. Pre-fix the screen wrote the keys but
/// the generator ignored every one of them — every "show this row"
/// toggle was cosmetic.
///
/// Plain Dart class (no freezed) — alhai_pos stays codegen-light, and
/// the field count is small enough that manual `copyWith` doesn't
/// introduce real maintenance cost.
library;

class ReceiptSettings {
  /// Optional custom header text printed above the store info block.
  /// Empty string treated as "no custom header".
  final String headerText;

  /// Optional custom footer text printed below the totals block.
  /// Empty string falls back to the default "شكراً لزيارتكم!" line.
  final String footerText;

  /// Render the store logo (NOTE: PDF generator currently has no
  /// logo path wired in — kept on the model so the screen can still
  /// surface the toggle, but treated as a no-op until the generator
  /// gains logo rendering. Documented intentionally.)
  final bool showLogo;

  /// Show the customer-name row when a customer is attached to the
  /// sale. Off → row is suppressed (privacy / receipt brevity).
  final bool showCustomerName;

  /// Show the cashier-name row.
  final bool showCashierName;

  /// Show the store address line in the header block.
  final bool showStoreAddress;

  /// Receipt paper width. Common values: '58mm', '80mm'. Generator
  /// converts to PDF page width via `mm * PdfPageFormat.mm`.
  final String paperWidth;

  const ReceiptSettings({
    this.headerText = '',
    this.footerText = '',
    this.showLogo = true,
    this.showCustomerName = true,
    this.showCashierName = true,
    this.showStoreAddress = true,
    this.paperWidth = '80mm',
  });

  /// Defaults — used when no row exists for the store yet, and when
  /// no settings were passed to a generator call (back-compat path).
  static const defaults = ReceiptSettings();

  /// Parse the paper-width string into millimeters. Unknown values
  /// fall back to 80mm so a typo in the settings UI doesn't break
  /// receipt printing.
  double get paperWidthMm {
    switch (paperWidth) {
      case '58mm':
        return 58.0;
      case '80mm':
        return 80.0;
      default:
        return 80.0;
    }
  }

  ReceiptSettings copyWith({
    String? headerText,
    String? footerText,
    bool? showLogo,
    bool? showCustomerName,
    bool? showCashierName,
    bool? showStoreAddress,
    String? paperWidth,
  }) {
    return ReceiptSettings(
      headerText: headerText ?? this.headerText,
      footerText: footerText ?? this.footerText,
      showLogo: showLogo ?? this.showLogo,
      showCustomerName: showCustomerName ?? this.showCustomerName,
      showCashierName: showCashierName ?? this.showCashierName,
      showStoreAddress: showStoreAddress ?? this.showStoreAddress,
      paperWidth: paperWidth ?? this.paperWidth,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReceiptSettings &&
          headerText == other.headerText &&
          footerText == other.footerText &&
          showLogo == other.showLogo &&
          showCustomerName == other.showCustomerName &&
          showCashierName == other.showCashierName &&
          showStoreAddress == other.showStoreAddress &&
          paperWidth == other.paperWidth;

  @override
  int get hashCode => Object.hash(
        headerText,
        footerText,
        showLogo,
        showCustomerName,
        showCashierName,
        showStoreAddress,
        paperWidth,
      );
}
