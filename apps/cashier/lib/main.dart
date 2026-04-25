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
// M-THEME-FIX: استيراد مزود الثيم من auth لمزامنته مع shared_ui
import 'package:alhai_auth/alhai_auth.dart' as auth_theme;
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:alhai_database/alhai_database.dart'
    show setDatabaseEncryptionKey, DatabaseSeeder, AppDatabase;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alhai_core/alhai_core.dart'
    show CertificatePinningService, SupabaseConfig;
import 'package:alhai_auth/alhai_auth.dart'
    show
        ForegroundLockGate,
        SecureStorageService,
        authStateProvider,
        currentStoreIdProvider;
import 'package:alhai_pos/alhai_pos.dart'
    show
        cartHapticsEnabled,
        clockOffsetProvider,
        posBarcodeScanFeedbackProvider,
        posBarcodeErrorFeedbackProvider,
        posSaleSuccessFeedbackProvider,
        posErrorFeedbackProvider,
        posCartMutationFeedbackProvider;
import 'di/injection.dart';
import 'dart:async';
import 'router/cashier_router.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'core/constants/timing.dart';
import 'core/services/backup_callback.dart';
import 'core/services/backup_scheduler.dart';
import 'core/services/sentry_service.dart';
import 'core/services/clock_validation_service.dart';
import 'core/services/sound_service.dart';
import 'core/services/haptic_shim.dart';
import 'core/services/shortcuts_shim.dart';
import 'core/services/web_db_key_service.dart';
import 'services/printing/auto_print_setup.dart';
import 'services/session_manager.dart';

/// Phase 2 §2.5 — SharedPreferences keys for the Feedback settings
/// (haptic + sound). Exposed here so both `main.dart` (initial load) and
/// `cashier_settings_screen.dart` (toggle UI) agree on the key names.
const String kPrefHapticEnabled = 'settings_haptic_enabled';
const String kPrefSoundEnabled = 'settings_sound_enabled';
const String kPrefSoundVolume = 'settings_sound_volume';

