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
import 'package:pos_app/core/config/whatsapp_config.dart';
import 'package:pos_app/core/monitoring/production_logger.dart';

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
    if (!kIsWeb) {
      if (certificateFingerprint != null && certificateFingerprint.isNotEmpty) {
        _applyCertificatePinning(dio, certificateFingerprint);
      } else if (kReleaseMode) {
        // في Release mode بدون fingerprint، نرفض الشهادات غير الموثوقة
        // بدلاً من قبولها جميعاً (CVE-mitigation)
        _rejectBadCertificates(dio);
      }
      // في Debug mode بدون fingerprint، نستخدم السلوك الافتراضي (permissive)
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
          AppLogger.error(
            'Certificate Pinning Failed! Host: $host:$port',
            tag: 'SSL',
          );
        }

        return isValid;
      };

      return client;
    };
  }

  /// رفض جميع الشهادات غير الموثوقة في Release mode
  /// عندما لا يتوفر fingerprint للـ pinning
  static void _rejectBadCertificates(Dio dio) {
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();

      client.badCertificateCallback = (cert, host, port) {
        // في Release mode بدون fingerprint مُعد، نرفض الشهادات غير الموثوقة
        AppLogger.warning(
          'SSL: Rejected untrusted certificate for $host:$port '
          '(no pinning fingerprint configured)',
          tag: 'SSL',
        );
        return false;
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
            final delayMs = 1000 * (1 << retryCount); // 1s, 2s, 4s
            await Future.delayed(
              Duration(milliseconds: delayMs),
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
        AppLogger.debug('REQUEST: ${options.method} ${options.uri}', tag: 'HTTP');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        AppLogger.debug(
          'RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          tag: 'HTTP',
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        AppLogger.error(
          'ERROR: ${error.type} ${error.requestOptions.uri} - ${error.message}',
          tag: 'HTTP',
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
  /// يستخدم WhatsAppConfig للحصول على الـ URL والـ headers
  static Dio createWaSenderClient() {
    return SecureHttpClient.create(
      baseUrl: WhatsAppConfig.baseUrl,
      headers: WhatsAppConfig.headers,
      certificateFingerprint: CertificateFingerprints.wasender,
    );
  }
}
