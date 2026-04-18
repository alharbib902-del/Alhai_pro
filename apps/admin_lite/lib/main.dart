import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_l10n/alhai_l10n.dart'
    show AppLocalizations, SupportedLocales, localeProvider;
import 'package:alhai_shared_ui/alhai_shared_ui.dart'
    show ThemeNotifier, themeProvider, AppTheme;
import 'dart:convert';
import 'dart:math';
import 'package:alhai_database/alhai_database.dart'
    show setDatabaseEncryptionKey;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alhai_core/alhai_core.dart' show SupabaseConfig;
import 'package:package_info_plus/package_info_plus.dart';
import 'di/injection.dart';
import 'dart:async';
import 'router/lite_router.dart';
import 'screens/onboarding_screen.dart';
import 'screens/settings/lite_settings_screen.dart' show appVersionProvider;
import 'core/network/certificate_pinning_service.dart';
import 'core/services/sentry_service.dart';

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

  // Initialize Firebase (graceful fallback if not configured)
  try {
    await Firebase.initializeApp();
    if (kDebugMode) {
      debugPrint('Firebase initialized successfully');
    }
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('Firebase not configured: $e');
    }
    reportError(e, stackTrace: stack, hint: 'Firebase init');
    // App continues without Firebase - analytics/crashlytics won't work
  }

  // Initialize Supabase (required for Lite - sync & auth)
  try {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase not configured. ${SupabaseConfig.configurationError}',
      );
    }
    final pinnedClient = CertificatePinningService.createPinnedClient();
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: SupabaseConfig.enableDebugLogs,
      httpClient: pinnedClient,
    );
    if (kDebugMode) {
      debugPrint(
        'Supabase initialized — cert pinning: '
        '${CertificatePinningService.diagnosticStatus}',
      );
    }
  } catch (e, stack) {
    if (kDebugMode) {
      debugPrint('Supabase initialization failed: $e');
    }
    reportError(e, stackTrace: stack, hint: 'Supabase init');
  }

  // Initialize database encryption key before DI creates the database
  final dbKey = await _getOrCreateDbKey();
  setDatabaseEncryptionKey(dbKey);

  // DI must run before runApp (Riverpod providers use getIt synchronously)
  await configureDependencies();

  // Pre-load theme (~50ms)
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('app_theme_mode');
  final initialThemeMode = switch (savedTheme) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };

  // M56: Pre-load onboarding state so router guard can check synchronously
  final hasSeenOnboardingFlag = await hasSeenLiteOnboarding();

  // Read app version from platform (pubspec.yaml)
  String appVersion = 'v1.0.0-beta.1';
  try {
    final info = await PackageInfo.fromPlatform();
    if (info.version.isNotEmpty) {
      appVersion = 'v${info.version}';
    }
  } catch (_) {
    // Fallback to default
  }

  addBreadcrumb(message: 'App initialized', category: 'lifecycle');

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => ThemeNotifier(initialThemeMode)),
        liteOnboardingSeenProvider.overrideWith((ref) => hasSeenOnboardingFlag),
        appVersionProvider.overrideWith((ref) => appVersion),
      ],
      child: const AdminLiteApp(),
    ),
  );
}

/// Get or create database encryption key from secure storage.
/// On web, FlutterSecureStorage has no native keychain, so we fall back
/// to SharedPreferences (less secure but functional).
Future<String> _getOrCreateDbKey() async {
  const keyName = 'db_encryption_key';

  if (kIsWeb) {
    // SECURITY NOTE: Web platform lacks secure key storage.
    // Key stored in localStorage — acceptable for local cache encryption
    // since web DB is sandboxed per origin. Server-side data remains
    // protected by Supabase RLS policies.
    final prefs = await SharedPreferences.getInstance();
    var key = prefs.getString('secure_storage_$keyName');
    if (key == null) {
      final random = Random.secure();
      final values = List<int>.generate(32, (_) => random.nextInt(256));
      key = base64Url.encode(values);
      await prefs.setString('secure_storage_$keyName', key);
    }
    return key;
  } else {
    // Native: use FlutterSecureStorage (encrypted keychain)
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    var key = await storage.read(key: keyName);
    if (key == null) {
      final random = Random.secure();
      final values = List<int>.generate(32, (_) => random.nextInt(256));
      key = base64Url.encode(values);
      await storage.write(key: keyName, value: key);
    }
    return key;
  }
}

class AdminLiteApp extends ConsumerWidget {
  const AdminLiteApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Al-HAI Lite',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeState.themeMode,
      routerConfig: ref.watch(liteRouterProvider),
      locale: localeState.locale,
      supportedLocales: SupportedLocales.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: localeState.textDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
