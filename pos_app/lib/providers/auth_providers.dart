/// مزودات المصادقة - Auth Providers
///
/// توفر حالة المصادقة والمستخدم الحالي لجميع أجزاء التطبيق
/// مع دعم SecureStorage و Session Management
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:uuid/uuid.dart';
import '../core/security/secure_storage_service.dart';
import '../core/security/session_manager.dart';
import '../services/whatsapp_otp_service.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

/// مدة الجلسة (30 دقيقة)
const Duration kSessionDuration = Duration(minutes: 30);

/// مدة تجديد التوكن قبل انتهاء الجلسة (5 دقائق)
const Duration kTokenRefreshBuffer = Duration(minutes: 5);

// ============================================================================
// REPOSITORY PROVIDERS
// ============================================================================

/// مزود مستودع المصادقة
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return getIt<AuthRepository>();
});

/// مزود عميل Supabase (nullable - قد لا يكون متاحاً في وضع عدم الاتصال)
final supabaseClientProvider = Provider<SupabaseClient?>((ref) {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
});

// ============================================================================
// AUTH STATE
// ============================================================================

/// حالة المصادقة
enum AuthStatus {
  /// غير معروف (التحقق جاري)
  unknown,

  /// مصادق عليه
  authenticated,

  /// غير مصادق عليه
  unauthenticated,
  
  /// الجلسة منتهية
  sessionExpired,
}

/// حالة المصادقة الكاملة
class AuthState {
  final AuthStatus status;
  final User? user;
  final String? error;
  final DateTime? sessionExpiry;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.user,
    this.error,
    this.sessionExpiry,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? error,
    DateTime? sessionExpiry,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
      sessionExpiry: sessionExpiry ?? this.sessionExpiry,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.unknown;
  bool get isSessionExpired => status == AuthStatus.sessionExpired;
  
  /// التحقق من صلاحية الجلسة
  bool get isSessionValid {
    if (sessionExpiry == null) return false;
    return DateTime.now().isBefore(sessionExpiry!);
  }
  
  /// هل تحتاج الجلسة للتجديد؟
  bool get needsRefresh {
    if (sessionExpiry == null) return true;
    final refreshTime = sessionExpiry!.subtract(kTokenRefreshBuffer);
    return DateTime.now().isAfter(refreshTime);
  }
}

// ============================================================================
// AUTH NOTIFIER
// ============================================================================

