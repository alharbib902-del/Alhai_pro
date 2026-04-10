import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/api/clearance_api.dart';
import 'package:alhai_zatca/src/api/zatca_api_client.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';

class MockZatcaApiClient extends Mock implements ZatcaApiClient {}

class FakeCertificateInfo extends Fake implements CertificateInfo {}

void main() {
  late ClearanceApi clearanceApi;
  late MockZatcaApiClient mockClient;

  const testCertificate = CertificateInfo(
    certificatePem: 'cert',
    privateKeyPem: 'key',
    csid: 'csid',
    secret: 'secret',
    isProduction: true,
  );

  const clearedResponse = ZatcaResponse(
    isSuccess: true,
    statusCode: 200,
    reportingStatus: ReportingStatus.reported,
    clearanceStatus: 'CLEARED',
    clearedInvoiceXml: 'base64-stamped-xml-content',
  );

  const clearedWithWarningsResponse = ZatcaResponse(
    isSuccess: true,
    statusCode: 202,
    reportingStatus: ReportingStatus.reported,
    clearanceStatus: 'CLEARED',
    clearedInvoiceXml: 'base64-stamped-xml-content',
    warnings: [
      ZatcaValidationResult(
        type: 'WARNING',
        code: 'W-001',
        message: 'Non-critical warning',
      ),
    ],
  );

  const rejectedResponse = ZatcaResponse(
    isSuccess: false,
    statusCode: 400,
    reportingStatus: ReportingStatus.rejected,
    clearanceStatus: 'NOT_CLEARED',
    errors: [
      ZatcaValidationResult(
        type: 'ERROR',
        code: 'BR-17',
        message: 'VAT calculation incorrect',
      ),
    ],
  );

  const serverErrorResponse = ZatcaResponse(
    isSuccess: false,
    statusCode: 500,
    reportingStatus: ReportingStatus.failed,
    errors: [
      ZatcaValidationResult(
        type: 'ERROR',
        code: 'LOCAL_ERROR',
        message: 'Server error',
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(FakeCertificateInfo());
  });

  setUp(() {
    mockClient = MockZatcaApiClient();
    clearanceApi = ClearanceApi(client: mockClient);
  });

  group('ClearanceApi', () {
    // ── clearInvoice ──────────────────────────────────────

    group('clearInvoice', () {
      test('delegates to client.clearInvoice and returns success', () async {
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => clearedResponse);

        final result = await clearanceApi.clearInvoice(
          signedXmlBase64: 'base64xml',
          invoiceHash: 'hash',
          uuid: 'uuid-1',
          certificate: testCertificate,
        );

        expect(result.isSuccess, isTrue);
        expect(result.clearanceStatus, 'CLEARED');
        expect(result.clearedInvoiceXml, 'base64-stamped-xml-content');
      });

      test('passes all parameters to client', () async {
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => clearedResponse);

        await clearanceApi.clearInvoice(
          signedXmlBase64: 'xml-payload',
          invoiceHash: 'hash-abc',
          uuid: 'uuid-xyz',
          certificate: testCertificate,
        );

        verify(() => mockClient.clearInvoice(
              signedXmlBase64: 'xml-payload',
              invoiceHash: 'hash-abc',
              uuid: 'uuid-xyz',
              certificate: testCertificate,
            )).called(1);
      });

      test('returns rejection response with errors', () async {
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => rejectedResponse);

        final result = await clearanceApi.clearInvoice(
          signedXmlBase64: 'bad-xml',
          invoiceHash: 'hash',
          uuid: 'uuid-1',
          certificate: testCertificate,
        );

        expect(result.isSuccess, isFalse);
        expect(result.clearanceStatus, 'NOT_CLEARED');
        expect(result.errors, isNotEmpty);
        expect(result.errors.first.code, 'BR-17');
      });

      test('propagates warnings on successful clearance', () async {
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => clearedWithWarningsResponse);

        final result = await clearanceApi.clearInvoice(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          certificate: testCertificate,
        );

        expect(result.isSuccess, isTrue);
        expect(result.statusCode, 202);
        expect(result.warnings, hasLength(1));
        expect(result.warnings.first.code, 'W-001');
      });
    });

    // ── clearAndGetStampedXml ─────────────────────────────

    group('clearAndGetStampedXml', () {
      test('returns stampedXmlBase64 on successful clearance', () async {
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => clearedResponse);

        final result = await clearanceApi.clearAndGetStampedXml(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          certificate: testCertificate,
        );

        expect(result.isCleared, isTrue);
        expect(result.stampedXmlBase64, 'base64-stamped-xml-content');
        expect(result.response.isSuccess, isTrue);
      });

      test('returns null stampedXmlBase64 on rejection', () async {
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => rejectedResponse);

        final result = await clearanceApi.clearAndGetStampedXml(
          signedXmlBase64: 'bad-xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          certificate: testCertificate,
        );

        expect(result.isCleared, isFalse);
        expect(result.stampedXmlBase64, isNull);
        expect(result.errors, isNotEmpty);
      });

      test('isCleared requires both success and non-null stamped XML',
          () async {
        // Success response but no stamped XML -- shouldn't happen in practice
        const successNoXml = ZatcaResponse(
          isSuccess: true,
          statusCode: 200,
          reportingStatus: ReportingStatus.reported,
        );

        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => successNoXml);

        final result = await clearanceApi.clearAndGetStampedXml(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          certificate: testCertificate,
        );

        expect(result.response.isSuccess, isTrue);
        expect(result.stampedXmlBase64, isNull);
        expect(result.isCleared, isFalse);
      });
    });

    // ── clearWithRetry ────────────────────────────────────

    group('clearWithRetry', () {
      test('succeeds on first attempt without retrying', () async {
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => clearedResponse);

        final result = await clearanceApi.clearWithRetry(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          certificate: testCertificate,
          maxRetries: 3,
        );

        expect(result.isCleared, isTrue);
        verify(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).called(1);
      });

      test('does NOT retry 400 validation rejections', () async {
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => rejectedResponse);

        final result = await clearanceApi.clearWithRetry(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          certificate: testCertificate,
          maxRetries: 3,
        );

        expect(result.isCleared, isFalse);
        expect(result.errors, isNotEmpty);
        verify(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).called(1);
      });

      test('retries on server error then succeeds', () async {
        var callCount = 0;
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) return serverErrorResponse;
          return clearedResponse;
        });

        final result = await clearanceApi.clearWithRetry(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          certificate: testCertificate,
          maxRetries: 3,
        );

        expect(result.isCleared, isTrue);
        expect(callCount, 2);
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('retries on thrown exception then succeeds', () async {
        var callCount = 0;
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 1) throw Exception('Network down');
          return clearedResponse;
        });

        final result = await clearanceApi.clearWithRetry(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          certificate: testCertificate,
          maxRetries: 3,
        );

        expect(result.isCleared, isTrue);
        expect(callCount, 2);
      }, timeout: const Timeout(Duration(seconds: 30)));

      test('gives up after max retries on persistent server errors',
          () async {
        when(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => serverErrorResponse);

        final result = await clearanceApi.clearWithRetry(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          certificate: testCertificate,
          maxRetries: 1,
        );

        expect(result.isCleared, isFalse);
        // maxRetries=1 means: initial call + 1 retry = 2 total
        verify(() => mockClient.clearInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).called(2);
      }, timeout: const Timeout(Duration(seconds: 30)));
    });
  });

  // ── ClearanceResult ─────────────────────────────────────

  group('ClearanceResult', () {
    test('isCleared is true with success and stamped XML', () {
      const result = ClearanceResult(
        response: clearedResponse,
        stampedXmlBase64: 'xml-content',
      );
      expect(result.isCleared, isTrue);
    });

    test('isCleared is false when stampedXmlBase64 is null', () {
      const result = ClearanceResult(
        response: clearedResponse,
      );
      expect(result.isCleared, isFalse);
    });

    test('isCleared is false on failed response', () {
      const result = ClearanceResult(
        response: rejectedResponse,
        stampedXmlBase64: 'xml',
      );
      expect(result.isCleared, isFalse);
    });

    test('exposes warnings from response', () {
      const result = ClearanceResult(
        response: clearedWithWarningsResponse,
        stampedXmlBase64: 'xml',
      );
      expect(result.warnings, hasLength(1));
      expect(result.warnings.first.type, 'WARNING');
    });

    test('exposes errors from response', () {
      const result = ClearanceResult(
        response: rejectedResponse,
      );
      expect(result.errors, hasLength(1));
      expect(result.errors.first.code, 'BR-17');
    });
  });
}
