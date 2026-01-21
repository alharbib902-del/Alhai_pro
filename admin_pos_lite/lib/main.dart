import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'core/router/app_router.dart';
import 'di/injection.dart';

void main() {
  configureDependencies();
  runApp(const ProviderScope(child: AdminPosLiteApp()));
}

class AdminPosLiteApp extends StatelessWidget {
  const AdminPosLiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Alhai Admin Lite',
      debugShowCheckedModeBanner: false,
      theme: AlhaiTheme.light,
      darkTheme: AlhaiTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      locale: const Locale('ar'),
    );
  }
}
