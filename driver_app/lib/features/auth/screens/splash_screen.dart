import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    final isAuth = ref.read(isAuthenticatedProvider);
    if (!isAuth) {
      context.go('/login');
      return;
    }

    // Load driver profile
    try {
      await ref.read(loadDriverProfileProvider.future);
    } catch (_) {}

    if (!mounted) return;

    final authState = ref.read(driverAuthStateProvider);
    switch (authState) {
      case DriverAuthState.unauthenticated:
        context.go('/login');
      case DriverAuthState.needsProfile:
        context.go('/profile-setup');
      case DriverAuthState.authenticated:
      case DriverAuthState.loading:
        context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_shipping_rounded,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.lg),
            Text(
              'Alhai Driver',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              'تطبيق السائق',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xxxl),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
