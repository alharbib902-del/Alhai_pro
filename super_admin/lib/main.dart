import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'core/router/app_router.dart';
import 'di/injection.dart';

void main() {
  configureDependencies();
  runApp(const ProviderScope(child: SuperAdminApp()));
}

class SuperAdminApp extends StatelessWidget {
  const SuperAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Alhai Super Admin',
      debugShowCheckedModeBanner: false,
      theme: AlhaiTheme.light,
      darkTheme: AlhaiTheme.dark,
      themeMode: ThemeMode.dark, // Dark mode by default for admin
      routerConfig: AppRouter.router,
      locale: const Locale('ar'),
    );
  }
}
