import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/xml/tax_total_builder.dart';

void main() {
  late TaxTotalBuilder builder;

  const seller = ZatcaSeller(
    name: 'Test Store',
    vatNumber: '300000000000003',
    streetName: 'King Fahd Road',
    buildingNumber: '1234',
    city: 'Riyadh',
    postalCode: '12345',
  );

  // Helper to build an invoice with given lines
  ZatcaInvoice makeInvoice({
    required List<ZatcaInvoiceLine> lines,
    String currencyCode = 'SAR',
  }) {
    return ZatcaInvoice(
      invoiceNumber: 'INV-001',
      uuid: '550e8400-e29b-41d4-a716-446655440000',
      issueDate: DateTime(2026, 1, 15),
      issueTime: DateTime(2026, 1, 15, 14, 30),
      typeCode: InvoiceTypeCode.standard,
      subType: '0100000',
      currencyCode: currencyCode,
      seller: seller,
      lines: lines,
    );
  }

  // Helper to find all elements by local name (regardless of prefix)
  List<XmlElement> findAll(XmlElement root, String name) {
    return root.descendants
        .whereType<XmlElement>()
        .where((e) => e.name.local == name)
        .toList();
  }

  XmlElement? findFirst(XmlElement root, String name) {
    for (final e in root.descendants.whereType<XmlElement>()) {
      if (e.name.local == name) return e;
    }
    return null;
  }

  setUp(() {
    builder = TaxTotalBuilder();
  });

  group('TaxTotalBuilder', () {
    // ── Structure ────────────────────────────────────────

    group('buildTaxTotals - structure', () {
      test('returns exactly two TaxTotal elements', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        expect(taxTotals, hasLength(2));
        expect(taxTotals.every((e) => e.name.local == 'TaxTotal'), isTrue);
      });

      test('first TaxTotal contains only TaxAmount (no TaxSubtotal)', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final first = taxTotals[0];

        expect(findAll(first, 'TaxAmount'), hasLength(1));
        expect(findAll(first, 'TaxSubtotal'), isEmpty);
      });

      test('second TaxTotal contains TaxAmount and TaxSubtotal breakdown', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final second = taxTotals[1];

        expect(findAll(second, 'TaxAmount'), isNotEmpty);
        expect(findAll(second, 'TaxSubtotal'), hasLength(1));
      });

      test('elements use cac namespace prefix for TaxTotal', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        for (final taxTotal in taxTotals) {
          expect(taxTotal.name.prefix, 'cac');
        }
      });
    });

    // ── Standard VAT (15%) ───────────────────────────────

    group('buildTaxTotals - standard VAT', () {
      test('calculates 15 VAT on 100 net', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final firstTaxAmount = findFirst(taxTotals[0], 'TaxAmount');
        expect(firstTaxAmount, isNotNull);
        expect(firstTaxAmount!.innerText, '15.00');
      });

      test('aggregates multiple lines with same VAT rate', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product 1',
            quantity: 2,
            unitPrice: 50.0,
            vatRate: 15.0,
          ),
          const ZatcaInvoiceLine(
            lineId: '2',
            itemName: 'Product 2',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final second = taxTotals[1];

        // Only one TaxSubtotal because both lines share the same category
        final subtotals = findAll(second, 'TaxSubtotal');
        expect(subtotals, hasLength(1));

        // Taxable amount: 100 + 100 = 200, VAT: 30
        final taxableAmount = findFirst(subtotals.first, 'TaxableAmount');
        final taxAmount = findFirst(subtotals.first, 'TaxAmount');
        expect(taxableAmount!.innerText, '200.00');
        expect(taxAmount!.innerText, '30.00');
      });

      test('includes currencyID attribute matching invoice currency', () {
        final invoice = makeInvoice(
          currencyCode: 'SAR',
          lines: [
            const ZatcaInvoiceLine(
              lineId: '1',
              itemName: 'Product',
              quantity: 1,
              unitPrice: 100.0,
              vatRate: 15.0,
            ),
          ],
        );

        final taxTotals = builder.buildTaxTotals(invoice);
        final taxAmount = findFirst(taxTotals[0], 'TaxAmount');
        expect(taxAmount!.getAttribute('currencyID'), 'SAR');
      });
    });

    // ── Zero tax ─────────────────────────────────────────

    group('buildTaxTotals - zero tax', () {
      test('handles zero-rated items (vatRate=0)', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Zero-rated product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 0.0,
            vatCategoryCode: 'Z',
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final firstTaxAmount = findFirst(taxTotals[0], 'TaxAmount');
        expect(firstTaxAmount!.innerText, '0.00');
      });

      test('still produces TaxSubtotal for zero-rated lines', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Zero-rated',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 0.0,
            vatCategoryCode: 'Z',
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final subtotals = findAll(taxTotals[1], 'TaxSubtotal');
        expect(subtotals, hasLength(1));

        // Taxable amount should still be present and correct
        final taxableAmount = findFirst(subtotals.first, 'TaxableAmount');
        expect(taxableAmount!.innerText, '100.00');
      });
    });

    // ── Multiple tax categories ──────────────────────────

    group('buildTaxTotals - multiple categories', () {
      test('produces separate TaxSubtotal per VAT category', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Standard',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
            vatCategoryCode: 'S',
          ),
          const ZatcaInvoiceLine(
            lineId: '2',
            itemName: 'Zero-rated',
            quantity: 1,
            unitPrice: 50.0,
            vatRate: 0.0,
            vatCategoryCode: 'Z',
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final subtotals = findAll(taxTotals[1], 'TaxSubtotal');
        expect(subtotals, hasLength(2));
      });

      test('total VAT is sum across categories', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Standard',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
            vatCategoryCode: 'S',
          ),
          const ZatcaInvoiceLine(
            lineId: '2',
            itemName: 'Zero-rated',
            quantity: 1,
            unitPrice: 50.0,
            vatRate: 0.0,
            vatCategoryCode: 'Z',
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        // Only the 15% line contributes VAT -> 15
        final firstTaxAmount = findFirst(taxTotals[0], 'TaxAmount');
        expect(firstTaxAmount!.innerText, '15.00');
      });

      test('separates lines with same category code but different rates', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Std 15',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
            vatCategoryCode: 'S',
          ),
          const ZatcaInvoiceLine(
            lineId: '2',
            itemName: 'Std 10',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 10.0,
            vatCategoryCode: 'S',
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final subtotals = findAll(taxTotals[1], 'TaxSubtotal');
        // Different rates with same code are split into two subtotals
        expect(subtotals, hasLength(2));
      });
    });

    // ── Tax category details ─────────────────────────────

    group('TaxCategory details', () {
      test('includes TaxCategory with ID matching vatCategoryCode', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
            vatCategoryCode: 'S',
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final taxCategory = findFirst(taxTotals[1], 'TaxCategory');
        expect(taxCategory, isNotNull);

        final id = findFirst(taxCategory!, 'ID');
        expect(id!.innerText, 'S');
      });

      test('includes Percent matching the VAT rate', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final taxCategory = findFirst(taxTotals[1], 'TaxCategory');
        final percent = findFirst(taxCategory!, 'Percent');
        expect(percent!.innerText, '15.00');
      });

      test('includes TaxScheme with VAT ID', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final taxScheme = findFirst(taxTotals[1], 'TaxScheme');
        expect(taxScheme, isNotNull);
        final id = findFirst(taxScheme!, 'ID');
        expect(id!.innerText, 'VAT');
      });

      test('includes exemption reason when provided', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Exempt medicine',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 0.0,
            vatCategoryCode: 'E',
            vatExemptionReasonCode: 'VATEX-SA-29',
            vatExemptionReason: 'Pharmaceutical products',
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final taxCategory = findFirst(taxTotals[1], 'TaxCategory');
        final reasonCode = findFirst(taxCategory!, 'TaxExemptionReasonCode');
        final reason = findFirst(taxCategory, 'TaxExemptionReason');

        expect(reasonCode!.innerText, 'VATEX-SA-29');
        expect(reason!.innerText, 'Pharmaceutical products');
      });

      test('omits exemption reason fields when not provided', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Standard',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        final taxCategory = findFirst(taxTotals[1], 'TaxCategory');
        expect(findFirst(taxCategory!, 'TaxExemptionReasonCode'), isNull);
        expect(findFirst(taxCategory, 'TaxExemptionReason'), isNull);
      });
    });

    // ── ZATCA schema compliance ──────────────────────────

    group('ZATCA schema compliance', () {
      test('amounts are always formatted with 2 decimal places', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        for (final taxTotal in taxTotals) {
          for (final e in taxTotal.descendants.whereType<XmlElement>()) {
            if (e.name.local == 'TaxAmount' ||
                e.name.local == 'TaxableAmount' ||
                e.name.local == 'Percent') {
              // Must contain a decimal point with exactly 2 fractional digits
              expect(e.innerText, matches(RegExp(r'^\d+\.\d{2}$')),
                  reason: 'Value "${e.innerText}" for ${e.name.local} '
                      'does not match 2-decimal format');
            }
          }
        }
      });

      test('all amount elements carry currencyID', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product',
            quantity: 1,
            unitPrice: 100.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        for (final taxTotal in taxTotals) {
          for (final e in taxTotal.descendants.whereType<XmlElement>()) {
            if (e.name.local == 'TaxAmount' ||
                e.name.local == 'TaxableAmount') {
              expect(e.getAttribute('currencyID'), isNotNull,
                  reason: '${e.name.local} missing currencyID');
            }
          }
        }
      });

      test('both TaxTotal elements report the same total VAT amount', () {
        final invoice = makeInvoice(lines: [
          const ZatcaInvoiceLine(
            lineId: '1',
            itemName: 'Product 1',
            quantity: 2,
            unitPrice: 50.0,
            vatRate: 15.0,
          ),
          const ZatcaInvoiceLine(
            lineId: '2',
            itemName: 'Product 2',
            quantity: 1,
            unitPrice: 200.0,
            vatRate: 15.0,
          ),
        ]);

        final taxTotals = builder.buildTaxTotals(invoice);
        // Direct children of TaxTotal named TaxAmount (not inside TaxSubtotal)
        final first = taxTotals[0]
            .childElements
            .firstWhere((e) => e.name.local == 'TaxAmount');
        final second = taxTotals[1]
            .childElements
            .firstWhere((e) => e.name.local == 'TaxAmount');
        expect(first.innerText, second.innerText);
      });
    });
  });
}
