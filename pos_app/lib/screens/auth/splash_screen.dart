import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../di/injection.dart';
import '../../core/monitoring/memory_monitor.dart';
import '../../core/monitoring/production_logger.dart';
import '../../data/local/seeders/database_seeder.dart';
import '../../l10n/generated/app_localizations.dart';

enum _SplashStatus { loading, initSearch, loadData, initDemo, ready }

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

      // 1. FTS - تهيئة البحث السريع
      setState(() => _status = _SplashStatus.initSearch);
      await _initializeFts();
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
        // Short delay so the user can see the error toast
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // التنقل لشاشة الدخول
    if (!mounted) return;
    context.go('/login');
  }

  /// تهيئة Full-Text Search
  Future<void> _initializeFts() async {
    try {
      await appDatabase.initializeFts();
      AppLogger.debug('FTS initialized successfully', tag: 'SPLASH');
    } catch (e) {
      AppLogger.warning('FTS not available: $e', tag: 'SPLASH');
    }
  }

  /// Seeds the database with demo data if it's empty
  Future<void> _seedDatabaseIfNeeded() async {
    if (!kDebugMode) return;
    try {
      final seeder = DatabaseSeeder(appDatabase);
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
      body: Container(
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
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.25),
                      blurRadius: 30,
                      offset: Offset(0, 15),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/mascot_robot.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.pointOfSale,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Al-HAI POS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 16),
              // نص الحالة
              Text(
                _getStatusText(_status, l10n),
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
