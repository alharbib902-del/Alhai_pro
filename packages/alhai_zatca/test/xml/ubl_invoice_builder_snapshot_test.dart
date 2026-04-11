import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/zatca_buyer.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/xml/ubl_invoice_builder.dart';

/// Golden-file ("snapshot") tests for [UblInvoiceBuilder].
///
/// The goal is to freeze the exact XML output for a handful of well-known
/// invoice fixtures so that *any* unintended change to UBL generation is
/// caught immediately — even cosmetic ones like element ordering or
/// whitespace, which matter for ZATCA canonical hashing.
///
/// ## Updating goldens
///
/// When a UBL change is intentional, regenerate the goldens with:
///
/// ```
/// UPDATE_GOLDENS=1 flutter test test/xml/ubl_invoice_builder_snapshot_test.dart
/// ```
///
/// Review the diff carefully before committing — a change here has
/// legal/compliance implications (ZATCA Phase 2 e-invoicing).
void main() {
  // ─── Test fixtures ──────────────────────────────────────

  // NOTE: All fields below are deliberately deterministic (fixed DateTime,
  // fixed UUIDs, fixed hashes) so the generated XML is byte-stable across
  // runs and machines.

  const seller = ZatcaSeller(
    name: 'Alhai Test Store LLC',
    vatNumber: '310122393500003',
    crNumber: '4030123456',
    streetName: 'King Fahd Road',
    buildingNumber: '1234',
    plotIdentification: '0000',
    city: 'Riyadh',
    district: 'Al Olaya',
    postalCode: '12345',
  );

  const buyer = ZatcaBuyer(
    name: 'Buyer Company Ltd',
    vatNumber: '399999999900003',
    streetName: 'Prince Sultan Street',
    buildingNumber: '5678',
    city: 'Jeddah',
    district: 'Al Rawdah',
    postalCode: '21589',
    countryCode: 'SA',
  );

  const line1 = ZatcaInvoiceLine(
    lineId: '1',
    itemName: 'Laptop Dell XPS 15',
    quantity: 2,
    unitPrice: 5000.0,
    vatRate: 15.0,
    vatCategoryCode: 'S',
  );

  const line2 = ZatcaInvoiceLine(
    lineId: '2',
    itemName: 'USB-C Adapter',
    quantity: 5,
    unitPrice: 50.0,
    grossPrice: 60.0,
    discountAmount: 50.0,
    discountReason: 'Bulk discount',
    vatRate: 15.0,
    vatCategoryCode: 'S',
    barcode: '6281234567890',
    sellerItemId: 'USBC-001',
  );

  final standardB2bMinimal = ZatcaInvoice(
    invoiceNumber: 'INV-2026-001',
    uuid: '550e8400-e29b-41d4-a716-446655440000',
    issueDate: DateTime.utc(2026, 4, 1),
    issueTime: DateTime.utc(2026, 4, 1, 14, 30, 0),
    typeCode: InvoiceTypeCode.standard,
    subType: InvoiceSubType.standardB2B,
    seller: seller,
    buyer: buyer,
    lines: const [line1],
    invoiceCounterValue: 1,
    previousInvoiceHash: 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzk=',
  );

  final standardB2bFullWithDiscount = ZatcaInvoice(
    invoiceNumber: 'INV-2026-042',
    uuid: '550e8400-e29b-41d4-a716-446655440042',
    issueDate: DateTime.utc(2026, 4, 1),
    issueTime: DateTime.utc(2026, 4, 1, 14, 30, 0),
    typeCode: InvoiceTypeCode.standard,
    subType: InvoiceSubType.standardB2B,
    seller: seller,
    buyer: buyer,
    lines: const [line1, line2],
    documentDiscount: 100.0,
    documentDiscountReason: 'Loyalty rebate',
    paymentMeansCode: '42',
    paymentNote: 'Bank transfer within 30 days',
    invoiceCounterValue: 42,
    previousInvoiceHash: 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzk=',
    qrCode: 'AQNBTEhBSQIPMzEwMTIyMzkzNTAwMDAzAxMyMDI2LTA0LTAxVDE0OjMwOjAw',
  );

  final simplifiedB2cMinimal = ZatcaInvoice(
    invoiceNumber: 'SINV-2026-001',
    uuid: '660e8400-e29b-41d4-a716-446655440111',
    issueDate: DateTime.utc(2026, 4, 2),
    issueTime: DateTime.utc(2026, 4, 2, 10, 0, 0),
    typeCode: InvoiceTypeCode.standard,
    subType: InvoiceSubType.simplifiedB2C,
    seller: seller,
    lines: const [line1],
    invoiceCounterValue: 2,
  );

  // Zero-rated export line (0% VAT, with exemption reason)
  const lineExportZero = ZatcaInvoiceLine(
    lineId: '1',
    itemName: 'Exported goods — machinery',
    quantity: 1,
    unitPrice: 10000.0,
    vatRate: 0.0,
    vatCategoryCode: 'Z',
    vatExemptionReason: 'Export outside GCC',
    vatExemptionReasonCode: 'VATEX-SA-32',
  );

  final standardSelfBilled = ZatcaInvoice(
    invoiceNumber: 'SB-2026-001',
    uuid: '880e8400-e29b-41d4-a716-446655440333',
    issueDate: DateTime.utc(2026, 4, 4),
    issueTime: DateTime.utc(2026, 4, 4, 11, 0, 0),
    typeCode: InvoiceTypeCode.standard,
    subType: InvoiceSubType.standardSelfBilled,
    seller: seller,
    buyer: buyer,
    lines: const [line1],
    invoiceCounterValue: 10,
    previousInvoiceHash: 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzk=',
  );

  final standardExport = ZatcaInvoice(
    invoiceNumber: 'EXP-2026-001',
    uuid: '990e8400-e29b-41d4-a716-446655440444',
    issueDate: DateTime.utc(2026, 4, 5),
    issueTime: DateTime.utc(2026, 4, 5, 13, 45, 0),
    typeCode: InvoiceTypeCode.standard,
    subType: InvoiceSubType.standardExport,
    seller: seller,
    buyer: const ZatcaBuyer(
      name: 'Foreign Importer GmbH',
      streetName: 'Hauptstraße 10',
      buildingNumber: '10',
      city: 'Berlin',
      postalCode: '10115',
      countryCode: 'DE',
    ),
    lines: const [lineExportZero],
    invoiceCounterValue: 11,
    previousInvoiceHash: 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzk=',
  );

  final standardThirdParty = ZatcaInvoice(
    invoiceNumber: 'TP-2026-001',
    uuid: 'aa0e8400-e29b-41d4-a716-446655440555',
    issueDate: DateTime.utc(2026, 4, 6),
    issueTime: DateTime.utc(2026, 4, 6, 16, 20, 0),
    typeCode: InvoiceTypeCode.standard,
    subType: InvoiceSubType.standardThirdParty,
    seller: seller,
    buyer: buyer,
    lines: const [line1, line2],
    purchaseOrderId: 'PO-2026-9001',
    contractId: 'CONTRACT-2026-42',
    invoiceCounterValue: 12,
    previousInvoiceHash: 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzk=',
  );

  final creditNote = ZatcaInvoice(
    invoiceNumber: 'CN-2026-001',
    uuid: '770e8400-e29b-41d4-a716-446655440222',
    issueDate: DateTime.utc(2026, 4, 3),
    issueTime: DateTime.utc(2026, 4, 3, 9, 15, 30),
    typeCode: InvoiceTypeCode.creditNote,
    subType: InvoiceSubType.standardB2B,
    seller: seller,
    buyer: buyer,
    lines: const [line1],
    billingReferenceId: 'INV-2026-001',
    invoiceCounterValue: 3,
    previousInvoiceHash: 'NWZlY2ViNjZmZmM4NmYzOGQ5NTI3ODZjNmQ2OTZjNzljMmRiYzk=',
  );

  // ─── Snapshot plumbing ──────────────────────────────────

  final snapshotDir = Directory('test/xml/snapshots');
  final updateGoldens = Platform.environment['UPDATE_GOLDENS'] == '1';

  setUpAll(() {
    if (updateGoldens && !snapshotDir.existsSync()) {
      snapshotDir.createSync(recursive: true);
    }
  });

  void expectMatchesGolden(String actualXml, String fileName) {
    final file = File('${snapshotDir.path}/$fileName');

    if (updateGoldens) {
      file.writeAsStringSync(actualXml);
      // Still assert — keeps the test green on update runs and proves
      // the read-back is consistent.
      expect(file.readAsStringSync(), actualXml);
      return;
    }

    if (!file.existsSync()) {
      fail(
        'Golden file "${file.path}" does not exist. '
        'Run with UPDATE_GOLDENS=1 to create it.',
      );
    }

    final expected = file.readAsStringSync();
    expect(
      actualXml,
      expected,
      reason:
          'UBL output for "$fileName" no longer matches the golden. '
          'If the change is intentional, rerun with UPDATE_GOLDENS=1 and '
          'review the diff carefully — this file has compliance weight.',
    );
  }

  // ─── Tests ──────────────────────────────────────────────

  group('UblInvoiceBuilder golden snapshots', () {
    final builder = UblInvoiceBuilder();

    test('standard B2B minimal (single line, with PIH)', () {
      final xml = builder.build(standardB2bMinimal);
      expectMatchesGolden(xml, 'standard_b2b_minimal.xml');
    });

    test('standard B2B full (2 lines, doc discount, QR, bank transfer)', () {
      final xml = builder.build(standardB2bFullWithDiscount);
      expectMatchesGolden(xml, 'standard_b2b_full.xml');
    });

    test('simplified B2C minimal (no buyer)', () {
      final xml = builder.build(simplifiedB2cMinimal);
      expectMatchesGolden(xml, 'simplified_b2c_minimal.xml');
    });

    test('credit note (with billing reference)', () {
      final xml = builder.build(creditNote);
      expectMatchesGolden(xml, 'credit_note.xml');
    });

    test('standard self-billed invoice (subType 0100010)', () {
      final xml = builder.build(standardSelfBilled);
      expectMatchesGolden(xml, 'standard_self_billed.xml');
    });

    test('standard export invoice (zero-rated, foreign buyer)', () {
      final xml = builder.build(standardExport);
      expectMatchesGolden(xml, 'standard_export.xml');
    });

    test('standard third-party invoice (with PO and contract refs)', () {
      final xml = builder.build(standardThirdParty);
      expectMatchesGolden(xml, 'standard_third_party.xml');
    });
  });
}
