/// CSRF Protection Service
///
/// يوفر حماية من هجمات Cross-Site Request Forgery عبر:
/// - إنشاء tokens عشوائية
/// - التحقق من صحة الـ tokens
/// - تحديث الـ tokens دورياً
library;

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// CSRF Token Manager
class CsrfProtection {
  CsrfProtection._();

  static String? _currentToken;
  static DateTime? _tokenCreatedAt;

  /// مدة صلاحية الـ token (15 دقيقة)
  static const Duration _tokenValidity = Duration(minutes: 15);

  /// طول الـ token بالـ bytes
  static const int _tokenLength = 32;

  /// إنشاء token جديد
  static String generateToken() {
    final random = Random.secure();
    final values = List<int>.generate(_tokenLength, (_) => random.nextInt(256));

    // إضافة timestamp للتفرد
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final combined = [...values, ...utf8.encode(timestamp)];

    // SHA-256 hash
    final digest = sha256.convert(combined);
    _currentToken = base64Url.encode(digest.bytes);
    _tokenCreatedAt = DateTime.now();

    if (kDebugMode) {
      debugPrint('🔐 CSRF Token generated (expires in ${_tokenValidity.inMinutes} min)');
    }

    return _currentToken!;
  }

  /// الحصول على الـ token الحالي أو إنشاء جديد
  static String getToken() {
    if (_currentToken == null || _isTokenExpired()) {
      return generateToken();
    }
    return _currentToken!;
  }

  /// التحقق من صحة token
  static bool validateToken(String token) {
    if (_currentToken == null) {
      if (kDebugMode) {
        debugPrint('⚠️ CSRF validation failed: No token stored');
      }
      return false;
    }

    if (_isTokenExpired()) {
      if (kDebugMode) {
        debugPrint('⚠️ CSRF validation failed: Token expired');
      }
      return false;
    }

    // مقارنة آمنة ضد timing attacks
    final isValid = _constantTimeEquals(token, _currentToken!);

    if (kDebugMode && !isValid) {
      debugPrint('⚠️ CSRF validation failed: Token mismatch');
    }

    return isValid;
  }

  /// هل انتهت صلاحية الـ token؟
  static bool _isTokenExpired() {
    if (_tokenCreatedAt == null) return true;
    return DateTime.now().difference(_tokenCreatedAt!) > _tokenValidity;
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

  /// إبطال الـ token الحالي
  static void invalidate() {
    _currentToken = null;
    _tokenCreatedAt = null;

    if (kDebugMode) {
      debugPrint('🔐 CSRF Token invalidated');
    }
  }

  /// الحصول على header للـ CSRF
  static Map<String, String> getHeaders() {
    return {
      'X-CSRF-Token': getToken(),
    };
  }
}

/// CSRF Validator Mixin للـ Services
mixin CsrfValidatorMixin {
  /// التحقق من CSRF token في الـ headers
  bool validateCsrfHeader(Map<String, String> headers) {
    final token = headers['X-CSRF-Token'] ?? headers['x-csrf-token'];
    if (token == null) {
      throw CsrfException('Missing CSRF token');
    }
    if (!CsrfProtection.validateToken(token)) {
      throw CsrfException('Invalid CSRF token');
    }
    return true;
  }
}

/// استثناء CSRF
class CsrfException implements Exception {
  final String message;

  CsrfException(this.message);

  @override
  String toString() => 'CsrfException: $message';
}
