import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/qr/zatca_qr_service.dart';
import 'package:alhai_zatca/src/qr/zatca_tlv_encoder.dart';
import 'package:alhai_zatca/src/signing/certificate_parser.dart';

// ── Mocks ──────────────────────────────────────────────────

class MockZatcaTlvEncoder extends Mock implements ZatcaTlvEncoder {}

class MockCertificateParser extends Mock implements CertificateParser {}

void main() {
  // Note: ZatcaTlvEncoder already has its own extensive unit-test file
  // at test/qr/zatca_tlv_encoder_test.dart covering TLV encoding,
  // Arabic, decoding, large values, variable-length encoding, etc.
  //
  // This test file focuses on the SERVICE LAYER (ZatcaQrService) —
  // orchestration, field selection, certificate parsing, and correct
  // delegation to the encoder. Some tests also exercise the real
  // encoder to verify end-to-end behavior (base64 output, tag 1-5
  // presence, decoding to correct TLV structure).

  // ── Sample binary values (as base64) for tags 6-9 ──────────
  final fakeHashB64 = base64Encode(
    Uint8List.fromList(List.generate(32, (i) => i)),
  );
  final fakeSignatureB64 = base64Encode(
    Uint8List.fromList(List.generate(64, (i) => i + 50)),
  );
  final fakePublicKeyBytes = List.generate(33, (i) => (i + 100) % 256);
  final fakePublicKeyB64 = base64Encode(fakePublicKeyBytes);
  final fakeCertSigBytes = List.generate(64, (i) => (i + 50) % 256);

  // ── Sample invoice factories ───────────────────────────────
  ZatcaInvoice buildInvoice({
    String sellerName = 'Test Seller',
    String vatNumber = '310122393500003',
    DateTime? issueDate,
    String subType = '0200000', // simplified (B2C) by default
    double unitPrice = 100.0,
    double quantity = 1,
  }) {
    return ZatcaInvoice(
      invoiceNumber: 'INV-001',
      uuid: '550e8400-e29b-41d4-a716-446655440000',
      issueDate: issueDate ?? DateTime(2026, 1, 15, 14, 30, 0),
      issueTime: issueDate ?? DateTime(2026, 1, 15, 14, 30, 0),
      typeCode: InvoiceTypeCode.standard,
      subType: subType,
      seller: ZatcaSeller(
        name: sellerName,
        vatNumber: vatNumber,
        streetName: 'King Fahd Road',
        buildingNumber: '1234',
        city: 'Riyadh',
        postalCode: '12345',
      ),
      lines: [
        ZatcaInvoiceLine(
          lineId: '1',
          itemName: 'Product',
          quantity: quantity,
          unitPrice: unitPrice,
          vatRate: 15.0,
        ),
      ],
    );
  }

  final sampleCertificate = CertificateInfo(
    certificatePem: '-----BEGIN CERTIFICATE-----\nFAKE\n-----END CERTIFICATE-----',
    privateKeyPem: '-----BEGIN EC PRIVATE KEY-----\nFAKE\n-----END EC PRIVATE KEY-----',
    csid: 'test-csid',
    secret: 'test-secret',
    isProduction: true,
  );

  setUpAll(() {
    // Register fallbacks for mocktail
    registerFallbackValue(DateTime(2024));
  });

  group('ZatcaQrService (service layer)', () {
    // ─── generateQrData (Phase 2, tags 1-8 or 1-9) ────────────

    group('generateQrData', () {
      late MockZatcaTlvEncoder mockEncoder;
      late MockCertificateParser mockCertParser;
      late ZatcaQrService service;

      setUp(() {
        mockEncoder = MockZatcaTlvEncoder();
        mockCertParser = MockCertificateParser();
        service = ZatcaQrService(
          encoder: mockEncoder,
          certParser: mockCertParser,
        );

        // Default cert parser behavior
        when(() => mockCertParser.extractPublicKey(any()))
            .thenReturn(fakePublicKeyBytes);
        when(() => mockCertParser.extractSignatureBytes(any()))
            .thenReturn(fakeCertSigBytes);

        // Default encoder returns a fake but valid base64 string
        when(() => mockEncoder.encode(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: any(named: 'publicKey'),
              certificateSignature: any(named: 'certificateSignature'),
            )).thenReturn('ENCODED_BASE64_QR');
      });

      test(
          'simplified invoice (subType 02*): omits tag 9 certificate signature',
          () {
        final invoice = buildInvoice(subType: '0200000');

        service.generateQrData(
          invoice: invoice,
          invoiceHash: fakeHashB64,
          digitalSignature: fakeSignatureB64,
          certificate: sampleCertificate,
        );

        // extractSignatureBytes should NOT be called for simplified
        verifyNever(() => mockCertParser.extractSignatureBytes(any()));

        // Encoder should be called with certificateSignature == null
        verify(() => mockEncoder.encode(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: any(named: 'publicKey'),
              certificateSignature: null,
            )).called(1);
      });

      test(
          'standard invoice (subType 01*): includes tag 9 certificate signature',
          () {
        final invoice = buildInvoice(subType: '0100000');

        service.generateQrData(
          invoice: invoice,
          invoiceHash: fakeHashB64,
          digitalSignature: fakeSignatureB64,
          certificate: sampleCertificate,
        );

        // extractSignatureBytes SHOULD be called for standard invoices
        verify(() => mockCertParser.extractSignatureBytes(any())).called(1);

        // Encoder should be called with certificateSignature non-null
        final captured = verify(() => mockEncoder.encode(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: any(named: 'publicKey'),
              certificateSignature:
                  captureAny(named: 'certificateSignature'),
            )).captured;
        expect(captured.single, isNotNull);
        expect(captured.single, isA<String>());
      });

      test('extracts public key from certificate and passes as base64', () {
        final invoice = buildInvoice();

        service.generateQrData(
          invoice: invoice,
          invoiceHash: fakeHashB64,
          digitalSignature: fakeSignatureB64,
          certificate: sampleCertificate,
        );

        verify(() =>
                mockCertParser.extractPublicKey(sampleCertificate.certificatePem))
            .called(1);

        final captured = verify(() => mockEncoder.encode(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: captureAny(named: 'publicKey'),
              certificateSignature: any(named: 'certificateSignature'),
            )).captured;

        // publicKey passed to encoder must be valid base64
        expect(captured.single, isA<String>());
        expect(() => base64Decode(captured.single as String), returnsNormally);
        // Decoded bytes must match the extracted public key bytes
        expect(
          base64Decode(captured.single as String),
          equals(Uint8List.fromList(fakePublicKeyBytes)),
        );
      });

      test('passes invoice seller name and VAT number to encoder', () {
        final invoice = buildInvoice(
          sellerName: 'My Store',
          vatNumber: '300075588700003',
        );

        service.generateQrData(
          invoice: invoice,
          invoiceHash: fakeHashB64,
          digitalSignature: fakeSignatureB64,
          certificate: sampleCertificate,
        );

        verify(() => mockEncoder.encode(
              sellerName: 'My Store',
              vatNumber: '300075588700003',
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: any(named: 'publicKey'),
              certificateSignature: any(named: 'certificateSignature'),
            )).called(1);
      });

      test('passes computed total/vat from invoice to encoder', () {
        // Invoice: 1 line, unitPrice 100, qty 2, vat 15%
        // => taxable 200, vat 30, totalWithVat 230
        final invoice = buildInvoice(unitPrice: 100.0, quantity: 2);

        service.generateQrData(
          invoice: invoice,
          invoiceHash: fakeHashB64,
          digitalSignature: fakeSignatureB64,
          certificate: sampleCertificate,
        );

        verify(() => mockEncoder.encode(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: 230.0,
              vatAmount: 30.0,
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: any(named: 'publicKey'),
              certificateSignature: any(named: 'certificateSignature'),
            )).called(1);
      });

      test('returns the encoder output unchanged', () {
        when(() => mockEncoder.encode(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: any(named: 'publicKey'),
              certificateSignature: any(named: 'certificateSignature'),
            )).thenReturn('FAKE_QR_OUTPUT');

        final invoice = buildInvoice();
        final result = service.generateQrData(
          invoice: invoice,
          invoiceHash: fakeHashB64,
          digitalSignature: fakeSignatureB64,
          certificate: sampleCertificate,
        );

        expect(result, equals('FAKE_QR_OUTPUT'));
      });
    });

    // ─── generateSimplifiedQr (Phase 1, tags 1-5) ──────────────

    group('generateSimplifiedQr', () {
      test('delegates to encoder.encodeSimplified with invoice fields', () {
        final mockEncoder = MockZatcaTlvEncoder();
        final service = ZatcaQrService(encoder: mockEncoder);

        when(() => mockEncoder.encodeSimplified(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
            )).thenReturn('SIMPLIFIED_QR');

        final invoice = buildInvoice(
          sellerName: 'Quick Mart',
          vatNumber: '310122393500003',
        );

        final result = service.generateSimplifiedQr(invoice: invoice);

        expect(result, equals('SIMPLIFIED_QR'));
        verify(() => mockEncoder.encodeSimplified(
              sellerName: 'Quick Mart',
              vatNumber: '310122393500003',
              timestamp: any(named: 'timestamp'),
              totalWithVat: 115.0,
              vatAmount: 15.0,
            )).called(1);
      });

      test('end-to-end: produces valid base64 with real encoder', () {
        // Real encoder, no mocks - verifies the full pipeline
        final service = ZatcaQrService();
        final invoice = buildInvoice();

        final qr = service.generateSimplifiedQr(invoice: invoice);

        expect(qr, isNotEmpty);
        expect(() => base64Decode(qr), returnsNormally);
      });

      test(
          'end-to-end: decoding QR yields 5 tags with correct seller/VAT values',
          () {
        final service = ZatcaQrService();
        final encoder = ZatcaTlvEncoder();

        final invoice = buildInvoice(
          sellerName: 'Test Store',
          vatNumber: '310122393500003',
        );

        final qr = service.generateSimplifiedQr(invoice: invoice);
        final decoded = encoder.decode(qr);

        // Tags 1-5 should be present, 6-9 absent
        expect(decoded.keys.toList()..sort(), equals([1, 2, 3, 4, 5]));
        expect(decoded.containsKey(6), isFalse);
        expect(decoded.containsKey(9), isFalse);

        final strings = encoder.decodeToStrings(qr);
        expect(strings[1], equals('Test Store'));
        expect(strings[2], equals('310122393500003'));
      });

      test('end-to-end: supports Arabic seller names (UTF-8)', () {
        final service = ZatcaQrService();
        final encoder = ZatcaTlvEncoder();

        final invoice = buildInvoice(sellerName: 'شركة الاختبار');
        final qr = service.generateSimplifiedQr(invoice: invoice);

        final strings = encoder.decodeToStrings(qr);
        expect(strings[1], equals('شركة الاختبار'));
      });

      test('end-to-end: handles large totals without truncation', () {
        final service = ZatcaQrService();
        final encoder = ZatcaTlvEncoder();

        // Use copyWith to get a large value - build via unitPrice*quantity
        final invoice = buildInvoice(unitPrice: 999999.99, quantity: 1);
        final qr = service.generateSimplifiedQr(invoice: invoice);

        final strings = encoder.decodeToStrings(qr);
        expect(strings[4], isNotNull);
        // Total with VAT = 999999.99 * 1.15 = 1149999.9885 ≈ 1149999.99
        expect(strings[4]!, contains('1149999'));
      });
    });

    // ─── generateQrDataFromValues ─────────────────────────────

    group('generateQrDataFromValues', () {
      test('delegates to encoder.encode with raw values', () {
        final mockEncoder = MockZatcaTlvEncoder();
        final service = ZatcaQrService(encoder: mockEncoder);

        when(() => mockEncoder.encode(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: any(named: 'publicKey'),
              certificateSignature: any(named: 'certificateSignature'),
            )).thenReturn('RAW_QR');

        final result = service.generateQrDataFromValues(
          sellerName: 'Direct Store',
          vatNumber: '310122393500003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 500.0,
          vatAmount: 65.22,
          invoiceHash: fakeHashB64,
          digitalSignature: fakeSignatureB64,
          publicKeyBase64: fakePublicKeyB64,
        );

        expect(result, equals('RAW_QR'));
        verify(() => mockEncoder.encode(
              sellerName: 'Direct Store',
              vatNumber: '310122393500003',
              timestamp: DateTime(2026, 1, 1),
              totalWithVat: 500.0,
              vatAmount: 65.22,
              invoiceHash: fakeHashB64,
              digitalSignature: fakeSignatureB64,
              publicKey: fakePublicKeyB64,
              certificateSignature: null,
            )).called(1);
      });

      test('passes certificateSignatureBase64 when provided', () {
        final mockEncoder = MockZatcaTlvEncoder();
        final service = ZatcaQrService(encoder: mockEncoder);

        when(() => mockEncoder.encode(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: any(named: 'publicKey'),
              certificateSignature: any(named: 'certificateSignature'),
            )).thenReturn('RAW_QR_WITH_CERT_SIG');

        const certSigB64 = 'Y2VydHNpZw==';
        service.generateQrDataFromValues(
          sellerName: 'Store',
          vatNumber: '310122393500003',
          timestamp: DateTime(2026, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
          invoiceHash: fakeHashB64,
          digitalSignature: fakeSignatureB64,
          publicKeyBase64: fakePublicKeyB64,
          certificateSignatureBase64: certSigB64,
        );

        verify(() => mockEncoder.encode(
              sellerName: any(named: 'sellerName'),
              vatNumber: any(named: 'vatNumber'),
              timestamp: any(named: 'timestamp'),
              totalWithVat: any(named: 'totalWithVat'),
              vatAmount: any(named: 'vatAmount'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              publicKey: any(named: 'publicKey'),
              certificateSignature: certSigB64,
            )).called(1);
      });
    });

    // ─── validateQrData ───────────────────────────────────────

    group('validateQrData', () {
      final service = ZatcaQrService();
      final encoder = ZatcaTlvEncoder();

      test('returns null for a valid Phase 2 QR with tags 1-8', () {
        final fakeHash = base64Encode(Uint8List.fromList(List.generate(32, (i) => i)));
        final fakeSig = base64Encode(Uint8List.fromList(List.generate(64, (i) => i)));
        final fakeKey = base64Encode(Uint8List.fromList(List.generate(33, (i) => i)));

        final qr = encoder.encode(
          sellerName: 'Valid Seller',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
          invoiceHash: fakeHash,
          digitalSignature: fakeSig,
          publicKey: fakeKey,
        );

        final error = service.validateQrData(qr);
        expect(error, isNull);
      });

      test('returns error when required tag (6) is missing (simplified QR)',
          () {
        // encodeSimplified only produces tags 1-5, missing 6-8
        final qr = encoder.encodeSimplified(
          sellerName: 'Test',
          vatNumber: '310122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 15.0,
        );

        final error = service.validateQrData(qr);
        expect(error, isNotNull);
        expect(error, contains('Missing required tag'));
      });

      test('returns error when VAT number has wrong format', () {
        final fakeHash = base64Encode(Uint8List.fromList(List.generate(32, (i) => i)));
        final fakeSig = base64Encode(Uint8List.fromList(List.generate(64, (i) => i)));
        final fakeKey = base64Encode(Uint8List.fromList(List.generate(33, (i) => i)));

        // VAT number not starting with 3
        final qr = encoder.encode(
          sellerName: 'Test',
          vatNumber: '410122393500003',
          timestamp: DateTime(2024, 1, 1),
          totalWithVat: 100.0,
          vatAmount: 13.04,
          invoiceHash: fakeHash,
          digitalSignature: fakeSig,
          publicKey: fakeKey,
        );

        final error = service.validateQrData(qr);
        expect(error, isNotNull);
        expect(error, contains('VAT number'));
      });

      test('returns error for malformed base64 input', () {
        final error = service.validateQrData('not-valid-base64!!!');
        expect(error, isNotNull);
      });
    });

    // ─── Constructor defaults ─────────────────────────────────

    group('constructor', () {
      test('uses default encoder and parser when none provided', () {
        final service = ZatcaQrService();
        final invoice = buildInvoice();

        // Should not throw with defaults
        final qr = service.generateSimplifiedQr(invoice: invoice);
        expect(qr, isNotEmpty);
      });
    });
  });
}
