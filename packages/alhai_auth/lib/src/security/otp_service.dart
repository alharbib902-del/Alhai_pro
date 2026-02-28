/// @deprecated استخدم WhatsAppOtpService بدلاً من هذه الخدمة
/// خدمة OTP العامة - Generic OTP Service (غير مستخدمة حالياً)
///
/// تُدير إرسال والتحقق من رموز OTP مع:
/// - Rate Limiting (5 محاولات كل 15 دقيقة لكل رقم هاتف)
/// - OTP Expiry (5 دقائق)
/// - Resend functionality
/// - State Persistence (حفظ الحالة عند إغلاق التطبيق)
/// - Rate-limit violation logging
///
/// ⚠️ تحذير أمني مهم:
/// ─────────────────
/// Rate Limiting هنا يعمل على مستوى Client فقط!
/// يمكن تجاوزه بإعادة تثبيت التطبيق أو مسح البيانات.
///
/// للحماية الكاملة، يجب تطبيق Rate Limiting على مستوى الـ Server أيضاً:
/// - استخدم Redis أو مشابه لتتبع المحاولات
/// - طبق حظر IP للطلبات المتكررة
/// - راقب patterns غير طبيعية (monitoring)
///
/// التحقق الفعلي من OTP يتم عبر [onVerify] callback
/// الذي يجب أن يتصل بالـ Server للتحقق.
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'secure_storage_service.dart';

// ============================================================================
// CONSTANTS
// ============================================================================

/// مدة صلاحية OTP (5 دقائق)
const Duration kOtpExpiry = Duration(minutes: 5);

/// الحد الأقصى للمحاولات لكل رقم هاتف خلال النافذة الزمنية
const int kMaxAttempts = 5;

/// فترة النافذة الزمنية (15 دقيقة)
const Duration kRateLimitWindow = Duration(minutes: 15);

/// الحد الأدنى للانتظار قبل إعادة الإرسال (60 ثانية)
const Duration kResendCooldown = Duration(seconds: 60);

// ============================================================================
// OTP STATE
// ============================================================================

/// حالة OTP
class OtpState {
  final String phone;
  final DateTime sentAt;
  final DateTime expiresAt;
  final int attempts;
  final DateTime? lastAttemptAt;
  final bool isBlocked;
  final DateTime? blockedUntil;

  /// App-level HMAC signing key for OTP state integrity verification.
  /// Prevents forging of locally-stored OTP data by someone with device access.
  static const _hmacKey = 'alhai-otp-signing-v1';

  const OtpState({
    required this.phone,
    required this.sentAt,
    required this.expiresAt,
    this.attempts = 0,
    this.lastAttemptAt,
    this.isBlocked = false,
    this.blockedUntil,
  });

