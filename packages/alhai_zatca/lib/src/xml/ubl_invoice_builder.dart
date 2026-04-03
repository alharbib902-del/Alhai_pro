import 'package:xml/xml.dart';

import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/xml/invoice_line_builder.dart';
import 'package:alhai_zatca/src/xml/tax_total_builder.dart';
import 'package:alhai_zatca/src/xml/ubl_namespaces.dart';

/// Builds a complete UBL 2.1 XML document from a [ZatcaInvoice]
///
/// Generates the XML structure required by ZATCA Phase 2,
/// including all mandatory and conditional elements.
class UblInvoiceBuilder {
  final InvoiceLineBuilder _lineBuilder;
  final TaxTotalBuilder _taxBuilder;

  UblInvoiceBuilder({
    InvoiceLineBuilder? lineBuilder,
    TaxTotalBuilder? taxBuilder,
  })  : _lineBuilder = lineBuilder ?? InvoiceLineBuilder(),
        _taxBuilder = taxBuilder ?? TaxTotalBuilder();

  /// ZATCA reporting profile ID
  static const String _profileId = 'reporting:1.0';

  /// Build the complete UBL 2.1 XML document for a ZATCA invoice
  ///
  /// Returns the XML string ready for signing.
  String build(ZatcaInvoice invoice) {
    final children = <XmlNode>[];

    // 1. UBLExtensions (signature placeholder, QR, PIH)
    children.add(_buildExtensions(invoice));

    // 2. ProfileID
    children.add(_cbcElement('ProfileID', _profileId));

    // 3. ID (invoice number)
    children.add(_cbcElement('ID', invoice.invoiceNumber));

    // 4. UUID
    children.add(_cbcElement('UUID', invoice.uuid));

    // 5. IssueDate
    children.add(_cbcElement('IssueDate', _fmtDate(invoice.issueDate)));

    // 6. IssueTime
    children.add(_cbcElement('IssueTime', _fmtTime(invoice.issueTime)));

    // 7. InvoiceTypeCode with name attribute (sub-type)
    children.add(
      XmlElement(
        XmlName('InvoiceTypeCode', 'cbc'),
        [XmlAttribute(XmlName('name'), invoice.subType)],
        [XmlText(invoice.typeCode.code)],
      ),
    );

    // 8. DocumentCurrencyCode
    children.add(_cbcElement('DocumentCurrencyCode', invoice.currencyCode));

    // 9. TaxCurrencyCode (ZATCA always requires SAR)
    children.add(_cbcElement('TaxCurrencyCode', 'SAR'));

    // 10. BillingReference (for credit/debit notes)
    if (invoice.billingReferenceId != null) {
      children.add(
        XmlElement(
          XmlName('BillingReference', 'cac'),
          [],
          [
            XmlElement(
              XmlName('InvoiceDocumentReference', 'cac'),
              [],
              [_cbcElement('ID', invoice.billingReferenceId!)],
            ),
          ],
        ),
      );
    }

    // 11. ContractDocumentReference
    if (invoice.contractId != null) {
      children.add(
        XmlElement(
          XmlName('ContractDocumentReference', 'cac'),
          [],
          [_cbcElement('ID', invoice.contractId!)],
        ),
      );
    }

    // 12. PurchaseOrderReference (BT-13)
    if (invoice.purchaseOrderId != null) {
      children.add(
        XmlElement(
          XmlName('OrderReference', 'cac'),
          [],
          [_cbcElement('ID', invoice.purchaseOrderId!)],
        ),
      );
    }

    // 13. AdditionalDocumentReference - ICV (Invoice Counter Value)
    children.add(_buildDocumentReference(
      id: invoice.invoiceNumber,
      uuid: 'ICV',
    ));

    // 14. AdditionalDocumentReference - PIH (Previous Invoice Hash)
    if (invoice.previousInvoiceHash != null) {
      children.add(_buildDocumentReference(
        id: 'PIH',
        uuid: 'PIH',
        attachmentContent: invoice.previousInvoiceHash!,
        mimeCode: 'text/plain',
      ));
    }

    // 15. AdditionalDocumentReference - QR code
    if (invoice.qrCode != null) {
      children.add(_buildDocumentReference(
        id: 'QR',
        uuid: 'QR',
        attachmentContent: invoice.qrCode!,
        mimeCode: 'text/plain',
      ));
    }

    // 16. Signature placeholder
    children.add(
      XmlElement(
        XmlName('Signature', 'cac'),
        [],
        [
          _cbcElement(
            'ID',
            'urn:oasis:names:specification:ubl:signature:Invoice',
          ),
          _cbcElement(
            'SignatureMethod',
            'urn:oasis:names:specification:ubl:dsig:enveloped:xades',
          ),
        ],
      ),
    );

    // 17. AccountingSupplierParty
    children.add(_buildSupplierParty(invoice));

    // 18. AccountingCustomerParty
    children.add(_buildCustomerParty(invoice));

    // 19. PaymentMeans
    children.add(_buildPaymentMeans(invoice));

    // 20. AllowanceCharge (document-level discounts)
    children.addAll(_buildAllowanceCharges(invoice));

    // 21. TaxTotal (two elements per ZATCA spec)
    children.addAll(_taxBuilder.buildTaxTotals(invoice));

    // 22. LegalMonetaryTotal
    children.add(_buildLegalMonetaryTotal(invoice));

    // 23. InvoiceLine items
    children.addAll(
      _lineBuilder.buildLines(invoice.lines, invoice.currencyCode),
    );

    // Build root element with all namespaces
    final root = XmlElement(
      XmlName('Invoice'),
      [
        XmlAttribute(XmlName('xmlns'), UblNamespaces.invoice),
        XmlAttribute(XmlName('cac', 'xmlns'), UblNamespaces.cac),
        XmlAttribute(XmlName('cbc', 'xmlns'), UblNamespaces.cbc),
        XmlAttribute(XmlName('ext', 'xmlns'), UblNamespaces.ext),
        XmlAttribute(XmlName('sig', 'xmlns'), UblNamespaces.sig),
        XmlAttribute(XmlName('sac', 'xmlns'), UblNamespaces.sac),
        XmlAttribute(XmlName('sbc', 'xmlns'), UblNamespaces.sbc),
      ],
      children,
    );

    // Build complete document with XML declaration
    final document = XmlDocument([
      XmlDeclaration([
        XmlAttribute(XmlName('version'), '1.0'),
        XmlAttribute(XmlName('encoding'), 'UTF-8'),
      ]),
      root,
    ]);

    return document.toXmlString(pretty: true, indent: '    ');
  }

