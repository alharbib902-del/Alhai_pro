/// خدمة OTP عبر WhatsApp باستخدام WaSenderAPI
///
/// توفر إرسال والتحقق من رموز OTP عبر WhatsApp مع:
/// - Rate Limiting
/// - OTP Expiry
/// - Secure Storage
/// - Certificate Pinning
library;

import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import '../core/monitoring/production_logger.dart';
import '../core/config/whatsapp_config.dart';
import '../core/network/secure_http_client.dart';
import '../security/secure_storage_service.dart';
import '../security/security_logger.dart';

// ============================================================================
// OTP DATA
// ============================================================================

/// بيانات OTP المخزنة
class OtpData {
  final String phone;
  final String otpHash;
  final String otpSalt;
  final DateTime createdAt;
  final DateTime expiresAt;
  int verifyAttempts;

  OtpData({
    required this.phone,
    required this.otpHash,
    this.otpSalt = '',
    required this.createdAt,
    required this.expiresAt,
    this.verifyAttempts = 0,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remainingTime {
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Map<String, dynamic> toJson() => {
        'phone': phone,
        'otpHash': otpHash,
        'otpSalt': otpSalt,
        'createdAt': createdAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
        'verifyAttempts': verifyAttempts,
      };

  factory OtpData.fromJson(Map<String, dynamic> json) => OtpData(
        phone: json['phone'],
        otpHash: json['otpHash'],
        otpSalt: json['otpSalt'] ?? '',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now(),
        expiresAt:
            DateTime.tryParse(json['expiresAt'] as String) ?? DateTime.now(),
        verifyAttempts: json['verifyAttempts'] ?? 0,
      );
}

// ============================================================================
// RESULT CLASSES
// ============================================================================

/// نتيجة إرسال OTP
class WhatsAppOtpSendResult {
  final bool isSuccess;
  final String? error;
  final DateTime? blockedUntil;
  final Duration? cooldown;
  final String? messageId;

  /// رمز OTP في وضع التطوير (للعرض في UI بدلاً من Console فقط)
  final String? devOtp;

  const WhatsAppOtpSendResult._({
    required this.isSuccess,
    this.error,
    this.blockedUntil,
    this.cooldown,
    this.messageId,
    this.devOtp,
  });

  factory WhatsAppOtpSendResult.success({String? messageId, String? devOtp}) =>
      WhatsAppOtpSendResult._(
          isSuccess: true, messageId: messageId, devOtp: devOtp);

  factory WhatsAppOtpSendResult.error(String message) =>
      WhatsAppOtpSendResult._(isSuccess: false, error: message);

  factory WhatsAppOtpSendResult.rateLimited(DateTime until) =>
      WhatsAppOtpSendResult._(
        isSuccess: false,
        error: 'تم تجاوز الحد الأقصى للإرسال',
        blockedUntil: until,
      );

  factory WhatsAppOtpSendResult.cooldown(Duration remaining) =>
      WhatsAppOtpSendResult._(
        isSuccess: false,
        error: 'يرجى الانتظار قبل إعادة الإرسال',
        cooldown: remaining,
      );
}

/// نتيجة التحقق من OTP
class WhatsAppOtpVerifyResult {
  final bool isSuccess;
  final String? error;
  final int? remainingAttempts;

  const WhatsAppOtpVerifyResult._({
    required this.isSuccess,
    this.error,
    this.remainingAttempts,
  });

  factory WhatsAppOtpVerifyResult.success() =>
      const WhatsAppOtpVerifyResult._(isSuccess: true);

  factory WhatsAppOtpVerifyResult.invalid(int remaining) =>
      WhatsAppOtpVerifyResult._(
        isSuccess: false,
        error: 'رمز التحقق غير صحيح',
        remainingAttempts: remaining,
      );

  factory WhatsAppOtpVerifyResult.expired() => const WhatsAppOtpVerifyResult._(
        isSuccess: false,
        error: 'انتهت صلاحية رمز التحقق',
      );

  factory WhatsAppOtpVerifyResult.noOtpSent() =>
      const WhatsAppOtpVerifyResult._(
        isSuccess: false,
        error: 'لم يتم إرسال رمز التحقق',
      );

  factory WhatsAppOtpVerifyResult.maxAttemptsExceeded() =>
      const WhatsAppOtpVerifyResult._(
        isSuccess: false,
        error: 'تم تجاوز الحد الأقصى للمحاولات',
        remainingAttempts: 0,
      );

  factory WhatsAppOtpVerifyResult.error(String message) =>
      WhatsAppOtpVerifyResult._(isSuccess: false, error: message);
}

// ============================================================================
// WHATSAPP OTP SERVICE
// ============================================================================

/// خدمة OTP عبر WhatsApp
class WhatsAppOtpService {
  /// Dio client مع Certificate Pinning
  static Dio? _dio;

  /// الحصول على Dio client
  static Dio get _client {
    _dio ??= SecureHttpClient.create(
      baseUrl: WhatsAppConfig.baseUrl,
      headers: WhatsAppConfig.headers,
      certificateFingerprint: CertificateFingerprints.wasender,
    );
    return _dio!;
  }

  // Cache للـ OTP (في الذاكرة)
  static final Map<String, OtpData> _otpCache = {};

  // تتبع طلبات الإرسال
  static final Map<String, List<DateTime>> _sendHistory = {};

  // تتبع محاولات التحقق لكل رقم (5 محاولات في 15 دقيقة)
  static final Map<String, List<DateTime>> _verifyAttemptHistory = {};

  // آخر وقت إرسال لكل رقم
  static final Map<String, DateTime> _lastSendTime = {};

  /// الحد الأقصى لمحاولات التحقق لكل رقم خلال 15 دقيقة
  static const int _kMaxVerifyAttemptsPerWindow = 5;
  static const Duration _kVerifyRateLimitWindow = Duration(minutes: 15);

  // Storage keys
  static const String _otpStorageKey = 'whatsapp_otp_data';
  static const String _sendHistoryKey = 'whatsapp_send_history';
  static const String _lastSendTimeKey = 'whatsapp_last_send_time';
  static bool _rateLimitLoaded = false;

  // ============================================================================
  // SEND OTP
  // ============================================================================

  /// إرسال OTP عبر WhatsApp
  static Future<WhatsAppOtpSendResult> sendOtp({
    required String phone,
  }) async {
    // تحميل بيانات Rate Limiting
    await _loadRateLimitData();

    // التحقق من الإعدادات
    if (!WhatsAppConfig.isConfigured && !WhatsAppConfig.isDevMode) {
      return WhatsAppOtpSendResult.error(
        'WhatsApp configuration is incomplete. ${WhatsAppConfig.configurationError}',
      );
    }

    // تنسيق الرقم
    final formattedPhone = _formatPhone(phone);

    // التحقق من Rate Limiting
    if (_isRateLimited(formattedPhone)) {
      SecurityLogger.logOtpRateLimited(formattedPhone);
      final blockedUntil = _getBlockedUntil(formattedPhone);
      return WhatsAppOtpSendResult.rateLimited(blockedUntil!);
    }

    // التحقق من Cooldown
    final cooldown = _getCooldownRemaining(formattedPhone);
    if (cooldown != null && cooldown > Duration.zero) {
      return WhatsAppOtpSendResult.cooldown(cooldown);
    }

    // توليد OTP مع salt عشوائي لكل جلسة
    final otp = _generateOtp();
    final salt = _generateSalt();
    final otpHash = _hashOtp(otp, salt);

    try {
      // 🔧 وضع التطوير: حفظ OTP بدون إرساله عبر WhatsApp
      // ⚠️ للاختبار فقط - يظهر OTP في Console
      if (WhatsAppConfig.isDevMode) {
        AppLogger.debug(
          'DEV MODE - OTP: $otp for $formattedPhone '
          '(valid for ${WhatsAppConfig.otpExpiryMinutes} min)',
          tag: 'OTP',
        );

        // حفظ OTP
        final now = DateTime.now();
        final otpData = OtpData(
          phone: formattedPhone,
          otpHash: otpHash,
          otpSalt: salt,
          createdAt: now,
          expiresAt:
              now.add(const Duration(minutes: WhatsAppConfig.otpExpiryMinutes)),
        );

        _otpCache[formattedPhone] = otpData;
        await _saveOtpToStorage(otpData);
        _recordSend(formattedPhone);
        SecurityLogger.logOtpSent(formattedPhone);

        return WhatsAppOtpSendResult.success(
            messageId: 'dev-mode', devOtp: otp);
      }

      // إرسال عبر WaSenderAPI (الإنتاج فقط)
      // حسب توثيق WaSenderAPI: POST /send-message
      // Payload: { "to": "+1234567890", "text": "message" }
      final response = await _client.post(
        '/send-message',
        data: {
          'to': '+$formattedPhone',
          'text': WhatsAppConfig.getOtpMessage(otp),
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // حفظ OTP
        final now = DateTime.now();
        final otpData = OtpData(
          phone: formattedPhone,
          otpHash: otpHash,
          otpSalt: salt,
          createdAt: now,
          expiresAt:
              now.add(const Duration(minutes: WhatsAppConfig.otpExpiryMinutes)),
        );

        _otpCache[formattedPhone] = otpData;
        await _saveOtpToStorage(otpData);

        // تسجيل الإرسال
        _recordSend(formattedPhone);
        SecurityLogger.logOtpSent(formattedPhone);

        final messageId = response.data?['id']?.toString();
        return WhatsAppOtpSendResult.success(messageId: messageId);
      } else {
        return WhatsAppOtpSendResult.error(
          'فشل إرسال الرسالة: ${response.statusMessage}',
        );
      }
    } on DioException catch (e) {
      String errorMessage;
      if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'فشل الاتصال بالخادم. تحقق من اتصالك بالإنترنت';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'انتهت مهلة الاتصال';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'خطأ في المصادقة';
      } else if (e.response?.statusCode == 429) {
        errorMessage = 'تم تجاوز حد الطلبات. حاول لاحقاً';
      } else {
        errorMessage = 'حدث خطأ: ${e.message}';
      }
      return WhatsAppOtpSendResult.error(errorMessage);
    } catch (e) {
      return WhatsAppOtpSendResult.error('حدث خطأ غير متوقع');
    }
  }

  // ============================================================================
  // VERIFY OTP
  // ============================================================================

  /// التحقق من OTP
  static Future<WhatsAppOtpVerifyResult> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final formattedPhone = _formatPhone(phone);

    // فحص Rate Limiting لمحاولات التحقق (5 محاولات في 15 دقيقة لكل رقم)
    if (_isVerifyRateLimited(formattedPhone)) {
      _logVerifyRateLimitViolation(formattedPhone);
      return WhatsAppOtpVerifyResult.maxAttemptsExceeded();
    }

    // تسجيل محاولة التحقق
    _recordVerifyAttempt(formattedPhone);

    // جلب OTP من الـ cache أو storage
    OtpData? otpData = _otpCache[formattedPhone];
    otpData ??= await _loadOtpFromStorage(formattedPhone);

    if (otpData == null) {
      return WhatsAppOtpVerifyResult.noOtpSent();
    }

    // التحقق من الصلاحية
    if (otpData.isExpired) {
      SecurityLogger.logOtpExpired(formattedPhone);
      await _clearOtp(formattedPhone);
      return WhatsAppOtpVerifyResult.expired();
    }

    // التحقق من عدد المحاولات (per-OTP limit from config)
    if (otpData.verifyAttempts >= WhatsAppConfig.maxVerifyAttempts) {
      await _clearOtp(formattedPhone);
      return WhatsAppOtpVerifyResult.maxAttemptsExceeded();
    }

    // التحقق من OTP باستخدام salt المخزن ومقارنة ثابتة الوقت
    final inputHash = _hashOtp(otp, otpData.otpSalt);
    // تأخير مقاوم للـ brute-force - يبطئ محاولات التخمين
    await Future.delayed(const Duration(milliseconds: 100));
    if (_constantTimeEquals(inputHash, otpData.otpHash)) {
      // نجاح - مسح OTP ومسح سجل المحاولات
      SecurityLogger.logOtpVerifySuccess(formattedPhone);
      await _clearOtp(formattedPhone);
      _verifyAttemptHistory.remove(formattedPhone);
      return WhatsAppOtpVerifyResult.success();
    }

    // فشل - زيادة المحاولات
    otpData.verifyAttempts++;
    _otpCache[formattedPhone] = otpData;
    await _saveOtpToStorage(otpData);

    final remaining = WhatsAppConfig.maxVerifyAttempts - otpData.verifyAttempts;

    if (remaining <= 0) {
      await _clearOtp(formattedPhone);
      return WhatsAppOtpVerifyResult.maxAttemptsExceeded();
    }

    SecurityLogger.logOtpVerifyFailed(formattedPhone, remaining);
    return WhatsAppOtpVerifyResult.invalid(remaining);
  }

  /// تسجيل محاولة تحقق لرقم هاتف محدد
  static void _recordVerifyAttempt(String phone) {
    _verifyAttemptHistory.putIfAbsent(phone, () => []);
    _verifyAttemptHistory[phone]!.add(DateTime.now());
    // تنظيف المحاولات القديمة
    final cutoff = DateTime.now().subtract(_kVerifyRateLimitWindow);
    _verifyAttemptHistory[phone]!.removeWhere((t) => t.isBefore(cutoff));
  }

  /// هل تم تجاوز حد محاولات التحقق لهذا الرقم
  static bool _isVerifyRateLimited(String phone) {
    final attempts = _verifyAttemptHistory[phone];
    if (attempts == null) return false;
    final cutoff = DateTime.now().subtract(_kVerifyRateLimitWindow);
    attempts.removeWhere((t) => t.isBefore(cutoff));
    return attempts.length >= _kMaxVerifyAttemptsPerWindow;
  }

  /// تسجيل انتهاك Rate Limit لمحاولات التحقق
  static void _logVerifyRateLimitViolation(String phone) {
    final masked = phone.length > 6
        ? '${phone.substring(0, 4)}****${phone.substring(phone.length - 2)}'
        : '****';
    final count = _verifyAttemptHistory[phone]?.length ?? 0;
    AppLogger.debug(
      'SECURITY: OTP verify rate limit violation for $masked: '
      '$count attempts in ${_kVerifyRateLimitWindow.inMinutes}min window',
      tag: 'OTP-SECURITY',
    );
  }

  // ============================================================================
  // RESEND OTP
  // ============================================================================

  /// إعادة إرسال OTP
  static Future<WhatsAppOtpSendResult> resendOtp({
    required String phone,
  }) async {
    final formattedPhone = _formatPhone(phone);

    // التحقق من Cooldown
    final cooldown = _getCooldownRemaining(formattedPhone);
    if (cooldown != null && cooldown > Duration.zero) {
      return WhatsAppOtpSendResult.cooldown(cooldown);
    }

    // مسح OTP القديم
    await _clearOtp(formattedPhone);

    // إرسال جديد
    return sendOtp(phone: phone);
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// توليد OTP عشوائي
  static String _generateOtp() {
    final random = Random.secure();
    final otp = List.generate(
      WhatsAppConfig.otpLength,
      (_) => random.nextInt(10),
    ).join();
    return otp;
  }

  /// توليد salt عشوائي آمن لكل جلسة OTP
  static String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  /// تشفير OTP مع salt باستخدام HMAC-SHA256
  static String _hashOtp(String otp, String salt) {
    final key = utf8.encode(salt);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(utf8.encode(otp));
    return digest.toString();
  }

  /// مقارنة ثابتة الوقت لمنع هجمات التوقيت
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// تنسيق رقم الهاتف
  static String _formatPhone(String phone) {
    // إزالة المسافات والرموز
    var cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // إزالة + إذا موجودة
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    // إضافة كود السعودية إذا لم يكن موجوداً
    if (cleaned.startsWith('05')) {
      cleaned = '966${cleaned.substring(1)}';
    } else if (cleaned.startsWith('5')) {
      cleaned = '966$cleaned';
    }

    return cleaned;
  }

  // ============================================================================
  // RATE LIMITING
  // ============================================================================

  /// تحميل بيانات Rate Limiting من التخزين الآمن
  static Future<void> _loadRateLimitData() async {
    if (_rateLimitLoaded) return;
    _rateLimitLoaded = true;
    try {
      final historyJson = await SecureStorageService.read(_sendHistoryKey);
      if (historyJson != null) {
        final historyMap = jsonDecode(historyJson) as Map<String, dynamic>;
        final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
        for (final entry in historyMap.entries) {
          final times = (entry.value as List)
              .map((e) => DateTime.tryParse(e as String) ?? DateTime.now())
              .where((t) => t.isAfter(oneHourAgo))
              .toList();
          if (times.isNotEmpty) {
            _sendHistory[entry.key] = times;
          }
        }
      }
      final lastSendJson = await SecureStorageService.read(_lastSendTimeKey);
      if (lastSendJson != null) {
        final lastSendMap = jsonDecode(lastSendJson) as Map<String, dynamic>;
        for (final entry in lastSendMap.entries) {
          _lastSendTime[entry.key] =
              DateTime.tryParse(entry.value as String) ?? DateTime.now();
        }
      }
    } catch (e) {
      AppLogger.debug('Failed to load rate limit data: $e', tag: 'OTP');
    }
  }

  /// حفظ بيانات Rate Limiting في التخزين الآمن
  static Future<void> _persistRateLimitData() async {
    try {
      final historyMap = <String, List<String>>{};
      for (final entry in _sendHistory.entries) {
        historyMap[entry.key] =
            entry.value.map((e) => e.toIso8601String()).toList();
      }
      await SecureStorageService.write(_sendHistoryKey, jsonEncode(historyMap));

      final lastSendMap = <String, String>{};
      for (final entry in _lastSendTime.entries) {
        lastSendMap[entry.key] = entry.value.toIso8601String();
      }
      await SecureStorageService.write(
          _lastSendTimeKey, jsonEncode(lastSendMap));
    } catch (e) {
      AppLogger.debug('Failed to persist rate limit data: $e', tag: 'OTP');
    }
  }

  static void _recordSend(String phone) {
    _sendHistory.putIfAbsent(phone, () => []);
    _sendHistory[phone]!.add(DateTime.now());
    _lastSendTime[phone] = DateTime.now();

    // إزالة السجلات القديمة (أكثر من ساعة)
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    _sendHistory[phone]!.removeWhere((time) => time.isBefore(oneHourAgo));

    // حفظ بيانات Rate Limiting
    _persistRateLimitData();
  }

  static bool _isRateLimited(String phone) {
    final history = _sendHistory[phone];
    if (history == null) return false;

    // إزالة السجلات القديمة
    final oneHourAgo = DateTime.now().subtract(const Duration(hours: 1));
    history.removeWhere((time) => time.isBefore(oneHourAgo));

    final isLimited = history.length >= WhatsAppConfig.maxSendRequestsPerHour;
    if (isLimited) {
      final masked = phone.length > 6
          ? '${phone.substring(0, 4)}****${phone.substring(phone.length - 2)}'
          : '****';
      AppLogger.debug(
        'SECURITY: OTP send rate limit hit for $masked: '
        '${history.length} sends in 1 hour',
        tag: 'OTP-SECURITY',
      );
    }
    return isLimited;
  }

  static DateTime? _getBlockedUntil(String phone) {
    final history = _sendHistory[phone];
    if (history == null || history.isEmpty) return null;

    final oldest = history.reduce((a, b) => a.isBefore(b) ? a : b);
    return oldest.add(const Duration(hours: 1));
  }

  static Duration? _getCooldownRemaining(String phone) {
    final lastSend = _lastSendTime[phone];
    if (lastSend == null) return null;

    final cooldownEnd = lastSend.add(
      const Duration(seconds: WhatsAppConfig.resendCooldownSeconds),
    );
    final remaining = cooldownEnd.difference(DateTime.now());

    return remaining.isNegative ? null : remaining;
  }

  // ============================================================================
  // STORAGE
  // ============================================================================

  static Future<void> _saveOtpToStorage(OtpData data) async {
    try {
      final json = jsonEncode(data.toJson());
      await SecureStorageService.write('${_otpStorageKey}_${data.phone}', json);
    } catch (e) {
      AppLogger.debug('Failed to save OTP to storage: $e', tag: 'OTP');
    }
  }

  static Future<OtpData?> _loadOtpFromStorage(String phone) async {
    try {
      final json = await SecureStorageService.read('${_otpStorageKey}_$phone');
      if (json == null) return null;
      return OtpData.fromJson(jsonDecode(json));
    } catch (e) {
      AppLogger.debug('Failed to load OTP from storage: $e', tag: 'OTP');
      return null;
    }
  }

  static Future<void> _clearOtp(String phone) async {
    _otpCache.remove(phone);
    try {
      await SecureStorageService.delete('${_otpStorageKey}_$phone');
    } catch (e) {
      AppLogger.debug('Failed to clear OTP from storage: $e', tag: 'OTP');
    }
  }

  // ============================================================================
  // STATE
  // ============================================================================

  /// الحصول على بيانات OTP الحالية (للـ UI)
  static OtpData? getOtpData(String phone) {
    return _otpCache[_formatPhone(phone)];
  }

  /// مسح كل البيانات (للاختبارات)
  static Future<void> reset() async {
    _otpCache.clear();
    _sendHistory.clear();
    _verifyAttemptHistory.clear();
    _lastSendTime.clear();
    _rateLimitLoaded = false;
    try {
      await SecureStorageService.delete(_sendHistoryKey);
      await SecureStorageService.delete(_lastSendTimeKey);
    } catch (_) {}
  }

  /// الحصول على الوقت المتبقي للـ cooldown
  static Duration? getCooldownRemaining(String phone) {
    return _getCooldownRemaining(_formatPhone(phone));
  }

  /// هل يمكن إعادة الإرسال؟
  static bool canResend(String phone) {
    final cooldown = _getCooldownRemaining(_formatPhone(phone));
    return cooldown == null || cooldown <= Duration.zero;
  }
}
