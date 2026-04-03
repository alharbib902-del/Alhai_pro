import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart' show AlhaiColors, AlhaiSpacing;
import 'package:alhai_l10n/alhai_l10n.dart';

/// Widget موحد لعرض الأخطاء
class AppErrorWidget extends StatelessWidget {
  /// رسالة الخطأ
  final String? message;

  /// حدث إعادة المحاولة
  final VoidCallback? onRetry;

  /// أيقونة الخطأ
  final IconData icon;

  /// نوع الخطأ الداخلي لتحديد الرسالة الافتراضية
  final _ErrorType _errorType;

  const AppErrorWidget({
    super.key,
    required String this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  }) : _errorType = _ErrorType.custom;

  /// خطأ شبكة
  const AppErrorWidget.network({super.key, this.onRetry, this.message})
      : icon = Icons.cloud_off,
        _errorType = _ErrorType.network;

  /// خطأ تحميل
  const AppErrorWidget.loading({super.key, String? details, this.onRetry})
      : message = details,
        icon = Icons.sync_problem,
        _errorType = _ErrorType.loading;

  /// خطأ عام
  const AppErrorWidget.generic({super.key, this.message, this.onRetry})
      : icon = Icons.warning_amber,
        _errorType = _ErrorType.generic;

  String _resolveMessage(AppLocalizations l10n) {
    if (message != null) return message!;
    switch (_errorType) {
      case _ErrorType.network:
        return l10n.networkError;
      case _ErrorType.loading:
        return l10n.dataLoadFailed;
      case _ErrorType.generic:
        return l10n.unexpectedError;
      case _ErrorType.custom:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AlhaiSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AlhaiColors.error.withValues(alpha: 0.6),
            ),
            SizedBox(height: AlhaiSpacing.md),
            Text(
              _resolveMessage(l10n),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              SizedBox(height: AlhaiSpacing.lg),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _ErrorType { custom, network, loading, generic }

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
      padding: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm),
      margin: const EdgeInsets.all(AlhaiSpacing.xs),
      decoration: BoxDecoration(
        color: AlhaiColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AlhaiColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AlhaiColors.error.withValues(alpha: 0.7), size: 20),
          SizedBox(width: AlhaiSpacing.sm),
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
