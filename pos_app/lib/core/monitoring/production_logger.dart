/// Production Logger Service
///
/// خدمة تسجيل محسّنة للـ Production:
/// - تسجيل منظم بمستويات مختلفة
/// - إرسال للـ backend (Crashlytics/Sentry)
/// - حماية البيانات الحساسة
/// - تخزين محلي مؤقت
library;

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// مستوى التسجيل
enum LogLevel {
  debug,    // للتطوير فقط
  info,     // معلومات عامة
  warning,  // تحذيرات
  error,    // أخطاء
  fatal,    // أخطاء قاتلة
}

/// سجل واحد
class LogEntry {
  final String id;
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final Map<String, dynamic>? context;
  final StackTrace? stackTrace;

  LogEntry({
    required this.id,
    required this.level,
    required this.message,
    this.tag,
    this.context,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'level': level.name,
    'message': message,
    'tag': tag,
    'context': context,
    'stackTrace': stackTrace?.toString(),
  };

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('[${timestamp.toIso8601String()}] ');
    buffer.write('[${level.name.toUpperCase()}] ');
    if (tag != null) buffer.write('[$tag] ');
    buffer.write(message);
    return buffer.toString();
  }
}

/// Sink للتسجيل (مكان إرسال السجلات)
abstract class LogSink {
  Future<void> write(LogEntry entry);
  Future<void> flush();
}

/// Console Sink (للتطوير)
class ConsoleLogSink implements LogSink {
  @override
  Future<void> write(LogEntry entry) async {
    final icon = _getIcon(entry.level);
    debugPrint('$icon ${entry.toString()}');
    if (entry.stackTrace != null) {
      debugPrint(entry.stackTrace.toString());
    }
  }

  @override
  Future<void> flush() async {}

  String _getIcon(LogLevel level) {
    return switch (level) {
      LogLevel.debug => '🔍',
      LogLevel.info => 'ℹ️',
      LogLevel.warning => '⚠️',
      LogLevel.error => '❌',
      LogLevel.fatal => '💀',
    };
  }
}

/// Memory Sink (للتخزين المؤقت)
class MemoryLogSink implements LogSink {
  final int maxEntries;
  final Queue<LogEntry> _entries = Queue();

  MemoryLogSink({this.maxEntries = 500});

  @override
  Future<void> write(LogEntry entry) async {
    _entries.add(entry);
    while (_entries.length > maxEntries) {
      _entries.removeFirst();
    }
  }

  @override
  Future<void> flush() async {
    _entries.clear();
  }

  List<LogEntry> getEntries({LogLevel? minLevel}) {
    if (minLevel == null) return _entries.toList();
    return _entries.where((e) => e.level.index >= minLevel.index).toList();
  }

  List<LogEntry> getRecentEntries(int count) {
    return _entries.toList().reversed.take(count).toList();
  }
}

/// Remote Sink (للإرسال للـ backend)
class RemoteLogSink implements LogSink {
  final Future<void> Function(List<LogEntry>) sendLogs;
  final int batchSize;
  final Duration flushInterval;

  final List<LogEntry> _buffer = [];
  Timer? _flushTimer;

  RemoteLogSink({
    required this.sendLogs,
    this.batchSize = 50,
    this.flushInterval = const Duration(seconds: 30),
  }) {
    _startFlushTimer();
  }

  void _startFlushTimer() {
    _flushTimer?.cancel();
    _flushTimer = Timer.periodic(flushInterval, (_) => flush());
  }

  @override
  Future<void> write(LogEntry entry) async {
    _buffer.add(entry);
    if (_buffer.length >= batchSize) {
      await flush();
    }
  }

  @override
  Future<void> flush() async {
    if (_buffer.isEmpty) return;

    final batch = List<LogEntry>.from(_buffer);
    _buffer.clear();

    try {
      await sendLogs(batch);
    } catch (e) {
      // إعادة السجلات للـ buffer في حالة الفشل
      _buffer.insertAll(0, batch);
      if (kDebugMode) {
        debugPrint('❌ Failed to send logs: $e');
      }
    }
  }

  void dispose() {
    _flushTimer?.cancel();
  }
}

/// خدمة التسجيل الرئيسية
class ProductionLogger {
  ProductionLogger._();

  static final List<LogSink> _sinks = [];
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;
  static int _logCounter = 0;

  /// البيانات الحساسة التي يجب إخفاؤها
  static final Set<String> _sensitiveKeys = {
    'password', 'pin', 'token', 'secret', 'key', 'auth',
    'credit_card', 'card_number', 'cvv', 'ssn', 'phone',
  };

