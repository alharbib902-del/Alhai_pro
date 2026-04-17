import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/widgets/driving_mode_scale.dart';
import '../data/pickup_otp_service.dart';

/// Screen for entering the 4-digit pickup OTP.
///
/// Flow:
/// 1. Driver taps "Request OTP" → server generates code.
/// 2. Cashier reads OTP from their screen to driver.
/// 3. Driver enters 4 digits → taps "Verify".
/// 4. On success → callback triggers navigation to next step.
class PickupOtpScreen extends ConsumerStatefulWidget {
  final String orderId;
  final VoidCallback onVerified;

  const PickupOtpScreen({
    super.key,
    required this.orderId,
    required this.onVerified,
  });

  @override
  ConsumerState<PickupOtpScreen> createState() => _PickupOtpScreenState();
}

class _PickupOtpScreenState extends ConsumerState<PickupOtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  bool _otpRequested = false;
  String? _errorMessage;
  bool _isLocked = false;

  late PickupOtpService _otpService;

  @override
  void initState() {
    super.initState();
    _otpService = PickupOtpService(ref.read(supabaseClientProvider));
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  Future<void> _requestOtp() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _otpService.requestOtp(widget.orderId);
      setState(() => _otpRequested = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إرسال رمز التحقق للمتجر')),
        );
        _focusNodes[0].requestFocus();
      }
    } on OtpNotAvailableException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ. حاول مرة أخرى.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyOtp() async {
    final code = _otpCode;
    if (code.length != 4) {
      setState(() => _errorMessage = 'أدخل الرمز المكون من 4 أرقام');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _otpService.verifyOtp(orderId: widget.orderId, otpCode: code);
      // Success
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم التحقق بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onVerified();
      }
    } on OtpVerificationException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLocked = e.isLocked;
      });
      _clearInputs();
    } on OtpNotAvailableException catch (e) {
      setState(() => _errorMessage = e.message);
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ. حاول مرة أخرى.');
      _clearInputs();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearInputs() {
    for (final c in _controllers) {
      c.clear();
    }
    if (_focusNodes[0].canRequestFocus) {
      _focusNodes[0].requestFocus();
    }
  }

  void _onDigitChanged(int index, String value) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto-verify when all 4 digits entered.
    if (_otpCode.length == 4) {
      _verifyOtp();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تحقق من الاستلام')),
      body: DrivingModeScale(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(AlhaiSpacing.lg),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                    Text(
                      'اطلب من صاحب المتجر رمز التحقق',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AlhaiSpacing.xs),
                    Text(
                      'سيظهر الرمز على شاشة المتجر',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AlhaiSpacing.xl),

                    if (!_otpRequested) ...[
                      // Request OTP button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isLoading ? null : _requestOtp,
                          icon: const Icon(Icons.send),
                          label: const Text('طلب رمز التحقق'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ] else ...[
                      // OTP input boxes
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AlhaiSpacing.xs,
                            ),
                            child: SizedBox(
                              width: 56,
                              height: 64,
                              child: TextField(
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: theme.textTheme.headlineMedium,
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AlhaiRadius.md,
                                    ),
                                  ),
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                enabled: !_isLocked,
                                onChanged: (v) => _onDigitChanged(i, v),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AlhaiSpacing.lg),

                      // Verify button
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: (_isLoading || _isLocked)
                              ? null
                              : _verifyOtp,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('تحقق'),
                        ),
                      ),
                      const SizedBox(height: AlhaiSpacing.sm),

                      // Request new OTP
                      TextButton.icon(
                        onPressed: (_isLoading || _isLocked)
                            ? null
                            : _requestOtp,
                        icon: const Icon(Icons.refresh),
                        label: const Text('طلب رمز جديد'),
                      ),
                    ],

                    // Error message
                    if (_errorMessage != null) ...[
                      const SizedBox(height: AlhaiSpacing.md),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],

                    // Debug skip (dev only)
                    if (kDebugMode && !kReleaseMode) ...[
                      const SizedBox(height: AlhaiSpacing.xl),
                      const Divider(),
                      TextButton(
                        onPressed: _isLoading ? null : widget.onVerified,
                        child: Text(
                          '[DEV] تخطي التحقق',
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