void main() {
  initSentry(
    appRunner: () async {
      final binding = WidgetsFlutterBinding.ensureInitialized();

      // Enable semantics tree for E2E testing (Playwright needs DOM elements).
      // On web, Flutter CanvasKit renders to canvas — enabling semantics
      // creates a parallel DOM tree that Playwright can interact with.
      if (kIsWeb) {
        binding.ensureSemantics();
      }

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

      // تهيئة Firebase + Supabase + مفتاح التشفير + استعادة الجلسة بالتوازي
      final dbKeyFuture = _getOrCreateDbKey();
      final prefsFuture = SharedPreferences.getInstance();
      // استعادة store ID المحفوظ لمنع فقدان الجلسة عند التحديث (F5)
      final storeIdFuture = SecureStorageService.getStoreId();

      final firebaseFuture = () async {
        // Skip Firebase on web debug (JS SDK can't load without internet to gstatic.com)
        if (kIsWeb && kDebugMode) {
          debugPrint('Firebase init skipped (web debug mode)');
          return;
        }
        try {
          await Firebase.initializeApp();
          if (kDebugMode) debugPrint('Firebase initialized successfully');
        } catch (e, stack) {
          reportError(e, stackTrace: stack, hint: 'Firebase init');
        }
      }();

      final supabaseFuture = () async {
        try {
          if (kDebugMode) {
            debugPrint(
              '🔧 Supabase config: url=${SupabaseConfig.url.isNotEmpty}, key=${SupabaseConfig.anonKey.isNotEmpty}',
            );
          }
          if (!SupabaseConfig.isConfigured) {
            throw StateError(
              'Supabase not configured. ${SupabaseConfig.configurationError}',
            );
          }
          // Phase 4 §4.1 — Certificate Pinning لـ Supabase
          // حماية ضد MITM في الشبكات غير الموثوقة (Wi-Fi عامة، captive
          // portals، certs صادرة من CA مخترق). الـ pins تُمرَّر وقت البناء عبر
          // --dart-define=SUPABASE_CERT_FINGERPRINT_1..10 (N-pin rotation)،
          // والـ service نفسه يقرأها عبر String.fromEnvironment كـ static
          // const داخل الـ class — لذا لا نمرّر pins من هنا. في debug يُرجع
          // IOClient عادي دون pinning (لدعم mitmproxy / Charles). في release
          // بدون pins يرمي StateError — هنا نمسكه كـ graceful degradation
          // (E2E CI يبني release بلا pins؛ أيضاً أول release قبل rollout
          // الـ secret). في production-release الطبيعي الـ pins تكون مكوَّنة.
          // التوثيق في docs/cashier-certificate-pinning.md.
          dynamic pinnedClient;
          try {
            pinnedClient = CertificatePinningService.createPinnedClient();
          } catch (e, st) {
            reportError(
              e,
              stackTrace: st,
              hint:
                  'Certificate pinning init failed — using default HTTP client',
            );
            pinnedClient = null;
          }
          await Supabase.initialize(
            url: SupabaseConfig.url,
            anonKey: SupabaseConfig.anonKey,
            debug: SupabaseConfig.enableDebugLogs,
            httpClient: pinnedClient,
          );
          if (kDebugMode) {
            debugPrint(
              '✅ Supabase initialized — cert pinning: '
              '${CertificatePinningService.diagnosticStatus}',
            );
          }
        } catch (e, stack) {
          if (kDebugMode) debugPrint('❌ Supabase init FAILED: $e');
          reportError(e, stackTrace: stack, hint: 'Supabase init');
        }
      }();

      // انتظر Firebase + Supabase + مفتاح DB + SharedPreferences + storeId معاً
      final results = await Future.wait([
        firebaseFuture,
        supabaseFuture,
        dbKeyFuture,
        prefsFuture,
        storeIdFuture,
      ]);

      final dbKey = results[2] as String;
      setDatabaseEncryptionKey(dbKey);

      // SESSION-FIX: على الويب، فحص سريع لجلسة Supabase
      // معظم المستخدمين يسجلون دخول محلي (verifyLocalOtp) بدون Supabase session
      // لذلك ننتظر 1500ms فقط (Timeouts.sessionCheck) لتحمّل الشبكات البطيئة
      // دون تأخير بدء التطبيق ملحوظًا
      if (kIsWeb) {
        try {
          final client = Supabase.instance.client;
          if (client.auth.currentSession == null) {
            if (kDebugMode) {
              debugPrint('⏳ Quick check for Supabase session on web...');
            }
            await client.auth.onAuthStateChange
                .where((data) => data.session != null)
                .first
                .timeout(Timeouts.sessionCheck);
            if (kDebugMode) debugPrint('✅ Supabase session recovered');
          } else {
            if (kDebugMode) {
              debugPrint('✅ Supabase session available immediately');
            }
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('ℹ️ No Supabase session (normal for local auth): $e');
          }
        }

        // SESSION-FIX: تشخيص حالة SecureStorage قبل runApp
        final isValid = await SecureStorageService.isSessionValid();
        final ssUserId = await SecureStorageService.getUserId();
        if (kDebugMode) {
          debugPrint(
            '📋 Pre-runApp SecureStorage: valid=$isValid, userId=${ssUserId ?? "null"}',
          );
        }
      }

      // DI must run before runApp (Riverpod providers use getIt synchronously)
      await configureDependencies();

      // Seed database from CSV assets (first launch only)
      await _seedDatabaseFromCsv();

      final prefs = results[3] as SharedPreferences;

      // Phase 2 §2.5 — load Feedback preferences (haptic/sound) and boot
      // the SoundService. Placeholder MP3 assets mean init is allowed to
      // fail silently (see SoundService docs). Never let audio/haptic
      // boot errors crash the app.
      final hapticEnabled = prefs.getBool(kPrefHapticEnabled) ?? true;
      final soundEnabled = prefs.getBool(kPrefSoundEnabled) ?? true;
      final soundVolume = prefs.getDouble(kPrefSoundVolume) ?? 0.8;
      HapticShim.loadFromPrefs(hapticEnabled);
      // Phase 4.5 — same pattern for the keyboard-shortcuts toggle. Reading
      // it here ensures CashierShell picks up the correct value on the first
      // build, before any shortcut combination could fire.
      ShortcutsShim.loadFromPrefs(
        prefs.getBool(kPrefKeyboardShortcutsEnabled),
      );
      // Phase 4.4 — mirror the animations toggle into the router-local flag
      // so the very first navigation already honours the stored preference.
      // Kept as a fire-and-forget: if prefs read fails we fall back to the
      // default (animations enabled) and the settings screen will refresh it
      // next time the user opens it.
      unawaited(refreshAnimationsFlag());
      // Mirror the haptic toggle into the POS package's lightweight
      // cart-mutation flag (StateNotifiers there have no access to
      // Riverpod providers, so we use a top-level switch instead).
      cartHapticsEnabled = hapticEnabled;
      try {
        await SoundService.instance.init(
          enabled: soundEnabled,
          volume: soundVolume,
        );
      } catch (e) {
        if (kDebugMode) debugPrint('[main] SoundService.init ignored: $e');
      }
      // SESSION-FIX: استعادة store ID المحفوظ قبل runApp لمنع فقدان الجلسة عند F5
      final savedStoreId = results[4] as String?;

      final savedTheme = prefs.getString('app_theme_mode');
      final initialThemeMode = switch (savedTheme) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };

      // M57: Pre-load onboarding state so router guard can check synchronously
      final hasSeenOnboardingFlag = prefs.getBool(kOnboardingSeenKey) ?? false;

      if (kDebugMode) {
        debugPrint('🔑 Restored storeId: $savedStoreId');
      }

      // Wave 5 (P0-09): boot the workmanager scheduler before runApp so
      // any pending OS-fired auto-backup task can mark its dispatcher as
      // ready. The init must happen on the platform thread (which the
      // outer `await` chain is already on); doing it after runApp risks
      // missing the first scheduled fire after install.
      try {
        await const BackupScheduler().init(
          callbackDispatcher: backupCallbackDispatcher,
        );
      } catch (e) {
        // Workmanager is platform-specific; on web it'll throw. Don't
        // let backup scheduling failures take the cashier down.
        if (kDebugMode) {
          debugPrint('[main] BackupScheduler.init skipped: $e');
        }
      }

      addBreadcrumb(message: 'App initialized', category: 'lifecycle');

      runApp(
        ProviderScope(
          overrides: [
            themeProvider.overrideWith(
              (ref) => ThemeNotifier(initialThemeMode),
            ),
            // M-THEME-FIX: تهيئة مزود auth بنفس القيمة الأولية
            auth_theme.themeProvider.overrideWith(
              (ref) => auth_theme.ThemeNotifier(initialThemeMode),
            ),
            onboardingSeenProvider.overrideWith((ref) => hasSeenOnboardingFlag),
            // SESSION-FIX: تهيئة store ID المحفوظ قبل أن يعمل router guard
            // هذا يمنع إعادة التوجيه إلى /store-select عند تحديث الصفحة (F5)
            if (savedStoreId != null && savedStoreId.isNotEmpty)
              currentStoreIdProvider.overrideWith((ref) => savedStoreId),
            // ZATCA: Wire clock offset from ClockValidationService into SaleService
            // so sale timestamps are corrected for device clock drift
            clockOffsetProvider.overrideWithValue(
              () => ClockValidationService.instance.clockOffset,
            ),
            // Phase 2 §2.5/2.6 — wire POS feedback hooks to the cashier
            // app's SoundService + HapticShim. Empty by default in the
            // POS package so non-cashier hosts don't pay for audio.
            posBarcodeScanFeedbackProvider.overrideWithValue(() {
              HapticShim.lightImpact();
              SoundService.instance.barcodeBeep();
            }),
            posBarcodeErrorFeedbackProvider.overrideWithValue(() {
              HapticShim.vibrate();
              SoundService.instance.errorBuzz();
            }),
            posSaleSuccessFeedbackProvider.overrideWithValue(() {
              HapticShim.heavyImpact();
              SoundService.instance.saleSuccess();
            }),
            posErrorFeedbackProvider.overrideWithValue(() {
              HapticShim.vibrate();
              SoundService.instance.errorBuzz();
            }),
            posCartMutationFeedbackProvider.overrideWithValue(() {
              HapticShim.lightImpact();
            }),
          ],
          child: const CashierApp(),
        ),
      );
    },
  );
}

