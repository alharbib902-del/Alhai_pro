import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart'
    hide AuthException;

import '../../core/services/audit_log_service.dart';
import '../../providers/sa_dashboard_providers.dart' show saSupabaseClientProvider;

/// MFA verification/enrollment screen for Super Admin.
///
/// Shown after successful password + RPC verification.
/// Supports two modes:
///   1. **Verification**: User has TOTP enrolled — enter 6-digit code.
///   2. **Enrollment**: First login — display QR code for Authenticator app,
///      then verify to complete enrollment.
///
/// After successful MFA, the user's assurance level is upgraded to AAL2
/// and the router redirect grants dashboard access.
class SAMfaScreen extends ConsumerStatefulWidget {
  const SAMfaScreen({super.key});

  @override
  ConsumerState<SAMfaScreen> createState() => _SAMfaScreenState();
}

class _SAMfaScreenState extends ConsumerState<SAMfaScreen> {
  final _codeController = TextEditingController();

  bool _isLoading = true;
  bool _isVerifying = false;
  String? _error;
  int _failedAttempts = 0;
  DateTime? _lockoutUntil;

  // Enrollment state
  bool _needsEnrollment = false;
  String? _totpUri; // otpauth:// URI for QR code
  String? _factorId;
  String? _enrollSecret; // human-readable secret key

  static const _maxAttempts = 5;
  static const _lockoutDuration = Duration(minutes: 30);

  @override
  void initState() {
    super.initState();
    _checkMfaStatus();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  /// Check whether the user has TOTP enrolled or needs enrollment.
  Future<void> _checkMfaStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = ref.read(saSupabaseClientProvider);
      final aal = client.auth.mfa.getAuthenticatorAssuranceLevel();

      if (kDebugMode) {
        debugPrint('MFA AAL: current=${aal.currentLevel}, next=${aal.nextLevel}');
        debugPrint('MFA factors: ${aal.currentAuthenticationMethods}');
      }

      // If current is already AAL2, user is fully verified.
      if (aal.currentLevel == AuthenticatorAssuranceLevels.aal2) {
        // Already passed MFA — let router redirect to dashboard.
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Check if user has any TOTP factors enrolled.
      final factors = client.auth.currentUser?.factors ?? [];
      final totpFactors = factors.where(
        (f) => f.factorType == FactorType.totp && f.status == FactorStatus.verified,
      );

      if (totpFactors.isNotEmpty) {
        // Has enrolled TOTP — go to verification mode.
        _factorId = totpFactors.first.id;
        setState(() {
          _needsEnrollment = false;
          _isLoading = false;
        });
      } else {
        // No TOTP enrolled — start enrollment.
        await _startEnrollment();
      }
    } catch (e) {
      if (kDebugMode) debugPrint('MFA status check failed: $e');
      // If MFA API is not available (Supabase project doesn't have MFA enabled),
      // fall through and show enrollment — enrollment will fail with a clear error.
      await _startEnrollment();
    }
  }

  /// Start TOTP enrollment: generates a secret and returns a QR URI.
  Future<void> _startEnrollment() async {
    try {
      final client = ref.read(saSupabaseClientProvider);
      final res = await client.auth.mfa.enroll(
        factorType: FactorType.totp,
        friendlyName: 'Alhai Super Admin',
      );

      final totp = res.totp;
      if (totp == null) {
        setState(() {
          _error = 'TOTP enrollment returned no data.';
          _isLoading = false;
          _needsEnrollment = true;
        });
        return;
      }

      setState(() {
        _needsEnrollment = true;
        _totpUri = totp.uri;
        _factorId = res.id;
        _enrollSecret = totp.secret;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) debugPrint('MFA enrollment failed: $e');
      setState(() {
        _error = 'MFA enrollment failed. '
            'Ensure MFA is enabled in your Supabase project.';
        _isLoading = false;
        _needsEnrollment = true;
      });
    }
  }

  /// Check whether the user is locked out based on server-side audit_log.
  ///
  /// Returns `true` if locked out (5+ failed MFA attempts in 30 minutes).
  /// Fail-safe: returns `true` (deny) on any error.
  Future<bool> _checkLockoutFromServer() async {
    try {
      final client = ref.read(saSupabaseClientProvider);
      final user = client.auth.currentUser;
      if (user == null) return true; // fail-safe: no user → deny

      final thirtyMinAgo = DateTime.now()
          .subtract(const Duration(minutes: 30))
          .toUtc()
          .toIso8601String();

      final response = await client
          .from('audit_log')
          .select('id')
          .eq('target_id', user.id)
          .eq('action', 'auth.mfa_failed')
          .gte('created_at', thirtyMinAgo);

      final recentFailures = (response as List).length;
      return recentFailures >= _maxAttempts;
    } catch (e) {
      if (kDebugMode) debugPrint('Lockout check failed: $e');
      return true; // fail-safe: deny on error
    }
  }

  /// Verify a TOTP code (works for both first enrollment and subsequent logins).
  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length != 6 || int.tryParse(code) == null) {
      setState(() => _error = 'Enter a valid 6-digit code');
      return;
    }

