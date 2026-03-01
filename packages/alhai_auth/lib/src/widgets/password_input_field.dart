/// Password Input Field - حقل إدخال كلمة المرور
///
/// حقل إدخال كلمة المرور مع إظهار/إخفاء
/// يدعم Dark Mode و RTL
library;

import 'package:flutter/material.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

/// حقل إدخال كلمة المرور
class PasswordInputField extends StatefulWidget {
  final TextEditingController controller;
  final String? errorText;
  final String? label;
  final String? hint;
  final bool enabled;
  final VoidCallback? onSubmitted;

  const PasswordInputField({
    super.key,
    required this.controller,
    this.errorText,
    this.label,
    this.hint,
    this.enabled = true,
    this.onSubmitted,
  });

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : isDarkMode
                      ? Colors.white24
                      : AppColors.border,
              width: hasError ? 1.5 : 1,
            ),
            color: isDarkMode
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.grey.withValues(alpha: 0.05),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: _obscure,
            enabled: widget.enabled,
            style: TextStyle(
              color: isDarkMode ? Colors.white : AppColors.textPrimary,
              fontSize: 16,
              letterSpacing: _obscure ? 2.0 : 0,
            ),
            decoration: InputDecoration(
              hintText: widget.hint ?? '••••••••',
              hintStyle: TextStyle(
                color: isDarkMode ? Colors.white38 : AppColors.textTertiary,
                fontSize: 16,
                letterSpacing: 2.0,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
                size: 22,
              ),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: isDarkMode ? Colors.white54 : AppColors.textSecondary,
                  size: 22,
                ),
                tooltip: _obscure ? 'إظهار' : 'إخفاء',
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            onSubmitted: (_) => widget.onSubmitted?.call(),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
