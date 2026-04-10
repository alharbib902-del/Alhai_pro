import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/api/compliance_api.dart';
import 'package:alhai_zatca/src/api/zatca_api_client.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';
import 'package:alhai_zatca/src/models/zatca_response.dart';

class MockZatcaApiClient extends Mock implements ZatcaApiClient {}

class FakeCertificateInfo extends Fake implements CertificateInfo {}

/// Helper to build a Dio Response
Response<dynamic> _buildResponse({
  required int statusCode,
  required Map<String, dynamic> data,
}) {
  return Response<dynamic>(
    requestOptions: RequestOptions(path: ''),
    statusCode: statusCode,
    data: data,
  );
}

void main() {
  late ComplianceApi complianceApi;
  late MockZatcaApiClient mockClient;

  const testCertificate = CertificateInfo(
    certificatePem: 'cert-pem',
    privateKeyPem: 'key-pem',
    csid: 'compliance-csid',
    secret: 'compliance-secret',
    isProduction: false,
  );

  const successInvoiceResponse = ZatcaResponse(
    isSuccess: true,
    statusCode: 200,
    reportingStatus: ReportingStatus.reported,
  );

  const rejectedInvoiceResponse = ZatcaResponse(
    isSuccess: false,
    statusCode: 400,
    reportingStatus: ReportingStatus.rejected,
    errors: [
      ZatcaValidationResult(
        type: 'ERROR',
        code: 'BR-16',
        message: 'Invalid line amount',
      ),
    ],
  );

  setUpAll(() {
    registerFallbackValue(FakeCertificateInfo());
  });

  setUp(() {
    mockClient = MockZatcaApiClient();
    complianceApi = ComplianceApi(client: mockClient);
  });

  group('ComplianceApi', () {
    // ── requestComplianceCsid ─────────────────────────────

    group('requestComplianceCsid', () {
      test('returns success response with csid and secret on 200', () async {
        when(() => mockClient.requestComplianceCsid(
              csrBase64: any(named: 'csrBase64'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => _buildResponse(
              statusCode: 200,
              data: <String, dynamic>{
                'binarySecurityToken': 'base64-token',
                'requestID': 'req-id-123',
                'secret': 'api-secret-xyz',
                'tokenType': 'http://docs.oasis-open.org/wss/2004/01/...',
              },
            ));

        final result = await complianceApi.requestComplianceCsid(
          csrBase64: 'csr-base64',
          otp: '123456',
        );

        expect(result.isSuccess, isTrue);
        expect(result.binarySecurityToken, 'base64-token');
        expect(result.csid, 'req-id-123');
        expect(result.secret, 'api-secret-xyz');
        expect(result.requestId, 'req-id-123');
        expect(result.errorMessage, isNull);
      });

      test('delegates csr and otp to client', () async {
        when(() => mockClient.requestComplianceCsid(
              csrBase64: any(named: 'csrBase64'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => _buildResponse(
              statusCode: 200,
              data: <String, dynamic>{
                'binarySecurityToken': 'tok',
                'requestID': 'id',
                'secret': 'sec',
              },
            ));

        await complianceApi.requestComplianceCsid(
          csrBase64: 'my-csr',
          otp: '987654',
        );

        verify(() => mockClient.requestComplianceCsid(
              csrBase64: 'my-csr',
              otp: '987654',
            )).called(1);
      });

      test('returns failure on non-200 status with error message', () async {
        when(() => mockClient.requestComplianceCsid(
              csrBase64: any(named: 'csrBase64'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => _buildResponse(
              statusCode: 400,
              data: <String, dynamic>{
                'message': 'Invalid OTP provided',
              },
            ));

        final result = await complianceApi.requestComplianceCsid(
          csrBase64: 'csr',
          otp: '000000',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, 'Invalid OTP provided');
        expect(result.csid, isNull);
      });

      test('extracts error from errors array when no top-level message',
          () async {
        when(() => mockClient.requestComplianceCsid(
              csrBase64: any(named: 'csrBase64'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => _buildResponse(
              statusCode: 400,
              data: <String, dynamic>{
                'errors': [
                  {'message': 'CSR validation failed'},
                  {'message': 'Invalid CSR signature'},
                ],
              },
            ));

        final result = await complianceApi.requestComplianceCsid(
          csrBase64: 'bad-csr',
          otp: '123456',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('CSR validation failed'));
        expect(result.errorMessage, contains('Invalid CSR signature'));
      });

      test('returns generic error when response has no message or errors',
          () async {
        when(() => mockClient.requestComplianceCsid(
              csrBase64: any(named: 'csrBase64'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => _buildResponse(
              statusCode: 500,
              data: <String, dynamic>{},
            ));

        final result = await complianceApi.requestComplianceCsid(
          csrBase64: 'csr',
          otp: '123456',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, 'Unknown compliance API error');
      });

      test('catches ZatcaApiException and returns failure', () async {
        when(() => mockClient.requestComplianceCsid(
              csrBase64: any(named: 'csrBase64'),
              otp: any(named: 'otp'),
            )).thenThrow(const ZatcaApiException(
          message: 'Network timeout',
          statusCode: 504,
        ));

        final result = await complianceApi.requestComplianceCsid(
          csrBase64: 'csr',
          otp: '123456',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, 'Network timeout');
      });

      test('catches unexpected exception and returns failure', () async {
        when(() => mockClient.requestComplianceCsid(
              csrBase64: any(named: 'csrBase64'),
              otp: any(named: 'otp'),
            )).thenThrow(Exception('Unexpected error'));

        final result = await complianceApi.requestComplianceCsid(
          csrBase64: 'csr',
          otp: '123456',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('Unexpected error'));
      });

      test('handles response with null data map gracefully', () async {
        when(() => mockClient.requestComplianceCsid(
              csrBase64: any(named: 'csrBase64'),
              otp: any(named: 'otp'),
            )).thenAnswer((_) async => Response<dynamic>(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
              data: null,
            ));

        final result = await complianceApi.requestComplianceCsid(
          csrBase64: 'csr',
          otp: '123456',
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, isNotNull);
      });
    });

    // ── submitComplianceInvoice ───────────────────────────

    group('submitComplianceInvoice', () {
      test('delegates to client.checkCompliance and returns success', () async {
        when(() => mockClient.checkCompliance(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => successInvoiceResponse);

        final result = await complianceApi.submitComplianceInvoice(
          signedXmlBase64: 'xml-base64',
          invoiceHash: 'hash-value',
          uuid: 'uuid-1',
          complianceCertificate: testCertificate,
        );

        expect(result.isSuccess, isTrue);
        expect(result.reportingStatus, ReportingStatus.reported);

        verify(() => mockClient.checkCompliance(
              signedXmlBase64: 'xml-base64',
              invoiceHash: 'hash-value',
              uuid: 'uuid-1',
              certificate: testCertificate,
            )).called(1);
      });

      test('propagates validation errors from ZATCA', () async {
        when(() => mockClient.checkCompliance(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => rejectedInvoiceResponse);

        final result = await complianceApi.submitComplianceInvoice(
          signedXmlBase64: 'bad-xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          complianceCertificate: testCertificate,
        );

        expect(result.isSuccess, isFalse);
        expect(result.errors, hasLength(1));
        expect(result.errors.first.code, 'BR-16');
      });

      test('propagates warnings on 202', () async {
        const warningResponse = ZatcaResponse(
          isSuccess: true,
          statusCode: 202,
          reportingStatus: ReportingStatus.reported,
          warnings: [
            ZatcaValidationResult(
              type: 'WARNING',
              code: 'W-05',
              message: 'Field should be optional',
            ),
          ],
        );

        when(() => mockClient.checkCompliance(
              signedXmlBase64: any(named: 'signedXmlBase64'),
              invoiceHash: any(named: 'invoiceHash'),
              uuid: any(named: 'uuid'),
              certificate: any(named: 'certificate'),
            )).thenAnswer((_) async => warningResponse);

        final result = await complianceApi.submitComplianceInvoice(
          signedXmlBase64: 'xml',
          invoiceHash: 'hash',
          uuid: 'uuid',
          complianceCertificate: testCertificate,
        );

        expect(result.isSuccess, isTrue);
        expect(result.statusCode, 202);
        expect(result.warnings, isNotEmpty);
      });
    });

    // ── requestProductionCsid ─────────────────────────────

    group('requestProductionCsid', () {
      test('returns success with production token on 200', () async {
        when(() => mockClient.requestProductionCsid(
              complianceRequestId: any(named: 'complianceRequestId'),
              complianceCertificate: any(named: 'complianceCertificate'),
            )).thenAnswer((_) async => _buildResponse(
              statusCode: 200,
              data: <String, dynamic>{
                'binarySecurityToken': 'prod-token-base64',
                'requestID': 'prod-req-id',
                'secret': 'prod-secret',
              },
            ));

        final result = await complianceApi.requestProductionCsid(
          complianceCsid: 'compliance-id-42',
          complianceCertificate: testCertificate,
        );

        expect(result.isSuccess, isTrue);
        expect(result.binarySecurityToken, 'prod-token-base64');
        expect(result.csid, 'prod-req-id');
        expect(result.secret, 'prod-secret');
        expect(result.requestId, 'prod-req-id');
      });

      test('passes compliance id and certificate to client', () async {
        when(() => mockClient.requestProductionCsid(
              complianceRequestId: any(named: 'complianceRequestId'),
              complianceCertificate: any(named: 'complianceCertificate'),
            )).thenAnswer((_) async => _buildResponse(
              statusCode: 200,
              data: <String, dynamic>{
                'binarySecurityToken': 't',
                'requestID': 'r',
                'secret': 's',
              },
            ));

        await complianceApi.requestProductionCsid(
          complianceCsid: 'my-compliance-id',
          complianceCertificate: testCertificate,
        );

        verify(() => mockClient.requestProductionCsid(
              complianceRequestId: 'my-compliance-id',
              complianceCertificate: testCertificate,
            )).called(1);
      });

      test('returns failure on non-200 with error message', () async {
        when(() => mockClient.requestProductionCsid(
              complianceRequestId: any(named: 'complianceRequestId'),
              complianceCertificate: any(named: 'complianceCertificate'),
            )).thenAnswer((_) async => _buildResponse(
              statusCode: 403,
              data: <String, dynamic>{
                'message': 'Compliance checks not complete',
              },
            ));

        final result = await complianceApi.requestProductionCsid(
          complianceCsid: 'incomplete-id',
          complianceCertificate: testCertificate,
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, 'Compliance checks not complete');
      });

      test('catches ZatcaApiException and returns failure', () async {
        when(() => mockClient.requestProductionCsid(
              complianceRequestId: any(named: 'complianceRequestId'),
              complianceCertificate: any(named: 'complianceCertificate'),
            )).thenThrow(const ZatcaApiException(
          message: 'Server unavailable',
          statusCode: 503,
        ));

        final result = await complianceApi.requestProductionCsid(
          complianceCsid: 'id',
          complianceCertificate: testCertificate,
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, 'Server unavailable');
      });

      test('catches generic exception and returns descriptive error', () async {
        when(() => mockClient.requestProductionCsid(
              complianceRequestId: any(named: 'complianceRequestId'),
              complianceCertificate: any(named: 'complianceCertificate'),
            )).thenThrow(StateError('unexpected state'));

        final result = await complianceApi.requestProductionCsid(
          complianceCsid: 'id',
          complianceCertificate: testCertificate,
        );

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('unexpected state'));
      });
    });
  });

  // ── ComplianceCsidResponse ──────────────────────────────

  group('ComplianceCsidResponse', () {
    test('stores all fields correctly', () {
      const response = ComplianceCsidResponse(
        isSuccess: true,
        binarySecurityToken: 'token',
        csid: 'csid-val',
        secret: 'secret-val',
        requestId: 'req-id-val',
      );

      expect(response.isSuccess, isTrue);
      expect(response.binarySecurityToken, 'token');
      expect(response.csid, 'csid-val');
      expect(response.secret, 'secret-val');
      expect(response.requestId, 'req-id-val');
      expect(response.errorMessage, isNull);
    });

    test('failure response has error message', () {
      const response = ComplianceCsidResponse(
        isSuccess: false,
        errorMessage: 'Failed',
      );

      expect(response.isSuccess, isFalse);
      expect(response.errorMessage, 'Failed');
      expect(response.csid, isNull);
    });
  });

  // ── ProductionCsidResponse ──────────────────────────────

  group('ProductionCsidResponse', () {
    test('stores all fields correctly', () {
      const response = ProductionCsidResponse(
        isSuccess: true,
        binarySecurityToken: 'prod-token',
        csid: 'prod-csid',
        secret: 'prod-secret',
        requestId: 'prod-req',
      );

      expect(response.isSuccess, isTrue);
      expect(response.binarySecurityToken, 'prod-token');
      expect(response.csid, 'prod-csid');
      expect(response.secret, 'prod-secret');
      expect(response.requestId, 'prod-req');
    });

    test('failure response has error message only', () {
      const response = ProductionCsidResponse(
        isSuccess: false,
        errorMessage: 'Rejected',
      );

      expect(response.isSuccess, isFalse);
      expect(response.errorMessage, 'Rejected');
      expect(response.csid, isNull);
      expect(response.secret, isNull);
    });
  });
}
