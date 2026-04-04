import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_l10n/alhai_l10n.dart';
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show AppTheme, ThemeNotifier, ThemeState;
import 'dart:convert';
import 'dart:math';
import 'package:alhai_database/alhai_database.dart' show setDatabaseEncryptionKey;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alhai_core/alhai_core.dart' show SupabaseConfig;
import 'di/injection.dart';
import 'dart:async';
import 'router/admin_router.dart';
import 'screens/onboarding/onboarding_screen.dart';

/// Local theme provider (same pattern as cashier app)
final themeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Global error handlers
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('PlatformError: $error\n$stack');
      return true;
    };

  // Initialize Firebase (graceful fallback if not configured)
  try {
    await Firebase.initializeApp();
    if (kDebugMode) {
      debugPrint('Firebase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Firebase not configured: $e');
    }
    // App continues without Firebase - analytics/crashlytics won't work
  }

  // Initialize Supabase (required for admin - online-first)
  try {
    if (!SupabaseConfig.isConfigured) {
      throw StateError(
        'Supabase not configured. ${SupabaseConfig.configurationError}',
      );
    }
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
      debug: SupabaseConfig.enableDebugLogs,
    );
    if (kDebugMode) {
      debugPrint('Supabase initialized successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Supabase initialization failed: $e');
    }
  }

  // Initialize database encryption key before DI creates the database
  final dbKey = await _getOrCreateDbKey();
  setDatabaseEncryptionKey(dbKey);

  // DI must run before runApp (Riverpod providers use getIt synchronously)
  await configureDependencies();

  // Pre-load theme (fast ~50ms)
  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('app_theme_mode');
  final initialThemeMode = switch (savedTheme) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };

  // Pre-load onboarding flag
  final hasSeenOnboardingFlag = await hasSeenAdminOnboarding();

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => ThemeNotifier(initialThemeMode)),
        adminOnboardingSeenProvider.overrideWith((ref) => hasSeenOnboardingFlag),
      ],
      child: const AdminApp(),
    ),
  );
  }, (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
  });
}

/// Get or create database encryption key from secure storage.
/// On web, FlutterSecureStorage has no native keychain, so we fall back
/// to SharedPreferences (less secure but functional).
Future<String> _getOrCreateDbKey() async {
  const keyName = 'db_encryption_key';

  if (kIsWeb) {
    // SECURITY WARNING: SharedPreferences on web stores data in plaintext
    // localStorage, which is accessible to any JS running on the same origin.
    // This is a known limitation — web has no secure keychain equivalent.
    // The key is persisted so the encrypted DB can be reopened across sessions.
    // For production hardening, consider:
    //   1. Using a server-side key derivation (e.g. from auth session token)
    //   2. Encrypting the key with a passphrase entered by the user
    //   3. Using WebCrypto API with non-extractable keys
    if (kDebugMode) {
      debugPrint('WARNING: DB encryption key stored in localStorage (insecure on web)');
    }
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
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
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

class AdminApp extends ConsumerWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch theme state
    final themeState = ref.watch(themeProvider);

    // Watch locale state
    final localeState = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Al-HAI Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeState.themeMode,
      routerConfig: ref.watch(adminRouterProvider),
      // 7 language support
      locale: localeState.locale,
      supportedLocales: SupportedLocales.all,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Apply text direction (RTL for Arabic/Urdu)
      builder: (context, child) {
        return Directionality(
          textDirection: localeState.textDirection,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
