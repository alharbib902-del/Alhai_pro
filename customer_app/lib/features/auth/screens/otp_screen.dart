import 'dart:async';
import 'dart:io';

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/providers/app_providers.dart';
import '../../../di/injection.dart';
import '../data/auth_datasource.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  bool _loading = false;
  String? _error;

  /// OTP verification rate limiting (persisted via SharedPreferences)
  int _failedAttempts = 0;
  int _lockoutSeconds = 0;
  Timer? _lockoutTimer;

  /// Resend cooldown
  int _resendCooldownSeconds = 0;
  Timer? _resendTimer;

  static const int _maxAttempts = 5;
  static const int _lockoutDuration = 900; // 15 minutes
  static const int _resendCooldown = AppConstants.otpLockoutSeconds;

  String get _attemptsKey => 'otp_failed_attempts_${widget.phone}';
  String get _lockoutKey => 'otp_lockout_until_${widget.phone}';

  @override
  void initState() {
    super.initState();
    _restoreRateLimitState();
    _startResendCooldown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _lockoutTimer?.cancel();
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _restoreRateLimitState() async {
    final prefs = await SharedPreferences.getInstance();
    _failedAttempts = prefs.getInt(_attemptsKey) ?? 0;
    final lockoutUntilMs = prefs.getInt(_lockoutKey) ?? 0;
    if (lockoutUntilMs > 0) {
      final remaining = lockoutUntilMs - DateTime.now().millisecondsSinceEpoch;
      if (remaining > 0) {
        if (mounted) {
          setState(() => _lockoutSeconds = (remaining / 1000).ceil());
        }
        _startLockoutTimer();
      } else {
        // Lockout expired — reset
        await prefs.remove(_attemptsKey);
        await prefs.remove(_lockoutKey);
        _failedAttempts = 0;
      }
    }
  }

  Future<void> _persistRateLimitState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_attemptsKey, _failedAttempts);
  }

  bool get _isLockedOut => _lockoutSeconds > 0;

  Future<void> _startLockout() async {
    _lockoutSeconds = _lockoutDuration;
    final prefs = await SharedPreferences.getInstance();
    final lockoutUntilMs =
        DateTime.now().millisecondsSinceEpoch + (_lockoutDuration * 1000);
    await prefs.setInt(_lockoutKey, lockoutUntilMs);
    _startLockoutTimer();
  }

  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _lockoutSeconds--;
        if (_lockoutSeconds <= 0) {
          timer.cancel();
          _failedAttempts = 0;
          // Clear persisted state when lockout expires
          SharedPreferences.getInstance().then((prefs) {
            prefs.remove(_attemptsKey);
            prefs.remove(_lockoutKey);
          });
        }
      });
    });
  }

  void _startResendCooldown() {
    _resendCooldownSeconds = _resendCooldown;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _resendCooldownSeconds--;
        if (_resendCooldownSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      if (mounted) setState(() => _error = 'أدخل رمز التحقق المكون من 6 أرقام');
      return;
    }

    if (_isLockedOut) {
      if (mounted) {
        setState(
          () => _error = 'تم تجاوز عدد المحاولات. انتظر $_lockoutSeconds ثانية',
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final datasource = locator<AuthDatasource>();
      final result = await datasource.verifyOtp(widget.phone, otp);

      // Update user state
      ref.read(currentUserProvider.notifier).state = result.user;

      if (mounted) context.go('/home');
    } on SocketException catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مرة أخرى',
        );
      }
    } on TimeoutException catch (_) {
      if (mounted) setState(() => _error = 'انتهت مهلة الاتصال. حاول مرة أخرى');
    } catch (e) {
      _failedAttempts++;
      _persistRateLimitState();
      if (_failedAttempts >= _maxAttempts) {
        await _startLockout();
        if (mounted) {
          setState(
            () =>
                _error = 'تم تجاوز عدد المحاولات. انتظر $_lockoutSeconds ثانية',
          );
        }
      } else {
        final remaining = _maxAttempts - _failedAttempts;
        if (mounted) {
          setState(
            () => _error = 'رمز التحقق غير صحيح ($remaining محاولات متبقية)',
          );
        }
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCooldownSeconds > 0) return;

    try {
      final datasource = locator<AuthDatasource>();
      await datasource.sendOtp(widget.phone);
      _startResendCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إعادة إرسال رمز التحقق')),
        );
      }
    } on SocketException catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لا يوجد اتصال بالإنترنت')),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OtpScreen] Error resending OTP: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل إعادة إرسال الرمز. حاول مرة أخرى')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'رجوع',
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AlhaiSpacing.lg),
              Icon(
                Icons.sms_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: AlhaiSpacing.lg),
              Text(
                'رمز التحقق',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AlhaiSpacing.xs),
              Text(
                'أدخل الرمز المرسل إلى ${widget.phone}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AlhaiSpacing.xl),
              Directionality(
                textDirection: TextDirection.ltr,
                child: TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  enabled: !_isLockedOut,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    letterSpacing: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '------',
                    border: OutlineInputBorder(
                      borderRadius: AlhaiRadius.borderMd,
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length == 6) _verifyOtp();
                  },
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: AlhaiSpacing.lg),
              FilledButton(
                onPressed: (_loading || _isLockedOut) ? null : _verifyOtp,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: AlhaiRadius.borderMd,
                  ),
                ),
                child: _loading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        _isLockedOut ? 'انتظر $_lockoutSeconds ثانية' : 'تأكيد',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
              const SizedBox(height: AlhaiSpacing.md),
              TextButton(
                onPressed: _resendCooldownSeconds > 0 ? null : _resendOtp,
                child: Text(
                  _resendCooldownSeconds > 0
                      ? 'إعادة الإرسال بعد $_resendCooldownSeconds ثانية'
                      : 'إعادة إرسال الرمز',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
