import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';

/// حقل إدخال OTP مكون من 6 خانات منفصلة
///
/// يدعم:
/// - التحقق التلقائي عند إكمال الإدخال
/// - التنقل التلقائي بين الخانات
/// - عرض حالة النجاح/الخطأ
/// - دعم RTL/LTR
class OtpInputField extends StatefulWidget {
  const OtpInputField({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.length = 6,
    this.isError = false,
    this.isSuccess = false,
    this.enabled = true,
    this.autoFocus = true,
  });

  /// عدد خانات OTP
  final int length;

  /// يتم استدعاؤه عند إكمال جميع الخانات
  final ValueChanged<String> onCompleted;

  /// يتم استدعاؤه عند تغيير أي خانة
  final ValueChanged<String>? onChanged;

  /// إظهار حالة الخطأ
  final bool isError;

  /// إظهار حالة النجاح
  final bool isSuccess;

  /// تفعيل/تعطيل الحقل
  final bool enabled;

  /// التركيز التلقائي على الخانة الأولى
  final bool autoFocus;

  @override
  State<OtpInputField> createState() => OtpInputFieldState();
}

class OtpInputFieldState extends State<OtpInputField>
    with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (_) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (_) => FocusNode(),
    );

    // Animation للاهتزاز عند الخطأ
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(OtpInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isError && !oldWidget.isError) {
      _shakeController.forward().then((_) => _shakeController.reverse());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _shakeController.dispose();
    super.dispose();
  }

  String get _otpValue {
    return _controllers.map((c) => c.text).join();
  }

  void _onChanged(int index, String value) {
    if (value.length == 1) {
      // الانتقال للخانة التالية
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // إكمال الإدخال
        _focusNodes[index].unfocus();
        final otp = _otpValue;
        if (otp.length == widget.length) {
          widget.onCompleted(otp);
        }
      }
    }

    widget.onChanged?.call(_otpValue);
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        // العودة للخانة السابقة عند الحذف
        _focusNodes[index - 1].requestFocus();
        _controllers[index - 1].clear();
      }
    }
  }

  /// مسح جميع الخانات
  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    widget.onChanged?.call('');
  }

  /// تعيين قيمة OTP
  void setValue(String value) {
    clear();
    for (int i = 0; i < value.length && i < widget.length; i++) {
      _controllers[i].text = value[i];
    }
    if (value.length == widget.length) {
      widget.onCompleted(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeAnimation.value, 0),
          child: child,
        );
      },
      child: Directionality(
        // دائماً LTR للأرقام
        textDirection: TextDirection.ltr,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: index == 0 || index == widget.length - 1 ? 0 : 4,
              ),
              child: _buildOtpBox(index),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color borderColor;
    Color fillColor;

    if (widget.isSuccess) {
      borderColor = AppColors.success;
      fillColor = AppColors.successSurface;
    } else if (widget.isError) {
      borderColor = AppColors.error;
      fillColor = AppColors.errorSurface;
    } else if (_focusNodes[index].hasFocus) {
      borderColor = AppColors.primary;
      fillColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    } else if (_controllers[index].text.isNotEmpty) {
      borderColor = AppColors.primaryLight;
      fillColor = isDark ? const Color(0xFF1E3A2F) : AppColors.primarySurface;
    } else {
      borderColor = isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.border;
      fillColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: _focusNodes[index].hasFocus ? 2 : 1.5,
        ),
        boxShadow: _focusNodes[index].hasFocus
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          enabled: widget.enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: widget.isError
                ? AppColors.error
                : widget.isSuccess
                    ? AppColors.success
                    : isDark
                        ? Colors.white
                        : AppColors.textPrimary,
          ),
          onChanged: (value) => _onChanged(index, value),
        ),
      ),
    );
  }
}

/// نسخة مبسطة مع label ورسالة خطأ
class OtpInputWithLabel extends StatelessWidget {
  const OtpInputWithLabel({
    super.key,
    required this.onCompleted,
    this.onChanged,
    this.label,
    this.errorText,
    this.isSuccess = false,
    this.enabled = true,
    this.otpKey,
  });

  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? errorText;
  final bool isSuccess;
  final bool enabled;
  final GlobalKey<OtpInputFieldState>? otpKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
        ],
        OtpInputField(
          key: otpKey,
          onCompleted: onCompleted,
          onChanged: onChanged,
          isError: errorText != null,
          isSuccess: isSuccess,
          enabled: enabled,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorText!,
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (isSuccess) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.success,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تم التحقق بنجاح',
                    style: TextStyle(
                      color: AppColors.success,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
