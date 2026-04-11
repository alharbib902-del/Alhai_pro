/// Logging abstraction for Alhai platform
///
/// This abstraction allows apps to plug in their preferred logging solution
/// (Firebase Crashlytics, Sentry, etc.) without coupling the core package.
library;

import 'package:flutter/foundation.dart';

/// Log levels
enum LogLevel { debug, info, warning, error }

/// Abstract logger interface
///
/// Implement this interface to integrate with your logging backend
abstract class AppLogger {
  /// Log a debug message
  void debug(String message, {Map<String, dynamic>? data});

  /// Log an info message
  void info(String message, {Map<String, dynamic>? data});

  /// Log a warning message
  void warning(String message, {Map<String, dynamic>? data});

  /// Log an error with optional exception and stack trace
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  });

  /// Set user context for crash reporting
  void setUser({String? id, String? email, String? name});

  /// Clear user context on logout
  void clearUser();

  /// Add a breadcrumb for navigation/action tracking
  void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  });
}

/// Default console logger implementation
///
/// Use this for development or as a fallback
class ConsoleLogger implements AppLogger {
  final String tag;
  final bool enabled;

  ConsoleLogger({this.tag = 'Alhai', this.enabled = kDebugMode});

  @override
  void debug(String message, {Map<String, dynamic>? data}) {
    if (enabled) {
      debugPrint('[$tag] DEBUG: $message${data != null ? ' | $data' : ''}');
    }
  }

  @override
  void info(String message, {Map<String, dynamic>? data}) {
    if (enabled) {
      debugPrint('[$tag] INFO: $message${data != null ? ' | $data' : ''}');
    }
  }

  @override
  void warning(String message, {Map<String, dynamic>? data}) {
    debugPrint('[$tag] WARNING: $message${data != null ? ' | $data' : ''}');
  }

  @override
  void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    debugPrint('[$tag] ERROR: $message');
    if (error != null) debugPrint('  Error: $error');
    if (stackTrace != null) debugPrint('  Stack: $stackTrace');
    if (data != null) debugPrint('  Data: $data');
  }

  @override
  void setUser({String? id, String? email, String? name}) {
    debug('User set: id=$id, email=$email, name=$name');
  }

  @override
  void clearUser() {
    debug('User cleared');
  }

  @override
  void addBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) {
    debug('Breadcrumb: [$category] $message${data != null ? ' | $data' : ''}');
  }
}

/// Global logger instance
///
/// Set this to your preferred logger implementation in main()
AppLogger logger = ConsoleLogger();