  /// تهيئة الـ Logger
  static void initialize({
    LogLevel minLevel = LogLevel.info,
    List<LogSink>? sinks,
  }) {
    _minLevel = kDebugMode ? LogLevel.debug : minLevel;
    _sinks.clear();

    if (sinks != null) {
      _sinks.addAll(sinks);
    } else {
      // الإعدادات الافتراضية
      if (kDebugMode) {
        _sinks.add(ConsoleLogSink());
      }
      _sinks.add(MemoryLogSink());
    }

    if (kDebugMode) {
      debugPrint('📝 ProductionLogger initialized (minLevel: ${_minLevel.name})');
    }
  }

  /// إضافة Sink
  static void addSink(LogSink sink) {
    _sinks.add(sink);
  }

  /// إزالة Sink
  static void removeSink(LogSink sink) {
    _sinks.remove(sink);
  }

  /// تسجيل رسالة
  static Future<void> log(
    LogLevel level,
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    StackTrace? stackTrace,
  }) async {
    if (level.index < _minLevel.index) return;

    final entry = LogEntry(
      id: 'log_${++_logCounter}_${DateTime.now().millisecondsSinceEpoch}',
      level: level,
      message: message,
      tag: tag,
      context: _sanitizeContext(context),
      stackTrace: stackTrace,
    );

    for (final sink in _sinks) {
      await sink.write(entry);
    }
  }

  /// Debug log
  static Future<void> debug(String message, {String? tag, Map<String, dynamic>? context}) {
    return log(LogLevel.debug, message, tag: tag, context: context);
  }

  /// Info log
  static Future<void> info(String message, {String? tag, Map<String, dynamic>? context}) {
    return log(LogLevel.info, message, tag: tag, context: context);
  }

  /// Warning log
  static Future<void> warning(String message, {String? tag, Map<String, dynamic>? context}) {
    return log(LogLevel.warning, message, tag: tag, context: context);
  }

  /// Error log
  static Future<void> error(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return log(
      LogLevel.error,
      message,
      tag: tag,
      context: {
        ...?context,
        if (error != null) 'error': error.toString(),
      },
      stackTrace: stackTrace,
    );
  }

  /// Fatal log
  static Future<void> fatal(
    String message, {
    String? tag,
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    return log(
      LogLevel.fatal,
      message,
      tag: tag,
      context: {
        ...?context,
        if (error != null) 'error': error.toString(),
      },
      stackTrace: stackTrace,
    );
  }

  /// تسجيل استثناء
  static Future<void> exception(
    Object exception, {
    StackTrace? stackTrace,
    String? tag,
    Map<String, dynamic>? context,
  }) {
    return error(
      'Exception: ${exception.runtimeType}',
      tag: tag ?? 'EXCEPTION',
      context: {
        ...?context,
        'exception': exception.toString(),
      },
      error: exception,
      stackTrace: stackTrace ?? StackTrace.current,
    );
  }

  /// إرسال جميع السجلات المعلقة
  static Future<void> flush() async {
    for (final sink in _sinks) {
      await sink.flush();
    }
  }

  /// الحصول على السجلات من الذاكرة
  static List<LogEntry> getRecentLogs({int count = 100, LogLevel? minLevel}) {
    for (final sink in _sinks) {
      if (sink is MemoryLogSink) {
        if (minLevel != null) {
          return sink.getEntries(minLevel: minLevel).reversed.take(count).toList();
        }
        return sink.getRecentEntries(count);
      }
    }
    return [];
  }

  /// تنظيف البيانات الحساسة
  static Map<String, dynamic>? _sanitizeContext(Map<String, dynamic>? context) {
    if (context == null) return null;

    return context.map((key, value) {
      final lowerKey = key.toLowerCase();
      if (_sensitiveKeys.any((s) => lowerKey.contains(s))) {
        return MapEntry(key, '***REDACTED***');
      }
      if (value is Map<String, dynamic>) {
        return MapEntry(key, _sanitizeContext(value));
      }
      return MapEntry(key, value);
    });
  }

  /// إضافة مفتاح حساس
  static void addSensitiveKey(String key) {
    _sensitiveKeys.add(key.toLowerCase());
  }
}

/// Extension لتسهيل التسجيل من أي مكان
extension LoggerExtension on Object {
  void logDebug(String message, {Map<String, dynamic>? context}) {
    ProductionLogger.debug(message, tag: runtimeType.toString(), context: context);
  }

  void logInfo(String message, {Map<String, dynamic>? context}) {
    ProductionLogger.info(message, tag: runtimeType.toString(), context: context);
  }

  void logWarning(String message, {Map<String, dynamic>? context}) {
    ProductionLogger.warning(message, tag: runtimeType.toString(), context: context);
  }

  void logError(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? context}) {
    ProductionLogger.error(
      message,
      tag: runtimeType.toString(),
      error: error,
      stackTrace: stackTrace,
      context: context,
    );
  }
}
