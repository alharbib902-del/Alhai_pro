/// ZATCA invoice type codes per UBL 2.1 / ZATCA specs
///
/// Reference: ZATCA E-Invoice Data Dictionary v2.1
enum InvoiceTypeCode {
  /// 388 - Standard Tax Invoice
  standard(code: '388', name: 'Standard Tax Invoice'),

  /// 381 - Credit Note
  creditNote(code: '381', name: 'Credit Note'),

  /// 383 - Debit Note
  debitNote(code: '383', name: 'Debit Note');

  const InvoiceTypeCode({required this.code, required this.name});

  /// The UBL numeric code
  final String code;

  /// Human-readable name
  final String name;

  /// Parse from string code, e.g. '388' -> standard
  static InvoiceTypeCode fromCode(String code) {
    return InvoiceTypeCode.values.firstWhere(
      (e) => e.code == code,
      orElse: () => throw ArgumentError('Unknown InvoiceTypeCode: $code'),
    );
  }
}

/// ZATCA invoice sub-type flags (BT-3)
///
/// The sub-type is a 7-character code where each position is 0 or 1.
/// Position meanings:
///   [0] = 0: standard, 1: simplified
///   [1] = 0: not third-party, 1: third-party
///   [2] = 0: not nominal, 1: nominal
///   [3] = 0: not exports, 1: exports
///   [4] = 0: not summary, 1: summary
///   [5] = 0: not self-billed, 1: self-billed
///   [6] = reserved (always 0)
class InvoiceSubType {
  /// Standard tax invoice (B2B)
  static const String standardB2B = '0100000';

  /// Simplified tax invoice (B2C)
  static const String simplifiedB2C = '0200000';

  /// Standard third-party invoice
  static const String standardThirdParty = '0110000';

  /// Simplified third-party invoice
  static const String simplifiedThirdParty = '0210000';

  /// Standard export invoice
  static const String standardExport = '0100100';

  /// Self-billed standard invoice
  static const String standardSelfBilled = '0100010';

  const InvoiceSubType._();
}
