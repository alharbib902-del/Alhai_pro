import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../tokens/alhai_radius.dart';
import '../../tokens/alhai_spacing.dart';

/// Alhai Text Field - Production-grade text input with RTL support
class AlhaiTextField extends StatefulWidget {
  /// Controller for the text field
  final TextEditingController? controller;

  /// Hint text
  final String? hintText;

  /// Label text
  final String? labelText;

  /// Helper text (shown below field)
  final String? helperText;

  /// Error text (overrides helper when present)
  final String? errorText;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Suffix icon
  final IconData? suffixIcon;

  /// Suffix icon callback
  final VoidCallback? onSuffixIconTap;

  /// Text input type
  final TextInputType keyboardType;

  /// Text input action
  final TextInputAction textInputAction;

  /// Obscure text (for passwords)
  final bool obscureText;

  /// Show password toggle for obscured fields
  final bool showPasswordToggle;

  /// Max lines
  final int maxLines;

  /// Min lines
  final int minLines;

  /// Max length
  final int? maxLength;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Validation function
  final String? Function(String?)? validator;

  /// On changed callback
  final ValueChanged<String>? onChanged;

  /// On submitted callback
  final ValueChanged<String>? onSubmitted;

  /// On tap callback
  final VoidCallback? onTap;

  /// Focus node
  final FocusNode? focusNode;

  /// Auto focus
  final bool autofocus;

  /// Read only
  final bool readOnly;

  /// Enabled
  final bool enabled;

  /// Text align
  final TextAlign textAlign;

  /// Autocorrect
  final bool autocorrect;

  /// Enable suggestions
  final bool enableSuggestions;

  const AlhaiTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.showPasswordToggle = false,
    this.maxLines = 1,
    this.minLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.focusNode,
    this.autofocus = false,
    this.readOnly = false,
    this.enabled = true,
    this.textAlign = TextAlign.start,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  /// Phone input factory
  factory AlhaiTextField.phone({
    Key? key,
    TextEditingController? controller,
    String? hintText,
    String? labelText,
    String? errorText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return AlhaiTextField(
      key: key,
      controller: controller,
      hintText: hintText ?? '+966 5XX XXX XXXX',
      labelText: labelText,
      errorText: errorText,
      prefixIcon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      autocorrect: false,
      enableSuggestions: false,
    );
  }

  /// OTP input factory
  factory AlhaiTextField.otp({
    Key? key,
    TextEditingController? controller,
    String? hintText,
    String? labelText,
    String? errorText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return AlhaiTextField(
      key: key,
      controller: controller,
      hintText: hintText ?? '• • • •',
      labelText: labelText,
      errorText: errorText,
      prefixIcon: Icons.lock_outline,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLength: 6,
      textAlign: TextAlign.center,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      autocorrect: false,
      enableSuggestions: false,
    );
  }

  /// Password input factory
  factory AlhaiTextField.password({
    Key? key,
    TextEditingController? controller,
    String? hintText,
    String? labelText,
    String? errorText,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return AlhaiTextField(
      key: key,
      controller: controller,
      hintText: hintText,
      labelText: labelText,
      errorText: errorText,
      prefixIcon: Icons.lock_outline,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      obscureText: true,
      showPasswordToggle: true,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      validator: validator,
      enabled: enabled,
      autocorrect: false,
      enableSuggestions: false,
    );
  }

  @override
  State<AlhaiTextField> createState() => _AlhaiTextFieldState();
}

class _AlhaiTextFieldState extends State<AlhaiTextField> {
  bool _obscureText = false;
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
    _focusNode.removeListener(_handleFocusChange);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: hasError
                  ? colorScheme.error
                  : _isFocused
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AlhaiSpacing.xs),
        ],

        // Text Field
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          obscureText: _obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          autofocus: widget.autofocus,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          textAlign: widget.textAlign,
          autocorrect: widget.autocorrect,
          enableSuggestions: widget.enableSuggestions,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            counterText: '', // Hide counter
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: hasError
                        ? colorScheme.error
                        : _isFocused
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                  )
                : null,
            suffixIcon: _buildSuffixIcon(colorScheme, hasError),
            filled: true,
            fillColor: widget.enabled
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.input),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.input),
              borderSide: hasError
                  ? BorderSide(color: colorScheme.error)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.input),
              borderSide: BorderSide(
                color: hasError ? colorScheme.error : colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.input),
              borderSide: BorderSide(color: colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AlhaiRadius.input),
              borderSide: BorderSide(color: colorScheme.error, width: 2),
            ),
          ),
        ),

        // Helper/Error text
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: AlhaiSpacing.xxs),
          Text(
            widget.errorText ?? widget.helperText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color:
                  hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon(ColorScheme colorScheme, bool hasError) {
    if (widget.showPasswordToggle && widget.obscureText) {
      return IconButton(
        icon: Icon(
          _obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: colorScheme.onSurfaceVariant,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: hasError ? colorScheme.error : colorScheme.onSurfaceVariant,
        ),
        onPressed: widget.onSuffixIconTap,
      );
    }

    return null;
  }
}
