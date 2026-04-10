import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/services/sentry_service.dart';
import 'core/supabase/supabase_client.dart';
import 'di/injection.dart';
import 'providers/distributor_providers.dart';

void main() {
  runZonedGuarded(() async {
    await initSentry(appRunner: () async {
      await _appMain();
    });
  }, (error, stack) {
    reportError(error, stackTrace: stack, hint: 'runZonedGuarded');
  });
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

  // Initialize SharedPreferences
  await SharedPreferences.getInstance();

  // Wire DI
  configureDependencies();

  addBreadcrumb(message: 'App initialized', category: 'lifecycle');

  runApp(const ProviderScope(child: DistributorPortalApp()));
}

class DistributorPortalApp extends ConsumerWidget {
  const DistributorPortalApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(distributorRouterProvider);
    final localeState = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Alhai Distributor Portal',
      debugShowCheckedModeBanner: false,
      theme: AlhaiTheme.light,
      darkTheme: AlhaiTheme.dark,
      themeMode: themeMode,
      themeAnimationDuration: const Duration(milliseconds: 300),
      themeAnimationCurve: Curves.easeInOut,
      routerConfig: router,
      locale: localeState.locale,
      supportedLocales: SupportedLocales.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        final isRtl = Directionality.of(context) == TextDirection.rtl;
        return Directionality(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: SessionTimeoutWrapper(
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
