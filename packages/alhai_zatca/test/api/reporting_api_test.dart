import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/api/reporting_api.dart';
import 'package:alhai_zatca/src/api/zatca_api_client.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';

class MockZatcaApiClient extends Mock implements ZatcaApiClient {}

class FakeCertificateInfo extends Fake implements CertificateInfo {}

void main() {
  late ReportingApi reportingApi;
  late MockZatcaApiClient mockClient;

  final testCertificate = CertificateInfo(
    certificatePem: 'cert',
    privateKeyPem: 'key',
    csid: 'csid',
    secret: 'secret',
    isProduction: true,
  );

  const successResponse = ZatcaResponse(
    isSuccess: true,
    statusCode: 200,
    reportingStatus: ReportingStatus.reported,
  );

  const warningResponse = ZatcaResponse(
    isSuccess: true,
    statusCode: 202,
    reportingStatus: ReportingStatus.reported,
    warnings: [
      ZatcaValidationResult(
        type: 'WARNING',
        code: 'BR-KSA-01',
        message: 'Minor formatting issue',
      ),
    ],
  );

  const rejectedResponse = ZatcaResponse(
    isSuccess: false,
    statusCode: 400,
    reportingStatus: ReportingStatus.rejected,
    errors: [
      ZatcaValidationResult(
        type: 'ERROR',
        code: 'BT-1',
        message: 'Invoice number invalid',
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(FakeCertificateInfo());
  });

  setUp(() {
    mockClient = MockZatcaApiClient();
    reportingApi = ReportingApi(client: mockClient);
  });

  group('ReportingApi', () {
    // ── reportInvoice ───────────────────────────────────

    group('reportInvoice', () {
      test('delegates to client and returns success response', () async {
        when(() => mockClient.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => successResponse);

        final result = await reportingApi.reportInvoice(
          signedXmlBase64: 'base64xml',
          invoiceHash: 'hash',
          uuid: 'uuid-1',
          certificate: testCertificate,
        );

        expect(result.isSuccess, isTrue);
        expect(result.reportingStatus, ReportingStatus.reported);
      });

      test('propagates rejection from ZATCA', () async {
        when(() => mockClient.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => rejectedResponse);

        final result = await reportingApi.reportInvoice(
          signedXmlBase64: 'base64xml',
          invoiceHash: 'hash',
          uuid: 'uuid-1',
          certificate: testCertificate,
        );

        expect(result.isSuccess, isFalse);
        expect(result.errors, isNotEmpty);
      });
    });

    // ── reportBatch ─────────────────────────────────────

    group('reportBatch', () {
      test('processes multiple invoices sequentially', () async {
        when(() => mockClient.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => successResponse);

        final requests = List.generate(
          3,
          (i) => ReportingRequest(
            signedXmlBase64: 'xml-$i',
            invoiceHash: 'hash-$i',
            uuid: 'uuid-$i',
          ),
        );

        final results = await reportingApi.reportBatch(
          requests: requests,
          certificate: testCertificate,
        );

        expect(results.length, 3);
        expect(results.every((r) => r.isSuccess), isTrue);
      });

      test('continues processing after individual failures', () async {
        var callCount = 0;
        when(() => mockClient.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async {
          callCount++;
          if (callCount == 2) throw Exception('Network error');
          return successResponse;
        });

        final requests = List.generate(
          3,
          (i) => ReportingRequest(
            signedXmlBase64: 'xml-$i',
            invoiceHash: 'hash-$i',
            uuid: 'uuid-$i',
          ),
        );

        final results = await reportingApi.reportBatch(
          requests: requests,
          certificate: testCertificate,
        );

        expect(results.length, 3);
        expect(results[0].isSuccess, isTrue);
        expect(results[1].isSuccess, isFalse);
        expect(results[2].isSuccess, isTrue);
      });

      test('returns empty list for empty request list', () async {
        final results = await reportingApi.reportBatch(
          requests: [],
          certificate: testCertificate,
        );

        expect(results, isEmpty);
      });
    });

    // ── reportBatchWithRetry ────────────────────────────

    group('reportBatchWithRetry', () {
      test('succeeds on first attempt without retry', () async {
        when(() => mockClient.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => successResponse);

        final results = await reportingApi.reportBatchWithRetry(
          requests: [
            const ReportingRequest(
              signedXmlBase64: 'xml',
              invoiceHash: 'hash',
              uuid: 'uuid',
            ),
          ],
          certificate: testCertificate,
          maxRetries: 3,
        );

        expect(results.length, 1);
        expect(results.first.isSuccess, isTrue);
        expect(results.first.wasRetried, isFalse);
      });

      test('does not retry 400 validation rejections', () async {
        when(() => mockClient.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => rejectedResponse);

        final results = await reportingApi.reportBatchWithRetry(
          requests: [
            const ReportingRequest(
              signedXmlBase64: 'xml',
              invoiceHash: 'hash',
              uuid: 'uuid',
            ),
          ],
          certificate: testCertificate,
          maxRetries: 3,
        );

        expect(results.first.isSuccess, isFalse);
        // Should only call once since 400 is not retried
        verify(() => mockClient.reportInvoice(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).called(1);
      });
    });
  });

  // ── ReportingRequest Model ────────────────────────────

  group('ReportingRequest', () {
    test('stores all required fields', () {
      const request = ReportingRequest(
        signedXmlBase64: 'xml-base64',
        invoiceHash: 'hash-value',
        uuid: 'uuid-value',
      );

      expect(request.signedXmlBase64, 'xml-base64');
      expect(request.invoiceHash, 'hash-value');
      expect(request.uuid, 'uuid-value');
    });
  });

  // ── ReportingResult Model ─────────────────────────────

  group('ReportingResult', () {
    test('isSuccess reflects response', () {
      const result = ReportingResult(
        request: ReportingRequest(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
        ),
        response: successResponse,
        attempts: 1,
      );

      expect(result.isSuccess, isTrue);
      expect(result.wasRetried, isFalse);
    });

    test('wasRetried is true when attempts > 1', () {
      const result = ReportingResult(
        request: ReportingRequest(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
        ),
        response: successResponse,
        attempts: 3,
      );

      expect(result.wasRetried, isTrue);
    });
  });
}
