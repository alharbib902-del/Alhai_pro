/// خدمة تسجيل أحداث الأمان - Security Logger
///
/// تسجل جميع الأحداث الأمنية للمراقبة والتحليل
library;

import '../core/monitoring/production_logger.dart';

/// أنواع الأحداث الأمنية
enum SecurityEventType {
  // OTP
  otpSent,
  otpVerifySuccess,
  otpVerifyFailed,
  otpExpired,
  otpRateLimited,
  
  // PIN
  pinVerifySuccess,
  pinVerifyFailed,
  pinLocked,
  pinCreated,
  pinChanged,
  pinRemoved,
  
  // Session
  sessionStarted,
  sessionEnded,
  sessionExpired,
  sessionRefreshed,
  
  // Biometric
  biometricSuccess,
  biometricFailed,
  biometricEnabled,
  biometricDisabled,
  
  // Auth
  loginSuccess,
  loginFailed,
  logoutSuccess,
}

/// سجل أمني
class SecurityLogEntry {
  final DateTime timestamp;
  final SecurityEventType type;
  final String? userId;
  final String? phone;
  final String? details;
  final Map<String, dynamic>? metadata;

  SecurityLogEntry({
    required this.type,
    this.userId,
    this.phone,
    this.details,
    this.metadata,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
    'userId': userId,
    'phone': phone,
    'details': details,
    'metadata': metadata,
  };

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write(type.name);
    if (phone != null) buffer.write(' | phone: ${_maskPhone(phone!)}');
    if (details != null) buffer.write(' | $details');
    return buffer.toString();
  }

  String _maskPhone(String phone) {
    if (phone.length < 6) return '***';
    return '${phone.substring(0, 4)}****${phone.substring(phone.length - 2)}';
  }
}

/// خدمة تسجيل الأمان
class SecurityLogger {
  SecurityLogger._();

  // السجلات في الذاكرة (آخر 100 سجل)
  static final List<SecurityLogEntry> _logs = [];
  static const int _maxLogs = 100;

  // Callbacks للمستمعين
  static final List<void Function(SecurityLogEntry)> _listeners = [];

  /// إضافة مستمع للأحداث
  static void addListener(void Function(SecurityLogEntry) listener) {
    _listeners.add(listener);
  }

  /// إزالة مستمع
  static void removeListener(void Function(SecurityLogEntry) listener) {
    _listeners.remove(listener);
  }

