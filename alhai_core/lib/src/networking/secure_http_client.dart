/// Secure HTTP Client with Certificate Pinning
///
/// Canonical location: alhai_core
/// Previously duplicated in alhai_auth and alhai_pos.
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
import '../config/whatsapp_config.dart';
import '../monitoring/production_logger.dart';

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
    //
    // Certificate pinning is only available on native platforms (Android/iOS).
    // On web, the browser handles TLS certificate validation and pinning
    // is not possible via the Dart HTTP client. This is a known Flutter limitation.
    // See: https://github.com/niclas9/ssl_pinning_plugin/issues/12
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

    // إضافة Interceptors للـ caching و logging والـ retry
    dio.interceptors.addAll([
      _CacheInterceptor(),
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

/// M88: HTTP Cache Interceptor with ETag/Last-Modified support
///
/// Caches GET responses that include ETag or Last-Modified headers.
/// On subsequent requests, sends conditional headers (If-None-Match,
/// If-Modified-Since). Returns cached data on 304 Not Modified.
/// Uses simple LRU eviction with a max of 100 entries.
class _CacheInterceptor extends Interceptor {
  final _cache = <String, _CacheEntry>{};
  static const _maxEntries = 100;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method != 'GET') return handler.next(options);
    final key = options.uri.toString();
    final entry = _cache[key];
    if (entry != null) {
      if (entry.etag != null) {
        options.headers['If-None-Match'] = entry.etag;
      }
      if (entry.lastModified != null) {
        options.headers['If-Modified-Since'] = entry.lastModified;
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method != 'GET') return handler.next(response);
    final key = response.requestOptions.uri.toString();
    final etag = response.headers.value('etag');
    final lastModified = response.headers.value('last-modified');
    if (etag != null || lastModified != null) {
      // LRU eviction: remove oldest entry when at capacity
      if (_cache.length >= _maxEntries) {
        _cache.remove(_cache.keys.first);
      }
      _cache[key] = _CacheEntry(
        etag: etag,
        lastModified: lastModified,
        data: response.data,
        statusCode: response.statusCode ?? 200,
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 304) {
      final key = err.requestOptions.uri.toString();
      final entry = _cache[key];
      if (entry != null) {
        return handler.resolve(Response<dynamic>(
          requestOptions: err.requestOptions,
          data: entry.data,
          statusCode: entry.statusCode,
        ));
      }
    }
    handler.next(err);
  }
}

/// Cache entry holding ETag/Last-Modified metadata and response data
class _CacheEntry {
  final String? etag;
  final String? lastModified;
  final dynamic data;
  final int statusCode;

  _CacheEntry({
    this.etag,
    this.lastModified,
    this.data,
    this.statusCode = 200,
  });
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
