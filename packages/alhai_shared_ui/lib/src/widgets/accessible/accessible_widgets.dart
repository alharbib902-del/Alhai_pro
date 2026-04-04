/// Accessible Widgets - عناصر واجهة مع دعم إمكانية الوصول
///
/// يوفر:
/// - Semantic wrappers للعناصر التفاعلية
/// - دعم قارئات الشاشة
/// - تباين ألوان محسن
/// - حجم لمس كافٍ
library accessible_widgets;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../../core/accessibility/semantic_labels.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

// ============================================================================
// ACCESSIBLE BUTTON
// ============================================================================

/// زر مع دعم إمكانية الوصول الكامل
class AccessibleButton extends StatelessWidget {
  /// نص الزر
  final String label;

  /// الإجراء عند الضغط
  final VoidCallback? onPressed;

  /// أيقونة اختيارية
  final IconData? icon;

  /// نوع الزر
  final AccessibleButtonType type;

  /// حجم الزر
  final AccessibleButtonSize size;

  /// هل الزر ممتلئ العرض
  final bool fullWidth;

  /// تلميح إضافي للقارئ
  final String? hint;

  /// هل الزر في حالة تحميل
  final bool isLoading;

  const AccessibleButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.type = AccessibleButtonType.primary,
    this.size = AccessibleButtonSize.medium,
    this.fullWidth = false,
    this.hint,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = _getButtonStyle(theme);
    final minSize = _getMinSize();

    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(_getLoadingColor(theme)),
            ),
          ),
          SizedBox(width: AlhaiSpacing.xs),
        ] else if (icon != null) ...[
          Icon(icon, size: _getIconSize()),
          SizedBox(width: AlhaiSpacing.xs),
        ],
        Text(label, style: TextStyle(fontSize: _getFontSize())),
      ],
    );

    return Semantics(
      label: label,
      hint: hint ?? AccessibilityHints.doubleTapToActivate,
      button: true,
      enabled: onPressed != null && !isLoading,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          minHeight: minSize,
        ),
        child: _buildButton(buttonChild, buttonStyle),
      ),
    );
  }

  Widget _buildButton(Widget child, ButtonStyle style) {
    switch (type) {
      case AccessibleButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
      case AccessibleButtonType.secondary:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
      case AccessibleButtonType.text:
        return TextButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
      case AccessibleButtonType.danger:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: child,
        );
    }
  }

  ButtonStyle _getButtonStyle(ThemeData theme) {
    switch (type) {
      case AccessibleButtonType.primary:
        return ElevatedButton.styleFrom(
          padding: _getPadding(),
        );
      case AccessibleButtonType.secondary:
        return OutlinedButton.styleFrom(
          padding: _getPadding(),
        );
      case AccessibleButtonType.text:
        return TextButton.styleFrom(
          padding: _getPadding(),
        );
      case AccessibleButtonType.danger:
        return ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
          padding: _getPadding(),
        );
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AccessibleButtonSize.small:
        return const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.sm, vertical: AlhaiSpacing.xs);
      case AccessibleButtonSize.medium:
        return const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.md, vertical: AlhaiSpacing.sm);
      case AccessibleButtonSize.large:
        return const EdgeInsets.symmetric(
            horizontal: AlhaiSpacing.lg, vertical: AlhaiSpacing.md);
    }
  }

  double _getMinSize() {
    switch (size) {
      case AccessibleButtonSize.small:
        return 40; // الحد الأدنى للمس
      case AccessibleButtonSize.medium:
        return 48; // الحجم الموصى به
      case AccessibleButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case AccessibleButtonSize.small:
        return 18;
      case AccessibleButtonSize.medium:
        return 20;
      case AccessibleButtonSize.large:
        return 24;
    }
  }

  double _getFontSize() {
    switch (size) {
      case AccessibleButtonSize.small:
        return 14;
      case AccessibleButtonSize.medium:
        return 16;
      case AccessibleButtonSize.large:
        return 18;
    }
  }

  Color _getLoadingColor(ThemeData theme) {
    switch (type) {
      case AccessibleButtonType.primary:
      case AccessibleButtonType.danger:
        return theme.colorScheme.onPrimary;
      case AccessibleButtonType.secondary:
      case AccessibleButtonType.text:
        return theme.colorScheme.primary;
    }
  }
}

enum AccessibleButtonType { primary, secondary, text, danger }

enum AccessibleButtonSize { small, medium, large }

// ============================================================================
// ACCESSIBLE ICON BUTTON
// ============================================================================

/// زر أيقونة مع تسمية دلالية
class AccessibleIconButton extends StatelessWidget {
  /// الأيقونة
  final IconData icon;

  /// الإجراء
  final VoidCallback? onPressed;