  /// تسجيل حدث
  static void log(SecurityLogEntry entry) {
    // إضافة للسجلات
    _logs.add(entry);
    
    // الحفاظ على الحد الأقصى
    while (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // طباعة في Debug
    final icon = _getIcon(entry.type);
    AppLogger.debug('SECURITY $icon ${entry.toString()}', tag: 'Security');

    // إشعار المستمعين
    for (final listener in _listeners) {
      listener(entry);
    }
  }

  /// تسجيل سريع
  static void logEvent(
    SecurityEventType type, {
    String? userId,
    String? phone,
    String? details,
    Map<String, dynamic>? metadata,
  }) {
    log(SecurityLogEntry(
      type: type,
      userId: userId,
      phone: phone,
      details: details,
      metadata: metadata,
    ));
  }

  // ============================================================================
  // OTP LOGGING
  // ============================================================================

  static void logOtpSent(String phone) {
    logEvent(SecurityEventType.otpSent, phone: phone);
  }

  static void logOtpVerifySuccess(String phone) {
    logEvent(SecurityEventType.otpVerifySuccess, phone: phone);
  }

  static void logOtpVerifyFailed(String phone, int remainingAttempts) {
    logEvent(
      SecurityEventType.otpVerifyFailed,
      phone: phone,
      details: 'remaining=$remainingAttempts',
    );
  }

  static void logOtpExpired(String phone) {
    logEvent(SecurityEventType.otpExpired, phone: phone);
  }

  static void logOtpRateLimited(String phone) {
    logEvent(SecurityEventType.otpRateLimited, phone: phone);
  }

  // ============================================================================
  // PIN LOGGING
  // ============================================================================

  static void logPinVerifySuccess() {
    logEvent(SecurityEventType.pinVerifySuccess);
  }

  static void logPinVerifyFailed(int remainingAttempts) {
    logEvent(
      SecurityEventType.pinVerifyFailed,
      details: 'remaining=$remainingAttempts',
    );
  }

  static void logPinLocked(Duration duration) {
    logEvent(
      SecurityEventType.pinLocked,
      details: 'duration=${duration.inMinutes}min',
    );
  }

  static void logPinCreated() {
    logEvent(SecurityEventType.pinCreated);
  }

  static void logPinChanged() {
    logEvent(SecurityEventType.pinChanged);
  }

  static void logPinRemoved() {
    logEvent(SecurityEventType.pinRemoved);
  }

  // ============================================================================
  // SESSION LOGGING
  // ============================================================================

  static void logSessionStarted(String userId) {
    logEvent(SecurityEventType.sessionStarted, userId: userId);
  }

  static void logSessionEnded() {
    logEvent(SecurityEventType.sessionEnded);
  }

  static void logSessionExpired() {
    logEvent(SecurityEventType.sessionExpired);
  }

  static void logSessionRefreshed() {
    logEvent(SecurityEventType.sessionRefreshed);
  }

  // ============================================================================
  // BIOMETRIC LOGGING
  // ============================================================================

  static void logBiometricSuccess() {
    logEvent(SecurityEventType.biometricSuccess);
  }

  static void logBiometricFailed(String reason) {
    logEvent(SecurityEventType.biometricFailed, details: reason);
  }

  static void logBiometricEnabled() {
    logEvent(SecurityEventType.biometricEnabled);
  }

  static void logBiometricDisabled() {
    logEvent(SecurityEventType.biometricDisabled);
  }

  // ============================================================================
  // AUTH LOGGING
  // ============================================================================

  static void logLoginSuccess(String userId) {
    logEvent(SecurityEventType.loginSuccess, userId: userId);
  }

  static void logLoginFailed(String? phone, String reason) {
    logEvent(
      SecurityEventType.loginFailed,
      phone: phone,
      details: reason,
    );
  }

  static void logLogoutSuccess() {
    logEvent(SecurityEventType.logoutSuccess);
  }

  // ============================================================================
  // HELPERS
  // ============================================================================

  /// الحصول على السجلات
  static List<SecurityLogEntry> getLogs() => List.unmodifiable(_logs);

  /// الحصول على سجلات نوع معين
  static List<SecurityLogEntry> getLogsByType(SecurityEventType type) {
    return _logs.where((e) => e.type == type).toList();
  }

  /// مسح السجلات
  static void clear() {
    _logs.clear();
  }

  /// أيقونة لكل نوع
  static String _getIcon(SecurityEventType type) {
    return switch (type) {
      SecurityEventType.otpSent => '📤',
      SecurityEventType.otpVerifySuccess => '✅',
      SecurityEventType.otpVerifyFailed => '❌',
      SecurityEventType.otpExpired => '⏰',
      SecurityEventType.otpRateLimited => '🚫',
      SecurityEventType.pinVerifySuccess => '✅',
      SecurityEventType.pinVerifyFailed => '❌',
      SecurityEventType.pinLocked => '🔒',
      SecurityEventType.pinCreated => '🆕',
      SecurityEventType.pinChanged => '🔄',
      SecurityEventType.pinRemoved => '🗑️',
      SecurityEventType.sessionStarted => '▶️',
      SecurityEventType.sessionEnded => '⏹️',
      SecurityEventType.sessionExpired => '⏰',
      SecurityEventType.sessionRefreshed => '🔄',
      SecurityEventType.biometricSuccess => '👆',
      SecurityEventType.biometricFailed => '❌',
      SecurityEventType.biometricEnabled => '✅',
      SecurityEventType.biometricDisabled => '⚪',
      SecurityEventType.loginSuccess => '🟢',
      SecurityEventType.loginFailed => '🔴',
      SecurityEventType.logoutSuccess => '👋',
    };
  }
}
