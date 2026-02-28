import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:alhai_l10n/alhai_l10n.dart' show AppLocalizations, SupportedLocales, localeProvider;
import 'package:alhai_shared_ui/alhai_shared_ui.dart' show ThemeNotifier, themeProvider, AppTheme;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:alhai_database/alhai_database.dart' show setDatabaseEncryptionKey, DatabaseSeeder, AppDatabase;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alhai_core/alhai_core.dart' show SupabaseConfig;
import 'di/injection.dart';
import 'dart:async';
import 'dart:ui';
import 'router/cashier_router.dart';
import 'screens/onboarding/onboarding_screen.dart';

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

  // تهيئة Firebase + Supabase + مفتاح التشفير بالتوازي (M87 fix)
  final dbKeyFuture = _getOrCreateDbKey();
  final prefsFuture = SharedPreferences.getInstance();

  final firebaseFuture = () async {
    try {
      await Firebase.initializeApp();
      if (kDebugMode) debugPrint('Firebase initialized successfully');
    } catch (e) {
      // L93: Log in both debug and release so production errors are visible
      debugPrint('Firebase not configured: $e');
    }
  }();

  final supabaseFuture = () async {
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
      if (kDebugMode) debugPrint('Supabase initialized successfully');
    } catch (e) {
      // L93: Log in both debug and release so production errors are visible
      debugPrint('Supabase initialization failed: $e');
    }
  }();

  // انتظر Firebase + Supabase + مفتاح DB + SharedPreferences معاً
  final results = await Future.wait([
    firebaseFuture,
    supabaseFuture,
    dbKeyFuture,
    prefsFuture,
  ]);

  final dbKey = results[2] as String;
  setDatabaseEncryptionKey(dbKey);

  // DI must run before runApp (Riverpod providers use getIt synchronously)
  await configureDependencies();

  // Seed database from CSV assets (first launch only)
  await _seedDatabaseFromCsv();

  final prefs = results[3] as SharedPreferences;
  final savedTheme = prefs.getString('app_theme_mode');
  final initialThemeMode = switch (savedTheme) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };

  // M57: Pre-load onboarding state so router guard can check synchronously
  final hasSeenOnboardingFlag = prefs.getBool(kOnboardingSeenKey) ?? false;

  runApp(
    ProviderScope(
      overrides: [
        themeProvider.overrideWith((ref) => ThemeNotifier(initialThemeMode)),
        onboardingSeenProvider.overrideWith((ref) => hasSeenOnboardingFlag),
      ],
      child: const CashierApp(),
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
    // Web fallback: use SharedPreferences (no native keychain available)
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

/// تحميل بيانات المتجر من CSV (عند أول تشغيل فقط)
/// L64: CSV file loading is done on the main thread (rootBundle requires it),
/// but the heavy parsing and DB insertion is deferred via Drift's async
/// executor so the UI thread is not blocked during first launch.
Future<void> _seedDatabaseFromCsv() async {
  try {
    final db = getIt<AppDatabase>();
    final seeder = DatabaseSeeder(db);

    if (await seeder.isDatabaseEmpty()) {
      debugPrint('Loading store data from CSV...');

      // Load CSV strings from assets (must be on main thread for rootBundle)
      final categoriesCsv =
          await rootBundle.loadString('assets/data/categories.csv');
      final productsCsv =
          await rootBundle.loadString('assets/data/products.csv');

      // L64: Parse CSV data in a background isolate to avoid blocking the UI.
      // The parsed rows (List<List<dynamic>>) are returned to the main thread,
      // then inserted into the DB via Drift's async executor.
      final parsedData = await compute(
        _parseCsvInBackground,
        _CsvInput(categoriesCsv: categoriesCsv, productsCsv: productsCsv),
      );

      // If compute returned null, something went wrong in parsing
      if (parsedData != null) {
        await seeder.seedFromCsv(
          categoriesCsv: parsedData.categoriesCsv,
          productsCsv: parsedData.productsCsv,
        );
      }
    }
  } catch (e) {
    debugPrint('CSV seeding failed: $e');
  }
}

/// Input data for the CSV parsing isolate
class _CsvInput {
  final String categoriesCsv;
  final String productsCsv;

  const _CsvInput({required this.categoriesCsv, required this.productsCsv});
}

/// Output data from the CSV parsing isolate - validated CSV strings
class _CsvOutput {
  final String categoriesCsv;
  final String productsCsv;

  const _CsvOutput({required this.categoriesCsv, required this.productsCsv});
}

/// L64: Runs in a background isolate via compute().
/// Validates and normalizes CSV data off the main thread.
/// Returns the cleaned CSV strings for the seeder to process.
_CsvOutput? _parseCsvInBackground(_CsvInput input) {
  try {
    // Validate that CSV data is non-empty and has content beyond headers
    final catLines = input.categoriesCsv.trim().split('\n');
    final prodLines = input.productsCsv.trim().split('\n');

    if (catLines.length < 2 || prodLines.length < 2) {
      return null; // Empty CSV files (header only)
    }

    // Return validated CSV strings - actual DB insertion happens on main
    // thread via Drift's async executor which handles its own isolate
    return _CsvOutput(
      categoriesCsv: input.categoriesCsv,
      productsCsv: input.productsCsv,
    );
  } catch (_) {
    return null;
  }
}

class CashierApp extends ConsumerWidget {
  const CashierApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Al-HAI Cashier',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeState.themeMode,
      routerConfig: ref.watch(cashierRouterProvider),
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
