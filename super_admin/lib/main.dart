import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'core/router/app_router.dart';
import 'di/injection.dart';

// L78: This app uses a router with placeholder screens per route.
// The router lives in core/router/app_router.dart with auth guard redirect.
// Responsive layout patterns (ResponsiveBuilder, breakpoints, adaptive
// navigation) should be applied when building real UI screens.
// See alhai_design_system responsive tokens and alhai_shared_ui ResponsiveScaffold.

void main() {
  configureDependencies();
  runApp(const ProviderScope(child: SuperAdminApp()));
}

class SuperAdminApp extends ConsumerWidget {
  const SuperAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(superAdminRouterProvider);

    return MaterialApp.router(
      title: 'Alhai Super Admin',
      debugShowCheckedModeBanner: false,
      theme: AlhaiTheme.light,
      darkTheme: AlhaiTheme.dark,
      themeMode: ThemeMode.dark, // Dark mode by default for admin
      routerConfig: router,
      locale: const Locale('ar'),
    );
  }
}
