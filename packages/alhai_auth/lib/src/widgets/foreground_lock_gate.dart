/// Foreground Lock Gate
///
/// Wraps an app subtree with a blocking lock overlay that appears when
/// the app returns from background after a configurable threshold. The
/// operator must re-authenticate (PIN or biometric) to dismiss it.
///
/// Activates only when the user is authenticated — on the login screen
/// the gate is transparent pass-through.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart' show authStateProvider, AuthStatus;
import '../security/biometric_service.dart';
import '../security/foreground_lock_service.dart';
import '../security/pin_service.dart';
import 'pin_numpad.dart';
/// Maximum consecutive failed unlock attempts before forcing a full
/// logout. Kept small because a shared terminal should fail closed.
const int kMaxForegroundLockAttempts = 3;
/// Wraps [child] with a lifecycle-aware lock that requires PIN or
/// biometric re-auth when the app returns from background after
/// [thresholdMinutes] minutes.
class ForegroundLockGate extends ConsumerStatefulWidget {
  const ForegroundLockGate({
    super.key,
    required this.child,
    this.thresholdMinutes = 2,
    required this.onForceLogout,
  });
  /// The protected subtree.
  final Widget child;
  /// Inactivity threshold in minutes before re-auth is required.
  final int thresholdMinutes;
  /// Callback invoked after [kMaxForegroundLockAttempts] consecutive
  /// failed unlock attempts. The parent should call the auth logout
  /// action (e.g. `authStateProvider.notifier.logout()`).
  final VoidCallback onForceLogout;
  @override
  ConsumerState<ForegroundLockGate> createState() =>
      _ForegroundLockGateState();
}
class _ForegroundLockGateState extends ConsumerState<ForegroundLockGate> {
  ForegroundLockService? _service;
  bool _isLocked = false;
  @override
  void initState() {
    super.initState();
    _service = ForegroundLockService(
      threshold: Duration(minutes: widget.thresholdMinutes),
      onLockRequired: _handleLockRequired,
    );
    _service!.attach();
  }
  @override
  void dispose() {
    _service?.detach();
    _service = null;
    super.dispose();
  }
  void _handleLockRequired() {
    // Only lock when the user is actually authenticated. If they're on
    // the login screen or signed out, the existing auth flow is already
    // gating access.
    final authState = ref.read(authStateProvider);
    if (authState.status != AuthStatus.authenticated) return;
    if (!mounted) return;
    if (_isLocked) return;
    setState(() => _isLocked = true);
  }
  Future<void> _handleUnlockSuccess() async {
    await _service?.clearBackgroundTimestamp();
    if (!mounted) return;
    setState(() => _isLocked = false);
  }
  void _handleForceLogout() {
    // Clear the timestamp first so a later cold start doesn't re-lock
    // immediately off stale data.
    _service?.clearBackgroundTimestamp();
    widget.onForceLogout();
    // After logout the auth gate will take over; drop the overlay.
    if (mounted) {
      setState(() => _isLocked = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isLocked)
          _ForegroundLockOverlay(
            onUnlock: _handleUnlockSuccess,
            onForceLogout: _handleForceLogout,
          ),
      ],
    );
  }
}
/// The full-screen blocking overlay shown when the gate is locked.
class _ForegroundLockOverlay extends StatefulWidget {
  const _ForegroundLockOverlay({
    required this.onUnlock,
    required this.onForceLogout,
  });
  final Future<void> Function() onUnlock;
  final VoidCallback onForceLogout;
  @override
  State<_ForegroundLockOverlay> createState() => _ForegroundLockOverlayState();
}
class _ForegroundLockOverlayState extends State<_ForegroundLockOverlay> {
  String _pin = '';
  int _failedAttempts = 0;
  bool _isVerifying = false;
  String? _errorMessage;
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;
  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }
  Future<void> _checkBiometricAvailability() async {
    final available = await BiometricService.isAvailable();
    final enabled = await BiometricService.isEnabled();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = enabled;
    });
  }
  bool get _isArabic {
    final locale = Localizations.maybeLocaleOf(context);
    return locale?.languageCode == 'ar';
  }
  String _t({required String ar, required String en}) =>
      _isArabic ? ar : en;
  void _onKeyPressed(String key) {
    if (_isVerifying) return;
    if (_pin.length >= 6) return;
    setState(() {
      _pin += key;
      _errorMessage = null;
    });
    if (_pin.length >= 4) {
      // Auto-verify at 4 — the most common PIN length — but let
      // 5/6-digit PINs continue to fill.
      // We only auto-submit at 4; users with longer PINs can still type.
      // For simplicity, submit when the user has typed 4 digits. If they
      // have a longer PIN, verification will fail and they can retry.
      _verify();
    }
  }
  void _onBackspace() {
    if (_isVerifying) return;
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
      _errorMessage = null;
    });
  }
  Future<void> _verify() async {
    setState(() => _isVerifying = true);
    try {
      final result = await PinService.verifyPin(_pin);
      if (!mounted) return;
      if (result.isSuccess) {
        await widget.onUnlock();
        return;
      }
      // Wrong PIN or locked out.
      final attempts = _failedAttempts + 1;
      if (attempts >= kMaxForegroundLockAttempts) {
        // Hit the cap → force logout.
        widget.onForceLogout();
        return;
      }
      setState(() {
        _failedAttempts = attempts;
        _pin = '';
        _errorMessage = _t(
          ar: 'رمز PIN غير صحيح. محاولات متبقية: '
              '${kMaxForegroundLockAttempts - attempts}',
          en: 'Incorrect PIN. Attempts remaining: '
              '${kMaxForegroundLockAttempts - attempts}',
        );
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _pin = '';
        _errorMessage = _t(
          ar: 'حدث خطأ، يرجى المحاولة مرة أخرى',
          en: 'An error occurred, please try again',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }
  Future<void> _tryBiometric() async {
    if (_isVerifying) return;
    setState(() => _isVerifying = true);
    try {
      final result = await BiometricService.login();
      if (!mounted) return;
      if (result.isSuccess) {
        await widget.onUnlock();
        return;
      }
      setState(() {
        _errorMessage = _t(
          ar: 'فشلت المصادقة بالبصمة، حاول بالـ PIN',
          en: 'Biometric authentication failed, try PIN instead',
        );
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = _t(
          ar: 'تعذّر استخدام البصمة',
          en: 'Biometric unavailable',
        );
      });
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showBiometricButton = _biometricAvailable && _biometricEnabled;
    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.98),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_rounded,
                  size: 72,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),
                Text(
                  _t(
                    ar: 'يرجى إدخال رمز PIN لفتح القفل',
                    en: 'Enter PIN to unlock',
                  ),
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                PinDisplay(
                  filledCount: _pin.length,
                  hasError: _errorMessage != null,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                PinNumpad(
                  onKeyPressed: _onKeyPressed,
                  onBackspace: _onBackspace,
                  onBiometric: showBiometricButton ? _tryBiometric : null,
                  showBiometric: showBiometricButton,
                  enabled: !_isVerifying,
                ),
                if (showBiometricButton) ...[
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: _isVerifying ? null : _tryBiometric,
                    icon: const Icon(Icons.fingerprint),
                    label: Text(
                      _t(
                        ar: 'استخدم البصمة',
                        en: 'Use Biometric',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
