/// حقول الإدخال الموحدة - App Inputs
///
/// مجموعة حقول إدخال متناسقة للتطبيق
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:alhai_core/alhai_core.dart' show StoreSettings;
import 'package:alhai_design_system/alhai_design_system.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_typography.dart';

/// حقل الإدخال الموحد
class AppTextField extends StatefulWidget {
  /// التسمية
  final String? label;

  /// نص التلميح
  final String? hint;

  /// قيمة أولية
  final String? initialValue;

  /// Controller
  final TextEditingController? controller;

  /// عند التغيير
  final ValueChanged<String>? onChanged;

  /// عند الإرسال
  final ValueChanged<String>? onSubmitted;

  /// التحقق
  final String? Function(String?)? validator;

  /// نوع لوحة المفاتيح
  final TextInputType keyboardType;

  /// Action الـ keyboard
  final TextInputAction? textInputAction;

  /// الأيقونة الأولى
  final IconData? prefixIcon;

  /// الأيقونة الأخيرة
  final Widget? suffix;

  /// قراءة فقط
  final bool readOnly;

  /// معطل
  final bool enabled;

  /// مطلوب
  final bool required;

  /// كلمة سر
  final bool obscureText;

  /// عدة أسطر
  final int? maxLines;

  /// الحد الأقصى للأحرف
  final int? maxLength;

  /// الفلاتر
  final List<TextInputFormatter>? inputFormatters;

  /// Focus Node
  final FocusNode? focusNode;

  /// Auto Focus
  final bool autofocus;

  /// رسالة خطأ
  final String? errorText;

  /// رسالة مساعدة
  final String? helperText;

  /// عند الضغط
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.prefixIcon,
    this.suffix,
    this.readOnly = false,
    this.enabled = true,
    this.required = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.focusNode,
    this.autofocus = false,
    this.errorText,
    this.helperText,
    this.onTap,
  });

  /// حقل البحث
  factory AppTextField.search({
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    VoidCallback? onClear,
    bool autofocus = false,
  }) {
    return AppTextField(
      hint: hint ?? 'بحث...',
      controller: controller,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      prefixIcon: Icons.search,
      suffix: controller != null && controller.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                controller.clear();
                onClear?.call();
                onChanged?.call('');
              },
              icon: const Icon(Icons.close, size: 20),
              color: AppColors.textMuted,
            )
          : null,
      autofocus: autofocus,
      textInputAction: TextInputAction.search,
    );
  }

  /// حقل الأرقام
  factory AppTextField.number({
    String? label,
    String? hint,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    bool allowDecimal = true,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(decimal: allowDecimal),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          allowDecimal ? RegExp(r'^\d*\.?\d*') : RegExp(r'^\d*'),
        ),
      ],
      maxLength: maxLength,
      validator: validator,
    );
  }

  /// حقل الهاتف
  factory AppTextField.phone({
    String? label,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return AppTextField(
      label: label ?? 'رقم الهاتف',
      hint: '05xxxxxxxx',
      controller: controller,
      onChanged: onChanged,
      keyboardType: TextInputType.phone,
      prefixIcon: Icons.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(10),
      ],
      validator: validator,
    );
  }

  /// حقل السعر
  factory AppTextField.price({
    String? label,
    TextEditingController? controller,
    ValueChanged<String>? onChanged,
    String currency = StoreSettings.defaultCurrencySymbol,
  }) {
    return AppTextField(
      label: label ?? 'السعر',
      hint: '0.00',
      controller: controller,
      onChanged: onChanged,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      suffix: Padding(
        padding: const EdgeInsetsDirectional.only(start: AppSpacing.md),
        child: Text(
          currency,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTypography.inputLabel.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              if (widget.required)
                Text(
                  ' *',
                  style: AppTypography.inputLabel.copyWith(
                    color: AppColors.error,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
        ],

        // Input Field
        TextFormField(
          controller: widget.controller,
          initialValue: widget.controller == null ? widget.initialValue : null,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          obscureText: _obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          onTap: widget.onTap,
          style: AppTypography.inputText.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.inputHint.copyWith(
              color: AppColors.textMuted,
            ),
            errorText: widget.errorText,
            helperText: widget.helperText,
            helperStyle: AppTypography.inputError.copyWith(
              color: AppColors.textMuted,
            ),
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused ? AppColors.primary : AppColors.textMuted,
                    size: AppIconSize.md,
                  )
                : null,
            suffixIcon: widget.obscureText
                ? IconButton(
                    onPressed: () =>
                        setState(() => _obscureText = !_obscureText),
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.textMuted,
                      size: AppIconSize.sm,
                    ),
                  )
                : widget.suffix,
            filled: true,
            fillColor: widget.enabled ? AppColors.surface : AppColors.grey100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppInputSize.padding,
              vertical: AppInputSize.paddingSm,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.grey200),
            ),
          ),
        ),
      ],
    );
  }
}

