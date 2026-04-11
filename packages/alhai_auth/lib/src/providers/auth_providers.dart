/// مزودات المصادقة - Auth Providers
///
/// توفر حالة المصادقة والمستخدم الحالي لجميع أجزاء التطبيق
/// مع دعم SecureStorage و Session Management
///
/// L48: Concurrent session limiting is enforced client-side via
/// [_maxConcurrentSessions]. On login, the server-side `active_sessions`
/// table should also be checked (see [ConcurrentSessionGuard]).
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide User, AuthException;
import 'package:uuid/uuid.dart';
import '../security/secure_storage_service.dart';
import '../security/session_manager.dart';
import '../services/whatsapp_otp_service.dart';
import 'user_role_resolver.dart';

// ============================================================================
// STORE ID PROVIDER
// ============================================================================

/// معرّف المتجر الافتراضي (يستخدم فقط عند CSV seeding ولا يُعيّن تلقائياً)
///
/// Reads from --dart-define=DEFAULT_STORE_ID=... at compile time.
///
/// IMPORTANT: Production builds MUST pass
/// `--dart-define=DEFAULT_STORE_ID=<uuid>` or the app will fail-safe with
/// an empty string. Consumers that require a non-empty value must guard
/// with a clear error at the consumption point — never silently fall back
/// to a hardcoded development UUID.
const String kDefaultStoreId = String.fromEnvironment(
  'DEFAULT_STORE_ID',
  defaultValue: '',
);

/// مزود معرّف المتجر الحالي
/// يبدأ بـ null ويُعيّن ديناميكياً:
/// - من SecureStorage عند فتح التطبيق (splash_screen)
/// - من اختيار المستخدم (store_select_screen)
final currentStoreIdProvider = StateProvider<String?>((ref) => null);

// ============================================================================
// CONSTANTS
// ============================================================================

/// مدة الجلسة (30 دقيقة)
const Duration kSessionDuration = Duration(minutes: 30);

/// مدة تجديد التوكن قبل انتهاء الجلسة (5 دقائق)
const Duration kTokenRefreshBuffer = Duration(minutes: 5);

