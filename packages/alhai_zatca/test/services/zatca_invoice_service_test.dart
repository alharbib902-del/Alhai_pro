import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/api/clearance_api.dart';
import 'package:alhai_zatca/src/api/reporting_api.dart';
import 'package:alhai_zatca/src/certificate/certificate_storage.dart';
import 'package:alhai_zatca/src/chaining/invoice_chain_service.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/invoice_type_code.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_invoice.dart';
import 'package:alhai_zatca/src/models/zatca_invoice_line.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';
import 'package:alhai_zatca/src/models/zatca_seller.dart';
import 'package:alhai_zatca/src/qr/zatca_qr_service.dart';
import 'package:alhai_zatca/src/services/zatca_compliance_checker.dart';
import 'package:alhai_zatca/src/services/zatca_invoice_service.dart';
import 'package:alhai_zatca/src/services/zatca_offline_queue.dart';
import 'package:alhai_zatca/src/signing/xades_signer.dart';
import 'package:alhai_zatca/src/xml/ubl_invoice_builder.dart';

// ── Mocks ──────────────────────────────────────────────────

class MockUblInvoiceBuilder extends Mock implements UblInvoiceBuilder {}

class MockXadesSigner extends Mock implements XadesSigner {}

class MockZatcaQrService extends Mock implements ZatcaQrService {}

class MockInvoiceChainService extends Mock implements InvoiceChainService {}

class MockReportingApi extends Mock implements ReportingApi {}

class MockClearanceApi extends Mock implements ClearanceApi {}

class MockCertificateStorage extends Mock implements CertificateStorage {}

class MockZatcaOfflineQueue extends Mock implements ZatcaOfflineQueue {}

class MockZatcaComplianceChecker extends Mock
    implements ZatcaComplianceChecker {}

// ── Fakes ──────────────────────────────────────────────────

class FakeZatcaInvoice extends Fake implements ZatcaInvoice {}

class FakeCertificateInfo extends Fake implements CertificateInfo {}

class FakeReportingApi extends Fake implements ReportingApi {}

class FakeClearanceApi extends Fake implements ClearanceApi {}

class FakeCertificateStorage extends Fake implements CertificateStorage {}