  /// هل OTP منتهي الصلاحية؟
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// الوقت المتبقي للصلاحية
  Duration get remainingTime {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// هل يمكن إعادة الإرسال؟
  bool get canResend {
    if (isBlocked) return false;
    final timeSinceSent = DateTime.now().difference(sentAt);
    return timeSinceSent >= kResendCooldown;
  }

  /// الوقت المتبقي لإعادة الإرسال
  Duration get resendCooldownRemaining {
    final elapsed = DateTime.now().difference(sentAt);
    final remaining = kResendCooldown - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Compute HMAC-SHA256 signature over core OTP fields to detect tampering.
  static String _computeHmac(String phone, String sentAt, String expiresAt) {
    final key = utf8.encode(_hmacKey);
    final data = utf8.encode('$phone:$sentAt:$expiresAt');
    final hmac = Hmac(sha256, key);
    return hmac.convert(data).toString();
  }

  /// تحويل إلى JSON للحفظ (مع توقيع HMAC)
  Map<String, dynamic> toJson() {
    final sentAtStr = sentAt.toIso8601String();
    final expiresAtStr = expiresAt.toIso8601String();
    return {
      'phone': phone,
      'sentAt': sentAtStr,
      'expiresAt': expiresAtStr,
      'attempts': attempts,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
      'isBlocked': isBlocked,
      'blockedUntil': blockedUntil?.toIso8601String(),
      'hmac': _computeHmac(phone, sentAtStr, expiresAtStr),
    };
  }

  /// إنشاء من JSON مع التحقق من توقيع HMAC.
  /// يُرجع null إذا كان التوقيع غير صالح (بيانات مُزورة أو تالفة).
  static OtpState? fromJson(Map<String, dynamic> json) {
    final phone = json['phone'] as String? ?? '';
    final sentAtStr = json['sentAt'] as String? ?? '';
    final expiresAtStr = json['expiresAt'] as String? ?? '';
    final storedHmac = json['hmac'] as String?;

    // Verify HMAC signature - reject if missing or invalid
    if (storedHmac == null || storedHmac.isEmpty) {
      debugPrint('[OTP-SECURITY] Rejected stored OTP state: missing HMAC signature');
      return null;
    }

    final expectedHmac = _computeHmac(phone, sentAtStr, expiresAtStr);
    if (storedHmac != expectedHmac) {
      debugPrint('[OTP-SECURITY] Rejected stored OTP state: HMAC mismatch (possible tampering)');
      return null;
    }

    return OtpState(
      phone: phone,
      sentAt: DateTime.tryParse(sentAtStr) ?? DateTime.now(),
      expiresAt: DateTime.tryParse(expiresAtStr) ?? DateTime.now(),
      attempts: json['attempts'] as int? ?? 0,
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.tryParse(json['lastAttemptAt'] as String)
          : null,
      isBlocked: json['isBlocked'] as bool? ?? false,
      blockedUntil: json['blockedUntil'] != null
          ? DateTime.tryParse(json['blockedUntil'] as String)
          : null,
    );
  }
}

// ============================================================================
// OTP SERVICE
// ============================================================================

/// مفتاح التخزين للحالة
const String _kOtpStateKey = 'otp_state';
const String _kAttemptHistoryKey = 'otp_attempt_history';

/// خدمة OTP العامة - غير مستخدمة، استخدم WhatsAppOtpService
@Deprecated('Use WhatsAppOtpService instead')
class OtpService {
  static OtpState? _currentOtpState;
  static final Map<String, List<DateTime>> _attemptHistory = {};
  static bool _isInitialized = false;

  // ============================================================================
  // INITIALIZATION & PERSISTENCE
  // ============================================================================

  /// تهيئة الخدمة واستعادة الحالة المحفوظة
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // استعادة حالة OTP
      final stateJson = await SecureStorageService.read(_kOtpStateKey);
      if (stateJson != null) {
        final state = OtpState.fromJson(jsonDecode(stateJson) as Map<String, dynamic>);
        if (state == null) {
          // HMAC verification failed - stored data is tampered or corrupted
          await SecureStorageService.delete(_kOtpStateKey);
        } else if (!state.isExpired) {
          // التحقق من أن الحالة لم تنتهِ صلاحيتها
          _currentOtpState = state;
        } else {
          // مسح الحالة المنتهية
          await SecureStorageService.delete(_kOtpStateKey);
        }
      }

      // استعادة سجل المحاولات
      final historyJson = await SecureStorageService.read(_kAttemptHistoryKey);
      if (historyJson != null) {
        final historyMap = jsonDecode(historyJson) as Map<String, dynamic>;
        _attemptHistory.clear();
        for (final entry in historyMap.entries) {
          final attempts = (entry.value as List)
              .map((e) => DateTime.tryParse(e as String) ?? DateTime.now())
              .where((time) => DateTime.now().difference(time) <= kRateLimitWindow)
              .toList();
          if (attempts.isNotEmpty) {
            _attemptHistory[entry.key] = attempts;
          }
        }
      }

      _isInitialized = true;
    } catch (e) {
      // في حالة الخطأ، نبدأ من جديد
      _currentOtpState = null;
      _attemptHistory.clear();
      _isInitialized = true;
    }
  }

  /// حفظ الحالة في التخزين الآمن
  static Future<void> _persistState() async {
    try {
      // حفظ حالة OTP
      if (_currentOtpState != null) {
        await SecureStorageService.write(
          _kOtpStateKey,
          jsonEncode(_currentOtpState!.toJson()),
        );
      } else {
        await SecureStorageService.delete(_kOtpStateKey);
      }

      // حفظ سجل المحاولات
      final historyMap = <String, List<String>>{};
      for (final entry in _attemptHistory.entries) {
        historyMap[entry.key] = entry.value
            .map((e) => e.toIso8601String())
            .toList();
      }
      await SecureStorageService.write(
        _kAttemptHistoryKey,
        jsonEncode(historyMap),
      );
    } catch (_) {
      // تجاهل أخطاء الحفظ
    }
  }

  // ============================================================================
  // SEND OTP
  // ============================================================================