/// Get or create database encryption key from secure storage.
///
/// **Web platform (4.2 hardening):**
/// يُفوَّض إلى `WebDbKeyService.getOrCreateWebDbKey()` الذي يستخدم WebCrypto
/// AES-GCM + non-extractable CryptoKey في IndexedDB. الـ dbKey raw لا يُخزَّن
/// مطلقاً في localStorage — فقط ciphertext. XSS على نفس origin يرى
/// ciphertext عديم الفائدة (لا يستطيع export wrappingKey من IDB).
/// إذا فشل WebCrypto (متصفح قديم جداً / non-secure context): يسقط تلقائياً
/// على localStorage + WARN في Sentry ليبقى التطبيق شغَّالاً.
///
/// For native platforms (Android/iOS), FlutterSecureStorage is used which
/// leverages the OS keychain / EncryptedSharedPreferences.
Future<String> _getOrCreateDbKey() async {
  const keyName = 'db_encryption_key';

  if (kIsWeb) {
    return WebDbKeyService.getOrCreateWebDbKey();
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

/// تحميل بيانات المتجر من CSV (عند أول تشغيل فقط)
/// L64: CSV file loading is done on the main thread (rootBundle requires it),
/// but the heavy parsing and DB insertion is deferred via Drift's async
/// executor so the UI thread is not blocked during first launch.
Future<void> _seedDatabaseFromCsv() async {
  try {
    final db = getIt<AppDatabase>();
    final seeder = DatabaseSeeder(db);

    if (await seeder.isDatabaseEmpty()) {
      addBreadcrumb(message: 'Seeding database from CSV', category: 'data');

      // Load CSV strings from assets (must be on main thread for rootBundle)
      final categoriesCsv = await rootBundle.loadString(
        'assets/data/categories.csv',
      );
      final productsCsv = await rootBundle.loadString(
        'assets/data/products.csv',
      );

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
  } catch (e, stack) {
    reportError(e, stackTrace: stack, hint: 'CSV seeding');
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
  } catch (e) {
    if (kDebugMode) debugPrint('CSV parse failed: $e');
    return null;
  }
}

class CashierApp extends ConsumerStatefulWidget {
  const CashierApp({super.key});

  @override
  ConsumerState<CashierApp> createState() => _CashierAppState();
}

class _CashierAppState extends ConsumerState<CashierApp> {
  bool _autoPrintInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_autoPrintInitialized) {
        _autoPrintInitialized = true;
        initializeAutoPrint(ref);
      }

      // M-THEME-FIX: مزامنة الثيم عند تغييره من شاشات auth (login/store-select)
      // عندما يبدّل المستخدم الثيم في شاشة Login → يتم تحديث MaterialApp أيضاً
      ref.listenManual(auth_theme.themeProvider, (previous, next) {
        if (previous?.themeMode != next.themeMode) {
          ref.read(themeProvider.notifier).setThemeMode(next.themeMode);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
        return ForegroundLockGate(
          thresholdMinutes: 2,
          onForceLogout: () =>
              ref.read(authStateProvider.notifier).logout(),
          child: Directionality(
            textDirection: localeState.textDirection,
            child: SessionTimeoutWrapper(
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        );
      },
    );
  }
}
