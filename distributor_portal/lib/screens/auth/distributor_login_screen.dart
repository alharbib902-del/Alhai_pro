/// Distributor Login Screen
///
/// Email + password auth via Supabase for distributor users.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import '../../core/supabase/supabase_client.dart';

class DistributorLoginScreen extends ConsumerStatefulWidget {
  const DistributorLoginScreen({super.key});

  @override
  ConsumerState<DistributorLoginScreen> createState() =>
      _DistributorLoginScreenState();
}

class _DistributorLoginScreenState
    extends ConsumerState<DistributorLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await AppSupabase.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      context.go('/dashboard');
    } catch (e) {
      if (kDebugMode) debugPrint('Login error: $e');
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _error = l10n.distributorLoginError;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final isWide = size.width >= AlhaiBreakpoints.tablet;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isWide ? AlhaiSpacing.xl : AlhaiSpacing.lg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 420),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  ExcludeSemantics(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.store,
                        color: AppColors.textOnPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.mdl),

                  // Title
                  Text(
                    l10n.distributorLogin,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xs),
                  Text(
                    l10n.distributorLoginSubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.xl),

                  // Error
                  if (_error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AlhaiSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 18,
                          ),
                          const SizedBox(width: AlhaiSpacing.xs),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AlhaiSpacing.md),
                  ],

                  // Email field
                  TextFormField(
                    controller: _emailController,
                    autofocus: true,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.distributorEmailLabel;
                      }
                      // Email format validation
                      final emailRegex = RegExp(
                        r'^[\w\-\.+]+@([\w\-]+\.)+[\w\-]{2,}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return l10n.distributorInvalidEmail;
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: '${l10n.distributorEmailLabel} *',
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest
                          : AppColors.backgroundSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  // Password field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.distributorPasswordLabel;
                      }
                      if (value.length < 8) {
                        return l10n.minLength(8);
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      labelText: '${l10n.distributorPasswordLabel} *',
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      suffixIcon: Semantics(
                        button: true,
                        label: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        child: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest
                          : AppColors.backgroundSecondary,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.lg),

                  // Login button
                  Semantics(
                    button: true,
                    label: l10n.distributorLoginButton,
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _login,
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
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.textOnPrimary,
                                ),
                              )
                            : Text(
                                l10n.distributorLoginButton,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AlhaiSpacing.md),

                  // Signup link
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/signup'),
                      child: Text(
                        'ليس لديك حساب؟ إنشاء حساب جديد',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