    // Server-side lockout check (authoritative).
    final serverLocked = await _checkLockoutFromServer();
    if (serverLocked) {
      setState(() => _error = 'Too many failed attempts. Locked for 30 minutes.');
      return;
    }

    // In-memory lockout check (fast UI optimization, not authoritative).
    if (_lockoutUntil != null && DateTime.now().isBefore(_lockoutUntil!)) {
      final remaining = _lockoutUntil!.difference(DateTime.now()).inMinutes + 1;
      setState(() => _error = 'Account locked. Try again in $remaining minutes.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = null;
    });

    try {
      final client = ref.read(saSupabaseClientProvider);

      // Create a challenge for this factor.
      final challenge = await client.auth.mfa.challenge(
        factorId: _factorId!,
      );

      // Verify the TOTP code.
      await client.auth.mfa.verify(
        factorId: _factorId!,
        challengeId: challenge.id,
        code: code,
      );

      // Success — log and let GoRouter redirect to dashboard.
      _failedAttempts = 0;
      _logMfaEvent(success: true);

      if (mounted) {
        setState(() => _isVerifying = false);
        // GoRouter will pick up the AAL2 state and redirect to dashboard.
        // Force a refresh of auth state.
        ref.invalidate(authStateProvider);
      }
    } catch (e) {
      _failedAttempts++;
      _logMfaEvent(success: false, reason: 'invalid_code attempt=$_failedAttempts');

      if (_failedAttempts >= _maxAttempts) {
        _lockoutUntil = DateTime.now().add(_lockoutDuration);
        _logMfaEvent(success: false, reason: 'lockout_triggered');
      }

      if (mounted) {
        setState(() {
          _isVerifying = false;
          if (_failedAttempts >= _maxAttempts) {
            _error = 'Too many failed attempts. Locked for 30 minutes.';
          } else {
            _error =
                'Invalid code. ${_maxAttempts - _failedAttempts} attempts remaining.';
          }
        });
      }
    }
  }

  void _logMfaEvent({required bool success, String? reason}) {
    try {
      final authState = ref.read(authStateProvider);
      ref.read(auditLogServiceProvider).log(
        action: success ? 'auth.mfa_verified' : 'auth.mfa_failed',
        targetType: 'user',
        targetId: authState.user?.id ?? 'unknown',
        metadata: {
          'email': authState.user?.email ?? '',
          'enrollment': _needsEnrollment,
          if (reason != null) 'reason': reason,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Shield icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.security_rounded,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 24),

                      Text(
                        _needsEnrollment
                            ? 'Set Up Two-Factor Authentication'
                            : 'Two-Factor Verification',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      Text(
                        _needsEnrollment
                            ? 'Scan the QR code with your authenticator app '
                              '(Google Authenticator, Authy, etc.) then enter '
                              'the 6-digit code to complete setup.'
                            : 'Enter the 6-digit code from your authenticator app.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // QR code section (enrollment only)
                      if (_needsEnrollment && _totpUri != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Placeholder for QR — in a real app, use qr_flutter
                              // to render the QR code from _totpUri.
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 80,
                                      color: Colors.grey.shade600,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'QR Code',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_enrollSecret != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  'Manual entry key:',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                SelectableText(
                                  _enrollSecret!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: _enrollSecret!),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Secret copied'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy_rounded, size: 16),
                                  label: const Text('Copy'),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // MFA enrollment failed message
                      if (_needsEnrollment && _totpUri == null && _error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning_rounded,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Code input
                      if (_factorId != null) ...[
                        TextField(
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(6),
                          ],
                          decoration: InputDecoration(
                            hintText: '000000',
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onSubmitted: (_) => _verifyCode(),
                        ),
                        const SizedBox(height: 8),

                        // Error
                        if (_error != null && !(_needsEnrollment && _totpUri == null))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _error!,
                              style: TextStyle(color: theme.colorScheme.error),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Verify button
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: FilledButton(
                            onPressed: _isVerifying ? null : _verifyCode,
                            child: _isVerifying
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _needsEnrollment
                                        ? 'Complete Setup'
                                        : 'Verify',
                                  ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // Back to login
                      TextButton(
                        onPressed: () async {
                          await ref.read(authStateProvider.notifier).logout();
                        },
                        child: const Text('Back to Login'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