  /// إرسال OTP
  ///
  /// [phone] رقم الهاتف
  /// [onSend] callback لإرسال OTP الفعلي (API call)
  static Future<OtpSendResult> sendOtp({
    required String phone,
    required Future<void> Function(String phone) onSend,
  }) async {
    // التأكد من التهيئة
    await initialize();

    // التحقق من Rate Limiting
    if (_isRateLimited(phone)) {
      final blockedUntil = _getBlockedUntil(phone);
      return OtpSendResult.rateLimited(blockedUntil);
    }

    try {
      // إرسال OTP عبر الـ API
      await onSend(phone);

      // تحديث الحالة
      final now = DateTime.now();
      _currentOtpState = OtpState(
        phone: phone,
        sentAt: now,
        expiresAt: now.add(kOtpExpiry),
      );

      // حفظ الحالة
      await _persistState();

      return OtpSendResult.success();
    } catch (e) {
      return OtpSendResult.error(e.toString());
    }
  }

  // ============================================================================
  // VERIFY OTP
  // ============================================================================

  /// التحقق من OTP
  ///
  /// [phone] رقم الهاتف
  /// [otp] رمز OTP
  /// [onVerify] callback للتحقق الفعلي (API call)
  static Future<OtpVerifyResult> verifyOtp({
    required String phone,
    required String otp,
    required Future<bool> Function(String phone, String otp) onVerify,
  }) async {
    // التأكد من التهيئة
    await initialize();

    // التحقق من الحالة
    if (_currentOtpState == null || _currentOtpState!.phone != phone) {
      return OtpVerifyResult.noOtpSent();
    }

    // التحقق من انتهاء الصلاحية
    if (_currentOtpState!.isExpired) {
      _currentOtpState = null;
      await _persistState();
      return OtpVerifyResult.expired();
    }

    // التحقق من Rate Limiting
    if (_isRateLimited(phone)) {
      final blockedUntil = _getBlockedUntil(phone);
      return OtpVerifyResult.rateLimited(blockedUntil);
    }

    // تسجيل المحاولة
    _recordAttempt(phone);
    await _persistState();

    try {
      // التحقق عبر الـ API (Server-side)
      final isValid = await onVerify(phone, otp);

      if (isValid) {
        await _clearState(phone);
        return OtpVerifyResult.success();
      } else {
        // التحقق من تجاوز الحد الأقصى
        final attempts = _getAttemptCount(phone);
        if (attempts >= kMaxAttempts) {
          _blockPhone(phone);
          await _persistState();
          return OtpVerifyResult.maxAttemptsExceeded();
        }

        return OtpVerifyResult.invalid(kMaxAttempts - attempts);
      }
    } catch (e) {
      return OtpVerifyResult.error(e.toString());
    }
  }

  // ============================================================================
  // RESEND OTP
  // ============================================================================

  /// إعادة إرسال OTP
  static Future<OtpSendResult> resendOtp({
    required String phone,
    required Future<void> Function(String phone) onSend,
  }) async {
    if (_currentOtpState != null && !_currentOtpState!.canResend) {
      return OtpSendResult.cooldown(_currentOtpState!.resendCooldownRemaining);
    }

    return sendOtp(phone: phone, onSend: onSend);
  }

  // ============================================================================
  // STATE
  // ============================================================================

  /// الحصول على حالة OTP الحالية
  static OtpState? get currentState => _currentOtpState;

  /// مسح الحالة
  static Future<void> _clearState(String phone) async {
    _currentOtpState = null;
    _attemptHistory.remove(phone);
    await _persistState();
  }

  /// إعادة تعيين كامل
  static Future<void> reset() async {
    _currentOtpState = null;
    _attemptHistory.clear();
    _isInitialized = false;
    await SecureStorageService.delete(_kOtpStateKey);
    await SecureStorageService.delete(_kAttemptHistoryKey);
  }

  // ============================================================================
  // RATE LIMITING (per phone number, 5 attempts per 15 minutes)
  // ============================================================================

  /// تسجيل محاولة لرقم هاتف محدد
  static void _recordAttempt(String phone) {
    _attemptHistory.putIfAbsent(phone, () => []);
    _attemptHistory[phone]!.add(DateTime.now());

    // إزالة المحاولات القديمة خارج النافذة الزمنية
    _cleanupExpiredAttempts(phone);
  }

  /// تنظيف المحاولات القديمة لرقم هاتف محدد
  static void _cleanupExpiredAttempts(String phone) {
    final attempts = _attemptHistory[phone];
    if (attempts == null) return;
    final cutoff = DateTime.now().subtract(kRateLimitWindow);
    attempts.removeWhere((time) => time.isBefore(cutoff));
    if (attempts.isEmpty) {
      _attemptHistory.remove(phone);
    }
  }

  /// عدد المحاولات الحالية لرقم هاتف محدد خلال النافذة الزمنية
  static int _getAttemptCount(String phone) {
    _cleanupExpiredAttempts(phone);
    return _attemptHistory[phone]?.length ?? 0;
  }

