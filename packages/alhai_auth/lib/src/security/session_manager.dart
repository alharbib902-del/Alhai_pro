/// مدير الجلسات - Session Manager
///
/// يدير جلسات المستخدم مع timeout تلقائي وتجديد التوكن
/// يستخدم cache في الذاكرة للسرعة ⚡
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

// ============================================================================
// SESSION STATUS
// ============================================================================

/// حالة الجلسة
enum SessionStatus {
  /// الجلسة صالحة
  valid,

  /// تحتاج تجديد
  needsRefresh,

  /// منتهية
  expired,

  /// غير مصادق
  notAuthenticated,
}

// ============================================================================
// SESSION MANAGER
// ============================================================================

/// مدير الجلسات
class SessionManager {
  static const sessionDuration = Duration(minutes: 30);
  static const tokenRefreshBuffer = Duration(minutes: 5);

  static Timer? _sessionTimer;
  static VoidCallback? _onExpiredCallback;

  // ============================================================================
  // MEMORY CACHE للسرعة ⚡
  // ============================================================================
  static bool _cacheInitialized = false;
  static String? _cachedAccessToken;
  static DateTime? _cachedExpiry;

  // ============================================================================
  // SESSION LIFECYCLE
  // ============================================================================

  /// بدء جلسة جديدة
  static Future<void> startSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String storeId,
  }) async {
    final expiry = DateTime.now().add(sessionDuration);

    // تحديث الـ cache فوراً ⚡
    _cachedAccessToken = accessToken;
    _cachedExpiry = expiry;
    _cacheInitialized = true;

    await SecureStorageService.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiry: expiry,
    );

    await SecureStorageService.saveUserData(userId: userId, storeId: storeId);
  }

  /// تجديد الجلسة
  static Future<bool> refreshSession({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      final expiry = DateTime.now().add(sessionDuration);

      await SecureStorageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiry: expiry,
      );

      // تحديث الـ cache فوراً ⚡ (مطابقة لسلوك startSession)
      _cachedAccessToken = accessToken;
      _cachedExpiry = expiry;
      _cacheInitialized = true;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// إنهاء الجلسة
  static Future<void> endSession() async {
    // مسح الـ cache فوراً ⚡
    _cachedAccessToken = null;
    _cachedExpiry = null;
    _cacheInitialized = true; // نحتفظ بـ initialized لنعرف أن الجلسة انتهت

    stopSessionMonitor();
    await SecureStorageService.clearSession();
  }

  // ============================================================================
  // SESSION STATUS
  // ============================================================================

  /// التحقق من حالة الجلسة - محسّن للسرعة مع cache ⚡
  static Future<SessionStatus> checkSession() async {
    String? accessToken;
    DateTime? expiry;

    // استخدام الـ cache إذا كان جاهزاً (فوري!) ⚡
    if (_cacheInitialized) {
      accessToken = _cachedAccessToken;
      expiry = _cachedExpiry;
    } else {
      // أول مرة: قراءة من التخزين وتحديث الـ cache
      final results = await Future.wait([
        SecureStorageService.getAccessToken(),
        SecureStorageService.getSessionExpiry(),
      ]);

      accessToken = results[0] as String?;
      expiry = results[1] as DateTime?;

      // تحديث الـ cache
      _cachedAccessToken = accessToken;
      _cachedExpiry = expiry;
      _cacheInitialized = true;
    }

    // لا يوجد token
    if (accessToken == null) {
      return SessionStatus.notAuthenticated;
    }

    // التحقق من الصلاحية
    if (expiry == null || DateTime.now().isAfter(expiry)) {
      return SessionStatus.expired;
    }

    // التحقق من الحاجة للتجديد
    final refreshTime = expiry.subtract(tokenRefreshBuffer);
    if (DateTime.now().isAfter(refreshTime)) {
      return SessionStatus.needsRefresh;
    }

    return SessionStatus.valid;
  }

  /// التحقق من صلاحية الجلسة
  static Future<bool> isSessionValid() async {
    final status = await checkSession();
    return status == SessionStatus.valid ||
        status == SessionStatus.needsRefresh;
  }

  // ============================================================================
  // SESSION MONITORING
  // ============================================================================

  /// بدء مراقبة الجلسة
  static void startSessionMonitor({
    required VoidCallback onExpired,
    VoidCallback? onNeedsRefresh,
  }) {
    _onExpiredCallback = onExpired;
    stopSessionMonitor();

    // تحقق كل دقيقة
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      final status = await checkSession();

      switch (status) {
        case SessionStatus.expired:
          await endSession();
          _onExpiredCallback?.call();
          break;
        case SessionStatus.needsRefresh:
          onNeedsRefresh?.call();
          break;
        case SessionStatus.valid:
        case SessionStatus.notAuthenticated:
          break;
      }
    });
  }

  /// إيقاف مراقبة الجلسة
  static void stopSessionMonitor() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// الحصول على وقت انتهاء الجلسة
  static Future<DateTime?> getSessionExpiry() async {
    return await SecureStorageService.getSessionExpiry();
  }

  /// الحصول على الوقت المتبقي للجلسة
  static Future<Duration?> getRemainingTime() async {
    final expiry = await SecureStorageService.getSessionExpiry();
    if (expiry == null) return null;

    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// الحصول على Access Token
  static Future<String?> getAccessToken() async {
    return await SecureStorageService.getAccessToken();
  }

  /// الحصول على Refresh Token
  static Future<String?> getRefreshToken() async {
    return await SecureStorageService.getRefreshToken();
  }
}