/// الحد الأقصى للجلسات المتزامنة لكل حساب (L48)
const int _maxConcurrentSessions = 3;

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
  StreamSubscription<dynamic>? _supabaseAuthSub;
  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initComplete => _initCompleter.future;

  AuthNotifier(this._authRepository, [this._supabaseClient])
    : super(const AuthState()) {
    _listenToSupabaseAuth();
    _checkAuthStatus();
  }

  // ==========================================================================
  // SESSION VALIDATION ON APP RESUME
  // ==========================================================================

  /// Validates the current session and refreshes the token if needed.
  ///
  /// Call this from a [WidgetsBindingObserver.didChangeAppLifecycleState]
  /// handler when [AppLifecycleState.resumed] is received to ensure the
  /// session is still valid after the app returns from the background.
  ///
  /// Flow:
  /// 1. If the Supabase session exists and is expired, attempt a refresh.
  /// 2. If no Supabase session, fall back to SecureStorage expiry check.
  /// 3. If the token is within the refresh buffer, proactively refresh.
  /// 4. If all checks fail, mark the session as expired and clear storage.
  Future<void> validateSession() async {
    // Only validate if currently authenticated
    if (state.status != AuthStatus.authenticated) return;

    try {
      // ── Check Supabase session first ──────────────────────────────
      if (_supabaseClient != null) {
        final session = _supabaseClient.auth.currentSession;
        if (session != null) {
          final expiry = session.expiresAt != null
              ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
              : state.sessionExpiry;

          // Token expired → try refresh
          if (expiry != null && DateTime.now().isAfter(expiry)) {
            try {
              await _supabaseClient.auth.refreshSession();
              final refreshed = _supabaseClient.auth.currentSession;
              if (refreshed != null) {
                final newExpiry = refreshed.expiresAt != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                        refreshed.expiresAt! * 1000,
                      )
                    : DateTime.now().add(kSessionDuration);
                await SecureStorageService.saveTokens(
                  accessToken: refreshed.accessToken,
                  refreshToken: refreshed.refreshToken ?? '',
                  expiry: newExpiry,
                );
                state = state.copyWith(sessionExpiry: newExpiry);
                return;
              }
            } catch (_) {
              // Refresh failed — fall through to expiry handling
            }
            await _handleSessionExpired();
            return;
          }

          // Within refresh buffer → proactive refresh
          if (expiry != null) {
            final refreshTime = expiry.subtract(kTokenRefreshBuffer);
            if (DateTime.now().isAfter(refreshTime)) {
              await _refreshToken();
            }
          }
          return;
        }
      }

      // ── Fallback: check SecureStorage expiry ──────────────────────
      final isValid = await SecureStorageService.isSessionValid();
      if (!isValid) {
        await _handleSessionExpired();
        return;
      }

      // Still valid but might need refresh
      if (state.needsRefresh) {
        await _refreshToken();
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('validateSession error: $e');
      }
      await _handleSessionExpired();
    }
  }

  /// SESSION-FIX: الاستماع لأحداث Supabase Auth لاستعادة الجلسة عند التحديث (F5)
  /// على الويب، Supabase قد تستعيد الجلسة بشكل غير متزامن بعد initialize().
  /// هذا الـ listener يلتقط الجلسة المستعادة ويحدّث الحالة.
  void _listenToSupabaseAuth() {
    if (_supabaseClient == null) return;

    _supabaseAuthSub = _supabaseClient.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final event = data.event;

      if (kDebugMode) {
        debugPrint(
          '🔄 Supabase auth event: $event, session: ${session != null}',
        );
      }

      // AUTH-GUARD FIX: resolve role from public.users on EVERY relevant
      // event (initialSession, signedIn, tokenRefreshed) so promotions /
      // demotions take effect after a refresh. Previously role was
      // hardcoded to UserRole.employee which made super-admin login
      // impossible and broke the router guard.
      final shouldHandle =
          (event == AuthChangeEvent.initialSession ||
              event == AuthChangeEvent.tokenRefreshed ||
              event == AuthChangeEvent.signedIn) &&
          session != null;

      if (shouldHandle) {
        final expiry = session.expiresAt != null
            ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
            : DateTime.now().add(kSessionDuration);

        // Resolve role from DB asynchronously, then commit to state.
        // On tokenRefreshed we still re-resolve to pick up role changes.
        _resolveUserRole(session.user.id).then((resolvedRole) {
          // If signedOut raced us, bail out.
          if (state.status == AuthStatus.unauthenticated) return;

          state = AuthState(
            status: AuthStatus.authenticated,
            user: User(
              id: session.user.id,
              phone: session.user.phone ?? '',
              name:
                  session.user.userMetadata?['name'] as String? ??
                  session.user.phone ??
                  '',
              email: session.user.email,
              role: resolvedRole,
              createdAt: DateTime.now(),
            ),
            sessionExpiry: expiry,
          );
          _startSessionMonitor();

          // تحديث tokens في SecureStorage
          SecureStorageService.saveTokens(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken ?? '',
            expiry: expiry,
          );

          // نسخ احتياطي / استعادة مفتاح تشفير قاعدة البيانات
          SecureStorageService.ensureEncryptionKeyBackup();

          if (!_initCompleter.isCompleted) {
            _initCompleter.complete();
          }
        });
      } else if (event == AuthChangeEvent.signedOut) {
        _stopSessionMonitor();
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  /// Resolve the current user's role from the `public.users` table
  /// (the server-side source of truth). Falls back to
  /// [kDefaultUserRole] (employee) on any failure, missing row, or
  /// unknown value — this is a safe default because employee has the
  /// fewest privileges and any super-admin gating will still refuse.
  ///
  /// SECURITY NOTE: This is only the client-side hint used to pick the
  /// correct navigation shell. Real enforcement must be performed
  /// server-side by RLS policies that gate mutations on
  /// `public.is_super_admin()`.
  Future<UserRole> _resolveUserRole(String userId) async {
    if (_supabaseClient == null || userId.isEmpty) {
      return kDefaultUserRole;
    }
    try {
      final row = await _supabaseClient
          .from('users')
          .select('role')
          .eq('id', userId)
          .maybeSingle();
      if (row == null) return kDefaultUserRole;
      return parseUserRoleFromDb(row['role']);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ _resolveUserRole failed for $userId: $e');
      }
      return kDefaultUserRole;
    }
  }

  /// التحقق من حالة المصادقة عند بدء التطبيق
  ///
  /// الترتيب:
  /// 1. Supabase session (إذا وُجدت → authenticated فوراً)
  /// 2. SecureStorageService (الحل الأساسي على الويب - verifyLocalOtp يحفظ هنا)
  /// 3. _authRepository (fallback للـ native حيث AuthLocalDatasource يستخدم FlutterSecureStorage)
  ///
  /// ملاحظة مهمة: على الويب، verifyLocalOtp() يحفظ التوكنات في SecureStorageService فقط
  /// (وليس في _authRepository/AuthLocalDatasource) لأن FlutterSecureStorage لا يعمل
  /// على الويب بدون keychain أصلي. لذلك نعتمد على SecureStorageService مباشرة.
  Future<void> _checkAuthStatus() async {
    try {
      // ── الخطوة 1: فحص Supabase session ──────────────────────────────
      if (_supabaseClient != null) {
        final session = _supabaseClient.auth.currentSession;
        if (session != null) {
          final expiry = session.expiresAt != null
              ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
              : DateTime.now().add(kSessionDuration);

          // التحقق من انتهاء صلاحية JWT (M84 fix)
          if (expiry.isBefore(DateTime.now())) {
            try {
              await _supabaseClient.auth.refreshSession();
              final refreshed = _supabaseClient.auth.currentSession;
              if (refreshed == null) {
                state = const AuthState(status: AuthStatus.unauthenticated);
                return;
              }
            } catch (_) {
              state = const AuthState(status: AuthStatus.unauthenticated);
              return;
            }
          }

          // AUTH-GUARD FIX: resolve role from public.users instead of
          // hardcoding employee — see _listenToSupabaseAuth().
          final resolvedRole = await _resolveUserRole(session.user.id);
          state = AuthState(
            status: AuthStatus.authenticated,
            user: User(
              id: session.user.id,
              phone: session.user.phone ?? '',
              name:
                  session.user.userMetadata?['name'] as String? ??
                  session.user.phone ??
                  '',
              email: session.user.email,
              role: resolvedRole,
              createdAt: DateTime.now(),
            ),
            sessionExpiry: expiry,
          );
          _startSessionMonitor();
          if (kDebugMode) {
            debugPrint(
              '✅ Auth restored from Supabase session (role=$resolvedRole)',
            );
          }
          return;
        }

        // على الويب، Supabase قد لا تملك الجلسة فوراً بعد initialize()
        if (kIsWeb) {
          try {
            await Future.delayed(const Duration(milliseconds: 500));
            final retrySession = _supabaseClient.auth.currentSession;
            if (retrySession != null) {
              if (state.status == AuthStatus.authenticated) return;
            }
          } catch (_) {}
        }
      }

      // ── الخطوة 2: فحص SecureStorageService ──────────────────────────
      final isSessionValid = await SecureStorageService.isSessionValid();
      final savedUserId = await SecureStorageService.getUserId();
      final savedExpiry = await SecureStorageService.getSessionExpiry();

      if (kDebugMode) {
        final hasToken = await SecureStorageService.getAccessToken() != null;
        debugPrint(
          '📋 SecureStorage check: valid=$isSessionValid, '
          'token=${hasToken ? "exists" : "null"}, '
          'userId=${savedUserId ?? "null"}, '
          'expiry=${savedExpiry?.toIso8601String() ?? "null"}',
        );
      }

      if (!isSessionValid) {
        if (_supabaseClient != null && kIsWeb) {
          if (kDebugMode) {
            debugPrint(
              '⏳ SecureStorage session expired, waiting for Supabase auth event...',
            );
          }
          state = const AuthState(status: AuthStatus.unauthenticated);
          return;
        }
        await SecureStorageService.clearSession();
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      // SESSION-FIX: استعادة الجلسة مباشرة من SecureStorageService
      // هذا يحل مشكلة F5 على الويب حيث verifyLocalOtp() يحفظ التوكنات
      // في SecureStorageService فقط (وليس في _authRepository/AuthLocalDatasource)
      if (savedUserId != null &&
          savedUserId.isNotEmpty &&
          savedExpiry != null) {
        // محاولة جلب بيانات المستخدم الكاملة من repository
        User? user;
        try {
          user = await _authRepository.getCurrentUser();
        } catch (_) {
          // repository قد لا يملك بيانات المستخدم (حالة local auth)
        }

        // إذا لم يكن في repository، ننشئ User من SecureStorage
        user ??= User(
          id: savedUserId,
          phone: savedUserId,
          name: savedUserId,
          role: UserRole.employee,
          createdAt: DateTime.now(),
        );

        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          sessionExpiry: savedExpiry,
        );
        _startSessionMonitor();

        if (kDebugMode) {
          debugPrint(
            '✅ Auth restored from SecureStorage for user: $savedUserId',
          );
        }

        if (state.needsRefresh) {
          await _refreshToken();
        }
        return;
      }

      // ── الخطوة 3: Fallback إلى _authRepository (native) ─────────────
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        final expiry = await SecureStorageService.getSessionExpiry();

        state = AuthState(
          status: AuthStatus.authenticated,
          user: user,
          sessionExpiry: expiry,
        );
        _startSessionMonitor();

        if (state.needsRefresh) {
          await _refreshToken();
        }
      } else {
        if (kDebugMode) {
          debugPrint('❌ Auth check: no valid session found anywhere');
        }
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Auth check exception: $e');
      }
      state = AuthState(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    } finally {
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
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
      // L48: Check concurrent sessions before proceeding
      final sessionCheck = await ConcurrentSessionGuard.checkAndEnforce(
        phone: phone,
        supabaseClient: _supabaseClient,
      );
      if (!sessionCheck.allowed) {
        state = state.copyWith(
          error:
              sessionCheck.reason ??
              'تم تجاوز الحد الأقصى للأجهزة المتصلة ($_maxConcurrentSessions). '
                  'يرجى تسجيل الخروج من جهاز آخر أولاً.',
        );
        return;
      }

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

      // نسخ احتياطي / استعادة مفتاح تشفير قاعدة البيانات
      SecureStorageService.ensureEncryptionKeyBackup();
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
      await SecureStorageService.saveUserData(userId: phone, storeId: '');

      state = AuthState(
        status: AuthStatus.authenticated,
        user: User(
          id: phone,
          phone: phone,
          name: phone,
          role: UserRole.employee,
          createdAt: DateTime.now(),
        ),
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
          await _supabaseClient.auth.signOut();
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

  // ==========================================================================
  // REAL AUTH: Phone → Email/Password → OTP (3-step flow)
  // ==========================================================================

  /// الخطوة 1: فحص الكاشير بالهاتف - يرجع بيانات المستخدم لو موجود
  Future<Map<String, dynamic>> checkCashierByPhone(String phone) async {
    try {
      if (_supabaseClient == null) {
        debugPrint('❌ checkCashierByPhone: _supabaseClient is NULL');
        return {'exists': false, 'error': 'Supabase غير متاح'};
      }

      // تنظيف الرقم: إزالة + لأن Supabase يخزّن بدون +
      final cleanPhone = phone.replaceAll('+', '');

      debugPrint(
        '📞 checkCashierByPhone: phone=$phone → cleanPhone=$cleanPhone',
      );

      final result = await _supabaseClient.rpc(
        'check_cashier_by_phone',
        params: {'p_phone': cleanPhone},
      );

      debugPrint('📦 RPC result type: ${result.runtimeType}');
      debugPrint('📦 RPC result value: $result');

      if (result is Map<String, dynamic>) {
        debugPrint('✅ Result is Map<String, dynamic>');
        return result;
      }

      // لو الـ RPC رجع نوع ثاني (مثل _JsonMap)
      if (result is Map) {
        debugPrint('⚠️ Result is Map but not Map<String, dynamic>, casting...');
        return Map<String, dynamic>.from(result);
      }

      debugPrint('❌ Result is NOT a Map: ${result.runtimeType}');
      return {'exists': false};
    } catch (e) {
      debugPrint('❌ checkCashierByPhone EXCEPTION: $e');
      return {'exists': false, 'error': e.toString()};
    }
  }

  /// الخطوة 2: تسجيل الدخول بالإيميل والباسورد
  Future<({bool success, String? error})> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (_supabaseClient == null) {
        return (success: false, error: 'Supabase غير متاح');
      }

      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        // حفظ الـ session مؤقتاً - لا نكمل الدخول إلا بعد OTP
        final expiry = DateTime.now().add(kSessionDuration);
        await SecureStorageService.saveTokens(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken ?? '',
          expiry: expiry,
        );
        final userId = response.user?.id ?? '';
        await SecureStorageService.saveUserData(userId: userId, storeId: '');

        // AUTH-GUARD FIX: resolve role from public.users and reflect
        // it in AuthState immediately. Previously this method only
        // wrote tokens to secure storage and left AuthState untouched,
        // which meant the super-admin router guard always rejected
        // password-based logins.
        if (userId.isNotEmpty) {
          final resolvedRole = await _resolveUserRole(userId);
          state = AuthState(
            status: AuthStatus.authenticated,
            user: User(
              id: userId,
              phone: response.user?.phone ?? '',
              name:
                  response.user?.userMetadata?['name'] as String? ??
                  response.user?.email ??
                  email,
              email: response.user?.email ?? email,
              role: resolvedRole,
              createdAt: DateTime.now(),
            ),
            sessionExpiry: expiry,
          );
          _startSessionMonitor();
          SecureStorageService.ensureEncryptionKeyBackup();
        }
        return (success: true, error: null);
      }

      return (success: false, error: 'فشل تسجيل الدخول');
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Sign in with password failed: $e');
      }
      final msg = e.toString();
      // ترجمة رسائل Supabase Auth للعربية
      if (msg.contains('Invalid login credentials')) {
        return (success: false, error: 'كلمة المرور غير صحيحة');
      }
      if (msg.contains('Email not confirmed')) {
        return (success: false, error: 'البريد الإلكتروني غير مؤكد');
      }
      if (msg.contains('SocketException') || msg.contains('ClientException')) {
        return (success: false, error: 'حدث خطأ في الاتصال');
      }
      return (success: false, error: 'فشل تسجيل الدخول: $msg');
    }
  }

  /// إرسال OTP عبر Supabase Auth
  Future<bool> sendSupabaseOtp(String phone) async {
    try {
      if (_supabaseClient == null) return false;

      await _supabaseClient.auth.signInWithOtp(phone: phone);
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

      final response = await _supabaseClient.auth.verifyOTP(
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
          await _supabaseClient.auth.signOut();
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
    _supabaseAuthSub?.cancel();
    _stopSessionMonitor();
    super.dispose();
  }
}

// ============================================================================
// CONCURRENT SESSION GUARD (L48)
// ============================================================================

/// نتيجة فحص الجلسات المتزامنة
class SessionCheckResult {
  final bool allowed;
  final int activeSessions;
  final String? reason;

  const SessionCheckResult({
    required this.allowed,
    this.activeSessions = 0,
    this.reason,
  });
}

/// حارس الجلسات المتزامنة
///
/// يتحقق من عدد الأجهزة المتصلة حالياً ويمنع تسجيل الدخول
/// إذا تجاوز الحد الأقصى [_maxConcurrentSessions].
///
/// يعتمد على جدول `active_sessions` في Supabase:
/// ```sql
/// CREATE TABLE active_sessions (
///   id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
///   user_phone TEXT NOT NULL,
///   device_id TEXT NOT NULL,
///   created_at TIMESTAMPTZ DEFAULT now(),
///   last_seen_at TIMESTAMPTZ DEFAULT now(),
///   expires_at TIMESTAMPTZ NOT NULL
/// );
/// ```
class ConcurrentSessionGuard {
  ConcurrentSessionGuard._();

  /// التحقق من الجلسات المتزامنة وفرض الحد الأقصى.
  ///
  /// - إذا لم يكن Supabase متاحاً (وضع عدم الاتصال)، يسمح بالدخول.
  /// - إذا كان عدد الجلسات النشطة < [_maxConcurrentSessions]، يسمح بالدخول.
  /// - خلاف ذلك، يرفض مع رسالة توضيحية.
  static Future<SessionCheckResult> checkAndEnforce({
    required String phone,
    SupabaseClient? supabaseClient,
  }) async {
    // في وضع عدم الاتصال أو عدم توفر Supabase → السماح
    if (supabaseClient == null) {
      return const SessionCheckResult(allowed: true, activeSessions: 0);
    }

    try {
      // استعلام الجلسات النشطة غير المنتهية
      final response = await supabaseClient
          .from('active_sessions')
          .select('id')
          .eq('user_phone', phone)
          .gt('expires_at', DateTime.now().toUtc().toIso8601String());

      final activeSessions = (response as List).length;

      if (activeSessions >= _maxConcurrentSessions) {
        return SessionCheckResult(
          allowed: false,
          activeSessions: activeSessions,
          reason:
              'لديك $activeSessions أجهزة متصلة حالياً. '
              'الحد الأقصى هو $_maxConcurrentSessions أجهزة. '
              'يرجى تسجيل الخروج من جهاز آخر أولاً.',
        );
      }

      return SessionCheckResult(allowed: true, activeSessions: activeSessions);
    } catch (e) {
      // إذا فشل الاستعلام (الجدول غير موجود، شبكة، إلخ) → السماح
      // لتجنب حظر المستخدمين بسبب خطأ في الشبكة
      if (kDebugMode) {
        debugPrint('ConcurrentSessionGuard: check failed ($e), allowing login');
      }
      return const SessionCheckResult(allowed: true, activeSessions: 0);
    }
  }

  /// تسجيل جلسة جديدة في الجدول
  static Future<void> registerSession({
    required String phone,
    required String deviceId,
    required DateTime expiresAt,
    SupabaseClient? supabaseClient,
  }) async {
    if (supabaseClient == null) return;
    try {
      await supabaseClient.from('active_sessions').insert({
        'user_phone': phone,
        'device_id': deviceId,
        'expires_at': expiresAt.toUtc().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ConcurrentSessionGuard: register failed ($e)');
      }
    }
  }

  /// إزالة جلسة عند تسجيل الخروج
  static Future<void> removeSession({
    required String deviceId,
    SupabaseClient? supabaseClient,
  }) async {
    if (supabaseClient == null) return;
    try {
      await supabaseClient
          .from('active_sessions')
          .delete()
          .eq('device_id', deviceId);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ConcurrentSessionGuard: remove failed ($e)');
      }
    }
  }
}

// ============================================================================
// PROVIDERS
// ============================================================================

/// مزود حالة المصادقة
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
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