  /// التسمية الدلالية (مطلوبة!)
  final String label;

  /// التلميح
  final String? hint;

  /// الحجم
  final double size;

  /// اللون
  final Color? color;

  /// لون الخلفية
  final Color? backgroundColor;

  const AccessibleIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onPressed,
    this.hint,
    this.size = 48, // الحد الأدنى الموصى به
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint ?? AccessibilityHints.doubleTapToActivate,
      button: true,
      enabled: onPressed != null,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(size / 2),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(size / 2),
          child: Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            child: Icon(
              icon,
              color: color ?? Theme.of(context).iconTheme.color,
              size: size * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ACCESSIBLE TEXT FIELD
// ============================================================================

/// حقل نص مع دعم إمكانية الوصول
class AccessibleTextField extends StatelessWidget {
  /// Controller
  final TextEditingController? controller;

  /// التسمية
  final String label;

  /// التلميح
  final String? hintText;

  /// نص المساعدة
  final String? helperText;

  /// رسالة الخطأ
  final String? errorText;

  /// هل مطلوب
  final bool isRequired;

  /// أيقونة البداية
  final IconData? prefixIcon;

  /// أيقونة النهاية
  final Widget? suffix;

  /// نوع لوحة المفاتيح
  final TextInputType? keyboardType;

  /// الإجراء عند التغيير
  final ValueChanged<String>? onChanged;

  /// الإجراء عند الإرسال
  final ValueChanged<String>? onSubmitted;

  /// هل قراءة فقط
  final bool readOnly;

  /// هل كلمة مرور
  final bool obscureText;

  /// الحد الأقصى للأسطر
  final int? maxLines;

  const AccessibleTextField({
    super.key,
    this.controller,
    required this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.isRequired = false,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.obscureText = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = _buildSemanticLabel();

    return Semantics(
      label: semanticLabel,
      textField: true,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: isRequired ? '$label *' : label,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffix: suffix,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        readOnly: readOnly,
        obscureText: obscureText,
        maxLines: obscureText ? 1 : maxLines,
      ),
    );
  }

  String _buildSemanticLabel() {
    final buffer = StringBuffer(label);

    if (isRequired) {
      buffer.write('، ${FormLabels.requiredField}');
    }

    if (errorText != null) {
      buffer.write('، ${FormLabels.fieldError(errorText!)}');
    }

    return buffer.toString();
  }
}

// ============================================================================
// ACCESSIBLE CARD
// ============================================================================

/// بطاقة مع دعم إمكانية الوصول
class AccessibleCard extends StatelessWidget {
  /// المحتوى
  final Widget child;

  /// التسمية الدلالية
  final String label;

  /// الإجراء عند الضغط
  final VoidCallback? onTap;

  /// التلميح
  final String? hint;

  /// الارتفاع
  final double? elevation;

  /// الحشوة
  final EdgeInsets? padding;

  /// لون الخلفية
  final Color? backgroundColor;

  const AccessibleCard({
    super.key,
    required this.child,
    required this.label,
    this.onTap,
    this.hint,
    this.elevation,
    this.padding,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: onTap != null
          ? (hint ?? AccessibilityHints.doubleTapToActivate)
          : null,
      button: onTap != null,
      child: Card(
        elevation: elevation,
        color: backgroundColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AlhaiSpacing.md),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ACCESSIBLE LIST TILE
// ============================================================================

/// عنصر قائمة مع دعم إمكانية الوصول
class AccessibleListTile extends StatelessWidget {
  /// العنوان
  final String title;

  /// العنوان الفرعي
  final String? subtitle;

  /// الأيقونة الأمامية
  final Widget? leading;

  /// الأيقونة الخلفية
  final Widget? trailing;

  /// الإجراء عند الضغط
  final VoidCallback? onTap;

  /// التلميح
  final String? hint;

  /// هل محدد
  final bool isSelected;

  /// هل معطل
  final bool isEnabled;

  const AccessibleListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.hint,
    this.isSelected = false,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final semanticLabel = _buildSemanticLabel();

    return Semantics(
      label: semanticLabel,
      hint: onTap != null && isEnabled
          ? (hint ?? AccessibilityHints.doubleTapToActivate)
          : null,
      button: onTap != null,
      enabled: isEnabled,
      selected: isSelected,
      child: ListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        leading: leading,
        trailing: trailing,
        onTap: isEnabled ? onTap : null,
        selected: isSelected,
        enabled: isEnabled,
      ),
    );
  }

  String _buildSemanticLabel() {
    final buffer = StringBuffer(title);

    if (subtitle != null) {
      buffer.write('، $subtitle');
    }

    if (isSelected) {
      buffer.write('، محدد');
    }

    if (!isEnabled) {
      buffer.write('، معطل');
    }

    return buffer.toString();
  }
}

// ============================================================================
// ACCESSIBLE IMAGE
// ============================================================================

/// صورة مع وصف بديل
class AccessibleImage extends StatelessWidget {
  /// مصدر الصورة
  final ImageProvider image;

  /// الوصف البديل (مطلوب!)
  final String altText;

  /// العرض
  final double? width;

  /// الارتفاع
  final double? height;

  /// طريقة الاحتواء
  final BoxFit fit;

  /// Widget للخطأ
  final Widget? errorWidget;

  /// Widget للتحميل
  final Widget? loadingWidget;

  const AccessibleImage({
    super.key,
    required this.image,
    required this.altText,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: altText,
      image: true,
      child: Image(
        image: image,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image,
                  color: Theme.of(context).colorScheme.outline,
                  size: 40,
                ),
              );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return loadingWidget ??
              Container(
                width: width,
                height: height,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
        },
      ),
    );
  }
}

// ============================================================================
// ACCESSIBLE CHECKBOX
// ============================================================================

/// خانة اختيار مع دعم إمكانية الوصول
class AccessibleCheckbox extends StatelessWidget {
  /// القيمة
  final bool value;

