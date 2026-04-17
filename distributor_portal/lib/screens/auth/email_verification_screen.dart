/// Email Verification Screen
///
/// Shown after signup. Instructs the user to verify their email.
/// Listens for auth state changes to detect verification.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';

import '../../core/supabase/supabase_client.dart';
import '../../providers/distributor_datasource_provider.dart';
import '../../providers/distributor_onboarding_providers.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String? email;
  const EmailVerificationScreen({super.key, this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _resending = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  String get _displayEmail =>
      widget.email ?? AppSupabase.client.auth.currentUser?.email ?? '';

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    if (_resending || _cooldownSeconds > 0 || _displayEmail.isEmpty) return;

    setState(() => _resending = true);

    try {
      final ds = ref.read(distributorDatasourceProvider);
      await ds.resendVerificationEmail(_displayEmail);

      if (!mounted) return;
      _startCooldown();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إعادة إرسال البريد'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل إعادة الإرسال: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _resending = false);
    }
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
        if (_cooldownSeconds <= 0) timer.cancel();
      });
    });
  }

  Future<void> _checkVerification() async {
    // Refresh session to check if email was verified
    try {
      await AppSupabase.client.auth.refreshSession();
      final user = AppSupabase.client.auth.currentUser;
      if (user != null && user.emailConfirmedAt != null) {
        // Mark email verified in distributor record
        final ds = ref.read(distributorDatasourceProvider);
        await ds.markEmailVerified();
        // Invalidate status provider
        ref.invalidate(distributorAccountStatusProvider);
        if (!mounted) return;
        context.go('/dashboard');
      }
    } catch (_) {
      // Silently fail — user can try again
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= AlhaiBreakpoints.tablet;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? AlhaiSpacing.xl : AlhaiSpacing.lg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: EdgeInsets.all(isWide ? AlhaiSpacing.xl : AlhaiSpacing.lg),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: isDark
                  ? Border.all(color: AppColors.getBorder(true))
                  : null,
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Email icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    color: AppColors.primary,
                    size: 36,
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.lg),

                // Title
                Text(
                  'تحقّق من بريدك الإلكتروني',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AlhaiSpacing.md),

                // Subtitle
                Text(
                  'أرسلنا رسالة تأكيد إلى:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AlhaiSpacing.xs),

                // Email display
                Text(
                  _displayEmail,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AlhaiSpacing.lg),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(AlhaiSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.info.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(height: AlhaiSpacing.xs),
                      Text(
                        'يرجى الضغط على الرابط في البريد لتأكيد حسابك.\n'
                        'بعد التأكيد، حسابك سيدخل قائمة المراجعة.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.lg),

                // Check verification button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _checkVerification,
                    icon: const Icon(Icons.refresh),
                    label: const Text('تحقّقت بالفعل؟ اضغط هنا'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AlhaiSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.md),

                // Resend button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: (_resending || _cooldownSeconds > 0)
                        ? null
                        : _resendEmail,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AlhaiSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: _resending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _cooldownSeconds > 0
                                ? 'إعادة الإرسال ($_cooldownSeconds ث)'
                                : 'لم يصلك البريد؟ إعادة الإرسال',
                          ),
                  ),
                ),
                const SizedBox(height: AlhaiSpacing.md),

                // Back to login
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: Text(
                    'العودة لتسجيل الدخول',
                    style: TextStyle(color: AppColors.primary, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
