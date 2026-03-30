import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:alhai_core/alhai_core.dart';
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
      // DI + CSV seeding تمت بالفعل في main.dart
      // هنا نبدأ FTS في الخلفية بدون انتظار + نتحقق من المصادقة فوراً

      // 1. FTS - fire-and-forget (لا نحتاجه إلا عند البحث في POS)
      _initializeFtsInBackground();

      // 2. Memory Monitor
      MemoryMonitor.instance.startMonitoring();

      stopwatch.stop();
      AppLogger.debug('Init time: ${stopwatch.elapsedMilliseconds}ms', tag: 'SPLASH');
    } catch (e, stackTrace) {
      stopwatch.stop();
      AppLogger.error('Initialization error: $e', tag: 'SPLASH');
      ProductionLogger.error(
        'Splash initialization failed',
        tag: 'SPLASH',
        error: e,
        stackTrace: stackTrace,
      );
    }

    if (!mounted) return;

    // ======================================================================
    // منطق التوجيه الذكي - يبدأ فوراً بدون انتظار FTS أو seed
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
    // Wait for AuthNotifier to finish its own initialization
    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.initComplete.timeout(const Duration(seconds: 3));
    } catch (e) {
      AppLogger.debug('Auth init timeout: $e', tag: 'SPLASH');
    }

    final authState = ref.read(authStateProvider);
    final isAuthenticated = authState.status == AuthStatus.authenticated;

    AppLogger.debug(
      'Auth status: ${authState.status}',
      tag: 'SPLASH',
    );

    if (!isAuthenticated) {
      return '/login';
    }

    // Authenticated - restore store ID
    try {
      final savedStoreId = await SecureStorageService.getStoreId();
      AppLogger.debug('Saved store_id: $savedStoreId', tag: 'SPLASH');

      if (savedStoreId != null && savedStoreId.isNotEmpty) {
        ref.read(currentStoreIdProvider.notifier).state = savedStoreId;
        return '/pos';
      }
    } catch (e) {
      AppLogger.debug('SecureStorage read failed: $e', tag: 'SPLASH');
    }

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
