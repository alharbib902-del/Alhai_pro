import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/xml/invoice_line_builder.dart';

/// Tests for [InvoiceLineBuilder]
///
/// These tests verify the structure, values, and ZATCA-specific
/// formatting rules of the UBL InvoiceLine XML elements produced
/// by the builder. We rely on the xml package's parser / descendant
/// APIs instead of string matching to guard against future whitespace
/// or attribute-ordering changes.
void main() {
  late InvoiceLineBuilder builder;

  setUp(() {
    builder = InvoiceLineBuilder();
  });

  // ─── Helpers ─────────────────────────────────────────────

  List<XmlElement> findAll(XmlElement root, String name) {
    return root.descendants
        .whereType<XmlElement>()
        .where((e) => e.name.local == name)
        .toList();
  }

  XmlElement firstElement(XmlElement root, String name) {
    return findAll(root, name).first;
  }

  // Only the DIRECT children of an element (not nested descendants)
  List<XmlElement> directChildren(XmlElement root, String name) {
    return root.childElements.where((e) => e.name.local == name).toList();
  }

  // ─── Basic line construction ─────────────────────────────

  group('buildLine - basic construction', () {
    test('builds line with quantity and price', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 3,
        unitPrice: 10.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');

      expect(el.name.local, 'InvoiceLine');
      expect(el.name.prefix, 'cac');

      final qty = firstElement(el, 'InvoicedQuantity');
      expect(qty.innerText, '3.00');

      final price = firstElement(el, 'Price');
      final priceAmount = firstElement(price, 'PriceAmount');
      expect(priceAmount.innerText, '10.00');
    });

    test('builds line with InvoicedQuantity containing unitCode', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 2.5,
        unitCode: 'KGM',
        unitPrice: 10.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');
      final qty = firstElement(el, 'InvoicedQuantity');

      expect(qty.getAttribute('unitCode'), 'KGM');
      expect(qty.innerText, '2.50');
    });

    test('line includes ItemName inside Item element', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Premium Widget',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');
      final item = firstElement(el, 'Item');
      final name = firstElement(item, 'Name');

      expect(name.innerText, 'Premium Widget');
    });

    test('line has correct currency on amounts', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');

      final lineExt = firstElement(el, 'LineExtensionAmount');
      expect(lineExt.getAttribute('currencyID'), 'SAR');

      final priceAmount = firstElement(el, 'PriceAmount');
      expect(priceAmount.getAttribute('currencyID'), 'SAR');
    });

    test('line uses custom currency when provided', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'USD');

      for (final amountTag in [
        'LineExtensionAmount',
        'PriceAmount',
        'TaxAmount',
        'RoundingAmount',
      ]) {
        for (final node in findAll(el, amountTag)) {
          expect(
            node.getAttribute('currencyID'),
            'USD',
            reason: '$amountTag should use USD currencyID',
          );
        }
      }
    });

    test('line has sequential ID set correctly', () {
      const line = ZatcaInvoiceLine(
        lineId: '42',
        itemName: 'Widget',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');
      // ID is the first direct cbc:ID child of InvoiceLine
      final idChildren = directChildren(el, 'ID');
      expect(idChildren, isNotEmpty);
      expect(idChildren.first.innerText, '42');
    });
  });

  // ─── Line-level TaxTotal ─────────────────────────────────

  group('buildLine - line-level TaxTotal', () {
    test('line includes a TaxTotal element', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 2,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');
      final taxTotals = directChildren(el, 'TaxTotal');

      expect(taxTotals.length, 1);
    });

    test('line TaxTotal has TaxAmount with correct VAT value', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 2,
        unitPrice: 100.0,
        vatRate: 15.0,
      );
      // net = 200, vat = 30

      final el = builder.buildLine(line, 'SAR');
      final taxTotal = directChildren(el, 'TaxTotal').first;
      final taxAmount = firstElement(taxTotal, 'TaxAmount');

      expect(taxAmount.innerText, '30.00');
      expect(taxAmount.getAttribute('currencyID'), 'SAR');
    });

    test('line TaxTotal has RoundingAmount = net + vat', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 4,
        unitPrice: 25.0,
        vatRate: 15.0,
      );
      // net = 100, vat = 15, rounding = 115

      final el = builder.buildLine(line, 'SAR');
      final taxTotal = directChildren(el, 'TaxTotal').first;
      final rounding = firstElement(taxTotal, 'RoundingAmount');

      expect(rounding.innerText, '115.00');
      expect(rounding.getAttribute('currencyID'), 'SAR');
    });

    test('zero-tax (Z) line produces TaxTotal with 0 TaxAmount', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Export Product',
        quantity: 5,
        unitPrice: 100.0,
        vatRate: 0.0,
        vatCategoryCode: 'Z',
        vatExemptionReason: 'Export to non-GCC',
        vatExemptionReasonCode: 'VATEX-SA-32',
      );

      final el = builder.buildLine(line, 'SAR');
      final taxTotal = directChildren(el, 'TaxTotal').first;
      final taxAmount = firstElement(taxTotal, 'TaxAmount');

      expect(taxAmount.innerText, '0.00');
    });

    test('exempt (E) line includes exemption reason in ClassifiedTaxCategory',
        () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Exempt Service',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 0.0,
        vatCategoryCode: 'E',
        vatExemptionReason: 'Financial services',
        vatExemptionReasonCode: 'VATEX-SA-29',
      );

      final el = builder.buildLine(line, 'SAR');
      final taxCategory = firstElement(el, 'ClassifiedTaxCategory');
      final reasonEl = firstElement(taxCategory, 'TaxExemptionReason');
      final reasonCodeEl = firstElement(taxCategory, 'TaxExemptionReasonCode');

      expect(reasonEl.innerText, 'Financial services');
      expect(reasonCodeEl.innerText, 'VATEX-SA-29');
    });
  });

  // ─── Discounts ───────────────────────────────────────────

  group('buildLine - discounts', () {
    test('handles line-level discount with AllowanceCharge', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Discounted Widget',
        quantity: 2,
        unitPrice: 90.0,
        grossPrice: 100.0,
        discountAmount: 20.0,
        discountReason: 'Volume discount',
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');

      // Line-level AllowanceCharge should exist as a direct child
      final lineAllowances = directChildren(el, 'AllowanceCharge');
      expect(lineAllowances.length, 1);

      final allowance = lineAllowances.first;
      final chargeIndicator = firstElement(allowance, 'ChargeIndicator');
      expect(chargeIndicator.innerText, 'false');

      final reasonCode = firstElement(allowance, 'AllowanceChargeReasonCode');
      expect(reasonCode.innerText, '95');

      final reason = firstElement(allowance, 'AllowanceChargeReason');
      expect(reason.innerText, 'Volume discount');

      final amount = firstElement(allowance, 'Amount');
      expect(amount.innerText, '20.00');
      expect(amount.getAttribute('currencyID'), 'SAR');
    });

    test('discount uses default reason "Discount" when none provided', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 1,
        unitPrice: 80.0,
        grossPrice: 100.0,
        discountAmount: 20.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');
      final allowance = directChildren(el, 'AllowanceCharge').first;
      final reason = firstElement(allowance, 'AllowanceChargeReason');

      expect(reason.innerText, 'Discount');
    });

    test('no line-level AllowanceCharge when discount is zero', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Full price item',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');
      final lineAllowances = directChildren(el, 'AllowanceCharge');

      expect(lineAllowances, isEmpty);
    });

    test('Price includes nested AllowanceCharge with grossPrice base', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 1,
        unitPrice: 90.0,
        grossPrice: 100.0,
        discountAmount: 10.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');
      final price = firstElement(el, 'Price');
      final priceAllowances = directChildren(price, 'AllowanceCharge');

      expect(priceAllowances.length, 1);

      final baseAmount = firstElement(priceAllowances.first, 'BaseAmount');
      expect(baseAmount.innerText, '100.00');
      expect(baseAmount.getAttribute('currencyID'), 'SAR');
    });
  });

  // ─── Multiple lines & IDs ────────────────────────────────

  group('buildLines - multiple lines', () {
    test('handles multiple lines with sequential IDs', () {
      final lines = [
        const ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'First',
          quantity: 1,
          unitPrice: 10.0,
          vatRate: 15.0,
        ),
        const ZatcaInvoiceLine(
          lineId: '2',
          itemName: 'Second',
          quantity: 2,
          unitPrice: 20.0,
          vatRate: 15.0,
        ),
        const ZatcaInvoiceLine(
          lineId: '3',
          itemName: 'Third',
          quantity: 3,
          unitPrice: 30.0,
          vatRate: 15.0,
        ),
      ];

      final elements = builder.buildLines(lines, 'SAR');

      expect(elements.length, 3);

      for (var i = 0; i < elements.length; i++) {
        final idChildren = directChildren(elements[i], 'ID');
        expect(idChildren.first.innerText, '${i + 1}');
      }
    });

    test('buildLines returns empty list when no lines provided', () {
      final elements = builder.buildLines([], 'SAR');
      expect(elements, isEmpty);
    });

    test('each line has its own independent Item name', () {
      final lines = [
        const ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Apples',
          quantity: 1,
          unitPrice: 5.0,
          vatRate: 15.0,
        ),
        const ZatcaInvoiceLine(
          lineId: '2',
          itemName: 'Oranges',
          quantity: 1,
          unitPrice: 5.0,
          vatRate: 15.0,
        ),
      ];

      final elements = builder.buildLines(lines, 'SAR');
      final name0 = firstElement(firstElement(elements[0], 'Item'), 'Name');
      final name1 = firstElement(firstElement(elements[1], 'Item'), 'Name');

      expect(name0.innerText, 'Apples');
      expect(name1.innerText, 'Oranges');
    });
  });

  // ─── Edge cases & rounding ───────────────────────────────

  group('buildLine - edge cases and rounding', () {
    test('handles negative quantity (returns / credit note lines)', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Returned Item',
        quantity: -2,
        unitPrice: 50.0,
        vatRate: 15.0,
      );
      // net = -100, vat = -15

      final el = builder.buildLine(line, 'SAR');
      final qty = firstElement(el, 'InvoicedQuantity');
      final lineExt = firstElement(el, 'LineExtensionAmount');

      expect(qty.innerText, '-2.00');
      expect(lineExt.innerText, '-100.00');

      final taxAmount = firstElement(
        directChildren(el, 'TaxTotal').first,
        'TaxAmount',
      );
      expect(taxAmount.innerText, '-15.00');
    });

    test('rounds amounts to 2 decimal places per ZATCA', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Rounded',
        quantity: 3,
        unitPrice: 33.333,
        vatRate: 15.0,
      );
      // Exact net = 99.999 → toStringAsFixed(2) = "100.00"

      final el = builder.buildLine(line, 'SAR');
      final lineExt = firstElement(el, 'LineExtensionAmount');
      final priceAmount = firstElement(el, 'PriceAmount');

      // All formatted with exactly 2 decimal places
      expect(RegExp(r'^-?\d+\.\d{2}$').hasMatch(lineExt.innerText), isTrue);
      expect(RegExp(r'^-?\d+\.\d{2}$').hasMatch(priceAmount.innerText), isTrue);
      expect(lineExt.innerText, '100.00');
    });

    test('all amount elements have exactly 2 decimal places', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 7,
        unitPrice: 12.5,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');

      final amountTags = [
        'InvoicedQuantity',
        'LineExtensionAmount',
        'PriceAmount',
        'TaxAmount',
        'RoundingAmount',
      ];
      final pattern = RegExp(r'^-?\d+\.\d{2}$');

      for (final tag in amountTags) {
        final elements = findAll(el, tag);
        for (final node in elements) {
          expect(
            pattern.hasMatch(node.innerText),
            isTrue,
            reason:
                '$tag has innerText="${node.innerText}" which is not 2 decimals',
          );
        }
      }
    });

    test('ClassifiedTaxCategory includes VAT TaxScheme', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');
      final taxCat = firstElement(el, 'ClassifiedTaxCategory');
      final taxScheme = firstElement(taxCat, 'TaxScheme');
      final schemeId = firstElement(taxScheme, 'ID');

      expect(schemeId.innerText, 'VAT');

      // And Percent of the tax category matches the line vatRate
      final percent = firstElement(taxCat, 'Percent');
      expect(percent.innerText, '15.00');
    });

    test('line with barcode exposes GTIN StandardItemIdentification', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Scanned Item',
        quantity: 1,
        unitPrice: 50.0,
        vatRate: 15.0,
        barcode: '6281234567890',
      );

      final el = builder.buildLine(line, 'SAR');
      final stdId = firstElement(el, 'StandardItemIdentification');
      final id = firstElement(stdId, 'ID');

      expect(id.innerText, '6281234567890');
      expect(id.getAttribute('schemeID'), 'GTIN');
    });

    test('line with sellerItemId exposes SellersItemIdentification', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Catalogued Item',
        quantity: 1,
        unitPrice: 50.0,
        vatRate: 15.0,
        sellerItemId: 'SKU-123',
      );

      final el = builder.buildLine(line, 'SAR');
      final sellerId = firstElement(el, 'SellersItemIdentification');
      final id = firstElement(sellerId, 'ID');

      expect(id.innerText, 'SKU-123');
    });

    test('validates all mandatory sub-elements are present', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Full Line',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');

      // All the required direct children per ZATCA/UBL spec
      final directLocalNames =
          el.childElements.map((e) => e.name.local).toList();

      expect(
          directLocalNames,
          containsAll(<String>[
            'ID',
            'InvoicedQuantity',
            'LineExtensionAmount',
            'TaxTotal',
            'Item',
            'Price',
          ]));
    });

    test('uses cac: namespace prefix for InvoiceLine root', () {
      const line = ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Widget',
        quantity: 1,
        unitPrice: 100.0,
        vatRate: 15.0,
      );

      final el = builder.buildLine(line, 'SAR');

      expect(el.name.local, 'InvoiceLine');
      expect(el.name.prefix, 'cac');
    });
  });
}
