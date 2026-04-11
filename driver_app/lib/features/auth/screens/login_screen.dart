import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // Saudi mobile numbers: 9 digits starting with 5 (e.g. 5XXXXXXXX).
  static final _saudiPhoneRegex = RegExp(r'^5\d{8}$');

  Future<void> _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _error = 'أدخل رقم الجوال');
      return;
    }
    if (!_saudiPhoneRegex.hasMatch(phone)) {
      setState(() => _error = 'أدخل رقم جوال سعودي صحيح (5XXXXXXXX)');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fullPhone = phone.startsWith('+') ? phone : '+966$phone';
      await ref.read(sendOtpProvider(fullPhone).future);
      setState(() {
        _otpSent = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'فشل إرسال الرمز. حاول مرة أخرى';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOtp() async {
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    if (otp.length < 6) {
      setState(() => _error = 'أدخل رمز التحقق كاملاً');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fullPhone = phone.startsWith('+') ? phone : '+966$phone';
      await ref.read(verifyOtpProvider((phone: fullPhone, otp: otp)).future);

      if (!mounted) return;

      final authState = ref.read(driverAuthStateProvider);
      if (authState == DriverAuthState.needsProfile) {
        context.go('/profile-setup');
      } else {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().contains('ليس حساب سائق')
            ? 'هذا الحساب ليس حساب سائق. تواصل مع الإدارة.'
            : 'رمز التحقق غير صحيح';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logoSize = MediaQuery.of(context).size.width * 0.25;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AlhaiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  // Logo
                  Center(
                    child: Container(
                      width: logoSize,
                      height: logoSize,
                      margin: const EdgeInsets.only(bottom: AlhaiSpacing.xl),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.local_shipping_rounded,
                        size: logoSize * 0.52,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    'تسجيل الدخول',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    'أدخل رقم جوالك المسجل كسائق',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AlhaiSpacing.xxl),

                  // Phone input – Saudi mobile: 9 digits starting with 5.
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _isLoading ? null : _sendOtp(),
                    enabled: !_otpSent,
                    maxLength: 9,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    decoration: InputDecoration(
                      labelText: 'رقم الجوال',
                      hintText: '5XXXXXXXX',
                      prefixText: '+966 ',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  if (_otpSent) ...[
                    const SizedBox(height: AlhaiSpacing.md),
                    TextField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _isLoading ? null : _verifyOtp(),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        labelText: 'رمز التحقق',
                        hintText: '------',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],

                  if (_error != null) ...[
                    const SizedBox(height: AlhaiSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AlhaiSpacing.sm),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: TextStyle(color: theme.colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],

                  const SizedBox(height: AlhaiSpacing.lg),

                  FilledButton(
                    onPressed: _isLoading
                        ? null
                        : (_otpSent ? _verifyOtp : _sendOtp),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AlhaiSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _otpSent ? 'تحقق' : 'إرسال رمز التحقق',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),

                  if (_otpSent) ...[
                    const SizedBox(height: AlhaiSpacing.sm),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              setState(() {
                                _otpSent = false;
                                _otpController.clear();
                                _error = null;
                              });
                            },
                      child: const Text('تغيير رقم الجوال'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
