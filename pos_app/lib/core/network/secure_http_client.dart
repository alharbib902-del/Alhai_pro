/// Secure HTTP Client with Certificate Pinning
///
/// يوفر عميل HTTP آمن مع:
/// - Certificate Pinning
/// - Timeout handling
/// - Retry logic
/// - Error handling
library;

import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Certificate fingerprints للـ APIs المعتمدة
/// ⚠️ يجب تحديث هذه القيم عند تجديد الشهادات
class CertificateFingerprints {
  CertificateFingerprints._();

  /// Supabase API SHA-256 fingerprint
  /// احصل على fingerprint باستخدام:
  /// openssl s_client -connect your-project.supabase.co:443 | openssl x509 -fingerprint -sha256
  static const String supabase = String.fromEnvironment(
    'SUPABASE_CERT_FINGERPRINT',
    // لا يوجد defaultValue - سيتم التحقق في runtime
  );

  /// WaSender API SHA-256 fingerprint
  static const String wasender = String.fromEnvironment(
    'WASENDER_CERT_FINGERPRINT',
    // لا يوجد defaultValue
  );

  /// هل Certificate Pinning مفعل؟
  static bool get isEnabled =>
      supabase.isNotEmpty || wasender.isNotEmpty;
}

/// Secure Dio Client Factory
class SecureHttpClient {
  SecureHttpClient._();

  /// إنشاء Dio client آمن
  static Dio create({
    required String baseUrl,
    Duration connectTimeout = const Duration(seconds: 30),
    Duration receiveTimeout = const Duration(seconds: 30),
    Map<String, String>? headers,
    String? certificateFingerprint,
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: headers,
    ));

    // إضافة Certificate Pinning (للـ native platforms فقط)
    if (!kIsWeb && certificateFingerprint != null && certificateFingerprint.isNotEmpty) {
      _applyCertificatePinning(dio, certificateFingerprint);
    }

    // إضافة Interceptors للـ logging والـ retry
    dio.interceptors.addAll([
      _createRetryInterceptor(dio),
      if (kDebugMode) _createLoggingInterceptor(),
    ]);

    return dio;
  }

  /// تطبيق Certificate Pinning
  static void _applyCertificatePinning(Dio dio, String fingerprint) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();

      client.badCertificateCallback = (cert, host, port) {
        // الحصول على fingerprint الشهادة
        final certFingerprint = _getCertificateFingerprint(cert);

        // المقارنة مع الـ fingerprint المتوقع
        final isValid = certFingerprint.toLowerCase() ==
            fingerprint.toLowerCase().replaceAll(':', '');

        if (!isValid) {
          debugPrint(
            '⚠️ Certificate Pinning Failed!\n'
            'Host: $host:$port\n'
            'Expected: $fingerprint\n'
            'Got: $certFingerprint',
          );
        }

        return isValid;
      };

      return client;
    };
  }

  /// الحصول على fingerprint الشهادة
  /// يستخدم SHA-256 الآمن من crypto package
  static String _getCertificateFingerprint(X509Certificate cert) {
    // SHA-256 fingerprint باستخدام crypto package
    final digest = sha256.convert(cert.der);
    return digest.toString();
  }

  /// Interceptor للـ Retry
  static Interceptor _createRetryInterceptor(Dio dio) {
    return InterceptorsWrapper(
      onError: (error, handler) async {
        // Retry للأخطاء القابلة للإعادة
        if (_isRetryableError(error) && _getRetryCount(error) < 3) {
          try {
            // انتظار قبل إعادة المحاولة (exponential backoff)
            final retryCount = _getRetryCount(error);
            await Future.delayed(
              Duration(milliseconds: 1000 * (retryCount + 1)),
            );

            // إعادة المحاولة
            final options = error.requestOptions;
            options.extra['retryCount'] = retryCount + 1;

            final response = await dio.fetch(options);
            return handler.resolve(response);
          } catch (e) {
            return handler.next(error);
          }
        }
        return handler.next(error);
      },
    );
  }

  /// هل الخطأ قابل لإعادة المحاولة؟
  static bool _isRetryableError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        (error.response?.statusCode ?? 0) >= 500;
  }

  /// الحصول على عدد المحاولات
  static int _getRetryCount(DioException error) {
    return error.requestOptions.extra['retryCount'] as int? ?? 0;
  }

  /// Interceptor للـ Logging (Debug فقط)
  static Interceptor _createLoggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        debugPrint('🌐 REQUEST: ${options.method} ${options.uri}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint(
          '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        debugPrint(
          '❌ ERROR: ${error.type} ${error.requestOptions.uri}\n'
          'Message: ${error.message}',
        );
        return handler.next(error);
      },
    );
  }
}

/// Extension لإنشاء Dio clients للـ APIs المختلفة
extension SecureDioExtensions on SecureHttpClient {
  /// إنشاء Dio client لـ Supabase
  static Dio createSupabaseClient({
    required String baseUrl,
    required String apiKey,
  }) {
    return SecureHttpClient.create(
      baseUrl: baseUrl,
      headers: {
        'apikey': apiKey,
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      certificateFingerprint: CertificateFingerprints.supabase,
    );
  }

  /// إنشاء Dio client لـ WaSender
  static Dio createWaSenderClient({
    required String apiToken,
  }) {
    return SecureHttpClient.create(
      baseUrl: 'https://api.wasenderapi.com/api/v1',
      headers: {
        'Authorization': 'Bearer $apiToken',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      certificateFingerprint: CertificateFingerprints.wasender,
    );
  }
}
