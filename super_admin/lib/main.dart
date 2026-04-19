import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

import 'core/router/app_router.dart';
import 'core/services/sentry_service.dart';
import 'core/supabase/supabase_client.dart';
import 'di/injection.dart';

void main() {
  runZonedGuarded(
    () async {
      await initSentry(
        appRunner: () async {
          await _appMain();
        },
      );
    },
    (error, stack) {
      reportError(error, stackTrace: stack, hint: 'runZonedGuarded');
    },
  );
}

Future<void> _appMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global error handlers — send to Sentry
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    reportError(
      details.exception,
      stackTrace: details.stack,
      hint: 'FlutterError: ${details.library}',
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    reportError(error, stackTrace: stack, hint: 'PlatformDispatcher');
    return true;
  };

  // Initialize Supabase
  try {
    await AppSupabase.initialize();
  } catch (e, stack) {
    if (kDebugMode) debugPrint('Supabase init failed: $e');
    reportError(e, stackTrace: stack, hint: 'Supabase init');
  }

  configureDependencies();

  addBreadcrumb(message: 'App initialized', category: 'lifecycle');

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
      routerConfig: router,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
