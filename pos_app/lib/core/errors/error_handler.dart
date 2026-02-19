/// Error Handler - معالجة الأخطاء الشاملة
///
/// يوفر:
/// - تصنيف الأخطاء حسب النوع (ErrorConverter)
/// - تسجيل الأخطاء (ErrorLogger)
/// - عرض الأخطاء للمستخدم (ErrorPresenter)
/// - ErrorBoundary للـ widgets
library error_handler;

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pos_app/core/monitoring/production_logger.dart';
import '../theme/app_sizes.dart';

// ============================================================================
// ERROR TYPES
// ============================================================================

/// أنواع الأخطاء
enum ErrorType {
  /// خطأ في الشبكة
  network,

  /// خطأ في الخادم
  server,

  /// خطأ في المصادقة
  authentication,

  /// خطأ في الصلاحيات
  authorization,

  /// خطأ في التحقق
  validation,

  /// خطأ في قاعدة البيانات
  database,

  /// خطأ غير معروف
  unknown,

  /// انتهاء المهلة
  timeout,

  /// لا يوجد اتصال
  noConnection,

  /// الموارد غير موجودة
  notFound,

  /// تعارض البيانات
  conflict,
}

// ============================================================================
// APP ERROR
// ============================================================================

/// خطأ التطبيق الموحد
class AppError implements Exception {
  /// نوع الخطأ
  final ErrorType type;

  /// رسالة الخطأ التقنية
  final String message;

  /// رسالة الخطأ للمستخدم (عربية)
  final String userMessage;

  /// الخطأ الأصلي
  final Object? originalError;

  /// StackTrace
  final StackTrace? stackTrace;

  /// هل يمكن إعادة المحاولة
  final bool canRetry;

  /// كود الخطأ (للـ API errors)
  final String? code;

  const AppError({
    required this.type,
    required this.message,
    required this.userMessage,
    this.originalError,
    this.stackTrace,
    this.canRetry = false,
    this.code,
  });

  @override
  String toString() => 'AppError($type): $message';

  /// إنشاء خطأ شبكة
  factory AppError.network({
    String? message,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.network,
      message: message ?? 'Network error',
      userMessage: 'حدث خطأ في الاتصال. يرجى التحقق من اتصالك بالإنترنت.',
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: true,
    );
  }

  /// إنشاء خطأ خادم
  factory AppError.server({
    String? message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.server,
      message: message ?? 'Server error',
      userMessage: 'حدث خطأ في الخادم. يرجى المحاولة لاحقاً.',
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: true,
      code: code,
    );
  }

  /// إنشاء خطأ مصادقة
  factory AppError.authentication({
    String? message,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.authentication,
      message: message ?? 'Authentication error',
      userMessage: 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.',
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: false,
    );
  }

  /// إنشاء خطأ صلاحيات
  factory AppError.authorization({
    String? message,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.authorization,
      message: message ?? 'Authorization error',
      userMessage: 'ليس لديك صلاحية للقيام بهذا الإجراء.',
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: false,
    );
  }

  /// إنشاء خطأ تحقق
  factory AppError.validation({
    required String message,
    required String userMessage,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.validation,
      message: message,
      userMessage: userMessage,
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: false,
    );
  }

  /// إنشاء خطأ قاعدة بيانات
  factory AppError.database({
    String? message,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.database,
      message: message ?? 'Database error',
      userMessage: 'حدث خطأ في حفظ البيانات. يرجى المحاولة مرة أخرى.',
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: true,
    );
  }

  /// إنشاء خطأ انتهاء المهلة
  factory AppError.timeout({
    String? message,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.timeout,
      message: message ?? 'Timeout error',
      userMessage: 'انتهى وقت الانتظار. يرجى المحاولة مرة أخرى.',
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: true,
    );
  }

  /// إنشاء خطأ لا يوجد اتصال
  factory AppError.noConnection({
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.noConnection,
      message: 'No internet connection',
      userMessage: 'لا يوجد اتصال بالإنترنت. يرجى التحقق من الاتصال.',
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: true,
    );
  }

  /// إنشاء خطأ غير موجود
  factory AppError.notFound({
    String? message,
    String? userMessage,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.notFound,
      message: message ?? 'Resource not found',
      userMessage: userMessage ?? 'العنصر المطلوب غير موجود.',
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: false,
    );
  }

  /// إنشاء خطأ غير معروف
  factory AppError.unknown({
    String? message,
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      type: ErrorType.unknown,
      message: message ?? 'Unknown error',
      userMessage: 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.',
      originalError: originalError,
      stackTrace: stackTrace,
      canRetry: true,
    );
  }
}

// ============================================================================
// ERROR CONVERTER - تحويل الأخطاء
// ============================================================================

/// تحويل أي خطأ لـ AppError
class ErrorConverter {
  ErrorConverter._();

