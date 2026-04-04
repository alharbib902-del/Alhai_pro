import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/supabase/supabase_client.dart';
import 'di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    if (kDebugMode) debugPrint('Firebase init failed: $e');
  }

  // Initialize Supabase
  try {
    await AppSupabase.initialize();
  } catch (e) {
    if (kDebugMode) debugPrint('Supabase init failed: $e');
  }

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  // Wire DI
  configureDependencies();

  // FIX 5: Configure image cache for better performance
  PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024; // 100MB
  PaintingBinding.instance.imageCache.maximumSize = 200; // 200 images max

  runApp(
    const ProviderScope(
      child: CustomerApp(),
    ),
  );
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'بقالة الحي',
      debugShowCheckedModeBanner: false,
      theme: AlhaiTheme.light,
      darkTheme: AlhaiTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
      // RTL + localization support
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
