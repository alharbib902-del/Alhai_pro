import 'dart:async';

import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/supabase/supabase_client.dart';
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
    if (!mounted) return;

    try {
      if (AppSupabase.isAuthenticated) {
        // Load user profile with timeout
        await ref
            .read(loadCurrentUserProvider.future)
            .timeout(const Duration(seconds: 10));
        if (mounted) context.go('/home');
      } else {
        if (mounted) context.go('/auth/login');
      }
    } on TimeoutException {
      // Auth check timed out — send to login
      if (mounted) context.go('/auth/login');
    } catch (_) {
      // Any other error — send to login
      if (mounted) context.go('/auth/login');
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
            const SizedBox(height: AlhaiSpacing.lg),
            Text(
              'بقالة الحي',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AlhaiSpacing.xs),
            Text(
              'تسوق من أقرب بقالة',
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