  /// هل الرقم محظور بسبب تجاوز الحد (5 محاولات في 15 دقيقة)
  static bool _isRateLimited(String phone) {
    final isLimited = _getAttemptCount(phone) >= kMaxAttempts;
    if (isLimited) {
      _logRateLimitViolation(phone);
    }
    return isLimited;
  }

  /// حظر رقم هاتف بتعبئة المحاولات
  static void _blockPhone(String phone) {
    _attemptHistory.putIfAbsent(phone, () => []);
    final now = DateTime.now();
    // Fill up to max attempts to ensure block
    final currentCount = _attemptHistory[phone]!.length;
    for (var i = currentCount; i < kMaxAttempts; i++) {
      _attemptHistory[phone]!.add(now);
    }
    _logRateLimitViolation(phone);
  }

  /// حساب وقت رفع الحظر عن رقم هاتف
  static DateTime? _getBlockedUntil(String phone) {
    final attempts = _attemptHistory[phone];
    if (attempts == null || attempts.isEmpty) return null;

    // أقدم محاولة في النافذة تحدد متى يُرفع الحظر
    final oldestAttempt = attempts.reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );

    return oldestAttempt.add(kRateLimitWindow);
  }

  /// تسجيل انتهاك Rate Limit للمراقبة الأمنية
  static void _logRateLimitViolation(String phone) {
    // Mask phone for privacy: show first 4 and last 2 digits
    final masked = phone.length > 6
        ? '${phone.substring(0, 4)}****${phone.substring(phone.length - 2)}'
        : '****';
    final attemptCount = _attemptHistory[phone]?.length ?? 0;
    debugPrint(
      '[OTP-SECURITY] Rate limit violation for $masked: '
      '$attemptCount attempts in ${kRateLimitWindow.inMinutes}min window. '
      'Blocked until ${_getBlockedUntil(phone)?.toIso8601String() ?? "unknown"}.',
    );
  }
}

// ============================================================================
// RESULT CLASSES
// ============================================================================

/// نتيجة إرسال OTP
class OtpSendResult {
  final bool isSuccess;
  final String? error;
  final DateTime? blockedUntil;
  final Duration? cooldown;

  const OtpSendResult._({
    required this.isSuccess,
    this.error,
    this.blockedUntil,
    this.cooldown,
  });

  factory OtpSendResult.success() => const OtpSendResult._(isSuccess: true);

  factory OtpSendResult.error(String message) => OtpSendResult._(
    isSuccess: false,
    error: message,
  );

  factory OtpSendResult.rateLimited(DateTime? until) => OtpSendResult._(
    isSuccess: false,
    error: 'تم تجاوز الحد الأقصى للمحاولات',
    blockedUntil: until,
  );

  factory OtpSendResult.cooldown(Duration remaining) => OtpSendResult._(
    isSuccess: false,
    error: 'يرجى الانتظار قبل إعادة الإرسال',
    cooldown: remaining,
  );
}

/// نتيجة التحقق من OTP
class OtpVerifyResult {
  final bool isSuccess;
  final String? error;
  final int? remainingAttempts;
  final DateTime? blockedUntil;

  const OtpVerifyResult._({
    required this.isSuccess,
    this.error,
    this.remainingAttempts,
    this.blockedUntil,
  });

  factory OtpVerifyResult.success() => const OtpVerifyResult._(isSuccess: true);

  factory OtpVerifyResult.invalid(int remaining) => OtpVerifyResult._(
    isSuccess: false,
    error: 'رمز التحقق غير صحيح',
    remainingAttempts: remaining,
  );

  factory OtpVerifyResult.expired() => const OtpVerifyResult._(
    isSuccess: false,
    error: 'انتهت صلاحية رمز التحقق',
  );

  factory OtpVerifyResult.noOtpSent() => const OtpVerifyResult._(
    isSuccess: false,
    error: 'لم يتم إرسال رمز التحقق',
  );

  factory OtpVerifyResult.maxAttemptsExceeded() => const OtpVerifyResult._(
    isSuccess: false,
    error: 'تم تجاوز الحد الأقصى للمحاولات',
    remainingAttempts: 0,
  );

  factory OtpVerifyResult.rateLimited(DateTime? until) => OtpVerifyResult._(
    isSuccess: false,
    error: 'يرجى الانتظار قبل المحاولة مرة أخرى',
    blockedUntil: until,
  );

  factory OtpVerifyResult.error(String message) => OtpVerifyResult._(
    isSuccess: false,
    error: message,
  );
}