  // ─── Extensions ──────────────────────────────────────────

  /// Build the UBLExtensions element (signature + additional data)
  XmlElement _buildExtensions(ZatcaInvoice invoice) {
    // UBLExtensions contains a single UBLExtension with a signature
    // placeholder that will be filled in by the signing step.
    final signatureContent = invoice.signedXml ?? '';

    final extensionContent = XmlElement(
      XmlName('ExtensionContent', 'ext'),
      [],
      signatureContent.isNotEmpty
          ? [XmlText(signatureContent)]
          : [
              // Empty placeholder for signing step to populate
              XmlElement(
                XmlName('UBLDocumentSignatures', 'sig'),
                [],
                [
                  XmlElement(
                    XmlName('SignatureInformation', 'sac'),
                    [],
                    [
                      _cbcElement(
                        'ID',
                        'urn:oasis:names:specification:ubl:signature:1',
                      ),
                      _sbcElement(
                        'ReferencedSignatureID',
                        'urn:oasis:names:specification:ubl:signature:Invoice',
                      ),
                    ],
                  ),
                ],
              ),
            ],
    );

    return XmlElement(
      XmlName('UBLExtensions', 'ext'),
      [],
      [
        XmlElement(
          XmlName('UBLExtension', 'ext'),
          [],
          [extensionContent],
        ),
      ],
    );
  }

  // ─── Parties ─────────────────────────────────────────────

