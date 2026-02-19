/// Security Interceptor for Dio
///
/// يضيف طبقة أمان للطلبات HTTP:
/// - CSRF Protection
/// - Request Signing للـ APIs الحساسة
/// - Security Headers
library;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../security/csrf_protection.dart';
import '../security/request_signer.dart';

/// Security Interceptor
class SecurityInterceptor extends Interceptor {
  /// قائمة الـ paths التي تحتاج توقيع
  final List<String> signedPaths;

  /// قائمة الـ paths التي تحتاج CSRF
  final List<String> csrfProtectedPaths;

  /// هل CSRF مفعل؟
  final bool enableCsrf;

  /// هل التوقيع مفعل؟
  final bool enableSigning;

  SecurityInterceptor({
    this.signedPaths = const [
      '/sales',
      '/payments',
      '/refunds',
      '/inventory',
      '/users',
    ],
    this.csrfProtectedPaths = const [
      '/auth',
      '/settings',
      '/profile',
    ],
    this.enableCsrf = true,
    this.enableSigning = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // إضافة Security Headers الأساسية
    options.headers.addAll(_getSecurityHeaders());

    // إضافة CSRF token للـ paths المحمية
    if (enableCsrf && _needsCsrf(options)) {
      options.headers.addAll(CsrfProtection.getHeaders());
      if (kDebugMode) {
        debugPrint('🔐 CSRF token added to ${options.path}');
      }
    }

    // إضافة التوقيع للـ paths الحساسة
    if (enableSigning && RequestSigner.isInitialized && _needsSigning(options)) {
      final signature = RequestSigner.sign(
        method: options.method,
        path: options.path,
        body: options.data is Map ? options.data as Map<String, dynamic> : null,
        queryParams: options.queryParameters.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );
      options.headers.addAll(signature.toHeaders());
      if (kDebugMode) {
        debugPrint('🔐 Request signed: ${options.method} ${options.path}');
      }
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // التحقق من CSRF token في الـ response (إذا أرسل السيرفر token جديد)
    final newCsrfToken = response.headers.value('X-CSRF-Token');
    if (newCsrfToken != null && newCsrfToken.isNotEmpty) {
      // السيرفر أرسل token جديد - يمكن تحديثه هنا إذا لزم الأمر
      if (kDebugMode) {
        debugPrint('🔐 New CSRF token received from server');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // التعامل مع أخطاء CSRF
    if (err.response?.statusCode == 403) {
      final errorCode = err.response?.data?['code'];
      if (errorCode == 'CSRF_INVALID' || errorCode == 'CSRF_EXPIRED') {
        // إبطال الـ token الحالي وإنشاء جديد
        CsrfProtection.invalidate();
        CsrfProtection.generateToken();

        if (kDebugMode) {
          debugPrint('⚠️ CSRF token regenerated after 403 error');
        }
      }
    }

    // التعامل مع أخطاء التوقيع
    if (err.response?.statusCode == 401) {
      final errorCode = err.response?.data?['code'];
      if (errorCode == 'SIGNATURE_INVALID' || errorCode == 'SIGNATURE_EXPIRED') {
        if (kDebugMode) {
          debugPrint('⚠️ Request signature rejected by server');
        }
      }
    }

    handler.next(err);
  }

  /// هل الطلب يحتاج CSRF؟
  bool _needsCsrf(RequestOptions options) {
    // POST, PUT, DELETE, PATCH يحتاجون CSRF
    final methodsNeedingCsrf = ['POST', 'PUT', 'DELETE', 'PATCH'];
    if (!methodsNeedingCsrf.contains(options.method.toUpperCase())) {
      return false;
    }

    // التحقق من الـ path
    return csrfProtectedPaths.any((path) => options.path.startsWith(path));
  }

  /// هل الطلب يحتاج توقيع؟
  bool _needsSigning(RequestOptions options) {
    // جميع الـ methods ما عدا GET و HEAD
    final methodsNeedingSigning = ['POST', 'PUT', 'DELETE', 'PATCH'];
    if (!methodsNeedingSigning.contains(options.method.toUpperCase())) {
      return false;
    }

    // التحقق من الـ path
    return signedPaths.any((path) => options.path.startsWith(path));
  }

  /// Security Headers الأساسية
  Map<String, String> _getSecurityHeaders() {
    return {
      // منع الـ caching للطلبات الحساسة
      'Cache-Control': 'no-store, no-cache, must-revalidate',
      'Pragma': 'no-cache',

      // تحديد نوع المحتوى المقبول
      'Accept': 'application/json',

      // إضافة request ID للتتبع
      'X-Request-ID': _generateRequestId(),

      // إضافة client version للتوافق
      'X-Client-Version': '1.0.0',
    };
  }

  /// إنشاء Request ID للتتبع
  String _generateRequestId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.hashCode.abs() % 10000;
    return '$timestamp-$random';
  }
}

/// Extension لإضافة Security Interceptor للـ Dio
extension DioSecurityExtension on Dio {
  /// إضافة Security Interceptor
  void addSecurityInterceptor({
    List<String>? signedPaths,
    List<String>? csrfProtectedPaths,
    bool enableCsrf = true,
    bool enableSigning = true,
  }) {
    interceptors.add(SecurityInterceptor(
      signedPaths: signedPaths ?? const ['/sales', '/payments', '/refunds', '/inventory', '/users'],
      csrfProtectedPaths: csrfProtectedPaths ?? const ['/auth', '/settings', '/profile'],
      enableCsrf: enableCsrf,
      enableSigning: enableSigning,
    ));
  }
}
