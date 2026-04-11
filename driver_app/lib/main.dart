import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alhai_design_system/alhai_design_system.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/services/location_service.dart';
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

  // Allow all orientations so tablets can use landscape mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Style the status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  // Initialize Supabase
  try {
    await AppSupabase.initialize();
  } catch (e, stack) {
    reportError(e, stackTrace: stack, hint: 'Supabase init');
  }

  // Initialize DI
  configureDependencies();

  // Initialize location service
  try {
    await LocationService.instance.initialize();
  } catch (e, stack) {
    reportError(e, stackTrace: stack, hint: 'LocationService init');
  }

  addBreadcrumb(message: 'App initialized', category: 'lifecycle');

  runApp(const ProviderScope(child: DriverApp()));
}

class DriverApp extends ConsumerStatefulWidget {
  const DriverApp({super.key});

  @override
  ConsumerState<DriverApp> createState() => _DriverAppState();
}

class _DriverAppState extends ConsumerState<DriverApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Called whenever the app lifecycle state changes.
  ///
  /// On resume, we verify the Supabase session is still valid so that an
  /// expired or revoked token is caught immediately rather than on the next
  /// network request.  Supabase will attempt a silent token refresh; if the
  /// refresh fails (e.g. session was revoked server-side), the auth state
  /// stream will emit a [AuthChangeEvent.signedOut] event and the router's
  /// redirect guard will navigate the driver back to the login screen.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifySession();
    }
  }

  Future<void> _verifySession() async {
    try {
      final session = AppSupabase.client.auth.currentSession;
      if (session == null) return; // Not logged in – router handles redirect.

      // Refresh the session if the access token has expired or will expire
      // within the next minute (gives a buffer before requests start failing).
      final expiresAt = session.expiresAt; // Unix epoch seconds
      if (expiresAt != null) {
        final expiry = DateTime.fromMillisecondsSinceEpoch(
          expiresAt * 1000,
          isUtc: true,
        );
        final buffer = DateTime.now().toUtc().add(const Duration(minutes: 1));
        if (expiry.isBefore(buffer)) {
          await AppSupabase.client.auth.refreshSession();
          if (kDebugMode) debugPrint('Session refreshed on app resume');
        }
      }
    } catch (e) {
      // If refresh fails, Supabase signs the user out internally and the
      // onAuthStateChange stream triggers the router to redirect to /login.
      if (kDebugMode) debugPrint('Session verification failed on resume: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(driverRouterProvider);

    return MaterialApp.router(
      title: 'Alhai Driver',
      debugShowCheckedModeBanner: false,
      theme: AlhaiTheme.light,
      darkTheme: AlhaiTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
        Locale('ur'),
        Locale('hi'),
        Locale('id'),
        Locale('bn'),
      ],
      // Clamp text scaling to prevent layout overflows while still
      // respecting accessibility preferences within a safe range.
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final clampedScale = mediaQuery.textScaler.scale(1.0).clamp(0.8, 1.4);
        return MediaQuery(
          data: mediaQuery.copyWith(
            textScaler: TextScaler.linear(clampedScale),
          ),
          child: child!,
        );
      },
    );
  }
}
