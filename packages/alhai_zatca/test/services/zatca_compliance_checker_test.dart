import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/zatca_buyer.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/services/zatca_compliance_checker.dart';

void main() {
  late ZatcaComplianceChecker checker;

  // ── Test Fixtures ──────────────────────────────────────────

  ZatcaSeller validSeller() => const ZatcaSeller(
        name: 'Test Store',
        vatNumber: '300000000000003',
        streetName: 'King Fahd Road',
        buildingNumber: '1234',
        city: 'Riyadh',
        postalCode: '12345',
        countryCode: 'SA',
      );

  ZatcaInvoiceLine validLine({
    String vatCategoryCode = 'S',
    double vatRate = 15.0,
    String? vatExemptionReason,
  }) =>
      ZatcaInvoiceLine(
        lineId: '1',
        itemName: 'Test Product',
        quantity: 2,
        unitPrice: 100.0,
        vatRate: vatRate,
        vatCategoryCode: vatCategoryCode,
        vatExemptionReason: vatExemptionReason,
      );

  ZatcaInvoice validSimplifiedInvoice({
    List<ZatcaInvoiceLine>? lines,
    ZatcaSeller? seller,
    String currencyCode = 'SAR',
    double documentDiscount = 0.0,
    InvoiceTypeCode typeCode = InvoiceTypeCode.standard,
    String? billingReferenceId,
    String paymentMeansCode = '10',
  }) =>
      ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: '550e8400-e29b-41d4-a716-446655440000',
        issueDate: DateTime(2026, 1, 15),
        issueTime: DateTime(2026, 1, 15, 14, 30),
        typeCode: typeCode,
        subType: '0200000',
        currencyCode: currencyCode,
        seller: seller ?? validSeller(),
        lines: lines ?? [validLine()],
        documentDiscount: documentDiscount,
        paymentMeansCode: paymentMeansCode,
        billingReferenceId: billingReferenceId,
      );

  ZatcaInvoice validStandardInvoice({
    ZatcaBuyer? buyer,
    List<ZatcaInvoiceLine>? lines,
  }) =>
      ZatcaInvoice(
        invoiceNumber: 'INV-002',
        uuid: '550e8400-e29b-41d4-a716-446655440001',
        issueDate: DateTime(2026, 1, 15),
        issueTime: DateTime(2026, 1, 15, 14, 30),
        typeCode: InvoiceTypeCode.standard,
        subType: '0100000',
        seller: validSeller(),
        buyer: buyer ??
            const ZatcaBuyer(
              name: 'Buyer Corp',
              vatNumber: '300000000000010',
            ),
        lines: lines ?? [validLine()],
        paymentMeansCode: '10',
      );

  setUp(() {
    checker = ZatcaComplianceChecker();
  });

  group('ZatcaComplianceChecker', () {
    // ── Valid Invoices ─────────────────────────────────────

    group('valid invoices', () {
      test('accepts a valid simplified invoice with no errors', () {
        final result = checker.check(validSimplifiedInvoice());

        expect(result.isValid, isTrue);
        expect(result.errors, isEmpty);
        expect(result.blockingErrors, isEmpty);
      });

      test('accepts a valid standard invoice with buyer info', () {
        final result = checker.check(validStandardInvoice());

        expect(result.isValid, isTrue);
        expect(result.blockingErrors, isEmpty);
      });
    });

    // ── Identity Validation ───────────────────────────────

    group('identity validation', () {
      test('rejects empty invoice number', () {
        final invoice = validSimplifiedInvoice().copyWith(invoiceNumber: '');
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-1'), isTrue);
      });

      test('rejects empty UUID', () {
        final invoice = validSimplifiedInvoice().copyWith(uuid: '');
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-124'), isTrue);
      });

      test('rejects invalid UUID format', () {
        final invoice =
            validSimplifiedInvoice().copyWith(uuid: 'not-a-valid-uuid');
        final errors = checker.validate(invoice);

        expect(
          errors.any(
              (e) => e.code == 'BT-124' && e.message.contains('UUID format')),
          isTrue,
        );
      });

      test('accepts valid UUID v4 format', () {
        final invoice = validSimplifiedInvoice().copyWith(
          uuid: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        );
        final errors = checker.validate(invoice);

        expect(errors.where((e) => e.code == 'BT-124'), isEmpty);
      });
    });

    // ── Type Code Validation ──────────────────────────────

    group('type code validation', () {
      test('rejects invalid subType length', () {
        final invoice = validSimplifiedInvoice().copyWith(subType: '01');
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'KSA-2'), isTrue);
      });

      test('rejects subType with non-digit characters', () {
        final invoice = validSimplifiedInvoice().copyWith(subType: '010000A');
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'KSA-2'), isTrue);
      });

      test('accepts valid subType codes', () {
        for (final subType in ['0100000', '0200000', '0110000']) {
          final invoice = validSimplifiedInvoice().copyWith(subType: subType);
          final errors = checker.validate(invoice);

          expect(
            errors.where((e) => e.code == 'KSA-2'),
            isEmpty,
            reason: 'SubType $subType should be valid',
          );
        }
      });

      test('warns about invalid payment means code', () {
        final invoice = validSimplifiedInvoice(paymentMeansCode: '99');
        final errors = checker.validate(invoice);

        expect(
          errors.any((e) =>
              e.code == 'BT-81' && e.severity == ComplianceSeverity.warning),
          isTrue,
        );
      });
    });

    // ── Seller Validation ─────────────────────────────────

    group('seller validation', () {
      test('rejects empty seller name', () {
        final seller = validSeller().copyWith(name: '');
        final invoice = validSimplifiedInvoice(seller: seller);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-27'), isTrue);
      });

      test('rejects invalid VAT number - wrong length', () {
        final seller = validSeller().copyWith(vatNumber: '12345');
        final invoice = validSimplifiedInvoice(seller: seller);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-31'), isTrue);
      });

      test('rejects invalid VAT number - does not start with 3', () {
        final seller = validSeller().copyWith(vatNumber: '100000000000003');
        final invoice = validSimplifiedInvoice(seller: seller);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-31'), isTrue);
      });

      test('rejects empty street name', () {
        final seller = validSeller().copyWith(streetName: '');
        final invoice = validSimplifiedInvoice(seller: seller);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-35'), isTrue);
      });

      test('rejects empty building number', () {
        final seller = validSeller().copyWith(buildingNumber: '');
        final invoice = validSimplifiedInvoice(seller: seller);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'KSA-17'), isTrue);
      });

      test('rejects empty city', () {
        final seller = validSeller().copyWith(city: '');
        final invoice = validSimplifiedInvoice(seller: seller);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-37'), isTrue);
      });

      test('rejects empty postal code', () {
        final seller = validSeller().copyWith(postalCode: '');
        final invoice = validSimplifiedInvoice(seller: seller);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-38'), isTrue);
      });

      test('warns about non-5-digit postal code', () {
        final seller = validSeller().copyWith(postalCode: '1234');
        final invoice = validSimplifiedInvoice(seller: seller);
        final errors = checker.validate(invoice);

        expect(
          errors.any((e) =>
              e.code == 'BT-38' && e.severity == ComplianceSeverity.warning),
          isTrue,
        );
      });

      test('rejects non-SA country code', () {
        final seller = validSeller().copyWith(countryCode: 'US');
        final invoice = validSimplifiedInvoice(seller: seller);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-40'), isTrue);
      });
    });

    // ── Buyer Validation ──────────────────────────────────

    group('buyer validation', () {
      test('requires buyer for standard B2B invoices', () {
        final invoice = ZatcaInvoice(
          invoiceNumber: 'INV-003',
          uuid: '550e8400-e29b-41d4-a716-446655440002',
          issueDate: DateTime(2026, 1, 15),
          issueTime: DateTime(2026, 1, 15, 14, 30),
          typeCode: InvoiceTypeCode.standard,
          subType: '0100000',
          seller: validSeller(),
          buyer: null,
          lines: [validLine()],
        );
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-44'), isTrue);
      });

      test('rejects buyer without name for standard invoices', () {
        final invoice = validStandardInvoice(
          buyer: const ZatcaBuyer(
            vatNumber: '300000000000010',
          ),
        );
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-44'), isTrue);
      });

      test('rejects buyer with invalid VAT format for standard invoices', () {
        final invoice = validStandardInvoice(
          buyer: const ZatcaBuyer(
            name: 'Buyer Corp',
            vatNumber: '12345',
          ),
        );
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-48'), isTrue);
      });

      test('does not require buyer for simplified invoices', () {
        final invoice = validSimplifiedInvoice();
        final errors = checker.validate(invoice);

        expect(errors.where((e) => e.code == 'BT-44'), isEmpty);
      });
    });

    // ── Line Items Validation ─────────────────────────────

    group('line items validation', () {
      test('rejects invoice with no lines', () {
        final invoice = validSimplifiedInvoice(lines: []);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BG-25'), isTrue);
      });

      test('rejects line with empty item name', () {
        final line = validLine().copyWith(itemName: '');
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-153'), isTrue);
      });

      test('rejects line with zero quantity', () {
        final line = validLine().copyWith(quantity: 0);
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-129'), isTrue);
      });

      test('rejects line with negative quantity', () {
        final line = validLine().copyWith(quantity: -1);
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-129'), isTrue);
      });

      test('rejects line with negative unit price', () {
        final line = validLine().copyWith(unitPrice: -5.0);
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-146'), isTrue);
      });

      test('rejects invalid VAT category code', () {
        final line = validLine(vatCategoryCode: 'X');
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-151'), isTrue);
      });

      test('requires exemption reason for exempt category E', () {
        final line = validLine(
          vatCategoryCode: 'E',
          vatRate: 0.0,
        );
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-120'), isTrue);
      });

      test('requires exemption reason for zero-rated category Z', () {
        final line = validLine(
          vatCategoryCode: 'Z',
          vatRate: 0.0,
        );
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-120'), isTrue);
      });

      test('accepts exempt category with exemption reason', () {
        final line = validLine(
          vatCategoryCode: 'E',
          vatRate: 0.0,
          vatExemptionReason: 'Exempt under Article 30',
        );
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.where((e) => e.code == 'BT-120'), isEmpty);
      });

      test('warns when standard rate is not 15%', () {
        final line = validLine(vatCategoryCode: 'S', vatRate: 10.0);
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(
          errors.any((e) =>
              e.code == 'KSA-EN16931-08' &&
              e.severity == ComplianceSeverity.warning),
          isTrue,
        );
      });

      test('rejects non-zero VAT rate for zero-rated category Z', () {
        final line = validLine(
          vatCategoryCode: 'Z',
          vatRate: 5.0,
          vatExemptionReason: 'Export',
        );
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-152'), isTrue);
      });

      test('rejects discount exceeding line amount', () {
        final line = validLine().copyWith(discountAmount: 999.0);
        final invoice = validSimplifiedInvoice(lines: [line]);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-136'), isTrue);
      });
    });

    // ── Amount Validation ─────────────────────────────────

    group('amount validation', () {
      test('rejects document discount exceeding total line net', () {
        final invoice = validSimplifiedInvoice(documentDiscount: 999.0);
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-107'), isTrue);
      });
    });

    // ── Billing Reference ─────────────────────────────────

    group('billing reference validation', () {
      test('requires billing reference for credit notes', () {
        final invoice = validSimplifiedInvoice(
          typeCode: InvoiceTypeCode.creditNote,
          billingReferenceId: null,
        );
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-25'), isTrue);
      });

      test('requires billing reference for debit notes', () {
        final invoice = validSimplifiedInvoice(
          typeCode: InvoiceTypeCode.debitNote,
          billingReferenceId: null,
        );
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-25'), isTrue);
      });

      test('accepts credit note with billing reference', () {
        final invoice = validSimplifiedInvoice(
          typeCode: InvoiceTypeCode.creditNote,
          billingReferenceId: 'INV-001',
        );
        final errors = checker.validate(invoice);

        expect(errors.where((e) => e.code == 'BT-25'), isEmpty);
      });

      test('does not require billing reference for standard invoices', () {
        final invoice = validSimplifiedInvoice(
          typeCode: InvoiceTypeCode.standard,
        );
        final errors = checker.validate(invoice);

        expect(errors.where((e) => e.code == 'BT-25'), isEmpty);
      });
    });

    // ── Currency Validation ───────────────────────────────

    group('currency validation', () {
      test('rejects non-SAR currency', () {
        final invoice = validSimplifiedInvoice(currencyCode: 'USD');
        final errors = checker.validate(invoice);

        expect(errors.any((e) => e.code == 'BT-5'), isTrue);
      });

      test('accepts SAR currency', () {
        final invoice = validSimplifiedInvoice(currencyCode: 'SAR');
        final errors = checker.validate(invoice);

        expect(errors.where((e) => e.code == 'BT-5'), isEmpty);
      });
    });

    // ── Convenience Methods ───────────────────────────────

    group('convenience methods', () {
      test('isValid returns true for valid invoice', () {
        expect(checker.isValid(validSimplifiedInvoice()), isTrue);
      });

      test('isValid returns false for invalid invoice', () {
        final invoice = validSimplifiedInvoice().copyWith(invoiceNumber: '');
        expect(checker.isValid(invoice), isFalse);
      });

      test('check returns ComplianceResult with correct state', () {
        final result = checker.check(validSimplifiedInvoice());
        expect(result.isValid, isTrue);
        expect(result.blockingErrors, isEmpty);
        expect(result.warnings, isEmpty);
      });

      test('check separates blocking errors from warnings', () {
        // Create an invoice with both an error and a warning
        final line = validLine(vatCategoryCode: 'S', vatRate: 10.0);
        final invoice = validSimplifiedInvoice(
          lines: [line],
          currencyCode: 'USD',
        );
        final result = checker.check(invoice);

        expect(result.isValid, isFalse);
        expect(result.blockingErrors, isNotEmpty);
        expect(result.warnings, isNotEmpty);
      });

      test('hasOnlyWarnings is true when no blocking errors', () {
        final line = validLine(vatCategoryCode: 'S', vatRate: 10.0);
        final invoice = validSimplifiedInvoice(lines: [line]);
        final result = checker.check(invoice);

        // VAT rate warning is non-blocking
        expect(result.hasOnlyWarnings, isTrue);
      });
    });
  });
}
