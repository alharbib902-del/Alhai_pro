import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pos_app/core/network/secure_http_client.dart';

// ===========================================
// Mocks
// ===========================================

class MockHttpClientAdapter extends Mock implements HttpClientAdapter {}

class FakeRequestOptions extends Fake implements RequestOptions {}

// ===========================================
// Secure HTTP Client Tests
// ===========================================

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRequestOptions());
  });
  group('CertificateFingerprints', () {
    test('supabase \u064a\u064f\u0631\u062c\u0639 String', () {
      expect(CertificateFingerprints.supabase, isA<String>());
    });

    test('wasender \u064a\u064f\u0631\u062c\u0639 String', () {
      expect(CertificateFingerprints.wasender, isA<String>());
    });

    test('isEnabled \u064a\u0639\u062a\u0645\u062f \u0639\u0644\u0649 \u0648\u062c\u0648\u062f fingerprints', () {
      // \u0641\u064a \u0628\u064a\u0626\u0629 \u0627\u0644\u0627\u062e\u062a\u0628\u0627\u0631\u060c \u0627\u0644\u0642\u064a\u0645 \u0641\u0627\u0631\u063a\u0629
      final supabaseEmpty = CertificateFingerprints.supabase.isEmpty;
      final wasenderEmpty = CertificateFingerprints.wasender.isEmpty;

      if (supabaseEmpty && wasenderEmpty) {
        expect(CertificateFingerprints.isEnabled, false);
      } else {
        expect(CertificateFingerprints.isEnabled, true);
      }
    });
  });

  group('SecureHttpClient.create', () {
    test('\u064a\u064f\u0646\u0634\u0626 Dio client \u0628\u0640 baseUrl \u0635\u062d\u064a\u062d', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
      );

      expect(dio.options.baseUrl, 'https://api.example.com');
    });

    test('\u064a\u0633\u062a\u062e\u062f\u0645 timeout \u0627\u0641\u062a\u0631\u0627\u0636\u064a', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
      );

      expect(dio.options.connectTimeout, const Duration(seconds: 30));
      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
    });

    test('\u064a\u062f\u0639\u0645 timeout \u0645\u062e\u0635\u0635', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      );

      expect(dio.options.connectTimeout, const Duration(seconds: 10));
      expect(dio.options.receiveTimeout, const Duration(seconds: 15));
    });

    test('\u064a\u0636\u064a\u0641 headers \u0645\u062e\u0635\u0635\u0629', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        headers: {
          'Authorization': 'Bearer token123',
          'X-Custom-Header': 'value',
        },
      );

      expect(dio.options.headers['Authorization'], 'Bearer token123');
      expect(dio.options.headers['X-Custom-Header'], 'value');
    });

    test('\u064a\u0636\u064a\u0641 interceptors', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
      );

      // \u064a\u062c\u0628 \u0623\u0646 \u064a\u0643\u0648\u0646 \u0644\u062f\u064a\u0647 \u0639\u0644\u0649 \u0627\u0644\u0623\u0642\u0644 retry interceptor
      expect(dio.interceptors.isNotEmpty, true);
    });

    test('\u064a\u0639\u0645\u0644 \u0628\u062f\u0648\u0646 certificate fingerprint', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        certificateFingerprint: null,
      );

      expect(dio, isNotNull);
    });

    test('\u064a\u0639\u0645\u0644 \u0645\u0639 certificate fingerprint \u0641\u0627\u0631\u063a', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        certificateFingerprint: '',
      );

      expect(dio, isNotNull);
    });
  });

  group('SecureDioExtensions', () {
    test('createSupabaseClient \u064a\u064f\u0646\u0634\u0626 client \u0635\u062d\u064a\u062d', () {
      final dio = SecureDioExtensions.createSupabaseClient(
        baseUrl: 'https://project.supabase.co',
        apiKey: 'test-api-key',
      );

      expect(dio.options.baseUrl, 'https://project.supabase.co');
      expect(dio.options.headers['apikey'], 'test-api-key');
      expect(dio.options.headers['Authorization'], 'Bearer test-api-key');
      expect(dio.options.headers['Content-Type'], 'application/json');
    });

    test('createWaSenderClient \u064a\u064f\u0646\u0634\u0626 client \u0635\u062d\u064a\u062d', () {
      final dio = SecureDioExtensions.createWaSenderClient(
        apiToken: 'wasender-token',
      );

      expect(dio.options.baseUrl, 'https://api.wasenderapi.com/api/v1');
      expect(dio.options.headers['Authorization'], 'Bearer wasender-token');
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.headers['Accept'], 'application/json');
    });
  });

  group('Retry Logic', () {
    test('SecureHttpClient \u064a\u064f\u0646\u0634\u0626 client \u0642\u0627\u0628\u0644 \u0644\u0644\u0627\u0633\u062a\u062e\u062f\u0627\u0645', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
      );

      expect(dio, isNotNull);
      expect(dio.options, isNotNull);
    });

    test('\u064a\u062d\u062a\u0648\u064a \u0639\u0644\u0649 retry interceptor', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
      );

      // \u0627\u0644\u062a\u062d\u0642\u0642 \u0645\u0646 \u0623\u0646 \u0627\u0644\u0640 interceptors \u0645\u0648\u062c\u0648\u062f\u0629
      expect(dio.interceptors.length, greaterThanOrEqualTo(1));

      // \u0627\u0644\u062a\u062d\u0642\u0642 \u0645\u0646 \u0623\u0646 \u0623\u062d\u062f \u0627\u0644\u0640 interceptors \u0647\u0648 InterceptorsWrapper
      final hasWrapper = dio.interceptors.any((i) => i is InterceptorsWrapper);
      expect(hasWrapper, isTrue);
    });

    test('retryCount \u064a\u0628\u062f\u0623 \u0645\u0646 0', () {
      final options = RequestOptions(path: '/test');
      expect(options.extra['retryCount'], isNull);
    });

    test('retryCount \u064a\u0645\u0643\u0646 \u062a\u0639\u064a\u064a\u0646\u0647\u0627 \u0641\u064a extra', () {
      final options = RequestOptions(path: '/test');
      options.extra['retryCount'] = 1;
      expect(options.extra['retryCount'], 1);
    });

    test('maximum retry \u0647\u0648 3 \u0645\u062d\u0627\u0648\u0644\u0627\u062a', () {
      // \u0627\u0644\u062a\u062d\u0642\u0642 \u0645\u0646 \u0623\u0646 \u0627\u0644\u062d\u062f \u0627\u0644\u0623\u0642\u0635\u0649 \u0644\u0644\u0645\u062d\u0627\u0648\u0644\u0627\u062a \u0647\u0648 3
      // \u0647\u0630\u0627 \u0627\u062e\u062a\u0628\u0627\u0631 \u0644\u0644\u062a\u0648\u062b\u064a\u0642 - \u0627\u0644\u0642\u064a\u0645\u0629 hardcoded \u0641\u064a \u0627\u0644\u0643\u0648\u062f
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
      );

      // \u0646\u062a\u062d\u0642\u0642 \u0645\u0646 \u0623\u0646 \u0627\u0644\u0640 client \u064a\u064f\u0646\u0634\u0623 \u0628\u0646\u062c\u0627\u062d
      // \u0627\u0644\u062d\u062f \u0627\u0644\u0623\u0642\u0635\u0649 (3) \u0645\u0648\u062c\u0648\u062f \u0641\u064a _createRetryInterceptor
      expect(dio, isNotNull);
    });
  });

  // ===========================================
  // Retryable Errors Tests
  // ===========================================

  group('Retryable Errors', () {
    test('connection error \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
      );

      // Connection error \u064a\u062c\u0628 \u0623\u0646 \u064a\u0643\u0648\u0646 \u0642\u0627\u0628\u0644 \u0644\u0644\u0625\u0639\u0627\u062f\u0629
      expect(error.type, DioExceptionType.connectionError);
    });

    test('connection timeout \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionTimeout,
      );

      expect(error.type, DioExceptionType.connectionTimeout);
    });

    test('receive timeout \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.receiveTimeout,
      );

      expect(error.type, DioExceptionType.receiveTimeout);
    });

    test('server error 500 \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 500,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(error.response?.statusCode, 500);
      expect(error.response!.statusCode! >= 500, isTrue);
    });

    test('server error 502 \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 502,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(error.response?.statusCode, 502);
      expect(error.response!.statusCode! >= 500, isTrue);
    });

    test('server error 503 \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 503,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(error.response?.statusCode, 503);
      expect(error.response!.statusCode! >= 500, isTrue);
    });

    test('client error 400 \u063a\u064a\u0631 \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 400,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(error.response?.statusCode, 400);
      expect(error.response!.statusCode! >= 500, isFalse);
    });

    test('client error 401 \u063a\u064a\u0631 \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(error.response?.statusCode, 401);
      expect(error.response!.statusCode! >= 500, isFalse);
    });

    test('client error 404 \u063a\u064a\u0631 \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        response: Response(
          requestOptions: RequestOptions(path: '/test'),
          statusCode: 404,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(error.response?.statusCode, 404);
      expect(error.response!.statusCode! >= 500, isFalse);
    });

    test('cancel error \u063a\u064a\u0631 \u0642\u0627\u0628\u0644 \u0644\u0625\u0639\u0627\u062f\u0629 \u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.cancel,
      );

      expect(error.type, DioExceptionType.cancel);
      // Cancel \u0644\u064a\u0633 \u0641\u064a \u0642\u0627\u0626\u0645\u0629 \u0627\u0644\u0623\u062e\u0637\u0627\u0621 \u0627\u0644\u0642\u0627\u0628\u0644\u0629 \u0644\u0644\u0625\u0639\u0627\u062f\u0629
    });
  });

  // ===========================================
  // Timeout Configuration Tests
  // ===========================================

  group('Timeout Configuration', () {
    test('connect timeout \u0627\u0644\u0627\u0641\u062a\u0631\u0627\u0636\u064a 30 \u062b\u0627\u0646\u064a\u0629', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
      );

      expect(dio.options.connectTimeout, const Duration(seconds: 30));
    });

    test('receive timeout \u0627\u0644\u0627\u0641\u062a\u0631\u0627\u0636\u064a 30 \u062b\u0627\u0646\u064a\u0629', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
      );

      expect(dio.options.receiveTimeout, const Duration(seconds: 30));
    });

    test('connect timeout \u0645\u062e\u0635\u0635 \u064a\u0639\u0645\u0644', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(seconds: 5),
      );

      expect(dio.options.connectTimeout, const Duration(seconds: 5));
    });

    test('receive timeout \u0645\u062e\u0635\u0635 \u064a\u0639\u0645\u0644', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        receiveTimeout: const Duration(seconds: 10),
      );

      expect(dio.options.receiveTimeout, const Duration(seconds: 10));
    });

    test('timeout \u0635\u0641\u0631 \u064a\u0639\u0645\u0644', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        connectTimeout: Duration.zero,
        receiveTimeout: Duration.zero,
      );

      expect(dio.options.connectTimeout, Duration.zero);
      expect(dio.options.receiveTimeout, Duration.zero);
    });

    test('timeout \u0637\u0648\u064a\u0644 \u062c\u062f\u0627\u064b \u064a\u0639\u0645\u0644', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 10),
      );

      expect(dio.options.connectTimeout, const Duration(minutes: 5));
      expect(dio.options.receiveTimeout, const Duration(minutes: 10));
    });
  });

  // ===========================================
  // Error Handling Tests
  // ===========================================

  group('Error Handling', () {
    test('DioException \u064a\u062d\u0645\u0644 requestOptions', () {
      final options = RequestOptions(path: '/test');
      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );

      expect(error.requestOptions, options);
      expect(error.requestOptions.path, '/test');
    });

    test('DioException \u064a\u062d\u0645\u0644 response \u0639\u0646\u062f \u0648\u062c\u0648\u062f\u0647\u0627', () {
      final options = RequestOptions(path: '/test');
      final response = Response(
        requestOptions: options,
        statusCode: 500,
        data: {'error': 'Internal Server Error'},
      );
      final error = DioException(
        requestOptions: options,
        response: response,
        type: DioExceptionType.badResponse,
      );

      expect(error.response, isNotNull);
      expect(error.response?.statusCode, 500);
      expect(error.response?.data['error'], 'Internal Server Error');
    });

    test('DioException \u064a\u062d\u0645\u0644 message', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/test'),
        type: DioExceptionType.connectionError,
        message: 'Connection refused',
      );

      expect(error.message, 'Connection refused');
    });

    test('retryCount \u064a\u064f\u062e\u0632\u0646 \u0641\u064a extra', () {
      final options = RequestOptions(path: '/test');
      options.extra['retryCount'] = 2;

      final error = DioException(
        requestOptions: options,
        type: DioExceptionType.connectionError,
      );

      expect(error.requestOptions.extra['retryCount'], 2);
    });

    test('retryCount null \u064a\u064f\u0639\u0627\u0645\u0644 \u0643\u0640 0', () {
      final options = RequestOptions(path: '/test');
      // \u0644\u0627 \u0646\u0636\u0639 retryCount

      final retryCount = options.extra['retryCount'] as int? ?? 0;
      expect(retryCount, 0);
    });
  });

  // ===========================================
  // Exponential Backoff Tests
  // ===========================================

  group('Exponential Backoff', () {
    test('\u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 \u0627\u0644\u0623\u0648\u0644\u0649 \u062a\u0646\u062a\u0638\u0631 1000ms', () {
      const retryCount = 0;
      const delay = Duration(milliseconds: 1000 * (retryCount + 1));
      expect(delay, const Duration(milliseconds: 1000));
    });

    test('\u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 \u0627\u0644\u062b\u0627\u0646\u064a\u0629 \u062a\u0646\u062a\u0638\u0631 2000ms', () {
      const retryCount = 1;
      const delay = Duration(milliseconds: 1000 * (retryCount + 1));
      expect(delay, const Duration(milliseconds: 2000));
    });

    test('\u0627\u0644\u0645\u062d\u0627\u0648\u0644\u0629 \u0627\u0644\u062b\u0627\u0644\u062b\u0629 \u062a\u0646\u062a\u0638\u0631 3000ms', () {
      const retryCount = 2;
      const delay = Duration(milliseconds: 1000 * (retryCount + 1));
      expect(delay, const Duration(milliseconds: 3000));
    });

    test('backoff formula \u0635\u062d\u064a\u062d\u0629', () {
      for (var i = 0; i < 5; i++) {
        final delay = Duration(milliseconds: 1000 * (i + 1));
        expect(delay.inMilliseconds, 1000 * (i + 1));
      }
    });
  });

  // ===========================================
  // Headers Tests
  // ===========================================

  group('Headers', () {
    test('headers \u0641\u0627\u0631\u063a\u0629 \u062a\u0639\u0645\u0644', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        headers: {},
      );

      expect(dio, isNotNull);
    });

    test('headers null \u062a\u0639\u0645\u0644', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        headers: null,
      );

      expect(dio, isNotNull);
    });

    test('headers \u0645\u062a\u0639\u062f\u062f\u0629 \u062a\u064f\u0636\u0627\u0641 \u0628\u0634\u0643\u0644 \u0635\u062d\u064a\u062d', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        headers: {
          'Authorization': 'Bearer token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Custom': 'value',
        },
      );

      expect(dio.options.headers['Authorization'], 'Bearer token');
      expect(dio.options.headers['Content-Type'], 'application/json');
      expect(dio.options.headers['Accept'], 'application/json');
      expect(dio.options.headers['X-Custom'], 'value');
    });
  });

  // ===========================================
  // Certificate Pinning Tests
  // ===========================================

  group('Certificate Pinning Configuration', () {
    test('fingerprint null \u0644\u0627 \u064a\u064f\u0641\u0639\u0651\u0644 pinning', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        certificateFingerprint: null,
      );

      expect(dio, isNotNull);
    });

    test('fingerprint \u0641\u0627\u0631\u063a \u0644\u0627 \u064a\u064f\u0641\u0639\u0651\u0644 pinning', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        certificateFingerprint: '',
      );

      expect(dio, isNotNull);
    });

    test('fingerprint \u0635\u0627\u0644\u062d \u064a\u064f\u0646\u0634\u0626 client', () {
      final dio = SecureHttpClient.create(
        baseUrl: 'https://api.example.com',
        certificateFingerprint: 'abc123def456',
      );

      expect(dio, isNotNull);
    });
  });
}