  /// تحويل أي خطأ لـ AppError
  static AppError convert(Object error, [StackTrace? stackTrace]) {
    if (error is AppError) {
      return error;
    }

    // أخطاء الشبكة
    if (error is SocketException) {
      return AppError.noConnection(
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return AppError.timeout(
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is HttpException) {
      return AppError.network(
        message: error.message,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // خطأ غير معروف
    return AppError.unknown(
      message: error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}

// ============================================================================
// ERROR LOGGER - تسجيل الأخطاء
// ============================================================================

/// تسجيل الأخطاء للتشخيص
class ErrorLogger {
  ErrorLogger._();

  /// تسجيل الخطأ
  static void log(AppError error) {
    final details = StringBuffer();
    details.write('${error.type} - ${error.message}');
    if (error.code != null) details.write(' [${error.code}]');
    if (error.originalError != null) details.write(' | Original: ${error.originalError}');

    AppLogger.error(
      details.toString(),
      tag: 'ErrorHandler',
      error: error.stackTrace,
    );

    // TODO: إرسال للـ Crashlytics في Production
    // CrashlyticsService.logError(error);
  }
}

// ============================================================================
// ERROR PRESENTER - عرض الأخطاء
// ============================================================================

/// عرض الأخطاء للمستخدم
class ErrorPresenter {
  ErrorPresenter._();

  /// مدة عرض الـ SnackBar
  static const _snackBarDuration = Duration(seconds: 4);

  /// عرض رسالة خطأ للمستخدم
  static void showError(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.userMessage),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        duration: _snackBarDuration,
        action: error.canRetry && onRetry != null
            ? SnackBarAction(
                label: 'إعادة المحاولة',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// عرض dialog للخطأ
  static Future<bool?> showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(
          getErrorIcon(error.type),
          color: Theme.of(context).colorScheme.error,
          size: AppIconSize.xl,
        ),
        title: Text(getErrorTitle(error.type)),
        content: Text(
          error.userMessage,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إغلاق'),
          ),
          if (error.canRetry && onRetry != null)
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
                onRetry();
              },
              child: const Text('إعادة المحاولة'),
            ),
        ],
      ),
    );
  }

  /// أيقونة الخطأ حسب النوع
  static IconData getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.noConnection:
        return Icons.wifi_off;
      case ErrorType.server:
        return Icons.cloud_off;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.authorization:
        return Icons.block;
      case ErrorType.validation:
        return Icons.warning_amber;
      case ErrorType.database:
        return Icons.storage;
      case ErrorType.timeout:
        return Icons.timer_off;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.conflict:
        return Icons.sync_problem;
      case ErrorType.unknown:
        return Icons.error_outline;
    }
  }

  /// عنوان الخطأ حسب النوع
  static String getErrorTitle(ErrorType type) {
    switch (type) {
      case ErrorType.network:
      case ErrorType.noConnection:
        return 'خطأ في الاتصال';
      case ErrorType.server:
        return 'خطأ في الخادم';
      case ErrorType.authentication:
        return 'انتهت الجلسة';
      case ErrorType.authorization:
        return 'غير مصرح';
      case ErrorType.validation:
        return 'خطأ في البيانات';
      case ErrorType.database:
        return 'خطأ في الحفظ';
      case ErrorType.timeout:
        return 'انتهت المهلة';
      case ErrorType.notFound:
        return 'غير موجود';
      case ErrorType.conflict:
        return 'تعارض في البيانات';
      case ErrorType.unknown:
        return 'خطأ';
    }
  }
}

// ============================================================================
// ERROR HANDLER (Facade) - واجهة موحدة
// ============================================================================

/// معالج الأخطاء المركزي - واجهة موحدة تفوض للفئات المتخصصة
class ErrorHandler {
  ErrorHandler._();

  /// تحويل أي خطأ لـ AppError
  static AppError handle(Object error, [StackTrace? stackTrace]) =>
      ErrorConverter.convert(error, stackTrace);

  /// تسجيل الخطأ
  static void log(AppError error) => ErrorLogger.log(error);

  /// عرض رسالة خطأ للمستخدم
  static void showError(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) =>
      ErrorPresenter.showError(context, error, onRetry: onRetry);

  /// عرض dialog للخطأ
  static Future<bool?> showErrorDialog(
    BuildContext context,
    AppError error, {
    VoidCallback? onRetry,
  }) =>
      ErrorPresenter.showErrorDialog(context, error, onRetry: onRetry);
}

// ============================================================================
// ERROR BOUNDARY
// ============================================================================

/// Widget للتعامل مع الأخطاء في شجرة الـ widgets
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(AppError error, VoidCallback retry)? errorBuilder;
  final void Function(AppError error)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppError? _error;

  @override
  void initState() {
    super.initState();
  }

  void _retry() {
    setState(() {
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(_error!, _retry);
      }
      return _DefaultErrorWidget(error: _error!, onRetry: _retry);
    }

    return widget.child;
  }
}

/// Widget الخطأ الافتراضي
class _DefaultErrorWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback onRetry;

  const _DefaultErrorWidget({
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppIconSize.xxl,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              error.userMessage,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            if (error.canRetry) ...[
              const SizedBox(height: AppSpacing.xxl),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ASYNC ERROR HANDLER
// ============================================================================

/// تنفيذ عملية async مع معالجة الأخطاء
Future<T?> runWithErrorHandler<T>(
  Future<T> Function() operation, {
  required BuildContext context,
  String? loadingMessage,
  VoidCallback? onRetry,
  bool showError = true,
}) async {
  try {
    return await operation();
  } catch (e, st) {
    final error = ErrorHandler.handle(e, st);
    ErrorHandler.log(error);

    if (showError && context.mounted) {
      ErrorHandler.showError(context, error, onRetry: onRetry);
    }

    return null;
  }
}

/// Extension لتسهيل معالجة الأخطاء على Future
extension FutureErrorExtension<T> on Future<T> {
  /// معالجة الأخطاء وتحويلها لـ AppError
  Future<T> handleErrors() async {
    try {
      return await this;
    } catch (e, st) {
      throw ErrorHandler.handle(e, st);
    }
  }

  /// معالجة الأخطاء مع إرجاع قيمة افتراضية
  Future<T> handleErrorsOr(T defaultValue) async {
    try {
      return await this;
    } catch (e, st) {
      final error = ErrorHandler.handle(e, st);
      ErrorHandler.log(error);
      return defaultValue;
    }
  }
}