/// حقل البحث مع اقتراحات
class AppSearchField extends StatefulWidget {
  /// نص التلميح
  final String hint;

  /// عند التغيير
  final ValueChanged<String>? onChanged;

  /// عند الإرسال
  final ValueChanged<String>? onSubmitted;

  /// عند المسح
  final VoidCallback? onClear;

  /// Auto Focus
  final bool autofocus;

  /// العرض الكامل
  final bool fullWidth;

  /// Controller
  final TextEditingController? controller;

  /// Focus Node
  final FocusNode? focusNode;

  /// الحد الأقصى لطول النص
  final int? maxLength;

  const AppSearchField({
    super.key,
    String hint = 'بحث...',
    String? hintText, // alias for hint
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.autofocus = false,
    this.fullWidth = false,
    this.controller,
    this.focusNode,
    this.maxLength,
  }) : hint = hintText ?? hint;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_updateHasText);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _updateHasText() {
    final hasText = _controller.text.isNotEmpty;
    if (_hasText != hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: widget.hint,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : 300,
        child: TextField(
          controller: _controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          autofocus: widget.autofocus,
          maxLength: widget.maxLength,
          textInputAction: TextInputAction.search,
          style: AppTypography.inputText,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTypography.inputHint.copyWith(
              color: AppColors.textMuted,
            ),
            counterText: '',
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textMuted,
              size: AppIconSize.md,
            ),
            suffixIcon: _hasText
                ? IconButton(
                    onPressed: _clear,
                    icon: const Icon(Icons.close, size: 20),
                    color: AppColors.textMuted,
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.full),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ),
    );
  }
}

/// حقل الكمية مع أزرار + و -
class AppQuantityField extends StatefulWidget {
  /// القيمة الحالية
  final int value;

  /// عند التغيير
  final ValueChanged<int> onChanged;

  /// الحد الأدنى
  final int min;

  /// الحد الأقصى
  final int? max;

  /// الخطوة
  final int step;

  /// معطل
  final bool enabled;

  /// الحجم
  final double size;

  const AppQuantityField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max,
    this.step = 1,
    this.enabled = true,
    this.size = 36,
  });

  @override
  State<AppQuantityField> createState() => _AppQuantityFieldState();
}

class _AppQuantityFieldState extends State<AppQuantityField> {
  void _increment() {
    if (widget.max == null || widget.value < widget.max!) {
      widget.onChanged(widget.value + widget.step);
    }
  }

  void _decrement() {
    if (widget.value > widget.min) {
      widget.onChanged(widget.value - widget.step);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDecrement = widget.enabled && widget.value > widget.min;
    final canIncrement =
        widget.enabled && (widget.max == null || widget.value < widget.max!);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement Button
          _QuantityButton(
            icon: Icons.remove,
            onPressed: canDecrement ? _decrement : null,
            size: widget.size,
          ),

          // Value
          Container(
            width: widget.size * 1.5,
            alignment: Alignment.center,
            child: Text(
              widget.value.toString(),
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Increment Button
          _QuantityButton(
            icon: Icons.add,
            onPressed: canIncrement ? _increment : null,
            size: widget.size,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;

  const _QuantityButton({
    required this.icon,
    this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Icon(
            icon,
            size: size * 0.5,
            color:
                onPressed != null ? AppColors.textPrimary : AppColors.grey300,
          ),
        ),
      ),
    );
  }
}