  /// Build the AccountingSupplierParty element
  XmlElement _buildSupplierParty(ZatcaInvoice invoice) {
    final seller = invoice.seller;

    // PostalAddress
    final addressChildren = <XmlNode>[
      _cbcElement('StreetName', seller.streetName),
      _cbcElement('BuildingNumber', seller.buildingNumber),
    ];
    if (seller.plotIdentification != null) {
      addressChildren.add(
        _cbcElement('PlotIdentification', seller.plotIdentification!),
      );
    }
    if (seller.district != null) {
      addressChildren.add(
        _cbcElement('CitySubdivisionName', seller.district!),
      );
    }
    addressChildren.add(_cbcElement('CityName', seller.city));
    addressChildren.add(_cbcElement('PostalZone', seller.postalCode));
    addressChildren.add(
      XmlElement(
        XmlName('Country', 'cac'),
        [],
        [_cbcElement('IdentificationCode', seller.countryCode)],
      ),
    );

    // PartyIdentification elements
    final partyIds = <XmlElement>[];

    // Primary: CRN if available
    if (seller.crNumber != null) {
      partyIds.add(
        XmlElement(
          XmlName('PartyIdentification', 'cac'),
          [],
          [
            _cbcElement('ID', seller.crNumber!,
                attributes: {'schemeID': 'CRN'}),
          ],
        ),
      );
    }

    // Additional ID
    if (seller.additionalId != null) {
      partyIds.add(
        XmlElement(
          XmlName('PartyIdentification', 'cac'),
          [],
          [
            _cbcElement('ID', seller.additionalId!,
                attributes: {
                  'schemeID': seller.additionalIdScheme ?? 'OTH',
                }),
          ],
        ),
      );
    }

    // PartyTaxScheme
    final partyTaxScheme = XmlElement(
      XmlName('PartyTaxScheme', 'cac'),
      [],
      [
        _cbcElement('CompanyID', seller.vatNumber),
        XmlElement(
          XmlName('TaxScheme', 'cac'),
          [],
          [_cbcElement('ID', 'VAT')],
        ),
      ],
    );

    // PartyLegalEntity
    final partyLegal = XmlElement(
      XmlName('PartyLegalEntity', 'cac'),
      [],
      [_cbcElement('RegistrationName', seller.name)],
    );

    // Assemble Party
    final partyChildren = <XmlNode>[
      ...partyIds,
      XmlElement(
        XmlName('PostalAddress', 'cac'),
        [],
        addressChildren,
      ),
      partyTaxScheme,
      partyLegal,
    ];

    return XmlElement(
      XmlName('AccountingSupplierParty', 'cac'),
      [],
      [
        XmlElement(
          XmlName('Party', 'cac'),
          [],
          partyChildren,
        ),
      ],
    );
  }

  /// Build the AccountingCustomerParty element
  XmlElement _buildCustomerParty(ZatcaInvoice invoice) {
    final buyer = invoice.buyer;

    final partyChildren = <XmlNode>[];

    // PartyIdentification (buyer ID)
    if (buyer?.buyerId != null) {
      partyChildren.add(
        XmlElement(
          XmlName('PartyIdentification', 'cac'),
          [],
          [
            _cbcElement('ID', buyer!.buyerId!,
                attributes: {'schemeID': buyer.buyerIdScheme ?? 'NAT'}),
          ],
        ),
      );
    }

    // PostalAddress (if available)
    if (buyer?.streetName != null || buyer?.city != null) {
      final addressChildren = <XmlNode>[];
      if (buyer?.streetName != null) {
        addressChildren.add(_cbcElement('StreetName', buyer!.streetName!));
      }
      if (buyer?.buildingNumber != null) {
        addressChildren
            .add(_cbcElement('BuildingNumber', buyer!.buildingNumber!));
      }
      if (buyer?.district != null) {
        addressChildren
            .add(_cbcElement('CitySubdivisionName', buyer!.district!));
      }
      if (buyer?.city != null) {
        addressChildren.add(_cbcElement('CityName', buyer!.city!));
      }
      if (buyer?.postalCode != null) {
        addressChildren.add(_cbcElement('PostalZone', buyer!.postalCode!));
      }
      if (buyer?.countryCode != null) {
        addressChildren.add(
          XmlElement(
            XmlName('Country', 'cac'),
            [],
            [_cbcElement('IdentificationCode', buyer!.countryCode!)],
          ),
        );
      }
      partyChildren.add(
        XmlElement(
          XmlName('PostalAddress', 'cac'),
          [],
          addressChildren,
        ),
      );
    }

    // PartyTaxScheme
    if (buyer?.vatNumber != null) {
      partyChildren.add(
        XmlElement(
          XmlName('PartyTaxScheme', 'cac'),
          [],
          [
            _cbcElement('CompanyID', buyer!.vatNumber!),
            XmlElement(
              XmlName('TaxScheme', 'cac'),
              [],
              [_cbcElement('ID', 'VAT')],
            ),
          ],
        ),
      );
    }

    // PartyLegalEntity
    if (buyer?.name != null) {
      partyChildren.add(
        XmlElement(
          XmlName('PartyLegalEntity', 'cac'),
          [],
          [_cbcElement('RegistrationName', buyer!.name!)],
        ),
      );
    }

    return XmlElement(
      XmlName('AccountingCustomerParty', 'cac'),
      [],
      [
        XmlElement(
          XmlName('Party', 'cac'),
          [],
          partyChildren,
        ),
      ],
    );
  }

  // ─── Monetary ────────────────────────────────────────────