void main() {
  late ZatcaInvoiceService service;
  late MockUblInvoiceBuilder mockXmlBuilder;
  late MockXadesSigner mockSigner;
  late MockZatcaQrService mockQrService;
  late MockInvoiceChainService mockChainService;
  late MockReportingApi mockReportingApi;
  late MockClearanceApi mockClearanceApi;
  late MockCertificateStorage mockCertStorage;
  late MockZatcaOfflineQueue mockOfflineQueue;
  late MockZatcaComplianceChecker mockComplianceChecker;

  // Test fixtures
  const storeId = 'store-1';

  final validCertificate = CertificateInfo(
    certificatePem: 'cert-pem',
    privateKeyPem: 'key-pem',
    csid: 'csid',
    secret: 'secret',
    isProduction: true,
  );

  final expiredCertificate = CertificateInfo(
    certificatePem: 'cert-pem',
    privateKeyPem: 'key-pem',
    csid: 'csid',
    secret: 'secret',
    isProduction: true,
    validTo: DateTime(2020, 1, 1),
  );

  ZatcaInvoice simplifiedInvoice() => ZatcaInvoice(
        invoiceNumber: 'INV-001',
        uuid: '550e8400-e29b-41d4-a716-446655440000',
        issueDate: DateTime(2026, 1, 15),
        issueTime: DateTime(2026, 1, 15, 14, 30),
        typeCode: InvoiceTypeCode.standard,
        subType: '0200000',
        seller: const ZatcaSeller(
          name: 'Test Store',
          vatNumber: '300000000000003',
          streetName: 'King Fahd Road',
          buildingNumber: '1234',
          city: 'Riyadh',
          postalCode: '12345',
        ),
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

  ZatcaInvoice standardInvoice() => simplifiedInvoice().copyWith(
        subType: '0100000',
      );

  const validComplianceResult = ComplianceResult(
    isValid: true,
    errors: [],
  );

  const invalidComplianceResult = ComplianceResult(
    isValid: false,
    errors: [
      ComplianceError(
        code: 'BT-1',
        field: 'invoiceNumber',
        message: 'Invoice number is required',
        severity: ComplianceSeverity.error,
      ),
    ],
  );

  const warningOnlyResult = ComplianceResult(
    isValid: false,
    errors: [
      ComplianceError(
        code: 'KSA-EN16931-08',
        field: 'vatRate',
        message: 'Non-standard VAT rate',
        severity: ComplianceSeverity.warning,
      ),
    ],
  );

  const successResponse = ZatcaResponse(
    isSuccess: true,
    statusCode: 200,
    reportingStatus: ReportingStatus.reported,
  );

  const clearanceSuccessResponse = ZatcaResponse(
    isSuccess: true,
    statusCode: 200,
    reportingStatus: ReportingStatus.cleared,
    clearedInvoiceXml: '<stamped-xml/>',
  );

  setUpAll(() {
    registerFallbackValue(FakeZatcaInvoice());
    registerFallbackValue(FakeCertificateInfo());
    registerFallbackValue(FakeReportingApi());
    registerFallbackValue(FakeClearanceApi());
    registerFallbackValue(FakeCertificateStorage());
  });

  setUp(() {
    mockXmlBuilder = MockUblInvoiceBuilder();
    mockSigner = MockXadesSigner();
    mockQrService = MockZatcaQrService();
    mockChainService = MockInvoiceChainService();
    mockReportingApi = MockReportingApi();
    mockClearanceApi = MockClearanceApi();
    mockCertStorage = MockCertificateStorage();
    mockOfflineQueue = MockZatcaOfflineQueue();
    mockComplianceChecker = MockZatcaComplianceChecker();

    service = ZatcaInvoiceService(
      xmlBuilder: mockXmlBuilder,
      signer: mockSigner,
      qrService: mockQrService,
      chainService: mockChainService,
      reportingApi: mockReportingApi,
      clearanceApi: mockClearanceApi,
      certStorage: mockCertStorage,
      offlineQueue: mockOfflineQueue,
      complianceChecker: mockComplianceChecker,
    );
  });

  // Helper to set up the full happy path
  void setupHappyPath({bool isStandard = false}) {
    when(() => mockComplianceChecker.check(any()))
        .thenReturn(validComplianceResult);
    when(() => mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
        .thenAnswer((_) async => validCertificate);
    when(() => mockChainService.getPreviousHash(storeId: any(named: 'storeId')))
        .thenAnswer((_) async => 'prev-hash-base64');
    when(() => mockXmlBuilder.build(any())).thenReturn('<Invoice/>');
    when(() => mockSigner.sign(
              invoiceXml: any(named: 'invoiceXml'),
              certificate: any(named: 'certificate'),
            ))
        .thenReturn(
            '<ds:Signature><ds:SignatureValue>abc123</ds:SignatureValue></ds:Signature>');
    when(() => mockSigner.computeInvoiceHash(any()))
        .thenReturn('invoice-hash-base64');
    when(() => mockQrService.generateQrData(
          invoice: any(named: 'invoice'),
          invoiceHash: any(named: 'invoiceHash'),
          digitalSignature: any(named: 'digitalSignature'),
          certificate: any(named: 'certificate'),
        )).thenReturn('qr-data-base64');

    if (isStandard) {
      when(() => mockClearanceApi.clearInvoice(
            signedXmlBase64: any(named: 'signedXmlBase64'),
            invoiceHash: any(named: 'invoiceHash'),
            uuid: any(named: 'uuid'),
            certificate: any(named: 'certificate'),
          )).thenAnswer((_) async => clearanceSuccessResponse);
    } else {
      when(() => mockReportingApi.reportInvoice(
            signedXmlBase64: any(named: 'signedXmlBase64'),
            invoiceHash: any(named: 'invoiceHash'),
            uuid: any(named: 'uuid'),
            certificate: any(named: 'certificate'),
          )).thenAnswer((_) async => successResponse);
    }

    when(() => mockChainService.updateLastHash(
          storeId: any(named: 'storeId'),
          invoiceHash: any(named: 'invoiceHash'),
        )).thenAnswer((_) async {});
  }

  group('ZatcaInvoiceService', () {
    // ── processInvoice ────────────────────────────────────

    group('processInvoice - happy path', () {
      test('processes simplified invoice end-to-end', () async {
        setupHappyPath();

        final result = await service.processInvoice(
          invoice: simplifiedInvoice(),
          storeId: storeId,
        );

        expect(result.reportingStatus, ReportingStatus.reported);
        expect(result.invoiceHash, 'invoice-hash-base64');
        expect(result.signedXml, isNotNull);
        expect(result.qrCode, 'qr-data-base64');
        expect(result.previousInvoiceHash, 'prev-hash-base64');

        verify(() => mockChainService.updateLastHash(
              storeId: storeId,
              invoiceHash: 'invoice-hash-base64',
            )).called(1);
      });

      test('processes standard invoice via clearance', () async {
        setupHappyPath(isStandard: true);

        final result = await service.processInvoice(
          invoice: standardInvoice(),
          storeId: storeId,
        );

        expect(result.reportingStatus, ReportingStatus.cleared);
        expect(result.signedXml, '<stamped-xml/>');

        verify(() => mockClearanceApi.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).called(1);
      });
    });

    // ── processInvoice - validation failures ──────────────

    group('processInvoice - validation', () {
      test('returns failed when compliance check has blocking errors',
          () async {
        when(() => mockComplianceChecker.check(any()))
            .thenReturn(invalidComplianceResult);

        final result = await service.processInvoice(
          invoice: simplifiedInvoice(),
          storeId: storeId,
        );

        expect(result.reportingStatus, ReportingStatus.failed);
        expect(result.errors, isNotEmpty);

        // Should not proceed to signing
        verifyNever(() => mockXmlBuilder.build(any()));
      });

      test('continues processing when only warnings exist', () async {
        setupHappyPath();
        when(() => mockComplianceChecker.check(any()))
            .thenReturn(warningOnlyResult);

        final result = await service.processInvoice(
          invoice: simplifiedInvoice(),
          storeId: storeId,
        );

        // Should succeed since no blocking errors
        expect(result.reportingStatus, ReportingStatus.reported);
        expect(result.warnings, isNotEmpty);
      });
    });

    // ── processInvoice - certificate issues ───────────────

    group('processInvoice - certificate', () {
      test('returns failed when no certificate found', () async {
        when(() => mockComplianceChecker.check(any()))
            .thenReturn(validComplianceResult);
        when(() =>
                mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => null);

        final result = await service.processInvoice(
          invoice: simplifiedInvoice(),
          storeId: storeId,
        );

        expect(result.reportingStatus, ReportingStatus.failed);
        expect(result.errors.any((e) => e.contains('No ZATCA certificate')),
            isTrue);
      });

      test('returns failed when certificate is expired', () async {
        when(() => mockComplianceChecker.check(any()))
            .thenReturn(validComplianceResult);
        when(() =>
                mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenAnswer((_) async => expiredCertificate);

        final result = await service.processInvoice(
          invoice: simplifiedInvoice(),
          storeId: storeId,
        );

        expect(result.reportingStatus, ReportingStatus.failed);
        expect(result.errors.any((e) => e.contains('expired')), isTrue);
      });
    });

    // ── processInvoice - network failures / offline ───────

    group('processInvoice - offline queue', () {
      test('queues simplified invoice when reporting fails', () async {
        setupHappyPath();
        when(() => mockReportingApi.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenThrow(Exception('Connection refused'));
        when(() => mockOfflineQueue.enqueue(
              invoiceNumber: any(named: 'invoiceNumber'),
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              isStandard: any(named: 'isStandard'),
            )).thenAnswer((_) async {});

        final result = await service.processInvoice(
          invoice: simplifiedInvoice(),
          storeId: storeId,
        );

        expect(result.reportingStatus, ReportingStatus.queued);
        verify(() => mockOfflineQueue.enqueue(
              invoiceNumber: any(named: 'invoiceNumber'),
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              isStandard: false,
            )).called(1);
      });

      test('queues standard invoice when clearance fails', () async {
        setupHappyPath(isStandard: true);
        when(() => mockClearanceApi.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenThrow(Exception('Timeout'));
        when(() => mockOfflineQueue.enqueue(
              invoiceNumber: any(named: 'invoiceNumber'),
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              isStandard: any(named: 'isStandard'),
            )).thenAnswer((_) async {});

        final result = await service.processInvoice(
          invoice: standardInvoice(),
          storeId: storeId,
        );

        expect(result.reportingStatus, ReportingStatus.queued);
      });
    });

    // ── processInvoice - QR fallback ──────────────────────

    group('processInvoice - QR fallback', () {
      test('falls back to simplified QR when enhanced QR fails', () async {
        setupHappyPath();
        when(() => mockQrService.generateQrData(
              invoice: any(named: 'invoice'),
              invoiceHash: any(named: 'invoiceHash'),
              digitalSignature: any(named: 'digitalSignature'),
              certificate: any(named: 'certificate'),
            )).thenThrow(Exception('Certificate parsing failed'));
        when(() => mockQrService.generateSimplifiedQr(
              invoice: any(named: 'invoice'),
            )).thenReturn('simplified-qr');

        final result = await service.processInvoice(
          invoice: simplifiedInvoice(),
          storeId: storeId,
        );

        expect(result.qrCode, 'simplified-qr');
        expect(result.reportingStatus, ReportingStatus.reported);
      });
    });

    // ── processInvoice - never throws ─────────────────────

    group('processInvoice - error handling', () {
      test('never throws - captures processing errors', () async {
        when(() => mockComplianceChecker.check(any()))
            .thenReturn(validComplianceResult);
        when(() =>
                mockCertStorage.getCertificate(storeId: any(named: 'storeId')))
            .thenThrow(Exception('Database corrupted'));

        final result = await service.processInvoice(
          invoice: simplifiedInvoice(),
          storeId: storeId,
        );

        expect(result.reportingStatus, ReportingStatus.failed);
        expect(
            result.errors.any((e) => e.contains('Processing error')), isTrue);
      });
    });

    // ── retryQueue ────────────────────────────────────────

    group('retryQueue', () {
      test('delegates to offline queue processQueue', () async {
        when(() => mockOfflineQueue.processQueue(
              reportingApi: any(named: 'reportingApi'),
              clearanceApi: any(named: 'clearanceApi'),
              certStorage: any(named: 'certStorage'),
              storeId: any(named: 'storeId'),
            )).thenAnswer((_) async => []);

        final results = await service.retryQueue(storeId: storeId);

        expect(results, isEmpty);
        verify(() => mockOfflineQueue.processQueue(
              reportingApi: mockReportingApi,
              clearanceApi: mockClearanceApi,
              certStorage: mockCertStorage,
              storeId: storeId,
            )).called(1);
      });
    });

    // ── getPendingQueueCount ──────────────────────────────

    group('getPendingQueueCount', () {
      test('returns count from offline queue', () async {
        when(() => mockOfflineQueue.pendingCount).thenAnswer((_) async => 5);

        final count = await service.getPendingQueueCount();
        expect(count, 5);
      });
    });

    // ── validateInvoice ───────────────────────────────────

    group('validateInvoice', () {
      test('delegates to compliance checker', () {
        when(() => mockComplianceChecker.check(any()))
            .thenReturn(validComplianceResult);

        final result = service.validateInvoice(simplifiedInvoice());
        expect(result.isValid, isTrue);
      });
    });
  });
}
