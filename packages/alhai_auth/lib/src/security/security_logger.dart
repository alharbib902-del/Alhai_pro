/// خدمة تسجيل أحداث الأمان - Security Logger
///
/// تسجل جميع الأحداث الأمنية للمراقبة والتحليل
/// يحتفظ بسجل في الذاكرة للوصول السريع ويرسل دورياً إلى قاعدة البيانات
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    show Supabase, SupabaseClient;

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
    DateTime? overrideTimestamp,
  }) : timestamp = overrideTimestamp ?? DateTime.now();

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
///
/// يحتفظ بسجل في الذاكرة (آخر 100 سجل) للوصول السريع،
/// ويرسل الأحداث إلى جدول `security_events` في Supabase دورياً.
///
/// استخدام:
///   await SecurityLogger.initialize(storeId: '...');
///   SecurityLogger.logLoginSuccess('user-1');
class SecurityLogger {
  SecurityLogger._();

  // السجلات في الذاكرة (آخر 100 سجل)
  static final List<SecurityLogEntry> _logs = [];
  static const int _maxLogs = 100;

  // Callbacks للمستمعين
  static final List<void Function(SecurityLogEntry)> _listeners = [];

  // ── Persistence ──────────────────────────────────────────────────────────
  /// Buffer of entries waiting to be flushed to the database.
  static final List<SecurityLogEntry> _pendingFlush = [];

  /// Periodic timer that triggers DB flush.
  static Timer? _flushTimer;

  /// How often to flush pending entries to the database.
  static const Duration _flushInterval = Duration(seconds: 30);

  /// Max entries to buffer before forcing an immediate flush.
  static const int _maxPendingBeforeFlush = 20;

  /// Store ID set during [initialize] -- used when writing events.
  static String? _storeId;

  /// Whether [initialize] has been called.
  @visibleForTesting
  static bool initialized = false;

  // ── Initialization ───────────────────────────────────────────────────────

  /// Initialize the logger and start periodic DB flushing.
  ///
  /// Call once at app startup (e.g. in splash screen) after Supabase is ready.
  /// [storeId] is optional -- if null, events are still logged in-memory and
  /// flushed without a store_id.
  /// [loadRecent] controls whether to pre-populate the in-memory buffer from
  /// the database on startup (default true).
  static Future<void> initialize({
    String? storeId,
    bool loadRecent = true,
  }) async {
    _storeId = storeId;

    if (loadRecent) {
      await _loadRecentFromDb();
    }

    // Start periodic flush timer (idempotent -- stops any existing timer)
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(_flushInterval, (_) => flush());

    initialized = true;
  }

  /// Update the store ID after initialization (e.g. when user selects store).
  static void setStoreId(String storeId) {
    _storeId = storeId;
  }

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

    // Add to pending flush buffer
    _pendingFlush.add(entry);

    // Force immediate flush if buffer is large
    if (_pendingFlush.length >= _maxPendingBeforeFlush) {
      flush();
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

  /// مسح السجلات (in-memory only; DB records are retained)
  static void clear() {
    _logs.clear();
    _pendingFlush.clear();
  }

  /// Stop the periodic flush timer and flush remaining entries.
  static Future<void> dispose() async {
    _flushTimer?.cancel();
    _flushTimer = null;
    await flush();
    initialized = false;
  }

  // ── Database Persistence ──────────────────────────────────────────────────

  /// Flush all pending entries to the `security_events` table.
  ///
  /// Safe to call at any time. If Supabase is unavailable (offline mode,
  /// not yet initialized, etc.) entries remain in the buffer and will be
  /// retried on the next flush cycle.
  static Future<void> flush() async {
    if (_pendingFlush.isEmpty) return;

    final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      // Supabase not initialized yet -- keep entries in buffer
      return;
    }

    // Snapshot the pending list and clear it so new events that arrive
    // during the async call don't get lost.
    final batch = List<SecurityLogEntry>.from(_pendingFlush);
    _pendingFlush.clear();

    try {
      final eventsJson = batch
          .map((e) => {
                'store_id': _storeId,
                'user_id': e.userId,
                'phone': e.phone,
                'event_type': e.type.name,
                'details': e.details,
                'metadata': e.metadata != null ? jsonEncode(e.metadata) : null,
                'created_at': e.timestamp.toUtc().toIso8601String(),
              })
          .toList();

      await client.rpc(
        'insert_security_events',
        params: {'p_events': eventsJson},
      );

      if (kDebugMode) {
        debugPrint('[SecurityLogger] Flushed ${batch.length} events to DB');
      }
    } catch (e) {
      // Put entries back at the front of the buffer so they are retried.
      _pendingFlush.insertAll(0, batch);

      if (kDebugMode) {
        debugPrint('[SecurityLogger] Flush failed ($e), '
            '${_pendingFlush.length} events pending');
      }
    }
  }

  /// Load recent security events from the database into the in-memory buffer.
  /// Called during [initialize].
  static Future<void> _loadRecentFromDb() async {
    final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      return; // Supabase not available
    }

    try {
      // Build query -- filter must come before order/limit
      var query = client.from('security_events').select();

      // If we have a store ID, scope the query
      if (_storeId != null && _storeId!.isNotEmpty) {
        query = query.eq('store_id', _storeId!);
      }

      final List<dynamic> rows =
          await query.order('created_at', ascending: false).limit(_maxLogs);

      // Insert at the front (newest first from DB, reverse to get
      // chronological order in _logs).
      for (final row in rows.reversed) {
        final map = row as Map<String, dynamic>;
        final eventTypeName = map['event_type'] as String? ?? '';
        final eventType = SecurityEventType.values.where(
          (e) => e.name == eventTypeName,
        );
        if (eventType.isEmpty) continue;

        final entry = SecurityLogEntry(
          type: eventType.first,
          userId: map['user_id'] as String?,
          phone: map['phone'] as String?,
          details: map['details'] as String?,
          metadata: map['metadata'] is Map
              ? Map<String, dynamic>.from(map['metadata'] as Map)
              : map['metadata'] is String
                  ? (jsonDecode(map['metadata'] as String)
                      as Map<String, dynamic>?)
                  : null,
          overrideTimestamp: DateTime.tryParse(
            map['created_at'] as String? ?? '',
          ),
        );

        // Only add if not exceeding max
        if (_logs.length < _maxLogs) {
          _logs.add(entry);
        }
      }

      if (kDebugMode) {
        debugPrint('[SecurityLogger] Loaded ${rows.length} events from DB');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[SecurityLogger] Failed to load from DB: $e');
      }
    }
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
