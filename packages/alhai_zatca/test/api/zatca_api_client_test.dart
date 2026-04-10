import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:alhai_zatca/src/api/zatca_api_client.dart';
import 'package:alhai_zatca/src/api/zatca_endpoints.dart';
import 'package:alhai_zatca/src/models/certificate_info.dart';
import 'package:alhai_zatca/src/models/reporting_status.dart';

class MockDio extends Mock implements Dio {}

class FakeOptions extends Fake implements Options {}

class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late MockDio mockDio;
  late ZatcaApiClient client;

  const testCertificate = CertificateInfo(
    certificatePem: 'cert-pem',
    privateKeyPem: 'key-pem',
    csid: 'test-csid',
    secret: 'test-secret',
    isProduction: false,
  );

  // Dio's default options must be non-null; mock this out.
  final defaultBaseOptions = BaseOptions(
    headers: <String, dynamic>{},
  );

  setUpAll(() {
    registerFallbackValue(FakeOptions());
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    mockDio = MockDio();
    // The ZatcaApiClient constructor mutates dio.options.headers
    // and sets timeouts, so we need a real BaseOptions on the mock.
    when(() => mockDio.options).thenReturn(defaultBaseOptions);
    client = ZatcaApiClient(
      environment: ZatcaEnvironment.sandbox,
      dio: mockDio,
    );
  });

  // ── Construction ─────────────────────────────────────────

  group('ZatcaApiClient construction', () {
    test('sets Accept-Language header to "ar"', () {
      expect(defaultBaseOptions.headers['Accept-Language'], 'ar');
    });

    test('sets Content-Type header to application/json', () {
      expect(defaultBaseOptions.headers['Content-Type'], 'application/json');
    });

    test('sets Accept-Version header to V2', () {
      expect(defaultBaseOptions.headers['Accept-Version'], 'V2');
    });

    test('exposes the current environment', () {
      expect(client.environment, ZatcaEnvironment.sandbox);
    });

    test('exposes the underlying Dio instance', () {
      expect(client.dio, same(mockDio));
    });

    test('supports production environment', () {
      final prodOptions = BaseOptions(headers: <String, dynamic>{});
      final prodDio = MockDio();
      when(() => prodDio.options).thenReturn(prodOptions);

      final prodClient = ZatcaApiClient(
        environment: ZatcaEnvironment.production,
        dio: prodDio,
      );

      expect(prodClient.environment, ZatcaEnvironment.production);
    });

    test('supports simulation environment', () {
      final simOptions = BaseOptions(headers: <String, dynamic>{});
      final simDio = MockDio();
      when(() => simDio.options).thenReturn(simOptions);

      final simClient = ZatcaApiClient(
        environment: ZatcaEnvironment.simulation,
        dio: simDio,
      );

      expect(simClient.environment, ZatcaEnvironment.simulation);
    });
  });

  // ── reportInvoice ────────────────────────────────────────

  group('reportInvoice', () {
    test('sends POST to reporting endpoint with correct URL', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{},
          ));

      await client.reportInvoice(
        signedXmlBase64: 'base64xml',
        invoiceHash: 'hash',
        uuid: 'uuid-1',
        certificate: testCertificate,
      );

      final captured = verify(() => mockDio.post(
            captureAny(),
            data: captureAny(named: 'data'),
            options: captureAny(named: 'options'),
          )).captured;

      final url = captured[0] as String;
      expect(url, contains(ZatcaEndpoints.reporting));
      expect(url, contains(ZatcaEndpoints.sandboxBase));
    });

    test('sends request body with invoiceHash, uuid, and invoice', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{},
          ));

      await client.reportInvoice(
        signedXmlBase64: 'xml-base64',
        invoiceHash: 'hash-value',
        uuid: 'uuid-value',
        certificate: testCertificate,
      );

      final captured = verify(() => mockDio.post(
            any(),
            data: captureAny(named: 'data'),
            options: any(named: 'options'),
          )).captured;

      final body = captured.first as Map<String, dynamic>;
      expect(body['invoiceHash'], 'hash-value');
      expect(body['uuid'], 'uuid-value');
      expect(body['invoice'], 'xml-base64');
    });

    test('includes Basic auth header built from csid and secret', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{},
          ));

      await client.reportInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      final captured = verify(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: captureAny(named: 'options'),
          )).captured;

      final options = captured.first as Options;
      final auth = options.headers!['Authorization'] as String;
      expect(auth, startsWith('Basic '));
      // Basic dGVzdC1jc2lkOnRlc3Qtc2VjcmV0 == base64('test-csid:test-secret')
      expect(auth, 'Basic dGVzdC1jc2lkOnRlc3Qtc2VjcmV0');
    });

    test('returns success response on 200', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{},
          ));

      final response = await client.reportInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      expect(response.isSuccess, isTrue);
      expect(response.statusCode, 200);
      expect(response.reportingStatus, ReportingStatus.reported);
    });

    test('returns success response on 202 (accepted with warnings)', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 202,
            data: <String, dynamic>{
              'validationResults': {
                'warningMessages': [
                  {
                    'type': 'WARNING',
                    'code': 'W-01',
                    'message': 'Minor warning',
                  },
                ],
                'errorMessages': [],
              },
            },
          ));

      final response = await client.reportInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      expect(response.isSuccess, isTrue);
      expect(response.statusCode, 202);
      expect(response.warnings, isNotEmpty);
      expect(response.warnings.first.code, 'W-01');
    });

    test('parses 400 validation rejection with error messages', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 400,
            data: <String, dynamic>{
              'validationResults': {
                'warningMessages': [],
                'errorMessages': [
                  {
                    'type': 'ERROR',
                    'code': 'BR-01',
                    'message': 'Invoice number missing',
                  },
                ],
              },
            },
          ));

      final response = await client.reportInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      expect(response.isSuccess, isFalse);
      expect(response.statusCode, 400);
      expect(response.reportingStatus, ReportingStatus.rejected);
      expect(response.errors, hasLength(1));
      expect(response.errors.first.code, 'BR-01');
    });

    test('converts 500 DioException to failure response', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
          statusMessage: 'Internal Server Error',
        ),
      ));

      final response = await client.reportInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      expect(response.isSuccess, isFalse);
      expect(response.statusCode, 500);
      expect(response.errors.first.message, contains('500'));
    });

    test('handles connection timeout', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      ));

      final response = await client.reportInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      expect(response.isSuccess, isFalse);
      expect(response.errors.first.message.toLowerCase(), contains('timeout'));
    });

    test('handles receive timeout', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.receiveTimeout,
      ));

      final response = await client.reportInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      expect(response.isSuccess, isFalse);
      expect(response.errors.first.message.toLowerCase(), contains('timeout'));
    });

    test('handles connection error (network unreachable)', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ));

      final response = await client.reportInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      expect(response.isSuccess, isFalse);
      expect(response.errors.first.message.toLowerCase(), contains('connect'));
    });

    test('handles non-map JSON response gracefully', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            // Unexpected shape: list instead of map
            data: <dynamic>['unexpected'],
          ));

      final response = await client.reportInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      // Should not throw; falls back to empty map parsing
      expect(response.statusCode, 200);
      expect(response.isSuccess, isTrue);
    });
  });

  // ── clearInvoice ─────────────────────────────────────────

  group('clearInvoice', () {
    test('sends POST to clearance endpoint with Clearance-Status header',
        () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{
              'clearedInvoice': 'stamped-xml-base64',
            },
          ));

      await client.clearInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      final captured = verify(() => mockDio.post(
            captureAny(),
            data: any(named: 'data'),
            options: captureAny(named: 'options'),
          )).captured;

      final url = captured[0] as String;
      final options = captured[1] as Options;
      expect(url, contains(ZatcaEndpoints.clearance));
      expect(options.headers!['Clearance-Status'], '1');
    });

    test('returns clearedInvoice XML on success', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{
              'clearedInvoice': 'base64-stamped-xml',
              'clearanceStatus': 'CLEARED',
            },
          ));

      final response = await client.clearInvoice(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      expect(response.isSuccess, isTrue);
      expect(response.clearedInvoiceXml, 'base64-stamped-xml');
      expect(response.clearanceStatus, 'CLEARED');
    });
  });

  // ── checkCompliance ──────────────────────────────────────

  group('checkCompliance', () {
    test('sends POST to compliance check endpoint', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{},
          ));

      await client.checkCompliance(
        signedXmlBase64: 'xml',
        invoiceHash: 'hash',
        uuid: 'uuid',
        certificate: testCertificate,
      );

      final captured = verify(() => mockDio.post(
            captureAny(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).captured;

      expect(captured.first, contains(ZatcaEndpoints.complianceCheck));
    });
  });

  // ── requestComplianceCsid ────────────────────────────────

  group('requestComplianceCsid', () {
    test('sends POST with OTP header and csr in body', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{
              'binarySecurityToken': 'token',
              'requestID': 'req-id',
              'secret': 'secret',
            },
          ));

      final response = await client.requestComplianceCsid(
        csrBase64: 'csr-data',
        otp: '123456',
      );

      expect(response.statusCode, 200);

      final captured = verify(() => mockDio.post(
            captureAny(),
            data: captureAny(named: 'data'),
            options: captureAny(named: 'options'),
          )).captured;

      final url = captured[0] as String;
      final body = captured[1] as Map<String, dynamic>;
      final options = captured[2] as Options;

      expect(url, contains(ZatcaEndpoints.complianceCsid));
      expect(body['csr'], 'csr-data');
      expect(options.headers!['OTP'], '123456');
    });

    test('throws ZatcaApiException on DioException', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'message': 'Invalid OTP'},
        ),
        message: 'Bad request',
      ));

      expect(
        () => client.requestComplianceCsid(csrBase64: 'csr', otp: '000000'),
        throwsA(isA<ZatcaApiException>()
            .having((e) => e.statusCode, 'statusCode', 400)),
      );
    });
  });

  // ── requestProductionCsid ────────────────────────────────

  group('requestProductionCsid', () {
    test('sends POST with compliance_request_id in body', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{
              'binarySecurityToken': 'prod-token',
              'requestID': 'prod-req-id',
              'secret': 'prod-secret',
            },
          ));

      await client.requestProductionCsid(
        complianceRequestId: 'compliance-id-123',
        complianceCertificate: testCertificate,
      );

      final captured = verify(() => mockDio.post(
            captureAny(),
            data: captureAny(named: 'data'),
            options: captureAny(named: 'options'),
          )).captured;

      final url = captured[0] as String;
      final body = captured[1] as Map<String, dynamic>;
      final options = captured[2] as Options;

      expect(url, contains(ZatcaEndpoints.productionCsid));
      expect(body['compliance_request_id'], 'compliance-id-123');
      expect(options.headers!['Authorization'], startsWith('Basic '));
    });

    test('throws ZatcaApiException on server error', () async {
      when(() => mockDio.post(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 500,
        ),
        message: 'Server down',
      ));

      expect(
        () => client.requestProductionCsid(
          complianceRequestId: 'id',
          complianceCertificate: testCertificate,
        ),
        throwsA(isA<ZatcaApiException>()),
      );
    });
  });

  // ── renewProductionCsid ──────────────────────────────────

  group('renewProductionCsid', () {
    test('sends PATCH with csr, OTP, and Basic auth', () async {
      when(() => mockDio.patch(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
            data: <String, dynamic>{
              'binarySecurityToken': 'renewed-token',
              'requestID': 'renewed-id',
              'secret': 'renewed-secret',
            },
          ));

      final response = await client.renewProductionCsid(
        csrBase64: 'new-csr',
        otp: '999999',
        currentCertificate: testCertificate,
      );

      expect(response.statusCode, 200);

      final captured = verify(() => mockDio.patch(
            captureAny(),
            data: captureAny(named: 'data'),
            options: captureAny(named: 'options'),
          )).captured;

      final url = captured[0] as String;
      final body = captured[1] as Map<String, dynamic>;
      final options = captured[2] as Options;

      expect(url, contains(ZatcaEndpoints.renewProductionCsid));
      expect(body['csr'], 'new-csr');
      expect(options.headers!['OTP'], '999999');
      expect(options.headers!['Authorization'], startsWith('Basic '));
    });

    test('throws ZatcaApiException on DioException', () async {
      when(() => mockDio.patch(
            any(),
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
        message: 'Timeout',
      ));

      expect(
        () => client.renewProductionCsid(
          csrBase64: 'csr',
          otp: 'otp',
          currentCertificate: testCertificate,
        ),
        throwsA(isA<ZatcaApiException>()),
      );
    });
  });

  // ── ZatcaApiException ────────────────────────────────────

  group('ZatcaApiException', () {
    test('stores message and status code', () {
      const ex = ZatcaApiException(
        message: 'Something went wrong',
        statusCode: 500,
        responseData: {'error': 'server'},
      );

      expect(ex.message, 'Something went wrong');
      expect(ex.statusCode, 500);
      expect(ex.responseData, isA<Map<String, dynamic>>());
    });

    test('toString includes status code and message', () {
      const ex = ZatcaApiException(
        message: 'Auth failed',
        statusCode: 401,
      );
      expect(ex.toString(), 'ZatcaApiException(401): Auth failed');
    });

    test('is an Exception', () {
      const ex = ZatcaApiException(message: 'error');
      expect(ex, isA<Exception>());
    });
  });
}
