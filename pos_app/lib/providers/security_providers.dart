/// مزودات الأمان - Security Providers
///
/// توفر خدمات الأمان والتخزين الآمن وإدارة الجلسات
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/security/secure_storage_service.dart';
import '../core/security/session_manager.dart';

// ============================================================================
// SECURE STORAGE PROVIDERS
// ============================================================================

/// مزود الـ Access Token
final accessTokenProvider = FutureProvider<String?>((ref) async {
  return await SecureStorageService.getAccessToken();
});

/// مزود الـ Refresh Token
final refreshTokenProvider = FutureProvider<String?>((ref) async {
  return await SecureStorageService.getRefreshToken();
});

/// مزود معرف المتجر المحفوظ
final savedStoreIdProvider = FutureProvider<String?>((ref) async {
  return await SecureStorageService.getStoreId();
});

// ============================================================================
// SESSION PROVIDERS
// ============================================================================

/// مزود حالة الجلسة
final sessionActiveProvider = FutureProvider<bool>((ref) async {
  try {
    return await SessionManager.isSessionValid();
  } catch (_) {
    return false;
  }
});

/// مزود حالة الجلسة التفصيلية
final sessionStatusProvider = FutureProvider<SessionStatus>((ref) async {
  return await SessionManager.checkSession();
});

/// مزود وقت انتهاء الجلسة
final sessionExpiryProvider = FutureProvider<DateTime?>((ref) async {
  return await SessionManager.getSessionExpiry();
});

/// مزود الوقت المتبقي للجلسة
final sessionRemainingTimeProvider = FutureProvider<Duration?>((ref) async {
  return await SessionManager.getRemainingTime();
});

// ============================================================================
// TOKEN REFRESH
// ============================================================================

/// حالة تجديد التوكن
class TokenRefreshState {
  final bool isRefreshing;
  final DateTime? lastRefresh;
  final String? error;

  const TokenRefreshState({
    this.isRefreshing = false,
    this.lastRefresh,
    this.error,
  });

  TokenRefreshState copyWith({
    bool? isRefreshing,
    DateTime? lastRefresh,
    String? error,
    bool clearError = false,
  }) {
    return TokenRefreshState(
      isRefreshing: isRefreshing ?? this.isRefreshing,
      lastRefresh: lastRefresh ?? this.lastRefresh,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// مُدير تجديد التوكن
class TokenRefreshNotifier extends StateNotifier<TokenRefreshState> {
  TokenRefreshNotifier() : super(const TokenRefreshState());

  /// تجديد التوكن
  Future<bool> refreshToken({
    required Future<({String accessToken, String refreshToken})> Function(String) onRefresh,
  }) async {
    if (state.isRefreshing) return false;
    
    state = state.copyWith(isRefreshing: true, clearError: true);
    
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null) {
        state = state.copyWith(
          isRefreshing: false,
          error: 'No refresh token available',
        );
        return false;
      }
      
      // استدعاء API لتجديد التوكن
      final tokens = await onRefresh(refreshToken);
      
      await SessionManager.refreshSession(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
      );
      
      state = state.copyWith(
        isRefreshing: false,
        lastRefresh: DateTime.now(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// التحقق من الحاجة لتجديد التوكن
  Future<bool> shouldRefresh() async {
    final status = await SessionManager.checkSession();
    return status == SessionStatus.needsRefresh;
  }
}

/// مزود تجديد التوكن
final tokenRefreshProvider =
    StateNotifierProvider<TokenRefreshNotifier, TokenRefreshState>((ref) {
  return TokenRefreshNotifier();
});
