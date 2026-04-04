import 'dart:async';
import 'dart:io';

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../di/injection.dart';
import '../data/auth_datasource.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;

  /// OTP cooldown
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _phoneController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownSeconds = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _cooldownSeconds--;
        if (_cooldownSeconds <= 0) {
          timer.cancel();
        }
      });
    });
  }

  bool get _isCooldownActive => _cooldownSeconds > 0;

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isCooldownActive) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final phone = '+966${_phoneController.text.trim()}';
      final datasource = locator<AuthDatasource>();
      await datasource.sendOtp(phone);

      _startCooldown();

      if (mounted) {
        context.push('/auth/otp', extra: phone);
      }
    } on SocketException catch (_) {
      setState(() => _error = 'لا يوجد اتصال بالإنترنت. تحقق من الشبكة وحاول مرة أخرى');
    } on TimeoutException catch (_) {
      setState(() => _error = 'انتهت مهلة الاتصال. حاول مرة أخرى');
    } catch (e) {
      setState(() => _error = 'فشل إرسال رمز التحقق. حاول مرة أخرى');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AlhaiSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                // Logo
                Builder(builder: (context) {
                  final logoSize = (MediaQuery.of(context).size.width * 0.25)
                      .clamp(80.0, 150.0);
                  return Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.storefront_rounded,
                      size: logoSize * 0.5,
                      color: theme.colorScheme.primary,
                    ),
                  );
                }),
                const SizedBox(height: AlhaiSpacing.xl),
                Text(
                  'مرحباً بك',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AlhaiSpacing.xs),
                Text(
                  'أدخل رقم جوالك لتسجيل الدخول',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AlhaiSpacing.xl),
                // Phone input
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textDirection: TextDirection.ltr,
                    maxLength: 9,
                    decoration: InputDecoration(
                      labelText: 'رقم الجوال',
                      hintText: '5XXXXXXXX',
                      prefixText: '+966 ',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: AlhaiRadius.borderMd,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'أدخل رقم الجوال';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
                        return 'رقم الجوال يجب أن يحتوي على أرقام فقط';
                      }
                      if (value.trim().length != 9) {
                        return 'رقم الجوال يجب أن يكون 9 أرقام';
                      }
                      if (!value.trim().startsWith('5')) {
                        return 'رقم الجوال يجب أن يبدأ بالرقم 5';
                      }
                      return null;
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
                  onPressed:
                    (_loading || _isCooldownActive) ? null : _sendOtp,
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
                          _isCooldownActive
                              ? 'إعادة الإرسال بعد $_cooldownSeconds ثانية'
                              : 'إرسال رمز التحقق',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
