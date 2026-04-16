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
import 'core/services/wakelock_service.dart';
import 'features/deliveries/providers/delivery_providers.dart';
import 'features/deliveries/providers/location_tracking_provider.dart';
import 'core/supabase/supabase_client.dart';
import 'di/injection.dart';

// ─── Required --dart-define variables ──────────────────────────────────────
//
// The following environment variables MUST be provided via --dart-define at
// build time. Without them the app will not connect to backend services or
// report errors.
//
//   SUPABASE_URL          – Supabase project URL (e.g. https://xxx.supabase.co)
//   SUPABASE_ANON_KEY     – Supabase anonymous/public API key
//   SENTRY_DSN_DRIVER     – Sentry DSN for crash reporting (optional in debug)
//
// Example (debug):
//   flutter run \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJ... \
//     --dart-define=SENTRY_DSN_DRIVER=https://xxx@xxx.ingest.sentry.io/xxx
//
// Example (release):
//   flutter build apk \
//     --dart-define=SUPABASE_URL=https://xxx.supabase.co \
//     --dart-define=SUPABASE_ANON_KEY=eyJ... \
//     --dart-define=SENTRY_DSN_DRIVER=https://xxx@xxx.ingest.sentry.io/xxx
// ──────────────────────────────────────────────────────────────────────────

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
    WakelockService.instance.disable();
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
    // Toggle screen wake lock based on active deliveries.
    // Screen stays on while the driver has any non-terminal delivery.
    ref.listen<AsyncValue<List<Map<String, dynamic>>>>(
      activeDeliveriesStreamProvider,
      (_, next) {
        final hasActive = next.valueOrNull?.isNotEmpty ?? false;
        if (hasActive) {
          WakelockService.instance.enable();
        } else {
          WakelockService.instance.disable();
        }
      },
    );

    // Wire location tracking — starts/stops automatically with active deliveries.
    ref.watch(locationTrackingWiringProvider);

    final router = ref.watch(driverRouterProvider);

    return MaterialApp.router(
      title: 'Alhai Driver',
      debugShowCheckedModeBanner: false,
      theme: AlhaiTheme.light,
      darkTheme: AlhaiTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
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
