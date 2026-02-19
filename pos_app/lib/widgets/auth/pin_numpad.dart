/// PIN Numpad Widget - لوحة أرقام PIN
///
/// لوحة أرقام لإدخال رمز PIN مع تصميم حديث
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/generated/app_localizations.dart';

/// عرض خانات PIN
class PinDisplay extends StatelessWidget {
  final int length;
  final int filledCount;
  final bool hasError;
  final bool obscure;

  const PinDisplay({
    super.key,
    this.length = 4,
    required this.filledCount,
    this.hasError = false,
    this.obscure = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFilled = index < filledCount;
        final isNext = index == filledCount;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 56,
          height: 64,
          decoration: BoxDecoration(
            color: isFilled
                ? (hasError ? AppColors.error.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1))
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError
                  ? AppColors.error
                  : isFilled
                      ? AppColors.primary
                      : isNext
                          ? AppColors.primary.withValues(alpha: 0.5)
                          : AppColors.border,
              width: isFilled || isNext ? 2 : 1,
            ),
            boxShadow: isNext
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isFilled
                ? (obscure
                    ? Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: hasError ? AppColors.error : AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      )
                    : Text(
                        '●',
                        style: TextStyle(
                          color: hasError ? AppColors.error : AppColors.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ))
                : null,
          ),
        );
      }),
    );
  }
}

/// لوحة أرقام PIN
class PinNumpad extends StatelessWidget {
  final ValueChanged<String> onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onBiometric;
  final bool showBiometric;
  final bool enabled;

  const PinNumpad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    this.onBiometric,
    this.showBiometric = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // الصف الأول: 1 2 3
        _buildRow(['1', '2', '3']),
        const SizedBox(height: 16),

        // الصف الثاني: 4 5 6
        _buildRow(['4', '5', '6']),
        const SizedBox(height: 16),

        // الصف الثالث: 7 8 9
        _buildRow(['7', '8', '9']),
        const SizedBox(height: 16),

        // الصف الرابع: Biometric 0 Backspace
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // زر البصمة أو فارغ
            if (showBiometric)
              _NumpadButton(
                icon: Icons.fingerprint_rounded,
                onPressed: enabled ? onBiometric : null,
                isSpecial: true,
              )
            else
              const SizedBox(width: 80),

            const SizedBox(width: 16),

            // زر 0
            _NumpadButton(
              text: '0',
              onPressed: enabled ? () => onKeyPressed('0') : null,
            ),

            const SizedBox(width: 16),

            // زر الحذف
            _NumpadButton(
              icon: Icons.backspace_outlined,
              onPressed: enabled ? onBackspace : null,
              isSpecial: true,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys.asMap().entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(
            left: entry.key > 0 ? 16 : 0,
          ),
          child: _NumpadButton(
            text: entry.value,
            onPressed: enabled ? () => onKeyPressed(entry.value) : null,
          ),
        );
      }).toList(),
    );
  }
}

/// زر في لوحة الأرقام
class _NumpadButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSpecial;

  const _NumpadButton({
    this.text,
    this.icon,
    this.onPressed,
    this.isSpecial = false,
  });

  @override
  State<_NumpadButton> createState() => _NumpadButtonState();
}

class _NumpadButtonState extends State<_NumpadButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _controller.forward();
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _handleTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: widget.isSpecial
                ? AppColors.backgroundSecondary
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: widget.text != null
                ? Text(
                    widget.text!,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Icon(
                    widget.icon,
                    color: widget.isSpecial
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                    size: 28,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Dialog موافقة المدير
class ManagerApprovalDialog extends StatefulWidget {
  final String action;
  final String? description;
  final Future<bool> Function(String pin) onVerify;

  const ManagerApprovalDialog({
    super.key,
    required this.action,
    this.description,
    required this.onVerify,
  });

  /// عرض الـ Dialog
  static Future<bool> show({
    required BuildContext context,
    required String action,
    String? description,
    required Future<bool> Function(String pin) onVerify,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ManagerApprovalDialog(
        action: action,
        description: description,
        onVerify: onVerify,
      ),
    );
    return result ?? false;
  }

  @override
  State<ManagerApprovalDialog> createState() => _ManagerApprovalDialogState();
}

class _ManagerApprovalDialogState extends State<ManagerApprovalDialog> {
  String _pin = '';
  bool _isVerifying = false;
  bool _hasError = false;
  String? _errorMessage;

  void _onKeyPressed(String key) {
    if (_pin.length < 4 && !_isVerifying) {
      setState(() {
        _pin += key;
        _hasError = false;
        _errorMessage = null;
      });

      if (_pin.length == 4) {
        _verify();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty && !_isVerifying) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _hasError = false;
        _errorMessage = null;
      });
    }
  }

  Future<void> _verify() async {
    setState(() => _isVerifying = true);

    try {
      final success = await widget.onVerify(_pin);
      if (success) {
        if (mounted) Navigator.of(context).pop(true);
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'رمز PIN غير صحيح';
          _pin = '';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'حدث خطأ، يرجى المحاولة مرة أخرى';
        _pin = '';
      });
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة القفل
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            // العنوان
            const Text(
              'موافقة المدير',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // الوصف
            Text(
              widget.description ?? 'الإجراء "${widget.action}" يتطلب صلاحيات مدير',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // عرض PIN
            PinDisplay(
              filledCount: _pin.length,
              hasError: _hasError,
            ),

            // رسالة الخطأ
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 14,
                ),
              ),
            ],

            const SizedBox(height: 32),

            // لوحة الأرقام
            PinNumpad(
              onKeyPressed: _onKeyPressed,
              onBackspace: _onBackspace,
              enabled: !_isVerifying,
            ),

            const SizedBox(height: 24),

            // زر الإلغاء
            TextButton(
              onPressed: _isVerifying
                  ? null
                  : () => Navigator.of(context).pop(false),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// حقل إدخال PIN منفصل (للاستخدام في شاشات أخرى)
class PinInputField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool obscure;

  const PinInputField({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.autofocus = true,
    this.obscure = true,
  });

  @override
  State<PinInputField> createState() => _PinInputFieldState();
}

class _PinInputFieldState extends State<PinInputField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

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

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _currentPin {
    return _controllers.map((c) => c.text).join();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        widget.onCompleted?.call(_currentPin);
      }
    }
    widget.onChanged?.call(_currentPin);
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          width: 56,
          height: 64,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) => _onKeyDown(index, event),
            child: TextField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              obscureText: widget.obscure,
              obscuringCharacter: '●',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => _onChanged(index, value),
            ),
          ),
        );
      }),
    );
  }
}
