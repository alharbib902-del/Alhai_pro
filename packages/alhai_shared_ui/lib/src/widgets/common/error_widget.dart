import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiColors;

/// Widget موحد لعرض الأخطاء
class AppErrorWidget extends StatelessWidget {
  /// رسالة الخطأ
  final String message;
  
  /// حدث إعادة المحاولة
  final VoidCallback? onRetry;
  
  /// أيقونة الخطأ
  final IconData icon;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  /// خطأ شبكة
  factory AppErrorWidget.network({VoidCallback? onRetry}) {
    return AppErrorWidget(
      message: 'خطأ في الاتصال بالخادم',
      icon: Icons.cloud_off,
      onRetry: onRetry,
    );
  }

  /// خطأ تحميل
  factory AppErrorWidget.loading({String? details, VoidCallback? onRetry}) {
    return AppErrorWidget(
      message: details ?? 'فشل تحميل البيانات',
      icon: Icons.sync_problem,
      onRetry: onRetry,
    );
  }

  /// خطأ عام
  factory AppErrorWidget.generic({String? message, VoidCallback? onRetry}) {
    return AppErrorWidget(
      message: message ?? 'حدث خطأ غير متوقع',
      icon: Icons.warning_amber,
      onRetry: onRetry,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AlhaiColors.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
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

/// رسالة خطأ بسيطة (inline)
class ErrorMessage extends StatelessWidget {
  /// رسالة الخطأ
  final String message;
  
  /// حدث الإغلاق
  final VoidCallback? onDismiss;

  const ErrorMessage({
    super.key,
    required this.message,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AlhaiColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AlhaiColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AlhaiColors.error.withValues(alpha: 0.7), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: AlhaiColors.errorDark),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: onDismiss,
              color: AlhaiColors.error.withValues(alpha: 0.7),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