  /// الإجراء عند التغيير
  final ValueChanged<bool?>? onChanged;

  /// التسمية
  final String label;

  /// التلميح
  final String? hint;

  /// هل معطل
  final bool isEnabled;

  const AccessibleCheckbox({
    super.key,
    required this.value,
    required this.label,
    this.onChanged,
    this.hint,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      hint: hint ?? 'انقر مرتين لتغيير الحالة',
      checked: value,
      enabled: isEnabled,
      child: InkWell(
        onTap: isEnabled && onChanged != null ? () => onChanged!(!value) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: value,
              onChanged: isEnabled ? onChanged : null,
            ),
            SizedBox(width: AlhaiSpacing.xs),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? null : Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SCREEN READER ANNOUNCER
// ============================================================================

/// إعلانات لقارئ الشاشة
class ScreenReaderAnnouncer {
  ScreenReaderAnnouncer._();

  /// إعلان رسالة
  static void announce(String message, {bool isPolite = true}) {
    // ignore: deprecated_member_use
    SemanticsService.announce(
      message,
      TextDirection.rtl,
      assertiveness: isPolite ? Assertiveness.polite : Assertiveness.assertive,
    );
  }

  /// إعلان نجاح
  static void announceSuccess(String message) {
    announce('${DialogLabels.success}: $message');
  }

  /// إعلان خطأ
  static void announceError(String message) {
    announce('${DialogLabels.error}: $message', isPolite: false);
  }

  /// إعلان تحذير
  static void announceWarning(String message) {
    announce('${DialogLabels.warning}: $message');
  }

  /// إعلان تحميل
  static void announceLoading() {
    announce(DialogLabels.loading);
  }

  /// إعلان انتهاء التحميل
  static void announceLoadingComplete(String? result) {
    if (result != null) {
      announce(result);
    }
  }
}

// ============================================================================
// FOCUS HELPERS
// ============================================================================

/// مساعدات التركيز
class FocusHelpers {
  FocusHelpers._();

  /// طلب التركيز على عنصر
  static void requestFocus(FocusNode node) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      node.requestFocus();
    });
  }

  /// نقل التركيز للعنصر التالي
  static void nextFocus(BuildContext context) {
    FocusScope.of(context).nextFocus();
  }

  /// نقل التركيز للعنصر السابق
  static void previousFocus(BuildContext context) {
    FocusScope.of(context).previousFocus();
  }

  /// إزالة التركيز
  static void unfocus(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}

// ============================================================================
// HIGH CONTRAST COLORS
// ============================================================================

/// ألوان عالية التباين
abstract class HighContrastColors {
  /// أسود نقي للنص
  static const Color textOnLight = Color(0xFF000000);

  /// أبيض نقي للنص
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// أزرق داكن للروابط
  static const Color link = Color(0xFF0000EE);

  /// أحمر للأخطاء
  static const Color error = Color(0xFFCC0000);

  /// أخضر للنجاح
  static const Color success = Color(0xFF008800);

  /// برتقالي للتحذيرات
  static const Color warning = Color(0xFFCC6600);

  /// التحقق من نسبة التباين
  static bool hasGoodContrast(Color foreground, Color background) {
    final luminance1 = foreground.computeLuminance();
    final luminance2 = background.computeLuminance();

    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;

    final ratio = (lighter + 0.05) / (darker + 0.05);

    // WCAG AA يتطلب 4.5:1 للنص العادي
    return ratio >= 4.5;
  }
}
