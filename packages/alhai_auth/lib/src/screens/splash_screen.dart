import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Supabase;
import '../core/monitoring/memory_monitor.dart';
import '../core/monitoring/production_logger.dart';
import '../security/secure_storage_service.dart';
import '../providers/auth_providers.dart';
import 'package:alhai_database/alhai_database.dart';
import 'package:alhai_l10n/alhai_l10n.dart';

enum _SplashStatus { loading, initSearch, loadData, initDemo, checkAuth, ready }

/// شاشة البداية - نقطة دخول التطبيق
///
/// تقوم بتهيئة التطبيق (DI, FTS, Database) مع عرض شاشة جميلة
/// ثم توجّه المستخدم لشاشة تسجيل الدخول
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  _SplashStatus _status = _SplashStatus.loading;

  @override
  void initState() {
    super.initState();
    _initializeAndNavigate();
  }

  Future<void> _initializeAndNavigate() async {
    final stopwatch = Stopwatch()..start();
    AppLogger.debug('Starting app initialization...', tag: 'SPLASH');

    try {
      // DI تمت بالفعل في main.dart (ضرورية قبل runApp)
      // هنا فقط العمليات البطيئة

      // 1. FTS - تهيئة البحث السريع (L54: runs in background isolate)
      setState(() => _status = _SplashStatus.initSearch);
      await _initializeFtsInBackground();
      AppLogger.debug('FTS: ${stopwatch.elapsedMilliseconds}ms', tag: 'SPLASH');

      // 2. Database Seeding
      setState(() => _status = _SplashStatus.loadData);
      await _seedDatabaseIfNeeded();
      AppLogger.debug('Seed: ${stopwatch.elapsedMilliseconds}ms', tag: 'SPLASH');

      // 3. Memory Monitor
      MemoryMonitor.instance.startMonitoring();

      stopwatch.stop();
      AppLogger.debug('Total init time: ${stopwatch.elapsedMilliseconds}ms', tag: 'SPLASH');
    } catch (e, stackTrace) {
      stopwatch.stop();
      AppLogger.error('Initialization error: $e', tag: 'SPLASH');
      ProductionLogger.error(
        'Splash initialization failed',
        tag: 'SPLASH',
        error: e,
        stackTrace: stackTrace,
      );

      // Show error feedback before navigating to login
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)?.errorOccurred ?? 'An error occurred during initialization',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    if (!mounted) return;

    // ======================================================================
    // منطق التوجيه الذكي:
    // 1. مصادق + عنده store_id محفوظ → مباشرة POS
    // 2. مصادق + بدون store_id → شاشة اختيار المتجر
    // 3. غير مصادق → شاشة تسجيل الدخول
    // ======================================================================
    if (mounted) setState(() => _status = _SplashStatus.checkAuth);

    final destination = await _determineDestination();
    AppLogger.debug('Navigation destination: $destination', tag: 'SPLASH');

    if (!mounted) return;
    context.go(destination);
  }

  /// تحديد وجهة التنقل بناءً على حالة المصادقة والمتجر المحفوظ
  Future<String> _determineDestination() async {
    // التحقق من جلسة Supabase
    bool isAuthenticated = false;
    try {
      final session = Supabase.instance.client.auth.currentSession;
      isAuthenticated = session != null;
      AppLogger.debug(
        'Supabase session: ${isAuthenticated ? "active" : "none"}',
        tag: 'SPLASH',
      );
    } catch (e) {
      AppLogger.debug('Supabase check failed: $e', tag: 'SPLASH');
    }

    // إذا Supabase غير متاح → تحقق من SecureStorage (الوضع المحلي / Web)
    if (!isAuthenticated) {
      try {
        final isSessionValid = await SecureStorageService.isSessionValid();
        if (isSessionValid) {
          isAuthenticated = true;
          AppLogger.debug('SecureStorage session: active (local mode)', tag: 'SPLASH');
        }
      } catch (e) {
        AppLogger.debug('SecureStorage session check failed: $e', tag: 'SPLASH');
      }
    }

    // إذا غير مسجل → شاشة الدخول
    if (!isAuthenticated) {
      return '/login';
    }

    // مسجل دخول → هل عنده store_id محفوظ؟
    try {
      final savedStoreId = await SecureStorageService.getStoreId();
      AppLogger.debug('Saved store_id: $savedStoreId', tag: 'SPLASH');

      if (savedStoreId != null && savedStoreId.isNotEmpty) {
        // تعيين store_id في Provider
        ref.read(currentStoreIdProvider.notifier).state = savedStoreId;
        return '/pos';
      }
    } catch (e) {
      AppLogger.debug('SecureStorage read failed: $e', tag: 'SPLASH');
    }

    // مسجل لكن بدون متجر → شاشة اختيار المتجر
    return '/store-select';
  }

  /// تهيئة Full-Text Search في خلفية (L54: offloaded from main thread)
  ///
  /// Note: Drift databases are tied to their creating isolate, so we cannot
  /// call db.initializeFts() inside compute(). Instead we schedule it as a
  /// microtask so the UI thread can paint before the work begins, and the
  /// actual SQL `CREATE VIRTUAL TABLE` runs asynchronously via Drift's
  /// built-in isolate-backed executor.
  Future<void> _initializeFtsInBackground() async {
    try {
      // On web, Isolate.run is unavailable; Drift's WASM executor already
      // runs SQL off-thread, so an awaited call is sufficient.
      if (kIsWeb) {
        await getIt<AppDatabase>().initializeFts();
      } else {
        // Yield to the UI thread first, then let Drift's native isolate
        // executor handle the heavy SQL work asynchronously.
        await Future.microtask(() async {
          await getIt<AppDatabase>().initializeFts();
        });
      }
      AppLogger.debug('FTS initialized successfully', tag: 'SPLASH');
    } catch (e) {
      AppLogger.warning('FTS not available: $e', tag: 'SPLASH');
    }
  }

  /// Seeds the database with demo data if it's empty
  Future<void> _seedDatabaseIfNeeded() async {
    if (!kDebugMode) return;
    try {
      final seeder = DatabaseSeeder(getIt<AppDatabase>());
      final isEmpty = await seeder.isDatabaseEmpty();

      if (isEmpty) {
        AppLogger.debug('Seeding database with demo data...', tag: 'SPLASH');
        if (mounted) setState(() => _status = _SplashStatus.initDemo);
        await seeder.seedAll();
        AppLogger.debug('Database seeded successfully', tag: 'SPLASH');
      } else {
        AppLogger.debug('Database already has data - skipping seed', tag: 'SPLASH');
      }
    } catch (e) {
      AppLogger.error('Database seeding error: $e', tag: 'SPLASH');
    }
  }

  String _getStatusText(_SplashStatus status, AppLocalizations l10n) {
    switch (status) {
      case _SplashStatus.loading: return l10n.loadingApp;
      case _SplashStatus.initSearch: return l10n.initializingSearch;
      case _SplashStatus.loadData: return l10n.loadingData;
      case _SplashStatus.initDemo: return l10n.initializingDemoData;
      case _SplashStatus.checkAuth: return 'جاري التحقق...';
      case _SplashStatus.ready: return l10n.pointOfSale;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // اللون الأخضر الطازج
    const primaryGreen = Color(0xFF10B981);
    const darkGreen = Color(0xFF059669);

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isDesktop = constraints.maxWidth >= 1200;
          final logoSize = isMobile ? 120.0 : isDesktop ? 200.0 : 150.0;
          final logoBorderRadius = isMobile ? 24.0 : isDesktop ? 40.0 : 30.0;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [primaryGreen, darkGreen],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // صورة الروبوت 3D
                  Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(logoBorderRadius),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(0, 0, 0, 0.25),
                          blurRadius: 30,
                          offset: Offset(0, 15),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.pointOfSale,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.surface,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 22 : isDesktop ? 32 : 26,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Al-HAI POS',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 48),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.surface),
                  ),
                  const SizedBox(height: 16),
                  // نص الحالة
                  Text(
                    _getStatusText(_status, l10n),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      ),
    );
  }
}
