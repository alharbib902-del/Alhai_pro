import 'package:xml/xml.dart';

import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/xml/ubl_namespaces.dart';

/// Builds UBL InvoiceLine XML elements from [ZatcaInvoiceLine] models
class InvoiceLineBuilder {
  /// Build a single InvoiceLine XML element
  ///
  /// Reference: ZATCA UBL InvoiceLine structure
  XmlElement buildLine(ZatcaInvoiceLine line, String currencyCode) {
    final children = <XmlNode>[
      _cbcElement('ID', line.lineId),
      _cbcElement(
        'InvoicedQuantity',
        _fmtAmount(line.quantity),
        attributes: {'unitCode': line.unitCode},
      ),
      _cbcElement(
        'LineExtensionAmount',
        _fmtAmount(line.lineNetAmount),
        attributes: {'currencyID': currencyCode},
      ),
    ];

    // Line-level AllowanceCharge (discount)
    final allowance = _buildLineAllowance(line, currencyCode);
    if (allowance != null) children.add(allowance);

    // Line-level TaxTotal
    children.add(_buildLineTaxTotal(line, currencyCode));

    // Item element
    children.add(_buildItem(line));

    // Price element
    children.add(_buildPrice(line, currencyCode));

    return XmlElement(
      XmlName('InvoiceLine', 'cac'),
      [],
      children,
    );
  }

  /// Build all InvoiceLine elements for a list of lines
  List<XmlElement> buildLines(
    List<ZatcaInvoiceLine> lines,
    String currencyCode,
  ) {
    return lines.map((l) => buildLine(l, currencyCode)).toList();
  }

  /// Build the TaxTotal element within an InvoiceLine
  XmlElement _buildLineTaxTotal(
    ZatcaInvoiceLine line,
    String currencyCode,
  ) {
    final taxAmount = _cbcElement(
      'TaxAmount',
      _fmtAmount(line.vatAmount),
      attributes: {'currencyID': currencyCode},
    );

    // Per-line rounding amount (ZATCA mandates this)
    final roundingAmount = _cbcElement(
      'RoundingAmount',
      _fmtAmount(line.lineNetAmount + line.vatAmount),
      attributes: {'currencyID': currencyCode},
    );

    return XmlElement(
      XmlName('TaxTotal', 'cac'),
      [],
      [taxAmount, roundingAmount],
    );
  }

  /// Build the Item element within an InvoiceLine
  XmlElement _buildItem(ZatcaInvoiceLine line) {
    final children = <XmlNode>[
      _cbcElement('Name', line.itemName),
    ];

    // Seller item identification
    if (line.sellerItemId != null) {
      children.add(
        XmlElement(
          XmlName('SellersItemIdentification', 'cac'),
          [],
          [_cbcElement('ID', line.sellerItemId!)],
        ),
      );
    }

    // Standard item identification (barcode / GTIN)
    if (line.barcode != null) {
      children.add(
        XmlElement(
          XmlName('StandardItemIdentification', 'cac'),
          [],
          [
            _cbcElement('ID', line.barcode!, attributes: {'schemeID': 'GTIN'}),
          ],
        ),
      );
    }

    // ClassifiedTaxCategory
    final taxCategoryChildren = <XmlNode>[
      _cbcElement('ID', line.vatCategoryCode),
      _cbcElement('Percent', _fmtAmount(line.vatRate)),
    ];

    // Exemption reason for E (Exempt) or Z (Zero-rated)
    if (line.vatExemptionReason != null) {
      taxCategoryChildren.add(
        _cbcElement('TaxExemptionReason', line.vatExemptionReason!),
      );
    }
    if (line.vatExemptionReasonCode != null) {
      taxCategoryChildren.add(
        _cbcElement('TaxExemptionReasonCode', line.vatExemptionReasonCode!),
      );
    }

    taxCategoryChildren.add(
      XmlElement(
        XmlName('TaxScheme', 'cac'),
        [],
        [_cbcElement('ID', 'VAT')],
      ),
    );

    children.add(
      XmlElement(
        XmlName('ClassifiedTaxCategory', 'cac'),
        [],
        taxCategoryChildren,
      ),
    );

    return XmlElement(
      XmlName('Item', 'cac'),
      [],
      children,
    );
  }

  /// Build the Price element within an InvoiceLine
  XmlElement _buildPrice(ZatcaInvoiceLine line, String currencyCode) {
    final children = <XmlNode>[
      _cbcElement(
        'PriceAmount',
        _fmtAmount(line.unitPrice),
        attributes: {'currencyID': currencyCode},
      ),
    ];

    // AllowanceCharge inside Price (shows gross price and discount)
    if (line.grossPrice != null && line.discountAmount > 0) {
      children.add(
        XmlElement(
          XmlName('AllowanceCharge', 'cac'),
          [],
          [
            _cbcElement('ChargeIndicator', 'false'),
            _cbcElement('AllowanceChargeReason', 'discount'),
            _cbcElement(
              'Amount',
              _fmtAmount(line.discountAmount),
              attributes: {'currencyID': currencyCode},
            ),
            _cbcElement(
              'BaseAmount',
              _fmtAmount(line.grossPrice!),
              attributes: {'currencyID': currencyCode},
            ),
          ],
        ),
      );
    }

    return XmlElement(
      XmlName('Price', 'cac'),
      [],
      children,
    );
  }

  /// Build line-level AllowanceCharge
  XmlElement? _buildLineAllowance(
    ZatcaInvoiceLine line,
    String currencyCode,
  ) {
    if (line.discountAmount <= 0) return null;

    final children = <XmlNode>[
      _cbcElement('ChargeIndicator', 'false'),
      _cbcElement(
        'AllowanceChargeReasonCode',
        '95', // Discount
      ),
      _cbcElement(
        'AllowanceChargeReason',
        line.discountReason ?? 'Discount',
      ),
      _cbcElement(
        'MultiplierFactorNumeric',
        _fmtAmount(
          line.grossPrice != null && line.grossPrice! > 0
              ? (line.discountAmount / (line.grossPrice! * line.quantity)) * 100
              : 0,
        ),
      ),
      _cbcElement(
        'Amount',
        _fmtAmount(line.discountAmount),
        attributes: {'currencyID': currencyCode},
      ),
      _cbcElement(
        'BaseAmount',
        _fmtAmount(
          line.grossPrice != null ? line.grossPrice! * line.quantity : 0,
        ),
        attributes: {'currencyID': currencyCode},
      ),
    ];

    return XmlElement(
      XmlName('AllowanceCharge', 'cac'),
      [],
      children,
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  /// Format a double as a 2-decimal-place string for XML amounts
  static String _fmtAmount(double value) => value.toStringAsFixed(2);

  /// Create a cbc: namespaced element with text content and optional attributes
  static XmlElement _cbcElement(
    String name,
    String text, {
    Map<String, String>? attributes,
  }) {
    return XmlElement(
      XmlName(name, 'cbc'),
      (attributes ?? {})
          .entries
          .map((e) => XmlAttribute(XmlName(e.key), e.value))
          .toList(),
      [XmlText(text)],
    );
  }
}
