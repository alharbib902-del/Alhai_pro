import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../security/pin_service.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_design_system/alhai_design_system.dart'
    show AlhaiContextExtensions, AlhaiSpacing;
import '../providers/auth_providers.dart';

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
  ConsumerState<ManagerApprovalScreen> createState() =>
      _ManagerApprovalScreenState();
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
    final screenWidth = context.screenWidth;
    final dialogWidth = screenWidth < 600 ? screenWidth * 0.9 : 420.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: child,
        ),
      ),
    );
  }

  /// محتوى شاشة الإعداد (بدون Scaffold) للاستخدام في Dialog
  Widget _buildSetupContent() {
    final l10n = AppLocalizations.of(context);
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
          child: Icon(
            Icons.lock_outline,
            size: 40,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.lg),
        Text(
          _isSettingUp ? l10n.confirmPin : l10n.createNewPin,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(
          _isSettingUp ? l10n.reenterPinToConfirm : l10n.enterFourDigitPin,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xl),
        _buildPinDots(
          currentPin: _isSettingUp ? _confirmPin : _setupPin,
          color: Colors.green,
        ),
        if (_error != null) ...[
          const SizedBox(height: AlhaiSpacing.sm),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: AlhaiSpacing.xl),
        _buildKeypad(isSetup: true),
        if (_isLoading) ...[
          const SizedBox(height: AlhaiSpacing.lg),
          const CircularProgressIndicator(),
        ],
        if (_isDialogMode) ...[
          const SizedBox(height: AlhaiSpacing.md),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSetupScreen() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.managerPinSetup), centerTitle: true),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final padding = isMobile ? 16.0 : 32.0;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildSetupContent(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// محتوى شاشة التحقق (بدون Scaffold) للاستخدام في Dialog
  Widget _buildVerifyContent() {
    final l10n = AppLocalizations.of(context);
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
          child: Icon(
            Icons.admin_panel_settings,
            size: 40,
            color: Colors.blue.shade700,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.lg),
        Text(
          l10n.enterManagerPin,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AlhaiSpacing.xs),
        Text(
          widget.action ?? l10n.operationRequiresApproval,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AlhaiSpacing.xl),
        _buildPinDots(currentPin: _pin, color: Colors.blue),
        if (_error != null) ...[
          const SizedBox(height: AlhaiSpacing.sm),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],
        const SizedBox(height: AlhaiSpacing.xl),
        _buildKeypad(isSetup: false),
        if (_isLoading) ...[
          const SizedBox(height: AlhaiSpacing.lg),
          const CircularProgressIndicator(),
        ],
        if (_isDialogMode) ...[
          const SizedBox(height: AlhaiSpacing.md),
          TextButton(
            onPressed: _isLoading
                ? null
                : () => Navigator.of(context).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVerifyScreen() {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.managerPinSetup), centerTitle: true),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final padding = isMobile ? 16.0 : 32.0;
            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: _buildVerifyContent(),
                ),
              ),
            );
          },
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
          margin: const EdgeInsets.symmetric(horizontal: AlhaiSpacing.xs),
          decoration: BoxDecoration(
            color: index < currentPin.length
                ? color
                : Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _error != null
                  ? Colors.red
                  : (index < currentPin.length
                        ? color
                        : Theme.of(context).colorScheme.outlineVariant),
              width: 2,
            ),
          ),
          child: Center(
            child: index < currentPin.length
                ? Icon(
                    Icons.circle,
                    size: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  )
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: AlhaiSpacing.sm,
          crossAxisSpacing: AlhaiSpacing.sm,
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
                      _confirmPin = _confirmPin.substring(
                        0,
                        _confirmPin.length - 1,
                      );
                    } else if (!_isSettingUp && _setupPin.isNotEmpty) {
                      _setupPin = _setupPin.substring(0, _setupPin.length - 1);
                    }
                  } else if (_pin.isNotEmpty) {
                    _pin = _pin.substring(0, _pin.length - 1);
                  }
                  _error = null;
                });
              },
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
    final l10n = AppLocalizations.of(context);
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
    final l10n = AppLocalizations.of(context);
    setState(() => _isLoading = true);

    try {
      final db = getIt<AppDatabase>();
      final storeId = ref.read(currentStoreIdProvider);

      if (storeId == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _pin = '';
          _error = 'لم يتم تحديد المتجر';
        });
        return;
      }

      // P0-1 fix: PinService is the ONLY security gate. Pre-fix the
      // primary path was a plaintext compare against `users.pin` —
      // that bypassed PBKDF2 and the lockout counter, so an attacker
      // could brute-force PINs as fast as the device disk allows.
      // Now every attempt — successful or failed — runs through
      // PinService, which:
      //   1. Refuses immediately if the lockout window is active.
      //   2. Compares the PBKDF2-salted hash in constant time.
      //   3. Increments the failure counter on miss + locks at 5.
      //
      // The legacy `db.usersDao.verifyPin(storeId, _pin)` plaintext
      // lookup is now only a SECONDARY audit-identification step
      // that runs ONLY after PinService says "approved" — its result
      // never gates approval, only fills in `userName` on the audit
      // row. If no matching DB row is found we still record the
      // approval, attributed to the currently-logged-in operator.
      final result = await PinService.verifyPin(_pin);
      if (!mounted) return;

      if (!result.isSuccess) {
        setState(() {
          _isLoading = false;
          _pin = '';
          if (result.errorType == PinError.lockedOut &&
              result.lockedUntil != null) {
            final remaining = result.lockedUntil!.difference(DateTime.now());
            _error = l10n.accountLockedWaitMinutes(remaining.inMinutes);
          } else if (result.remainingAttempts != null) {
            _error = l10n.wrongPinAttemptsRemaining(
              result.remainingAttempts!,
            );
          } else if (result.errorType == PinError.notEnabled) {
            _error = 'لم يتم إعداد PIN المدير على هذا الجهاز بعد';
          } else {
            _error = 'رمز PIN غير صحيح';
          }
        });
        return;
      }

      // PIN verified. Try to identify which DB user record matches
      // (for richer audit attribution). This is best-effort — a null
      // result means "device PIN matched but no per-user record" and
      // we fall back to the currently-logged-in operator.
      final matchingUser = await db.usersDao.verifyPin(storeId, _pin);
      final currentUser = ref.read(currentUserProvider);
      final approverId = matchingUser?.id ?? currentUser?.id ?? 'unknown';
      final approverName =
          matchingUser?.name ?? currentUser?.name ?? 'manager';

      // P0-1 fix: write the approval through the hash-chained audit
      // path, NOT the legacy `auditLogDao.log` direct insert. The
      // legacy path bypassed `__meta__` content+previous hashes, so
      // any tampering of an approval row went undetected by
      // `verifyChain`. Use `appendLogWithHashChain` directly here
      // because alhai_auth can't depend on the cashier app's
      // AuditService wrapper without a layer inversion.
      try {
        await db.auditLogDao.appendLogWithHashChain(
          storeId: storeId,
          userId: approverId,
          userName: approverName,
          action: AuditAction.settingsChange,
          payload: {
            'approvalAction': widget.action ?? 'unspecified',
            'pinSource':
                matchingUser != null ? 'user_record' : 'device_pin_only',
          },
          entityType: 'manager_approval',
          description:
              'موافقة المدير على: ${widget.action ?? 'عملية تتطلب موافقة'}',
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('خطأ في تسجيل الموافقة: $e');
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (_isDialogMode) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.approvalGranted),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _pin = '';
        _error = 'حدث خطأ أثناء التحقق. يرجى المحاولة مرة أخرى';
      });
      if (kDebugMode) {
        debugPrint('خطأ في التحقق من PIN المدير: $e');
      }
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
      color: color ?? Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: icon != null
              ? Icon(
                  icon,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                )
              : Text(
                  label ?? '',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
                ),
        ),
      ),
    );
  }
}
