/// الحوارات والـ Modals - App Dialogs
///
/// مجموعة حوارات متناسقة للتطبيق
library;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';
import 'app_button.dart';

/// حوار موحد
class AppDialog extends StatelessWidget {
  /// العنوان
  final String title;

  /// المحتوى
  final Widget content;

  /// الأيقونة
  final IconData? icon;

  /// لون الأيقونة
  final Color? iconColor;

  /// أزرار الحوار
  final List<Widget>? actions;

  /// عرض الحوار
  final double? width;

  /// قابل للإغلاق بالضغط خارجه
  final bool barrierDismissible;

  const AppDialog({
    super.key,
    required this.title,
    required this.content,
    this.icon,
    this.iconColor,
    this.actions,
    this.width,
    this.barrierDismissible = true,
  });

  /// حوار التأكيد
  static Future<bool?> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color? confirmColor,
    IconData? icon,
    bool isDangerous = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        icon: icon ?? (isDangerous ? Icons.warning_amber_rounded : Icons.help_outline),
        iconColor: isDangerous ? AppColors.error : AppColors.primary,
        content: Text(
          message,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          AppButton.ghost(
            label: cancelText,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          AppButton(
            label: confirmText,
            onPressed: () => Navigator.of(context).pop(true),
            color: confirmColor ?? (isDangerous ? AppColors.error : AppColors.primary),
            variant: AppButtonVariant.filled,
          ),
        ],
      ),
    );
  }

  /// حوار النجاح
  static Future<void> success(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'حسناً',
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        icon: Icons.check_circle,
        iconColor: AppColors.success,
        content: message != null
            ? Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : const SizedBox.shrink(),
        actions: [
          AppButton.primary(
            label: buttonText,
            onPressed: () {
              Navigator.of(context).pop();
              onDismiss?.call();
            },
          ),
        ],
      ),
    );
  }

  /// حوار الخطأ
  static Future<void> error(
    BuildContext context, {
    required String title,
    String? message,
    String buttonText = 'حسناً',
    VoidCallback? onRetry,
  }) {
    return showDialog(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        icon: Icons.error,
        iconColor: AppColors.error,
        content: message != null
            ? Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              )
            : const SizedBox.shrink(),
        actions: [
          if (onRetry != null)
            AppButton.ghost(
              label: 'إلغاء',
              onPressed: () => Navigator.of(context).pop(),
            ),
          AppButton(
            label: onRetry != null ? 'إعادة المحاولة' : buttonText,
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            color: AppColors.error,
            variant: AppButtonVariant.filled,
          ),
        ],
      ),
    );
  }

  /// حوار التحميل
  static Future<T?> loading<T>(
    BuildContext context, {
    required Future<T> Function() task,
    String message = 'جاري التحميل...',
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: AppSpacing.lg),
              Text(message),
            ],
          ),
        ),
      ),
    );

    try {
      final result = await task();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      return result;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  /// حوار إدخال نص
  static Future<String?> input(
    BuildContext context, {
    required String title,
    String? hint,
    String? initialValue,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    TextInputType keyboardType = TextInputType.text,
    int? maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    return showDialog<String>(
      context: context,
      builder: (context) => AppDialog(
        title: title,
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: validator,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
        ),
        actions: [
          AppButton.ghost(
            label: cancelText,
            onPressed: () => Navigator.of(context).pop(),
          ),
          AppButton.primary(
            label: confirmText,
            onPressed: () {
              if (formKey.currentState?.validate() ?? true) {
                Navigator.of(context).pop(controller.text);
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? AppDialogSize.widthMd;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDialogSize.radius),
      ),
      child: Container(
        width: effectiveWidth,
        constraints: BoxConstraints(
          maxWidth: effectiveWidth,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppDialogSize.padding),
              child: Column(
                children: [
                  // Icon
                  if (icon != null) ...[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 28,
                        color: iconColor ?? AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],

                  // Title
                  Text(
                    title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDialogSize.padding,
                ),
                child: content,
              ),
            ),

            // Actions
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.all(AppDialogSize.padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    for (int i = 0; i < actions!.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.sm),
                      actions![i],
                    ],
                  ],
                ),
              ),
            ] else
              const SizedBox(height: AppDialogSize.padding),
          ],
        ),
      ),
    );
  }
}

/// Bottom Sheet موحد
class AppBottomSheet extends StatelessWidget {
  /// العنوان
  final String? title;

  /// المحتوى
  final Widget content;

  /// أزرار
  final List<Widget>? actions;

  /// إظهار المقبض
  final bool showHandle;

  /// قابل للإغلاق بالسحب
  final bool isDismissible;

  /// ارتفاع أقصى (نسبة من الشاشة)
  final double maxHeightFactor;

  const AppBottomSheet({
    super.key,
    this.title,
    required this.content,
    this.actions,
    this.showHandle = true,
    this.isDismissible = true,
    this.maxHeightFactor = 0.9,
  });

  /// إظهار Bottom Sheet
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    required Widget content,
    List<Widget>? actions,
    bool showHandle = true,
    bool isDismissible = true,
    double maxHeightFactor = 0.9,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        content: content,
        actions: actions,
        showHandle: showHandle,
        isDismissible: isDismissible,
        maxHeightFactor: maxHeightFactor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * maxHeightFactor,
        maxWidth: AppBottomSheetSize.maxWidth,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: AppBreakpoints.isDesktop(context)
            ? (MediaQuery.of(context).size.width - AppBottomSheetSize.maxWidth) / 2
            : 0,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBottomSheetSize.topRadius),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          if (showHandle)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Container(
                width: AppBottomSheetSize.handleWidth,
                height: AppBottomSheetSize.handleHeight,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(AppBottomSheetSize.handleHeight / 2),
                ),
              ),
            ),

          // Title
          if (title != null)
            Padding(
              padding: const EdgeInsets.all(AppBottomSheetSize.padding),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ),

          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: AppBottomSheetSize.padding,
                vertical: title == null ? AppBottomSheetSize.padding : 0,
              ),
              child: content,
            ),
          ),

          // Actions
          if (actions != null && actions!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(AppBottomSheetSize.padding),
              child: Row(
                children: [
                  for (int i = 0; i < actions!.length; i++) ...[
                    if (i > 0) const SizedBox(width: AppSpacing.sm),
                    Expanded(child: actions![i]),
                  ],
                ],
              ),
            ),

          // Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