  /// Build the LegalMonetaryTotal element
  XmlElement _buildLegalMonetaryTotal(ZatcaInvoice invoice) {
    final cc = invoice.currencyCode;

    return XmlElement(
      XmlName('LegalMonetaryTotal', 'cac'),
      [],
      [
        _cbcElement(
          'LineExtensionAmount',
          _fmtAmount(invoice.totalLineNetAmount),
          attributes: {'currencyID': cc},
        ),
        _cbcElement(
          'TaxExclusiveAmount',
          _fmtAmount(invoice.taxableAmount),
          attributes: {'currencyID': cc},
        ),
        _cbcElement(
          'TaxInclusiveAmount',
          _fmtAmount(invoice.totalWithVat),
          attributes: {'currencyID': cc},
        ),
        _cbcElement(
          'AllowanceTotalAmount',
          _fmtAmount(invoice.totalAllowance),
          attributes: {'currencyID': cc},
        ),
        _cbcElement(
          'PayableAmount',
          _fmtAmount(invoice.totalWithVat),
          attributes: {'currencyID': cc},
        ),
      ],
    );
  }

  // ─── Allowances ──────────────────────────────────────────

  /// Build AllowanceCharge elements for document-level discounts
  List<XmlElement> _buildAllowanceCharges(ZatcaInvoice invoice) {
    if (invoice.documentDiscount <= 0) return [];

    return [
      XmlElement(
        XmlName('AllowanceCharge', 'cac'),
        [],
        [
          _cbcElement('ChargeIndicator', 'false'),
          _cbcElement('AllowanceChargeReasonCode', '95'),
          _cbcElement(
            'AllowanceChargeReason',
            invoice.documentDiscountReason ?? 'Discount',
          ),
          _cbcElement(
            'Amount',
            _fmtAmount(invoice.documentDiscount),
            attributes: {'currencyID': invoice.currencyCode},
          ),
          XmlElement(
            XmlName('TaxCategory', 'cac'),
            [],
            [
              _cbcElement('ID', 'S'),
              _cbcElement('Percent', '15.00'),
              XmlElement(
                XmlName('TaxScheme', 'cac'),
                [],
                [_cbcElement('ID', 'VAT')],
              ),
            ],
          ),
        ],
      ),
    ];
  }

  // ─── Payment ─────────────────────────────────────────────

  /// Build PaymentMeans element
  XmlElement _buildPaymentMeans(ZatcaInvoice invoice) {
    final children = <XmlNode>[
      _cbcElement('PaymentMeansCode', invoice.paymentMeansCode),
    ];

    if (invoice.paymentNote != null) {
      children.add(
        _cbcElement('InstructionNote', invoice.paymentNote!),
      );
    }

    return XmlElement(
      XmlName('PaymentMeans', 'cac'),
      [],
      children,
    );
  }

  // ─── Document References ─────────────────────────────────

  /// Build an AdditionalDocumentReference element
  XmlElement _buildDocumentReference({
    required String id,
    required String uuid,
    String? attachmentContent,
    String? mimeCode,
  }) {
    final children = <XmlNode>[
      _cbcElement('ID', id),
      _cbcElement('UUID', uuid),
    ];

    if (attachmentContent != null) {
      children.add(
        XmlElement(
          XmlName('Attachment', 'cac'),
          [],
          [
            XmlElement(
              XmlName('EmbeddedDocumentBinaryObject', 'cbc'),
              [
                XmlAttribute(
                  XmlName('mimeCode'),
                  mimeCode ?? 'text/plain',
                ),
              ],
              [XmlText(attachmentContent)],
            ),
          ],
        ),
      );
    }

    return XmlElement(
      XmlName('AdditionalDocumentReference', 'cac'),
      [],
      children,
    );
  }

  // ─── Helpers ─────────────────────────────────────────────

  /// Format a double as a 2-decimal-place string
  static String _fmtAmount(double value) => value.toStringAsFixed(2);

  /// Format a DateTime as yyyy-MM-dd
  static String _fmtDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-'
      '${dt.month.toString().padLeft(2, '0')}-'
      '${dt.day.toString().padLeft(2, '0')}';

  /// Format a DateTime as HH:mm:ss
  static String _fmtTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:'
      '${dt.minute.toString().padLeft(2, '0')}:'
      '${dt.second.toString().padLeft(2, '0')}';

  /// Create a cbc: namespaced element
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

  /// Create a sbc: namespaced element
  static XmlElement _sbcElement(String name, String text) {
    return XmlElement(
      XmlName(name, 'sbc'),
      [],
      [XmlText(text)],
    );
  }
}
