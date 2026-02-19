import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/responsive/responsive_utils.dart';
import '../../core/security/pin_service.dart';
import '../../l10n/generated/app_localizations.dart';

/// وضع الشاشة: إعداد أو تحقق أو حوار موافقة
enum ManagerApprovalMode { setup, verify, dialog }

/// شاشة موافقة المشرف بـ PIN
///
/// يمكن استخدامها كشاشة كاملة أو كحوار (dialog) عبر [showApprovalDialog].
class ManagerApprovalScreen extends ConsumerStatefulWidget {
  /// وضع العرض: dialog يُستخدم عند العرض كحوار
  final ManagerApprovalMode mode;

  /// وصف الإجراء المطلوب الموافقة عليه (يظهر في وضع dialog)
  final String? action;

  const ManagerApprovalScreen({
    super.key,
    this.mode = ManagerApprovalMode.verify,
    this.action,
  });

  /// عرض حوار موافقة المشرف ويعود بـ true إذا تم التحقق بنجاح
  ///
  /// يستخدم PinService مباشرة للتحقق (PBKDF2 + lockout).
  /// إذا لم يكن PIN مُعداً بعد، يعرض شاشة الإعداد أولاً.
  ///
  /// [context] - BuildContext
  /// [action] - وصف الإجراء (اختياري، يظهر للمستخدم)
  static Future<bool> showApprovalDialog(
    BuildContext context, {
    String? action,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ManagerApprovalScreen(
        mode: ManagerApprovalMode.dialog,
        action: action,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<ManagerApprovalScreen> createState() => _ManagerApprovalScreenState();
}

class _ManagerApprovalScreenState extends ConsumerState<ManagerApprovalScreen> {
  String _pin = '';
  bool _isLoading = false;
  String? _error;
  bool _needsSetup = false;
  bool _isSettingUp = false;
  String _setupPin = '';
  String _confirmPin = '';

  @override
  void initState() {
    super.initState();
    _checkPinSetup();
  }

  Future<void> _checkPinSetup() async {
    final hasPin = await PinService.isEnabled();
    if (!hasPin && mounted) {
      setState(() => _needsSetup = true);
    }
  }

  bool get _isDialogMode => widget.mode == ManagerApprovalMode.dialog;

  @override
  Widget build(BuildContext context) {
    if (_needsSetup) {
      if (_isDialogMode) {
        return _buildDialogWrapper(child: _buildSetupContent());
      }
      return _buildSetupScreen();
    }

    if (_isDialogMode) {
      return _buildDialogWrapper(child: _buildVerifyContent());
    }
    return _buildVerifyScreen();
  }

  /// غلاف الحوار (Dialog) مع حجم مناسب وتصميم موحد
  Widget _buildDialogWrapper({required Widget child}) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 420,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: child,
        ),
      ),
    );
  }

  /// محتوى شاشة الإعداد (بدون Scaffold) للاستخدام في Dialog
  Widget _buildSetupContent() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.lock_outline, size: 40, color: Colors.green.shade700),
        ),
        const SizedBox(height: 24),
        Text(
          _isSettingUp ? l10n.confirmPin : l10n.createNewPin,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isSettingUp ? l10n.reenterPinToConfirm : l10n.enterFourDigitPin,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600),
        ),
        const SizedBox(height: 32),
        _buildPinDots(
          currentPin: _isSettingUp ? _confirmPin : _setupPin,
          color: Colors.green,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 32),
        _buildKeypad(isSetup: true),
        if (_isLoading) ...[
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
        if (_isDialogMode) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600, fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSetupScreen() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.managerPinSetup),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: _buildSetupContent(),
        ),
      ),
    );
  }

  /// محتوى شاشة التحقق (بدون Scaffold) للاستخدام في Dialog
  Widget _buildVerifyContent() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.admin_panel_settings, size: 40, color: Colors.blue.shade700),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.enterManagerPin,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.action ?? l10n.operationRequiresApproval,
          style: TextStyle(color: isDark ? Colors.white70 : Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _buildPinDots(currentPin: _pin, color: Colors.blue),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: 32),
        _buildKeypad(isSetup: false),
        if (_isLoading) ...[
          const SizedBox(height: 24),
          const CircularProgressIndicator(),
        ],
        if (_isDialogMode) ...[
          const SizedBox(height: 16),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600, fontSize: 16),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerifyScreen() {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.managerPinSetup),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: _buildVerifyContent(),
        ),
      ),
    );
  }

  /// نقاط عرض PIN مع لون محدد
  Widget _buildPinDots({required String currentPin, required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 50,
          height: 60,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: index < currentPin.length ? color : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _error != null
                  ? Colors.red
                  : (index < currentPin.length ? color : Colors.grey.shade300),
              width: 2,
            ),
          ),
          child: Center(
            child: index < currentPin.length
                ? const Icon(Icons.circle, size: 16, color: Colors.white)
                : null,
          ),
        );
      }),
    );
  }

  Widget _buildKeypad({required bool isSetup}) {
    return SizedBox(
      width: 280,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: getResponsiveGridColumns(context, mobile: 2, desktop: 4),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          if (index == 9) {
            // Clear button
            return _KeypadButton(
              label: 'C',
              onTap: () => setState(() {
                if (isSetup) {
                  if (_isSettingUp) {
                    _confirmPin = '';
                  } else {
                    _setupPin = '';
                  }
                } else {
                  _pin = '';
                }
                _error = null;
              }),
              color: Colors.red.shade100,
              textColor: Colors.red,
            );
          } else if (index == 10) {
            // 0
            return _KeypadButton(
              label: '0',
              onTap: () => _addDigit('0', isSetup: isSetup),
            );
          } else if (index == 11) {
            // Backspace
            return _KeypadButton(
              icon: Icons.backspace_outlined,
              onTap: () {
                setState(() {
                  if (isSetup) {
                    if (_isSettingUp && _confirmPin.isNotEmpty) {
                      _confirmPin = _confirmPin.substring(0, _confirmPin.length - 1);
                    } else if (!_isSettingUp && _setupPin.isNotEmpty) {
                      _setupPin = _setupPin.substring(0, _setupPin.length - 1);
                    }
                  } else if (_pin.isNotEmpty) {
                    _pin = _pin.substring(0, _pin.length - 1);
                  }
                  _error = null;
                });
              },
              color: Colors.grey.shade200,
            );
          } else {
            // 1-9
            final digit = (index + 1).toString();
            return _KeypadButton(
              label: digit,
              onTap: () => _addDigit(digit, isSetup: isSetup),
            );
          }
        },
      ),
    );
  }

  void _addDigit(String digit, {required bool isSetup}) {
    if (_isLoading) return;

    if (isSetup) {
      if (_isSettingUp) {
        if (_confirmPin.length >= 4) return;
        setState(() {
          _confirmPin += digit;
          _error = null;
        });
        if (_confirmPin.length == 4) {
          _confirmSetup();
        }
      } else {
        if (_setupPin.length >= 4) return;
        setState(() {
          _setupPin += digit;
          _error = null;
        });
        if (_setupPin.length == 4) {
          setState(() => _isSettingUp = true);
        }
      }
    } else {
      if (_pin.length >= 4) return;
      setState(() {
        _pin += digit;
        _error = null;
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  Future<void> _confirmSetup() async {
    final l10n = AppLocalizations.of(context)!;
    if (_setupPin != _confirmPin) {
      setState(() {
        _error = l10n.pinsMismatch;
        _confirmPin = '';
      });
      return;
    }

    setState(() => _isLoading = true);

    final result = await PinService.createPin(_setupPin);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (!_isDialogMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.managerPinCreatedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
      setState(() {
        _needsSetup = false;
        _isSettingUp = false;
        _setupPin = '';
        _confirmPin = '';
      });
    } else {
      setState(() {
        _error = result.error;
        _confirmPin = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);

    final result = await PinService.verifyPin(_pin);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.isSuccess) {
      if (_isDialogMode) {
        // في وضع الحوار: نعود بـ true مباشرة
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.approvalGranted),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true); // Return success
      }
    } else {
      setState(() {
        _pin = '';

        if (result.errorType == PinError.lockedOut && result.lockedUntil != null) {
          final remaining = result.lockedUntil!.difference(DateTime.now());
          _error = l10n.accountLockedWaitMinutes(remaining.inMinutes);
        } else if (result.remainingAttempts != null) {
          _error = l10n.wrongPinAttemptsRemaining(result.remainingAttempts!);
        } else {
          _error = result.error;
        }
      });
    }
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? Colors.grey.shade100,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: icon != null
              ? Icon(icon, color: textColor ?? Colors.grey.shade700)
              : Text(
                  label ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Colors.grey.shade800,
                  ),
                ),
        ),
      ),
    );
  }
}
