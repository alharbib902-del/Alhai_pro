import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_auth/alhai_auth.dart';
import 'package:alhai_core/alhai_core.dart' show UserRole;
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/app_router.dart';
import '../../core/services/audit_log_service.dart';
import '../../core/services/mfa_guard_service.dart';
import '../../providers/sa_dashboard_providers.dart'
    show saSupabaseClientProvider;

/// Super Admin login screen.
/// Shows phone + OTP flow, then verifies the user has superAdmin role.
class SALoginScreen extends ConsumerStatefulWidget {
  const SALoginScreen({super.key});

  @override
  ConsumerState<SALoginScreen> createState() => _SALoginScreenState();
}

class _SALoginScreenState extends ConsumerState<SALoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context);
    final email = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = l10n.saEnterCredentials);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Step 1: Supabase email/password auth
      final result = await ref
          .read(authStateProvider.notifier)
          .signInWithEmailPassword(email: email, password: password);

      if (!result.success) {
        // Audit: failed login (password wrong or user not found)
        _logLoginAttempt(
          email: email,
          success: false,
          reason: result.error ?? 'auth_failed',
        );
        if (mounted) {
          setState(() {
            _error = result.error ?? l10n.saSignInFailed;
            _isLoading = false;
          });
        }
        return;
      }

      // Step 2: Client-side role check (fast path)
      final authState = ref.read(authStateProvider);
      if (authState.user?.role != UserRole.superAdmin) {
        _logLoginAttempt(
          email: email,
          userId: authState.user?.id,
          success: false,
          reason: 'client_role_not_super_admin',
        );
        await ref.read(authStateProvider.notifier).logout();
        if (mounted) {
          setState(() {
            _error = l10n.saAccessDenied;
            _isLoading = false;
          });
        }
        return;
      }

      // Step 3: Server-side RPC verification — the critical addition.
      // Even if the client-side role says super_admin, we verify against
      // the database's is_super_admin() function which checks public.users.
      final serverVerified = await _verifySuperAdminRpc();
      if (!serverVerified) {
        _logLoginAttempt(
          email: email,
          userId: authState.user?.id,
          success: false,
          reason: 'rpc_is_super_admin_rejected',
        );
        await ref.read(authStateProvider.notifier).logout();
        if (mounted) {
          setState(() {
            _error = l10n.saAccessDenied;
            _isLoading = false;
          });
        }
        return;
      }

      // Step 4: Check MFA status — redirect to MFA screen if needed.
      final mfaRequired = await _checkMfaRequired();
      if (mfaRequired) {
        _logLoginAttempt(
          email: email,
          userId: authState.user?.id,
          success: true,
          reason: 'password_verified_mfa_pending',
        );
        if (mounted) {
          setState(() => _isLoading = false);
          context.go(SuperAdminRoutes.mfa);
        }
        return;
      }

      // Step 5: No MFA or already at AAL2 — full login success.
      _logLoginAttempt(email: email, userId: authState.user?.id, success: true);
    } catch (e) {
      _logLoginAttempt(email: email, success: false, reason: e.toString());
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _isLoading = false);
  }

  /// Calls the database `is_super_admin()` RPC to verify the current
  /// authenticated user truly has the super_admin role server-side.
  ///
  /// Returns `true` only if the RPC confirms the role. Any error
  /// (network, missing function, etc.) is treated as a rejection to
  /// fail-safe: if we can't verify, we don't allow access.
  Future<bool> _verifySuperAdminRpc() async {
    try {
      final client = ref.read(saSupabaseClientProvider);
      final result = await client.rpc('is_super_admin');
      // The RPC returns a boolean directly.
      if (result == true) return true;
      if (kDebugMode) {
        debugPrint('is_super_admin RPC returned: $result');
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('is_super_admin RPC failed: $e');
      }
      // Fail-safe: if we can't verify, deny access.
      return false;
    }
  }

  /// Checks whether the user needs to complete MFA verification.
  ///
  /// Returns `true` if the user has TOTP factors enrolled (or needs
  /// enrollment) and the current AAL is below AAL2. Returns `false`
  /// if MFA is not available or the user is already at AAL2.
  Future<bool> _checkMfaRequired() async {
    // Delegates to MfaGuardService so router + login share one implementation.
    final client = ref.read(saSupabaseClientProvider);
    return MfaGuardService.requiresMfa(client);
  }

  /// Fire-and-forget audit log entry for login attempts.
  void _logLoginAttempt({
    required String email,
    String? userId,
    required bool success,
    String? reason,
  }) {
    try {
      final audit = ref.read(auditLogServiceProvider);
      audit.log(
        action: success ? 'auth.login' : 'auth.login_failed',
        targetType: 'user',
        targetId: userId ?? email,
        metadata: {
          'email': email,
          if (reason != null) 'reason': reason,
          'timestamp': DateTime.now().toUtc().toIso8601String(),
        },
      );
    } catch (_) {
      // Never block login flow due to audit failure.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 48,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  l10n.saSuperAdmin,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.saPlatformManagement,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // Email field
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _login(),
                ),
                const SizedBox(height: 8),

                // Error message
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      _error!,
                      style: TextStyle(color: theme.colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 24),

                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _login,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.saSignIn),
                  ),
                ),

                const SizedBox(height: 24),

                // Hint
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.amber.withValues(alpha: 0.1)
                        : Colors.amber.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 20,
                        color: Colors.amber.shade700,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.saSuperAdminOnly,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? Colors.amber.shade300
                                : Colors.amber.shade800,
                          ),
                        ),
                      ),
                    ],
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
