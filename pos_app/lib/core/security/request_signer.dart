/// Request Signing Service
///
/// يوفر توقيع رقمي للطلبات الحساسة لمنع التلاعب:
/// - HMAC-SHA256 للتوقيع
/// - Timestamp للحماية من replay attacks
/// - Nonce للتفرد
library;

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:pos_app/core/monitoring/production_logger.dart';

/// Request Signer للـ APIs الحساسة
class RequestSigner {
  RequestSigner._();

  /// مفتاح التوقيع (يجب تخزينه بشكل آمن)
  /// ⚠️ في Production، احصل على المفتاح من Secure Storage
  static String? _signingKey;

  /// تهيئة المفتاح
  static void initialize(String key) {
    _signingKey = key;
    AppLogger.debug('Request Signer initialized', tag: 'RequestSigner');
  }

  /// هل المفتاح مهيأ؟
  static bool get isInitialized => _signingKey != null && _signingKey!.isNotEmpty;

  /// إنشاء nonce عشوائي
  static String _generateNonce() {
    final random = Random.secure();
    final values = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }

  /// توقيع الطلب
  static RequestSignature sign({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) {
    if (!isInitialized) {
      throw SigningException('Request Signer not initialized');
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final nonce = _generateNonce();

    // بناء الـ payload للتوقيع
    final payload = _buildSignaturePayload(
      method: method,
      path: path,
      timestamp: timestamp,
      nonce: nonce,
      body: body,
      queryParams: queryParams,
    );

    // HMAC-SHA256 signature
    final hmac = Hmac(sha256, utf8.encode(_signingKey!));
    final digest = hmac.convert(utf8.encode(payload));
    final signature = base64Url.encode(digest.bytes);

    AppLogger.debug('Request signed: $method $path', tag: 'RequestSigner');

    return RequestSignature(
      signature: signature,
      timestamp: timestamp,
      nonce: nonce,
    );
  }

  /// بناء الـ payload للتوقيع
  static String _buildSignaturePayload({
    required String method,
    required String path,
    required int timestamp,
    required String nonce,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
  }) {
    final parts = <String>[
      method.toUpperCase(),
      path,
      timestamp.toString(),
      nonce,
    ];

    // إضافة query params مرتبة
    if (queryParams != null && queryParams.isNotEmpty) {
      final sortedParams = queryParams.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      parts.add(sortedParams.map((e) => '${e.key}=${e.value}').join('&'));
    }

    // إضافة body hash
    if (body != null && body.isNotEmpty) {
      final bodyJson = jsonEncode(body);
      final bodyHash = sha256.convert(utf8.encode(bodyJson));
      parts.add(bodyHash.toString());
    }

    return parts.join('\n');
  }

  /// التحقق من التوقيع
  static bool verify({
    required String signature,
    required int timestamp,
    required String nonce,
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Duration maxAge = const Duration(minutes: 5),
  }) {
    if (!isInitialized) {
      throw SigningException('Request Signer not initialized');
    }

    // التحقق من الـ timestamp
    final now = DateTime.now().millisecondsSinceEpoch;
    if ((now - timestamp).abs() > maxAge.inMilliseconds) {
      AppLogger.warning('Signature verification failed: Request too old', tag: 'RequestSigner');
      return false;
    }

    // إعادة حساب التوقيع
    final expectedPayload = _buildSignaturePayload(
      method: method,
      path: path,
      timestamp: timestamp,
      nonce: nonce,
      body: body,
      queryParams: queryParams,
    );

    final hmac = Hmac(sha256, utf8.encode(_signingKey!));
    final expectedDigest = hmac.convert(utf8.encode(expectedPayload));
    final expectedSignature = base64Url.encode(expectedDigest.bytes);

    // مقارنة آمنة
    final isValid = _constantTimeEquals(signature, expectedSignature);

    if (!isValid) {
      AppLogger.warning('Signature verification failed: Signature mismatch', tag: 'RequestSigner');
    }

    return isValid;
  }

  /// مقارنة آمنة ضد timing attacks
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// الحصول على headers للتوقيع
  static Map<String, String> getSignatureHeaders(RequestSignature sig) {
    return {
      'X-Signature': sig.signature,
      'X-Timestamp': sig.timestamp.toString(),
      'X-Nonce': sig.nonce,
    };
  }
}

/// نتيجة التوقيع
class RequestSignature {
  final String signature;
  final int timestamp;
  final String nonce;

  RequestSignature({
    required this.signature,
    required this.timestamp,
    required this.nonce,
  });

  Map<String, String> toHeaders() => {
    'X-Signature': signature,
    'X-Timestamp': timestamp.toString(),
    'X-Nonce': nonce,
  };
}

/// استثناء التوقيع
class SigningException implements Exception {
  final String message;

  SigningException(this.message);

  @override
  String toString() => 'SigningException: $message';
}

/// Signed Request Mixin للـ Services
mixin SignedRequestMixin {
  /// إضافة التوقيع للـ headers
  Map<String, String> signRequest({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? queryParams,
    Map<String, String>? existingHeaders,
  }) {
    final headers = <String, String>{};

    if (existingHeaders != null) {
      headers.addAll(existingHeaders);
    }

    if (RequestSigner.isInitialized) {
      final signature = RequestSigner.sign(
        method: method,
        path: path,
        body: body,
        queryParams: queryParams,
      );
      headers.addAll(signature.toHeaders());
    }

    return headers;
  }
}
