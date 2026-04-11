import 'package:xml/xml.dart';

import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';

/// Builds UBL TaxTotal XML elements
///
/// Groups line items by VAT category and builds the TaxTotal
/// and TaxSubtotal elements required by ZATCA.
class TaxTotalBuilder {
  /// Build TaxTotal elements for an invoice
  ///
  /// ZATCA requires two TaxTotal elements:
  /// 1. First with TaxAmount only (for the invoice total)
  /// 2. Second with TaxAmount and TaxSubtotal breakdown
  List<XmlElement> buildTaxTotals(ZatcaInvoice invoice) {
    final currencyCode = invoice.currencyCode;
    final totalVat = invoice.totalVatAmount;

    // First TaxTotal: total tax amount only (for display)
    final firstTaxTotal = XmlElement(XmlName('TaxTotal', 'cac'), [], [
      _cbcElement(
        'TaxAmount',
        _fmtAmount(totalVat),
        attributes: {'currencyID': currencyCode},
      ),
    ]);

    // Second TaxTotal: includes TaxSubtotal breakdown by category
    final groups = _groupByVatCategory(invoice.lines);
    final subtotals = <XmlElement>[];

    for (final entry in groups.entries) {
      final lines = entry.value;
      final taxableAmount = lines.fold<double>(
        0.0,
        (sum, l) => sum + l.lineNetAmount,
      );
      final taxAmount = lines.fold<double>(0.0, (sum, l) => sum + l.vatAmount);
      final vatRate = lines.first.vatRate;
      final vatCategoryCode = lines.first.vatCategoryCode;
      final exemptionReason = lines.first.vatExemptionReason;
      final exemptionReasonCode = lines.first.vatExemptionReasonCode;

      subtotals.add(
        _buildTaxSubtotal(
          taxableAmount: taxableAmount,
          taxAmount: taxAmount,
          vatRate: vatRate,
          vatCategoryCode: vatCategoryCode,
          exemptionReason: exemptionReason,
          exemptionReasonCode: exemptionReasonCode,
          currencyCode: currencyCode,
        ),
      );
    }

    final secondTaxTotal = XmlElement(XmlName('TaxTotal', 'cac'), [], [
      _cbcElement(
        'TaxAmount',
        _fmtAmount(totalVat),
        attributes: {'currencyID': currencyCode},
      ),
      ...subtotals,
    ]);

    return [firstTaxTotal, secondTaxTotal];
  }

  /// Build a TaxSubtotal element for a group of lines with the same VAT rate
  XmlElement _buildTaxSubtotal({
    required double taxableAmount,
    required double taxAmount,
    required double vatRate,
    required String vatCategoryCode,
    String? exemptionReason,
    String? exemptionReasonCode,
    required String currencyCode,
  }) {
    // Build TaxCategory children
    final taxCategoryChildren = <XmlNode>[
      _cbcElement('ID', vatCategoryCode),
      _cbcElement('Percent', _fmtAmount(vatRate)),
    ];

    if (exemptionReasonCode != null) {
      taxCategoryChildren.add(
        _cbcElement('TaxExemptionReasonCode', exemptionReasonCode),
      );
    }
    if (exemptionReason != null) {
      taxCategoryChildren.add(
        _cbcElement('TaxExemptionReason', exemptionReason),
      );
    }

    taxCategoryChildren.add(
      XmlElement(XmlName('TaxScheme', 'cac'), [], [_cbcElement('ID', 'VAT')]),
    );

    return XmlElement(XmlName('TaxSubtotal', 'cac'), [], [
      _cbcElement(
        'TaxableAmount',
        _fmtAmount(taxableAmount),
        attributes: {'currencyID': currencyCode},
      ),
      _cbcElement(
        'TaxAmount',
        _fmtAmount(taxAmount),
        attributes: {'currencyID': currencyCode},
      ),
      XmlElement(XmlName('TaxCategory', 'cac'), [], taxCategoryChildren),
    ]);
  }

  /// Group invoice lines by VAT category code and rate
  Map<String, List<ZatcaInvoiceLine>> _groupByVatCategory(
    List<ZatcaInvoiceLine> lines,
  ) {
    final groups = <String, List<ZatcaInvoiceLine>>{};
    for (final line in lines) {
      final key = '${line.vatCategoryCode}_${line.vatRate}';
      groups.putIfAbsent(key, () => []).add(line);
    }
    return groups;
  }

  // ─── Helpers ─────────────────────────────────────────────

  static String _fmtAmount(double value) => value.toStringAsFixed(2);

  static XmlElement _cbcElement(
    String name,
    String text, {
    Map<String, String>? attributes,
  }) {
    return XmlElement(
      XmlName(name, 'cbc'),
      (attributes ?? {}).entries
          .map((e) => XmlAttribute(XmlName(e.key), e.value))
          .toList(),
      [XmlText(text)],
    );
  }
}