/// مُدير حالة المصادقة مع SecureStorage
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final SupabaseClient? _supabaseClient;
  Timer? _sessionTimer;

  AuthNotifier(this._authRepository, [this._supabaseClient]) : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// التحقق من حالة المصادقة عند بدء التطبيق
  Future<void> _checkAuthStatus() async {
    try {
      // Check Supabase session first
      if (_supabaseClient != null) {
        final session = _supabaseClient!.auth.currentSession;
        if (session != null) {
          final expiry = session.expiresAt != null
              ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
              : DateTime.now().add(kSessionDuration);

          state = AuthState(
            status: AuthStatus.authenticated,
            sessionExpiry: expiry,
          );
          _startSessionMonitor();
          return;
        }
      }

      // التحقق من الجلسة المحفوظة
      final isSessionValid = await SecureStorageService.isSessionValid();
      
      if (!isSessionValid) {
        await SecureStorageService.clearSession();
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }
      
      // التحقق من المصادقة
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        final expiry = await SecureStorageService.getSessionExpiry();
        
        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          sessionExpiry: expiry,
        );
        
        // بدء مراقبة الجلسة
        _startSessionMonitor();
        
        // تحقق من الحاجة لتجديد التوكن
        if (state.needsRefresh) {
          await _refreshToken();
        }
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// إرسال رمز OTP
  Future<void> sendOtp(String phone) async {
    try {
      await _authRepository.sendOtp(phone);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// التحقق من رمز OTP وتسجيل الدخول
  Future<void> verifyOtp(String phone, String otp) async {
    try {
      final result = await _authRepository.verifyOtp(phone, otp);
      
      // حساب وقت انتهاء الجلسة
      final expiry = DateTime.now().add(kSessionDuration);
      
      // حفظ الـ tokens بشكل آمن
      await SecureStorageService.saveTokens(
        accessToken: result.tokens.accessToken,
        refreshToken: result.tokens.refreshToken,
        expiry: expiry,
      );
      
      // حفظ بيانات المستخدم
      await SecureStorageService.saveUserData(
        userId: result.user.id,
        storeId: result.user.storeId ?? '',
      );
      
      state = AuthState(
        status: AuthStatus.authenticated,
        user: result.user,
        sessionExpiry: expiry,
      );
      
      // بدء مراقبة الجلسة
      _startSessionMonitor();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// التحقق المحلي من OTP عبر WhatsApp وإنشاء جلسة محلية
  /// يُستخدم عندما يتم التحقق من OTP محلياً عبر WhatsAppOtpService
  Future<void> verifyLocalOtp({
    required String phone,
    required WhatsAppOtpVerifyResult otpResult,
  }) async {
    if (!otpResult.isSuccess) {
      state = state.copyWith(error: otpResult.error ?? 'فشل التحقق من OTP');
      return;
    }

    try {
      // حساب وقت انتهاء الجلسة
      final expiry = DateTime.now().add(kSessionDuration);

      // إنشاء tokens محلية للجلسة باستخدام UUID
      const uuid = Uuid();
      final localAccessToken = 'session_${uuid.v4()}';
      final localRefreshToken = 'refresh_${uuid.v4()}';

      // حفظ الـ tokens بشكل آمن
      await SecureStorageService.saveTokens(
        accessToken: localAccessToken,
        refreshToken: localRefreshToken,
        expiry: expiry,
      );

      // حفظ بيانات المستخدم
      await SecureStorageService.saveUserData(
        userId: phone,
        storeId: '',
      );

      state = AuthState(
        status: AuthStatus.authenticated,
        sessionExpiry: expiry,
      );

      // بدء مراقبة الجلسة
      _startSessionMonitor();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// تسجيل الخروج
  Future<void> logout() async {
    try {
      _stopSessionMonitor();

      // Sign out from Supabase if available
      if (_supabaseClient != null) {
        try {
          await _supabaseClient!.auth.signOut();
        } catch (_) {}
      }

      await _authRepository.logout();
      await SecureStorageService.clearSession();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// إرسال OTP عبر Supabase Auth
  Future<bool> sendSupabaseOtp(String phone) async {
    try {
      if (_supabaseClient == null) return false;

      await _supabaseClient!.auth.signInWithOtp(
        phone: phone,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Supabase OTP send failed: $e');
      }
      return false;
    }
  }

  /// التحقق من OTP عبر Supabase Auth
  Future<bool> verifySupabaseOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      if (_supabaseClient == null) return false;

      final response = await _supabaseClient!.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.session != null) {
        final session = response.session!;
        final expiry = DateTime.now().add(kSessionDuration);

        // حفظ tokens Supabase
        await SecureStorageService.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken ?? '',
          expiry: expiry,
        );

        // حفظ بيانات المستخدم
        await SecureStorageService.saveUserData(
          userId: response.user?.id ?? phone,
          storeId: '', // يتم تحديده لاحقاً في store-select
        );

        state = AuthState(
          status: AuthStatus.authenticated,
          sessionExpiry: expiry,
        );

        _startSessionMonitor();
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Supabase OTP verify failed: $e');
      }
      return false;
    }
  }

  /// تسجيل الخروج (مع Supabase)
  Future<void> logoutWithSupabase() async {
    try {
      _stopSessionMonitor();

      // تسجيل الخروج من Supabase
      if (_supabaseClient != null) {
        try {
          await _supabaseClient!.auth.signOut();
        } catch (_) {
          // تجاهل أخطاء Supabase عند الخروج
        }
      }

      // تسجيل الخروج من المستودع المحلي
      await _authRepository.logout();
      await SecureStorageService.clearSession();
      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  /// تحديث بيانات المستخدم
  Future<void> refreshUser() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        state = state.copyWith(user: user);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
  
  /// تجديد التوكن
  Future<bool> _refreshToken() async {
    try {
      final tokens = await _authRepository.refreshToken();
      
      final newExpiry = DateTime.now().add(kSessionDuration);
      
      await SecureStorageService.saveTokens(
        accessToken: tokens.accessToken,
        refreshToken: tokens.refreshToken,
        expiry: newExpiry,
      );
      
      state = state.copyWith(sessionExpiry: newExpiry);
      return true;
    } catch (e) {
      // فشل التجديد - تسجيل الخروج
      await _handleSessionExpired();
      return false;
    }
  }
  
  /// بدء مراقبة الجلسة
  void _startSessionMonitor() {
    _stopSessionMonitor();
    
    // تحقق كل دقيقة
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) async {
      if (!state.isSessionValid) {
        await _handleSessionExpired();
      } else if (state.needsRefresh) {
        await _refreshToken();
      }
    });
  }
  
  /// إيقاف مراقبة الجلسة
  void _stopSessionMonitor() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }
  
  /// معالجة انتهاء الجلسة
  Future<void> _handleSessionExpired() async {
    _stopSessionMonitor();
    await SecureStorageService.clearSession();
    state = const AuthState(status: AuthStatus.sessionExpired);
  }

  /// مسح الخطأ
  void clearError() {
    state = state.copyWith(clearError: true);
  }
  
  @override
  void dispose() {
    _stopSessionMonitor();
    super.dispose();
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود حالة المصادقة
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final supabase = ref.watch(supabaseClientProvider);
  return AuthNotifier(authRepository, supabase);
});

/// مزود المستخدم الحالي (اختصار)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

/// مزود حالة تسجيل الدخول (اختصار)
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

/// مزود التحقق من صلاحيات المستخدم
final userRoleProvider = Provider<UserRole?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});

/// مزود التحقق من كون المستخدم مدير
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.superAdmin || role == UserRole.storeOwner;
});

/// مزود حالة الجلسة
final sessionStatusProvider = Provider<SessionStatus>((ref) {
  final authState = ref.watch(authStateProvider);
  
  if (authState.status == AuthStatus.unauthenticated) {
    return SessionStatus.notAuthenticated;
  }
  if (authState.status == AuthStatus.sessionExpired) {
    return SessionStatus.expired;
  }
  if (!authState.isSessionValid) {
    return SessionStatus.expired;
  }
  if (authState.needsRefresh) {
    return SessionStatus.needsRefresh;
  }
  return SessionStatus.valid;
});
